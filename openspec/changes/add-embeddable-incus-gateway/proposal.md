# Proposal

## Why

Macus needs a native Incus gateway mounted in its existing Elixir server without another Opsmaru endpoint or a controller for every backend method. Reusable gateway mechanics and an independent Opsmaru acceptance harness let us verify portable behavior before Macus installation or hardware integration.

## What Changes

- Add an optional `Opsmaru.Incus.Gateway` library component with a mountable Plug for native HTTP/streaming and WebSockets plus a Cowboy protocol-switch companion for raw SFTP/NBD upgrades on the host's existing listener.
- Keep reusable modules under `lib/opsmaru/incus/gateway/`; reserve `OpsmaruWeb` for explicit standalone endpoint/router composition. Loading or configuring the library starts no endpoint, Repo, listener, credentials, runtime state or backend connection.
- Define an explicit host policy/configuration contract for verified callers, readiness, fixed backend connections, gateway identity/trust mediation, revocation and bounded resources. Macus retains its endpoint, policy, trust state, private sockets, Swift bridge, VM and packaging ownership.
- Preserve canonical `/`, `/1.0` and `/1.0/*` routes, native bytes/queries/headers/errors/ETags and operation identities, with authorization before backend access across every protocol. Never replay potentially accepted mutations or substitute WebSocket framing for raw upgrades.
- Add database-free protocol fixtures, an isolated immutable consumer and unmodified pinned Incus CLI/client conformance tests. Run direct typed-client and gateway tests against explicitly opted-in isolated real Incus in Opsmaru, recording each evidence class separately from installed Macus/hardware acceptance.
- Keep typed-client completion in `add-embedded-incus-foundation`; gateway proxy success cannot close its missing task 3.9 coverage. Foundation task 4.3 can be verified directly in Opsmaru without Macus or this gateway, with any shared acceptance evidence explicitly cross-referenced.
- Exclude central REST/MCP, OIDC/OAuth, registry/connectors, application task persistence, scheduling, provisioning, installers and modifications to Macus source.

## Capabilities

### New Capabilities

- `incus-gateway`: passive host mounting, policy-bound native relay, protocol upgrades and independent conformance/real-backend acceptance.

### Modified Capabilities

None. The main spec inventory is empty. Existing pending embedded-service/incus-client requirements remain owned by the foundation change, and the central service remains under its existing later changes.

## Impact

- The pinned baseline is Phoenix 1.8.15, Plug.Cowboy 2.9.0, Cowboy 2.19.0, Mint 1.11.0 and MintWebSocket 1.0.5. Plug.Cowboy currently supports WebSocket upgrades only; full raw upgrade handling requires Cowboy integration, not a `forward` line alone.
- Macus's current router has an empty JSON API scope; `Macus.Proxy` and `Macus.Auth` are boundary stubs. Its fixture-only Cowboy takeover proves coalesced-byte/half-close mechanics, not a production gateway. Reusable fixture transfer needs provenance/notices; no Macus source moves in this change.
- Opsmaru's typed client is implemented in partial verified slices at published revisions. Reuse transport/framing primitives where suitable, but its typed calls and buffered HTTP facade are not a transparent incoming streaming proxy.
- This explicitly refines previous proxy ownership: portable relay mechanics may be shared, while the public endpoint, trusted host policy and Apple-specific bridge remain Macus-owned. Macus adoption and reconciliation of its plans are separate consumer work.
- Merge the existing foundation feature into develop only with an honest reviewed delivery boundary; completing gateway planning or gateway proxy tests does not complete outstanding client or live-backend acceptance. Do not merge, tag, archive or activate services during planning.
