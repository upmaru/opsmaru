# Design

## Context

See [proposal.md](proposal.md) for motivation. `git@github.com:upmaru/opsmaru.git` was empty when checked out; the initial proposal was a greenfield planning baseline. The subsequent explicit bootstrap request generated a root Phoenix/Cowboy project with PostgreSQL/Ecto and HTML/LiveView assets on feature/phoenix-bootstrap-and-remote-access. Baseline tests and embedded startup pass; shared compute functions remain unimplemented.

The integration reference is Macus's `add-elixir-server` change on `feature/elixir-server`. Its current implementation has a headless Phoenix scaffold, module boundary stubs, pinned Incus reference inventory/differential fixtures and a successful fixture-only Cowboy transport trial. Seven original tasks are checked; shared client methods, MCP tools, production gateway and durable tasks are pending. Macus uses Phoenix 1.8.15, Plug.Cowboy 2.9.0, Cowboy 2.19.0 and TamaMCP 0.1.1 in its current lockfile. These are a verified compatibility baseline for dependency resolution, not a mandate to publish those versions or claim new acceptance.

The reference client is Incus v7.0.1 at `13f3992766142d5087fff2e362cd2e1a75294fe8`. Macus owns the initial provenance and fixture inputs. Transfer reusable evidence with notices during implementation; retain consumer-specific evidence in Macus. TamaMCP currently compiles catalogues from explicitly registered tool modules and accepts application-owned authorization/cache/task adapters. It has no production durable store or web server of its own.

## Goals / Non-Goals

**Goals:**

- One public library and Phoenix application whose compute semantics are reusable inside Macus and a Linux service.
- One authenticated MCP endpoint per execution host, with shared tool contracts and composable host extensions.
- Native Incus behavior, truthful method/capability coverage and durable execution bound to caller and host identity.
- An embedded mode with no dependency-owned endpoint process, listener, installation or outer-runtime lifecycle side effect.

**Non-Goals:**

- Moving Swift/VZ, Macus's private relay, public native Incus proxy or macOS installer into Opsmaru.
- Replacing Incus with another workload manager; a central scheduler, clustered task broker or one endpoint managing multiple independent hosts.
- Environment-image recipes, skill bundling, worktree creation, source synchronization, workspace provisioning, service previews or arbitrary host-shell tools in this foundation.
- A second `opsmaru_server` Mix project or required second BEAM on macOS. The earlier two-package sketch is superseded by the requested single Phoenix application.
- Package publication, deployment, workload mutation or real-host acceptance during planning.

## Decisions

### 1. One root Phoenix application with optional standalone web/persistence

Use one Mix application `:opsmaru`, modules `Opsmaru` and `OpsmaruWeb`, with the explicitly requested PostgreSQL/Ecto, HTML/LiveView and assets for standalone authentication. Pin toolchains and lock dependencies compatible with the Macus Phoenix/Cowboy baseline. Keep the Cowboy2 adapter and omit mailer/dashboard/gettext scaffolding. Embedded supervision must not start its own Repo or web endpoint. Identity/OAuth/REST feature implementation belongs to [add-remote-api-and-oauth](../add-remote-api-and-oauth/design.md).

```text
lib/opsmaru/
  application.ex       mode-aware supervision
  incus/               portable typed client and transports
  host/                configured backend, provider and capability contracts
  mcp/                 shared tools, catalogue inclusion and cache adapter
  tasks/               journal, durable runner, execution descriptors
  auth/                common policy/context and standalone credential adapter
lib/opsmaru_web/
  endpoint.ex          standalone-only endpoint
  router.ex            standalone /mcp and authenticated status
config/
test/
packaging/linux/
```

The shared client is initially `Opsmaru.Incus`, isolated from Phoenix, MCP and host runtime code. A later standalone client package can be extracted without changing the consumer API, but this foundation does not introduce an additional repository.

Alternatives: two Mix projects add versioning and wiring before there is separate functionality; placing a complete duplicate service in Macus defeats the shared boundary. One application with an opt-in endpoint satisfies the requested deployment modes.

### 2. Embedded mode is the default; the host starts one service tree

Use explicit application configuration for `deployment_mode: :embedded | :standalone`, private state root, backend connection, host provider, identity integration and service names. Default mode is embedded. `Opsmaru.Application` starts only the configured shared services in that mode; it does not supervise `OpsmaruWeb.Endpoint` or any dependency-owned HTTP listener.

Macus sets its embedded configuration before dependency startup and uses the shared application inside its existing release/BEAM. It does not separately start a second task tree or install an Opsmaru launchd job. Incomplete unconfigured library startup is inert: it must not create private state or contact a backend merely because the dependency was loaded. A deployment advertising execution validates the full required service configuration before serving requests.

The standalone release's runtime configuration explicitly selects standalone mode and validates TLS/listener, state, identity and Incus configuration before adding the endpoint child. `PHX_SERVER`, `PORT` and unrelated environment variables cannot infer or change deployment mode. Macus does not evaluate dependency release configuration; its own configuration remains authoritative. Endpoint configuration updates do not dynamically switch embedding into standalone mode; mode transitions require explicit service restart.

Shared service failure/restart leaves Swift and Incus runtime/workloads intact. Process names and selected state identify one configured host per application instance; no implicit global `~/.tama/incus-mac` binding exists in the library.

Dependency applications may start before the embedding host's own supervision tree. Use an explicit host-readiness gate for identity/provider integration before runner dispatch or backend recovery; loading callback modules alone does not establish readiness. Failure or delayed startup keeps execution unavailable rather than substituting ambient owner authority. This readiness gate does not require Incus to be running before the public service can report status.

Alternatives: merely setting Phoenix `server: false` still starts the endpoint tree and can be overridden by generated runtime configuration. Conditional endpoint supervision makes the no-server embedding contract directly testable.

### 3. The host mounts a shared MCP contract and composes its catalogue

The designated MCP dependency is [kritama/tama-mcp](https://github.com/kritama/tama-mcp), OTP application `:tama_mcp` and module namespace `TamaMCP`. Opsmaru consumes its supported JSON-RPC, schemas, transport, tool compilation and task contracts rather than implementing or selecting an alternative protocol engine. Reusable protocol gaps belong in that library; Opsmaru owns compute tools, authorization policy, persistence and host integration. Pin a verified package release or immutable revision, never an editable production sibling path. Shared tools live under `Opsmaru.MCP.Tools.*`; expose a documented compile-time inclusion helper or explicit registration list and immutable names/schemas/scopes. Host composition uses TamaMCP's existing tool DSL, not mutable runtime code loading. Reject duplicate names during compilation.

```text
Macus BEAM
  MacusWeb.Endpoint /mcp
    Macus composed catalogue
      Opsmaru shared tools + Macus runtime tools
    host authentication + shared cache/store/runner
  /runtime --> Macus.Runtime --> private Swift runtime.sock
  /1.0/*   --> Macus.Proxy   --> private incus.sock relay
  Opsmaru.Incus             --> same configured incus.sock
  OpsmaruWeb.Endpoint is absent

Linux BEAM
  OpsmaruWeb.Endpoint /mcp
    shared catalogue + Linux host capability integration
    standalone authentication + same shared cache/store/runner
  Opsmaru.Incus --> configured local Unix or HTTPS Incus backend
```

Mount the maintained Streamable HTTP Plug with the composed catalogue and explicitly configured authorization, validator cache, task store and runner. Shared schemas remain identical in both deployments. Macus-only runtime tools are implemented/registered in Macus and absent from Linux. The standalone app does not provide Macus `/runtime` routes or a second native Incus reverse proxy in this foundation; operators retain normal access to their existing Incus endpoint.

Initial shared tools cover server/instance/image/project/profile/network/storage inspection; explicit instance/state/image/snapshot mutations; destructive deletion/restore with explicit confirmation; and bounded guest exec. Document every exported tool name and scope. Host capability inspection is passive. Higher-level environment and workspace tools are separate future additions.

### 4. A single trusted execution context crosses every boundary

The public host verifies credentials and returns the maintained authorization decision. Normalize principal, stable owner key, scopes, expiry, request identity and an allowlisted registered-host binding. Request fields cannot replace owner identity, select arbitrary backend URLs or manufacture a filesystem provider.

Macus retains its gateway certificate/bearer trust and revocation policy, including its authorization-before-private-socket requirements. Standalone Linux supplies scoped bearer credentials and HTTPS identity through Opsmaru's own adapter. Common scope/tool policy lives in Opsmaru; deployment-specific credential verification and issuance remain selectable adapters. Keep ordinary native Incus proxy trust in Macus separate from MCP bearer policy.

Shared service calls and host extension execution preserve caller context rather than using ambient owner privileges. The execution descriptor binds owner, registered host, tool version and selected native project/member. Queued dispatch checks the host's current authorization policy before issuing new mutations. Revocation does not undo already accepted Incus work; denied polling/subscription and backend reconciliation retain their distinct semantics. Store credential references when needed, never raw bearer tokens in task data.

### 5. One portable Incus client with explicit coverage

Move the pending portable client implementation and reusable method/type inventory into this project. Preserve upstream notices, immutable source reference, fixture provenance and evidence that local Macs and Linux use the same Unix/HTTPS transports. Macus consumes the public client instead of implementing its own methods; a temporary compatibility module may only delegate and must not duplicate wire behavior.

Port in verified slices: discovery/raw query/codecs/extensions; projects/profiles/access; instances/state/snapshots; images/transfers; networks/clusters; storage/buckets; files/backups/native SFTP/NBD; operation/event handling; exec/console; migration and remaining entries. Complete support requires every supported reference inventory entry to have implementation and behavior evidence. Missing entries remain explicit; partial development must not be shipped as full parity.

The native Incus raw proxy and typed client are distinct consumers of transport behavior. Preserve Macus's Cowboy trial fixtures locally; generalize useful protocol fixtures into Opsmaru with notices and retest them there. No host HTTP adapter or proxy trial substitutes for client method parity or real Incus evidence.

### 6. Durable tasks are shared application infrastructure

Implement the planned single-node append-only journal and serialized transitions in Opsmaru. Configure an owner-private state location from the host. Persist task plus execution intent before exposing a task handle, then supervise an outbox/runner. Store non-secret serializable execution descriptors; resolve credential and provider references from current host configuration after restart.

Persist native operation IDs as soon as known. Recover by querying them. A possible mutation with no durable identity is uncertain and must not be replayed. Enforce caller-bound polling/input/cancellation, monotonic execution deadlines, bounded output/concurrency and post-commit notifications. Task notifications are lossy; polling is authoritative. Use the maintained task schemas/runner/store contracts and bounded local notification adapter. Keep the task journal independent of standalone identity SQL storage; Ecto's presence must not make database startup mandatory for embedded compute. Do not add Erlang distribution or clustered scheduling for this change.

Macus runtime tool modules remain consumer-owned, but the shared runner may execute them through an explicitly registered tool catalogue and execution adapter. Stable tool identity and host bindings are persisted; recovery rejects missing or incompatible tool descriptors explicitly. The library cannot invoke arbitrary modules named by a request or journal record.

### 7. Host providers expose capability boundaries, not a second hypervisor API

Define an explicit registered execution-host descriptor and a small host adapter contract for passive capability inspection and filesystem-path resolution. Lifecycle extension actions remain host-owned and explicitly authorized. Macus supplies Swift readiness and VZ share information; Linux supplies existing Incus readiness and authorized local path information.

Report separately: implemented client surface, observed Incus extensions, system/OCI/VM capability and optional host features. On Macus, VM capability also depends on supported host nesting and observed guest KVM. Linux has no fictional outer-VM start/stop operation. A native Incus cluster member selector is preserved as a native parameter under configured policy, not interpreted as an arbitrary independently managed host.

Path resolution returns execution-host locality, authorized scope and prerequisites. Macus's current Swift runtime requires a stopped VM for configuration changes, so unresolved new shares cannot be silently applied or trigger a reboot. This foundation defines/report tests the contract; it does not mount arbitrary new workspaces or introduce source synchronization.

### 8. Standalone Linux release and service configuration

The same root project produces an `opsmaru` Mix release with bundled ERTS, distribution disabled by default and explicit standalone runtime configuration. Support Linux ARM64 and x86_64 GNU/glibc artifacts built for a declared compatible OS baseline; do not claim musl or unrelated distributions from a successful glibc build. Record system-library prerequisites and test each advertised target without host Elixir/Erlang.

Default standalone binding is loopback HTTPS. Explicit remote bind and advertised identity require operator-selected valid certificate/key. Use owner-local administration commands for identity initialization and bearer issuance/revocation to private destinations. Private state paths/ownership, permission checks, credential expiry and stream revocation are verified before privileged backend use. Document how the selected service account gets authorized Incus access; package installation must not silently grant backend privileges, install Incus or use a host-shell MCP tool.

Provide a foreground systemd unit and passive installation into an operator-selected prefix. Enabling/start is explicit; installation creates no workload, credential or listener. Upgrade, rollback and removal preserve host state and Incus data. Linux does not need Macus's public native Incus trust mediation unless a future change explicitly adds a proxy.

### 9. Consumer pinning and implementation order

1. Implement and validate the Opsmaru root project, modes, public adapter/context contracts and portable reference foundation.
2. Implement the client/tool/task slices required by Macus, with truthful partial coverage during development and full planned coverage before completion claims.
3. Create an immutable Opsmaru revision/release and revise Macus's dependency lock plus integration code through its apply workflow. Development may use an editable sibling path; production and CI must resolve a pinned Git revision or released package without that sibling.
4. Macus validates the composed catalogue, host identity/context, task recovery and native relay behavior. Its paired Swift/Mix build records one Macus revision and the distinct Opsmaru dependency revision; those are not required to be identical repositories' commits.
5. Independently finish Linux listener/admin/release/service work and opt-in live Incus acceptance. Macus hardware acceptance remains in Macus; Linux package success cannot complete it.

The Macus gateway/runtime/proxy implementation can progress after its revised planning is validated, but shared client/MCP/task work must use the Opsmaru boundary. No absent Hex release or placeholder remote dependency is invented. The Opsmaru repository is currently unborn; initial commit/publication and long-lived branch bootstrap are explicit delivery steps, not performed by this planning request.

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

There is no deployed Opsmaru state to migrate. Establish its standalone planning and implement the foundation first. Transfer reusable reference fixtures with provenance rather than deleting Macus's original evidence prematurely. Macus's first dependency integration is gated by a real immutable Opsmaru revision and updated lockfile.

Installation remains passive. For deployment upgrades, stop only the owned public service, retain credential/task directories and restart the selected verified release. Do not stop Incus or Swift as an Opsmaru upgrade side effect. Rollback preserves task journal contents; an older release that cannot read a newer journal must fail with explicit recovery guidance, not truncate or rewrite it. Journal format/version compatibility is part of release validation.

## Open Questions

- First Linux operator's certificate identity, install prefix, service account and authorized backend path are deployment inputs.
- Resolve the exact compatible locked dependency versions and immutable published Opsmaru revision during implementation; no unreleased artifact is assumed here.
