# Tasks

Proposal only. The feature branch contains the explicitly requested Phoenix bootstrap, not the functionality below. Apply the shared `add-compute-substrate` foundation before completing dependent operation/task integration. No OAuth credentials, user database migrations, live Incus work or remote service activation are performed by proposing this change.

## 1. Shared application operation boundary

- [ ] 1.1 Introduce registered domain operation descriptors and validation/policy/result envelopes over foundation services; verify MCP and direct Elixir calls share schemas, permissions and trusted owner/host bindings without duplicate compute behavior.
- [ ] 1.2 Define stable operation/task result and error schemas plus documented API versioning; verify accepted/completed/uncertain outcomes and native error filtering remain distinguishable and contain no backend secrets.
- [ ] 1.3 Document the transport-neutral operation API and future macro registration contract; verify no caller-supplied workflow language, arbitrary module or host command can enter the registry.

## 2. Optional identity persistence and provisioning

- [ ] 2.1 Add explicit PostgreSQL migrations for users, sessions, clients, service principals, grants, codes, refresh families, active-token status, assertion replay and bounded audit; verify isolated migrations, constraints and embedded startup without Repo or database secrets.
- [ ] 2.2 Implement owner-local initial account and subsequent admin provisioning with private inputs and password hashing policy; verify no default account/public signup/startup credential creation and bounded non-enumerating login errors.
- [ ] 2.3 Implement atomic one-use code, refresh rotation/replay and revocation transitions; verify competing requests yield one valid transition and appropriate family invalidation without leaked raw credentials.
- [ ] 2.4 Implement key-provider custody, verification-hash storage, active-token/grant checks and filtered audit; verify public JWKS excludes private material and database/status/log fixtures contain no passwords/codes/refresh/bearer tokens.
- [ ] 2.5 Document migration/backup/restore/rollback and host-supplied persistence; verify an incompatible schema rollback preserves data and an embedded consumer needs no standalone identity database.

## 3. Self-hosted OAuth protocol and resource authorization

- [ ] 3.1 Pin the designated kritama/tama-oauth (`:tama_oauth`) dependency and supported OAuth 2.1 draft/RFC profile; verify code/refresh/PKCE/metadata/client-auth primitives and record the client_credentials parser gap without unsupported grant advertisement.
- [ ] 3.2 Implement issuer/resource metadata, public JWKS and authentication challenges for MCP and REST; verify exact public identities, supported endpoints/scopes and no private backend address exposure.
- [ ] 3.3 Implement registered-client authorization-code/S256 request validation and one-use redemption; verify exact redirect/resource/client/consent binding, bad verifier, expired/reused code, mix-up inputs and exclusion of implicit/password grants.
- [ ] 3.4 Implement refresh exchange, asymmetric access tokens and revocation using transactional state; verify issuer/audience/expiry/scopes/client/subject agreement, rotation races, family replay and active-status checks.
- [ ] 3.5 Coordinate the reusable client_credentials protocol extension in kritama/tama-oauth under a separate authorized change, consume its verified revision and implement only Opsmaru's persisted service-client grant/policy adapter; verify private_key_jwt replay, allowed host/project/resource/scopes and absence of caller-selected human impersonation before advertising client_credentials.
- [ ] 3.6 Implement admin client registration and explicit optional bounded public registration policy; verify redirect/method/scope limits, rate limits and registration never grants service-client or compute privileges automatically.
- [ ] 3.7 Document the exact protocol profile and remote-agent/service-client setup; run positive/negative conformance fixtures against registered issuers/resources and verify incomplete grant support remains absent from metadata.

## 4. Browser login, consent and administration

- [ ] 4.1 Add provisioned-account login/logout/session renewal with secure production cookies, CSRF and login-attempt bounds; verify session fixation, account enumeration, expired/revoked session and LiveView origin defenses.
- [ ] 4.2 Add validated authorization-request handoff and consent views displaying escaped client/resource/scopes; verify modified browser parameters cannot widen the grant and denial creates no credential or unsafe redirect.
- [ ] 4.3 Add owner-bound grant/session inspection and revocation plus admin-only client/account management; verify cross-owner and non-admin access is denied without changing policy.
- [ ] 4.4 Separate browser/session, OAuth form, REST JSON and MCP body/auth pipelines; verify browser cookies cannot authorize compute routes and one transport cannot consume another's request body.
- [ ] 4.5 Document the minimal UI and first-owner flow; verify browser-to-code-to-token acceptance with isolated users/clients while embedded mode mounts none of the standalone UI automatically.

## 5. REST operations and durable request reconciliation

- [ ] 5.1 Mount versioned discovery/submission routes over the shared operation boundary with verified resource credentials; verify schema/policy equivalence with MCP, filtered discovery and denial before backend access.
- [ ] 5.2 Extend the foundation task journal to atomically persist owner/host/operation-bound idempotency receipt, canonical input digest and execution intent; verify duplicate submission returns the same task, changed input conflicts and crash boundaries cause no second mutation.
- [ ] 5.3 Implement durable accepted responses, Location/polling and owner-bound result/cancel routes; verify disconnect reconciliation, retained uncertain outcomes and cancellation intent versus observed backend completion.
- [ ] 5.4 Implement documented receipt retention and reauthorization on replay; verify nonterminal/uncertain work retains receipts and expired/wrong-owner/revoked credentials cannot retrieve a stored result.
- [ ] 5.5 Add structured correlation/error handling and API schema exports; verify errors preserve useful codes without tokens/private addresses and an external graph fixture submits/polls using stable identity instead of blindly retrying.
- [ ] 5.6 Document the external opsmaru-tama client contract and bounded macro boundary; verify the API introduces no reasoning engine, host scheduler or source/workspace workflow implementation.

## 6. Embedded consumer and remote service integration

- [ ] 6.1 Expose shared HTTP handler composition with host identity/persistence adapters; verify an external Macus-like consumer mounts REST/MCP on its existing endpoint without starting Opsmaru Endpoint/Repo/issuer or requiring DATABASE_URL.
- [ ] 6.2 Configure standalone HTTPS/issuer/database/key preflight and current subject/project policy; verify wrong-resource tokens and unauthorized native project selection fail before privileged backend access.
- [ ] 6.3 Integrate revocation/expiry with REST/MCP task access and long-lived delivery; verify active-token checks and stream invalidation preserve existing task/backend state rather than claiming work was undone.
- [ ] 6.4 Reevaluate the locked Cowboy/Cowlib advisory and compatible fixes before standalone security acceptance; verify the explicit response-header guard and header-injection regression, recording any remaining library advisory separately from the mitigation.
- [ ] 6.5 Update release/service/deployment docs for explicit migrations, private key/database configuration and account provisioning; verify passive installation cannot initialize credentials, migrate automatically or open a public listener.

## 7. Integrated and installed acceptance

- [ ] 7.1 Run canonical scaffold/core checks, protocol/browser/API tests and SQL race fixtures; verify reports distinguish generated baseline checks from implemented OAuth/REST/Incus acceptance.
- [ ] 7.2 With explicit standalone opt-in, prove installed browser login/consent, MCP/REST resource grants, confidential client flow and revocation using isolated state/database/project; preserve data and diagnostics on failure.
- [ ] 7.3 With explicit restart/upgrade opt-in, prove same idempotency task and owner identity survive process recovery and compatible migration; reject incompatible rollback without resetting identity or execution stores.
- [ ] 7.4 With explicit remote-client opt-in, verify advertised HTTPS/issuer/resource discovery from another client and denied cross-resource/cross-owner calls; leave unavailable remote/hardware gates incomplete and keep Macus consumer acceptance separately owned.
