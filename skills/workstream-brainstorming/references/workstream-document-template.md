# Workstream Document Template and Schema

Part of `solopowers:workstream-brainstorming`.

The canonical Workstream Document is written to `docs/workstreams/YYYY-MM-DD-<topic>.md`. It serves as the single source of truth for architectural design, scope boundaries, decision provenance, and sequential slice execution used by `solopowers:workstream-driven-development`.

## Schema Guidelines

### 1. Document Completeness and Sizing
- **No Pseudo-code or Raw Implementation Code:** The Workstream Document deliberately contains no raw implementation code. Key file paths, API contracts, schema definitions, test targets, and verification commands are encouraged to eliminate ambiguity, but raw code generation belongs entirely to the slice implementer.
- **Decision Completeness:** All design choices that could require rework if decided wrong MUST be settled in the document. Incidental choices (variable names, internal helper decomposition, log message wording) are explicitly left to implementation discretion.
- **Slice Sizing:** Slices are executed by low-cost models with limited context windows. Each slice should touch 1–5 files, have clear TDD tasks (red → green → verification), explicit watch-outs, verification commands, and manual smoke test steps. If a slice requires extensive prose to be unambiguous, split it.
- **Slice Heading Grammar:** Slice headings use `### Slice <SLICE_ID>: <Slice Title>`, where `<SLICE_ID>` matches `[A-Z][0-9]*` (e.g., `A`, `A1`, `A2`). The ID is matched exactly by helper scripts (`bash scripts/slice-brief`).

---

## Canonical Template

```markdown
# <Topic> Workstream

**Date**: YYYY-MM-DD
**Status**: Planned / In Progress / Complete
**Merged**: Target branch (e.g. `dev` or `main`)
**Objective**: Clear, concise statement of the ultimate goal.

---

## Context

### Problem
What is currently wrong, inefficient, or missing?

### Approved simplification
What constraints have been agreed upon to simplify the task and avoid over-engineering?

### Target behaviour
How should the system behave once the workstream is finished?

### Deliberate simplification for this workstream
What is explicitly deferred, out of scope, or accepted as a limitation for this workstream?

### Architecture invariant
What are the strict design, folder, or boundary rules that must never be violated?

### Design decisions and assumptions

| ID | Settled decision | Why / evidence | Rejected alternative | Relied-on assumption | Revisit when |
| -- | ---------------- | -------------- | -------------------- | -------------------- | ------------ |
| D1 | [decision]       | [rationale]    | [what was rejected]  | [what this depends on] | [condition that would reopen] |

Only capture decisions where choosing differently would cause substantial rework, alter safety/correctness, change package or data boundaries, or invalidate later slices. Do not record incidental implementation choices.

### Implementation discretion

The following are intentionally left to `workstream-driven-development` and do not need resolution here:
- Variable naming, log message wording, helper decomposition
- Local type annotations and import mechanics (where no architecture boundary is affected)
- Fixture construction and test data
- Any choice where every reasonable pick works fine

### Unresolved design blockers

{List any remaining open design questions that block approval, or state `None`.}

---

## Workstream scope

**In scope**
- Bullet 1
- Bullet 2

**Out of scope**
- Bullet 1
- Bullet 2

---

## Key files

| File | Package | Current role |
| ---- | ------- | ------------ |
| `path/to/file` | Name or `@pkg` | Brief description of its role in this workstream |

---

## Scoped workstream slices

### Slice A: <Slice Title>

**Goal**: What does this slice achieve?

#### Tasks

**`file/to/modify`**
- [ ] Write the failing test for the exact behavior this slice introduces or changes
- [ ] Run the focused test command and verify the failure for the expected reason
- [ ] Implement the minimum production change required for that behavior
- [ ] Run the focused test again and verify it passes
- [ ] Commit the slice changes once the focused behavior and slice verification are green

#### Watch out
- Caveats, risks, or API constraints

#### Verification
- Commands to run and assertions to check (use the project's actual test/build tooling)

#### Manual smoke test
- Setup / preconditions the user needs before testing
- Explicit user actions to perform
- Expected visible or behavioral outcome to confirm

#### Carry-forward
- State, APIs, or schema elements established in this slice that the next slice assumes to be present.

*(Repeat for Slice A1, Slice A2, or other sequentially ordered slice IDs matching `[A-Z][0-9]*`.)*

---

## Final verification

Run all of the following before handoff. Each must pass clean:
- [ ] Tests pass
- [ ] Type check passes
- [ ] Linter passes
- [ ] Formatter passes

---

## Success criteria

All criteria met:
- [ ] Specific behavior 1
- [ ] Specific behavior 2
```
