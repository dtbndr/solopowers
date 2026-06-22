# AGENTS.md

This file contains information for AI coding agents working on this project.

## Project Overview

**solopowers** is a curated skill pack for solo developer workflows, derived from [obra/superpowers](https://github.com/obra/superpowers). It provides agent skills for workstream-doc-driven development with subagent dispatch.

## Directory Structure

```
skills/
  <skill-name>/
    SKILL.md              # Main skill file (required)
    *.md                  # Supporting docs (optional)
    scripts/              # Executable helpers (optional)
```

Each skill lives in its own directory under `skills/`. The `SKILL.md` frontmatter (`name`, `description`) drives skill discovery.

## Skill Lifecycle

When incorporating a superpowers skill, decide one of three fates:

| Fate | When | Action |
|---|---|---|
| **Fork as-is** | Skill is useful and needs no structural changes | Copy, update "human partner" refs, done |
| **Adapt** | Skill is useful but needs solo/workstream modifications | Copy, make targeted edits, verify |
| **Eliminate** | Skill doesn't apply to solo workflows | Don't include, document why in research/ |

Document decisions in `research/` (gitignored, local only).

## Hard Dependencies

`workstream-driven-development` explicitly references these skills by name:

- `using-git-worktrees` — called at workstream start
- `finishing-a-development-branch` — called at workstream end

Changes to these skills have downstream impact on WSD. Verify compatibility before modifying.

## Agent Instructions

- Skills use `solopowers:` namespace for cross-references (e.g., `solopowers:test-driven-development`)
- When adding or modifying skills, follow the TDD-for-skills methodology in `writing-skills`
- Update `using-solopowers/SKILL.md` skill table when adding new skills

### Verification Checklist

Run before committing skill changes:

```bash
grep -rn "human partner" skills/        # must be 0
grep -rn "superpowers:" skills/         # must be 0 (unless intentionally referencing upstream)
diff <(ls skills/) <(grep '|' skills/using-solopowers/SKILL.md | awk '{print $2}' | sort)
```

The last command verifies the skill table in `using-solopowers` matches the actual skill directories.
