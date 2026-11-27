# Handling Worker Status Reports

Part of `solopowers:workstream-driven-development`.

Worker subagents report one of four statuses upon completing their turn:

## DONE

The worker completed the slice, committed changes, and ran tests.
0. **Check the RED before review.** Open the report's RED excerpt. If it shows `ERR_MODULE_NOT_FOUND`, a "module/export must exist" assertion, `error TS`, a setup or fixture error, or one assertion standing for several contracts, it is not RED: redispatch the worker for correct RED with the rules in `solopowers:test-driven-development` `red-evidence.md` (before the review, while the code is fresh) instead of waiting for the reviewer to flag it. If the raw RED is gone, use the unrecoverable-RED ladder in [cannot-verify.md](cannot-verify.md).
1. Generate the review package (run `scripts/review-package` by its absolute path, from the working tree you're executing in):
   ```bash
   bash scripts/review-package "$BASE" "$HEAD" "$WORKSPACE_SLUG" "$WORKSTREAM_FILE"  # always <folder>/slices.md
   ```
   (`BASE` is the commit recorded before dispatching the worker — never `HEAD~1`, which silently drops earlier commits of a multi-commit slice).
2. Dispatch the slice reviewer using `workstream-reviewer-prompt.md`.
3. The reviewer returns spec compliance (✅/❌/⚠️), P0-P3 findings, and a `Verdict:` line (CLEAN / NEEDS FIXES).

## DONE_WITH_CONCERNS

The worker completed the work but flagged doubts or observations.
1. Read the concerns before proceeding to review.
2. If the concerns are about correctness, spec ambiguity, or scope creep, address them or clarify with the user before review.
3. If they are informational observations (e.g., "module is growing large"), note them in the ledger and proceed to review.

## NEEDS_CONTEXT

The worker needs information that was not provided in the curated brief or carry-forward.
1. Supply the missing context (interfaces, example usages, or configuration).
2. Re-dispatch the worker subagent.

## BLOCKED

The worker cannot complete the slice.
Assess the blocker systematically:
1. **Missing context:** Provide the context and re-dispatch with the same model.
2. **Insufficient reasoning capacity:** Re-dispatch on the strongest tier.
3. **Oversized slice:** If the slice is too large or complex for a single turn, split it in `slices.md` with user consent.
4. **Workstream defect:** If `brief.md` or `slices.md` itself contains an incorrect requirement or contradiction, escalate to the user.

**Partial work left in the tree.** A stalled or blocked worker may leave uncommitted implementation. Do not tell a takeover worker to "preserve and extend" it: that skips RED. Tell it to stash the implementation, write or restore the tests, save RED against the base, then restore the implementation and verify GREEN (`red-evidence.md`, "Taking over uncommitted implementation"). If the behavior cannot be isolated, the worker reports it and the unrecoverable-RED ladder in [cannot-verify.md](cannot-verify.md) applies.

> [!CAUTION]
> Never ignore an escalation or force the same model to retry without changes. If the worker reports that it is stuck, something needs to change.
