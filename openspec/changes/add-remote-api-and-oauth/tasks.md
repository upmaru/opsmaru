# Tasks

Proposal only. The existing Phoenix scaffold does not implement these features. Apply the shared compute foundation before dependent execution integration. This revision performs no provider startup, credential provisioning, migrations, remote activation or real Incus work. External-provider operations remain at the issuer; any reusable protocol-library extension requires its own authorized upstream change.

## 1. Shared application operation boundary

- [ ] 1.1 Introduce registered operation descriptors, validation/policy/result envelopes over compute-substrate services; verify MCP/direct calls share schemas, permissions and trusted owner/host bindings.
- [ ] 1.2 Define versioned operation/task outcomes and bounded errors; verify accepted/completed/uncertain results remain distinct and backend secrets are filtered.
- [ ] 1.3 Document transport-neutral invocation and future bounded macros; verify arbitrary workflow/module/host commands cannot enter the registry.

## 2. External identity bindings and local persistence

- [ ] 2.1 Add explicit PostgreSQL migrations for exact issuer/subject/kind/client bindings, target/project grants, device/public-key bindings, sessions, policy versions and audit; verify isolated constraints and no local passwords/code/refresh/signing-key tables or mandatory embedded Repo.
- [ ] 2.2 Implement owner-local first central-admin external-subject binding and authorized subsequent grants; verify no provider account creation, default admin, email ownership or automatic privilege on login.
- [ ] 2.3 Implement atomic grant/disable/session transitions and cache invalidation; verify concurrent changes enforce current local policy and preserve task ownership across token refresh/restart.
- [ ] 2.4 Protect provider credentials, hash session IDs and filter audit; verify raw API tokens never enter SQL/task stores or ordinary logs/status and document private credential references.
- [ ] 2.5 Document migrations, backups, rollback and explicit issuer/subject migration; verify incompatible rollback preserves state and replacement-email identities cannot inherit historical tasks.

## 3. Provider configuration and protocol compatibility

- [ ] 3.1 Pin designated TamaOAuth/TamaMCP dependencies and inventory external OIDC/resource primitives; compare captured Keycloak JWT/introspection claims with audience/client/grant_id requirements and record verified compatibility gaps.
- [ ] 3.2 Implement explicit single-issuer/resource/client/claim configuration and trusted bounded discovery; verify issuer mismatch, unsafe token-selected URLs, redirects, TLS failure and invalid activation cause denial without local issuer fallback.
- [ ] 3.3 Resolve reusable provider-token/introspection/OIDC/client-auth gaps through separately authorized kritama/tama-oauth work and consume its verified revision; verify audience arrays/client mappings work without synthetic identity claims or a duplicate verifier.
- [ ] 3.4 Implement protected-resource metadata/challenges referencing the external issuer; verify no Opsmaru OAuth token/authorization/client-registration/token-revocation/JWKS service and advertise only the tested resource/client profile.
- [ ] 3.5 Implement JWT/JWKS plus active introspection, bounded caches/key rotation and current policy checks; verify wrong issuer/audience/algorithm/client/subject/scopes, ID-token misuse, unknown keys, inactive tokens and outages deny before backend access.
- [ ] 3.6 Implement exact human/service owner normalization and permission intersection; verify provider client_credentials subjects cannot impersonate users or forge host/project grants and document direct provider token acquisition.
- [ ] 3.7 Document registered MCP/REST agent setup, resource indicators, provider scopes/audiences and revocation semantics; verify a real client acquires a correctly bound token rather than inferring interoperability from OIDC discovery.

## 4. Central target and enrollment HTTP integration

- [ ] 4.1 Mount permission-filtered target inventory and administrative direct-HTTPS registration over compute-substrate registry contracts; verify overlapping target resource names, explicit target selection, protected credential references and no caller URL override or automatic target privileges.
- [ ] 4.2 Mount short-lived one-use key-bound device enrollment/completion/receipt routes with user scope and central policy; verify wrong key/service/user, expiry/replay and lost completion response cannot create another target or widen permissions.
- [ ] 4.3 Publish trusted enrollment CLI client/flow configuration and integrate designated OAuth Device Authorization Grant primitives for Keycloak; verify browser approval, polling limits/deadline, denied/expired grant and no persisted user refresh/API tokens or unsupported-provider fallback.
- [ ] 4.4 Integrate authenticated connector ingress and target/device revocation with compute-substrate session epochs and dispatch receipts; verify device certificates cannot call user APIs, user tokens cannot create a device session and revoked/stale generations cease dispatch/stream delivery within 30 seconds.
- [ ] 4.5 Integrate central SQL task acceptance and per-target routing for REST/MCP/Tama clients; verify one atomic outbox/idempotency commit, local receipt linkage and cross-target/cross-owner/reconnect failures without duplicate execution.
- [ ] 4.6 Document/test central registration UI/API, direct Incus mTLS and optional connector enrollment with Keycloak plus multiple isolated target fixtures; verify targets need no full Phoenix install and local Macus/connector roles require no central SQL/provider startup.
## 5. Browser relying party and local administration

- [ ] 5.1 Implement external S256/state/nonce login and code callback through verified protocol primitives; verify one-use transaction, ID token, issuer mix-up, callback/return target and expired/bad-verifier rejection without local credential entry or consent.
- [ ] 5.2 Implement hashed local sessions, secure cookies, CSRF/origin defenses, local logout and provider-round-trip renewal; verify fixation/revocation and the 15-minute/token-expiry lifetime cap with no persisted upstream refresh tokens.
- [ ] 5.3 Add own identity/session/permitted-target views and admin-only target/device/grant administration; verify cross-owner/non-admin denial and no provider account/client lifecycle operations.
- [ ] 5.4 Separate browser, callback, REST and MCP pipelines; verify cookies cannot authorize compute routes, callback secrets are absent from logs/output and browser handlers preserve MCP framing.
- [ ] 5.5 Document external sign-in, first-admin binding and local versus provider logout; verify browser acceptance in isolated state and no automatic browser/provider startup when embedded.

## 6. REST operations and durable reconciliation

- [ ] 6.1 Mount versioned manifest/submission routes over the shared boundary with verified resource credentials; verify MCP-equivalent schemas/policy, filtered discovery and backend-free denial.
- [ ] 6.2 Use the compute-substrate central SQL transaction for owner/target/generation/operation-bound idempotency, canonical input digests, task intent and dispatch outbox; verify duplicate acceptance returns one task, changed input conflicts and crash boundaries cannot replay a mutation.
- [ ] 6.3 Implement accepted responses, polling/results and cancellation; verify owner-safe lookup, disconnect reconciliation, uncertainty and cancellation intent versus observed backend completion.
- [ ] 6.4 Implement receipt retention and fresh access/local policy checks for replay and delayed dispatch; verify expired/inactive/ungranted users cannot retrieve results, accepted work contains no bearer token and revoked access is not reported as undone work.
- [ ] 6.5 Export schemas/correlation/errors and document the opsmaru-tama submission/polling contract; verify an external graph fixture reconciles known work without blind retry or an embedded reasoning engine.

## 7. Embedded and standalone integration

- [ ] 7.1 Expose handler composition with host identity/persistence adapters; verify a Macus-like consumer mounts REST/MCP without Opsmaru Endpoint/Repo/provider credentials/discovery or another auth surface.
- [ ] 7.2 Add central HTTPS/database/provider/resource/registry preflight and current target/project policy without a mandatory local backend; verify invalid activation/outage behavior and no API bearer forwarding to Incus.
- [ ] 7.3 Integrate token activity/expiry and local disable with task access/streams; verify the 30-second maximum cache/reauthorization bound, local policy invalidation and preserved accepted tasks during provider failure.
- [ ] 7.4 Reevaluate locked Cowboy/Cowlib advisories before security acceptance; verify response-header guard/injection regression and record any remaining advisory independently of the mitigation.
- [ ] 7.5 Document release/service/provider setup and explicit local policy migrations; verify passive installation starts no issuer/provider, grants no privileges and opens no listener.

## 8. Keycloak and installed acceptance

- [ ] 8.1 Add isolated reproducible Keycloak realm/client/scope/audience fixtures with official image version/digest and explicit lifecycle; verify clean setup/teardown, private excluded state/secrets and no dependency on a production realm or default provider service.
- [ ] 8.2 Run Keycloak browser S256 login, human MCP/REST tokens and Tama client_credentials acceptance with registered clients; verify resource indicators, exact subjects/client mappings, introspection agreement and locally bounded grants with recorded provider/dependency provenance.
- [ ] 8.3 Run negative/provider-lifecycle integration including issuer/audience/client/ID-token misuse, disabled/ungranted users, cross-owner tasks, key rotation, actual revocation, expiry and outage; verify documented cache/stream bounds without claiming untested provider logout behavior.
- [ ] 8.4 Run canonical strict spec/core/protocol/browser/SQL checks; verify reports distinguish scaffold, fixtures and Keycloak integration from installed/live-Incus acceptance.
- [ ] 8.5 With explicit standalone/restart/remote opt-in, prove installed external sign-in, authorized API/MCP access, same-owner/target/generation idempotency recovery and compatible upgrades using isolated database/state/project; preserve data and leave unavailable Linux/remote/Macus hardware gates incomplete.
