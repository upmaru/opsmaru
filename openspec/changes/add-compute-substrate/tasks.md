# Tasks

Planning only. All implementation, service activation, publication and real-backend work below requires a later apply request. Macus integration is tracked in its separate `add-elixir-server` change. Sections 1-6 establish the shared foundation; standalone Linux work can follow independently of Macus's runtime/proxy work.

## 1. Phoenix project and listener-free embedding

- [ ] 1.1 Scaffold one root headless Phoenix/Cowboy application `:opsmaru` with public `Opsmaru`/`OpsmaruWeb` namespaces; verify compilation, generated baseline tests and absence of HTML/assets/LiveView/Ecto scaffolding.
- [ ] 1.2 Pin Elixir/OTP, development tools and compatible Phoenix/Cowboy/TamaMCP dependencies; commit the lockfile and verify a clean dependency build against the Macus compatibility baseline without sibling path dependencies.
- [ ] 1.3 Implement explicit embedded/standalone mode configuration and conditional endpoint supervision; verify default startup and PHX_SERVER/PORT cannot start an embedded endpoint process or listener, and invalid standalone configuration binds no port.
- [ ] 1.4 Implement passive unconfigured startup, configured activation/state validation and host identity/provider readiness gating; verify loading creates no files, unsafe state fails, delayed host startup dispatches no backend work and supervision restarts preserve backend markers.
- [ ] 1.5 Document library configuration, deployment modes and host startup ownership; verify a small external consumer starts embedded workers while retaining its own endpoint and stopping only the shared service tree.

## 2. Incus reference and portable client foundation

- [ ] 2.1 Transfer the pinned official Incus v7.0.1 revision/inventory inputs and reusable Macus fixtures with source notices; verify hashes, inventory regeneration and added/removed/changed-entry detection while retaining consumer-specific Macus evidence.
- [ ] 2.2 Generalize fake Unix/TLS backends and differential fixtures for both supported host platforms; verify query/body/status/error/ETag mismatches fail and provenance reports distinguish fixture evidence from live Incus.
- [ ] 2.3 Implement typed codecs, native error envelopes and extension/version checks in the public client boundary; verify required/optional/null fields and unsupported-operation failure against pinned reference fixtures.
- [ ] 2.4 Implement configured Unix/HTTPS discovery and raw requests with backend identity, deadlines and cleanup; verify local Macus-style relay and native Linux socket bindings use the same implementation, invalid TLS fails and caller addresses cannot replace the registered host.
- [ ] 2.5 Document public connection configuration, coverage rules and upstream updates; verify missing evidence blocks a complete-port claim and the client boundary calls no Swift or Phoenix endpoint modules.

## 3. Portable client behavior slices

- [ ] 3.1 Port project/member selection, profiles and access/certificate operations; verify native parameters, conditional requests, errors and inventory evidence against the pinned reference.
- [ ] 3.2 Port instance create/read/update/state/delete and snapshot/restore operations; verify accepted handles, conflicts and destructive inputs retain native semantics in differential fixtures.
- [ ] 3.3 Port images, aliases, imports, copies and exports; verify binary transfer framing, operation identity and the corresponding model/method evidence.
- [ ] 3.4 Port network and cluster operations; verify configured target policy and all affected inventory entries without adding a multi-host scheduler.
- [ ] 3.5 Port storage pools/volumes/snapshots/buckets; verify typed payloads and native errors without implementing storage behavior in the library.
- [ ] 3.6 Port files/backups and native SFTP/NBD upgrade clients; verify official-client wire comparison, coalesced handshake bytes, binary duplex transfer, half-close and disconnect cleanup without counting Macus proxy fixtures as client completion.
- [ ] 3.7 Port waiting/polling/supported cancellation and bounded event streams; verify native completion races, visible overflow, local timeout versus remote cancellation and no replay after ambiguous acceptance.
- [ ] 3.8 Port exec/console and control streams; verify bounded input/output, terminal control, native exit status and cleanup against the pinned reference.
- [ ] 3.9 Port migration/copy and every remaining supported inventory entry; verify address/operation negotiation, stream teardown and complete method/model evidence.
- [ ] 3.10 Complete client API documentation and method/type manifest; rerun affected differential fixtures on macOS/Linux and verify no unsupported entry is hidden by raw proxy or platform-capability results.

## 4. Host and caller integration contracts

- [ ] 4.1 Define the configured single-host descriptor, trusted request/owner context and host provider contract; verify malicious owner/backend values cannot replace registered bindings and shared code starts no outer runtime.
- [ ] 4.2 Implement passive capability reporting separating client support, live backend extensions/readiness and optional host features; verify missing Macus/nesting/KVM providers report unavailable rather than fabricated support.
- [ ] 4.3 Implement authorized execution-host path resolution/prerequisite reporting; verify Linux-local versus client-local paths, read-only scope and Macus share-change prerequisites without mounting a workspace or restarting a host.
- [ ] 4.4 Document stable host/caller contracts and Macus adapter responsibilities; verify an external consumer adapter can provide host features without importing Swift into Opsmaru or exposing arbitrary host execution.

## 5. Shared MCP catalogue and authorization

- [ ] 5.1 Integrate the maintained TamaMCP dependency, cache adapter and documented compile-time shared-tool inclusion; verify applicable conformance fixtures, deterministic catalogue ordering and duplicate-name compile failures.
- [ ] 5.2 Register shared server/instance/image/project/profile/network/storage inspection and passive host-capability tools; verify schemas, configured backend binding and scope-aware discovery in standalone and composed consumer catalogues.
- [ ] 5.3 Register explicit instance/state/image/snapshot mutations and bounded guest exec; verify native client delegation, required write/exec scopes and denial before backend access without a host-shell tool.
- [ ] 5.4 Register explicit deletion/destructive restore inputs and destructive scopes; verify missing confirmation, forbidden tools and wrong scopes cannot dispatch backend or host-provider calls.
- [ ] 5.5 Provide host authorization/context adapters and shared scope policy wiring; verify verified principal/owner/expiry survive dispatch and asynchronous handoff, revocation closes streams and request fields cannot forge identity.
- [ ] 5.6 Publish the exact portable tool/schema/scope manifest and composition guide; verify a consumer adds a fixture runtime tool at one endpoint while the default Linux catalogue excludes it and shared schemas stay identical.

## 6. Shared durable execution

- [ ] 6.1 Implement versioned owner-private append-only task storage and serialized transitions; verify state isolation, journal replay, unsafe-path rejection, data-only descriptors and flush-before-handle behavior.
- [ ] 6.2 Implement atomic task/intent persistence plus supervised outbox execution; verify queued authorization, configured host/tool bindings and crash recovery without arbitrary module execution or bearer tokens in storage.
- [ ] 6.3 Implement prompt native operation-ID persistence and reconciliation; verify a crash after possible acceptance but before durable identity records uncertainty without replaying the mutation.
- [ ] 6.4 Implement durable input acceptance/cancellation, deadlines, output and concurrency bounds; verify duplicate updates do not resignal workers and local timeout/cancellation never asserts unsupported remote cancellation.
- [ ] 6.5 Integrate bounded post-commit notifications, owner-bound polling and stream reauthorization; verify expiry/revocation/overflow/lost delivery and authoritative recovery through the maintained conformance contracts.
- [ ] 6.6 Support registered consumer tool execution/recovery through the same runner; verify a fixture host-runtime tool retains owner/tool identity and missing or incompatible descriptors fail explicitly after restart.
- [ ] 6.7 Document task schema versions, recovery, acceptance/completion semantics and advertisement gating; verify a deployment with incomplete adapters never advertises durable tasks and rollback cannot truncate an incompatible journal.

## 7. Standalone Linux HTTP and administration

- [ ] 7.1 Configure the standalone-only Phoenix endpoint for loopback HTTPS and explicit remote identity; verify embedded configuration cannot enable it, invalid TLS binds no listener and native backend access follows authentication.
- [ ] 7.2 Mount the shared catalogue at /mcp with standalone bearer verification and shared task/cache adapters; verify real HTTP conformance, read/write/exec/delete scope separation and caller-owned task access against fake Unix/TLS backends.
- [ ] 7.3 Implement owner-local identity initialization and private bearer issuance/revocation; verify unsafe ownership/destinations fail, ordinary inspection creates no credentials and secrets are absent from logs/status/packages.
- [ ] 7.4 Provide authenticated service/capability status that distinguishes backend unavailability; verify status remains available while Incus is stopped and no startup action installs Incus or creates an outer VM.
- [ ] 7.5 Document local/remote setup, service-account Incus permissions and credential rotation; verify isolated configured examples without automatic privilege grants, network/firewall changes or an additional Incus proxy.

## 8. Linux release and passive installation

- [ ] 8.1 Build a bundled-ERTS opsmaru release with explicit standalone runtime settings, distribution disabled and immutable dependency/reference metadata; verify a matching isolated Linux host needs no installed Elixir/Erlang.
- [ ] 8.2 Define and build supported ARM64/x86_64 GNU/glibc targets with declared OS/system-library prerequisites; verify each advertised target separately and no artifact claims musl or untested ABI compatibility.
- [ ] 8.3 Provide passive prefix installation and a foreground systemd unit with explicit configuration/activation; verify installation binds no listener, grants no Incus privileges and starts no service or workload.
- [ ] 8.4 Implement/document owned-service stop/start, upgrade, rollback and uninstall preservation; verify task/credential/backend markers survive package fixtures and incompatible journal rollback fails without rewriting state.
- [ ] 8.5 Document source builds, installed usage and separate consumer pinning; verify installed commands and an external pinned consumer build work without a sibling checkout before advertising an available artifact.

## 9. Cross-component and real-host acceptance

- [ ] 9.1 Add canonical format/compile/test, strict OpenSpec validation and platform fixture CI; verify shared client/conformance reports, embedded listener absence and standalone release checks independently.
- [ ] 9.2 Run an external consumer fixture with the Macus-compatible dependency set, combined catalogue and shared runner; verify version resolution, host adapter context and only one public endpoint without claiming Macus hardware acceptance.
- [ ] 9.3 With explicit live Linux opt-in, use isolated project/state/credentials to prove shared inspection/mutation/exec/native file channels and durable task recovery against actual Incus; preserve backend data and failure diagnostics.
- [ ] 9.4 With explicit installed Linux opt-in, prove passive install followed by standalone activation, restart and upgrade/rollback with retained workload/task markers; record package, service and backend evidence separately.
- [ ] 9.5 With explicit remote-client opt-in, prove advertised TLS identity, scopes and revocation from another client; keep unavailable remote/live gates unchecked and link Macus-owned hardware acceptance without claiming it here.
