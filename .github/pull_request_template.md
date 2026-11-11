## Description

<!-- Briefly describe the purpose and scope of this pull request. -->

## Decision Grounding (`AGENTS.md`)

- [ ] Planning artifact is a single workstream folder (`brief.md`, `slices.md`, `log.md`); no separate spec/plan artifacts
- [ ] Follows sequential, slice-based execution with one isolation unit (a branch or a worktree) per workstream
- [ ] Human smoke testing happens once, at the end of the workstream, limited to P0/P1 checks agents cannot perform (skipped when none)
- [ ] No leaked superpowers-specific artifact references (`docs/superpowers/specs`, `docs/superpowers/plans`)
- [ ] Uses `solopowers:` namespace for normative skill cross-references

## Verification Checklist

Run the full **Verification Checklist** in `AGENTS.md` locally before requesting review. It is the source of truth; do not rely on a partial list.

- [ ] Every command in the `AGENTS.md` Verification Checklist passed (greps return 0, the skill inventory diff is empty, all test scripts exit 0)

## Changelog

- [ ] `CHANGELOG.md` `[Unreleased]` has a line for this change, or the change is not user-visible
