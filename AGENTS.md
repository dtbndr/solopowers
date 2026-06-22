# AGENTS.md

This file contains information for AI coding agents working on this project.

## Project Overview

**solopowers** is a curated skill pack for solo developer workflows, derived from [obra/superpowers](https://github.com/obra/superpowers). It provides agent skills for workstream-doc-driven development with subagent dispatch.

## Skills

| Skill | Type | Description |
|---|---|---|
| `using-solopowers` | Meta | Skill discovery and routing |
| `workstream-brainstorming` | Original | Feature design exploration |
| `workstream-driven-development` | Original | Slice-by-slice workstream execution |
| `test-driven-development` | Forked | TDD enforcement |
| `using-git-worktrees` | Forked | Git worktree isolation |
| `finishing-a-development-branch` | Forked | Branch completion |
| `verification-before-completion` | Forked | Evidence-before-claims discipline |
| `systematic-debugging` | Forked | Structured debugging methodology |
| `dispatching-parallel-agents` | Forked | Parallel subagent orchestration |
| `writing-skills` | Adapted | Skill creation methodology |
| `requesting-code-review` | Adapted | Ad-hoc code review dispatch |
| `receiving-code-review` | Adapted | Review feedback handling |

## Agent Instructions

- Skills use `solopowers:` namespace for cross-references (e.g., `solopowers:test-driven-development`)
- When adding or modifying skills, follow the TDD-for-skills methodology in `writing-skills`
- Update `using-solopowers/SKILL.md` skill table when adding new skills
- Run `grep -rn "human partner" skills/` to verify no team-dynamics language leaked in
- Keep `README.md` skill table in sync with actual skills

## Upstream

Upstream remote: `https://github.com/obra/superpowers.git`

To pull upstream changes:
```bash
git fetch upstream
git cherry-pick <commit>  # or merge specific files
```

## Install

```bash
npx skills add ~/Development/skills-ws/solopowers      # local
npx skills add https://github.com/dtbndr/solopowers    # GitHub
```
