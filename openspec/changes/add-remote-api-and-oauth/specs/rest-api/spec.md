# Spec Delta

## Purpose

Allows HTTP clients and external orchestration graphs to invoke the same authorized compute operations and track the same results as MCP and embedded library callers.

## ADDED Requirements

### Requirement: Shared versioned operation contract

The REST API SHALL expose registered operations under /api/v1 using the same domain validation, permissions, host binding and execution services as MCP. It MUST NOT implement a second workload manager or independently duplicate compute behavior.

#### Scenario: Equivalent invocation

- **WHEN** the same authorized principal invokes a registered operation through REST and MCP
- **THEN** both paths enforce equivalent schemas and policy and produce equivalent domain outcomes

### Requirement: Scope-aware operation selection

Only registered operations SHALL be discoverable or invocable. Caller credentials SHALL select authorized scopes and projects on the configured host; request fields MUST NOT forge another owner, remote backend or arbitrary host command.

#### Scenario: Unknown operation

- **WHEN** a client submits an unregistered operation name
- **THEN** the API returns a bounded not-found or validation error before backend access

### Requirement: Durable asynchronous results

Long-running REST operations SHALL return an accepted response with a durable owner-bound task identity and polling location only after execution intent is committed. Acceptance, completion and uncertain backend outcomes SHALL remain distinct.

#### Scenario: Client disconnect after acceptance

- **WHEN** the caller loses the response to an accepted operation
- **THEN** its authenticated reconciliation request can recover the committed task rather than issuing the mutation again

### Requirement: Replay-safe request identity

Mutating submissions SHALL support owner/host/operation-bound idempotency keys persisted atomically with execution intent. Reusing a key with the same normalized input SHALL return the original task/result; different input SHALL fail with conflict. Unknown backend outcomes MUST NOT be retried blindly.

#### Scenario: Duplicate submission

- **WHEN** the same owner repeats an accepted submission with the same idempotency key and normalized input
- **THEN** it receives the original task identity and no second backend mutation occurs

#### Scenario: Key reused for different input

- **WHEN** the owner reuses a committed key with different operation input
- **THEN** the API returns conflict without replacing the original execution

### Requirement: Owner-bound task API

Task inspection, result retrieval and cancellation SHALL enforce the same owner and expiry/revocation policy as MCP task access. Polling SHALL remain authoritative; cancellation intent MUST NOT be reported as completed remote cancellation without evidence.

#### Scenario: Unauthorized task lookup

- **WHEN** a caller requests another principal's task
- **THEN** the API returns an owner-safe failure without revealing the task or native operation data

### Requirement: External orchestration boundary

The API SHALL supply bounded structured errors, correlation identifiers and operation/task state suitable for external orchestration. Reasoning, branching, model selection and general workflow scheduling SHALL remain external. Macros SHALL be explicitly registered bounded operations.

#### Scenario: Tama orchestration client

- **WHEN** an authorized graph client submits and polls a compute operation
- **THEN** it can decide its next step from structured results without Opsmaru running the reasoning graph

### Requirement: Embedded HTTP composition

An embedding host SHALL be able to mount shared REST handlers and shared MCP tools on its existing endpoint with host identity adapters. Mounting MUST NOT start the dependency's endpoint, repository or standalone provider/login services.

#### Scenario: Macus mounts REST

- **WHEN** Macus explicitly mounts the shared API with its verified host context
- **THEN** REST and composed MCP share its gateway identity and existing compute workers without another listener
