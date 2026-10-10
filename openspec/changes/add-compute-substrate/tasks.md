# Tasks

Later change, dependent on add-embedded-incus-foundation. Core embedding/client implementation tasks and specs are extracted there; do not implement a duplicate client here. The original checked scaffold task is retained as historical evidence only. Macus may pin the first foundation for local server/client progress before these tools/tasks/central/connector milestones. No new completion is claimed.

## 1. Historical scaffold and foundation consumption

- [x] 1.1 Scaffold one root Phoenix/Cowboy application `:opsmaru` with public `Opsmaru`/`OpsmaruWeb`, optional PostgreSQL/Ecto and HTML/LiveView assets; verify compilation, asset builds, generated baseline tests, absent mailer/dashboard and embedded startup without Endpoint/Repo.
- [ ] 1.2 Build on the implemented add-embedded-incus-foundation connection/client API in the same root application and record its verified baseline revision; verify clean locked dependencies and no duplicate portable client or database requirement for local embedding.
- [ ] 1.3 Document foundational versus later tool/task/central/connector ownership and dependency order; verify Macus library/client acceptance is independent of central feature completion.

## 2. Host and caller integration contracts

- [ ] 2.1 Define registered target/transport/generation and trusted caller/local host-provider contracts; verify malicious owner/backend values cannot replace registered bindings and shared code starts no outer runtime.
- [ ] 2.2 Implement passive capability reporting separating client support, live backend extensions/readiness and optional host features; verify missing Macus/nesting/KVM providers report unavailable rather than fabricated support.
- [ ] 2.3 Implement authorized execution-host path resolution/prerequisite reporting; verify Linux-local versus client-local paths, read-only scope and Macus share-change prerequisites without mounting a workspace or restarting a host.
- [ ] 2.4 Document stable host/caller contracts and Macus adapter responsibilities; verify an external consumer adapter can provide host features without importing Swift into Opsmaru or exposing arbitrary host execution.

## 3. Shared MCP catalogue and authorization

- [ ] 3.1 Integrate kritama/tama-mcp (`:tama_mcp`) and its maintained contracts, cache adapter and documented compile-time shared-tool inclusion; verify applicable conformance fixtures, deterministic catalogue ordering and duplicate-name compile failures.
- [ ] 3.2 Register shared server/instance/image/project/profile/network/storage inspection and passive host-capability tools; verify schemas, configured backend binding and scope-aware discovery in standalone and composed consumer catalogues.
- [ ] 3.3 Register explicit instance/state/image/snapshot mutations and bounded guest exec; verify native client delegation, required write/exec scopes and denial before backend access without a host-shell tool.
- [ ] 3.4 Register explicit deletion/destructive restore inputs and destructive scopes; verify missing confirmation, forbidden tools and wrong scopes cannot dispatch backend or host-provider calls.
- [ ] 3.5 Provide host authorization/context adapters and shared scope policy wiring; verify verified principal/owner/expiry survive dispatch and asynchronous handoff, revocation closes streams and request fields cannot forge identity.
- [ ] 3.6 Publish the exact portable tool/schema/scope manifest and composition guide; verify a consumer adds a fixture runtime tool at one endpoint while Incus-only target execution excludes it and shared schemas stay identical.

## 4. Shared durable execution

- [ ] 4.1 Define shared store/runner contracts and implement versioned owner-private local task/receipt journal and serialized transitions; verify state isolation, journal replay, unsafe-path rejection, data-only descriptors and flush-before-handle behavior.
- [ ] 4.2 Implement local atomic task/receipt-intent persistence plus supervised outbox execution; verify queued authorization, configured host/tool bindings and crash recovery without arbitrary module execution or bearer tokens in storage.
- [ ] 4.3 Implement prompt native operation-ID persistence and reconciliation; verify a crash after possible acceptance but before durable identity records uncertainty without replaying the mutation.
- [ ] 4.4 Implement durable input acceptance/cancellation, deadlines, output and concurrency bounds; verify duplicate updates do not resignal workers and local timeout/cancellation never asserts unsupported remote cancellation.
- [ ] 4.5 Integrate bounded post-commit notifications, owner-bound polling and stream reauthorization; verify expiry/revocation/overflow/lost delivery and authoritative recovery through the maintained conformance contracts.
- [ ] 4.6 Support registered consumer tool execution/recovery through the same runner; verify a fixture host-runtime tool retains owner/tool identity and missing or incompatible descriptors fail explicitly after restart.
- [ ] 4.7 Document task schema versions, recovery, acceptance/completion semantics and advertisement gating; verify a deployment with incomplete adapters never advertises durable tasks and rollback cannot truncate an incompatible journal.

## 5. Registered targets and central SQL coordination

- [ ] 5.1 Implement registry schema/contracts for target kind, transport, generation, credential references, ownership/grants, capability/version and readiness; verify duplicate/replacement identities do not rebind tasks and document target versus cluster-member selection.
- [ ] 5.2 Implement trusted direct HTTPS target adapter with dedicated certificate/private-key references and server/address policy; verify wrong trust, cross-target pool/credential reuse, redirects/backend-returned endpoints and unauthorized project/member selections cannot contact another backend.
- [ ] 5.3 Implement PostgreSQL task/idempotency/outbox transactions and dispatch leases through the common store/runner contract; verify racing acceptance/restart yields one committed intent and no split transaction with a second central journal.
- [ ] 5.4 Integrate per-target/global concurrency, owner/target/generation recovery and post-commit events; verify offline/replaced targets preserve outcomes, other targets remain responsive and missing native acceptance evidence records uncertainty.
- [ ] 5.5 Document central storage/backup/rollback and registered target lifecycle; verify isolated migration/restore preserves historical targets/tasks and an incompatible rollback fails without resetting state.

## 6. Outbound connector protocol and local receipts

- [ ] 6.1 Implement one-use key-bound device enrollment contracts and registered public-certificate trust; verify replay/expiry/wrong key/owner/generation denial and no user OAuth token issuer or stored device private key on central.
- [ ] 6.2 Implement versioned outbound TLS/WebSocket handshake, session epochs, heartbeat/backoff and device revocation; verify stale/revoked sessions cannot dispatch, NAT fixtures need no inbound port and disabled embedded mode creates no connection.
- [ ] 6.3 Implement registered operation envelopes and local permission/schema/deadline enforcement; verify forged owners/targets/projects, arbitrary commands/destinations and incompatible tool versions fail before backend/runtime access.
- [ ] 6.4 Commit dispatch receipts/input digests in the existing local journal before acknowledgement; verify duplicate/conflicting dispatch, lost acknowledgement, connector restart and uncertain native acceptance cannot repeat a mutation or create a second runner.
- [ ] 6.5 Implement bounded correlated control/data streams with receipt/status reconciliation; verify binary transfer, exec control, half-close, saturation/disconnect and 30-second maximum central device revocation bound with per-capability support evidence.
- [ ] 6.6 Package/document the connector-only bundled-ERTS Linux role under passive systemd delivery; verify no Elixir/Erlang/Repo/issuer credentials/inbound listener are required and private receipt/device markers survive upgrades.
- [ ] 6.7 Run isolated multi-target direct/connector integration with overlapping names, generations and allowed scopes; verify one endpoint routes correctly, outages isolate targets and fixture results remain distinct from actual installed/Linux/Macus acceptance.

## 7. Central service and connector-only startup

- [ ] 7.1 Configure explicit central/embedded/connector-only roles with private state and role-specific preflight; verify empty central registry needs no local Incus, connector-only starts no Endpoint/Repo/listener and ambient web variables cannot change roles.
- [ ] 7.2 Mount one central MCP catalogue with registry/target dispatch and common store adapters; verify explicit target selection, target-filtered discovery and equivalent schemas on direct/connector/local paths.
- [ ] 7.3 Integrate external user verification and target-grant/enrollment HTTP adapters from add-remote-api-and-oauth; verify user/device/backend identities remain distinct and local embedding requires no central OIDC or SQL.
- [ ] 7.4 Expose sanitized central/target/connector/backend readiness; verify one failed target leaves others usable and ordinary inspection starts no sessions, credentials or workloads.
- [ ] 7.5 Document central direct-HTTPS setup and optional Linux connector service/backend permissions; verify examples require explicit enrollment/activation and create no inbound firewall changes, outer VM or full server on every target.

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
- [ ] 9.6 With explicit installed/remote Linux opt-in, prove a central service managing separate direct-HTTPS and outbound-connector Incus targets using isolated projects/credentials/state; verify native certificate trust, no inbound connector port, cross-target isolation, stream limits and disconnect/receipt recovery without replay, preserving data and leaving unavailable gates incomplete.
