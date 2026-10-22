# Optional External Harness Review

Part of `solopowers:workstream-brainstorming`.

The supplemental External Harness Review is an optional, user-coordinated audit. The primary agent session (Harness A) owns brainstorming, internal adversarial review, git commits, package creation, report verification, finding adjudication, document revisions, and handoff to `solopowers:workstream-driven-development`.

Harness B is an independent, user-launched reviewer session with no bridge to Harness A. Harness B is strictly read-only with respect to the canonical Workstream Document, reading only Git objects anchored at the package commit. The Workstream Document at `docs/workstreams/YYYY-MM-DD-<topic>.md` remains the only canonical design artifact.

## Supporting Tools and Artifacts

- `bash scripts/external-review-workspace WORKSTREAM_FILE` — Creates a local self-ignoring `.solopowers/workstream-reviews/...` audit workspace. It is append-only by protocol, not durable archival storage.
- `bash scripts/external-review-package initial WORKSTREAM_FILE` — Creates a commit- and blob-anchored package manifest and prints the canonical launch instruction for Harness B.
- `external-workstream-document-reviewer-prompt.md` — Harness B’s dedicated contract prompt.
- `bash scripts/external-review-report publish PACKAGE DRAFT` — Mechanically validates and publishes Harness B’s report draft.
- `bash scripts/external-review-report verify PACKAGE REPORT` — Runs on Harness A to verify cryptographic integrity and schema compliance of the report before adjudication.

## State Machine and Lifecycle

1. **A-internal-ready:** The mandatory internal document review (`workstream-document-reviewer-prompt.md`) has passed (`Approved`), decision provenance is complete in the Context section, and the canonical Workstream Document is committed.
2. **external-skipped:** If the user declines external review, proceed directly to user review and WDD.
3. **initial-package:** Harness A runs `bash scripts/external-review-package initial WORKSTREAM_FILE`. The user copies the emitted launch instruction and pastes it into Harness B.
4. **initial-report:** Harness B writes its draft and publishes via `bash scripts/external-review-report publish PACKAGE DRAFT`. Harness A runs `bash scripts/external-review-report verify PACKAGE REPORT`, then enters adjudication, even when the blocker count is zero.
5. **A-adjudication:** Harness A accepts or rejects findings with the user:
   - Commit accepted implementation concerns into the relevant canonical slice's Tasks, Watch out, or Verification guidance.
   - Advisory-only or empty reports need no document edit.
   - If no accepted design blocker exists, external review ends after this adjudication.
6. **confirmation-package:** Only if an accepted design blocker required a committed canonical decision revision, Harness A creates a confirmation package:
   ```bash
   bash scripts/external-review-package confirmation WORKSTREAM_FILE \
     --prior-report "$REPORT_PATH" \
     --dispositions "$DISPOSITIONS_FILE" \
     --affected-area "$AFFECTED_AREA"
   ```
7. **confirmation-report:** Harness B verifies the prior report, then reviews only the accepted dispositions, listed affected areas, and resulting regressions. Harness A verifies and adjudicates the confirmation report. If no accepted blocker remains, external review ends. A newly evidenced blocker requires explicit user authorization before any further pass; no third pass is automatic.

## Finding Classification

- **Design Blocker:** Requires altering a settled architectural decision/invariant, public or inter-slice contract, safety/correctness/data-loss property, scope or feasibility premise, or slice sequencing/dependency.
- **Implementation Concern:** Refinements or clarifications that fit within existing decisions and can be folded into a slice's Tasks, Watch out, or Verification guidance.
- **Advisory:** Non-blocking observations or suggestions that do not require changes.

> [!NOTE]
> Harness B's `Ready for user approval/WDD` recommendation does not override the user, who remains the sole coordinator and decision-maker.
