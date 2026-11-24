# Harness Dispatch

Part of `solopowers:workstream-driven-development`.

Use the table below to dispatch implementer and reviewer subagents on your harness:

| Harness | Dispatch implementer | Dispatch reviewer |
|---|---|---|
| Pi | built-in `worker` role | built-in `reviewer` role |
| claude-code | `Task` tool with implementer prompt | `Task` tool with reviewer prompt |
| Antigravity | describe the implementation task in natural language; harness spawns dynamically | describe the review task in natural language; harness spawns dynamically |

### Model tiers

Skills say "strongest" (reviewers) and "standard" (workers). Map them per harness:

| Harness | Strongest | Standard |
|---|---|---|
| claude-code | `opus` | `sonnet` |
| Pi | no override documented; state the intended tier in the dispatch text (`reviewer` role default) | no override documented; state the intended tier in the dispatch text (`worker` role default) |
| Antigravity | no tier choice; harness picks the model | harness picks the model |

Where a harness has no tier choice, state the intended tier in the dispatch text and accept the harness default.

### Dispatch core

A subagent may not see this pack's skills, and its role or system prompt may set its own report shape or tell it to escalate unapproved decisions. A path to the template is not enough: workers that were not handed the contract did not follow it. So write the filled implementer prompt to the workspace (`implementer-<slice>-prompt.md`) and put this block, filled in, in every implementer dispatch, resume, and fix-round message. A resumed worker receives only your message, so a resume is never bare.

```
Read first: <prompt file> and <slice brief>; follow solopowers:test-driven-development.
Testing this round: <behavior change: observe RED before editing implementation and save the command and failure excerpt to the report | refactor: before/after evidence, characterization first if uncovered | evidence-only: expected result is no changes>. Full suite before DONE.
Report details to: <report file>.
Decisions: the controller approves slice-level decisions inside the brief. Record each as `Ruling: <decision> — <why> — <cost if wrong>` and continue; escalate only genuine blockers.
Finish with a last line `Status: DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT`, then commits, a one-line test summary, and the report path. This adds to whatever report format you otherwise use.
```

Reviewer dispatches follow the same rule: write the filled reviewer prompt to a file and name it, the review package, and the required `Verdict:` line in the message.

### Empty worker result

A result is empty only when it states no outcome (no `Status:` line and no summary of what was done or why not), updates no report file, and leaves no new commit or working-tree change. A dispatch whose core says `expected result is no changes` is not empty when it reports its findings. Do not advance the fix round on an empty result. Keep any findings it reports, then redispatch once with the dispatch core and the last obstacle the worker hit, if the transcript shows one. If the second result is also empty, stop and hand the slice to the operator with both transcripts' last messages.

### Escalation (subagent needs controller input mid-task)

| Harness | How to escalate |
|---|---|
| Pi | `contact_supervisor` MCP tool |
| claude-code | surface the question in response; controller resumes |
| Antigravity | subagent reports back; controller resumes with answer |
