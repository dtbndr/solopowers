# Handling Worker Status Reports

Part of `solopowers:workstream-driven-development`.

Worker subagents report one of four statuses upon completing their turn:

## DONE

The worker completed the slice, committed changes, and ran tests.
1. Generate the review package:
   ```bash
   bash scripts/review-package "$BASE" "$HEAD" "$WORKSPACE_SLUG" "$WORKSTREAM_FILE"
   ```
   (`BASE` is the commit recorded before dispatching the worker — never `HEAD~1`, which silently drops earlier commits of a multi-commit slice).
2. Dispatch the slice reviewer using `workstream-reviewer-prompt.md`.
3. The reviewer returns separate verdicts for spec compliance (✅/❌/⚠️) and slice quality (Approved/Needs fixes).

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
2. **Insufficient reasoning capacity:** Re-dispatch with a more capable model.
3. **Oversized slice:** If the slice is too large or complex for a single turn, split it in the Workstream Document with user consent.
4. **Workstream Document defect:** If the document itself contains an incorrect requirement or contradiction, escalate to the user.

> [!CAUTION]
> Never ignore an escalation or force the same model to retry without changes. If the worker reports that it is stuck, something needs to change.
