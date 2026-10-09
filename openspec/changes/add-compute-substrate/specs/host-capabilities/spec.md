# Spec Delta

## Purpose

Describes the execution host and its available operations consistently while allowing macOS runtime and filesystem integration to remain specific to Macus.

## ADDED Requirements

### Requirement: One execution host per endpoint

An endpoint SHALL bind to one explicitly configured execution host/backend identity. It MUST NOT interpret an arbitrary request address as another managed host. Native project and cluster-member targeting SHALL remain subject to configured backend permissions.

#### Scenario: Unregistered host selection

- **WHEN** a caller supplies a host address outside the configured execution host
- **THEN** the service rejects the selection without connecting to that address

### Requirement: Explicit capability reporting

Capability reporting SHALL distinguish available shared client functions, live Incus extensions, backend readiness and registered host features. Unsupported or unobserved capabilities MUST NOT be reported as available.

#### Scenario: No Macus provider

- **WHEN** the Linux service has no outer-runtime provider
- **THEN** it reports no Macus runtime lifecycle capability while supported native Incus functions remain available

### Requirement: Host provider delegation

Host-specific operations SHALL delegate to explicitly registered host adapters. Shared code MUST NOT implement Apple virtualization, invoke another host VM runtime or assume that every host owns an outer VM.

#### Scenario: Macus runtime request

- **WHEN** an authorized Macus runtime tool requests lifecycle work
- **THEN** Macus's adapter uses the existing Swift runtime and Opsmaru does not become its VM owner

### Requirement: Filesystem locality contract

Host path resolution SHALL identify the execution-host directory and its authorized scope. Client-local paths MUST NOT be treated as remotely mountable paths. The host SHALL report required sharing or configuration steps before attachment is claimed ready.

#### Scenario: Macus share change required

- **WHEN** a selected Mac directory is not already available to the Incus guest and sharing requires a stopped-runtime configuration change
- **THEN** the adapter reports the prerequisite without implicitly restarting the runtime or claiming the directory is attached

### Requirement: Capability contract without workflow activation

Registering a provider or inspecting capabilities MUST NOT provision workspaces, install skills, build images, activate services or modify host sharing. Higher-level development workflows SHALL require separately specified operations.

#### Scenario: Provider inspection

- **WHEN** an agent inspects the host's capabilities
- **THEN** inspection returns available capabilities without creating task containers or changing host files
