# Spec Delta

## Purpose

Authenticates external human and service callers against a configured OIDC/OAuth provider while enforcing resource-specific compute access and host-owned embedding.

## ADDED Requirements

### Requirement: Configurable external issuer

Standalone deployments SHALL trust one explicitly configured external issuer and approved endpoint/client profile. Discovery SHALL verify exact issuer agreement and use trusted bounded HTTPS transport in production. The service MUST NOT select providers from request/token URLs or fall back to a local issuer.

#### Scenario: Unknown issuer

- **WHEN** a token names an issuer other than the configured provider
- **THEN** access is denied without fetching that issuer or opening the Incus backend

#### Scenario: Missing provider configuration

- **WHEN** standalone activation lacks required issuer/resource configuration
- **THEN** activation fails without generating local tokens or enabling anonymous compute access

### Requirement: Resource-bound access token validation

MCP and REST SHALL verify external access-token signature, algorithm, issuer, resource audience, times, subject, approved client and scopes before backend access. Audience membership SHALL support the verified provider profile. ID tokens MUST NOT authorize APIs; one resource credential MUST NOT authorize another absent an explicit grant.

#### Scenario: Wrong resource audience

- **WHEN** an MCP-only token is presented to the separately identified REST resource
- **THEN** access is denied before backend access

#### Scenario: ID token presented as bearer

- **WHEN** a caller presents its browser ID token to a compute API
- **THEN** the token is rejected as an API credential

### Requirement: Active token and current local policy checks

Protected requests SHALL require active provider introspection and current local authorization. Positive activity caches SHALL expire within 30 seconds and no later than token expiry. A provider failure after that bound SHALL deny access. Affected streams SHALL reauthorize within the same bound; revocation MUST NOT claim to undo accepted backend work.

#### Scenario: Provider unavailable after cached activity expires

- **WHEN** activity can no longer be established within the configured bound
- **THEN** new access and stream delivery fail while committed task and Incus data remain preserved

#### Scenario: Token revoked

- **WHEN** the configured provider marks a previously accepted token inactive
- **THEN** new calls and affected streams reject it within the documented end-to-end bound

### Requirement: Protected resource discovery

Opsmaru SHALL publish protected-resource metadata and challenges naming its canonical MCP/REST resources and configured external authorization server. Issuer metadata, signing keys, consent, client registration and token issuance SHALL remain provider-owned. Only verified methods and scopes SHALL be advertised.

#### Scenario: Remote MCP authentication challenge

- **WHEN** an agent receives an authentication challenge
- **THEN** it discovers the configured external server through resource metadata without requiring an Opsmaru token endpoint

### Requirement: Human and service principal separation

Provider-issued human and service tokens SHALL map to stable exact issuer/subject bindings and approved client identities. Effective permissions SHALL intersect token authority with local host/project/scope grants. Caller-supplied owners and provider usernames MUST NOT manufacture another principal or administrator authority.

#### Scenario: Service client names a human owner

- **WHEN** an authorized orchestration service submits a human owner field
- **THEN** execution remains bound to its registered service principal or fails without impersonation

### Requirement: Provider-independent verified profile

Provider support SHALL be gated by tested claim, introspection, discovery, resource and flow interoperability through the designated protocol libraries. Missing reusable protocol support SHALL be resolved upstream before advertisement; unverified default claims or fabricated identity/grant fields MUST NOT establish compatibility.

#### Scenario: Keycloak claim mismatch

- **WHEN** the pinned library cannot safely validate the configured Keycloak token/introspection profile
- **THEN** integration remains unsupported until a valid tested profile or verified upstream update resolves it

### Requirement: Host-owned authentication when embedded

Embedded handlers SHALL accept host-verified identity through configured adapters without requiring provider discovery/credentials, Opsmaru browser sessions, an endpoint or database. Shared scope and owner checks SHALL remain enforced.

#### Scenario: Macus authenticates an embedded call

- **WHEN** Macus supplies its verified principal and scopes
- **THEN** shared handlers use that context without another login, issuer or standalone provider process

### Requirement: Incus authentication boundary

Compute access SHALL enforce Opsmaru policy before privileged Incus transport. Presented resource tokens MUST NOT be forwarded as backend credentials. A separately configured Incus OIDC provider SHALL not substitute for authentication of Opsmaru endpoints.

#### Scenario: Local Incus socket is privileged

- **WHEN** an ungranted provider user calls an Opsmaru mutation backed by the local socket
- **THEN** Opsmaru rejects the operation without relying on socket-level user authorization
