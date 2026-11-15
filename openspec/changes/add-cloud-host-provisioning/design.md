# Design

## Context

See [proposal.md](proposal.md) for motivation. Central Opsmaru manages registered Incus targets over native HTTPS with a dedicated client certificate per target ([add-compute-substrate](../add-compute-substrate/design.md), decision 4). Registration there assumes the target already exists and explicitly creates no workloads or provider accounts. This change adds the step before it: creating the machine and putting Incus on it.

None of this is implemented. The Phoenix scaffold exists; the registry, durable tasks and authorization this change builds on are themselves still proposals.

```text
Agent / REST caller
   | plan_host, provision_host, host_status, destroy_host
   v
central Opsmaru ── host record (desired state) ── reconciler task
   |                                                  |
   | 1. create     provider adapter (AWS | GCP | DigitalOcean)
   |               network, firewall, instance + user-data
   | 2. bootstrap  cloud-init on the VM: install Incus, preseed,
   |               trust host client cert, call back with fingerprint
   | 3. register   pin fingerprint, connect via :opsmaru_incus,
   |               record capabilities, add to target registry
   v
registered Incus target ── normal Incus tools from here on
```

Only step 1 differs between clouds.

## Goals / Non-Goals

**Goals:**

- One request turns into a ready, registered Incus target on AWS, GCP or DigitalOcean without the caller touching the provider.
- Deterministic, resumable provisioning: the same host record always converges on the same resources, and a crash never duplicates or silently loses a billable resource.
- A small provider contract, so a fourth provider is one adapter plus its acceptance run.
- The agent chooses intent (provider, region, size); it never sequences cloud primitives or holds cloud credentials.

**Non-Goals:**

- General infrastructure management: DNS, load balancers, managed databases, IAM, object storage.
- Incus clustering, autoscaling, placement or scheduling. Each provisioned host is one standalone Incus server.
- Running Terraform/OpenTofu, a cloud CLI, SSH or any configuration-management tool from Opsmaru.
- Baking custom images. Bootstrap starts from a stock provider image.
- Hosts that can only dial out. The outbound connector path stays as specified in add-compute-substrate and is not provisioned here.
- Any provisioning in embedded or connector-only roles.

## Decisions

### 1. Native provider adapters, not Terraform

Each provider implements one behaviour:

```elixir
@callback ensure_network(account, host, spec) :: {:ok, resources} | {:pending, operation} | {:error, reason}
@callback ensure_firewall(account, host, spec) :: ...
@callback ensure_instance(account, host, spec, user_data) :: ...
@callback describe(account, host) :: {:ok, observed}
@callback destroy(account, host, resources) :: ...
@callback options(account) :: {:ok, %{regions: [...], sizes: [...]}}
```

Every `ensure_*` is idempotent: it looks up resources by the host label first and creates only what is missing.

| Provider | Network | Firewall | Idempotency on create |
|---|---|---|---|
| AWS | VPC, subnet, internet gateway, route | Security group | `ClientToken` |
| GCP | VPC network, subnetwork | Firewall rules by target tag | `requestId` |
| DigitalOcean | VPC | Cloud firewall | none; deterministic name plus tag lookup |

Alternatives considered:

- **Terraform/OpenTofu with stored modules.** Gives broad provider coverage, but adds a binary to ship and shell out to, a state file that competes with the host record as the source of truth, and failures reported as log text rather than native operation identity. The surface needed here is five to eight API calls per provider, so the coverage is not used.
- **Fine-grained MCP tools orchestrated by the agent.** Makes the agent the determinism layer. A dropped session mid-sequence leaves orphaned billable resources that nothing owns.

A Terraform/OpenTofu adapter can implement the same behaviour later if hosts need infrastructure beyond this surface.

### 2. Host record as desired state, driven by a reconciler

A host row holds the specification (provider account, region, size, disk, network choice), the current phase and the registry target it produced. Resource rows hold each cloud resource's kind, provider ID, native operation ID and whether Opsmaru created it.

```text
requested → creating → bootstrapping → registering → ready
     \________\____________\_____________\→ failed
ready | failed → destroying → destroyed
```

The reconciler runs as a durable task under the central SQL task store from add-compute-substrate. It performs one step, commits the outcome and the native operation ID, then schedules the next. After a restart it resumes from the committed phase. If a create call may have been accepted but its ID was not recorded, the reconciler looks the resource up by label instead of repeating the call; if that is inconclusive it records the uncertainty and stops for an operator rather than guessing.

Each phase has a deadline. Exceeding it moves the host to `failed` with the phase and last provider response retained.

### 3. Ownership labels and failure handling

Every resource Opsmaru creates carries the host ID and the installation ID as provider tags or labels. Destroy acts only on resources that are both recorded for the host and still carry its label.

A failed host keeps its resources. This follows the project rule to preserve backend data after failures, and it keeps the evidence for diagnosis. The cost is that a failed host keeps billing until someone destroys it, so status reports list the retained resources and a host in `failed` is surfaced in readiness. Retrying a failed host resumes from the failed phase.

If the specification names an existing network, Opsmaru records it as supplied, attaches to it and never changes or deletes it.

### 4. Bootstrap by cloud-init only

One template, rendered per host, is passed as instance user-data on all three providers. It:

1. installs Incus from a pinned package source on a pinned stock OS image family;
2. applies a preseed: one storage pool on the instance disk, one managed bridge, the HTTPS listener on port 8443;
3. adds the host's dedicated client certificate (public part only) to the Incus trust store;
4. posts the Incus server certificate fingerprint to the Opsmaru enrolment callback with the one-use token.

Opsmaru never opens SSH and the firewall does not allow it by default. Anything that would need a shell on the host is out of scope; a host that fails bootstrap is diagnosed from the provider's console output and replaced.

The firewall allows inbound 8443 only from central's configured egress addresses. Provisioning refuses to start if those are not configured, rather than opening the Incus API to the internet.

### 5. Enrolment callback and certificate pinning

Before creating the instance, Opsmaru generates the per-host client key pair (private key stays central, encrypted) and a random one-use enrolment token bound to the host ID with a short expiry.

User-data is readable by any process on the instance and by anyone with read access to the cloud account, so the token must not be enough to redirect Opsmaru:

- the callback supplies only a fingerprint; it cannot supply an address;
- Opsmaru connects to the address the provider API reports for that instance;
- the token is accepted once, only while the host is in `bootstrapping`, and is invalidated on use, expiry or destroy.

A stolen token could therefore register a wrong fingerprint, which makes the real host fail to connect (a visible failure), but cannot make Opsmaru trust a different machine. No private key and no provider credential is ever placed in user-data.

### 6. Registration hands off to the existing registry

Once the pinned fingerprint verifies, Opsmaru creates the target through the same registry contract an administrator-registered direct-HTTPS target uses: stable target ID, generation, credential reference and permitted projects. The host record links to the target; the target does not need to know it was provisioned. Grants on the new target follow the normal grant model, with the requesting principal recorded as the host's owner.

Capabilities come from Incus after connection: the instance drivers it reports decide whether containers, VMs or both are available. Opsmaru keeps no per-cloud table of which sizes support nested virtualization. A plan may warn that VM support is unverified until the host is ready.

### 7. Provider accounts and credentials

A provider account is an administrator-managed record: provider, a label, and credentials encrypted under the secret protection from add-remote-api-and-oauth. Grants decide which principals may provision against which account. Tool and API inputs carry only the account ID. Credentials are never returned, logged or included in task records.

Documentation states the minimum provider permissions per adapter (instance, network and firewall management in the chosen regions) so operators can scope the credential.

### 8. Coarse operation surface

| Operation | Effect | Scope |
|---|---|---|
| `list_provider_accounts`, `list_provider_options` | Accounts the caller may use; regions and sizes | read |
| `plan_host` | Validates a specification and lists what would be created. Creates nothing | read |
| `provision_host` | Creates the host record and starts the reconciler; returns a task | provision |
| `host_status` | Phase, resources, linked target, failure detail | read |
| `destroy_host` | Removes the target registration and the owned resources | destructive, with explicit confirmation |

MCP and REST adapt the same operations, as in add-remote-api-and-oauth decision 5. Destroying a host that still has Incus instances requires a second explicit acknowledgement naming the host, because the instances' data is on the disk being deleted.

### 9. Central only

Provisioning supervision, provider HTTP clients and the callback route start only in standalone mode and only when provisioning is enabled in configuration. Loading `:opsmaru` embedded, or running the connector-only role, starts none of them.

## Risks / Trade-offs

- **Cost leak from retained failures.** Mitigated by labels, status reporting and readiness surfacing; not by automatic deletion.
- **Three hand-written API clients to maintain.** The surface per provider is small and pinned to recorded fixtures plus a live acceptance run; provider API changes show up there.
- **Inbound-only reachability.** A host must have a public address reachable from central. Operators who cannot allow that need the connector path, which this change does not provision.
- **Stock image drift.** A new upstream image or Incus package can break bootstrap. The image family and package source are pinned and changed deliberately.
- **Depends on unimplemented proposals.** The registry, task store and authorization must land first; this change cannot be accepted ahead of them.

## Open Questions

- Which OS image family and Incus package channel to pin first (for example Debian stable or Ubuntu LTS with the Zabbly packages).
- Whether the first release should allow a supplied existing network, or only Opsmaru-created networks.
- Whether one Opsmaru-created network per account and region is shared by hosts, or each host gets its own.
- Whether a host without a public address (private subnet plus the outbound connector) should be a follow-up change.
- Disk layout: a single root disk with a directory or loop-backed pool, or a second attached volume for a ZFS/Btrfs pool.
