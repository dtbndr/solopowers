# solopowers

A curated skill pack for solo development workflows, derived from [obra/superpowers](https://github.com/obra/superpowers).

## Origin

solopowers began as local adaptations of superpowers for a workflow where **a single workstream folder** (`brief.md`, `slices.md`, `log.md`) replaces the spec + plan artifact model (`docs/superpowers/specs`, `docs/superpowers/plans`). Work is split into sequential slices, executed in one isolation unit per workstream (a git branch or worktree, the operator's choice), with a single end-of-workstream human smoke phase for the P0/P1 checks agents cannot do, after Final verification passes and before final review. What started as project-local skill overrides later became this standalone project for identity and lifecycle management.

Workstream folders are stored at `docs/workstreams/YYYY-MM-DD-<topic>/`. `workstream-brainstorming` creates the folder; `workstream-driven-development` executes it sequentially in one branch or worktree.

### What changed vs the original workflow

- `brief.md` (about one page) is the only file the operator approves; `slices.md` and `log.md` are agent-facing.
- The operator picks a git branch or a worktree once per workstream.
- Slice reviewers grade findings P0-P3 with evidence. Confirmed spec gaps require action, and unresolved evidence blocks completion, except an unrecoverable historical RED, which is logged as a `RED gap` for later triage. P2/P3 findings are logged and not fixed unless the operator asks. The loop has a 4-round cap; missing evidence alone does not trigger a code-fix round.
- No per-slice smoke pause: one end-of-workstream human smoke phase follows passing Final verification and precedes final review. It covers only P0/P1 checks agents cannot do, and is skipped if none remain.
- Strongest-tier review and standard-tier implementation are the intended model policy, subject to model selection in each harness. Dispatch sections document or link to the mechanism. Brainstorming playback and external review are opt-in (the agent recommends, the operator chooses); external review targets a package anchored to committed `brief.md` and `slices.md`, excluding `log.md`.

## Skills

### Workflow

| Skill | Origin | Description |
|---|---|---|
| `workstream-brainstorming` | Original | Explore feature ideas and design before implementation |
| `workstream-driven-development` | Original | Execute workstream folders slice-by-slice with subagent dispatch |
| `using-git-worktrees` | [superpowers](https://github.com/obra/superpowers) | Isolated git worktrees for feature work (used when the operator chooses a worktree) |
| `finishing-a-development-branch` | [superpowers](https://github.com/obra/superpowers) | Structured merge/PR/cleanup branch completion |
| `dispatching-parallel-agents` | [superpowers](https://github.com/obra/superpowers) | Run multiple independent subagents concurrently |

### Implementation & Quality

| Skill | Origin | Description |
|---|---|---|
| `test-driven-development` | [superpowers](https://github.com/obra/superpowers) | TDD workflow: red→green cycle, testing anti-patterns |
| `systematic-debugging` | [superpowers](https://github.com/obra/superpowers) | Root-cause-first debugging methodology |
| `verification-before-completion` | [superpowers](https://github.com/obra/superpowers) | Evidence before claims — run verification before declaring done |
| `dispatching-code-review` | [superpowers](https://github.com/obra/superpowers) | Dispatch reviewer subagents for ad-hoc code review |
| `handling-review-feedback` | [superpowers](https://github.com/obra/superpowers) | Handle review feedback with rigor, not performative agreement |

### Meta

| Skill | Origin | Description |
|---|---|---|
| `using-solopowers` | Original | Meta-skill for discovering and using skills in this pack |
| `authoring-skills` | [superpowers](https://github.com/obra/superpowers) | Create, edit, and verify skills before deployment |

## Repository layout

```text
skills/<skill-name>/SKILL.md  # Skill definitions, with supporting docs/scripts as needed
tests/                        # Skill validation scripts
AGENTS.md, CLAUDE.md          # Agent guidance
```

## Install

```bash
# From local path
npx skills add ~/Development/skills-ws/solopowers

# From GitHub (tracks main)
npx skills add https://github.com/dtbndr/solopowers

# Pinned to a release; replace vX.Y.Z with a tag
npx skills add dtbndr/solopowers@vX.Y.Z
```

Unpinned installs track `main`; pin a tag for a stable version. See [Releases](https://github.com/dtbndr/solopowers/releases) for available tags. For workstreams with an interrupted final-review fix wave from any pre-v3 release, finish the wave on `v2.0.2` before upgrading; otherwise expect an operator handoff rather than automatic re-review. See the [3.0.0 changelog entry](CHANGELOG.md#300---2026-11-23).

After updating the pack, start a new controller session (or have it re-read `workstream-driven-development/SKILL.md` and every reference file before it next uses it). A session that began earlier keeps following the older text.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT, see [LICENSE](LICENSE). Includes work from [obra/superpowers](https://github.com/obra/superpowers), Copyright (c) 2025 Jesse Vincent.

## Agent Dispatch

solopowers dispatch skills include a platform routing table for Pi, claude-code, and Antigravity. Each dispatch-bearing skill (e.g., `workstream-driven-development`, `dispatching-parallel-agents`, `dispatching-code-review`, `workstream-brainstorming`) contains a dispatch section (named `## Harness Dispatch` or `## Platform-Specific Subagent Dispatch` depending on the skill) documenting or linking to the concrete dispatch mechanism for your platform. No custom agent definitions or bridge skills are needed.

## Pulling upstream changes

```bash
git remote add upstream https://github.com/obra/superpowers.git
git config remote.upstream.tagOpt --no-tags
git fetch --no-tags upstream
# Port per AGENTS.md "Skill Lifecycle" (fork/adapt/eliminate); cherry-pick only fork-as-is changes
git cherry-pick <commit>
```

## Relationship to superpowers

This is a personal derivation, not an official fork. Skills are adapted for:

- Solo developer workflows (no team coordination overhead)
- Workstream-driven development patterns
- Simplified agent dispatch

Upstream changes from `obra/superpowers` can be cherry-picked (fork-as-is) or ported per the Skill Lifecycle in `AGENTS.md`.
