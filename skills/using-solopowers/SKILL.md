---
name: using-solopowers
description: "Use when starting any conversation - establishes how to find and use solopowers skills, requiring skill invocation before ANY response including clarifying questions."
---

# Using Solopowers

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, skip this skill.
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
If there is even a 1% chance a skill applies, you MUST invoke it. No exceptions, no rationalizations.
</EXTREMELY-IMPORTANT>

## Instruction Priority

**User instructions take precedence over skills, which override default behavior.** Only skip skill workflows when the user has explicitly told you to. User instructions include explicit instruction files and direct requests.

## Red Flags

These thoughts mean STOP—you're rationalizing:

| Thought | Reality |
|---------|---------|
| "This is just a simple question" | Questions are tasks. Check for skills. |
| "I need more context first" | Skill check comes BEFORE clarifying questions. |
| "Let me explore the codebase first" | Skills tell you HOW to explore. Check first. |
| "This doesn't need a formal skill" | If a skill exists, use it. |
| "I remember this skill" | Skills evolve. Read current version. |
| "The skill is overkill" | Simple things become complex. Use it. |
| "I'll just do this one thing first" | Check BEFORE doing anything. |

## Routing

**Feature work, multi-file changes** → `workstream-brainstorming` → `workstream-driven-development`

The workstream model has four non-negotiable invariants: one canonical Workstream Document (no separate spec/plan artifacts), strictly sequential slice execution (one at a time, never parallel), one worktree per full workstream (not per slice), and a mandatory manual smoke-test pause after every review-approved slice before advancing.

**Bug fixes, single-file changes** → work directly with `test-driven-development`.

**Bugs, test failures, unexpected behavior** → `systematic-debugging` before proposing fixes.

**Before claiming completion** → `verification-before-completion`.

**Code review (non-workstream contexts)** → `dispatching-code-review`, then `handling-review-feedback`.

## Skills

### Workflow

| Skill | Use when... |
|---|---|
| `workstream-brainstorming` | Multi-file changes or behavior changes that need design |
| `workstream-driven-development` | Executing an approved Workstream Document slice-by-slice |
| `using-git-worktrees` | Starting feature work that needs workspace isolation |
| `finishing-a-development-branch` | Work is complete and you need to merge, PR, or clean up |
| `dispatching-parallel-agents` | Facing 2+ independent tasks with no shared state |

### Implementation & Quality

| Skill | Use when... |
|---|---|
| `test-driven-development` | Implementing any feature or bugfix |
| `systematic-debugging` | Bugs, test failures, or unexpected behavior |
| `verification-before-completion` | About to claim work is done |
| `dispatching-code-review` | Completing a task and wanting a reviewer check |
| `handling-review-feedback` | Receiving review feedback |

### Meta

| Skill | Use when... |
|---|---|
| `using-solopowers` | Starting any conversation |
| `authoring-skills` | Creating or editing skills |

## Superseded Skills

| Upstream skill | Replaced by |
|---|---|
| `brainstorming` | `workstream-brainstorming` |
| `writing-plans` | _(eliminated — workstream doc replaces separate plans)_ |
| `executing-plans` | `workstream-driven-development` |
| `subagent-driven-development` | `workstream-driven-development` |
| `using-superpowers` | `using-solopowers` |
