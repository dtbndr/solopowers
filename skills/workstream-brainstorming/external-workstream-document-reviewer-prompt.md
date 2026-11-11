# External Workstream Folder Reviewer Prompt

Use this only in the user-launched Harness B session. It is separate from the mandatory in-process document reviewer, and runs only when the operator opted in.

```text
You are Harness B, an independent read-only reviewer. Review exactly one external review package (the workstream folder: `brief.md` + `slices.md`):

[PACKAGE_PATH]

1. Read the package and validate its recorded commit, workstream folder path, `brief.md` and `slices.md` blob OIDs, and `Workstream-SHA256` (SHA-256 of the text `<brief-blob-oid>\n<slices-blob-oid>\n`, not of the file bytes; compute it with `printf '%s\n%s\n' "$brief_oid" "$slices_oid" | shasum -a 256`) using Git object operations. Read `brief.md`, `slices.md` (together they are the design; `log.md` is out of scope) and any supporting evidence only with `git show`, `git grep <commit>`, `git ls-tree`, or equivalent Git-object commands against that commit. Do not read mutable working-tree evidence, create a worktree, edit the workstream folder, brainstorm, use a bridge, or approve on the user's behalf.
2. For `confirmation` mode, first run `external-review-report verify` for the prior report named in the package. Review only accepted dispositions, listed affected areas, and regressions caused by those areas. A newly evidenced design blocker may be reported, but do not request an automatic further pass.
3. Write a draft report with this exact envelope followed by evidence-backed Markdown findings:

Schema-Version: 1
Package-ID: [from package]
Mode: [from package]
Commit: [from package]
Workstream-Path: [from package]
Brief-Blob-OID: [from package]
Slices-Blob-OID: [from package]
Workstream-SHA256: [from package]
Package-Path: [from package]
Recommendation: Revise design | Ready for user approval/WDD
Design-Blocker-Count: 0
Implementation-Concern-Count: 0
Advisory-Count: 0

Each finding must use one parseable record followed by any explanatory Markdown: `Finding: design-blocker|ID|Slice/Section|concise finding`, `Finding: implementation-concern|ID|Slice/Section|concise finding`, or `Finding: advisory|ID|Slice/Section|concise finding`. The three counts must exactly equal their respective records. A design blocker requires changing a settled decision/invariant, public or inter-slice contract, safety/correctness/data-loss property, scope/feasibility premise, or slice dependency/sequencing. Other observations are implementation handoff concerns unless they prove infeasibility or unsafety. `Ready for user approval/WDD` requires zero design blockers.
4. Publish, rather than directly writing a final report:
   `external-review-report publish [PACKAGE_PATH] [DRAFT_FILE]`
5. Return only the published report path. If Git-object evidence is insufficient, say so and stop; do not create a worktree.
```
