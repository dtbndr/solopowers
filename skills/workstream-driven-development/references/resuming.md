# Resuming From an Existing Ledger

Part of `solopowers:workstream-driven-development`.

Conversation memory does not survive compaction. When a session ends mid-workstream (context compaction, session restart, crash, or user interruption), the durable progress ledger (`progress.md`) is the source of truth for slice state. The committed `<folder>/log.md` is the human/agent record (isolation mode, review verdicts, carry-forward); it never overrides the ledger on slice state.

## Ledger Location and Workspace Identity

The ledger lives inside the per-workstream workspace directory. Run `scripts/wsd-workspace` by its absolute path, from the working tree you're executing in:
```bash
$(bash scripts/wsd-workspace <workspace-slug> WORKSTREAM_FILE)/progress.md
```
Or simply:
```bash
$(bash scripts/wsd-workspace WORKSTREAM_FILE)/progress.md
```
`WORKSTREAM_FILE` is always `<folder>/slices.md`; the helper derives the slug and date from the parent folder name.

### Ledger Header and Slug Disambiguation
- **Header format:** At create time, `wsd-workspace` writes `# Workstream: <path>` as the first line of `progress.md`.
- **Slug disambiguation:** If another workstream used the same slug, passing `WORKSTREAM_FILE` enables `wsd-workspace` to detect the mismatch and automatically disambiguate to a unique directory: `<slug>-<date>[-N]`.
- **Legacy headerless ledger adoption:** If an existing ledger has no header (e.g., created by an earlier version of solopowers), `wsd-workspace` emits a warning to stderr and adopts it. **Rule:** If an adopted legacy ledger already contains completed slices, confirm with the user before trusting them.

## Ledger State Lines

Per-slice entries in `progress.md` distinguish **state lines** (which define where execution stands) from **annotation lines** (`Ruling (user)`, `⚠️ resolved`):

| Line | Written when |
|---|---|
| `Slice <ID>: review clean (commits <base7>..<head7>) — awaiting smoke test` | Initial review is ✅ + `Verdict: CLEAN` with every ⚠️ resolved, **or** a fix round has 0 open, **or** user rulings let the slice stand. Written immediately *before* pausing for the smoke test. |
| `Slice <ID>: fix round <R>/4 (<X> addressed, <Y> open — …; commits <a7>..<b7>)` | Written after each fix round re-review. "Open" always means open P0/P1; P2/P3 live in `log.md`, never in the ledger. |
| `Slice <ID>: escalated at cap — <Y> open` | Written when round 4 still has open findings and the controller escalates to the user. |
| `Slice <ID>: Ruling (user): <finding> — <decision>` | Annotation: written one per open finding once the user decides. |
| `Slice <ID>: ⚠️ resolved — <item> — <evidence>` | Annotation: written when the controller resolves a `⚠️ Cannot verify` item. |
| `Slice <ID>: smoke test failed (at <head7>) — <one-liner>` | Written when the user reports a manual smoke test failure; starts a fresh 4-round budget with `FIX_BASE` = `<head7>` recorded on the preceding `review clean` line. |
| `Slice <ID>: complete (commits <base7>..<head7>, review clean[, <K> user rulings], smoke test passed)` | Written immediately after the user confirms the manual smoke test passed. |

## Resume Dispatch Table

When resuming an interrupted session, locate the slice's **last state line** (skip `Ruling (user)` and `⚠️ resolved` lines when determining the last state line, unless inspecting rulings after `escalated at cap`):

| Last state line | Action on resume |
|---|---|
| `complete` | Skip the slice (already DONE). Resume at the next slice. |
| `review clean (... — awaiting smoke test)` | Check current `HEAD` against `<head7>`. If `HEAD == <head7>`, **re-ask the user for the manual smoke test** (do NOT re-dispatch implementer or reviewer). If `HEAD != <head7>`, stop and ask the user how to handle the unreviewed commits past `<head7>` before running the smoke test. |
| `fix round <R>/4` with `0 open` | Session stopped between appends: check current `HEAD` against `<b7>` (the round's reviewed head commit). If `HEAD == <b7>`, write `review clean (commits <base7>..<b7>) — awaiting smoke test` and ask the user for the smoke test; if `HEAD != <b7>`, stop and ask the user how to handle the unreviewed commits past `<b7>`. |
| `fix round <R>/4` (`R < 4`) with `>0 open` | Continue the fix loop at round `<R+1>` (see [references/fix-loop.md](fix-loop.md)). |
| `fix round 4/4` with `>0 open`, or `escalated at cap — <Y> open` with no rulings | Re-present the escalation to the user; **never dispatch round 5**. |
| `escalated at cap — <Y> open` followed by `Ruling (user)` lines | Compare the count of `Ruling (user)` lines against `<Y>`. If fewer than `<Y>` rulings are recorded, re-present the remaining unruled findings to the user before proceeding. Once all `<Y>` rulings are present: if rulings let the slice stand as-is without code changes, check current `HEAD` against `<b7>` (the round-4 reviewed head commit from the preceding `fix round 4/4` line); if `HEAD == <b7>`, write `review clean (commits <base7>..<b7>) — awaiting smoke test` and ask the user for the smoke test; if `HEAD != <b7>`, stop and ask the user how to handle the unreviewed commits past `<b7>`. If rulings direct code changes, start a fresh 4-round fix series (round 1/4) with `FIX_BASE` anchored to the round-4 `<b7>` commit (from the preceding `fix round 4/4` line, not current `HEAD`, in case a crash occurred after new commits landed before the round line was written) with the user-directed changes as findings. |
| `smoke test failed (at <head7>) — <one-liner>` | Start the fix loop at round 1/4 (fresh 4-round budget) with `FIX_BASE` = `<head7>` recorded on the preceding `review clean` line, with the user's report as findings. |
| No state line for this slice | Set `BASE` = previous slice's `complete` `<head7>` (for the first slice, the last setup commit: `git log -n1 --format=%H -G'^Pre-flight:' -- <folder>/log.md`, so Slice A's review excludes setup commits; only if `log.md` has no `Pre-flight:` line AND the ledger already shows a slice past dispatch (legacy log), use the `Isolation:` commit via `-G'^Isolation:'`; otherwise redo pre-flight first, see step 1a). If no commits exist past `BASE` (unstarted, or crashed before first commit), dispatch or resume the implementer from `BASE`. If commits exist past `BASE`: inspect the implementer report file; if implementation reported `DONE` or `DONE_WITH_CONCERNS` (matching `SKILL.md`), run the initial slice review (`bash scripts/review-package BASE HEAD ...`); otherwise resume/re-dispatch the implementer subagent. |

## Step-by-Step Resume Procedure

0. **Locate the isolation unit BEFORE any `wsd-workspace` call** (it silently creates an empty ledger in whatever checkout you are in). After a restart you may be in the main checkout (worktree mode) or on the default branch after `git switch main` (branch mode).
   - Derive `<slug>`: the workstream folder name minus its leading `YYYY-MM-DD-`. Run `git worktree list --porcelain` and `git branch --list 'ws/<slug>'`. Match worktrees by the exact line `branch refs/heads/ws/<slug>` (never a prefix match: `foo` vs `foo-bar`). If several candidate worktrees or branches match, stop and ask the operator.
   - **Worktree mode:** if a worktree on `ws/<slug>` exists (or any worktree whose tree contains `<folder>/log.md` with an `Isolation:` line anywhere in it), `cd` into that worktree directory. Every later step (`wsd-workspace`, `slice-brief`, ledger, `log.md`, commits) runs there.
   - **Branch mode:** if branch `ws/<slug>` exists and you are not on it, first validate with `git show ws/<slug>:<folder>/log.md` that it contains an `Isolation:` line (if not, stop and ask the operator), then run `git switch ws/<slug>` only when the working tree is clean; otherwise stop and ask the operator.
   - Read the mode from `<folder>/log.md` IN THE UNIT. **Stop and ask the operator** (never dispatch an implementer on the default branch, never run `wsd-workspace` outside the unit) if: the unit's `log.md` has no `Isolation:` line anywhere; no unit can be found but a ledger or log shows work was done; or you are on the default branch while a `ws/<slug>` branch exists and cannot be switched to.
   - Only if NO `ws/<slug>` branch or worktree exists AND no `Isolation:` line exists anywhere is this a first run, not a resume: go through the normal isolation choice ([references/isolation.md](isolation.md)).
1. From inside the unit, run `bash scripts/wsd-workspace <folder>/slices.md` to identify the resolved workspace directory.
1a. **Pre-flight check.** If `log.md` in the unit has an `Isolation:` line but no `Pre-flight:` line, setup was interrupted: before dispatching anything, redo the pre-flight scan inside the unit ([references/preflight.md](preflight.md)), apply agreed edits, and append and commit the `Pre-flight:` line. Otherwise skip pre-flight.
2. Read `<workspace>/progress.md` for slice state, and confirm the isolation mode from `log.md` in the unit (the first `Isolation: <branch|worktree> — branch <name>` line anywhere in it). Do not ask the operator to choose isolation again; if the mode in `log.md` does not match the current checkout, stop and ask.
3. If the ledger is legacy headerless and marks slices complete, confirm with the user: "Adopted existing ledger for <workstream>. Slices [X, Y] are marked complete in the ledger. Proceed with Slice [Z]?"
4. Inspect the last state line for the first incomplete slice according to the Resume Dispatch Table above.
5. Take the corresponding action from the table, carrying forward context from the preceding completed slice.
