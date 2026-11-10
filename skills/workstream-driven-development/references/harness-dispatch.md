# Harness Dispatch

Part of `solopowers:workstream-driven-development`.

Use the table below to dispatch implementer and reviewer subagents on your harness:

| Harness | Dispatch implementer | Dispatch reviewer |
|---|---|---|
| Pi | built-in `worker` role | built-in `reviewer` role |
| kiro-cli | `orchestrate_subagent(role: general-task-execution)` | `orchestrate_subagent(role: semantic_reviewer)` |
| claude-code | `Task` tool with implementer prompt | `Task` tool with reviewer prompt |
| Antigravity | describe the implementation task in natural language; harness spawns dynamically | describe the review task in natural language; harness spawns dynamically |

### Escalation (subagent needs controller input mid-task)

| Harness | How to escalate |
|---|---|
| Pi | `contact_supervisor` MCP tool |
| kiro-cli | surface the question in response; controller resumes |
| claude-code | surface the question in response; controller resumes |
| Antigravity | subagent reports back; controller resumes with answer |
