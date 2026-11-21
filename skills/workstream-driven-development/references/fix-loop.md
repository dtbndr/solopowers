# The Fix Loop

For Final verification failures, use the tracked non-waivable recovery path in [Final Verification Blocker](verification-blocker.md); do not route them through smoke findings or waivers.

Part of `solopowers:workstream-driven-development`.

> [!IMPORTANT]
> **Controller Instruction:** You MUST re-read this file (`references/fix-loop.md`) before every fix round. Conversation memory does not survive compaction.

The fix loop is entered when an initial slice review reports spec compliance ❌, `Verdict: NEEDS FIXES` (an open P0/P1), or a confirmed ⚠️ gap; when an end-smoke check fails ([end-smoke.md](end-smoke.md)); or when user rulings (`Ruling (user)`) after cap escalation direct code changes. Missing evidence alone is handled through the existing `⚠️ Cannot verify` route: obtain credible evidence from the implementer or verify it directly before completion. If a reported requirement is confirmed missing, treat it as a spec gap and use the normal findings route. Never fabricate unrecorded RED.

Before the loop starts, two routes leave it immediately:

- **P2/P3 findings:** Never enter the loop and are not fixed unless the operator asks. The controller appends them to the gitignored `<workspace>/p2p3.md` (next to `progress.md`), one line each: `Slice <ID>: P2: <one-liner>` or `Slice <ID>: P3: <one-liner>`. Final review copies them into `<folder>/log.md` under a `P2/P3:` entry and tells the operator the count. Out-of-scope observations from a re-review are logged the same way. Entries are appended once per review round; the controller de-duplicates by finding text before appending.
- **Workstream-mandated findings:** A finding labeled workstream-mandated — or any finding that conflicts with what `brief.md` or `slices.md` requires — is the user's decision, like any workstream contradiction: present the finding and the workstream text to the user and ask which governs. Do not dismiss the finding because the workstream mandates it, and do not dispatch a fix that contradicts the workstream without explicit human guidance.

Everything else enters the loop. When the initial review requires a fix round, save its findings to `<workspace>/findings-<ID>.md` and append `Slice <ID>: fix round 0/4 (<Y> open — initial review; commits <base7>..<head7>)` before dispatching round 1. A fix round is one fix dispatch plus one scoped re-review. Four rounds maximum per fix series:

## Rounds and Dispatch

**Rounds 1-3 — resume the original implementer.** Send it the open findings verbatim. Its context is intact: it knows the slice, the code, and its own choices. If your harness cannot send another message to a live subagent, dispatch a fresh implementer carrying the slice brief path, the report-file path, and the findings — the report file is the persistent memory either way.

**Round 4 — dispatch a fresh implementer on the strongest tier** (the one exception to fixers running on the standard tier; per SKILL.md's Model Selection), with the slice brief path, the report-file path, the open findings, and this framing: "A prior implementer attempted this slice 3 times; you own it now. Read the report file for what was tried." Also dispatch fresh if the implementer is stuck or context-polluted. A loop that survives three resumes usually means the implementer cannot see its own problem — fresh eyes and a capability bump in one move.

## Every Round: Fix & Test Contract

Every round, either way:
- The implementer fixes code findings, commits, re-runs the tests covering amended code, and appends only its designated round report to `<workspace>/end-smoke-report.md` for end-smoke work (creating it only when absent). The controller owns blocker status, required-check sets, saved per-check results, rulings, dispatch/revision/range and outcome records; the implementer must not edit those records or prior reports. Never overwrite them. Existing revision/range, outcome, and failure-group records are authoritative; if their association is unclear, stop rather than reconstructing or replacing them. Never invent a missing historical RED result.
- **Test execution rule:** Run covering tests per fix round; run the full repository test suite before reporting slice DONE and before final workstream review.
- For slice fixes, before dispatching scoped re-review for the round verify the amended report against applicable evidence requirements: behavior changes need meaningful pre-edit RED and GREEN; pure refactors need credible preservation evidence; mixed work needs both. If correction is needed, request it without commit or ledger advance, then dispatch once with this round's current nonempty `FIX_BASE..HEAD`. After review, any evidence-related `⚠️ Cannot verify` triggers the same-range evidence correction and redispatch route, whether or not the reviewer explicitly requests correction. Preserve findings and uncertainties; do not replace the range. Original RED carries forward with fresh GREEN only when it demonstrated the same behavior now fixed and the test covers it; a materially distinct behavior or failure mode needs its own meaningful pre-edit RED. If evidence cannot be established, stop and escalate. For end-smoke fixes, retain the failed-check covering-test/report requirements and final verification route; do not apply slice-only evidence persistence.

## Scoped Re-Review

The re-review is scoped to the fix diff:
1. Generate the scoped review package (run `scripts/review-package` by its absolute path, from the working tree you're executing in):
   ```bash
   bash scripts/review-package "$FIX_BASE" "$HEAD" "$WORKSPACE_SLUG" "$WORKSTREAM_FILE"
   ```
   Keep the helper's nonempty-range guard. If re-review reports `⚠️ Cannot verify` for evidence, first persist the established scoped outcome, actual P0/P1 count, and unresolved uncertainties for this completed round; correct the report and redispatch using the exact range reviewed. After that same-range re-review, reconcile and persist the revised verdict, actual open count, findings, and uncertainty list in the existing report/findings file; this revised outcome is authoritative for that exact range. This correction is not another round: do not create an empty diff, commit, or additional ledger entry. If interrupted, do not infer an unrecorded dispatch range; resume from the last recorded checkpoint only when its tip matches HEAD, otherwise stop and ask the operator.
2. Dispatch `re-review-prompt.md` with findings, brief, report, and diff. For slice fixes, include the full original review if preserved and the saved findings plus unresolved `⚠️ Cannot verify` items from `<workspace>/findings-<ID>.md`. Legacy findings-only files are sufficient to continue; do not imply an unavailable original review was preserved. For end-smoke fixes, use `end-smoke-findings.md` plus relevant `brief.md` acceptance boundary as the brief; omit original-review input.
3. The re-reviewer verdicts each finding ADDRESSED or NOT ADDRESSED and flags new breakage in the fix diff only. Evidence remains subject to the `⚠️ Cannot verify` resolution route.
4. For slice rounds, before appending the round state, update `<workspace>/findings-<ID>.md` with the complete unresolved `⚠️ Cannot verify` list from re-review, including newly raised items; remove only verified and recorded resolutions. New P0/P1 breakage joins the open list. For end-smoke rounds, use the existing end-smoke findings/report and ledger route; do not apply slice-specific persistence. New P2/P3 and out-of-scope observations go to `p2p3.md` as above.

## Ledger Tracking

After persisting the current unresolved `⚠️ Cannot verify` list and re-review outcome, append the round state once the scoped verdict is established, even when evidence remains unresolved. Record the actual count of open P0/P1 findings; `⚠️ Cannot verify` is not a finding severity and does not increase that count. Thus `Verdict: CLEAN` may be recorded with `0 open` while evidence remains unresolved. Such a checkpoint is not slice acceptance: preserve the uncertainties and stop the completion route until credible Test Evidence exists and every `⚠️ Cannot verify` item is resolved. If the review outcome or its exact range cannot be established, stop rather than reconstructing it.
```markdown
Slice <ID>: fix round <R>/4 (<X> addressed, <Y> open — <finding one-liners>; commits <a7>..<b7>)
```
`<Y>` counts open P0/P1 findings only.

Never fix findings yourself in the controller session — your context stays clean for coordination, and controller fixes skip review. For smoke success or verification repair, hand off to the canonical [Final Verification Blocker](verification-blocker.md) procedure; do not summarize it as permission to record smoke success.

## End-Smoke Variant

For an end-smoke failure ([end-smoke.md](end-smoke.md)) there is no slice. Findings = `<workspace>/end-smoke-findings.md`; spec context = `brief.md`; the implementer and re-review's `[BRIEF_FILE]` are that findings file plus the relevant `brief.md` acceptance boundary (not `slice-brief`). Ledger lines are `End smoke: fix round <R>/4 (...)`, `End smoke: escalated at cap — <Y> open`, `End smoke: Ruling (user): ...`. The implementer is a fresh dispatch in round 1 and appends to `<workspace>/end-smoke-report.md` if it exists, creating it only when absent; later rounds and resumes preserve and append to it. Never overwrite blocker status, required-check sets, saved per-check results, rulings, or prior rounds. Everything else is unchanged, including the cap. Overrides: there is no `Slice <ID>: complete` write. After user rulings and independent review-clean, rerun checks attached to findings whose rulings direct code fixes, plus every other required check still outstanding or invalidated by code changes. Reuse valid saved passes and do not rerun checks explicitly accepted without code changes. Then run full Final verification. Record `End smoke: passed` only if every required non-waived check and Final verification pass. If all rulings accept smoke failures without code changes and Final verification passes, record `End smoke: passed (rulings accepted)`. If required Final verification fails, retain it as a non-waivable Final verification blocker in the existing report; do not append `End smoke: failed` or route it into the smoke fix/waiver loop. On restart, resolve that blocker and rerun Final verification before recording smoke passed.

## The Breaker (Cap Escalation)

When round 4's re-review still leaves a P0/P1 open, the cap is reached. (P2/P3 never trigger escalation.) Stop dispatching.

Immediately append to the ledger:
```markdown
Slice <ID>: escalated at cap — <Y> open
```
`<Y>` counts open P0/P1 findings only.

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

- Before acting on any rulings, including rulings directing code changes, validate `HEAD` against the latest recorded verification-repair tip when it supersedes round-four `<b7>`; otherwise require `HEAD == <b7>`. Keep `<b7>` as the exact round-four review range for matching findings and rulings. Resolve/establish credible Test Evidence and every `⚠️ Cannot verify` item, and independently re-review the recorded round-four range when evidence was unresolved or corrected. Reconcile and persist the revised scoped outcome and current named findings in the existing report/findings file; the revised outcome controls routing for that exact range. First select the current applicable `End smoke: escalated at cap` checkpoint for this round-four range, if any. A current escalation governs before any CLEAN/0-open shortcut: preserve its failures, match rulings to distinct current findings, and wait for rulings on every failure. Once all current findings are ruled, apply those rulings before any CLEAN shortcut: directed fixes must enter their authorized series; accepted findings remain named waivers. Do not rerun a current unruled cap failure or bypass a directed fix. Historical/superseded smoke escalations and their rulings remain evidence but do not govern a newer authorized fix series or its current round-four outcome. Only when no current applicable escalation governs may CLEAN with `0 open` return to normal clean completion before matching or applying stale rulings. Otherwise match rulings to distinct current findings. If any current finding lacks a ruling, re-present unmatched findings and wait; do not act on partial rulings. If range/evidence cannot be established, stop and ask. This same-range review does not consume a round.
- If the user's rulings let slice findings stand without code changes, keep `<head7>` tied to round-four `<b7>`; review-clean still requires credible evidence and resolved uncertainties. For end-smoke rulings, rerun checks attached to code-fix rulings plus every other required check still outstanding or invalidated by code changes; reuse valid saved passes and skip checks explicitly waived by acceptance rulings. Then run full Final verification only after the evidence gate. If it fails, retain the required Final verification failure in the existing report as a non-waivable blocker; do not append `End smoke: failed` or route it through the smoke fix/waiver loop. On restart, resolve the blocker and rerun Final verification.
- If the user's rulings direct a code change, start a fresh 4-round fix series (round 1/4) with `FIX_BASE` at the accepted verification-repair tip when it supersedes `<b7>`, otherwise at `<b7>`, and only the current directed findings. Preserve rulings on findings no longer open. Record the dispatch/base before starting. If resuming after interruption, continue the recorded fix series from its established base and report; do not dispatch it again. If HEAD is neither that recorded base nor its recorded tip, stop and ask rather than replaying or reviewing an unknown range.

## Success Gate: Review Clean

### Definition of "Review Clean"

Every completion route requires credible Test Evidence for the reviewed revision and resolution of all `⚠️ Cannot verify` items. On the normal path, additionally require no unresolved P0/P1 findings and a CLEAN review for the reviewed tip:
1. The initial review is `✅ Slice compliant` + `Verdict: CLEAN` (no open P0/P1), and every `⚠️ Cannot verify` item is resolved (see [cannot-verify.md](cannot-verify.md)), **OR**
2. The latest fix round's scoped re-review ends `Verdict: CLEAN`: every `[FINDINGS]` item `ADDRESSED` (spec gaps, end-smoke failures and user-ruled changes count as P0/P1 for the verdict), and no new P0/P1 (`0 open`). Any `⚠️ Cannot verify` items remain separate evidence uncertainty and must be resolved for completion, not to establish the scoped verdict, **OR**
3. At the round-4 cap, every open P0/P1 has a user ruling that lets the slice stand, all `⚠️ Cannot verify` items are resolved, and credible Test Evidence for the reviewed revision is present. CLEAN and zero open are not required on this cap route; rulings accept the named findings but do not substitute for evidence or uncertainty resolution.

### Completion

Immediately when the slice achieves **review clean** (initial review with 0 fix rounds, after a fix round, or via user rulings), verify `HEAD == <head7>` and credible Test Evidence is present for that revision (otherwise stop and request or establish it); then write to `progress.md`: no pause:
```markdown
Slice <ID>: complete (commits <base7>..<head7>, review clean[, <K> user rulings])
```
(`<base7>` is the commit before this slice began; `<head7>` is the reviewed head: current `HEAD` for initial review, or `<b7>` from the latest `fix round` line.) Mark the slice complete in the Todo list and proceed to the next slice. Human smoke testing happens once, at workstream end ([end-smoke.md](end-smoke.md)).
