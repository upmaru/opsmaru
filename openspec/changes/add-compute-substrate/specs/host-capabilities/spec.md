# Spec Delta

## Purpose

Registers and authorizes multiple compute targets, their connection identities and capabilities while retaining execution-host runtime and filesystem ownership.

## ADDED Requirements

### Requirement: Registered target selection

The central endpoint SHALL manage multiple registered Incus servers/clusters and Macus targets using stable target IDs. Targeted mutations SHALL require explicit target selection. Caller addresses MUST NOT select or replace backends. Native project/member selection SHALL remain within the authorized target.

#### Scenario: Overlapping instance names

- **WHEN** two registered targets contain an instance with the same name
- **THEN** an explicitly selected permitted target receives the operation and the other target remains unchanged

#### Scenario: Unregistered target

- **WHEN** a caller supplies an unknown target or backend URL
- **THEN** selection fails without connecting to that address

### Requirement: Authorized registration and generation

Registration SHALL require approved administration/enrollment and bind verified backend/device identity, permitted projects/capabilities and a stable generation. Replacement or re-enrollment MUST NOT silently transfer old task authority. Registration SHALL not create workloads, shares, images or provider accounts.

#### Scenario: Replacement device

- **WHEN** a new device enrolls against a previously used target identity
- **THEN** old tasks/receipts retain their generation and cannot execute on the replacement implicitly

### Requirement: Explicit capability reporting

Per-target discovery SHALL distinguish shared implementation coverage, observed backend extensions, connector protocol compatibility, reachability and host features. Only permitted targets SHALL be visible. Direct Incus targets MUST NOT advertise Macus lifecycle or host-file access without an authorized adapter.

#### Scenario: Incus-only target

- **WHEN** a reachable Linux cluster has no host runtime adapter
- **THEN** native capabilities are visible but Macus outer-runtime operations are unavailable

### Requirement: Outbound connector identity

Connectors SHALL initiate authenticated outbound sessions to the configured central service using enrolled device identity. Enrollment SHALL verify one-use challenge and private-key possession. Wrong target/generation, expired/replayed enrollment and revoked device sessions MUST NOT authorize dispatch.

#### Scenario: Enrollment replay

- **WHEN** a device reuses a consumed enrollment challenge
- **THEN** registration fails without another grant or backend contact

#### Scenario: Wrong registration

- **WHEN** an authenticated connector submits another target ID
- **THEN** its session cannot control that target

### Requirement: Bounded connector dispatch

Connected execution SHALL accept only known compatible operation descriptors, verified central context and locally approved project/tool limits. Arbitrary destinations, host commands and serialized code MUST NOT be accepted. Duplicate dispatch IDs SHALL reconcile durable receipts before further execution.

#### Scenario: Unauthorized host command

- **WHEN** central dispatch names an unregistered host command or unapproved project
- **THEN** the connector rejects it before any host/backend execution

### Requirement: Connector availability and stream bounds

Reconnect SHALL use bounded backoff and reconcile accepted work. Session replacement SHALL fence stale sessions. Buffers, streams and control queues SHALL be bounded; disconnection MUST NOT imply mutation failure or cancellation. Native operation-specific streaming semantics SHALL be independently verified.

#### Scenario: Lost connection after acceptance

- **WHEN** the connector loses its session after backend acceptance
- **THEN** reconnect queries the committed receipt/native operation instead of issuing another mutation

### Requirement: Host provider delegation

Host-specific operations SHALL delegate to explicitly registered adapters on the selected target. Shared code MUST NOT implement Apple virtualization, invoke another host VM runtime or assume an outer VM exists. Remote calls SHALL retain local lifecycle/destructive-input rules.

#### Scenario: Macus runtime request

- **WHEN** a permitted central caller requests a registered Macus lifecycle operation
- **THEN** the Macus adapter invokes its existing Swift runtime with the same local safety checks

### Requirement: Filesystem locality contract

Path resolution SHALL identify target/generation, execution-host locality and permitted scope. Central-server and caller-local paths MUST NOT be treated as remote mounts. Required sharing/configuration steps SHALL be reported before attachment is claimed ready.

#### Scenario: Macus share prerequisite

- **WHEN** a selected Mac directory requires stopped-runtime share configuration
- **THEN** the adapter reports the prerequisite without implicit restart or attachment

### Requirement: Embedded optional connector activation

An embedding host SHALL enable connector workers only after explicit enrollment. Workers SHALL reuse its existing local store/service tree without a dependency endpoint/repository. Standalone local access SHALL remain available while central is disconnected; base library/client acceptance MUST NOT require connector activation.

#### Scenario: Library-only Macus installation

- **WHEN** Macus imports the foundational library/client before enabling connector features
- **THEN** it needs no central registration or connector services to use its local Incus connection

### Requirement: Per-target connection isolation

Central target adapters SHALL isolate backend credentials, trust, pools, capabilities and events by target/generation. Connected execution SHALL use the canonical client at its configured host. Backend-returned operation/stream addresses MUST NOT escape registered trust policy or reuse another target's credentials.

#### Scenario: Cross-target connection reuse

- **WHEN** target B is selected after an operation used target A
- **THEN** B's own approved connection identity is used and no A credentials/event stream are reused
