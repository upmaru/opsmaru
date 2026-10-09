# Spec Delta

## Purpose

Provides durable account and authorization state for standalone deployments while keeping embedded compute independent of a dependency-owned database.

## ADDED Requirements

### Requirement: Standalone identity database

Standalone authorization SHALL persist account, session, registered-client, grant, code, token-family, replay and revocation state transactionally. Embedded mode SHALL not start its own repository or require database credentials unless persistence is explicitly selected by the host.

#### Scenario: Embedded startup without database

- **WHEN** a host starts the shared dependency without database configuration
- **THEN** no dependency repository starts and the host can supply its own identity and execution storage

### Requirement: Controlled owner bootstrap

The first owner SHALL be created by an explicit local administrative action. Public account signup and startup-generated default credentials MUST NOT exist. Subsequent accounts and service principals SHALL require authorized administrative provisioning.

#### Scenario: Empty account database

- **WHEN** an uninitialized standalone installation starts
- **THEN** it reports that owner setup is required without creating an account or accepting an anonymous compute caller

### Requirement: Atomic credential lifecycle

Code consumption, refresh rotation, replay rejection and revocation SHALL use atomic transitions and database constraints. Concurrent requests MUST NOT reuse a one-use credential or create multiple successful descendants from one refresh credential.

#### Scenario: Concurrent refresh

- **WHEN** two requests concurrently attempt to rotate the same refresh credential
- **THEN** at most one succeeds and the replay policy records the other attempt without creating another active descendant

### Requirement: Secret protection and bounded audit

Passwords and opaque credentials SHALL use appropriate one-way verification storage. Private signing keys SHALL remain outside ordinary database output or be protected with explicit key custody. Audit records SHALL be bounded metadata without raw credentials, operation secrets or arbitrary request bodies.

#### Scenario: Authorization audit

- **WHEN** a grant or token lifecycle event is recorded
- **THEN** its audit identifies actor/client/resource/action without storing the raw code, refresh token, password or bearer token

### Requirement: Explicit migrations and state preservation

Database initialization/migrations SHALL be explicit deployment actions, not dependency startup side effects. Upgrade and rollback SHALL preserve identity and task state and reject incompatible schema versions instead of silently resetting or truncating data.

#### Scenario: Incompatible rollback

- **WHEN** an older release cannot read the current authorization schema
- **THEN** startup reports the incompatibility and leaves stored credentials, grants and task data intact
