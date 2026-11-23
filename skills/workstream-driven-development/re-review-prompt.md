# Scoped Re-Review Prompt Template

Use this template when dispatching a re-review after a fix round. The re-reviewer verifies the findings were addressed and checks the fix diff for new breakage. It is not a fresh review — the full review already happened.

**Purpose:** Verify each finding from the previous review was addressed, and that the fix itself broke nothing.

```
Subagent (general-purpose):
  description: "Re-review Slice [SLICE_ID] fix round [ROUND]"
  model: [MODEL — REQUIRED: strongest tier per SKILL.md Model Selection; an omitted
         model silently inherits the session's model]
  prompt: |
    You are re-reviewing one slice's fix round for a workstream implementation. A previous review produced findings; an implementer has attempted to fix them. Your job is to verdict each finding and inspect the fix diff — nothing else.

    ## The Slice

    Read the slice brief: [BRIEF_FILE]

    ## The Findings Under Verification

    [FINDINGS]

    Do not invent a code finding; report unresolved uncertainty as `⚠️ Cannot verify`.

    ## The Fix

    Read the implementer's report (fix reports are appended at the end):
    [REPORT_FILE]

    **Original slice review (when preserved):** [ORIGINAL_REVIEW_FILE]

    If no original review artifact exists (including legacy findings-only
    checkpoints), use the supplied findings as the complete record available.
    Do not imply unseen review content or reconstruct missing historical
    evidence. For end-smoke fixes, use the supplied end-smoke findings and
    brief acceptance boundary instead.

    Check the reported Test Evidence against the current [HEAD_SHA].

    **Fix base:** [FIX_BASE_SHA] (the head the previous review saw)
    **Head:** [HEAD_SHA]
    **Diff file:** [DIFF_FILE]

    Read the diff file once — it contains the fix commits, a stat summary,
    and the fix diff with surrounding context. Do not re-run git commands.
    If the diff file is missing, fetch the diff yourself:
    `git diff --stat [FIX_BASE_SHA]..[HEAD_SHA]` and
    `git diff [FIX_BASE_SHA]..[HEAD_SHA]`.

    Your review is read-only on this checkout. Do not mutate the working
    tree, the index, HEAD, or branch state in any way.

    ## You Do Not Dispatch Subagents

    Do all of this review yourself. Never spawn a subagent to review part
    of the diff, and never spawn another reviewer for a second opinion.
    This process already provides every review seat the work gets; a
    reviewer you spawn duplicates one of them at full cost, and its
    verdict counts for nothing. If the diff feels too large for one
    pass, review it in passes yourself and say so in your report.

    ## Scope

    Your scope is the findings list and the fix diff. Verdict every finding.
    Inspect the fix diff for new problems the fix itself introduced. A
    fix-diff change that undoes a requirement in the slice brief is new
    breakage (grade it P0-P3). Do NOT re-review code the fix did not touch:
    if you notice an issue entirely outside the fix diff, report it under
    Out-of-Scope Observations — it does not block this slice and does not
    extend the loop. A broad whole-workstream review happens after all slices
    are complete.

    ## Test Evidence by Review Type

    For slice fixes, verify RED/GREEN or refactor preservation evidence against the reviewed tip and report missing proof as `⚠️ Cannot verify`. A controller-recorded `reconstructed RED (<sha>)` line with commands, failure excerpt and GREEN satisfies RED when original output is unrecoverable; do not re-flag its ordering. End-smoke fixes are different: verify only the failed-check covering tests and report required for the end-smoke fix; do not require slice RED evidence or broader slice Test Evidence.

    The implementer re-ran the tests covering amended code and appended
    results to the report file. Treat the report as unverified claims:
    confirm the fix report names the covering tests and shows their output,
    and verify the claims against the diff. Do not re-run the suite to
    confirm their report. Run a test only when reading the code raises a
    specific doubt that no existing run answers — and then a focused test,
    never a package-wide suite.

    ## Output Format

    Audit the reported Test Evidence and report uncertainty as `⚠️ Cannot verify`;
    missing proof alone is not a code finding. Do not fabricate unrecorded RED
    evidence. Begin with the finding verdicts (write `None` when there are no
    findings), then report uncertainty separately and retain the scoped verdict format.
    Every line must be a verdict, finding with file:line, check you ran, or
    `⚠️ Cannot verify` item — no preamble or process narration.

    ### Finding Verdicts

    For each finding in The Findings Under Verification, in order:
    - **[finding one-liner]** — ADDRESSED | NOT ADDRESSED, with file:line
      evidence. "Attempted" is not addressed: the specific defect must no
      longer exist.
    Write `None` when the findings list is empty; still report any uncertainty below.

    ### Unverified / Cannot Verify

    List each unresolved uncertainty as `⚠️ Cannot verify — <item>`, including both Test Evidence gaps and requirements you cannot verify from the fix diff (for example, behavior spanning unchanged code or multiple slices). Write `None` only when neither kind remains. This is separate from findings and does not affect P0/P1 counts.

    ### New Breakage in the Fix Diff

    Anything the fix itself broke or introduced, graded P0-P3 with evidence
    (file:line, failing output, or a concrete scenario; P0/P1 without
    evidence is downgraded to P2). "None" if clean.

    Severity definitions:

    [SEVERITY_DEFINITIONS]

    ### Out-of-Scope Observations

    Issues you noticed entirely outside the fix diff. Non-blocking; the
    controller ledgers these for the final review. "None" if none.

    ### Verdict

    `Verdict: CLEAN` (every [FINDINGS] item ADDRESSED, no new P0/P1) |
    `Verdict: NEEDS FIXES (<n> P0/P1)` — list the open ones. Open P2/P3 do
    not block.
```

**Placeholders:**
- `[MODEL]` — REQUIRED: strongest tier per SKILL.md Model Selection, even for scoped
  re-reviews of small fix diffs
- `[SLICE_ID]` — the slice identifier (e.g. `A`, `A1`); `end-smoke` in the end-smoke fix loop, where "slice brief" means the findings file
- `[ROUND]` — current fix round number (e.g. `1`, `2`)
- `[BRIEF_FILE]` — the slice brief file (end-smoke fix loop: `end-smoke-findings.md` plus the `brief.md` acceptance boundary, see fix-loop.md; otherwise `bash scripts/slice-brief WORKSTREAM_FILE SLICE_ID` prints the path; same file the implementer worked from; run `scripts/` helpers by their absolute path, from the working tree)
- `[SEVERITY_DEFINITIONS]` — same text given to the original reviewer
- `[FINDINGS]` — open P0/P1 findings and spec gaps from the prior review (or end-smoke failure report, or code changes directed by user rulings),
  copied verbatim, one per bullet
- `[ORIGINAL_REVIEW_FILE]` — slice fixes: `<workspace>/findings-<ID>.md` when available; omit this input entirely for end-smoke fixes
- `[REPORT_FILE]` — the implementer's report file (fix reports appended)
- `[FIX_BASE_SHA]` — the head the previous review saw
- `[HEAD_SHA]` — current commit
- `[DIFF_FILE]` — the path `bash scripts/review-package FIX_BASE HEAD <workspace-slug> WORKSTREAM_FILE` printed

**Re-reviewer returns:** per-finding verdicts (ADDRESSED / NOT ADDRESSED),
new breakage in the fix diff, out-of-scope observations, and a round verdict.
(The controller derives whether the slice is **review clean** from this report;
the re-reviewer never evaluates whole-slice compliance).
