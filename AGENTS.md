# AGENTS.md

This file contains information for AI coding agents working on this project.

## Project Overview

**solopowers** is a curated skill pack for solo developer workflows, derived from [obra/superpowers](https://github.com/obra/superpowers). It provides agent skills for workstream-doc-driven development with subagent dispatch.

## Decision Grounding

These principles drive fork/adapt/eliminate decisions when upstream (superpowers) changes arrive:

- The canonical planning artifact is one **workstream folder** with a human-readable `brief.md` (the only file the operator approves) and agent-facing `slices.md` and `log.md`. Do not reintroduce separate spec/plan artifacts.
- Execution is **sequential and slice-based**. Upstream changes that assume independent parallel tasks may need adaptation.
- **One isolation unit per workstream** (a git branch or a git worktree, chosen by the operator), never per task or slice. Workspace-isolation patterns must preserve this.
- **Human smoke testing happens once, at the end of the workstream**, limited to P0/P1 checks agents cannot perform or are not authorized to perform. Skip it when that set is empty.
- Upstream changes that remove human-in-the-loop points require adaptation.
- Operator choices (playback, external review, isolation mode) follow one convention: the agent recommends an option with a one-line reason and the operator decides.
- Upstream rigor (TDD enforcement, review discipline) should be **mapped onto workstream slices**, not upstream artifact assumptions.
- Skills must not leak superpowers-specific artifact references (`docs/superpowers/specs`, `docs/superpowers/plans`) when those concepts do not exist in solopowers.
- Review runs on the strongest model tier, implementation on the standard tier; do not route reviews to cheaper tiers.
- Upstream drift is a managed risk. Preserve compatibility where possible, but **do not compromise the workstream model** to stay in sync.

## Directory Structure

```
AGENTS.md, CLAUDE.md          # Agent guidance
skills/
  <skill-name>/
    SKILL.md                  # Main skill file (required)
    *.md                      # Supporting docs (optional)
    references/               # Supporting docs split out of SKILL.md (optional)
    scripts/                  # Executable helpers (optional)
tests/                        # Skill validation scripts
.solopowers/wsd/              # Durable workstream state (local)
```

Each skill lives in its own directory under `skills/`. Its `SKILL.md` frontmatter (`name`, `description`) is consumed by the skills CLI for discovery.

## Skill Lifecycle

When incorporating a superpowers skill, decide one of three fates:

| Fate | When | Action |
|---|---|---|
| **Fork as-is** | Skill is useful and needs no structural changes | Copy, update "human partner" refs, done |
| **Adapt** | Skill is useful but needs solo/workstream modifications | Copy, make targeted edits, verify |
| **Eliminate** | Skill doesn't apply to solo workflows | Don't include, document why in research/ |

Document decisions in `research/` (gitignored, local only).

## Hard Dependencies

`workstream-driven-development` explicitly references these skills by name:

- `using-git-worktrees` — called at workstream start when the operator chooses worktree isolation (branch mode is handled inline by workstream-driven-development)
- `finishing-a-development-branch` — called at workstream end

Changes to these skills have downstream impact on WSD. Verify compatibility before modifying.

## Agent Instructions

- Use the `solopowers:` namespace for new normative skill cross-references (e.g., `solopowers:test-driven-development`)
- When adding or modifying skills, follow the TDD-for-skills methodology in `authoring-skills`
- Update `using-solopowers/SKILL.md` skill table when adding new skills

### Verification Checklist

Run before committing skill changes:

```bash
grep -rn "human partner" skills/        # must be 0
grep -rn "superpowers:" skills/         # must be 0; exceptions require an intentional upstream-compatibility reference
diff \
  <(find skills -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort) \
  <(awk -F'`' '/^## Superseded Skills/{exit} /^\| `/{print $2}' \
    skills/using-solopowers/SKILL.md | sort)
bash tests/authoring-skills/test-render-graphs.sh
bash tests/skill-size/test-skill-size.sh
bash tests/skill-helper-paths/test-wsd-helper-paths.sh
bash tests/skill-layout/test-no-dev-files-in-skills.sh
bash tests/workstream-driven-development/test-slice-brief
bash tests/workstream-driven-development/test-wsd-repo-guard
bash tests/workstream-brainstorming/test-external-review-tools
```

The inventory comparison verifies the current skill table in `using-solopowers` against the actual skill directories; migration aliases in `## Superseded Skills` are intentionally excluded.

## Releases

Versioning is SemVer, starting at `v1.0.0`, with annotated tags on `main`. Numbering is our own: upstream (superpowers) tags are not ours and are never fetched (`remote.upstream.tagOpt = --no-tags`).

A **breaking change** (major bump) is any of the following:

- a skill removed or renamed without a `## Superseded Skills` alias in `using-solopowers`
- a change to the workstream folder contract: location (`docs/workstreams/YYYY-MM-DD-<topic>/`), file set (`brief.md`, `slices.md`, `log.md`), or markers skills parse (e.g. `Final review: clean`, `Isolation:` in `log.md`), unless existing in-flight workstreams keep working unchanged
- a change to the `.solopowers/wsd/` local state layout, unless existing in-flight workstreams keep working unchanged
- a change to a helper script interface
- an incompatible change to how WSD calls `using-git-worktrees` / `finishing-a-development-branch` (name, inputs, outcomes)
- dropping a harness from the dispatch tables

New skills or backwards-compatible behavior changes are minor; fixes are patch.

Procedure (always pass `-R dtbndr/solopowers` to `gh`). `verify.yml` covers only part of the checklist, so the local run stays required.

1. The Verification Checklist passes locally.
2. Branch from an up-to-date `main` (`git switch -c release/vX.Y.Z`; not `ws/…`, which is for workstreams) and move `CHANGELOG.md` `Unreleased` entries under `## [X.Y.Z] - YYYY-MM-DD`.
3. Commit, push the branch, and open a PR: `git push -u origin HEAD`, then `gh pr create -R dtbndr/solopowers --fill`. Direct pushes to `main` are rejected by the "Protect main" ruleset.
4. Wait for `verify` on the PR: `gh pr checks <n> -R dtbndr/solopowers --watch --fail-fast`. Then merge with the admin override: `gh pr merge <n> -R dtbndr/solopowers --admin --squash --delete-branch`. The override is needed because you cannot approve your own PR; it skips every ruleset rule, so never merge before `verify` is green.
5. `git switch main && git pull --ff-only`, then `SHA=$(git rev-parse HEAD)`. The squash merge created a new commit, so the PR run does not cover it: wait for the push-triggered run on that exact SHA (the run may take a few seconds to register): `gh run watch -R dtbndr/solopowers --exit-status $(gh run list -R dtbndr/solopowers --workflow verify.yml --commit "$SHA" --json databaseId -q '.[0].databaseId')`. If the run id is empty (run not registered yet), wait a few seconds and rerun the lookup. If CI is red, fix forward through another PR and repeat steps 1-5; never tag a red commit.
6. Tag that exact commit, never a stale local `HEAD`: `git tag -a vX.Y.Z -m "vX.Y.Z" "$SHA"`, then `git push origin vX.Y.Z` (never `git push --tags`).
7. `awk '/^## \[X.Y.Z\]/{f=1;next} /^## \[/{f=0} f' CHANGELOG.md | gh release create vX.Y.Z -R dtbndr/solopowers --verify-tag --notes-file -`

Release tags are immutable: the GitHub ruleset "Protect release tags" blocks deleting or moving any `v*` tag, with no bypass. Do not retag a published version; ship a new patch release instead. Only if a tag was pushed to the wrong commit before anyone pinned it, the operator must temporarily disable that ruleset (repo Settings > Rules) to fix it, then re-enable it.
