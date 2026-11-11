# Optional External Harness Review

Part of `solopowers:workstream-brainstorming`.

The supplemental External Harness Review is an opt-in, user-coordinated audit, off by default (see [opt-ins.md](opt-ins.md)). It reviews the workstream folder: `brief.md` and `slices.md` together; `log.md` is excluded. The primary agent session (Harness A) owns brainstorming, internal adversarial review, git commits, package creation, report verification, finding adjudication, document revisions, and handoff to `solopowers:workstream-driven-development`.

Harness B is an independent, user-launched reviewer session with no bridge to Harness A. Harness B is strictly read-only with respect to the workstream folder, reading only Git objects anchored at the package commit. The folder `docs/workstreams/YYYY-MM-DD-<topic>/` remains the only canonical design artifact.

## Supporting Tools and Artifacts

Run each helper by its absolute path, from the working tree you're executing in (never `cd` into the skill directory).

- `bash scripts/external-review-workspace WORKSTREAM_FOLDER` — Creates a local self-ignoring `.solopowers/workstream-reviews/...` audit workspace. It is append-only by protocol, not durable archival storage.
- `bash scripts/external-review-package initial WORKSTREAM_FOLDER` — Requires `brief.md` and `slices.md` tracked and committed (unstaged or staged changes to either fail; `log.md` is ignored). Creates a commit- and blob-anchored package manifest writes the canonical launch instruction for Harness B to `LAUNCH_FILE` (printed as the first stdout line) and prints it.
- `external-workstream-document-reviewer-prompt.md` — Harness B’s dedicated contract prompt.
- `bash scripts/external-review-report publish PACKAGE DRAFT` — Mechanically validates and publishes Harness B’s report draft.
- `bash scripts/external-review-report verify PACKAGE REPORT` — Runs on Harness A to verify cryptographic integrity and schema compliance of the report before adjudication.

## State Machine and Lifecycle

1. **A-internal-ready:** The mandatory internal document review (`workstream-document-reviewer-prompt.md`) has passed (`Approved`), decision provenance is complete (`slices.md` Assumptions and design decisions), and the workstream folder is committed. External review runs after this gate and before the operator reviews `brief.md`.
2. **external-skipped:** If the operator did not opt in (`external review=off` in `log.md`), skip this protocol and proceed directly to the operator's review of `brief.md`, then WDD.
3. **initial-package:** Harness A runs `bash scripts/external-review-package initial WORKSTREAM_FOLDER`. Harness A reads `LAUNCH_FILE` (first stdout line) and, in the SAME message and without being asked, pastes its contents verbatim in a fenced code block for the user to paste into Harness B, then waits. No paraphrasing; never only the path or digest.
4. **initial-report:** Harness B writes its draft and publishes via `bash scripts/external-review-report publish PACKAGE DRAFT`. Harness A runs `bash scripts/external-review-report verify PACKAGE REPORT`, then enters adjudication, even when the blocker count is zero.
5. **A-adjudication:** Harness A accepts or rejects findings with the user:
   - Commit accepted implementation concerns into the relevant slice's Tasks in `slices.md`, Watch out, or Verification guidance.
   - Advisory-only or empty reports need no document edit.
   - If no accepted design blocker exists, external review ends after this adjudication.
6. **confirmation-package:** Only if an accepted design blocker required a committed revision of `brief.md` or `slices.md`, Harness A creates a confirmation package:
   ```bash
   bash scripts/external-review-package confirmation WORKSTREAM_FOLDER \
     --prior-report "$REPORT_PATH" \
     --dispositions "$DISPOSITIONS_FILE" \
     --affected-area "$AFFECTED_AREA"
   ```
   Same relay rule: read `LAUNCH_FILE`, paste its contents verbatim in a fenced code block in the same message, unprompted, then wait.
7. **confirmation-report:** Harness B verifies the prior report, then reviews only the accepted dispositions, listed affected areas, and resulting regressions. Harness A verifies and adjudicates the confirmation report. If no accepted blocker remains, external review ends. A newly evidenced blocker requires explicit user authorization before any further pass; no third pass is automatic.

## Finding Classification

- **Design Blocker:** Requires altering a settled architectural decision/invariant, public or inter-slice contract, safety/correctness/data-loss property, scope or feasibility premise, or slice sequencing/dependency.
- **Implementation Concern:** Refinements or clarifications that fit within existing decisions and can be folded into a slice's Tasks, Watch out, or Verification guidance.
- **Advisory:** Non-blocking observations or suggestions that do not require changes.

> [!NOTE]
> Harness B's `Ready for user approval/WDD` recommendation does not override the user, who remains the sole coordinator and decision-maker.

## Package Format (folder review)

The package records `Workstream-Path` (the folder), `Brief-Blob-OID`, `Slices-Blob-OID`, and `Workstream-SHA256` (SHA-256 of the text `<brief-blob-oid>\n<slices-blob-oid>\n`, which is unambiguous because blob OIDs are fixed-length and content-addressed). Reports must echo these fields. A confirmation package requires the combined digest to differ from the initial package's.

Incompatible with the earlier single-file format: tools take the folder path (not a file), and the single `Blob-OID` field is replaced by the two blob fields. Packages and reports written in the old format fail validation; regenerate them.
