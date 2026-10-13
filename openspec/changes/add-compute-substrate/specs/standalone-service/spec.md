# Spec Delta

## Purpose

Delivers a central authenticated gateway for registered compute targets and an optional listener-free Linux connector without requiring a full server beside each Incus cluster.

## ADDED Requirements

### Requirement: Central authenticated endpoint

Standalone central mode SHALL expose MCP and shared REST over explicitly configured HTTPS with external user authentication. Default binding SHALL be loopback. An empty registry SHALL be valid; local Incus installation MUST NOT be required. Invalid configuration SHALL not fall back to anonymous or cleartext access.

#### Scenario: Empty central registry

- **WHEN** a configured central installation has no targets yet
- **THEN** it serves authorized registration/status without creating or requiring a local Incus backend

### Requirement: Direct Incus HTTPS access

Registered reachable targets SHALL use native Incus HTTPS with verified server identity and protected trusted client certificate/private key. Central authorization SHALL precede access. A full Opsmaru deployment or user OIDC token forwarding MUST NOT be required at the target.

#### Scenario: Direct remote cluster

- **WHEN** an approved reachable cluster is registered
- **THEN** central shared operations use its authenticated API without installing a connector or Phoenix server there

### Requirement: Optional Linux connector role

Connector-only Linux SHALL initiate outbound sessions and use one configured local Unix/private HTTPS backend. It SHALL start no inbound listener, MCP endpoint, repository or identity UI and require no central database/issuer credentials. Backend privileges SHALL be explicitly provisioned.

#### Scenario: Private cluster

- **WHEN** a private Linux installation starts its explicitly enrolled connector
- **THEN** central can dispatch permitted operations through the outbound session without inbound ports or a local full server

### Requirement: External users and device trust

Central user authentication SHALL use the configured external issuer plus local target permissions. Native backend credentials and enrolled device identity SHALL remain separate. Ordinary inspection MUST NOT issue credentials, enroll devices or activate services.

#### Scenario: Ungrantable provider identity

- **WHEN** a valid provider user lacks target permission
- **THEN** compute access is denied before opening that target transport

### Requirement: Target failure isolation

The service SHALL distinguish central availability, connector reachability and per-target backend readiness. One unavailable target MUST NOT prevent operations on other permitted targets. Disconnection SHALL preserve accepted work and report uncertainty where appropriate.

#### Scenario: One backend stopped

- **WHEN** one registered Incus target becomes unavailable
- **THEN** other targets remain usable and the failed target reports unavailable without automatic runtime creation

### Requirement: Self-contained platform releases

Central and connector-only Linux artifacts SHALL identify immutable application/dependency/reference provenance and include the required Erlang runtime. Advertised architecture/ABI support SHALL be explicit. Installed roles MUST NOT require host Elixir/Erlang or a source checkout.

#### Scenario: Clean connector installation

- **WHEN** a matching connector-only artifact starts on Linux without Elixir/Erlang or PostgreSQL
- **THEN** its bundled runtime supports outbound execution without activating a central endpoint

### Requirement: Passive installation and state preservation

Installation SHALL remain passive; enrollment and service activation SHALL be explicit. Restart/upgrade/removal SHALL preserve central registry/tasks, local receipts/credentials and Incus data. Installation MUST NOT install Incus, alter firewalls or grant backend access implicitly.

#### Scenario: Package installed

- **WHEN** an operator installs either Linux role
- **THEN** no listener/session starts and target/credential/workload state is not created implicitly

### Requirement: Independent acceptance evidence

Checks SHALL distinguish shared-library embedding, multi-target/direct/connector fixtures, installed Linux roles, real remote Incus and Macus hardware acceptance. Fixture/package success MUST NOT establish live-host completion.

#### Scenario: Fixture-only central success

- **WHEN** multiple fake targets and connector fixtures pass
- **THEN** protocol evidence is recorded while installed/live Linux and Macus gates remain incomplete
