# Spec Delta

## Purpose

Lets remote agents, users and service clients obtain bounded access to the configured compute host through a self-hosted authorization service and standard discovery contracts.

## ADDED Requirements

### Requirement: Authorization code with PKCE

The authorization service SHALL require authorization-code flow with S256 PKCE for public clients, registered exact redirect validation and explicit requested resource/scopes. Codes SHALL be short-lived, one-use and bound to client, redirect, user, verifier challenge and resource. Implicit and password grants MUST NOT be supported.

#### Scenario: Invalid verifier

- **WHEN** a client redeems a code with a mismatched PKCE verifier
- **THEN** token issuance fails without granting access to the compute resource

### Requirement: Resource and scope bound tokens

Access tokens SHALL identify a verified issuer, subject, client, expiry and authorized resource/scopes. MCP and REST SHALL validate their canonical resource audience and policy before backend access. A credential for one resource MUST NOT automatically authorize another.

#### Scenario: Wrong resource audience

- **WHEN** a caller presents an MCP-bound token to a separately identified REST resource
- **THEN** authorization rejects it unless that resource was explicitly authorized

### Requirement: Discovery and challenge metadata

The service SHALL publish authorization-server metadata, public signing keys and protected-resource metadata for configured MCP/REST resources. Challenges SHALL identify the resource metadata location without exposing private keys or host backend addresses.

#### Scenario: Remote MCP discovery

- **WHEN** a remote agent receives an authentication challenge
- **THEN** it can discover the configured issuer and supported flow through public metadata before requesting consent

### Requirement: Refresh rotation and revocation

Refresh credentials SHALL rotate with replay detection and family invalidation policy. Revocation and expiry SHALL reject new calls and invalidate affected long-lived delivery within the documented bound. Accepted compute work SHALL not be described as undone merely because its credential was revoked.

#### Scenario: Refresh credential replay

- **WHEN** an already consumed refresh credential is presented again
- **THEN** the service records replay and applies its family revocation policy without issuing another token

### Requirement: Authorized service clients

Confidential orchestration clients SHALL authenticate with an approved client method and receive only explicitly granted resource/host/project scopes for a service principal. Client-credentials issuance MUST NOT accept a caller-supplied user identity or impersonate a human owner.

#### Scenario: Service client supplies user identity

- **WHEN** a service client requests a token while naming another user as owner
- **THEN** issuance binds the registered service principal or rejects the request without adopting that supplied identity

### Requirement: Registered client trust

Client registration SHALL enforce approved redirect URIs, supported authentication methods and bounded scope/resource policy. Optional dynamic public registration SHALL be explicit, rate-limited and unable to grant scopes or service-client privileges without owner policy.

#### Scenario: Registration requests elevated scopes

- **WHEN** a newly registered public client requests permissions beyond its allowed policy
- **THEN** registration or authorization rejects those permissions and no elevated grant is created

### Requirement: Host-owned authentication when embedded

Embedded HTTP and MCP handlers SHALL accept host-verified identity through configured adapters without starting an Opsmaru issuer, browser session service, key generator or database. The same scope and task-owner contract SHALL apply to host-issued credentials.

#### Scenario: Macus authenticates an embedded call

- **WHEN** Macus supplies its verified principal and scopes
- **THEN** shared handlers use that identity without requiring a second OAuth login or standalone issuer

### Requirement: Verified protocol profile

The advertised OAuth grant and discovery profile SHALL match tested application and dependency support. Internet-Draft targets SHALL identify their revision. Missing protocol-library support MUST remain explicit; helper primitives MUST NOT be advertised as a completed authorization server.

#### Scenario: Unsupported grant implementation

- **WHEN** a grant parser or persistence adapter lacks required behavior
- **THEN** that grant is not advertised or accepted until conformance and lifecycle tests pass
