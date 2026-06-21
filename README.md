# solopowers

A curated fork of [obra/superpowers](https://github.com/obra/superpowers) skills, adapted for solo development workflows.

## Skills

| Skill | Description |
|---|---|
| `test-driven-development` | TDD workflow with red→green cycle and testing anti-patterns |
| `tdd` | TDD reference: mocking, refactoring, test structure |
| `using-superpowers` | Meta-skill for discovering and using skills |

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
git cherry-pick <commit>  # or git merge upstream/main -- skills/test-driven-development
```

## Relationship to superpowers

This is a personal derivation, not an official fork. Skills are adapted for:
- Solo developer workflows (no team coordination overhead)
- Workstream-driven development patterns
- Simplified agent dispatch

Upstream changes from `obra/superpowers` can be cherry-picked or merged as needed.
