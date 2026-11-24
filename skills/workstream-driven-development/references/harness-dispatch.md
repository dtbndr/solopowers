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

### Empty worker result

A worker result with no `Status:` line and no new commit or working-tree change is not a slice outcome; do not advance the fix round on it. Keep any findings it reports (for example evidence that a test passes against old code), then redispatch once asking for the Status-line report, and put the full return contract (Status line, commits, test summary, report file path) in the new message together with the last obstacle the worker hit, if the transcript shows one. If the second result is also empty, stop and hand the slice to the operator with both transcripts' last messages.

Resuming an existing worker (Pi `subagent` with `action: "resume"`) sends only your follow-up text; the original prompt survives only as background context, and a bare follow-up has produced a worker that ended without a `Status:` line. Restate the return contract in the resume message.

### Escalation (subagent needs controller input mid-task)

| Harness | How to escalate |
|---|---|
| Pi | `contact_supervisor` MCP tool |
| claude-code | surface the question in response; controller resumes |
| Antigravity | subagent reports back; controller resumes with answer |
