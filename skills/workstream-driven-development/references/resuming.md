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

Per-slice entries in `progress.md` distinguish **state lines** (which define where execution stands) from **annotation lines** (`Ruling (user)`, `⚠️ resolved`, legacy `minor (deferred)`):

| Line | Written when |
|---|---|
| `Slice <ID>: fix round <R>/4 (<X> addressed, <Y> open — …; commits <a7>..<b7>)` | Written after each fix round re-review. "Open" always means open P0/P1; P2/P3 live in `p2p3.md`, never in the ledger. |
| `Slice <ID>: escalated at cap — <Y> open` | Written when round 4 still has open findings and the controller escalates to the user. |
| `Slice <ID>: Ruling (user): <finding> — <decision>` | Annotation: written one per open finding once the user decides. |
| `Slice <ID>: ⚠️ resolved — <item> — <evidence>` | Annotation: written when the controller resolves a `⚠️ Cannot verify` item. |
| `Slice <ID>: complete (commits <base7>..<head7>, review clean[, <K> user rulings])` | Written immediately when the slice is review clean: initial review is ✅ + `Verdict: CLEAN` with every ⚠️ resolved, **or** a fix round has 0 open, **or** user rulings let the slice stand. No pause. |

## Resume Dispatch Table

When resuming an interrupted session, locate the slice's **last state line** (skip `Ruling (user)`, `⚠️ resolved` and legacy `minor (deferred)` lines). Legacy smoke lines: a `review clean … awaiting smoke test` line counts as `complete` if `HEAD == <head7>`; if `HEAD != <head7>`, stop and ask the operator. A legacy `smoke test failed` line after it is not skipped: start fix loop round 1/4 with `FIX_BASE` = that `<head7>` and the reported failure as findings.

| Last state line | Action on resume |
|---|---|
| `complete` | Skip the slice (already DONE). Resume at the next slice. |
| `fix round <R>/4` with `0 open` | Session stopped between appends: check current `HEAD` against `<b7>` (the round's reviewed head commit). If `HEAD == <b7>`, write `complete (commits <base7>..<b7>, review clean[, <K> user rulings])` and proceed to the next slice; if `HEAD != <b7>`, stop and ask the user how to handle the unreviewed commits past `<b7>`. |
| `fix round <R>/4` (`R < 4`) with `>0 open` | Continue the fix loop at round `<R+1>` (see [references/fix-loop.md](fix-loop.md)). |
| `fix round 4/4` with `>0 open`, or `escalated at cap — <Y> open` with no rulings | Re-present the escalation to the user; **never dispatch round 5**. |
| `escalated at cap — <Y> open` followed by `Ruling (user)` lines | Compare the count of `Ruling (user)` lines against `<Y>`. If fewer than `<Y>` rulings are recorded, re-present the remaining unruled findings to the user before proceeding. Once all `<Y>` rulings are present: if rulings let the slice stand as-is without code changes, check current `HEAD` against `<b7>` (the round-4 reviewed head commit from the preceding `fix round 4/4` line); if `HEAD == <b7>`, write `complete (commits <base7>..<b7>, review clean[, <K> user rulings])` and proceed to the next slice; if `HEAD != <b7>`, stop and ask the user how to handle the unreviewed commits past `<b7>`. If rulings direct code changes, start a fresh 4-round fix series (round 1/4) with `FIX_BASE` anchored to the round-4 `<b7>` commit (from the preceding `fix round 4/4` line, not current `HEAD`, in case a crash occurred after new commits landed before the round line was written) with the user-directed changes as findings. |
| No state line for this slice | Set `BASE` = previous slice's `complete` `<head7>` (for the first slice, the last setup commit: `git log -n1 --format=%H -G'^Pre-flight:' -- <folder>/log.md`, so Slice A's review excludes setup commits; if `log.md` has no `Pre-flight:` line, redo pre-flight first, see step 1a). If no commits exist past `BASE` (unstarted, or crashed before first commit), dispatch or resume the implementer from `BASE`. If commits exist past `BASE`: inspect the implementer report file; if implementation reported `DONE` or `DONE_WITH_CONCERNS` (matching `SKILL.md`), run the initial slice review (`bash scripts/review-package BASE HEAD ...`); otherwise resume/re-dispatch the implementer subagent. |
| `End smoke: failed … (at <h7>)` | If `HEAD == <h7>`, start fix round 1/4 ([fix-loop.md](fix-loop.md), End-smoke variant) from `<workspace>/end-smoke-findings.md`, dispatching a fresh implementer that writes `<workspace>/end-smoke-report.md`; if `HEAD != <h7>`, stop and ask the operator. |
| `End smoke: fix round <R>/4` with `0 open` | If `HEAD == <b7>`, re-run only the failed check, then `passed` or a new `failed` line (then re-run Final verification); if `HEAD != <b7>`, stop and ask the operator. |
| `End smoke: fix round <R>/4` (`R < 4`) with `>0 open` | Continue at round `<R+1>` (an interrupted implementer's state is in `<workspace>/end-smoke-report.md`). |
| `End smoke: fix round 4/4` with `>0 open`, or `escalated at cap` with fewer rulings than `<Y>` | Re-present to the user; never round 5. |
| `End smoke: escalated at cap` with all `<Y>` rulings | No code change: if `HEAD == <b7>` (`<b7>` from the preceding `End smoke: fix round 4/4` line), write `End smoke: passed (rulings accepted)`; else stop and ask the operator. Code changes: fresh round 1/4, `FIX_BASE` = `<b7>`. |

### End smoke line

After the last slice, `progress.md` carries `End smoke: pending|passed|skipped|failed|fix round|escalated` ([end-smoke.md](end-smoke.md)). On resume with every slice `complete`: no line or `pending` means rerun Final verification, then the end-smoke step; `passed`/`skipped` (including `passed (rulings accepted)`) means go to final review. After the final review, if progress.md has `End: final review clean`, do nothing but offer `solopowers:finishing-a-development-branch`; if the final review ran but that line is absent, check whether `log.md` already has the final-outcome entry before appending and committing again (no double commit). The ledger is append-only; the last `End smoke:` state line wins (ignore `Ruling (user)` lines); `failed`, `fix round` and `escalated` lines resume per the `End smoke:` rows above (the table is otherwise per slice), never by rerunning the whole smoke.

## Step-by-Step Resume Procedure

0. **Locate the isolation unit BEFORE any `wsd-workspace` call** (it silently creates an empty ledger in whatever checkout you are in). After a restart you may be in the main checkout (worktree mode) or on the default branch after `git switch main` (branch mode).
   - Derive `<slug>`: the workstream folder name minus its leading `YYYY-MM-DD-`. Run `git worktree list --porcelain` and `git branch --list 'ws/<slug>'`. Match worktrees by the exact line `branch refs/heads/ws/<slug>` (never a prefix match: `foo` vs `foo-bar`). If several candidate worktrees or branches match, stop and ask the operator.
   - **Worktree mode:** if a worktree on `ws/<slug>` exists (or any worktree whose tree contains `<folder>/log.md` with an `Isolation:` line anywhere in it), `cd` into that worktree directory. Every later step (`wsd-workspace`, `slice-brief`, ledger, `log.md`, commits) runs there.
   - **Branch mode:** if branch `ws/<slug>` exists and you are not on it, first validate with `git show ws/<slug>:<folder>/log.md` that it contains an `Isolation:` line (if not, stop and ask the operator), then run `git switch ws/<slug>` only when the working tree is clean; otherwise stop and ask the operator.
   - Read the mode from `<folder>/log.md` IN THE UNIT. **Stop and ask the operator** (never dispatch an implementer on the default branch, never run `wsd-workspace` outside the unit) if: the unit's `log.md` has no `Isolation:` line anywhere; no unit can be found but a ledger or log shows work was done; or you are on the default branch while a `ws/<slug>` branch exists and cannot be switched to.
   - Only if NO `ws/<slug>` branch or worktree exists AND no `Isolation:` line exists anywhere is this a first run, not a resume: go through the normal isolation choice ([references/isolation.md](isolation.md)).
1. From inside the unit, run `bash scripts/wsd-workspace <folder>/slices.md` to identify the resolved workspace directory.
1a. **Pre-flight check.** If `log.md` in the unit has an `Isolation:` line but no `Pre-flight:` line, setup was interrupted (no fallback to the `Isolation:` commit; `BASE` is the last `Pre-flight:` commit): before dispatching anything, redo the pre-flight scan inside the unit ([references/preflight.md](preflight.md)), apply agreed edits, and append and commit the `Pre-flight:` line. Otherwise skip pre-flight.
2. Read `<workspace>/progress.md` for slice state, and confirm the isolation mode from `log.md` in the unit (the first `Isolation: <branch|worktree> — branch <name>` line anywhere in it). Do not ask the operator to choose isolation again; if the mode in `log.md` does not match the current checkout, stop and ask.
3. If the ledger is legacy headerless and marks slices complete, confirm with the user: "Adopted existing ledger for <workstream>. Slices [X, Y] are marked complete in the ledger. Proceed with Slice [Z]?"
4. Inspect the last state line for the first incomplete slice according to the Resume Dispatch Table above.
5. Take the corresponding action from the table, carrying forward context from the preceding completed slice.
