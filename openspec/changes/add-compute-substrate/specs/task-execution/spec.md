# Spec Delta

## Purpose

Provides owner-and-target-bound durable execution with central coordination and local receipts so operations survive direct transport, connector and process failures.

## ADDED Requirements

### Requirement: Durable execution handoff

A returned durable task handle SHALL identify an owner-bound task and accepted execution intent persisted before the response. Tasks SHALL persist data-only execution descriptors, stable tool identity and host/backend binding, not closures or bearer credentials.

#### Scenario: Immediate process failure

- **WHEN** the server exits immediately after returning a durable task handle
- **THEN** task lookup after restart recovers the task and committed execution intent for the same owner

### Requirement: Deployment-selected durable persistence

Central task, idempotency and dispatch intent SHALL commit atomically in its configured durable store. Embedded tasks and connector receipts SHALL use host-private storage outside packages/workload disks without requiring a repository. Stores SHALL isolate owner, target and generation; inspection/library inclusion MUST NOT create storage implicitly.

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

### Requirement: Central task and connector receipt linkage

Central dispatch SHALL persist a stable ID, target/generation and input digest before sending. A connector SHALL commit its execution receipt before acknowledgement. Duplicate matching IDs SHALL return the same receipt; changed inputs SHALL conflict. Reconnect MUST NOT bypass known or uncertain native acceptance.

#### Scenario: Acknowledgement lost

- **WHEN** central loses the connector acknowledgement after durable local acceptance
- **THEN** it queries the same receipt and native operation rather than creating another dispatch

### Requirement: Target-bound recovery

Tasks SHALL preserve registered target/generation, native operation identity and execution owner across restart. A revoked or replacement target SHALL not receive old work automatically. Cancellation SHALL remain intent until supported backend evidence confirms its effect.

#### Scenario: Target replacement during recovery

- **WHEN** a task's registered generation differs from the current device/backend
- **THEN** recovery preserves the task and reports reconciliation required without rerouting its mutation
