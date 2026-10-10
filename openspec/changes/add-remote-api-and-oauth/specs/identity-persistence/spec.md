# Spec Delta

## Purpose

Persists external subject bindings, local compute grants and browser sessions without creating a local identity provider or requiring a database for embedded compute.

## ADDED Requirements

### Requirement: Standalone local authorization database

Standalone mode SHALL persist exact issuer/subject bindings, principal kind, service-client bindings, local grants, sessions and bounded audit. Provider accounts, passwords, signing keys and authorization-code/refresh families MUST NOT be managed locally. Embedded mode SHALL not require its own repository unless the host explicitly selects it.

#### Scenario: Embedded startup without database

- **WHEN** a host starts the dependency without database configuration
- **THEN** it starts no dependency repository and can supply its own identity/persistence adapters

### Requirement: Controlled local administrator bootstrap

The first local administrator SHALL be bound to an existing exact external issuer/subject by an explicit owner-local action. Provider authentication alone MUST NOT create compute/admin grants. Additional bindings SHALL require authorized administration; no default account or public signup SHALL exist.

#### Scenario: Authenticated ungranted user

- **WHEN** a valid provider user has no local grant
- **THEN** compute access is denied without automatic account privilege or administrator creation

### Requirement: Stable ownership and explicit identity migration

Task and grant ownership SHALL use stable issuer/subject identity, independent of email, display name and token refresh. Changing issuer or subject SHALL require explicit audited rebinding to transfer authority; a matching email MUST NOT inherit historical ownership.

#### Scenario: Same email at replacement issuer

- **WHEN** a user authenticates through a replacement issuer with an old owner's email
- **THEN** it receives no historical task/grant access without an authorized identity migration

### Requirement: Atomic local permission and session transitions

Local grant changes, subject disable and session revocation SHALL use atomic persisted transitions. Current policy SHALL be enforced on new calls, replayed results and delayed dispatch; stale caches MUST NOT retain local revoked authority.

#### Scenario: Local subject disabled

- **WHEN** an administrator disables a subject whose external token remains active
- **THEN** its new requests and affected delivery are denied by local policy without deleting accepted tasks

### Requirement: Secret protection and bounded audit

Local session identifiers SHALL use one-way verification storage. Provider client credentials SHALL remain in protected configuration; raw API tokens MUST NOT enter the identity/task stores. Audit SHALL contain bounded actor/client/action/resource metadata without passwords, codes, tokens or arbitrary request bodies.

#### Scenario: Authentication audit

- **WHEN** login or compute authorization is audited
- **THEN** the audit excludes raw bearer tokens, callback codes and provider client secrets

### Requirement: Explicit migrations and state preservation

Initialization/migrations SHALL be explicit deployment actions. Upgrade and rollback SHALL preserve local policy and task state and reject incompatible schemas without resetting data. Provider configuration changes MUST NOT silently reassign ownership.

#### Scenario: Incompatible rollback

- **WHEN** an older release cannot read the current local authorization schema
- **THEN** it reports incompatibility and leaves grants, sessions and task data intact
