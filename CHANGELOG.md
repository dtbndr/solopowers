# Changelog

All notable changes to this project are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning follows [SemVer](https://semver.org/) (see "Releases" in AGENTS.md).

## [Unreleased]

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
