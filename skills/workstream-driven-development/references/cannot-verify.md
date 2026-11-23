# "Cannot Verify From Diff" Items

Part of `solopowers:workstream-driven-development`.

The reviewer may report `⚠️ Cannot verify` for requirements hidden by the diff or missing Test Evidence. This is uncertainty, not a verdict or finding severity. Inspect whether existing evidence or direct repository inspection establishes the affected contract. If evidence is missing or inadequate, correct it and redispatch review of the same recorded range (an unrecoverable historical RED instead follows the ladder below, without redispatch); if direct inspection resolves the uncertainty, record the evidence and outcome. A confirmed contract gap enters the fix loop. The status alone is neither a correction request nor proof of a defect. For evidence omissions, inspect the report and worktree; ask the implementer to amend `report.md` without a commit when checks ran but were not recorded. If required checks can be run at the reviewed tip without code changes, run them and record the evidence; do not enter a fix round for evidence-only work. If missing coverage requires code changes, enter the normal fix loop; never fabricate historical RED. If the evidence cannot be established, follow the unrecoverable-RED ladder below before escalating.

## Unrecoverable historical RED

Applies when the worker reports a pre-implementation RED but its raw output or edit sequence is no longer recoverable (tests and implementation committed together, report lost or truncated). This is an evidence-process gap, not a code defect, and the worker's report is not thereby false. Work down the ladder and stop at the first rung that succeeds:

1. **Recorded RED.** `report.md` holds the RED command and a failure excerpt that matches the missing behavior in the diff (for example, a failed assertion on the wrong value). A load, import or missing-export error is not RED: go to rung 2. Treat a valid excerpt as worker-attested evidence and record `Slice <ID>: ⚠️ resolved — <item> — attested RED: <command>; <excerpt>` in the progress ledger and, as a controller record, in `report.md`. Do not label it independently verified.
2. **Reconstructed RED.** Create a throwaway worktree outside the repository, detached at the reviewed tip (`git worktree add --detach <scratch path> <tip>`); it is never the workstream's isolation unit, so remove it (`git worktree remove --force`) before continuing, and again on resume if one is left over. In it, restore the slice's implementation files that existed at `BASE` (`git checkout BASE -- <paths>`) and delete the files the slice added; keep the tests. If the tests now fail to load (missing import or export), add minimal stubs for the missing symbols in the throwaway worktree only, so the failure is on assertions: an error or broken setup is not RED. The tests must fail for the intended missing behavior. Then run them at the tip for GREEN. Record `Slice <ID>: ⚠️ resolved — <item> — reconstructed RED (<tip sha>): <commands>; <failure excerpt>; GREEN at <tip sha>` in the progress ledger and append the same line to `report.md` as a controller record (reviewers receive the report, not the ledger). Treat a reviewer re-flag of the same ordering gap as resolved by this line; do not redispatch for it. This is fresh evidence labeled as such, not fabricated history. Leave the real branch untouched.
3. **Escalate with a recommendation.** Only when neither rung applies (for example, edited existing tests entangled with the implementation). State that this is an evidence-process blocker and not a defect, and recommend one of: accept the worker-attested account as a named ruling, or re-dispatch the slice. Give a one-line reason; the operator decides.

Fix-round and preservation evidence follow the same ladder, with the exceptions that a refactor needs no RED and an unchanged-behavior test added against existing behavior is preservation evidence, never RED.

For `⚠️ Cannot verify from diff` items: requirements may live in unchanged code, depend on environment setup, or span multiple slices.

These items do not automatically fail the review, but you must resolve each one yourself before the slice can achieve **review clean**:
- Inspect the repository or worktree to check the requirement directly.
- If you verify the requirement is satisfied in existing code or architecture, record your resolution in the progress ledger:
  ```markdown
  Slice <ID>: ⚠️ resolved — <item> — <evidence>
  ```
  Recording this ensures your verification survives context compaction and session resume.
- If you confirm an actual gap, record it as an actionable spec gap and enter the fix loop (see [references/fix-loop.md](fix-loop.md)). Count it as open P0/P1 only when the reviewer assigns that severity; do not inflate the ledger count merely because the gap triggers the loop.
