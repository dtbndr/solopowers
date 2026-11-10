---
name: dispatching-code-review
description: Use when completing tasks, implementing major features, or before merging to verify work meets requirements
---

# Requesting Code Review

**Scope:** This skill is for ad-hoc code reviews outside of workstream slice execution. For slice-level reviews within a workstream, use `workstream-driven-development`'s built-in review mechanism ([workstream-reviewer-prompt.md](../workstream-driven-development/workstream-reviewer-prompt.md)).

Dispatch a code reviewer subagent to catch issues before they cascade. The reviewer gets precisely crafted context for evaluation — never your session's history. This keeps the reviewer focused on the work product, not your thought process, and preserves your own context for continued work.

**Core principle:** Review early, review often.

## When to Request Review

**Mandatory:**

- After each task in workstream-driven-development
- After completing major feature
- Before merge to main

**Optional but valuable:**

- When stuck (fresh perspective)
- Before refactoring (baseline check)
- After fixing complex bug

## How to Request

**1. Get git SHAs:**

```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or: git merge-base origin/main HEAD
HEAD_SHA=$(git rev-parse HEAD)
```

**2. Dispatch code reviewer subagent:**

Dispatch a reviewer subagent, filling the template at [code-reviewer.md](code-reviewer.md). See **Harness Dispatch** below for how to dispatch on your harness.

**Placeholders:**

- `{DESCRIPTION}` - Brief summary of what you built
- `{PLAN_OR_REQUIREMENTS}` - What it should do
- `{BASE_SHA}` - Starting commit
- `{HEAD_SHA}` - Ending commit
- `{SEVERITY_DEFINITIONS}` - P0-P3 definitions (the project's `.memory/*grounding*.md` P0/P1 definitions if present, else the default in `code-reviewer.md`)

**3. Act on feedback:**

- Fix P0 and P1 issues before proceeding
- Note P2/P3 issues for later (in a workstream: log them to the workspace `p2p3.md`)
- Push back if reviewer is wrong (with reasoning)

## Example

```
[Just completed Task 2: Add verification function]

You: Let me request code review before proceeding.

BASE_SHA=$(git log --oneline | grep "Task 1" | head -1 | cut -d' ' -f1)
HEAD_SHA=$(git rev-parse HEAD)

[Dispatch code reviewer subagent]
  DESCRIPTION: Added verifyIndex() and repairIndex() with 4 issue types
  PLAN_OR_REQUIREMENTS: Slice B from docs/workstreams/2026-01-15-deployment/slices.md
  BASE_SHA: a7981ec
  HEAD_SHA: 3df7661

[Subagent returns]:
  Strengths: Clean architecture, real tests
  Issues:
    P1: Missing progress indicators (verify.ts:42, scenario: 10k-file run shows no output)
    P3: Magic number (100) for reporting interval
  Verdict: NEEDS FIXES (1 P0/P1)

You: [Fix progress indicators]
[Continue to Task 3]
```

## Integration with Workflows

**Workstream-Driven Development:**

- Review after EACH task
- Catch issues before they compound
- Fix before moving to next task

**Executing Plans:**

- Review after each task or at natural checkpoints
- Get feedback, apply, continue

**Ad-Hoc Development:**

- Review before merge
- Review when stuck

## Red Flags

**Never:**

- Skip review because "it's simple"
- Ignore P0 issues
- Proceed with unfixed P1 issues
- Argue with valid technical feedback

**If reviewer wrong:**

- Push back with technical reasoning
- Show code/tests that prove it works
- Request clarification

See template at: [code-reviewer.md](code-reviewer.md)

## Harness Dispatch

| Harness | Dispatch reviewer |
|---|---|
| Pi | built-in `reviewer` role |
| kiro-cli | `orchestrate_subagent(role: semantic_reviewer)` |
| claude-code | `Task` tool with reviewer prompt |
| Antigravity | describe the review task in natural language; harness spawns dynamically |
