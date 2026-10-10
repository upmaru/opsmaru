# Spec Delta

## Purpose

Makes portable compute tools available through a shared MCP contract that standalone and embedding hosts compose with their own explicitly authorized extensions.

## ADDED Requirements

### Requirement: Maintained protocol integration

MCP SHALL use the designated maintained MCP library's supported transport, schemas and task contracts; Opsmaru MUST NOT duplicate its protocol engine. Unsupported resources, prompts, stdio or protocol versions MUST NOT be advertised. Authentication SHALL precede discovery and dispatch.

#### Scenario: Unsupported protocol

- **WHEN** a client requests a protocol feature unsupported by the pinned dependency
- **THEN** the endpoint returns a bounded protocol failure rather than advertising invented support

### Requirement: Shared portable tool contract

Shared Incus inspection, explicit mutations and bounded guest-execution tools SHALL retain the same names, schemas, scope requirements and result semantics across hosts. Tools SHALL delegate to the shared client and MUST NOT expose an unrestricted host command endpoint.

#### Scenario: Same compute operation on both hosts

- **WHEN** an authorized caller invokes the same shared tool on Macus and standalone Linux
- **THEN** both endpoints enforce the same input and output contract while using their configured Incus backend

### Requirement: Host catalogue composition

An embedding host SHALL be able to expose shared compute tools and host-specific tools through one catalogue and endpoint. Duplicate names SHALL fail catalogue construction. Platform-specific runtime tools SHALL execute only on selected targets that supply compatible authorized adapters.

#### Scenario: Macus combined catalogue

- **WHEN** Macus registers shared tools and its Swift runtime tools
- **THEN** both tool families are available through Macus's single MCP endpoint without starting the embedded service's listener

#### Scenario: Standalone Linux catalogue

- **WHEN** a Linux server builds its catalogue without a Macus runtime provider
- **THEN** shared compute tools remain available and Macus runtime execution is unavailable on Incus-only targets

### Requirement: Verified caller context

Tool execution SHALL receive a host-verified principal, stable owner identity and granted scopes. Backend and host bindings SHALL come from trusted host configuration, not arbitrary caller endpoints or paths. Caller identity SHALL survive asynchronous handoff.

#### Scenario: Forged owner or backend

- **WHEN** a request supplies another owner identity or an unregistered backend address
- **THEN** those values do not replace the authenticated owner or configured backend and no unauthorized operation is dispatched

### Requirement: Scope-aware discovery and dispatch

Inspection, write, exec and destructive permissions SHALL be enforced during discovery and execution. Unknown tools and insufficient permissions SHALL fail before backend or host-provider access. Long-lived streams SHALL reauthorize and close on expiry or revocation.

#### Scenario: Read-only caller

- **WHEN** a caller has inspection permissions only
- **THEN** it cannot discover or execute mutation tools and denied calls never contact the backend

### Requirement: Explicit destructive inputs

Deletion, destructive restore and forced operations SHALL require their explicit destructive inputs and permissions. Natural-language inference or broad implicit consent MUST NOT authorize a mutation. Host-specific tools SHALL preserve their host's existing safety requirements.

#### Scenario: Missing deletion confirmation

- **WHEN** an authorized caller omits the required confirmation for a deletion
- **THEN** validation rejects the request before backend dispatch

### Requirement: Shared contract verification

Shared tool schemas and protocol conformance SHALL be tested independently of host integration. Each host SHALL verify its composed catalogue, identity adapter and backend binding. Protocol fixture success MUST NOT establish installed or real-host acceptance.

#### Scenario: Consumer integration review

- **WHEN** Macus integrates a new pinned shared-library revision
- **THEN** its catalogue composition, shared schemas and authorization integration are verified in addition to the library's own conformance evidence

### Requirement: Registered-target MCP selection

Central discovery SHALL expose only permitted registered targets and their observed capabilities through one MCP endpoint. Targeted central execution SHALL require explicit target ID; local embedded calls SHALL default only to their configured local target. Tool schema compatibility SHALL be maintained across direct and connected execution.

#### Scenario: Missing central mutation target

- **WHEN** an agent requests a targeted mutation without a registered target ID
- **THEN** validation fails before backend dispatch rather than using a global default target

#### Scenario: Local target omitted

- **WHEN** a standalone Macus caller omits target ID for a local compute operation
- **THEN** its sole configured local backend is selected without contacting central Opsmaru
