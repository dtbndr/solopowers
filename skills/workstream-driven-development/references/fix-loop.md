# The Fix Loop

Part of `solopowers:workstream-driven-development`.

> [!IMPORTANT]
> **Controller Instruction:** You MUST re-read this file (`references/fix-loop.md`) before every fix round. Conversation memory does not survive compaction.

The slice review reported spec compliance ❌, slice quality Needs fixes, a Critical or Important finding, or a ⚠️ item you confirmed as a real gap.

Before the loop starts, two routes leave it immediately:

- **Minor findings:** Record Minor findings in the progress ledger as you go (`Slice <ID>: minor (deferred): <one-liner>`), and point the final whole-workstream review at that list so it can triage which must be fixed before merge. A roll-up nobody reads is a silent discard. Minor findings never enter the loop.
- **Workstream-mandated findings:** A finding labeled workstream-mandated — or any finding that conflicts with what the Workstream Document's text requires — is the user's decision, like any workstream contradiction: present the finding and the workstream text to the user and ask which governs. Do not dismiss the finding because the workstream mandates it, and do not dispatch a fix that contradicts the workstream without explicit human guidance.

Everything else enters the loop. A fix round is one fix dispatch plus one scoped re-review. Four rounds maximum per slice:

## Rounds and Dispatch

**Rounds 1-3 — resume the original implementer.** Send it the open findings verbatim. Its context is intact: it knows the slice, the code, and its own choices. If your harness cannot send another message to a live subagent, dispatch a fresh implementer carrying the slice brief path, the report-file path, and the findings — the report file is the persistent memory either way.

**Round 4 — dispatch a fresh implementer on a more capable model** (per SKILL.md's Model Selection), with the slice brief path, the report-file path, the open findings, and this framing: "A prior implementer attempted this slice 3 times; you own it now. Read the report file for what was tried." Also dispatch fresh if the implementer is stuck or context-polluted. A loop that survives three resumes usually means the implementer cannot see its own problem — fresh eyes and a capability bump in one move.

## Every Round: Fix & Test Contract

Every round, either way:
- The implementer fixes the code, commits, re-runs the tests covering the amended code, appends its fix report to the same report file, and returns the short contract.
- **Test execution rule:** Run covering tests per fix round; run the full repository test suite before reporting slice DONE and before final workstream review.
- Before re-dispatching the reviewer, confirm the fix report contains the covering tests, the command run, and the output; dispatch the re-review once all three are present. Name the covering test files in the fix message — a one-line fix does not need the whole suite.

## Scoped Re-Review

The re-review is scoped to the fix diff:
1. Generate the scoped review package:
   ```bash
   bash scripts/review-package "$FIX_BASE" "$HEAD" "$WORKSPACE_SLUG" "$WORKSTREAM_FILE"
   ```
   where `FIX_BASE` is the head the previous review saw.
2. Dispatch `re-review-prompt.md` with the findings list, the slice brief, the report file, and the printed diff path.
3. The re-reviewer verdicts each finding ADDRESSED or NOT ADDRESSED and flags new breakage in the fix diff only.
4. New Critical/Important breakage in the fix diff joins the open findings list. Out-of-scope observations go to the ledger as deferred minors — they never extend the loop.

## Ledger Tracking

After each round, append to `$(bash scripts/wsd-workspace <workspace-slug> WORKSTREAM_FILE)/progress.md`:
```markdown
Slice <ID>: fix round <R>/4 (<X> addressed, <Y> open — <finding one-liners>; commits <a7>..<b7>)
```

Never fix findings yourself in the controller session — your context stays clean for coordination, and controller fixes skip review.

## The Breaker (Cap Escalation)

When round 4's re-review still leaves findings open, the cap is reached. Stop dispatching.

**Escalate to the user:**
Present the user with:
- The remaining open findings and reviewer verdict
- The diff range (`$FIX_BASE..$HEAD`)
- What was tried across the fix rounds
- The specific conflict between the implementation and the Workstream Document (if any)

**DO NOT** let the controller silently park findings or override the Workstream Document. The user makes the call on how to proceed (adjusting the Workstream Document, accepting a trade-off, or providing direct instructions).

## Success Gate: Manual Smoke Test Pause

Once all findings are resolved and the reviewer reports both spec compliance ✅ and slice quality Approved, you MUST pause and ask the user to perform the manual smoke test for that slice:
- Direct the user to the exact manual smoke test steps in the Workstream Document.
- Wait for user confirmation before proceeding to the next slice.
