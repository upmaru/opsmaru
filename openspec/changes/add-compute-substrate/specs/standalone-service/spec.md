# Spec Delta

## Purpose

Allows Linux operators to install and explicitly activate the same compute application as an independent authenticated Phoenix service beside their existing Incus installation.

## ADDED Requirements

### Requirement: Explicit authenticated Linux endpoint

Standalone Linux mode SHALL expose MCP at /mcp through explicitly configured HTTPS. Binding SHALL default to loopback; remote exposure SHALL require a configured bind address and matching advertised identity. Missing or invalid authentication SHALL fail before backend access.

#### Scenario: Unauthorized request

- **WHEN** an anonymous or invalid-credential caller requests tool discovery or execution
- **THEN** the server denies access without opening the privileged Incus connection

### Requirement: Standalone host configuration

The service SHALL use operator-selected Incus transport, private state and host identity. It SHALL distinguish service availability from backend readiness. It MUST NOT install Incus, create an outer VM or modify networking/firewall configuration implicitly.

#### Scenario: Incus unavailable

- **WHEN** the configured Incus backend is stopped
- **THEN** authenticated service status remains available and compute requests report backend unavailability without starting another runtime

### Requirement: Owner-local credential administration

Operators SHALL explicitly initialize, issue and revoke scoped bearer credentials using private local administration. Keys, verifiers and task state SHALL be owner-private and excluded from packages, normal output and logs. Ordinary inspection MUST NOT create credentials or activate services.

#### Scenario: Revoked credential

- **WHEN** an operator revokes a credential
- **THEN** new requests fail and affected streams close within the documented revocation bound

### Requirement: Self-contained platform release

Standalone artifacts SHALL include the application and Erlang runtime and identify immutable application, dependency and backend-reference provenance. Supported target architecture and ABI SHALL be explicit. Installed releases MUST NOT require host Elixir/Erlang or a source checkout.

#### Scenario: Clean Linux installation

- **WHEN** a matching supported Linux release is installed on a host without Elixir or Erlang
- **THEN** the service starts with its bundled runtime after explicit configuration and activation

### Requirement: Passive installation and explicit service activation

Installation SHALL remain passive. Explicit service activation SHALL run the release in the foreground under the selected service manager. Shutdown, restart, upgrade and uninstall MUST preserve Incus workloads, credentials and task state unless a distinct authorized cleanup is requested.

#### Scenario: Package installed

- **WHEN** an operator installs the standalone artifact
- **THEN** no listener starts, no Incus data changes and credentials are not generated implicitly

### Requirement: Independent embedded and Linux acceptance

Checks SHALL separately verify library embedding, standalone fixtures, release contents and real Linux Incus behavior. Macus hardware acceptance SHALL remain consumer-owned. Fixture or package success MUST NOT establish real-host acceptance.

#### Scenario: Package smoke test only

- **WHEN** a Linux release smoke test passes against a fake backend
- **THEN** package evidence is recorded while live Linux and Macus hardware acceptance remain incomplete
