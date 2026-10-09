# Spec Delta

## Purpose

Provides reusable caller-bound durable execution so long-running compute operations can be tracked and recovered consistently inside Macus or an independent Linux service.

## ADDED Requirements

### Requirement: Durable execution handoff

A returned durable task handle SHALL identify an owner-bound task and accepted execution intent persisted before the response. Tasks SHALL persist data-only execution descriptors, stable tool identity and host/backend binding, not closures or bearer credentials.

#### Scenario: Immediate process failure

- **WHEN** the server exits immediately after returning a durable task handle
- **THEN** task lookup after restart recovers the task and committed execution intent for the same owner

### Requirement: Host-owned private persistence

Task storage SHALL use an explicitly configured host-private location outside installed packages and workload disks. Embedded and standalone instances SHALL isolate task ownership and state. Library inclusion or read-only inspection MUST NOT create storage implicitly.

#### Scenario: Isolated embedding

- **WHEN** two isolated host installations select different state roots
- **THEN** neither installation reads or mutates the other's task journal

### Requirement: Native operation reconciliation

Known backend operation IDs SHALL be persisted promptly and used during recovery. A crash after possible acceptance but before durable identity SHALL produce an uncertain outcome requiring reconciliation. Recovery MUST NOT automatically replay a potentially accepted mutation.

#### Scenario: Ambiguous crash boundary

- **WHEN** execution crashes after possible backend acceptance without a durable operation ID
- **THEN** recovery records uncertainty and leaves backend state intact without repeating the mutation

### Requirement: Owner-bound task operations

Lookup, updates, input acceptance and cancellation SHALL enforce the authenticated owner. State transitions and cancellation intent SHALL be durable and idempotent. Committed tasks SHALL remain queryable independently of a notification connection.

#### Scenario: Another owner's task

- **WHEN** a caller requests another owner's task
- **THEN** the service returns an owner-safe failure without disclosing or modifying task state

### Requirement: Bounded execution and cancellation

Execution SHALL enforce concurrency, deadlines and captured-output bounds. Cancellation SHALL record intent and perform supported cooperative or backend cancellation. Local waiting cancellation MUST NOT be reported as confirmation that remote work stopped.

#### Scenario: Repeated cancellation

- **WHEN** the same task receives an already committed cancellation request again
- **THEN** the request returns the authoritative state without repeating cancellation side effects

### Requirement: Post-commit notifications

Notifications SHALL publish only committed task transitions through bounded subscriptions. Expiry, revocation and overflow SHALL terminate delivery as appropriate; task lookup SHALL remain authoritative after notification loss.

#### Scenario: Notification disconnect

- **WHEN** a subscription disconnects before delivering a committed transition
- **THEN** the same owner can recover the committed state through task lookup without an invented replay guarantee

### Requirement: Truthful task advertisement

Durable task support SHALL be advertised only when store, runner and execution handoff meet the maintained dependency's contracts. Native operation acceptance, in-memory execution and final completion SHALL be identified distinctly.

#### Scenario: Adapters incomplete

- **WHEN** a deployment lacks a complete durable store and runner
- **THEN** it does not advertise durable execution or return an in-memory worker handle as a durable task
