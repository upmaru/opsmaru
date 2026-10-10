# Proposal

## Why

After add-embedded-incus-foundation, Opsmaru's later compute-substrate layer needs a REST contract and remote authentication shared through one central gateway managing registered compute targets. A configurable external OIDC/OAuth authorization server lets operators use one identity system across clusters while Opsmaru enforces central target/project permissions. Keycloak is the first integration test provider; it is not a bundled runtime dependency.

## What Changes

- Retain one Phoenix/Cowboy application with optional PostgreSQL/Ecto and HTML/LiveView. Embedded Macus mode starts neither the Opsmaru endpoint nor repository and continues to use host-supplied identity and persistence.
- Add versioned REST operations/tasks at `/api/v1` over the same domain command boundary as MCP and direct Elixir calls, sharing schemas, permissions, durable identity, cancellation and replay-safe reconciliation.
- Configure one external issuer for the central deployment, canonical MCP/REST resource audiences, approved clients, claim mappings and protected-resource discovery. Opsmaru is an OAuth resource server and browser OIDC relying party, not an authorization server.
- Validate external JWT access tokens and active introspection before compute access, with bounded caches, expiry, provider key rotation, outage denial and local permission checks. Use the designated [kritama/tama-oauth](https://github.com/kritama/tama-oauth) primitives and resolve reusable provider-compatibility gaps there rather than creating a second protocol engine.
- Support provider-issued human and service identities. Authorization-code/S256 PKCE, refresh, client registration, consent and service-client token issuance belong to the external provider. Opsmaru never forwards user tokens to Incus or exchanges them for its own compute tokens.
- Replace local passwords, account creation, consent, signing keys and code/refresh-family storage with stable external subject bindings, central target/project/scope grants, browser sessions and bounded audit. Initial local administrator binding is an explicit owner-local action against an exact issuer/subject.
- Provide a minimal browser sign-in redirect, validated OIDC callback, local logout and local authorization/session administration. No public signup, provider account/client administration or workload dashboard is added.
- Add permission-filtered target registration/inspection/revocation routes and one-use key-bound enrollment for outbound devices. Reachable Incus targets use native HTTPS certificate/private-key credentials; Macus and private Linux targets use enrolled device sessions. User tokens never become device or Incus credentials.
- Add reproducible, isolated Keycloak acceptance for browser login, MCP/REST access, service clients, revocation/expiry, key rotation and negative claim/policy cases. Record the exact provider image digest and realm/client profile when implemented.
- Keep reasoning and orchestration in the external opsmaru-tama graph; development macros, multi-host scheduling and workspace/skills features remain later changes.

## Capabilities

### New Capabilities

- `rest-api`: shared versioned operation/task endpoints and durable caller reconciliation.
- `identity-persistence`: external subject/device bindings, target grants, sessions and audit with optional embedded persistence.
- `oauth-authorization`: configurable external issuer validation, resource metadata and owner-bound human/service authorization.
- `oauth-web-interface`: external OIDC login and central target/session/permission administration without local credential issuance.

### Modified Capabilities

None in the empty main specification inventory. Reconcile pending `add-compute-substrate` standalone credential administration with this external-provider contract; preserve its compute, task and embedding boundaries. Existing capability paths are retained so the current complete proposal can be revised in place.

## Impact

- The branch currently contains a generated Phoenix scaffold, not implemented authentication, REST/MCP compute or live Incus execution. This revision changes planning and explanatory documentation only.
- Implementation adds provider configuration/discovery, resource verification, claim normalization, local policy migrations, browser callback/session handlers and Keycloak fixtures. The central PostgreSQL database owns registry/policy/sessions and atomic tasks/idempotency/outbox. Embedded Macus and Linux connectors use the compute-substrate's private local journals for execution receipts without a central database dependency.
- Retain [kritama/tama-mcp](https://github.com/kritama/tama-mcp) and TamaOAuth as the protocol targets. The inspected TamaOAuth 0.4.2 protected-resource profile is stricter than generic Keycloak defaults; compatibility must be demonstrated or resolved upstream before support claims. Opsmaru no longer needs an authorization-server client_credentials parser or token-issuance implementation.
- Standalone production requires a configured external provider; there is no automatic local issuer fallback. Macus retains its existing gateway/native proxy trust and embeds shared compute without adopting this standalone login surface.
- Separate protocol fixtures, isolated Keycloak integration, installed Linux/remote access and real Incus/Macus acceptance. Publishing a plan does not complete any live authentication or hardware gate.
