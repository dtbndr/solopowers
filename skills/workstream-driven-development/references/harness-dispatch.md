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

### Escalation (subagent needs controller input mid-task)

| Harness | How to escalate |
|---|---|
| Pi | `contact_supervisor` MCP tool |
| claude-code | surface the question in response; controller resumes |
| Antigravity | subagent reports back; controller resumes with answer |
