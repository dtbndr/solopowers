# Final Review and Finish

Part of `solopowers:workstream-driven-development`. Every slice in the workstream's `slices.md` is complete and verified.

## Whole-Workstream Review

The final whole-workstream review inspects the entire branch diff across all completed slices:
1. Run the commands listed in the **Final verification** section of `<folder>/slices.md` (e.g. full test suite, linter, typecheck, build), and check the result against the acceptance boundary and success criteria in `<folder>/brief.md`. Then run the end smoke step ([end-smoke.md](end-smoke.md)) before dispatching the final review. Skip both Final verification and end smoke when `progress.md` already has `End smoke: passed` or `End smoke: skipped` (the SKILL graph ran them before this step); after an end-smoke fix loop, Final verification is re-run in full first.
2. Generate the full review package (run `scripts/review-package` by its absolute path, from the working tree you're executing in):
   ```bash
   bash scripts/review-package "$MERGE_BASE" "$HEAD" "$WORKSPACE_SLUG" "$WORKSTREAM_FILE"
   ```
   where `WORKSTREAM_FILE` is always `<folder>/slices.md` and `WORKSPACE_SLUG` is the folder name without its leading `YYYY-MM-DD-`; `MERGE_BASE` is the commit the workstream branch started from (e.g. `git merge-base main HEAD`).
3. Dispatch the final review using `solopowers:dispatching-code-review` ([code-reviewer.md](../../dispatching-code-review/code-reviewer.md)) on the strongest tier. Supply `[PLAN_OR_REQUIREMENTS]` as `brief.md`'s happy path and acceptance boundary plus `<folder>/slices.md`. Fill `[SEVERITY_DEFINITIONS]` as in [reviewer-prompts.md](reviewer-prompts.md). Include the printed review package path in the dispatch so the final reviewer reads one unified file instead of re-deriving the diff with git commands.
4. Point the reviewer at the progress ledger's `Ruling (user)` lines and and at `<workspace>/p2p3.md` as carry-forward input, so it can see which decisions were made and which P2/P3 findings were logged. Tell the operator the P2/P3 count; they are not fixed unless the operator asks.

## Handling Final Review Findings ("No Second Fix Wave")

If the final whole-workstream review returns P0/P1 findings (P2/P3 are logged to `p2p3.md`, not fixed):
- Dispatch **ONE fix subagent** with the complete findings list — do NOT spawn one fixer per finding. Per-finding fixers each rebuild context and re-run suites, drastically increasing context and wall-clock costs.
- The fix subagent addresses the findings, runs covering tests, commits, and runs the full repository test suite.
- Run exactly one scoped re-review of the fix wave:
  ```bash
  bash scripts/review-package "$FIX_BASE" "$HEAD" "$WORKSPACE_SLUG" "$WORKSTREAM_FILE"
  ```
- **No second fix wave:** If any findings remain unresolved or conflict with `brief.md` or `slices.md` after this single fix wave and re-review, escalate them directly to the user. Present the findings, the diff, and the trade-offs.

## Finish and Cleanup

1. Confirm that the final review is clean and all final verification commands pass.
2. Record the finish in `<folder>/log.md`, including the fixed-format marker line `Final review: clean (at <h7>)` (`<h7>` = the reviewed head, 7 chars) and the `Smoke:` lines, together with the `P2/P3:` entry copied from `<workspace>/p2p3.md` (if any), and commit that change (explicit path). The committed marker is the durable finished state; the local ledger is not.
3. Only after that commit, delete the workstream workspace directory:
   ```bash
   rm -rf ".solopowers/wsd/<resolved-workspace>/"
   ```
   (The git history is the permanent record now; leave sibling workspace directories untouched).
4. Use `solopowers:finishing-a-development-branch` (called once, in both isolation modes) to guide the user through local merging, pushing, opening a PR, or branch cleanup.
