# "Cannot Verify From Diff" Items

Part of `solopowers:workstream-driven-development`.

The slice reviewer may report items under `⚠️ Cannot verify from diff`: requirements that live in unchanged code, depend on environment setup, or span multiple slices.

These items do not automatically fail the review, but you must resolve each one yourself before marking the slice complete:
- Inspect the repository or worktree to check the requirement directly.
- If you verify the requirement is satisfied in existing code or architecture, note your resolution in the progress ledger.
- If you confirm the item is an actual gap or missing requirement, treat it as a failed spec review — it enters the fix loop (see [references/fix-loop.md](fix-loop.md)).
