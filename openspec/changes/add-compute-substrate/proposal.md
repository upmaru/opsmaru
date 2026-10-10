# Proposal

## Why

Macus's in-progress Elixir server assigns portable Incus operations, MCP tools and durable execution to a macOS application. Opsmaru will provide one reusable compute service that Macus embeds and Linux operators install independently, keeping native Incus behavior consistent across hosts.

## What Changes

- Create one Phoenix/Cowboy Mix application, `:opsmaru`, with `Opsmaru`/`OpsmaruWeb` namespaces and a public library API. The same source supports embedding and a standalone Linux release.
- Include the explicitly requested PostgreSQL/Ecto and HTML/LiveView scaffold for standalone external-identity bindings, local authorization and OIDC sign-in UI; their feature behavior is proposed in [add-remote-api-and-oauth](../add-remote-api-and-oauth/proposal.md).
- Default to embedded mode: start configured application workers without starting an Opsmaru endpoint, repository or listener. Explicit standalone configuration enables the authenticated Phoenix endpoint; ambient `PHX_SERVER` or `PORT` must not activate an embedded installation.
- Provide the portable `Opsmaru.Incus` client over local Unix and authenticated HTTPS transports, preserving a pinned official-client coverage inventory, native operation identities and streaming behavior.
- Provide shared typed Incus MCP tools, catalogue composition and scoped request context through the designated [kritama/tama-mcp](https://github.com/kritama/tama-mcp) dependency (`:tama_mcp`, `TamaMCP`). Macus adds its own runtime tools and mounts one combined `/mcp` endpoint in its existing server.
- Provide reusable durable task persistence, execution handoff, recovery, cancellation, deadlines and bounded notifications with host-owned private state and credentials.
- Define host registration and capability contracts for a single execution host per endpoint. macOS runtime and filesystem sharing remain supplied by Macus; Linux uses existing Incus without owning a new outer VM.
- Provide standalone Linux HTTPS/MCP configuration, configured external-provider authentication and owner-local permission administration, a bundled-ERTS release and explicit systemd installation/activation with separate package and real-Incus acceptance.
- Treat the first foundation as shared compute primitives. Environment recipes, skills, workspace provisioning, previews, scheduling and multi-host control remain subsequent changes.

## Capabilities

### New Capabilities

- `embedded-service`: reusable service startup, host configuration and listener-free embedding into another OTP application.
- `incus-client`: portable canonical Incus API and stream behavior with independently recorded coverage.
- `mcp-service`: shared tool contracts, host catalogue composition and caller-bound authorization.
- `task-execution`: durable task handoff, recovery, bounded execution and authoritative task lookup.
- `host-capabilities`: explicit execution-host identity, adapters and truthful platform/backend capability reporting.
- `standalone-service`: independently installed Linux HTTPS/MCP service, external identity configuration, packaging and lifecycle.

### Modified Capabilities

None; the supplied repository has no existing application or main specifications.

## Impact

- Implementation will add a root Phoenix project, dependency locks, pinned development tools, conformance/differential fixtures, documentation and Linux release/service packaging to `upmaru/opsmaru`.
- The integration consumer is Macus's `add-elixir-server` change. Its pending shared client/tool/task implementation moves to this project; Macus retains its Swift runtime adapter, transparent proxy, authentication boundary, CLI and macOS delivery.
- No Macus source is moved by this proposal. Existing reference provenance and Cowboy fixture evidence are inputs for implementation, with source notices and acceptance boundaries retained.
- The shared library has no mandatory Macus dependency, fixed macOS state path, Swift runtime endpoint or host lifecycle installation side effect. Production consumers pin an immutable revision or released package; editable path dependencies are development-only.
- The later explicitly requested Phoenix bootstrap is now present on the feature branch with baseline compilation/assets/tests and embedded-start verification. Shared compute, OAuth and installed/live-backend functionality remain pending; no service activation, credential creation or live workload mutation was performed.
