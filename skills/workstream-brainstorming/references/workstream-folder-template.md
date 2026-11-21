# Workstream Folder Template and Schema

Part of `solopowers:workstream-brainstorming`.

The canonical planning artifact is a **workstream folder** written to `docs/workstreams/YYYY-MM-DD-<topic>/` containing three files. It is the single source of truth for design, scope, decision provenance, and sequential slice execution used by `solopowers:workstream-driven-development`.

| File | Audience | Purpose |
| ---- | -------- | ------- |
| `brief.md` | The operator | The only file the operator approves. One screen, about 40 lines max. |
| `slices.md` | Agents only | Agent preamble plus the slices. As verbose as needed. |
| `log.md` | Agents only | Execution log, owned by the execution skill. Starts with a header and an `Opt-ins:` line. |

Only `brief.md` needs operator approval. `slices.md` and `log.md` need none.

## Schema Guidelines

### 1. Completeness and Sizing
- **No Pseudo-code or Raw Implementation Code:** The folder deliberately contains no raw implementation code. Key file paths, API contracts, schema definitions, test targets, and verification commands are encouraged to eliminate ambiguity, but raw code generation belongs entirely to the slice implementer.
- **Decision Completeness:** All design choices that could require rework if decided wrong MUST be settled. Incidental choices (variable names, internal helper decomposition, log message wording) are explicitly left to implementation discretion.
- **Slice Sizing:** Size each slice to fit the implementer's available context and the behavior's complexity, dependencies, and verification burden—not a file-count proxy. Keep a slice cohesive and independently verifiable; split when its objective, dependencies, or verification cannot be handled clearly in one worker context. State the behavior or refactor objective, relevant tests/evidence, explicit watch-outs, and verification commands (no per-slice manual smoke tests).
- **Slice Heading Grammar:** Slice headings in `slices.md` use `### Slice <SLICE_ID>: <Slice Title>`, where `<SLICE_ID>` matches `[A-Z][0-9]*` (e.g., `A`, `A1`, `A2`). The ID is matched exactly by helper scripts (`slice-brief`).

### 2. Section Ownership
- `brief.md` holds what the operator must judge: why, happy path and acceptance boundary, key decisions, open questions, and final smoke checks.
- `slices.md` holds everything agents need: objective, scope, key files, architecture invariant, fuller assumptions and design-decision detail, implementation discretion, unresolved blockers, final-verification commands, and the slices.
- Do not duplicate content across files. The brief links to the other two files and does not restate them.

### 3. Brief Rules
- Roughly one screen: about 40 lines maximum.
- No tables anywhere in `brief.md`.
- Each key decision is ONE bullet: `decision — why`.
- Final smoke checks list only P0/P1 checks that agents cannot perform or are not authorized to perform. Write `None` if there are no such checks; the operator runs them once at workstream end.

---

## Canonical Template: `brief.md`

```markdown
# <Topic> Workstream Brief

**Date**: YYYY-MM-DD
**Status**: Planned / Approved / Done

## Why
2-4 lines: the problem and what the operator gets.

## Happy path and acceptance boundary
- Testable outcome 1 (what "done" looks like)
- Testable outcome 2
- Boundary: what is explicitly not part of this workstream

## Key decisions
- <decision> — <why>
- <decision> — <why>

## Open questions
- <question that needs the operator, or `none`>

## Final smoke checks
- <only P0/P1 checks agents cannot or are not authorized to perform (provider/quota use, deploy, DNS/email/account changes, physical device); `None` if empty>

## Pointers
- Slices (agents only): [slices.md](slices.md)
- Log (agents only): [log.md](log.md)
```

## Canonical Template: `slices.md`

```markdown
# <Topic> Workstream Slices

Agent-facing. The operator does not need to read this file.

## Objective
Clear, concise statement of the ultimate goal.

## Scope
**In scope**
- Bullet 1

**Out of scope**
- Bullet 1

## Key files
- `path/to/file` (`@pkg`): brief description of its role in this workstream

## Architecture invariant
Strict design, folder, or boundary rules that must never be violated.

## Assumptions and design decisions
Fuller detail behind the brief's key decisions: for each consequential choice, the settled decision, why or evidence, the rejected alternative, the relied-on assumption, and what would reopen it. Cover only choices where deciding differently would cause substantial rework, alter safety/correctness, change package or data boundaries, or invalidate later slices.

### Implementation discretion
Intentionally left to `workstream-driven-development`:
- Variable naming, log message wording, helper decomposition
- Local type annotations and import mechanics (where no architecture boundary is affected)
- Fixture construction and test data
- Any choice where every reasonable pick works fine

### Unresolved design blockers
{Remaining open design questions that block approval, or `None`.}

## Final verification
Run all applicable commands before final handoff and record exact commands/results. Every required final verification command must pass. Any failing required check blocks completion; if the operator changes scope, document that change and ensure every check that remains required passes.
- [ ] Tests: command and result, including known pre-existing failures
- [ ] Type check: command and result
- [ ] Linter: command and result
- [ ] Formatter: command and result

---

## Slices

### Slice A: <Slice Title>

**Goal**: What does this slice achieve?

#### Tasks

**`file/to/modify`**
- [ ] For intentional behavior changes, establish meaningful RED before editing for the missing behavior; a relevant existing test may qualify only if verified to fail for that reason. For pure refactors, identify the affected contract and capture matching or demonstrably equivalent before/after evidence; add targeted characterization coverage before editing when existing checks do not exercise a material affected contract. For mixed work, do both for their respective changes.
- [ ] Run focused checks and record exact commands/results; distinguish verified unchanged baseline failures from new failures.
- [ ] Implement the specified change with minimum scope, then rerun relevant focused checks and record outcomes.
- [ ] Before reporting slice DONE, run the full project-required verification suite and report actual results. Fix regressions and identify verified unchanged baseline failures separately; do not describe a failing suite as green. An unchanged baseline failure does not by itself block slice handoff, but never waives final workstream verification, where every required check must pass.
- [ ] Commit the slice changes only after implementation and required slice verification are complete.

#### Watch out
- Caveats, risks, or API constraints

#### Verification
- Commands to run and assertions to check (use the project's actual test/build tooling)

#### Carry-forward
- State, APIs, or schema elements established in this slice that the next slice assumes to be present.

*(Repeat for Slice A1, Slice A2, or other sequentially ordered slice IDs matching `[A-Z][0-9]*`.)*
```

## Canonical Template: `log.md`

Brainstorming creates `log.md` with the header `# <Topic> Workstream Log` and one `Opt-ins:` line recording the operator's choices (see [opt-ins.md](opt-ins.md)); nothing else (it is committed with the folder). The execution skill (`solopowers:workstream-driven-development`) owns its content and only appends after it: `Isolation: <branch|worktree> — branch <name>`, then `Pre-flight:`, `Smoke:` lines, the `Final review:` outcome and the `P2/P3:` entry (nothing else).

```markdown
# <Topic> Workstream Log

Opt-ins: playback=<on|off>, external review=<on|off>
```
