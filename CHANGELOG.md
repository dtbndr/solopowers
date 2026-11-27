# Changelog

All notable changes to this project are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning follows [SemVer](https://semver.org/) (see "Releases" in AGENTS.md).

## [Unreleased]

### Fixed

- Pi dispatch no longer breaks when `pi-subagents` agent names change or when a role name such as `document-writer` is passed as `agent:`. `harness-dispatch.md` gains a "Pi agent names" section: Pi names are defaults validated once per session with `subagent({ action: "list", options: { capabilities: true } })`, role names are never agent names, and a missing default stops for an operator choice.
- Pi document review uses `reviewer` (was `oracle`), matching the other dispatch tables. On Pi the code reviewer never runs git: the controller attaches the diff as a file.

### Changed

- Pi model tiers use the per-call `model` parameter. Before the session's first Pi dispatch, the operator confirms both models in one question: the agent recommends the strongest and the standard model with a one-line reason each. On a WSD first run this is the same turn as the isolation choice; on a resume it comes before the first dispatch on that resume (`resuming.md` step 0); in brainstorming it comes before the document-writer. A review never runs without a confirmed strongest model; the standard model falls back to the agent default only if the operator declines. The question is never asked between slices.

## [3.2.0] - 2026-11-27

### Changed

- `workstream-driven-development`: an unrecoverable historical RED no longer stops the workstream for an operator decision. When neither rung 1 nor the rung-2 reconstruction works, rung 3 now logs a `RED gap` (with the rung-2 attempt, meaning its command and observed output, why it failed, the worker-attested account and GREEN at the tip) in a separate gitignored `red-gaps.md`, proceeds only when the slice is GREEN at the tip and the full suite passes (a gap logged before review is still subject to that review), and finish records it under a `RED gaps:` entry in `log.md` with its own count, apart from P2/P3. Reviewers treat the line as a disposed evidence gap and still review the code and tests on their merits; the final reviewer does not raise a P0/P1 for the missing RED alone.
- `test-driven-development`: the WSD exception for a fix that landed without RED now says the controller logs a RED gap for triage at finish, instead of the operator deciding.
- `workstream-brainstorming`: the `log.md` contract (SKILL.md and the folder template) lists the new `RED gaps:` entry among what the execution skill appends.

### Fixed

- `handling-reports.md` step 0 no longer reads as banning a rung-2 reconstruction dispatch: it says not to ask a worker to recall a RED it did not save, and to run the reconstruction instead.
- The dispatch core's testing line now points to `red-evidence.md`, so workers that only get the dispatch core still reach the stub, one-test-per-contract and saved-RED rules.

## [3.1.2] - 2026-11-27

### Fixed

- Implementation workers frequently missed a valid RED. A session audit of one project found workers turning a missing-module load error into an assertion (`try { await import() } catch {}` plus `assert.ok(mod)`), hiding several contracts behind one failing assertion, rewriting tests after the failure so the saved output no longer matched them, and taking over uncommitted implementation. New `test-driven-development/red-evidence.md` (linked from the skill and the implementer prompt) sets RED against a compiling stub, an outcome assertion (plus a positive control where an allowed path exists) for every "never does X" test, one test per contract, raw RED output saved to a file before the implementation edit, and reset-and-rerun when tests change after RED. `workstream-driven-development/references/handling-reports.md` now has the controller route an invalid first RED to the reconstructed-RED rung before review and brief takeover workers to set partial implementation aside, record RED, then restore it.

## [3.1.1] - 2026-11-24

### Fixed

- Slice sizing: `workstream-brainstorming` (sizing principles, folder template, document-reviewer prompt) and the `workstream-driven-development` pre-flight scan now treat a slice that bundles several independent contracts, each needing its own failing test and review, as oversized, so it is split before dispatch and not after workers stall.
- A controller session keeps following the skill text it loaded at its start. `harness-dispatch.md` and the README now say to re-read `SKILL.md` and the reference files before their next use, or restart the controller session, after the pack is updated mid-session.

## [3.1.0] - 2026-11-24

### Changed

- `workstream-driven-development`: every implementer dispatch, resume and fix-round message now carries a short **dispatch core** (prompt and brief paths, this round's testing rule, report path, pre-approved slice-level `Ruling:`s, and a closing `Status:` line). In a session audit only 11 of 138 workers read the implementer template, and every `Status:` line came from those workers; a harness role may also replace the system prompt, set its own report shape, or tell workers to escalate. The core adds to those instructions instead of overriding them. Reviewer dispatches follow the same rule. The implementer prompt now pre-approves slice-level decisions and ends its report with the `Status:` line even when another instruction sets the report format.
- The empty-worker-result rule from 3.0.4 is superseded: a result is empty only when it states no outcome, updates no report and leaves no change, and dispatches that expect no change are exempt. A non-empty result without a `Status:` line is classified by the controller and not redispatched.
- A fix that landed without RED is no longer sent back for after-the-fact RED; fix-round dispatches ask for RED before the edit. For a fix that landed without RED, the `cannot-verify` ladder applies: a reconstructed RED (from the round's `FIX_BASE`) is the standard and the operator decides at the escalation rung, as does a nondeterministic race or crash test that cannot be reconstructed. `test-driven-development` notes this mapping.
- Reviewer dispatches write the filled prompt to a workspace file and name it with the `Verdict:` requirement (`reviewer-prompts.md`).

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
