# Proposal

## Why

Opsmaru's compute foundation exposes reusable operations through MCP but lacks a REST contract and a self-hosted identity/consent surface for remote callers. A database-backed OAuth service and minimal browser UI will let direct agents and an external opsmaru-tama graph use the same authorized compute operations without embedding orchestration logic in Opsmaru.

## What Changes

- Retain one Phoenix/Cowboy application with PostgreSQL/Ecto, HTML/LiveView and assets for standalone accounts and OAuth UI. Embedded Macus mode starts neither the Opsmaru endpoint nor repository by default and continues to use host-supplied identity/persistence.
- Add a versioned REST operation/task API at `/api/v1` over the same application command boundary used by MCP and direct Elixir calls. Share schemas, scope checks, owner/host bindings, durable task identity, cancellation and uncertain-outcome handling; preserve native Incus as the backend.
- Add a self-hosted OAuth authorization server with authorization-code plus S256 PKCE, exact registered redirect/resource/scope validation, one-use codes, refresh rotation/replay handling, discovery and revocation. Use [kritama/tama-oauth](https://github.com/kritama/tama-oauth) (`:tama_oauth`, `TamaOAuth`) for protocol primitives with application-owned persistence and policy; do not claim the library already implements a complete server.
- Add first-owner bootstrap and a minimal browser login, consent, registered-client/grant management and revocation interface. There is no public account signup or workload dashboard in this change.
- Support separately authorized confidential service clients for REST orchestration, with client credentials bound to service principals and allowed host/project/scopes rather than user impersonation. Resolve reusable grant-protocol gaps in kritama/tama-oauth and consume a verified supported revision before advertising the grant.
- Publish MCP protected-resource metadata and resource-bound credentials for MCP and REST. Embedded deployments use their host issuer and explicitly mounted shared REST/MCP handlers without starting another issuer, database or endpoint.
- Add identity storage for users, sessions, clients, grants, code/token families, revocation, replay and audit metadata. The existing host-private task journal remains a separate execution store; PostgreSQL is not made mandatory for embedded compute.
- Define restart-safe owner-bound request deduplication and task polling suitable for external orchestration. No Tama graph implementation, multi-host scheduler, arbitrary macro language or new development-workspace feature is included.

## Capabilities

### New Capabilities

- `rest-api`: shared versioned command/inspection/task endpoints, result contracts and replay-safe caller integration.
- `identity-persistence`: optional embedded and explicit standalone persistence, accounts, credential lifecycle and atomic transitions.
- `oauth-authorization`: self-hosted remote authorization, token/resource/client policy and discovery contracts.
- `oauth-web-interface`: first-owner setup, secure browser authentication, consent and limited authorization administration.

### Modified Capabilities

None in the main specification inventory, which is still empty. This change depends on the pending `add-compute-substrate` change. Its project design is reconciled to allow the explicitly requested web/Ecto scaffold while retaining its listener-free embedding and task/Incus contracts; those foundation contracts are not duplicated here.

## Impact

- The current feature branch contains an explicitly requested `mix phx.new` scaffold, mode-aware startup, pinned tools/dependencies and a baseline development page. It does not implement accounts, OAuth, REST/MCP compute tools or real Incus execution.
- Implementation will add application contexts, migrations, authorization adapters, REST controllers, browser routes/components and security/conformance fixtures. Database transactions own OAuth lifecycle; the shared task store owns execution handoff and REST deduplication, avoiding a split transaction across SQL and the task journal.
- Reuse the inspected TamaOAuth 0.4.2 protocol surface as a compatibility reference, resolve a real immutable/package dependency before implementation and verify its grant/conformance coverage. OAuth 2.1 is targeted as the pinned Internet-Draft with applicable finalized security/discovery RFCs, not asserted as a finalized standard.
- The standalone service authenticates remote users itself. Macus retains its own gateway/native proxy trust and can embed shared services without these standalone account/issuer features; mounting the shared REST API in Macus is a consumer integration step.
- Standalone Linux acceptance covers database migrations, full browser-to-token flows, API/MCP scope equivalence, revocation and process-restart reconciliation. Installed and real-Incus/Macus acceptance remain distinct.
