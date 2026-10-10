# Spec Delta

## Purpose

Provides external-provider browser sign-in and limited local authorization/session administration while leaving account authentication and OAuth consent at the provider.

## ADDED Requirements

### Requirement: External OIDC sign-in

Browser login SHALL use authorization code with S256 PKCE, expiring one-use state and nonce against the configured provider. Callback validation SHALL bind issuer, signature, client audience, expiry, nonce and transaction before creating a session. Local passwords, account signup and OAuth consent/token issuance MUST NOT be provided.

#### Scenario: Unsolicited or replayed callback

- **WHEN** an OIDC callback has missing, expired or consumed transaction state
- **THEN** login fails without creating a session or following an untrusted return target

#### Scenario: Validated external login

- **WHEN** an authorized external subject completes a valid callback
- **THEN** Opsmaru creates a fresh local session for that exact issuer/subject without issuing compute tokens

### Requirement: Bounded secure browser sessions

Sessions SHALL use secure production cookies, session renewal, CSRF protection, bounded login initiation and origin validation. Their maximum lifetime SHALL be 15 minutes capped at verified login token expiry, with a fresh provider round trip for renewal. Logout/local revocation SHALL remove local session authority; provider-wide logout MUST NOT be implied.

#### Scenario: Local logout

- **WHEN** a user logs out of Opsmaru
- **THEN** its local session fails subsequent authorization without claiming provider tokens or other applications were revoked

### Requirement: Local authorization administration

Users SHALL inspect their identity, sessions and permitted target permissions. Target registration/revocation and grant/subject administration SHALL require explicit administrator authority. Provider accounts, registered clients, consent and credential lifecycle SHALL remain provider-owned; the UI MUST NOT expose arbitrary host commands or orchestration.

#### Scenario: Non-admin changes local grants

- **WHEN** a non-admin submits a local permission change
- **THEN** it is denied without altering compute policy

### Requirement: Browser and resource boundary separation

Browser sessions SHALL remain separate from REST/MCP bearer credentials and request parsing. Cookies MUST NOT authorize compute routes implicitly. Callback codes/tokens SHALL not appear in ordinary logs or output; return destinations SHALL be validated and cannot retain authorization material.

#### Scenario: Session cookie on API route

- **WHEN** a browser sends only its login cookie to a compute API
- **THEN** the API requires explicit resource bearer authorization

### Requirement: Optional embedded web surface

The browser surface SHALL not start or mount automatically in embedded mode. Hosts SHALL retain their own identity UI and endpoint; reusing provider handlers SHALL require explicit integration without another listener or repository.

#### Scenario: Macus includes the dependency

- **WHEN** Macus starts shared compute without mounting browser routes
- **THEN** no Opsmaru login interface, provider connection, endpoint or database is activated
