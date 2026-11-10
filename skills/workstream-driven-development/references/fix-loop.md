# The Fix Loop

Part of `solopowers:workstream-driven-development`.

> [!IMPORTANT]
> **Controller Instruction:** You MUST re-read this file (`references/fix-loop.md`) before every fix round. Conversation memory does not survive compaction.

The fix loop is entered when an initial slice review reports spec compliance ❌, `Verdict: NEEDS FIXES` (an open P0/P1), or a confirmed ⚠️ gap; when a user reports a manual smoke-test failure; or when user rulings (`Ruling (user)`) after cap escalation direct code changes.

Before the loop starts, two routes leave it immediately:

- **P2/P3 findings:** Never enter the loop and are not fixed unless the operator asks. Append them to `<folder>/log.md` (one line each, `Slice <ID>: P2: <one-liner>` or `Slice <ID>: P3: <one-liner>`) under a `P2/P3:` entry for the slice. Do not stage `log.md` into a slice or fix commit and do not commit it mid-slice (HEAD must stay at the reviewed head); commit it, explicit path, with the next `log.md` commit, at the latest the final outcome record. The final review gets these lines as carry-forward input and the operator is shown the count. Out-of-scope observations from a re-review are logged the same way.
- **Workstream-mandated findings:** A finding labeled workstream-mandated — or any finding that conflicts with what `brief.md` or `slices.md` requires — is the user's decision, like any workstream contradiction: present the finding and the workstream text to the user and ask which governs. Do not dismiss the finding because the workstream mandates it, and do not dispatch a fix that contradicts the workstream without explicit human guidance.

Everything else enters the loop. A fix round is one fix dispatch plus one scoped re-review. Four rounds maximum per fix series:

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
1. Generate the scoped review package (run `scripts/review-package` by its absolute path, from the working tree you're executing in):
   ```bash
   bash scripts/review-package "$FIX_BASE" "$HEAD" "$WORKSPACE_SLUG" "$WORKSTREAM_FILE"
   ```
   where `FIX_BASE` is the head the previous review saw.
2. Dispatch `re-review-prompt.md` with the findings list, the slice brief, the report file, and the printed diff path.
3. The re-reviewer verdicts each finding ADDRESSED or NOT ADDRESSED and flags new breakage in the fix diff only.
4. New P0/P1 breakage in the fix diff joins the open findings list. New P2/P3 and out-of-scope observations go to `log.md` as above — they never extend the loop.

## Ledger Tracking

After each round, append to `$(bash scripts/wsd-workspace <workspace-slug> WORKSTREAM_FILE)/progress.md`:
```markdown
Slice <ID>: fix round <R>/4 (<X> addressed, <Y> open — <finding one-liners>; commits <a7>..<b7>)
```
`<Y>` counts open P0/P1 findings only.

Never fix findings yourself in the controller session — your context stays clean for coordination, and controller fixes skip review.

## The Breaker (Cap Escalation)

When round 4's re-review still leaves a P0/P1 open, the cap is reached. (P2/P3 never trigger escalation.) Stop dispatching.

Immediately append to the ledger:
```markdown
Slice <ID>: escalated at cap — <Y> open
```

**Escalate to the user:**
Present the user with:
- The remaining open findings and reviewer verdict
- The diff range (`$FIX_BASE..$HEAD`)
- What was tried across the fix rounds
- The specific conflict between the implementation and `brief.md` or `slices.md` (if any)

**DO NOT** let the controller silently park findings or override `brief.md` or `slices.md`. The user makes the call on how to proceed (adjusting `brief.md` or `slices.md`, accepting a trade-off, or providing direct instructions).

When the user decides on each finding, write one ledger line per open finding:
```markdown
Slice <ID>: Ruling (user): <finding> — <decision>
```

- If the user's rulings let the slice stand as-is without code changes, the slice achieves **review clean** (see Success Gate below) with `<head7>` tied to the round-4 `<b7>` commit (from the preceding `fix round 4/4` line).
- If the user's rulings direct a code change, start a fresh 4-round fix series (round 1/4) with `FIX_BASE` anchored to the round-4 `<b7>` commit (from the `fix round 4/4 (...; commits <a7>..<b7>)` line) with the user-directed changes as findings.

## Success Gate: Manual Smoke Test Pause

### Definition of "Review Clean"

A slice achieves **review clean** when:
1. The initial review is `✅ Slice compliant` + `Verdict: CLEAN` (no open P0/P1) with every `⚠️ Cannot verify` item resolved (see [references/cannot-verify.md](cannot-verify.md)), **OR**
2. The latest fix round's scoped re-review ends `Verdict: CLEAN`: every P0/P1 `ADDRESSED`, no new P0/P1 (`0 open`), **OR**
3. Every open P0/P1 at the round-4 cap has a user ruling (`Ruling (user)`) that lets the slice stand.

### Awaiting Smoke Test

Immediately when the slice achieves **review clean** (whether on initial review with 0 fix rounds, after a fix round, or via user rulings), write to `progress.md` *before* pausing for the user's manual smoke test:
```markdown
Slice <ID>: review clean (commits <base7>..<head7>) — awaiting smoke test
```
(where `<base7>` is the commit before this slice began, and `<head7>` is the reviewed head commit: current `HEAD` for initial review, or `<b7>` from the latest `fix round` line; verify `HEAD == <head7>` before pausing).

Then pause and ask the user to perform the manual smoke test for that slice:
- Direct the user to the exact manual smoke test steps in `slices.md`.
- Wait for user confirmation before proceeding to the next slice.

### Smoke Test Outcome

- **If the user confirms the smoke test passed:**
  Immediately append to `progress.md`:
  ```markdown
  Slice <ID>: complete (commits <base7>..<head7>, review clean[, <K> user rulings], smoke test passed)
  ```
  Mark the slice complete in the Todo list, and proceed to the next slice.

- **If the user reports a manual smoke test failure:**
  Append to `progress.md`:
  ```markdown
  Slice <ID>: smoke test failed (at <head7>) — <one-liner>
  ```
  A smoke test failure starts a **fresh 4-round budget** (round 1/4). Set `FIX_BASE` = `<head7>` (the commit at the smoke pause, recorded on the preceding `review clean` line). The user's failure report becomes the findings for the implementer subagent. Run scoped re-review (`bash scripts/review-package "$FIX_BASE" "$HEAD" "$WORKSPACE_SLUG" "$WORKSTREAM_FILE"`), repeating the fix loop until the slice achieves review clean again, followed by another smoke test pause.
