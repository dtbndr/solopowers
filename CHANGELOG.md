# Changelog

All notable changes to this project are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning follows [SemVer](https://semver.org/) (see "Releases" in AGENTS.md).

## [Unreleased]

## [3.1.0] - 2026-11-24

### Changed

- `workstream-driven-development`: every implementer dispatch, resume and fix-round message now carries a short **dispatch core** (prompt and brief paths, this round's testing rule, report path, pre-approved slice-level `Ruling:`s, and a closing `Status:` line). In a session audit only 11 of 138 workers read the implementer template, and every `Status:` line came from those workers; a harness role may also replace the system prompt, set its own report shape, or tell workers to escalate. The core adds to those instructions instead of overriding them. Reviewer dispatches follow the same rule.
- The empty-worker-result rule from 3.0.4 is superseded: a result is empty only when it states no outcome, updates no report and leaves no change, and dispatches that expect no change are exempt.
- A fix that landed without RED is no longer sent back for after-the-fact RED; fix-round dispatches ask for RED before the edit, and nondeterministic race or crash tests that cannot be reconstructed go to the `cannot-verify` escalation rung.

## [3.0.4] - 2026-11-24

### Fixed

- `workstream-driven-development`: an implementer that hit a retryable tool error (for example a refused ambiguous edit) could end its turn with an "incomplete" summary and no `Status:` line, which the controller saw as a worker that stopped without changes. The implementer prompt now treats such errors as obstacles to retry (BLOCKED only after real attempts, always ending with the Status line), and `harness-dispatch.md` tells the controller to redispatch once on a statusless, change-free result and to restate the return contract when resuming a Pi worker.

## [3.0.3] - 2026-11-24

### Fixed

- `workstream-driven-development`: the unrecoverable-RED ladder no longer accepts a load or import error as attested RED; recovery records now go to `report.md` so reviewers see them, `fix-loop.md` no longer redispatches already-resolved evidence items, and resume ignores leftover detached scratch worktrees.

## [3.0.2] - 2026-11-24

### Fixed

- `workstream-driven-development`: a slice whose historical RED output was no longer recoverable no longer stalls the workstream. The `cannot-verify` reference now gives a recovery ladder (attested record, then independently reconstructed RED, then escalation with a recommendation; reviewers accept a recorded `reconstructed RED` line), and implementers must save the RED command and failure excerpt to the report as they observe it.

## [3.0.1] - 2026-11-23

### Fixed

- Update the README to reflect current workstream review and smoke guidance, upstream fetch configuration, and the v3 upgrade caveat.

## [3.0.0] - 2026-11-23

### Breaking

- An interrupted final-review fix wave created by an earlier release may lack the dispatch-continuation evidence now required for automatic resume. Finish such workstreams on `v2.0.2` before upgrading, or expect an operator handoff instead of automatic re-review.

### Changed

- Size independently verifiable slices using behavioral complexity, context, dependencies, uncertainty and verification burden rather than a fixed file-count target.
- Apply proportional, risk-aware TDD: preserve meaningful pre-edit RED for behavior changes and use baseline and characterization evidence for refactors.
- Clarify review evidence, exact-range tracking, final verification and smoke recovery, including retry caps, named waivers and conservative handling of ambiguous history.

## [2.0.2] - 2026-11-12

### Fixed

- `workstream-brainstorming`: the external reviewer prompt now defines `Workstream-SHA256` as the SHA-256 of `<brief-blob-oid>\n<slices-blob-oid>\n` (with the `printf … | shasum -a 256` recipe), matching `references/external-review.md` and the package script, instead of the ambiguous "brief bytes then slices bytes".

## [2.0.1] - 2026-11-11

### Changed

- `LICENSE`: 2026 copyright holder is now the maintainer's legal name (upstream's notice unchanged).
- README: the pinned install example now uses `v2.0.0`.

## [2.0.0] - 2026-11-11

### Added

- MIT `LICENSE`, preserving upstream's copyright notice (obra/superpowers, Copyright (c) 2025 Jesse Vincent).

### Removed

- kiro-cli harness support: dropped its rows from the dispatch tables (Pi, claude-code and Antigravity remain). **Breaking for kiro-cli users**; pin `v1.0.0` to keep it.

## [1.0.0] - 2026-11-11

Baseline release, summarising the state at first tagging:

- Workstream folders (`brief.md`, `slices.md`, `log.md`) as the single planning artifact, with sequential slice-based execution and one isolation unit (branch or worktree) per workstream.
- P0/P1 review loops, with reviews on the strongest model tier.
- A single human smoke test at the end of the workstream, limited to P0/P1 checks agents cannot perform.
- Opt-in `workstream-brainstorming`, including external review and session decisions swept into the writer's input.
- Platform dispatch tables for Pi, kiro-cli, claude-code and Antigravity.

To cut a release, follow "Releases" in AGENTS.md.
