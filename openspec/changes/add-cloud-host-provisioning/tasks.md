# Tasks

Proposal only. Nothing here is implemented. This change depends on the target registry, direct-HTTPS adapter, durable central tasks and central startup in add-compute-substrate (sections 4, 5 and 7) and on verified callers, grants and secret protection in add-remote-api-and-oauth; implement those first. Fixture checks, per-provider live acceptance and installed-service acceptance are separate evidence.

## 1. Foundations and configuration

- [ ] 1.1 Resolve the open questions in design.md (image family and Incus package channel, supplied versus created networks, network sharing, disk layout) and record the decisions; verify the specs still validate.
- [ ] 1.2 Add provisioning configuration: explicit enable flag, central egress addresses, callback base URL, phase deadlines; verify standalone preflight fails clearly when enabled without egress addresses and that embedded and connector-only roles start no provisioning process, provider client or callback route.
- [ ] 1.3 Add migrations and schemas for provider accounts, hosts, host resources and enrolment tokens; verify credentials and host client private keys are encrypted at rest and never appear in inspected rows, logs or task payloads.

## 2. Provider contract and host lifecycle

- [ ] 2.1 Define the `Opsmaru.Provisioning.Provider` behaviour and a fixture provider; verify the contract covers ensure network, firewall and instance, describe, destroy and options with idempotent results.
- [ ] 2.2 Implement the host state machine and reconciler on the central durable task store; verify with the fixture provider that each phase commits before the next, a restart resumes from the committed phase and phase deadlines move the host to failed.
- [ ] 2.3 Implement native operation identity recording and label-based adoption; verify a crash after a possibly accepted create adopts the labelled resource, and an inconclusive lookup records uncertainty without a second create.
- [ ] 2.4 Implement ownership labels and supplied-resource handling; verify destroy removes only recorded and labelled resources and leaves a supplied network unchanged.
- [ ] 2.5 Implement failure retention, retry from the failed phase and readiness reporting; verify a failed host keeps and lists its resources and nothing is deleted automatically.

## 3. Bootstrap and registration

- [ ] 3.1 Implement per-host client key pair generation and the cloud-init template with pinned image family, Incus package source and preseed; verify rendered user-data contains no private key or provider credential and is identical across providers apart from per-host values.
- [ ] 3.2 Implement one-use enrolment tokens and the callback route; verify replay, expiry, wrong phase, destroyed host and supplied-address cases are rejected or ignored as specified.
- [ ] 3.3 Implement the pinned connection to the provider-reported address through `:opsmaru_incus`; verify a fingerprint mismatch fails the host and creates no target.
- [ ] 3.4 Hand off to the target registry with owner, generation and credential reference; verify a ready host is usable through the normal Incus operations and a re-provisioned host inherits no earlier target identity or tasks.
- [ ] 3.5 Record observed instance drivers as target capabilities; verify a host without a virtual-machine driver advertises containers only and refuses a virtual-machine request with that reason.

## 4. Provider adapters

- [ ] 4.1 Implement the DigitalOcean adapter (VPC, cloud firewall, droplet, tags) with recorded-response fixtures; verify idempotent ensure and labelled destroy without an idempotency token.
- [ ] 4.2 Implement the AWS adapter (VPC, subnet, internet gateway, route, security group, instance) with request signing and client tokens; verify fixtures for idempotent create, partial creation and labelled destroy.
- [ ] 4.3 Implement the GCP adapter (network, subnetwork, firewall rules, instance) with service-account authorization and request IDs; verify fixtures for pending operations, idempotent create and labelled destroy.
- [ ] 4.4 Document the minimum provider permissions for each adapter; verify each adapter's fixtures use no permission outside the documented set.

## 5. Operations and authorization

- [ ] 5.1 Add administrator management of provider accounts and account grants; verify credentials are write-only and an ungranted caller is denied before any provider request.
- [ ] 5.2 Register the shared operations (list accounts and options, plan, provision, status, destroy) for MCP and REST with read, provision and destructive scopes; verify identical schemas on both surfaces and that no provider-primitive operation is exposed.
- [ ] 5.3 Implement planning; verify it lists intended resources, reports unverified virtual-machine support and leaves nothing at the fixture provider.
- [ ] 5.4 Implement destroy confirmation and the further acknowledgement for hosts with instances; verify missing confirmation, wrong scope and a host with running sandboxes dispatch no provider or Incus request.

## 6. Acceptance and documentation

- [ ] 6.1 Run live acceptance per provider in a dedicated test account: plan, provision to ready, create and remove one container, destroy, confirm no labelled resource remains; record evidence per provider and advertise a provider only after its run passes.
- [ ] 6.2 Run live failure acceptance on at least one provider: interrupted creation resumes without duplicates, and a bootstrap failure retains and reports resources.
- [ ] 6.3 Document operator setup (provider accounts, egress addresses, costs of retained failures, teardown) and update the Terraform deferral note in add-compute-substrate; verify `mise run spec:validate` passes.
