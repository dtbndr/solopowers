# Contributing to solopowers

Thanks for your interest. solopowers is a curated skill pack for solo developer workflows, derived from [obra/superpowers](https://github.com/obra/superpowers). Contributions are welcome as pull requests from a fork.

## Before you start

Read [`AGENTS.md`](AGENTS.md). It is the source of truth for:

- **Decision Grounding**: the principles that decide what fits this pack (workstream folders, sequential slices, one isolation unit per workstream).
- **Skill Lifecycle** and the `solopowers:` namespace for cross-references.
- **Verification Checklist**: the commands that must pass before you open a PR. Run all of them; the CI check covers only part of the list.

When you add or change a skill, follow the TDD-for-skills method in `skills/authoring-skills`, and update the skill table in `skills/using-solopowers/SKILL.md` if you add a skill.

## Opening a pull request

1. Fork the repository and branch from `main`.
2. Make your change and run the full Verification Checklist from `AGENTS.md`.
3. Add a line under `[Unreleased]` in [`CHANGELOG.md`](CHANGELOG.md) (Added, Changed or Fixed) for any user-visible change.
4. Open the PR and fill in the template.

CI on a pull request from a fork waits for a maintainer to approve the run. Merging needs a passing `verify` check and an approving review from the maintainer.

## Releases

Releases, tags and version numbers are maintainer-only. Do not bump versions or edit release sections of the changelog. The procedure is in the "Releases" section of `AGENTS.md`.
