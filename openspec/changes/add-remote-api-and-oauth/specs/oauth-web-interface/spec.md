# Spec Delta

## Purpose

Provides a small standalone browser surface for login, deliberate OAuth consent and authorization administration without making a GUI mandatory for embedded compute.

## ADDED Requirements

### Requirement: Secure standalone browser sessions

Browser login SHALL establish renewable authenticated sessions with secure production cookies, session rotation, CSRF protection and bounded login attempts. Authentication errors MUST NOT reveal whether an account exists. Sessions SHALL be revocable independently of OAuth client grants.

#### Scenario: Successful login

- **WHEN** a provisioned user authenticates successfully
- **THEN** the browser receives a renewed session and cannot retain an attacker-chosen pre-login session identity

### Requirement: Deliberate consent

Consent SHALL display the verified client, requested resource and allowed scopes. A user's decision SHALL apply only to the validated authorization request. Denial MUST NOT create a grant, and invalid redirect requests MUST NOT be followed.

#### Scenario: User denies consent

- **WHEN** an authenticated user denies a validated client request
- **THEN** no grant or access token is issued and only the validated protocol error redirect is used

### Requirement: Limited authorization administration

Authorized users SHALL inspect and revoke their grants and sessions. Client/account administration SHALL require explicit administrative authority. The initial UI MUST NOT provide arbitrary host commands, public signup or a workload orchestration dashboard.

#### Scenario: Non-admin client administration

- **WHEN** a non-admin requests client or account administration
- **THEN** access is denied without changing the registered authorization policy

### Requirement: Browser and API boundary separation

Browser session/CSRF handling SHALL remain separate from OAuth token and REST/MCP request parsing. Browser cookies MUST NOT silently replace resource bearer credentials on compute routes. Secrets SHALL be excluded from browser output, URLs and ordinary logs.

#### Scenario: Session cookie on API route

- **WHEN** a browser sends only its login cookie to a bearer-protected compute route
- **THEN** the API requires its explicit resource authorization instead of inheriting session authority

### Requirement: Optional embedded web surface

The library's browser surface SHALL not start or be mounted automatically in embedded mode. Hosts SHALL retain the choice to provide their own authentication UI or explicitly mount compatible handlers without another endpoint or repository.

#### Scenario: Macus includes the dependency

- **WHEN** Macus starts shared compute without mounting the standalone browser routes
- **THEN** no Opsmaru login/consent interface, endpoint or database is activated
