# Project instructions

Use the pinned mise Elixir/OTP and Node/OpenSpec tools. Opsmaru is one Phoenix application and reusable OTP dependency. The portable Incus client is the separate `:opsmaru_incus` library in upmaru/opsmaru-incus, used by Opsmaru and Macus; change it there and pin an immutable revision here, never a sibling path. Keep embedded mode the default: no Opsmaru endpoint, repository, issuer keys or standalone service may start merely because Macus loads the dependency. Standalone mode is explicit.

Incus remains the canonical workload backend. Never implement its workload manager, invoke a host VM CLI or move Apple virtualization into shared code. Host applications supply verified identity and platform adapters. Preserve task ownership, native operation identity and backend data after failures.

Use OpenSpec for substantial behavior changes and validate planning before implementation. Distinguish the generated scaffold, proposed functionality, fixture checks, installed service acceptance and real Incus/Macus hardware acceptance. Do not advertise authentication, protocol support or complete client parity before their respective acceptance passes.

Run `mise trust` and `mise install` for the checkout. Canonical checks are `mise run check` (with a dedicated configured test database) and `mise run spec:validate`. Never run tests against production data or commit ignored `_build`, `deps`, asset build outputs, secrets or integration-state directories.

Use Git Flow: main is released history, develop is integration, feature/* starts from develop, release/* starts from develop and finishes into both branches, and hotfix/* starts from main and finishes into both. Publish development work on its feature branch. Do not finish/merge branches, create release tags or deploy services without user authorization.
