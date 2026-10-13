# Opsmaru

Opsmaru is a Phoenix application intended to provide portable Incus compute operations through an embedded Elixir API, MCP and REST. Macus embeds the same application; a central Linux deployment manages registered Incus clusters and Macus targets through one MCP/REST gateway.

This branch contains a Phoenix 1.8 scaffold with passive embedded startup. The portable Unix/mutual-TLS Incus client is the separate [`:opsmaru_incus`](https://github.com/upmaru/opsmaru-incus) library, used by both Opsmaru and Macus; its API, coverage and acceptance live in that repository. Central registration, outbound connectors, external OIDC, permissions and REST/MCP operations remain planning artifacts. The generated development page is not an authenticated compute console.

## Development

From this checkout:

```sh
mise trust
mise install
```

Configure a dedicated PostgreSQL database through `OPSMARU_DATABASE_HOST`, `OPSMARU_DATABASE_PORT`, `OPSMARU_DATABASE_USER` and `OPSMARU_DATABASE_PASSWORD`. Development/test defaults are localhost:5432 and the generated postgres/postgres development credentials. Database names are `opsmaru_dev` and `opsmaru_test` (plus `MIX_TEST_PARTITION` for partitioned tests). Do not point tests at a production database.

```sh
mise run setup
OPSMARU_MODE=standalone mise exec -- mix phx.server
```

The development page is served on loopback at port 4000. Assets use the generated Tailwind/esbuild setup. External OIDC sign-in and provider-issued API tokens are proposed next, with Keycloak as the first test provider. Setup does not provision provider accounts, local administrator grants or OAuth keys.

```sh
mise run check
mise run spec:validate
```

The checks require the configured dedicated test database. `scripts/check-embedded.exs` independently verifies the default embedding boundary with hostile server environment variables.

Strict Credo is included in `mix precommit` and `mise run check`. It is a
development/test dependency and does not start with an embedded production
consumer. Run the real precommit command safely
with `python3 scripts/check-isolated.py --precommit`; this also runs canonical
checks in a fresh test-only PostgreSQL cluster and removes it afterward.

## Embedding and deployment

Embedded mode is the default, starting an empty supervisor. It starts neither `OpsmaruWeb.Endpoint` nor `Opsmaru.Repo`; loading the dependency does not require database or web secrets or contact a backend. The host application owns authentication, endpoint mounting, private state and platform adapters. Optional bounded client supervision is host-selected. Standalone Macus needs no central registration; the outbound connector and macus connect [url] belong to later changes.

Central standalone mode is selected explicitly with `OPSMARU_MODE=standalone`. Production configuration requires `DATABASE_URL`, `SECRET_KEY_BASE`, `PHX_HOST`, `OPSMARU_TLS_CERTFILE` and `OPSMARU_TLS_KEYFILE`. It binds HTTPS to loopback by default; `OPSMARU_BIND_IP` and `PORT` select an explicit address/port. The central role will use PostgreSQL for registry/policy/tasks and will not require a local Incus install. A planned connector-only Linux role uses private receipt/device state with no Endpoint/Repo or inbound listener. The application currently provides only scaffold routes; authentication and compute endpoints require implementation of the plans below.

## Planning

- [Embedded library and Incus client first](https://github.com/upmaru/opsmaru-incus/blob/develop/openspec/changes/add-embedded-incus-foundation/proposal.md): moved to `upmaru/opsmaru-incus` with the client on 2026-10-13; task 3.9 continues there.
- Native gateway and shared Incus MCP tools: moved to `upmaru/opsmaru-incus` (`add-embeddable-incus-gateway`, `add-incus-operations`).
- [Later compute substrate](openspec/changes/add-compute-substrate/proposal.md): shared Incus client/tools, registered targets, direct HTTPS, outbound connectors and central/local durable execution.
- [Remote API and OAuth](openspec/changes/add-remote-api-and-oauth/proposal.md): shared REST commands, configurable external OIDC/OAuth, central target grants, device enrollment, browser sessions and Keycloak acceptance.

Implement add-embedded-incus-foundation (in opsmaru-incus) first; it does not depend on central service, MCP/task adapters, OIDC or connectors. Implementation follows validated OpenSpec changes. A validated proposal is not completed runtime or security acceptance.

## Git Flow

`main` is the released-history branch; its initial commit establishes repository planning only. `develop` is the integration branch. Development uses `feature/*` branches from `develop`. Releases use `release/*`, finishing into both long-lived branches; hotfixes start from `main`. Branch finishing/merging requires explicit authorization. Development work is published on its feature branch. Bootstrap work is published on its feature branch, without a release tag.
