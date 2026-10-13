# Proposal

## Why

Opsmaru must provide one central MCP/REST gateway for registered Incus clusters and Macus installations while sharing its compute implementation with independently usable Macus. Direct Incus HTTPS and authenticated outbound connectors allow the same operations across reachable and private targets without requiring a full Opsmaru server beside each cluster.

## What Changes

- Depend first on [add-embedded-incus-foundation](https://github.com/upmaru/opsmaru-incus/blob/feature/incus-client/openspec/changes/add-embedded-incus-foundation/proposal.md), which independently implements the portable Incus client as the `:opsmaru_incus` library in `upmaru/opsmaru-incus`. This later change adds tools/tasks/central registration/connectors on that verified library.
- Keep one Phoenix/Cowboy application `:opsmaru`, namespaces `Opsmaru`/`OpsmaruWeb`, reusable as an embedded dependency and delivered as a central Linux service.
- Replace the earlier one-host-per-endpoint design with an authorized target registry. One central MCP endpoint manages multiple registered standalone Incus servers, clusters and Macus installations using stable target IDs, explicit project/member selection and per-target capabilities.
- Connect reachable Incus targets directly through native HTTPS with verified server identity and a dedicated trusted client certificate/private key. No full Opsmaru install on the target is required.
- Provide a versioned authenticated outbound connector for private targets. Macus embeds it in its existing Elixir server; private Linux networks can install a small connector-only release using a configured Incus Unix socket or HTTPS backend, with no Phoenix listener/MCP endpoint or identity database.
- Default library inclusion to embedded mode with no endpoint or repository. Explicit standalone mode runs the central service; explicit connector-only mode starts outbound workers and private receipt storage without a public listener. Macus remains standalone-capable with its connector disabled until explicit enrollment.
- Reuse portable Incus clients, bounded operation/stream contracts and the designated [kritama/tama-mcp](https://github.com/kritama/tama-mcp) integration. Target selection is shared schema input; direct transport and connector execution must not duplicate workload behavior.
- Add durable storage adapters: central PostgreSQL tasks/intents/idempotency/outbox and target registry; host-private local journals for embedded tasks and connector execution receipts. Stable target/registration generation and native operation IDs prevent reconnect replay or accidental reassignment.
- Retain configurable external OIDC/OAuth for central users, tested with Keycloak under [add-remote-api-and-oauth](../add-remote-api-and-oauth/proposal.md). Backend Incus certificates and enrolled connector device identities are distinct from user tokens.
- Support remote host capabilities only through known versioned descriptors and explicit target permission. Swift/VZ lifecycle and Mac filesystem sharing remain Macus-owned.
- Deliver the central and connector-only Linux roles as explicit bundled-ERTS releases with passive systemd installation, separate fixture/package/live acceptance and preserved Incus data.
- Keep Tama orchestration, scheduling, Terraform jobs, environment images, skills and workspace provisioning as later changes. Multi-target management does not introduce a placement scheduler or workload manager.

## Capabilities

### New Capabilities

- `mcp-service`: shared catalogue, explicit registered-target selection and caller-bound permissions.
- `task-execution`: central/local durable stores, remote receipts, reconciliation and bounded execution.
- `host-capabilities`: registered target identity, enrollment/connector protocol and truthful host features/locality.
- `standalone-service`: central Linux gateway, direct cluster access, optional connector-only delivery and lifecycle.

### Modified Capabilities

None in the main inventory. Core embedded-service/incus-client requirements and implementation tasks now belong only to add-embedded-incus-foundation in `upmaru/opsmaru-incus`. This later change consumes those contracts; central and optional connector activation are specified under standalone-service/host-capabilities without duplicating the foundational client.

## Impact

- The foundational library/client can be completed and pinned by Macus before this central-service change.
- [add-embeddable-incus-gateway](../add-embeddable-incus-gateway/proposal.md) separately owns optional reusable native proxy mechanics. It does not add a central multi-target native proxy or gate this change; Macus retains its endpoint, authentication/trust policy and private Swift/Incus bridge.
- The Phoenix scaffold exists on the feature branch; shared compute, central registry, connector roles and authentication remain unimplemented. Keep the one completed bootstrap task as evidence, not central-service acceptance.
- `add-remote-api-and-oauth` supplies central user verification, local target/project grants, browser administration and enrollment REST adapters. Implement the core target/storage/connector contracts here; wire the HTTP/auth surface there without duplicated registries or circular completion requirements.
- Macus's `add-elixir-server` consumes the library and connector, adds `macus connect [url]`, connection status and disconnect, and preserves its local gateway, native proxy and Swift runtime. Macus does not become a multi-cluster manager.
- Production consumers still pin an implemented immutable dependency and upstream reference; separate Macus/central/connector evidence. No source migration, service/provider activation, workload mutation, branch merge or hardware acceptance occurs during this planning update.
