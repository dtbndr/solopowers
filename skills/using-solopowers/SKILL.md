---
name: using-solopowers
description: "Use when starting any conversation - establishes how to find and use solopowers skills, requiring skill invocation before ANY response including clarifying questions."
---

# Using Solopowers

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, skip this skill.
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a skill might apply to what you are doing, you ABSOLUTELY MUST invoke the skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. This is not optional. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

## Instruction Priority

Solopowers skills override default system prompt behavior, but **user instructions always take precedence**:

1. **User's explicit instructions** (CLAUDE.md, GEMINI.md, AGENTS.md, direct requests) — highest priority
2. **Solopowers skills** — override default system behavior where they conflict
3. **Default system prompt** — lowest priority

If CLAUDE.md, GEMINI.md, or AGENTS.md says "don't use TDD" and a skill says "always use TDD," follow the user's instructions. The user is in control.

## Skills in this Pack

| Skill | Use when... |
|---|---|
| `workstream-brainstorming` | Exploring feature ideas, multi-file changes, or behavior changes that need design |
| `workstream-driven-development` | Executing an approved Workstream Document slice-by-slice |
| `test-driven-development` | Implementing any feature or bugfix (TDD enforcement) |

## Routing Rules

**Feature work, new functionality, or multi-file changes:**
→ `workstream-brainstorming` → `workstream-driven-development`

**Bug fixes, single-file changes, refactors that don't need design:**
→ Work directly. Use `test-driven-development` for implementation discipline.

## Upstream Skills (from superpowers)

These skills from [obra/superpowers](https://github.com/obra/superpowers) remain useful and can be invoked as needed:

- `systematic-debugging` — When encountering bugs or unexpected behavior
- `verification-before-completion` — Before claiming work is done
- `using-git-worktrees` — For isolated feature work
- `finishing-a-development-branch` — For branch completion decisions
- `requesting-code-review` / `receiving-code-review` — For code review workflows
- `dispatching-parallel-agents` — For parallel independent tasks
- `frontend-design` — For UI/UX design decisions

## Superseded Skills

The following upstream skills are replaced by solopowers equivalents:

| Upstream skill | Replaced by |
|---|---|
| `brainstorming` | `workstream-brainstorming` |
| `writing-plans` | _(eliminated — workstream doc replaces separate plans)_ |
| `executing-plans` | `workstream-driven-development` |
| `subagent-driven-development` | `workstream-driven-development` |
| `using-superpowers` | `using-solopowers` |
