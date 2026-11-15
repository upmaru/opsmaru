# Spec Delta

## Purpose

Creates and removes cloud virtual machines and their networking on supported providers as reconciled, owner-labelled hosts that become Incus targets.

## ADDED Requirements

### Requirement: Native provider adapters

Central Opsmaru SHALL provision hosts through provider adapters implementing one shared contract for network, firewall, instance, description and destruction. Adapters SHALL call provider HTTP APIs directly. Opsmaru MUST NOT invoke a cloud CLI, Terraform, OpenTofu or a remote shell to provision a host.

#### Scenario: Same specification on two providers

- **WHEN** equivalent host specifications are provisioned on two supported providers
- **THEN** both reach the same ready state through the same lifecycle and differ only in provider resources

#### Scenario: Unsupported provider

- **WHEN** a specification names a provider with no accepted adapter
- **THEN** planning fails and no provider request is made

### Requirement: Administrator-managed provider accounts

Provider credentials SHALL be stored as encrypted provider accounts created by an administrator. Provisioning requests SHALL reference an account by ID and require a grant for that account. Credentials MUST NOT appear in tool inputs, responses, task records, logs or instance user-data.

#### Scenario: Caller without an account grant

- **WHEN** a caller requests a host against a provider account they are not granted
- **THEN** the request is denied before any provider API is contacted

#### Scenario: Credentials supplied in a request

- **WHEN** a request includes provider credentials instead of an account ID
- **THEN** the request is rejected and the supplied values are not stored

### Requirement: Side-effect-free planning

Planning SHALL validate a host specification against the account, provider options and central configuration and SHALL list the resources that provisioning would create. Planning MUST NOT create, modify or reserve any provider resource.

#### Scenario: Valid plan

- **WHEN** a permitted caller plans a host with a valid region and size
- **THEN** the response lists the intended network, firewall and instance and nothing exists at the provider afterwards

#### Scenario: Missing central egress addresses

- **WHEN** central has no configured egress addresses for the firewall rule
- **THEN** planning and provisioning fail rather than permitting the Incus API from any address

### Requirement: Reconciled host lifecycle

Each host SHALL be a persisted desired-state record advanced by a durable reconciler through requested, creating, bootstrapping, registering and ready, with failed, destroying and destroyed. Each step SHALL be idempotent and bounded by a deadline. A restart SHALL resume from the committed phase.

#### Scenario: Restart during creation

- **WHEN** central restarts after the network exists but before the instance is created
- **THEN** the reconciler resumes, reuses the existing network and creates one instance

#### Scenario: Phase deadline exceeded

- **WHEN** a host does not complete bootstrap within its deadline
- **THEN** the host becomes failed with the phase and last provider response recorded

### Requirement: Native operation identity and no blind replay

The reconciler SHALL record each provider operation or resource identity before advancing. When a create request may have been accepted without a recorded identity, it SHALL resolve the outcome by looking up the host label and MUST NOT repeat the request blindly. An unresolved outcome SHALL be recorded as uncertain and stop the host for an operator.

#### Scenario: Crash after instance create was sent

- **WHEN** central stops after sending an instance create request and before recording its result
- **THEN** on restart the reconciler finds the labelled instance and adopts it instead of creating a second one

#### Scenario: Lookup inconclusive

- **WHEN** the provider cannot confirm whether a labelled resource exists
- **THEN** the host records uncertainty and no further create request is sent automatically

### Requirement: Resource ownership labels

Every resource Opsmaru creates SHALL carry the host ID and installation ID as provider labels and SHALL be recorded against the host. Opsmaru MUST NOT modify or destroy a resource that is not both recorded for the host and labelled for it. A network supplied in the specification SHALL be recorded as supplied and left unchanged.

#### Scenario: Unlabelled resource in the same account

- **WHEN** destroy runs in an account containing unrelated instances and networks
- **THEN** only resources recorded and labelled for that host are removed

#### Scenario: Supplied network

- **WHEN** a host was provisioned into an existing network named in its specification
- **THEN** destroying the host leaves that network in place

### Requirement: Failure preserves resources

A failed host SHALL keep its created resources and SHALL report them, with the failing phase, in host status and central readiness. Opsmaru MUST NOT delete resources automatically on failure. A failed host SHALL be retryable from its failed phase.

#### Scenario: Bootstrap failure

- **WHEN** the instance is created but Incus never enrols
- **THEN** the host is failed, its instance and network still exist and status lists them as retained

### Requirement: Explicit destructive teardown

Destroying a host SHALL require a destructive scope and explicit confirmation naming the host. Destroying a host whose Incus server still has instances SHALL require a further explicit acknowledgement. Teardown SHALL remove the target registration and owned resources and SHALL be resumable.

#### Scenario: Missing confirmation

- **WHEN** a destroy request omits the confirmation or carries the wrong scope
- **THEN** nothing is removed and no provider API is contacted

#### Scenario: Host with running sandboxes

- **WHEN** a destroy request targets a ready host that still has Incus instances and lacks the further acknowledgement
- **THEN** the request is refused and the instances continue running

### Requirement: Coarse operation surface

MCP and REST SHALL expose provider account and option listing, host planning, provisioning, status and destruction through one shared operation contract. Opsmaru MUST NOT expose operations that create or change individual provider primitives. Provisioning SHALL return a durable task bound to the caller.

#### Scenario: Agent provisions a host

- **WHEN** an agent with the provisioning scope calls the provision operation with an account, region and size
- **THEN** it receives a task and can follow the host to ready without any other provider-level call

### Requirement: Central-only activation

Provisioning processes, provider clients and the enrolment callback route SHALL start only in standalone mode with provisioning explicitly enabled. Embedded and connector-only roles MUST NOT start them or contact a provider.

#### Scenario: Embedded inclusion

- **WHEN** a host application loads Opsmaru as a dependency in embedded mode
- **THEN** no provisioning process, provider client or callback route exists

### Requirement: Per-provider acceptance evidence

A provider SHALL be advertised as supported only after its own live acceptance in a dedicated test account. Fixture checks against recorded provider responses SHALL be reported separately and MUST NOT be presented as provider support.

#### Scenario: Fixtures pass without live acceptance

- **WHEN** an adapter passes fixture checks but has no live acceptance record
- **THEN** the provider is not listed as available for provisioning
