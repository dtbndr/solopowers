# Final Review and Finish

Part of `solopowers:workstream-driven-development`. Every slice in the workstream's `slices.md` is complete and verified.

## Whole-Workstream Review

The final whole-workstream review inspects the entire branch diff across all completed slices:
1. If any required Final verification command fails, immediately route to [Final Verification Blocker](verification-blocker.md), create/mark the blocker active in `<workspace>/end-smoke-report.md`, and do not dispatch final review until resolved. The blocker recovery workflow may require or authorize smoke while pending; follow its state and resume rules. A recorded `passed` or `skipped` smoke line never bypasses an active/pending blocker. Resume blocker recovery before deciding whether smoke can be skipped; dispatch final review only after blocker resolution and current full verification. Run the commands listed in the **Final verification** section of `<folder>/slices.md` (e.g. full test suite, linter, typecheck, build), and check the result against the acceptance boundary and success criteria in `<folder>/brief.md`. Then run the end smoke step ([end-smoke.md](end-smoke.md)) before dispatching the final review. Skip both Final verification and end smoke when `progress.md` already has `End smoke: passed`, `passed (rulings accepted)` or `skipped` (these are written only after the full Final verification passed, so it is current).
2. Generate the full review package (run `scripts/review-package` by its absolute path, from the working tree you're executing in):
   ```bash
   bash scripts/review-package "$MERGE_BASE" "$HEAD" "$WORKSPACE_SLUG" "$WORKSTREAM_FILE"
   ```
   where `WORKSTREAM_FILE` is always `<folder>/slices.md` and `WORKSPACE_SLUG` is the folder name without its leading `YYYY-MM-DD-`; `MERGE_BASE` is the commit the workstream branch started from (e.g. `git merge-base main HEAD`).
3. Dispatch the final review using `solopowers:dispatching-code-review` ([code-reviewer.md](../../dispatching-code-review/code-reviewer.md)) on the strongest tier. Supply `[PLAN_OR_REQUIREMENTS]` as `brief.md`'s happy path and acceptance boundary plus `<folder>/slices.md`. Fill `[SEVERITY_DEFINITIONS]` as in [reviewer-prompts.md](reviewer-prompts.md). Include the printed review package path in the dispatch so the final reviewer reads one unified file instead of re-deriving the diff with git commands.
4. Point the reviewer at the progress ledger's `Ruling (user)` lines and at `<workspace>/p2p3.md` as carry-forward input, so it can see which decisions were made and which P2/P3 findings were logged. Final-review P2/P3 findings are logged to `p2p3.md` as `Final: P2: <one-liner>` / `Final: P3: <one-liner>`. Tell the operator the P2/P3 count; they are not fixed unless the operator asks.

## Handling Final Review Findings ("No Second Fix Wave")

If the final whole-workstream review returns P0/P1 findings (P2/P3 are logged to `p2p3.md`, not fixed):
- Dispatch **ONE fix subagent** with the complete findings list — do NOT spawn one fixer per finding. Per-finding fixers each rebuild context and re-run suites, drastically increasing context and wall-clock costs.
- The fix subagent addresses the findings, runs covering tests, commits, and runs the full repository test suite. Determine the exact wave range and persist it, the known-undispatched review status, and all known outstanding or invalidated smoke obligations in `<workspace>/end-smoke-report.md` before writing the ledger checkpoint or running Final verification. A pending record is not verification success or proof of dispatch; record dispatch separately at the dispatch boundary. If interrupted between writes, reconcile only when exact-range evidence establishes the association; otherwise stop and ask. Then append `End: final review fix wave (commits <a7>..<b7>)` to `progress.md`.
- At the wave tip `<b7>`, run every command in the workstream's **Final verification** section. If any fails, immediately create/update the `ACTIVE` blocker in `<workspace>/end-smoke-report.md` using [Final Verification Blocker](verification-blocker.md). For this fix-wave continuation, dispatch the single re-review once the repair tip is independently accepted and current full Final verification passes; smoke revalidation and blocker resolution are finish gates, not prerequisites for this re-review. Recovery may record reviewed repair commits after `<b7>`; in that case, the single authorized re-review must cover the complete change through current `HEAD`, not a stale range.
- Before dispatch, update the existing continuation record with the exact range and one-review intent; if no blocker exists, use `FINAL REVIEW RE-REVIEW PENDING`, not an `ACTIVE` blocker. Reconcile smoke-result revisions through the candidate tip and retain all outstanding or invalidated checks as obligations. Record dispatch separately at dispatch and the exact review range/outcome before continuing. On resume, reconcile this state and never redispatch if dispatch or outcome may have occurred; if state or coverage is uncertain, stop and ask.
- Run exactly one scoped re-review of the verified fix wave/change range:
  ```bash
  bash scripts/review-package "$FIX_BASE" "$HEAD" "$WORKSPACE_SLUG" "$WORKSTREAM_FILE"
  ```
- After the single re-review is clean, resume the smoke obligations recorded in the continuation report: run only outstanding or invalidated checks, reusing valid saved passes and honoring only applicable named waivers. Do not finish until all obligations are durably passed/disposed of, Final verification remains current, and the blocker is resolved when one is active. If a check fails or requires code changes after this re-review, stop for operator direction; do not dispatch another fix wave or review.
- **No second fix wave:** If any findings remain unresolved or conflict with `brief.md` or `slices.md` after this single fix wave and re-review, escalate them directly to the user. Present the findings, the diff, and the trade-offs.

## Finish and Cleanup

1. Confirm that the final review is clean, all Final verification commands pass, all required smoke obligations are durably satisfied or explicitly disposed of by their applicable named rulings, and any active verification blocker is `RESOLVED`. If smoke requires a code change after the one re-review, stop for operator direction; do not finish at an unreviewed tip or dispatch another re-review.
2. Check `<folder>/log.md` first (a resumed run may already have uncommitted `Smoke:`, `P2/P3:` or `Final review:` lines; never append duplicates). Record the finish in `<folder>/log.md`, including the fixed-format marker line `Final review: clean (at <h7>)` (`<h7>` = the reviewed head, 7 chars) and the `Smoke:` lines, and set `brief.md` `**Status**` to `Done`, together with the `P2/P3:` entry copied from `<workspace>/p2p3.md` (if any), and commit those changes (explicit paths). The committed marker is the durable finished state; the local ledger is not.
3. Only after that commit, delete the workstream workspace directory:
   ```bash
   rm -rf ".solopowers/wsd/<resolved-workspace>/"
   ```
   (The git history is the permanent record now; leave sibling workspace directories untouched).
4. Use `solopowers:finishing-a-development-branch` (called once, in both isolation modes) to guide the user through local merging, pushing, opening a PR, or branch cleanup.
