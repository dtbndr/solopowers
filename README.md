# solopowers

A curated skill pack for solo development workflows, derived from [obra/superpowers](https://github.com/obra/superpowers).

## Skills

| Skill | Origin | Description |
|---|---|---|
| `using-solopowers` | Original | Meta-skill for discovering and using skills in this pack |
| `workstream-brainstorming` | Original | Explore feature ideas and design before implementation |
| `workstream-driven-development` | Original | Execute workstream documents slice-by-slice with subagent dispatch |
| `test-driven-development` | [superpowers](https://github.com/obra/superpowers) | TDD workflow: red→green cycle, testing anti-patterns |

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
