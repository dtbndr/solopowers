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

### Workflow

| Skill | Use when... |
|---|---|
| `workstream-brainstorming` | Exploring feature ideas, multi-file changes, or behavior changes that need design |
| `workstream-driven-development` | Executing an approved Workstream Document slice-by-slice |
| `using-git-worktrees` | Starting feature work that needs workspace isolation |
| `finishing-a-development-branch` | Work is complete and you need to merge, PR, or clean up |
| `dispatching-parallel-agents` | Facing 2+ independent tasks with no shared state or sequential dependencies |

### Implementation & Quality

| Skill | Use when... |
|---|---|
| `test-driven-development` | Implementing any feature or bugfix — TDD enforcement |
| `systematic-debugging` | Encountering bugs, test failures, or unexpected behavior |
| `verification-before-completion` | About to claim work is done — run verification commands first |
| `requesting-code-review` | Completing a task and wanting a reviewer check (ad-hoc or non-workstream) |
| `receiving-code-review` | Receiving review feedback — verify before implementing, push back with evidence |

### Meta

| Skill | Use when... |
|---|---|
| `using-solopowers` | Starting any conversation — tells agents which skills to invoke |
| `writing-skills` | Creating new skills, editing existing ones, or verifying skills before deployment |

## Routing Rules

**Feature work, new functionality, or multi-file changes:**
→ `workstream-brainstorming` → `workstream-driven-development`

**Bug fixes, single-file changes, refactors that don't need design:**
→ Work directly. Use `test-driven-development` for implementation discipline.

**Bugs, test failures, unexpected behavior:**
→ `systematic-debugging` before proposing fixes.

**Before claiming completion:**
→ `verification-before-completion` — no completion claims without fresh verification evidence.

**Code review (non-workstream contexts):**
→ `requesting-code-review` to dispatch a reviewer.
→ `receiving-code-review` to handle feedback with technical rigor.

## Superseded Skills

The following upstream skills are replaced by solopowers equivalents:

| Upstream skill | Replaced by |
|---|---|
| `brainstorming` | `workstream-brainstorming` |
| `writing-plans` | _(eliminated — workstream doc replaces separate plans)_ |
| `executing-plans` | `workstream-driven-development` |
| `subagent-driven-development` | `workstream-driven-development` |
| `using-superpowers` | `using-solopowers` |
