# "Cannot Verify From Diff" Items

Part of `solopowers:workstream-driven-development`.

The reviewer may report `⚠️ Cannot verify` for requirements hidden by the diff or missing Test Evidence. This is uncertainty, not a verdict or finding severity. For evidence omissions, inspect the report and worktree; ask the implementer to amend `report.md` without a commit when checks ran but were not recorded. If required checks can be run at the reviewed tip without code changes, run them and record the evidence; do not enter a fix round for evidence-only work. If missing coverage requires code changes, enter the normal fix loop; never fabricate historical RED. If the evidence cannot be established, stop and escalate.

For `⚠️ Cannot verify from diff` items: requirements may live in unchanged code, depend on environment setup, or span multiple slices.

These items do not automatically fail the review, but you must resolve each one yourself before the slice can achieve **review clean**:
- Inspect the repository or worktree to check the requirement directly.
- If you verify the requirement is satisfied in existing code or architecture, record your resolution in the progress ledger:
  ```markdown
  Slice <ID>: ⚠️ resolved — <item> — <evidence>
  ```
  Recording this ensures your verification survives context compaction and session resume.
- If you confirm an actual gap, record it as an actionable spec gap and enter the fix loop (see [references/fix-loop.md](fix-loop.md)). Count it as open P0/P1 only when the reviewer assigns that severity; do not inflate the ledger count merely because the gap triggers the loop.
