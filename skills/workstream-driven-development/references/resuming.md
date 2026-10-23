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

## Ledger State Lines

Per-slice entries in `progress.md` distinguish **state lines** (which define where execution stands) from **annotation lines** (`minor (deferred)`, `Ruling (user)`, `⚠️ resolved`):

| Line | Written when |
|---|---|
| `Slice <ID>: review clean (commits <base7>..<head7>) — awaiting smoke test` | Initial review is ✅ + Approved with every ⚠️ resolved, **or** a fix round has 0 open, **or** user rulings let the slice stand. Written immediately *before* pausing for the smoke test. |
| `Slice <ID>: fix round <R>/4 (<X> addressed, <Y> open — …; commits <a7>..<b7>)` | Written after each fix round re-review. |
| `Slice <ID>: escalated at cap — <Y> open` | Written when round 4 still has open findings and the controller escalates to the user. |
| `Slice <ID>: Ruling (user): <finding> — <decision>` | Annotation: written one per open finding once the user decides. |
| `Slice <ID>: ⚠️ resolved — <item> — <evidence>` | Annotation: written when the controller resolves a `⚠️ Cannot verify` item. |
| `Slice <ID>: minor (deferred): <one-liner>` | Annotation: written when minor findings are deferred to final review. |
| `Slice <ID>: smoke test failed — <one-liner>` | Written when the user reports a manual smoke test failure; starts a fresh 4-round budget. |
| `Slice <ID>: complete (commits <base7>..<head7>, review clean[, <K> user rulings], smoke test passed)` | Written immediately after the user confirms the manual smoke test passed. |

## Resume Dispatch Table

When resuming an interrupted session, locate the slice's **last state line** (skip `minor (deferred)`, `Ruling (user)`, and `⚠️ resolved` lines when determining the last state line, unless inspecting rulings after `escalated at cap`):

| Last state line | Action on resume |
|---|---|
| `complete` | Skip the slice (already DONE). Resume at the next slice. |
| `review clean (... — awaiting smoke test)` | Check that current `HEAD == <head7>`. If matched, **re-ask the user for the manual smoke test** (do NOT re-dispatch implementer or reviewer). |
| `fix round <R>/4` with `0 open` | Session stopped between appends: write `review clean (commits <base7>..<head7>) — awaiting smoke test`, then ask the user for the smoke test. |
| `fix round <R>/4` (`R < 4`) with `>0 open` | Continue the fix loop at round `<R+1>` (see [references/fix-loop.md](fix-loop.md)). |
| `fix round 4/4` with `>0 open`, or `escalated at cap` with no rulings | Re-present the escalation to the user; **never dispatch round 5**. |
| `escalated at cap` followed by `Ruling (user)` lines | Apply the user's rulings: if rulings let the slice stand as-is, write `review clean` and ask for the smoke test; if rulings direct code changes, start a fresh 4-round fix series (round 1/4) from current `HEAD` with the user-directed changes as findings. |
| `smoke test failed — <one-liner>` | Start the fix loop at round 1/4 (fresh 4-round budget) from the smoke-pause `<head7>` with the user's report as findings. |
| No state line for this slice; commits exist past previous slice's `<head7>` | Set `BASE` = previous slice's `complete` `<head7>` (or `git merge-base main HEAD` for Slice 1). Inspect the implementer report file and workspace: if implementation finished (`DONE`), run the initial slice review; otherwise resume/re-dispatch the implementer subagent. |

## Step-by-Step Resume Procedure

1. Run `bash scripts/wsd-workspace WORKSTREAM_FILE` to identify the resolved workspace directory.
2. Read `<workspace>/progress.md`.
3. If the ledger is legacy headerless and marks slices complete, confirm with the user: "Adopted existing ledger for <workstream>. Slices [X, Y] are marked complete in the ledger. Proceed with Slice [Z]?"
4. Inspect the last state line for the first incomplete slice according to the Resume Dispatch Table above.
5. Take the corresponding action from the table, carrying forward context from the preceding completed slice.
