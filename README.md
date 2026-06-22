# solopowers

A curated skill pack for solo development workflows, derived from [obra/superpowers](https://github.com/obra/superpowers).

## Origin

solopowers began as local adaptations of superpowers for a workflow where **a single workstream document** replaces the spec + plan artifact model (`docs/superpowers/specs`, `docs/superpowers/plans`). Work is split into sequential slices, executed in one git worktree per workstream, with **manual smoke-test pauses** between slices after automated review gates pass. What started as project-local skill overrides later became this standalone project for identity and lifecycle management.

## Skills

### Workflow

| Skill | Origin | Description |
|---|---|---|
| `workstream-brainstorming` | Original | Explore feature ideas and design before implementation |
| `workstream-driven-development` | Original | Execute workstream documents slice-by-slice with subagent dispatch |
| `using-git-worktrees` | [superpowers](https://github.com/obra/superpowers) | Isolated git worktrees for feature work |
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

## Install

```bash
# From local path
npx skills add ~/Development/skills-ws/solopowers

# From GitHub (after pushing)
npx skills add https://github.com/dtbndr/solopowers
```

## Pulling upstream changes

```bash
git remote add upstream https://github.com/obra/superpowers.git
git fetch upstream
# Cherry-pick specific changes from superpowers
git cherry-pick <commit>
```

## Relationship to superpowers

This is a personal derivation, not an official fork. Skills are adapted for:

- Solo developer workflows (no team coordination overhead)
- Workstream-driven development patterns
- Simplified agent dispatch

Upstream changes from `obra/superpowers` can be cherry-picked or merged as needed.
