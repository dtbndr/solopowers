# Harness Dispatch

Part of `solopowers:workstream-driven-development`.

Use the table below to dispatch implementer and reviewer subagents on your harness:

| Harness | Dispatch implementer | Dispatch reviewer |
|---|---|---|
| Pi | default agent `worker` (see Pi agent names) | default agent `reviewer` (see Pi agent names) |
| claude-code | `Task` tool with implementer prompt | `Task` tool with reviewer prompt |
| Antigravity | describe the implementation task in natural language; harness spawns dynamically | describe the review task in natural language; harness spawns dynamically |

### Pi agent names

Agent names belong to the `pi-subagents` extension and can change between its releases. Treat every Pi name in this pack as a **default to validate**, never as a contract.

- Solopowers role names (`implementer`, `reviewer` prompt roles, `document-writer`, `document-reviewer`, `builder-check`) are never `agent:` values. Pass an agent that exists in `pi-subagents`, and put the role's prompt in the task text.
- Once per session, before the first Pi dispatch, run `subagent({ action: "list", options: { capabilities: true } })` and confirm each default you need is listed with the capability the role requires:

| Role | Default agent | Required capability | Context |
|---|---|---|---|
| implementer, ad-hoc worker | `worker` | writer (edit/write/bash) | `fresh` |
| reviewer, document-reviewer, builder-check | `reviewer` | read-only | `fresh` |
| document-writer | `delegate` | writer (edit/write/bash) | `fork` |
| scout (recon) | `scout` | read-only recon | `fresh` |

- If a default is missing or lacks the capability, stop and ask the operator. Recommend the best listed candidate with a one-line reason; do not pick one silently. Never route to an external-CLI agent (`agy`, `codex-exec*`, `cursor-agent*`, `claude-code*`) unless the operator chose it.
- On `Unknown agent`, do not parse the error's candidate list (it can be filtered). Re-run `action: "list"`, then follow the previous bullet. Retry once, with a name the operator confirmed.
- Pi agents here run with `inheritSkills: false`: put the full prompt in the dispatch text, not a pointer to a skill.

### Model tiers

Skills say "strongest" (reviewers) and "standard" (workers). Map them per harness:

| Harness | Strongest | Standard |
|---|---|---|
| claude-code | `opus` | `sonnet` |
| Pi | no override documented; state the intended tier in the dispatch text (`reviewer` role default) | no override documented; state the intended tier in the dispatch text (`worker` role default) |
| Antigravity | no tier choice; harness picks the model | harness picks the model |

Where a harness has no tier choice, state the intended tier in the dispatch text and accept the harness default.

### Dispatch core

A running controller session keeps following the skill text it loaded at its start. If the operator says the pack was updated mid-session, re-read `SKILL.md`, this file, and any other reference before its next use, or restart the controller session.

A subagent may not see this pack's skills, and its role or system prompt may set its own report shape or tell it to escalate unapproved decisions. A path to the template is not enough: workers that were not handed the contract did not follow it. So write the filled implementer prompt to `<workspace>/implementer-<ID>-prompt.md` (also when it is absent on resume of an older workstream) and put this block, filled in, in every implementer dispatch, resume (a follow-up message to a live worker), and fix-round message. A resumed worker receives only your message, so a resume is never bare.

```
Read first (if not already read this session): <prompt file> and <slice brief>; follow solopowers:test-driven-development.
Testing this round: <behavior change: observe a behavioral RED before editing implementation (an error or load failure is not RED) and save the command and failure excerpt to the report; for a new module or export, several contracts, or work taken over, follow `red-evidence.md` in `solopowers:test-driven-development` | refactor: before/after evidence, characterization first if uncovered | mixed: both | evidence-only: no code changes or commits; record findings in the report>. Full suite before DONE.
Report details to: <report file>.
Decisions: the controller approves in advance any decision within this slice's scope that the brief, objective and code leave open. Record each as `Ruling: <decision> — <why> — <cost if wrong>` and continue; escalate only blockers (cross-slice architecture conflict, missing out-of-scope information, a test loop you cannot break).
End your final message with this block: commits, a one-line test summary, the report path, and as the very last line `Status: DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT`. This adds to any report format you otherwise use.
```

For end-smoke, final-review and verification-repair fixes: `Read first:` names the filled prompt (`<workspace>/implementer-end-smoke-prompt.md`, `-final-prompt.md` or `-verify-prompt.md`), the findings file (`end-smoke-findings.md` or the final-review findings) and `brief.md`'s acceptance boundary; `Report details to:` names your designated section of `end-smoke-report.md` (do not edit controller records); testing is covering tests for the failed check, then the full suite before DONE.

Reviewer dispatches follow the same rule: write the filled reviewer prompt to a file and name it, the review package, and the required `Verdict:` line in the message ([reviewer-prompts.md](reviewer-prompts.md)).

### Empty worker result

A result is empty only when it states no outcome (no `Status:` line and no summary of what was done or why not), updates no report file, and leaves no new commit or working-tree change. A dispatch whose core says `evidence-only` is not empty when it reports its findings. A non-empty result without a `Status:` line is classified by the controller from its stated outcome, report and diff: DONE when the report holds the evidence this round's testing line requires; DONE_WITH_CONCERNS when it also names open risks or doubts; otherwise BLOCKED or NEEDS_CONTEXT with the stated obstacle. Record the inferred status in the report as a controller record and route it per [handling-reports.md](handling-reports.md); do not redispatch only to obtain the Status line. Do not advance the fix round on an empty result. Keep any findings the empty result reports, then redispatch once with the dispatch core and the last obstacle the worker hit, if the transcript shows one. If the second result is also empty, stop and hand the slice to the operator with both transcripts' last messages.

### Escalation (subagent needs controller input mid-task)

| Harness | How to escalate |
|---|---|
| Pi | `contact_supervisor` MCP tool |
| claude-code | surface the question in response; controller resumes |
| Antigravity | subagent reports back; controller resumes with answer |
