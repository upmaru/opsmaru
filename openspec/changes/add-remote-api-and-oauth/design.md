# Design

## Context

See [proposal.md](proposal.md). This change builds on [add-compute-substrate](../add-compute-substrate/design.md), whose shared Incus/MCP/task implementation is still pending. The explicitly requested bootstrap used Phoenix installer 1.8.15 with Cowboy, PostgreSQL/Ecto, binary IDs, HTML/LiveView/assets and no mailer/dashboard/gettext. The root application now distinguishes embedded and standalone supervision; embedded startup starts neither the endpoint nor Repo. It has only generated web routes, not accounts, OAuth, REST compute or MCP operations.

The original headless/no-Ecto foundation is reconciled to retain an optional standalone web/database surface. PostgreSQL is for identity and OAuth state; the host-private task journal remains the execution store. Macus's existing gateway trust/runtime/proxy belongs to Macus and is not replaced by a second issuer.

The inspected Tama checkout consumes Hex `tama_oauth` 0.4.2. Its source provides framework-neutral PKCE, code/refresh request parsing, private-key client authentication, JWT/JWKS, metadata, rotation/replay decisions and registration primitives. It does not provide Phoenix routes, user accounts, consent or database transactions. Its current token parser supports authorization_code and refresh_token, not client_credentials: that gap must be implemented and verified explicitly, not hidden by advertising an unsupported grant. The designated protocol sources are [kritama/tama-oauth](https://github.com/kritama/tama-oauth) (`:tama_oauth`, `TamaOAuth`) and [kritama/tama-mcp](https://github.com/kritama/tama-mcp) (`:tama_mcp`, `TamaMCP`). Opsmaru owns account/persistence/policy/HTTP adapters, not another OAuth or MCP protocol engine.

## Goals / Non-Goals

**Goals:**

- One reusable command API presented through REST, MCP and direct Elixir calls, preserving owner/host/task identity.
- A self-hosted standalone authorization service and small browser login/consent/admin surface for remote users and agents.
- A service-client contract usable by an external opsmaru-tama orchestration graph without running that reasoning graph in Opsmaru.
- Database-backed credential lifecycle that remains optional when embedding in a host with its own identity system.

**Non-Goals:**

- Implementing the OAuth/REST features in the bootstrap commit, treating a scaffold as a security-ready deployment, or changing Macus application code here.
- Public self-signup, a workload dashboard, email delivery, external identity-provider federation, social login or an OIDC provider in this first authorization change.
- A generic workflow language, model execution, multi-host scheduler, skills/environment/workspace implementation or a replacement Incus API.
- Making PostgreSQL, Opsmaru's endpoint, private signing keys or standalone browser routes mandatory for Macus embedding.

## Decisions

### 1. Keep a full Phoenix shell with explicit optional startup

Use the existing single application `:opsmaru`. Keep Ecto/Repo and HTML/LiveView/assets available for standalone functionality, but condition their supervision on explicit standalone deployment. Embedded mode starts configured shared compute services only and remains safe without DATABASE_URL, browser secrets or OAuth keys. The explicit bootstrap currently supervises telemetry alone in embedded mode; foundation workers and host readiness gates remain future implementation.

Test browser behavior in a standalone fixture configuration with `server: false` and an isolated PostgreSQL database. Independently test actual embedded application startup with hostile PHX_SERVER/PORT values and no database/endpoint processes. Macus supplies its own principal and optional persistence adapters; the dependency's release runtime configuration is not evaluated as Macus configuration.

Standalone production requires configured TLS, advertised host, database and browser secret. Default bind is loopback. A reverse proxy or remote binding must be a deliberate deployment configuration with trusted forwarded-header policy, not automatic environment inference. Core embedding keeps its endpoint absent even though UI modules are compiled into the dependency.

### 2. REST and MCP adapt one operation boundary

Introduce `Opsmaru.Operations` as the domain entry point and registry of explicitly supported operations. Each descriptor owns its input/output schema, scope requirements, task policy and implementation binding. MCP tool modules and REST handlers adapt these descriptors; neither transport owns a separate permission or execution implementation. Keep domain outcomes independent of HTTP codes and MCP response structs.

Proposed REST routes:

| Route | Contract |
| --- | --- |
| GET /api/v1/operations | Scope-filtered operation manifest and schema references |
| POST /api/v1/operations/:name | Validated registered invocation; Idempotency-Key required for mutations |
| GET /api/v1/tasks/:id | Owner-bound committed task state/result |
| POST /api/v1/tasks/:id/cancel | Durable cancellation intent, with truthful backend state |

Use 200 for final synchronous outcomes, 202 plus task identity/Location for durably accepted asynchronous execution, 400/422 for bounded invalid input, 401/403 for identity/scope failures, owner-safe 404 for inaccessible tasks, 409 for conflicting idempotency input and 503 for unavailable backend/storage. Errors carry stable code and request/correlation identity without raw credentials/backend secret URLs. Native errors retain useful codes but are filtered through the shared domain envelope.

REST handler composition is an explicit mount under the host's existing endpoint. Standalone Opsmaru mounts both /api/v1 and /mcp; Macus can mount the same handlers with its own authentication adapter in a later consumer integration. The native Incus /1.0 API/proxy remains separate. Shared inspection and mutation operations are the foundation primitives; development macros are later registered code with bounded steps, not caller-supplied programs.

### 3. Deduplication belongs to durable execution, not the SQL identity store

Extend the foundation's serialized task/intent commit with an idempotency receipt keyed by verified owner, configured host and operation plus a client key. Persist a canonical normalized input digest, task identity and acceptance record in that same journal commit before dispatch. Reject same-key/different-input conflict; same-key/same-input returns the original authorized result and must not resignal execution.

Reauthorize before returning a replayed result. Record an explicit retention policy: retain receipts while tasks are nonterminal or uncertain and for at least the documented reconciliation window after terminal completion. Requests outside a published expired window are new submissions; callers must use task lookup to reconcile known work rather than infer failure from a timeout. No exactly-once backend claim is made: a crash after possible Incus acceptance but before durable operation identity still yields an uncertain outcome without blind replay.

The identity database can audit the request identity but does not own a second accepted-work row requiring an atomic transaction with the journal. External Tama graphs use the key, accepted task and polling contract; Opsmaru does not choose graph branches, model calls or general retry policy.

### 4. PostgreSQL owns standalone identities and OAuth transitions

Add standalone contexts for accounts, sessions, clients, service principals, grants and token lifecycle. Use generated UUID/binary IDs, explicit migrations and database constraints/transactions for one-use authorization codes, refresh families, assertion replay and revocation. Account/session/client/grant owner bindings are not interchangeable with caller-supplied user IDs.

Initial human accounts are provisioned by an explicit owner-local administrative command using a private terminal or protected input destination. No public signup/default account/startup password exists. Password login uses an audited password hashing library with work-factor policy; browser sessions use hashed opaque identifiers and renewal. Define service principals separately from human sessions.

Store only verification hashes for opaque sessions/codes/refresh credentials. Use persisted token/grant status to support revocation of signed access tokens; signature verification alone is insufficient. Keep private signing keys in an owner-private key-provider destination or explicitly encrypted external custody, and expose only public JWKS. Database audit events store bounded IDs/actions, not credentials or full operation input. Database connection secrets are configuration, never ordinary status/log output.

Keep the task journal behind its existing host-owned storage contract. An embedding host is not forced to run Opsmaru.Repo or migrate an Opsmaru database merely to invoke compute.

### 5. Compose an authorization server from maintained OAuth primitives

Target OAuth 2.1 draft-ietf-oauth-v2-1-16 as work in progress, with finalized PKCE/resource-indicator/security/discovery RFCs where applicable. Pin the supported profile and dependency revision in acceptance artifacts. Start with authorization_code + S256 PKCE, refresh_token rotation and explicitly authorized confidential service client_credentials. No implicit, password or token passthrough grant.

Use public-client `none` and confidential `private_key_jwt` authentication with bounded assertion lifetime and persisted replay detection. The inspected parser lacks client_credentials. Target the reusable request parsing/validation extension in kritama/tama-oauth and consume its verified release or immutable revision before enabling that grant. Opsmaru implements the application grant adapter for persisted client/service-principal lookup, scope/project policy and token lifecycle; it does not fork or substitute the protocol parser. Upstream implementation/publication is a separately authorized library change, not work performed by this proposal. Its own tests must cover authentication, replay, scope/resource restrictions and a service subject distinct from human impersonation. Do not add unverified grant behavior to package claims.

Suggested routes:

| Route | Purpose |
| --- | --- |
| GET /.well-known/oauth-authorization-server | Configured issuer and supported endpoints/grants |
| GET /.well-known/oauth-protected-resource/mcp | Canonical MCP resource and issuer discovery |
| GET /.well-known/oauth-protected-resource/api/v1 | Canonical REST resource and issuer discovery |
| GET /.well-known/jwks.json | Public signing keys only |
| GET /oauth/authorize | Validated authorization request and login/consent handoff |
| POST /oauth/token | One-use code, refresh or authorized service-client exchange |
| POST /oauth/revoke | Caller-authorized credential/grant revocation |

Issuer is the explicitly advertised standalone HTTPS origin. MCP and REST have separate canonical resource identifiers, selected with an exact resource parameter and token audience. Consent grants only approved scopes for that resource. A client needs an explicit grant for each resource; no received token is forwarded to Incus. Resolve native backend credentials/socket access from private host configuration only.

Manual admin client registration is the default. Support an explicitly enabled bounded public-client registration endpoint only after rate limiting, URI validation and registration-policy tests pass; registration itself grants no compute permission. Confidential orchestration clients require administrative provisioning and key registration. Client-ID metadata retrieval/federation is deferred unless a specific client integration requires it; no arbitrary untrusted URL fetching is introduced by this initial profile.

JWT access tokens use an eligible asymmetric key provider, explicit algorithm allowlist, issuer/audience/expiry/client/subject/scope claims and active grant/token status. Access tokens are short-lived; refresh lifecycle is transactional with rotation-family replay policy. HTTP resource challenges point to public metadata as defined by the protected-resource contract. TLS, active-token checks and short-lived stream reauthorization enforce the same expiry/revocation bound as the shared foundation.

### 6. Browser UI is an authorization surface

Use the generated HTML/LiveView infrastructure for /login, validated consent and authenticated settings for sessions/grants; administrator-only client/account provisioning is separate. Preserve approved authorization parameters server-side through login and consent rather than trusting a browser-returned client/resource/scope payload. Display escaped verified client/resource/scope values and never follow an invalid redirect.

Use CSRF protection, secure HttpOnly/SameSite cookies in production, session renewal on login and authorization changes, origin checks for LiveView, bounded login attempts and non-enumerating errors. Public login pages and metadata are narrowly anonymous; compute routes still require explicit bearer authorization. Cookies do not authorize REST/MCP operations implicitly. Partition browser, OAuth form endpoints, REST JSON and MCP body handling so none consumes the other's request framing.

Consent denial produces a validated protocol error with no grant. Revocation UI operates on the current user's own grants/sessions; admin operations require a separate policy check. Do not implement a workload dashboard or make browser routes auto-mount in Macus.

### 7. Embedding retains host identity and state ownership

Expose configurable identity, key, persistence and command-context adapters. Macus mounts REST/MCP with its gateway authentication and selects its own owner identity, state and provider. Opsmaru's standalone Repo/issuer/session/UI remain disabled. OAuth browser/API handlers may be reused only through explicit host integration; the dependency never starts them by detecting an environment variable.

Preserve common policy at the operation boundary even for direct Elixir calls: host code supplies a trusted context and selected backend, not ambient root authority. A human OAuth grant and a service-client token normalize to distinct stable owner principals. Native project/host permissions remain an application-enforced allowlist before use of a privileged local Incus socket.

### 8. Scaffold delivery and verification boundaries

Keep the explicitly requested scaffold and validated proposals on `feature/phoenix-bootstrap-and-remote-access`, based on develop. The initial main/develop bootstrap contains planning history only, not a product release. Push all requested branches without merging or tagging.

Verify source formatting, warnings-as-errors compilation, asset builds, generated browser tests against isolated PostgreSQL and actual embedded startup without Repo/Endpoint. These checks do not prove OAuth, REST, task or Incus functionality. Their feature-specific conformance, transaction races, browser security and installed/live-backend checks are implementation tasks.

The current Cowboy compatibility lock resolves Cowlib 2.21.0 with a known structured-header advisory. Keep Cowboy's explicit invalid_response_headers: :error_terminate guard for HTTP/TLS listeners, fixed native protocol names and no unchecked header encoding. Record the advisory; this mitigation does not claim the transitive library is fixed. Reevaluate a patched compatible dependency before standalone security acceptance.

## Risks / Trade-offs

- An embedded library starts a database/issuer/listener -> explicit mode-aware supervision, no required production secrets in embedded mode and separate real-start tests.
- SQL identity persistence and journal execution cannot share one transaction -> execution receipts/intents stay in one journal commit; identity lifecycle is separately atomic and revalidated before dispatch.
- Protocol helpers appear to provide a full OAuth server -> application-owned transactions/consent/policy and profile-specific conformance, with the service-grant gap explicit.
- Privileged Incus access bypasses project policy -> verified subject/resource/scopes/project bindings before backend access across every transport.
- Signed tokens remain usable after revocation -> active grant/token checks and bounded stream reauthorization, rather than signature-only authorization.
- Client registration or login redirect creates an escalation path -> owner-approved policy, bounded registration and exact validated redirects with escaped consent values.
- OAuth 2.1 evolves -> pin the draft/profile and finalized RFC references, record compatibility evidence and reassess before advertising new support.
- A placeholder Phoenix page is mistaken for an authenticated console -> README/deployment status explicitly identify the scaffold and all unimplemented API/security capabilities.

## Migration Plan

There are no deployed accounts or compute tasks in this bootstrap. Apply the compute foundation first, then add explicit identity migrations and owner provisioning before exposing protected operations. Advertise only the implemented/tested grant and API profile. Keep browser/UI, issuer and Repo absent in embedded Macus.

For upgrades, preserve identity database, key custody and task journal. Run compatible migrations explicitly; a failed migration/startup does not reset users, grants or workloads. Rollback checks schema/journal compatibility and stops with recovery guidance if incompatible. No task migration, public endpoint activation, initial owner creation or OAuth key issuance occurs in this proposal request.

## Open Questions

- Deployment-selected issuer hostname, certificates, database connection and service-client registration are operational inputs.
- Exact compatible protocol/password-hashing dependency versions are locked during implementation before any supported-profile claim.

## References

- [OAuth 2.1 draft-16](https://datatracker.ietf.org/doc/html/draft-ietf-oauth-v2-1-16), work in progress.
- [OAuth Security BCP, RFC 9700](https://www.rfc-editor.org/rfc/rfc9700.html).
- [Protected Resource Metadata, RFC 9728](https://www.rfc-editor.org/rfc/rfc9728.html).
- [Authorization Server Metadata, RFC 8414](https://www.rfc-editor.org/rfc/rfc8414.html).
- [PKCE, RFC 7636](https://www.rfc-editor.org/rfc/rfc7636.html), and [Resource Indicators, RFC 8707](https://www.rfc-editor.org/rfc/rfc8707.html).
- [TamaOAuth source](https://github.com/kritama/tama-oauth), inspected local package 0.4.2 and Tama lockfile as provenance inputs.
