# Final Review and Finish

Part of `solopowers:workstream-driven-development`. Every slice in the workstream's `slices.md` is complete, verified, and smoke-tested.

## Whole-Workstream Review

The final whole-workstream review inspects the entire branch diff across all completed slices:
1. Run the commands listed in the **Final verification** section of `<folder>/slices.md` (e.g. full test suite, linter, typecheck, build), and check the result against the acceptance boundary and success criteria in `<folder>/brief.md`. The **Final smoke checks** in `brief.md` are the operator's manual end-to-end checks; ask the operator to run them (in their normal checkout when the work is on a branch, or note that a worktree lacks gitignored files such as `.env`, virtualenvs, and `node_modules`).
2. Generate the full review package (run `scripts/review-package` by its absolute path, from the working tree you're executing in):
   ```bash
   bash scripts/review-package "$MERGE_BASE" "$HEAD" "$WORKSPACE_SLUG" "$WORKSTREAM_FILE"
   ```
   where `WORKSTREAM_FILE` is always `<folder>/slices.md` and `WORKSPACE_SLUG` is the folder name without its leading `YYYY-MM-DD-`; `MERGE_BASE` is the commit the workstream branch started from (e.g. `git merge-base main HEAD`).
3. Dispatch the final review using `solopowers:dispatching-code-review` ([code-reviewer.md](../../dispatching-code-review/code-reviewer.md)) on the most capable available model. Include the printed review package path in the dispatch so the final reviewer reads one unified file instead of re-deriving the diff with git commands.
4. Point the reviewer at the progress ledger's `Ruling (user)` lines and `minor (deferred)` lines so it can triage which decisions were made and which minors must be fixed before merge.

## Handling Final Review Findings ("No Second Fix Wave")

If the final whole-workstream review returns findings:
- Dispatch **ONE fix subagent** with the complete findings list — do NOT spawn one fixer per finding. Per-finding fixers each rebuild context and re-run suites, drastically increasing context and wall-clock costs.
- The fix subagent addresses the findings, runs covering tests, commits, and runs the full repository test suite.
- Run exactly one scoped re-review of the fix wave:
  ```bash
  bash scripts/review-package "$FIX_BASE" "$HEAD" "$WORKSPACE_SLUG" "$WORKSTREAM_FILE"
  ```
- **No second fix wave:** If any findings remain unresolved or conflict with `brief.md` or `slices.md` after this single fix wave and re-review, escalate them directly to the user. Present the findings, the diff, and the trade-offs.

## Finish and Cleanup

1. Confirm that the final review is clean and all final verification commands pass.
2. Delete the workstream workspace directory:
   ```bash
   rm -rf ".solopowers/wsd/<resolved-workspace>/"
   ```
   (The git history is the permanent record now; leave sibling workspace directories untouched).
3. Record the final outcome in `<folder>/log.md`. Use `solopowers:finishing-a-development-branch` (called once, in both isolation modes) to guide the user through local merging, pushing, opening a PR, or branch cleanup.
