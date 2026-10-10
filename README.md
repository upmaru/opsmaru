# Opsmaru

Opsmaru is a Phoenix application intended to provide portable Incus compute operations through an embedded Elixir API, MCP and REST. Macus embeds the same application; Linux hosts can run its standalone Phoenix service.

This branch contains a Phoenix 1.8 scaffold with PostgreSQL/Ecto, HTML/LiveView assets and Cowboy. External OIDC login/token validation, local permissions, REST operations, MCP tools and Incus execution are planning artifacts, not implemented features. The generated development page is not an authenticated compute console.

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

## Embedding and deployment

Embedded mode is the default. It starts neither `OpsmaruWeb.Endpoint` nor `Opsmaru.Repo`; loading the dependency does not require database or web secrets. The host application owns authentication, endpoint mounting and optional persistence adapters. Shared compute workers will be implemented by the foundation change.

Standalone mode is selected explicitly with `OPSMARU_MODE=standalone`. Production configuration requires `DATABASE_URL`, `SECRET_KEY_BASE`, `PHX_HOST`, `OPSMARU_TLS_CERTFILE` and `OPSMARU_TLS_KEYFILE`. It binds HTTPS to loopback by default; `OPSMARU_BIND_IP` and `PORT` select an explicit address/port. The application currently provides only scaffold routes; authentication and compute endpoints require implementation of the plans below.

## Planning

- [Compute foundation](openspec/changes/add-compute-substrate/proposal.md): shared Incus client, composable MCP tools, host contracts and durable execution.
- [Remote API and OAuth](openspec/changes/add-remote-api-and-oauth/proposal.md): shared REST commands, configurable external OIDC/OAuth, local permission/session persistence and Keycloak acceptance.

Implementation follows validated OpenSpec changes. A validated proposal is not completed runtime or security acceptance.

## Git Flow

`main` is the released-history branch; its initial commit establishes repository planning only. `develop` is the integration branch. Development uses `feature/*` branches from `develop`. Releases use `release/*`, finishing into both long-lived branches; hotfixes start from `main`. Branch finishing/merging and publication require explicit authorization. Bootstrap work is published on its feature branch, without a release tag.
