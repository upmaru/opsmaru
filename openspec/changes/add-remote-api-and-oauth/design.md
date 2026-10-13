# Design

> **Revision note (2026-10-13), to resolve before implementing this change:** `:opsmaru` is now a standalone central service with its own business logic; Macus no longer embeds it. The Incus client, the native gateway mechanics and the shared Incus operation/MCP tool definitions live in the pure `:opsmaru_incus` library ([upmaru/opsmaru-incus](https://github.com/upmaru/opsmaru-incus): `add-embedded-incus-foundation`, `add-embeddable-incus-gateway`, `add-incus-operations`), which central Opsmaru consumes like Macus does. The first milestone is a standalone Macus; registering a Mac with central is Macus's later `add-central-registration`, where a reachable Mac can be a direct-HTTPS Incus target through its gateway and the outbound connector serves Macs behind NAT. Sections below that describe Macus embedding `:opsmaru`, an embedded deployment role, or `Opsmaru.MCP.Tools.*` defined here are superseded by this note.

## Context

See [proposal.md](proposal.md). The root Phoenix/Cowboy scaffold has PostgreSQL/Ecto and HTML/LiveView/assets with embedded-by-default supervision. No accounts, OAuth, REST compute or MCP operations are implemented. This revision replaces the previously proposed local authorization server with the user's selected external-provider architecture; there is no deployed issuer state to migrate.

The independent [add-embedded-incus-foundation](https://github.com/upmaru/opsmaru-incus/blob/feature/incus-client/openspec/changes/add-embedded-incus-foundation/design.md) delivers embedding/client first, without these central auth features. The later shared [add-compute-substrate](../add-compute-substrate/design.md) foundation remains pending. It owns Incus, MCP tools, central SQL task coordination and local execution journals. Macus owns its public gateway and private Swift/Incus sockets; Opsmaru remains a library in that BEAM. The standalone service is central: one MCP/REST endpoint manages multiple registered targets. Reachable clusters use direct Incus HTTPS; private Linux and Macus installations initiate outbound connector sessions. This supersedes the earlier per-host endpoint model.

The separate [add-embeddable-incus-gateway](https://github.com/upmaru/opsmaru-incus/blob/feature/incus-gateway-and-operations/openspec/changes/add-embeddable-incus-gateway/design.md) proposes shared native relay mechanics with host-owned mounting, policy and trust. It is independent of central OIDC/REST/MCP, does not alter Macus's certificate/bearer contract, and does not automatically expose native Incus routes on the central service. Its portable acceptance can run in Opsmaru without Macus, while typed-client and installed/hardware evidence remain separate.

The designated protocol sources are [kritama/tama-oauth](https://github.com/kritama/tama-oauth) (`:tama_oauth`, `TamaOAuth`) and [kritama/tama-mcp](https://github.com/kritama/tama-mcp) (`:tama_mcp`, `TamaMCP`). The inspected TamaOAuth 0.4.2 `ProtectedResource` verifies JWTs, requires active introspection and exact agreement of `iss sub aud client_id scope jti iat exp`; its introspection validator also requires `grant_id` and a string audience. These are compatibility inputs, not proof of generic provider support. Standard Keycloak tokens can use `azp`, audience arrays and introspection responses without that application-specific grant field. Never fabricate missing identity/grant claims to pass validation.

## Goals / Non-Goals

**Goals:**

- Configurable external identity with central target/project authorization and stable task ownership across hosts and restarts.
- Shared REST/MCP/direct-call semantics, bounded remote authentication and listener-free embedding.
- Keycloak as the first verified integration profile, with provider-neutral OIDC/OAuth contracts.
- Human login and unattended Tama service identities without implementing a local authorization server.

**Non-Goals:**

- Local passwords, user signup, an Opsmaru token issuer, signing-key generation, consent UI, provider client registration or refresh-family management.
- Bundling or starting Keycloak in production, multi-issuer routing per deployment, mandatory provider-vendor code in compute, or provider account administration.
- Changing Macus's initial certificate/bearer gateway contract, implementing an Incus OIDC proxy, provider federation, a workload dashboard or orchestration engine.
- Implementation or live provider/service activation in this planning revision.

## Decisions

### 1. External provider boundary and configuration

Standalone Opsmaru is an OAuth protected resource for `/mcp` and `/api/v1`, plus an OIDC relying party for its small browser surface. The external provider owns user authentication, MFA, client registration, consent, access/refresh issuance and service accounts. One configured issuer authenticates central users. MCP and REST audiences identify the central resources; registered target/project grants constrain backend access independently of token audience. Target IDs are not additional OAuth issuers or token endpoints.

Use explicit configuration for exact `issuer`, canonical public resource URLs/audiences, allowed access-token algorithms, provider timeout/cache bounds, approved calling client IDs and deterministic claim mappings. Browser configuration adds a registered relying-party client ID, protected client credential reference and exact callback URI. Resource introspection uses its own approved confidential-client authentication and protected credential reference. These credentials authenticate Opsmaru to the provider; they are not local token signing keys. Production provider URLs and callbacks use HTTPS.

Load OIDC discovery only from the operator-configured issuer and require exact issuer agreement. Provider endpoints, JWKS and any endpoint-origin override must be explicitly trusted by configuration, with bounded transport, response sizes, redirects and TLS verification. Do not discover issuers or fetch keys from unverified token `iss`, `jku` or `x5u`, request URLs or browser parameters. A non-HTTPS issuer is permitted only in an explicitly isolated development/test profile; never infer that profile from an address or environment accident.

Invalid configuration fails before activation. Discovery/key/introspection outages never enable anonymous access or switch issuers. Valid bounded cached discovery/keys may be used within their expiry; inability to prove token activity denies protected calls. The service can remain alive with sanitized readiness diagnostics and an unavailable authentication subsystem. Keycloak is separately operated and configured, never a child of Opsmaru supervision.

Alternative: local password/issuer capability creates separate account stores for every cluster. External OIDC login followed by Opsmaru-issued API tokens also retains unnecessary issuer lifecycle; the chosen provider issues resource access tokens directly.

### 2. Protected-resource validation and upstream compatibility gate

The initial supported external-token profile is signed JWT access tokens with JWKS validation plus RFC 7662 active introspection. Opaque tokens and vendor-specific alternative flows are deferred. Require exact issuer, audience membership, allowed algorithm/key, subject, calling client, granted scopes and valid times; reject ID tokens as API credentials. MCP and REST have distinct audiences. A token authorizes both only when both audiences and scopes were explicitly granted; accepting a configured audience array does not weaken this check.

Use TamaOAuth for protocol verification, introspection and metadata, TamaMCP for its supported transport/discovery/task contracts. Opsmaru owns trusted provider HTTP/key-cache adapters, local principal mapping and policy. First capture real Keycloak tokens/introspection responses in isolated tests and compare them with the pinned library profile. Configure valid provider claim mappers where appropriate. Any reusable support for standard audience arrays, provider client-claim differences, optional introspection fields, browser OIDC verification or standard confidential-client authentication belongs in a separately authorized kritama/tama-oauth change and a verified immutable dependency revision. Do not bypass its verifier, synthesize `grant_id`, silently drop security fields or claim compatibility before that gate passes. The earlier local token-request client_credentials parser gap is irrelevant here: clients exchange directly with the provider.

Refresh/revocation endpoints stay at the issuer. Opsmaru performs no refresh exchange for API callers. Cache successful activity checks for at most 30 seconds and never beyond token expiry; hash token cache keys and partition caches by issuer/resource/configuration version. Do not persist raw API tokens. For new requests after cache expiry, unavailable/inactive introspection rejects access. Long-lived delivery rechecks local policy and activity within the same 30-second maximum, and closes on expiry or failed reauthorization. Fixture acceptance must establish the provider's actual revocation semantics and the end-to-end bound; disabling a user or calling logout is not assumed to invalidate every access token instantly.

Bound clock skew, key/cache cardinality and refresh frequency. Unknown key IDs allow a single rate-limited refresh, then denial if unresolved; never try arbitrary token-controlled endpoints. Key rotation tests verify new keys and the documented overlap/retirement policy. No signature-only fallback is included in the first profile.

Alternative: offline JWT-only verification offers more provider independence but leaves revocation effective only at expiry. Active introspection preserves the existing bounded revocation contract at the cost of provider availability.

### 3. Stable principals and local permission persistence

PostgreSQL stores central principal bindings keyed by exact `(issuer, subject)`, explicit principal kind, approved service-client binding, target/project/scope grants, policy version, local disable state, hashed browser session IDs and bounded audit. Email, display name and caller-supplied owner/client fields are not identity keys. Explicit service-principal bindings distinguish machine tokens from human tokens; never infer machine authority from a username prefix.

Provision the first local administrator through an explicit owner-local command binding an existing external subject. It creates no provider account or password. Other grants require local administrative authority. A newly authenticated provider user has no compute permission until a local grant exists. Provider groups/roles can be mapped only through an explicit administrator-selected claim/value-to-local-policy mapping; arbitrary groups or realm-admin claims confer no authority automatically.

Effective authorization is the intersection of verified token permissions, approved client identity and current central target/project/scope grants. Disabled subjects/issuers and current policy revisions invalidate access caches. One exact subject retains the owner key across token refresh and process restart; changing issuer or deleting/recreating a provider subject is a different identity. Do not silently rebind historical tasks by email. Issuer migration requires explicit administrative mapping and retained audit; otherwise old tasks remain preserved but inaccessible to the new subject.

SQL owns central session/policy updates and concurrent grant/disable transitions. The compute-substrate registry/device tables store target generation, public device certificate/fingerprint and registration policy. Only protected credential references are stored for native Incus client keys. Device private keys remain at the connector. Provider credential lifecycle remains external. Keep verification hashes for opaque browser session IDs; keep provider client secrets outside ordinary database/status output in protected configuration. Audit only bounded actor/client/resource/action/correlation metadata. No passwords, code/refresh families, signing-key store or local active-token ledger is added. Embedded callers use host identity/persistence without Opsmaru.Repo.

### 4. Minimal browser relying party

`/login` starts an authorization-code flow with S256 PKCE, state and nonce against the configured provider; `/oidc/callback` exchanges a short-lived code at that provider and validates its ID token issuer/signature/audience/expiry/nonce before mapping the exact external principal. Transaction state is one-use, server-bound, expiring and cannot change provider, client, redirect or return target. Reject unsolicited, reused, mixed-up or invalid callbacks. Tokens and codes are excluded from logs/output; the protocol code is transient at the registered callback and cannot become a return URL or persistent browser artifact.

Use the designated protocol library for reusable OIDC/PKCE validation; upstream any missing primitives before enabling this surface. No local user credential entry or OAuth consent page is provided. Keycloak handles login/MFA/consent. A provider-authenticated but ungranted user can see a bounded access-denied page, not create an admin session.

Create a fresh hashed opaque server-side session after login, with secure HttpOnly/SameSite production cookies, CSRF protection, bounded login starts, LiveView origin checks and local revocation. Maximum session lifetime is 15 minutes, capped at verified login token expiry; renewal requires a fresh provider round trip, normally using its SSO session. Do not persist upstream refresh/access tokens for browser renewal in this first profile. Provider-side session revocation is therefore not advertised as immediate local logout; current local disable/logout takes effect immediately, and external session state is rechecked on renewal. Local logout always clears the Opsmaru session; provider-wide RP-initiated logout is optional and separately verified.

Minimal UI shows current identity, own sessions, permitted targets and central permissions; authorized administrators manage target registration, connector revocation and subject/service target grants. Provider accounts, clients, consent and token issuance remain in its console. Browser cookies do not authorize REST/MCP compute routes; those require explicit resource bearer credentials. UI policy administration uses its own authenticated/CSRF-protected browser routes and local admin check. Browser pipeline does not consume MCP request framing. No routes auto-mount in embedded Macus.

### 5. REST and MCP adapt one operation boundary

`Opsmaru.Operations` registers supported descriptors with input/output schemas, scopes, task policy and implementation bindings. REST, MCP and direct Elixir calls adapt this common domain API. The native Incus API and Macus proxy remain separate. Macros are future explicitly registered bounded operations, not caller-supplied programs.

| Route | Contract |
| --- | --- |
| GET /api/v1/operations | Scope-filtered operation manifest |
| POST /api/v1/operations/:name | Registered invocation with explicit target_id; Idempotency-Key required for mutations |
| GET /api/v1/targets | Permission-filtered target/capability/readiness inventory |
| POST /api/v1/targets | Authorized direct-HTTPS target registration with protected credential references |
| PATCH /api/v1/targets/:id | Authorized target disable/configuration update without silent identity reassignment |
| POST /api/v1/enrollments | Authorized short-lived connector enrollment challenge |
| POST /api/v1/enrollments/:id/complete | One-use device key proof and approved target registration |
| POST /api/v1/targets/:id/revoke-connector | Authorized device/session revocation, preserving historical work |
| GET /api/v1/tasks/:id | Owner-bound committed state/result |
| POST /api/v1/tasks/:id/cancel | Durable cancellation intent |
| GET /.well-known/oauth-protected-resource/mcp | Canonical MCP resource and external authorization server |
| GET /.well-known/oauth-protected-resource/api/v1 | Canonical REST resource and external authorization server |

Use 200 for final synchronous outcomes, 202 with task identity/Location only after durable acceptance, 400/422 for invalid input, 401/403 for authentication/policy denial, owner-safe 404 for inaccessible tasks, 409 for conflicting idempotency input and 503 for unavailable authentication/backend/storage. Challenges point to protected-resource metadata. Provider authorization-server metadata and JWKS stay at the provider; Opsmaru publishes no `/oauth/token`, `/oauth/authorize`, OAuth client-registration, OAuth token-revocation or local JWKS service. Missing client registration is diagnosed with provider setup guidance, not solved by automatic local registration.

Domain errors carry stable codes/correlation IDs without tokens or private backend addresses. Protected-resource metadata lists the configured external issuer and only tested scopes/methods. MCP OAuth resource indicators must result in the exact configured audience; Keycloak's handling of `resource`, audiences and client-registration/discovery mechanisms is an explicit acceptance gate. A tested pre-registered client profile is the initial integration; do not claim arbitrary MCP client interoperability.

### 6. Central admission, enrollment and connector trust

Use the compute-substrate's central PostgreSQL registry/task store, shared operation boundary and connector protocol. Persist central task, target/generation/owner binding, input digest, idempotency receipt and dispatch outbox in one transaction before a 202 response. Replays, polling and cancellation require current user/target/project/tool grants. Do not keep a second central file journal or duplicate the connector runner. Local journals contain linked dispatch receipts/native operation identity for independently safe reconciliation. Retain nonterminal/uncertain receipts and documented post-terminal reconciliation windows.

Target registration is an administrative mutation with validated endpoint identity/network policy and protected key references. Users cannot register arbitrary backend URLs through a normal operation field. A cluster is one target, with native project/member routing; aggregated inventory is permission-filtered and can report partial target failures. Shared schemas include target_id; it is required centrally and may be omitted only by a local Macus caller for its configured local target. No central default target is changed by an agent.

Connector enrollment is authorized by an external user API token with appropriate enrollment scope plus central permission. Bind a five-minute one-use challenge to the same central URL, registering principal, public device certificate, proof of private key possession and explicit target/project/capability grant. Complete the compute-substrate device registration atomically in a separate explicit transaction, returning a stable target/generation and enrollment receipt. Duplicate completion with the same committed proof recovers that receipt without creating another target/grant; a consumed challenge cannot authorize a different device. Incomplete/expired enrollments confer no execution permission. Never upload the device private key or persist the user's API/refresh token in connector state.

Macus enrollment uses a pre-registered public CLI client at the configured external provider with Device Authorization Grant and browser confirmation. Keycloak is the first tested profile. The Elixir server drives the bounded provider exchange through designated OAuth primitives; Swift displays the user verification instruction and opens the system browser. The public enrollment client ID and supported flow are documented by trusted central metadata/configuration. Device grant support is an explicit upstream/interoperability gate, not assumed for every OIDC provider. Other central web/agent logins retain authorization-code S256 PKCE. Provider-issued enrollment tokens authorize setup only; persistent reconnect uses the enrolled device certificate/private key. No local OAuth issuer is introduced.

Connector ingress is a separate authenticated internal TLS/WebSocket route, `/connectors/v1/connect`, with explicit device trust before upgrade. It does not accept a user bearer token as proof of installed device identity. Active target/generation, negotiated operation versions and current session epoch bind each dispatch. Key rotation/revocation update device trust explicitly and invalidate old sessions. Central delegation contains only verified owner/operation/target/project context; connector limits intersect that authority with locally approved capabilities. No user token is forwarded to Incus or converted into a local Macus admin token.

Direct Incus HTTPS uses target-specific client certificate/private-key credentials and verified server trust; existing native restrictions plus central checks are enforced before access. Connected Linux uses its configured Unix or private HTTPS client locally. Macus uses incus.sock and its Swift runtime adapter. API bearer authentication and native backend/device trust are independent; a separately configured Incus OIDC provider is optional for direct native users and cannot secure Opsmaru by itself.

Already accepted work remains durable if user credentials expire, the connector disconnects or target availability changes. Current local execution policy is checked before delayed mutations. Revoked/replacement generations do not inherit accepted work, and uncertain possible backend acceptance is never replayed. Device/target revocation blocks new dispatch and delivery within 30 seconds; a local disconnect closes its worker immediately. Do not describe remote acceptance or stream interruption as final completion/cancellation.

### 7. Central, embedded and connector-only startup

Central standalone mode explicitly configures HTTPS, advertised origin, SQL, external provider/resource/client profile and registry adapters, not a required local Incus backend. An empty registry is valid for first registration. SQL migrations and first central administrator subject binding are explicit deployment commands. Missing user identity cannot fall back to local token generation; provider outages preserve central task/target data while refusing unprovable user access.

Macus embeds shared operations and an optional enrolled connector in its existing Elixir server, with its own local gateway identity and local journal. It never starts Opsmaru Endpoint/Repo or the central browser/provider UI. Macus's local certificate/bearer gateway and `macus start` remain independent of central registration. `macus connect [url]` may explicitly activate/recover only the already installed matching Elixir job, then perform enrollment; it does not start Swift/VZ, create an appliance, change shares or expose an inbound port. CLI behavior and service identity checks are defined in Macus's own change.

Connector-only Linux requires protected device/receipt state, central trust and one authorized local/private Incus backend, without database/issuer credentials, user login UI or listener. The device enrollment adapter may be used by an explicitly invoked setup command; ordinary reconnect uses device trust only. Passive packaging activates none of these roles or registrations.

### 8. Keycloak test profile and delivery evidence

During implementation pin a supported official Keycloak image tag plus immutable digest and record the matching documentation/profile. Use an isolated realm, private fixture state and explicit start/stop commands. Commit reproducible realm/client/audience/scope configuration without secrets; supply test credentials through excluded local fixture configuration. A loopback-only development profile is explicit and cannot be used as production security evidence.

Define separate pre-registered clients for the browser relying party, public MCP/REST test agent with S256 PKCE, public Macus enrollment CLI with Device Authorization Grant, confidential introspection and Tama service credentials. Use distinct central MCP/REST audiences and a service subject with bounded target/project grants. Enroll separate device key pairs and verify they cannot impersonate user clients or each other. Optional direct Incus tests use another registration with Device Authorization Grant; they remain a separate integration gate. PKCE, audience/resource mapping, standard claim shape and introspection agreement are tested together, not inferred from Keycloak feature names.

Positive/negative fixtures cover browser state/nonce/verifier and session isolation; human/service login; wrong issuer/audience/client/subject/type/scope; ungranted and disabled users; cross-owner tasks; key rotation; revocation/expiry/activity-cache/stream bounds; provider outage; and real external-graph multi-target submission/polling without duplicate mutations; direct certificate trust, outbound enrollment replay/key/generation and connector interruption recovery. Do not start Keycloak, provision real users, deploy a listener or invoke Incus merely to publish this plan. Keep fixture, installed Linux, actual remote client and Macus hardware evidence separate.

## Risks / Trade-offs

- Provider outage interrupts fresh authorization -> bounded active-check cache, denial after expiry, sanitized readiness and preserved accepted task/backend state.
- Keycloak defaults differ from TamaOAuth's strict contract -> capture real claim fixtures, legitimate provider mappings and verified upstream protocol updates before advertising support.
- OIDC support is mistaken for arbitrary MCP compatibility -> test resource indicators, discovery and the chosen registered client; document unsupported mechanisms.
- Provider-wide accounts become privileged on every host -> local grants default to none and intersect with token scopes/client/resource; explicit administrator binding only.
- Identity changes orphan historical task access -> exact issuer/subject owner keys and explicit audited migration without email rebinding.
- Browser logout is confused with revoking API credentials -> separate session and provider credential lifecycles with documented 15-minute browser and 30-second activity-check bounds.
- Compiled web modules start services in Macus -> mode-aware supervision and actual embedded-start fixtures with no Repo/provider credentials/extra endpoint.

## Migration Plan

No local accounts/issuer state exist in the scaffold. Revise the pending foundation before implementation, then pin compatible protocol dependencies, implement central registry/task/policy migrations and provider validation, and prove isolated Keycloak acceptance before standalone activation. Preserve task ownership and Macus embedding.

Upgrades preserve central registry/policy/session/task database and connector/local journals. Explicit migrations and rollback compatibility checks must never reset grants, subjects or backend data. Provider replacement is an explicit identity migration, not a deployment URL edit that silently transfers ownership. This planning request performs no schema migration, provider startup or service activation.

## Open Questions

- Deployment issuer URL, approved client IDs/credential references, resource audiences and exact external subject grants are operator inputs.
- The compatible protocol-library revision and Keycloak image digest are selected and recorded during implementation before supported-profile claims; the validation/compatibility gates above are mandatory.

## References

- [Keycloak OIDC endpoints and flows](https://www.keycloak.org/securing-apps/oidc-layers).
- [Keycloak container deployment](https://www.keycloak.org/server/containers).
- [OIDC Core](https://openid.net/specs/openid-connect-core-1_0.html) and [OIDC Discovery](https://openid.net/specs/openid-connect-discovery-1_0.html).
- [OAuth Security BCP, RFC 9700](https://www.rfc-editor.org/rfc/rfc9700.html), [PKCE, RFC 7636](https://www.rfc-editor.org/rfc/rfc7636.html).
- [Protected Resource Metadata, RFC 9728](https://www.rfc-editor.org/rfc/rfc9728.html), [Authorization Server Metadata, RFC 8414](https://www.rfc-editor.org/rfc/rfc8414.html).
- [Token Introspection, RFC 7662](https://www.rfc-editor.org/rfc/rfc7662.html), [Resource Indicators, RFC 8707](https://www.rfc-editor.org/rfc/rfc8707.html).
- [TamaOAuth source](https://github.com/kritama/tama-oauth), inspected package 0.4.2 as compatibility evidence, not an external-provider support claim.
