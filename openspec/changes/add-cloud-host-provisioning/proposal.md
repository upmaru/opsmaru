# Proposal

## Why

Opsmaru is the universal control plane for Incus: sandboxes (containers and VMs) are always created through Incus, whatever machine Incus runs on. Today a target must already exist before it can be registered. To offer compute on demand, central Opsmaru needs to create a cloud VM on AWS, GCP or DigitalOcean, install Incus on it and register it as a target, so that everything afterwards goes through the normalized Incus tools.

Because Incus is the normalized plane, the cloud-specific surface is deliberately small: an instance, its network and firewall, and a bootstrap script. That is a handful of API calls per provider, which does not justify a Terraform/OpenTofu runtime, a second state store or an agent sequencing raw cloud primitives.

## What Changes

- Add cloud host provisioning to central (standalone) Opsmaru: create a VM and its networking on a supported provider, install and configure Incus on it, and register it as a direct-HTTPS Incus target in the registry from [add-compute-substrate](../add-compute-substrate/proposal.md).
- Implement providers as native adapters behind one `Opsmaru.Provisioning.Provider` behaviour (ensure network, ensure firewall, ensure instance, describe, destroy). AWS, GCP and DigitalOcean are the first three. Adapters call the provider HTTP APIs directly; no cloud CLI and no Terraform/OpenTofu binary is invoked.
- Store each host as a desired-state record in PostgreSQL and drive it with a reconciler through `requested → creating → bootstrapping → registering → ready`, with `failed`, `destroying` and `destroyed`. Each step is idempotent, records the provider's native operation identity before continuing and resumes after a restart without repeating an accepted mutation.
- Label every created cloud resource with the Opsmaru host ID, so ownership is provable and resources left by a failure can be found. Resources the administrator supplied (an existing network) are never modified or destroyed.
- Bootstrap Incus with one provider-neutral cloud-init template: pinned OS image family, pinned Incus package source, a preseed (storage pool, bridge, HTTPS listener) and trust of a client certificate dedicated to that host. Opsmaru does not open SSH or run commands on the host.
- Register through a one-use enrolment token: the new host calls back to Opsmaru with its Incus server certificate fingerprint. Opsmaru pins that fingerprint and connects only to the address the provider API reports, never to an address supplied by the callback.
- After registration, read container and VM driver availability from Incus and record it as target capability. VM sandboxes depend on nested virtualization, which varies by provider and instance type; Opsmaru reports what Incus observed rather than predicting it.
- Hold provider credentials as encrypted provider accounts managed by an administrator. Callers and agents refer to an account by ID and never receive or supply cloud credentials.
- Expose a coarse MCP/REST surface: list provider accounts and options, plan a host, provision it, read its status and destroy it. There are no tools for individual cloud primitives. Destroy requires explicit destructive confirmation and a destructive scope.
- Revise the note in add-compute-substrate that defers "Terraform jobs" to a later change: for Incus host creation this change chooses native adapters instead. A Terraform/OpenTofu adapter behind the same behaviour remains possible later if scope grows beyond hosts.

## Capabilities

### New Capabilities

- `cloud-provisioning`: provider accounts, host specification, reconciled lifecycle, resource ownership, teardown and the coarse operation surface.
- `host-bootstrap`: provider-neutral Incus installation, enrolment callback, certificate pinning, registry handoff and observed capability recording.

### Modified Capabilities

None in the main inventory. This change consumes the target registry, direct-HTTPS trust and durable task contracts proposed in add-compute-substrate and the user authorization and administration surface proposed in [add-remote-api-and-oauth](../add-remote-api-and-oauth/proposal.md); it does not redefine them.

## Impact

- Depends on add-compute-substrate sections 4, 5 and 7 (durable tasks, registry and direct HTTPS adapter, central startup) and on add-remote-api-and-oauth for verified callers, grants and secret protection. It cannot be implemented before those.
- Central mode only. Embedded and connector-only roles start no provisioning process, provider client or callback route. `:opsmaru_incus` is unchanged; no Macus or Swift code is involved.
- New persistent data: provider accounts (encrypted credentials), hosts, per-host resource records and enrolment tokens. New outbound network access from central to provider APIs, and one new inbound callback route.
- Provisioning creates billable resources in the operator's cloud account. A failed host keeps its resources until an explicit destroy; destroying a ready host deletes the Incus data on its disk.
- Out of scope: Incus clustering across hosts, autoscaling, placement or scheduling, DNS, load balancers, managed databases, custom image baking, user-supplied Terraform modules and hosts that reach central only through the outbound connector.
- Each provider is advertised only after its own live acceptance in a dedicated test account. Fixture checks against recorded provider responses are separate evidence and do not count as provider support. No cloud resource is created, and no service deployed, by this planning change.
