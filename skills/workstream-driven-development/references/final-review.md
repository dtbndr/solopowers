# Final Review and Finish

Part of `solopowers:workstream-driven-development`. Every slice in the Workstream Document is complete, verified, and smoke-tested.

## Whole-Workstream Review

The final whole-workstream review inspects the entire branch diff across all completed slices:
1. Run the commands listed in the **Final verification** section of the Workstream Document (e.g. full test suite, linter, typecheck, build).
2. Generate the full review package:
   ```bash
   bash scripts/review-package "$MERGE_BASE" "$HEAD" "$WORKSPACE_SLUG" "$WORKSTREAM_FILE"
   ```
   where `MERGE_BASE` is the commit the workstream branch started from (e.g. `git merge-base main HEAD`).
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
- **No second fix wave:** If any findings remain unresolved or conflict with the Workstream Document after this single fix wave and re-review, escalate them directly to the user. Present the findings, the diff, and the trade-offs.

## Finish and Cleanup

1. Confirm that the final review is clean and all final verification commands pass.
2. Delete the workstream workspace directory:
   ```bash
   rm -rf ".solopowers/wsd/<resolved-workspace>/"
   ```
   (The git history is the permanent record now; leave sibling workspace directories untouched).
3. Use `solopowers:finishing-a-development-branch` to guide the user through local merging, pushing, opening a PR, or branch cleanup.
