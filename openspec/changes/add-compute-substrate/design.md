# Design

## Context

See [proposal.md](proposal.md) for motivation. First complete [add-embedded-incus-foundation](https://github.com/upmaru/opsmaru-incus/blob/feature/incus-client/openspec/changes/add-embedded-incus-foundation/design.md), now in `upmaru/opsmaru-incus`, for the native client library. This later change consumes it; MCP/local tasks, central registry/SQL and connectors are not gates on that first milestone. `git@github.com:upmaru/opsmaru.git` was empty when checked out; the initial proposal was a greenfield planning baseline. The subsequent explicit bootstrap request generated a root Phoenix/Cowboy project with PostgreSQL/Ecto and HTML/LiveView assets on feature/phoenix-bootstrap-and-remote-access. Baseline tests and embedded startup pass; shared compute functions remain unimplemented.

The integration reference is Macus's `add-elixir-server` change on `feature/elixir-server`. Its current implementation has a headless Phoenix scaffold, module boundary stubs, pinned Incus reference inventory/differential fixtures and a successful fixture-only Cowboy transport trial. Seven original tasks are checked; shared client methods, MCP tools, production gateway and durable tasks are pending. Macus uses Phoenix 1.8.15, Plug.Cowboy 2.9.0, Cowboy 2.19.0 and TamaMCP 0.1.1 in its current lockfile. These are a verified compatibility baseline for dependency resolution, not a mandate to publish those versions or claim new acceptance.

The reference client is Incus v7.0.1 at `13f3992766142d5087fff2e362cd2e1a75294fe8`. Macus owns the initial provenance and fixture inputs. Transfer reusable evidence with notices during implementation; retain consumer-specific evidence in Macus. TamaMCP currently compiles catalogues from explicitly registered tool modules and accepts application-owned authorization/cache/task adapters. It has no production durable store or web server of its own.

## Goals / Non-Goals

**Goals:**

- One shared library and central Phoenix service whose compute semantics are reusable inside standalone Macus and optional Linux connectors.
- One central authenticated MCP/REST gateway managing registered targets, with direct Incus HTTPS and outbound connector execution; Macus retains its local composed MCP endpoint.
- Native Incus behavior, truthful method/capability coverage and durable execution bound to caller and host identity.
- An embedded mode with no dependency-owned endpoint process, listener, installation or outer-runtime lifecycle side effect.

**Non-Goals:**

- Moving Swift/VZ, Macus's private relay, public endpoint/authentication/trust ownership or macOS installer into Opsmaru. Optional portable proxy mechanics are separately specified by [add-embeddable-incus-gateway](../add-embeddable-incus-gateway/design.md); consuming them does not transfer Macus host ownership or expose a central multi-target native proxy.
- Replacing Incus with another workload manager, adding workload placement/scheduling or a Tama reasoning engine, and imposing a full Opsmaru server beside each cluster.
- Environment-image recipes, skill bundling, worktree creation, source synchronization, workspace provisioning, service previews or arbitrary host-shell tools in this foundation.
- A second `opsmaru_server` Mix project or required second BEAM on macOS. The earlier two-package sketch is superseded by the requested single Phoenix application.
- Package publication, deployment, workload mutation or real-host acceptance during planning.

## Decisions

### 1. One root Phoenix application with optional standalone web/persistence

Use one Mix application `:opsmaru`, modules `Opsmaru` and `OpsmaruWeb`, with the explicitly requested PostgreSQL/Ecto, HTML/LiveView and assets for central external OIDC sign-in, target/user policy and central task persistence. Pin toolchains and lock dependencies compatible with the Macus Phoenix/Cowboy baseline. Keep the Cowboy2 adapter and omit mailer/dashboard/gettext scaffolding. Embedded supervision must not start its own Repo or web endpoint. Central identity/enrollment/REST feature implementation belongs to [add-remote-api-and-oauth](../add-remote-api-and-oauth/design.md).

```text
lib/opsmaru/
  application.ex       mode-aware supervision
  incus/               portable typed client and transports
  targets/             authorized registry and registered target adapters
  connector/           outbound sessions, execution receipts and stream workers
  host/                local provider and capability contracts
  mcp/                 shared tools, catalogue inclusion and cache adapter
  tasks/               shared store/runner contracts, SQL outbox and local journal
  auth/                common policy/context and standalone credential adapter
lib/opsmaru_web/
  endpoint.ex          standalone-only endpoint
  router.ex            central /mcp, /api/v1 and authenticated connector upgrades
config/
test/
packaging/linux/
```

The shared client is `Opsmaru.Incus`, delivered as the separate pure `:opsmaru_incus` library (`upmaru/opsmaru-incus`) and pinned here as a Git dependency. It is isolated from Phoenix, MCP and host runtime code. It was extracted from this application on 2026-10-13 without changing its module names.

Alternatives: two Mix projects add versioning and wiring before there is separate functionality; placing a complete duplicate service in Macus defeats the shared boundary. One application with an opt-in endpoint satisfies the requested deployment modes.

### 2. Explicit embedded, central and connector-only roles

Keep `deployment_mode: :embedded` as the library default. Existing `:standalone` means the central Phoenix service; add an explicit `:connector` role for small Linux outbound installations. Roles are mutually exclusive and configured before startup. Ambient PHX_SERVER/PORT cannot create an endpoint, repository or central role in embedded/connector mode. The current scaffold only implements the original embedded/standalone startup; the new role is a future task.

Central mode starts its configured Repo, registry, central task store/outbox, authenticated MCP/REST and connector ingress. Empty target registration is valid: the central service must start so an administrator can enroll its first target. It needs no local Incus install, host VM or default backend. Missing database, external identity or TLS configuration fails preflight; a registered unavailable backend affects only that target's readiness.

Macus supplies its private sockets, local identity/provider and journal and starts the shared application once inside its existing BEAM. Its optional outbound connector is another configured worker subtree in the same server, disabled until explicit enrollment. No Opsmaru endpoint, Repo, launchd job or mandatory central connection exists in Macus. Connector-only Linux starts outbound session/receipt workers and a configured local Incus client, without Repo, inbound listener, MCP surface, UI or local user database.

Unconfigured inclusion is inert and creates no state or backend contacts. Configured local execution waits for trusted host readiness. Central/connector shutdown or restart must not implicitly stop Incus, Swift or workloads. Target/provider identifiers replace fixed global host paths; each selected Macus state has isolated connector identity and receipt storage. No Erlang distribution is introduced.

Alternative: deploying the entire Phoenix app beside every cluster duplicates identity/UI state. Direct HTTPS requires no target agent; a listener-free connector handles networks that require outbound connectivity.

### 3. The host mounts a shared MCP contract and composes its catalogue

The designated MCP dependency is [kritama/tama-mcp](https://github.com/kritama/tama-mcp), OTP application `:tama_mcp` and module namespace `TamaMCP`. Opsmaru consumes its supported JSON-RPC, schemas, transport, tool compilation and task contracts rather than implementing or selecting an alternative protocol engine. Reusable protocol gaps belong in that library; Opsmaru owns compute tools, authorization policy, persistence and host integration. Pin a verified package release or immutable revision, never an editable production sibling path. Shared tools live under `Opsmaru.MCP.Tools.*`; expose a documented compile-time inclusion helper or explicit registration list and immutable names/schemas/scopes. Host composition uses TamaMCP's existing tool DSL, not mutable runtime code loading. Reject duplicate names during compilation.

```text
Agent or Tama --> central Opsmaru /mcp + /api/v1
                  OIDC + target grants + SQL tasks/outbox
                    |--> native HTTPS/mTLS --> Incus cluster A
                    |--> native HTTPS/mTLS --> Incus server B
                    |<-- outbound connector -- private Linux --> Incus
                    |<-- outbound connector -- Macus Elixir --> Incus/Swift

Standalone Macus /mcp + /runtime + native /1.0/*
  shared tools + Macus runtime tools + local journal
  Opsmaru.Incus --> incus.sock; Macus.Runtime --> runtime.sock
  connector is optional in this BEAM; Opsmaru endpoint/Repo is absent
```

The central tool catalogue is built from shared operation descriptors and known versioned host-capability descriptors, with execution routed through a target adapter. Macus supplies the implementations of its runtime descriptors; central Opsmaru never executes VZ code or caller-selected modules. Unknown/incompatible host descriptors are rejected, not loaded dynamically.

Shared schemas include optional `target_id`. Central invocation requires an explicit registered target for targeted operations, particularly mutations; there is no mutable global default target. Local Macus calls may omit it to use the one configured local target, and an explicit different target fails. Permission-filtered target discovery is separate from workload discovery; project and cluster-member fields remain native selections within the chosen target. A cluster is one registered backend with optional member routing, not a new Opsmaru cluster membership mechanism.

Mount the maintained Streamable HTTP Plug with the composed catalogue and explicitly configured authorization, validator cache, task store and runner. Shared schemas and results remain identical across direct and connected execution. Macus runtime operations are selectable centrally only for a Macus target that explicitly advertises/permits their registered descriptors. Incus-only targets expose no outer-runtime operations. Central Opsmaru is an operation gateway, not an aggregate native `/1.0` proxy; normal Incus clients retain native target endpoints.

Initial shared tools cover server/instance/image/project/profile/network/storage inspection; explicit instance/state/image/snapshot mutations; destructive deletion/restore with explicit confirmation; and bounded guest exec. Document every exported tool name and scope. Host capability inspection is passive. Higher-level environment and workspace tools are separate future additions.

### 4. Target registry and three separate trust boundaries

The registry stores a stable opaque `target_id`, registration generation, display metadata, kind (`incus_server`, `incus_cluster`, `macus`), transport, approved backend configuration/credential references, owner/authorization partition, local project/tool permissions, observed capabilities, readiness and revocation state. Server-generated target IDs are not addresses or display names. Credential changes, re-enrollment and replacement backend identity never silently rebind existing tasks. An incompatible replacement requires a new generation/target and explicit reconciliation; preserve historical receipts/tasks.

Only approved registration administration sets backend addresses and server trust. Agent operations use registered target IDs and cannot change URLs, credential references, owner identity or host paths. Validate admin endpoint configuration against explicit network policy, TLS identity and bounded redirects before probing, including documented Incus operation/WebSocket/migration addresses; untrusted backend-returned addresses cannot redirect credentials outside the authorized target. Connection pools, caches, capabilities and events are partitioned by target and registration generation.

Central users authenticate through external OIDC; their effective access intersects token scopes/client identity with local target/project/tool grants. Direct Incus access uses a dedicated registered client certificate/private key and verifies server CA/fingerprint. Prefer project-restricted Incus credentials where their native policy covers the operation; broad credentials still require central checks before access. OIDC user tokens are not passed to Incus, and Incus login is not required for central users.

Connectors authenticate using an enrolled device certificate/private key and verify the configured central HTTPS identity. Enrollment is a short-lived one-use challenge bound to an OIDC-authorized registering user, exact central service, public key proof, target and maximum approved capabilities/projects. Central stores public certificate/fingerprint and grant metadata, not the device private key. Self-generated device certificates are enrolled explicitly; there is no new OAuth token issuer. Connector identity permits its own session/receipts only, never user API access or arbitrary targets. Replay, expired challenges and wrong-key completion fail. Users, backend credentials and devices have independent revocation.

For a connected dispatch, central policy constructs the verified principal/owner, operation/version, target/generation, project, input digest, task/dispatch ID, deadline and authorization snapshot. The authenticated session binds the envelope; arbitrary request owner fields cannot enter it. The connector accepts only its exact active registration and locally approved operation/project limits, revalidates schema/destructive inputs and executes through its configured adapter. A central user never becomes the local Mac owner implicitly. Local revocation or reduced enrollment permissions block new dispatch even if central asks otherwise.

The common operation boundary handles central and standalone Macus authorization, but the credential-verification adapters differ. Local Macus bearer/certificate trust remains independent; no central OIDC secrets or database are mandatory there.

### 5. Consume the independently delivered portable client

The first add-embedded-incus-foundation change, in `upmaru/opsmaru-incus`, owns Opsmaru.Incus, host connection/context contracts, native API/stream port, pinned inventory/notices and database-free consumer checks. Consume its verified immutable revision/API rather than reimplementing those modules here. Macus can adopt this first library before shared tools, task adapters or central connectivity are implemented.

This change adds registered-target transport adapters: direct HTTPS resolves the target's protected credential/trust references; connector dispatch executes through the same client at the configured remote host. Partition pools/caches/events and validate backend-returned addresses by target/generation. Preserve the foundation's operation/stream/uncertainty contract; no aggregate native Incus proxy or second client codec is introduced. Qualify direct/connector streaming separately from core client coverage.

### 6. Central SQL tasks and local execution receipts

Keep common store/runner contracts, but select PostgreSQL for central task coordination and the host-private append-only journal for local Macus/connector persistence. Central tasks, idempotency receipts, dispatch outbox and execution intent commit in one SQL transaction with uniqueness and monotonic state transitions; no split transaction with another central journal. Durable acceptance is returned only after commit. Central policy/registry changes share the same configured database. A transactional lease/compare-and-set serializes dispatch ownership; start with one central BEAM, without promising distributed scheduling or HA from the schema alone.

Central identity includes `(owner, target_id, registration_generation, operation/version, project, normalized_input_digest)`. Persist a stable dispatch ID before sending. A connector keys receipts by central service, target/generation and dispatch ID, and commits that ID/digest and local execution receipt before acknowledging; repeats of the same ID/digest return the committed receipt, and changed inputs conflict. This is a central task plus a linked local receipt in the existing runner, not another independently scheduled user task or duplicate Macus runner. Local standalone tasks retain their own namespace and cannot collide with centrally delegated owners.

Use explicit stages: centrally accepted, connector accepted, native operation accepted, final result and uncertain outcome. No atomic transaction spans central SQL, connector journal and Incus. Lost acknowledgement is reconciled using the same dispatch receipt; a receipt indicating possible native acceptance without an operation ID remains uncertain and cannot be replayed. Disconnection is availability loss, never evidence of cancellation or execution failure. Device/backend generation changes quarantine unmatched work rather than routing it to a replacement.

Persist native operation IDs promptly and query them after restart. Macus runtime descriptors similarly record their observed outcome and uncertainty; a host lifecycle action is not blindly repeated. Central polling/cancellation verifies current owner/target policy; connector cancellation records intent idempotently and reports actual supported backend outcome. Expiring user tokens block new calls, not retroactively undo accepted work. Local/device disable blocks new remote dispatch and closes delivery while preserving receipt/backend reconciliation.

Bound deadlines, concurrency, captured output and queues per target plus central totals. Result/status events carry monotonic sequence/receipt identity and are applied idempotently; gaps lead to authoritative polling rather than invented replay guarantees. Only committed transitions notify clients. API bearer tokens are not stored in SQL or connector/task journals. Store protected credential references and non-secret authorization snapshots only. Receipt retention covers nonterminal/uncertain work and a published reconciliation window, so reconnect/cleanup cannot permit duplicate mutation.

Alternative: keeping all central tasks in a per-host file journal complicates registry transactions and restart coordination; making SQL mandatory inside Macus breaks embedding. Storage adapters retain one execution contract with deployment-appropriate persistence.

### 7. Host providers expose capability boundaries, not a second hypervisor API

Define an explicit registered target descriptor and a small execution-host adapter contract for passive capability inspection and filesystem-path resolution. Lifecycle extension actions remain host-owned and explicitly authorized. Macus supplies Swift readiness and VZ share information; Linux connectors supply their configured Incus readiness and authorized local path information. Direct remote Incus targets cannot inspect a remote host filesystem unless an explicit capability adapter exists.

Report separately: implemented client surface, observed Incus extensions, system/OCI/VM capability and optional host features. On Macus, VM capability also depends on supported host nesting and observed guest KVM. Linux has no fictional outer-VM start/stop operation. A native Incus cluster member selector is preserved as a native parameter under configured policy, not interpreted as a different registered target.

Path resolution includes target/generation and execution-host locality, authorized scope and prerequisites. Central-server or caller-local paths are never treated as remote mounts, and registration neither transfers code nor installs skills. Macus's current Swift runtime requires a stopped VM for configuration changes, so unresolved new shares cannot be silently applied or trigger a reboot. This foundation defines/report tests the contract; it does not mount arbitrary new workspaces or introduce source synchronization.

### 8. Outbound protocol and independent Linux delivery

Use an explicitly versioned authenticated outbound TLS/WebSocket control session initiated by the connector to the registered central service. Central ingress validates the enrolled device certificate and active generation before upgrade. One current session epoch is selected per registration; replacement sessions fence old channels and may only reconcile committed dispatch IDs. Handshake negotiates protocol/operation manifest versions and bounded capabilities. Heartbeats report connector reachability separately from Incus readiness; reconnect uses bounded exponential backoff/jitter and does not dispatch new work while identity/policy is unavailable.

Internal envelopes carry registered operation descriptors, data-only context, receipt/query/cancel messages and bounded stream setup, never arbitrary host commands, destination URLs, serialized closures or unrestricted port forwarding. A single request cannot retarget the connector. Private Linux supports shared Incus operations; Macus additionally supplies known Swift runtime/capability descriptors under enrollment permission. Schema changes require compatible version negotiation, not remote code loading.

Separate correlated stream channels preserve exec input/output/control, binary transfers, applicable native upgrade/half-close and disconnect semantics at the operation boundary. Backpressure, quotas and idle/deadline limits are mandatory; whole-file buffering and an unbounded shared control mailbox are prohibited. On disconnect, streams report interruption and tasks reconcile receipts/native operation state. Generic transport connection does not establish support for every stream type: record per-operation direct/connector acceptance and reject unqualified capabilities. Central authentication/device revocation terminates affected dispatch/streams within the documented maximum (30 seconds), while local Macus disable/disconnect stops its outbound worker immediately. No inbound firewall/router changes are necessary for the connector.

The same source provides a central `opsmaru` Linux release and a connector-only role with bundled ERTS, distribution disabled, no target-host toolchain prerequisite and explicit ARM64/x86_64 GNU/glibc baselines. Central installation may be remote from all clusters. Connector-only installation needs no Repo/DATABASE_URL/issuer credentials, Phoenix/MCP listener or browser UI, only private device/receipt state, registered central URL/trust and one configured Incus backend. A host may run a connector with authorized local socket access; alternatively deploy it within a private network with restricted HTTPS credentials. It is not installed automatically beside every cluster.

Provide passive systemd packaging and separate explicit activation/enrollment instructions for both roles. Do not install/configure Incus, open inbound ports or grant backend privileges as a packaging side effect. Stop/restart/upgrades preserve targets, central SQL, local receipts and native data; role changes require explicit compatible configuration. Device credentials are private and absent from packages/logs/status. Reachable direct clusters require no connector. Terraform/OpenTofu provisioning and external Tama workflow orchestration remain later registered-operation changes; neither is a connectivity prerequisite.

### 9. Consumer pinning and implementation order

1. Complete add-embedded-incus-foundation independently in `upmaru/opsmaru-incus` and publish a real implemented immutable library/client revision; no central/connector completion is required.
2. Consume that client and implement shared MCP/tool/local-task contracts needed by Macus; preserve explicit incomplete-adapter advertisement and independent consumer evidence.
3. Macus can pin the foundation first for local gateway/runtime/proxy/client integration, then update to a verified tool/task revision through its apply workflow. Development may use an editable sibling path; production and CI must resolve a pinned Git revision or released package without that sibling.
4. Macus validates the composed catalogue, host identity/context, task recovery and native relay behavior. Its paired Swift/Mix build records one Macus revision and the distinct Opsmaru dependency revision; those are not required to be identical repositories' commits.
5. Implement central registry/SQL/transport and connector receipt contracts here, then wire OIDC/enrollment/REST/browser adapters in add-remote-api-and-oauth. Finish central and connector package/opt-in acceptance with multiple isolated targets; Macus owns its CLI/enrollment and hardware gates. Core/embedded tests can finish before central HTTP/OIDC acceptance, avoiding a cycle between the two changes.

The Macus gateway/runtime/proxy implementation can progress after its revised planning is validated, but shared client/MCP/task work must use the Opsmaru boundary. No absent Hex release or placeholder remote dependency is invented. The scaffold and previous plans are already published on feature/phoenix-bootstrap-and-remote-access; main/develop remain the planning baseline. This update publishes planning only, not an implemented central/connector release.

## Risks / Trade-offs

- Dependency startup accidentally enables a second server -> embedded default, no endpoint child, hostile-environment startup tests and explicit standalone mode.
- Host and embedded dependency resolve incompatible Phoenix/Plug versions -> consumer fixture CI with both lockfiles and an immutable dependency pin before packaging.
- A shared runner loses host-tool or caller identity after restart -> stable allowlisted tool/provider descriptors, retained owner keys and explicit incompatible/uncertain recovery states.
- A native socket gives privileged Incus access -> host authentication and tool authorization before connection, narrow capability/context construction and denial-counter fixtures.
- A Mac mount path is mistaken for a Linux/remote path -> host-local path references and prerequisite reporting, with workflow attachment deferred.
- Large client port appears complete from proxy fixtures -> independent inventory evidence and separate platform/live-backend gates.
- Generic library shutdown affects host workloads -> no implicit lifecycle callbacks; restart/stop tests retain backend/runtime markers.
- New Linux packaging broadens Macus's platform promise -> Linux delivery owned by Opsmaru; Macus remains Apple Silicon/macOS-only.

## Migration Plan

There is no deployed Opsmaru one-host state to migrate. The central/connector design supersedes the earlier per-host standalone service. Implement shared core and target/storage contracts first. Transfer reusable reference fixtures with provenance rather than deleting Macus's original evidence prematurely. Macus's first dependency integration is gated by a real immutable Opsmaru revision and updated lockfile.

Installation remains passive. For deployment upgrades, stop only the owned public service, retain central database and local credential/receipt/task directories and restart the selected verified release. Do not stop Incus or Swift as an Opsmaru upgrade side effect. Rollback preserves task journal contents; an older release that cannot read a newer journal must fail with explicit recovery guidance, not truncate or rewrite it. Journal format/version compatibility is part of release validation.

## Open Questions

- First Linux operator's certificate identity, install prefix, service account and authorized backend path are deployment inputs.
- Resolve the exact compatible locked dependency versions and immutable published Opsmaru revision during implementation; no unreleased artifact is assumed here.

## Central and connector acceptance additions

Verify two isolated Incus targets with overlapping project/instance names and one Macus-like connector fixture behind a simulated inbound firewall. Prove permitted inventory aggregation, explicit target selection, independent TLS identities, per-target pools/policy, device enrollment/revocation, generation fencing, duplicate/conflicting dispatch, lost acknowledgements, receipt recovery, key rotation, target outages and native streaming limits. A target failure cannot block other targets or imply deletion/cancellation. Installed Linux direct/connector and real Macus hardware tests remain explicit opt-in with isolated data and separate reports.

Registration is connectivity/permission setup only. It must not build an environment, transfer code, mount directories, modify a Mac share, start a VM or schedule cross-cluster workloads. Local Macus works while central is absent. Central service user OIDC remains tested against Keycloak; test device enrollment separately from user login and native Incus client-certificate trust.
