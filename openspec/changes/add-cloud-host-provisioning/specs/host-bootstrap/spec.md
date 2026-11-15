# Spec Delta

## Purpose

Installs Incus on a newly created host, establishes mutual trust with central Opsmaru and hands the host to the target registry with its observed capabilities.

## ADDED Requirements

### Requirement: Provider-neutral bootstrap

A new host SHALL be configured only by a single cloud-init template passed as instance user-data and shared by all providers. The template SHALL install Incus from a pinned package source on a pinned stock image family and apply a preseed for storage, a managed bridge and the HTTPS listener. Opsmaru MUST NOT open a remote shell on the host.

#### Scenario: Same template across providers

- **WHEN** hosts are provisioned on two different providers
- **THEN** both receive the same bootstrap template, differing only in per-host values

#### Scenario: No remote shell

- **WHEN** a host is provisioned with default settings
- **THEN** its firewall permits no inbound SSH and central makes no shell connection to it

### Requirement: Restricted Incus API exposure

The host firewall SHALL permit inbound access to the Incus HTTPS API only from central's configured egress addresses. Provisioning MUST NOT create a rule permitting the Incus API from any address.

#### Scenario: Connection from another address

- **WHEN** a client outside the configured egress addresses connects to the host's Incus API port
- **THEN** the provider firewall drops the connection

### Requirement: Dedicated host client identity

Opsmaru SHALL generate a client key pair dedicated to each host before instance creation. The private key SHALL remain encrypted in central storage. Only the public certificate SHALL be placed in user-data and trusted by the host's Incus server. A client identity MUST NOT be reused across hosts.

#### Scenario: User-data contents

- **WHEN** the rendered user-data for a host is inspected
- **THEN** it contains the public client certificate and enrolment token and no private key or provider credential

### Requirement: One-use enrolment callback

Bootstrap SHALL report the Incus server certificate fingerprint to central using a random one-use token bound to the host and limited by expiry. Central SHALL accept the token once, only while that host is bootstrapping, and SHALL invalidate it on use, expiry or destroy.

#### Scenario: Token replay

- **WHEN** an enrolment token is presented a second time
- **THEN** the callback is rejected and the recorded fingerprint is unchanged

#### Scenario: Token for a host in another phase

- **WHEN** a valid token is presented after its host has failed or been destroyed
- **THEN** the callback is rejected

### Requirement: Provider-reported address and pinned certificate

Central SHALL connect to a provisioned host only at the address the provider API reports for its instance and SHALL verify the server certificate against the enrolled fingerprint. The callback MUST NOT be able to supply or change the address central connects to.

#### Scenario: Callback carries an address

- **WHEN** a callback includes a host address or URL
- **THEN** that value is ignored and central uses the provider-reported address

#### Scenario: Fingerprint mismatch

- **WHEN** the server at the provider-reported address presents a certificate that does not match the enrolled fingerprint
- **THEN** registration fails, the host becomes failed and no target is created

### Requirement: Registry handoff

After the pinned connection verifies, central SHALL register the host as a direct-HTTPS Incus target through the existing registry contract, with a stable target ID, generation and credential reference, and SHALL link the host record to that target. The requesting principal SHALL be recorded as owner. A host MUST NOT be reported ready before its target is usable.

#### Scenario: Ready host

- **WHEN** a host reaches ready
- **THEN** it appears as a registered target and a permitted caller can create an Incus instance on it through the normal Incus operations

#### Scenario: Re-provision after destroy

- **WHEN** a new host is provisioned after an earlier host was destroyed
- **THEN** it receives a new target identity and generation and inherits no tasks from the earlier host

### Requirement: Observed sandbox capabilities

After registration central SHALL read the instance drivers reported by the host's Incus server and record container and virtual-machine availability as target capabilities. Opsmaru MUST NOT advertise virtual-machine support for a host from its provider or size alone.

#### Scenario: Host without nested virtualization

- **WHEN** a provisioned host's Incus server reports no virtual-machine driver
- **THEN** the target advertises containers only and a virtual-machine request is refused with that reason

#### Scenario: Plan before the host exists

- **WHEN** a host is planned on a size whose virtualization support is unknown
- **THEN** the plan states that virtual-machine support is unverified until the host is ready
