# Resuming From an Existing Ledger

Part of `solopowers:workstream-driven-development`.

Conversation memory does not survive compaction. When a session ends mid-workstream (context compaction, session restart, crash, or user interruption), the durable progress ledger is the source of truth.

## Ledger Location and Workspace Identity

The ledger lives inside the per-workstream workspace directory at:
```bash
$(bash scripts/wsd-workspace <workspace-slug> WORKSTREAM_FILE)/progress.md
```
Or simply:
```bash
$(bash scripts/wsd-workspace WORKSTREAM_FILE)/progress.md
```

### Ledger Header and Slug Disambiguation
- **Header format:** At create time, `wsd-workspace` writes `# Workstream: <path>` as the first line of `progress.md`.
- **Slug disambiguation:** If another workstream used the same slug, passing `WORKSTREAM_FILE` enables `wsd-workspace` to detect the mismatch and automatically disambiguate to a unique directory: `<slug>-<date>[-N]`.
- **Legacy headerless ledger adoption:** If an existing ledger has no header (e.g., created by an earlier version of solopowers), `wsd-workspace` emits a warning to stderr and adopts it. **Rule:** If an adopted legacy ledger already contains completed slices, confirm with the user before trusting them.

## Determining What Is Complete

1. **Check completed slices in the ledger:**
   - Slices with a `Slice <ID>: complete (...)` line are DONE — do not re-dispatch them.
   - Slices with a `Slice <ID>: minor (deferred): ...` line recorded minor items for triage at final review.
   - Slices whose last line is a fix round (`Slice <ID>: fix round <R>/4 (...)`) are mid-loop: resume the fix loop at round `<R+1>` (see [references/fix-loop.md](fix-loop.md)).
2. **Confirm with git log:**
   - Check `git log` in the worktree to verify commits match the ledger records.
3. **Check the Workstream Document:**
   - Inspect task checkboxes (`- [x]`) and carry-forward notes from the last completed slice.

## Step-by-Step Resume Procedure

1. Run `bash scripts/wsd-workspace WORKSTREAM_FILE` to identify the resolved workspace directory.
2. Read `<workspace>/progress.md`.
3. If the ledger is legacy headerless and marks slices complete, confirm with the user: "Adopted existing ledger for <workstream>. Slices [X, Y] are marked complete in the ledger. Proceed with Slice [Z]?"
4. Resume execution at the first incomplete slice.
5. Provide the carry-forward context from the preceding slice in the dispatch to the next worker.
