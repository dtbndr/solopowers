---
name: workstream-brainstorming
description: "Use when exploring feature ideas, multi-file changes, or behavior changes that need a project-specific design and approved Workstream Document before implementation."
---

# Workstream Brainstorming

Help turn ideas into fully formed designs and sequential execution slices through natural collaborative dialogue, culminating in a single **Workstream Document**.

Start by understanding the current project context, then ask questions one at a time to refine the idea. Once you understand what you're building, present the design and get user approval.

<HARD-GATE>
Do NOT invoke any implementation skill, write any code, scaffold any project, or take any implementation action until you have presented a design/workstream and the user has approved it. This applies to EVERY project regardless of perceived simplicity.
</HARD-GATE>

## Anti-Pattern: "This Is Too Simple To Need A Design"

Every project goes through this process. A todo list, a single-function utility, a config change — all of them. "Simple" projects are where unexamined assumptions cause the most wasted work. The design can be short (a few sentences for truly simple projects), but you MUST present it and get approval.

## The Workstream Document Concept

We explicitly do NOT split design and implementation planning into separate documents. Instead, we capture both in a single **Workstream Document** written under `docs/workstreams/YYYY-MM-DD-<topic>.md`.

A Workstream Document contains:

1. **Metadata**: Title, Date, Status (Planned/In Progress/Complete), Objective, Target Branch.
2. **Context**: Problem description, Approved simplifications, Target behavior, Deliberate simplifications, Architecture invariants, Design decisions and assumptions, Implementation discretion, Unresolved design blockers.
3. **Scope**: In scope, Out of scope.
4. **Key Files**: Table mapping file paths, packages, and their roles.
5. **Scoped Slices**: Sequential slices (Slice A, B, C...) containing Goals, TDD-structured Tasks, Watch outs, Verification steps, Manual smoke test guidelines, and Carry-forwards.
6. **Final Verification**: Comprehensive validation checklist (compilation, typecheck, tests, lint, format).
7. **Success Criteria**: Clear, testable outcomes that must be met.

This document serves as the single source of truth for both architectural design and the task checklist used by `workstream-driven-development`.

## Checklist

You MUST create a task for each of these items and complete them in order:

1. **Explore project context** — check files, docs, recent commits
2. **Ask clarifying questions** — one at a time, understand purpose/constraints/success criteria
3. **Propose 2-3 approaches** — with trade-offs and your recommendation
4. **Present design and slice breakdown** — in sections scaled to their complexity, get user approval after each section
5. **Write Workstream Document** — dispatch a `document-writer` subagent to write the Workstream Document to `docs/workstreams/YYYY-MM-DD-<topic>.md` and commit. Provide the approved design, slice breakdown, and schema.
6. **Mandatory Document Review** — dispatch a `document-reviewer` subagent to adversarially review the Workstream Document before user review. Use the template in `skills/workstream-brainstorming/workstream-document-reviewer-prompt.md`. This step is a strict gate and is never optional. Fix accepted design blockers, then run a confirmation review. Stop when zero design blockers remain. Escalate to the user if blockers persist after three rounds. Implementation concerns and advisory findings do not gate approval.
7. **User reviews Workstream Document** — ask user to review the workstream file before proceeding
8. **Transition to implementation** — invoke `workstream-driven-development` skill

## Process Flow

```dot
digraph workstream_brainstorming {
    "Explore project context" [shape=box];
    "Ask clarifying questions" [shape=box];
    "Propose 2-3 approaches" [shape=box];
    "Present design & slices" [shape=box];
    "User approves design?" [shape=diamond];
    "Dispatch document-writer to write Workstream Document" [shape=box];
    "Dispatch document-reviewer to review Workstream Document" [shape=box];
    "User reviews workstream?" [shape=diamond];
    "Invoke workstream-driven-development" [shape=doublecircle];

    "Explore project context" -> "Ask clarifying questions";
    "Ask clarifying questions" -> "Propose 2-3 approaches";
    "Propose 2-3 approaches" -> "Present design & slices";
    "Present design & slices" -> "User approves design?";
    "User approves design?" -> "Present design & slices" [label="no, revise"];
    "User approves design?" -> "Dispatch document-writer to write Workstream Document" [label="yes"];
    "Dispatch document-writer to write Workstream Document" -> "Dispatch document-reviewer to review Workstream Document";
    "Dispatch document-reviewer to review Workstream Document" -> "User reviews workstream?";
    "User reviews workstream?" -> "Dispatch document-writer to write Workstream Document" [label="changes requested"];
    "User reviews workstream?" -> "Invoke workstream-driven-development" [label="approved"];
}
```

**The terminal state is invoking workstream-driven-development.** Do NOT invoke `writing-plans` or standard implementation skills.

## Harness Dispatch

Use the table below to dispatch the document-writer and document-reviewer subagents on your harness:

| Harness | Dispatch document-writer | Dispatch document-reviewer |
|---|---|---|
| Pi | built-in `delegate` role (using `context: "fork"`) | built-in `oracle` role (using `context: "fresh"`) |
| kiro-cli | `orchestrate_subagent(role: plan-composer)` | `orchestrate_subagent(role: architecture-oracle)` |
| claude-code | `Task` tool with document-writer prompt | `Task` tool with document-reviewer prompt |
| Antigravity | describe the document-writing task in natural language; harness spawns dynamically | describe the adversarial review task... |

## The Process

**Understanding the idea:**

- Check out the current project state first (files, docs, recent commits).
- Before asking detailed questions, assess scope: if the request describes multiple independent subsystems, flag this immediately. Don't spend questions refining details of a project that needs decomposition first.
- If the project is too large for a single Workstream Document, help the user decompose it into sub-projects: what are the independent pieces, how do they relate, and what order should they be built? Then brainstorm the first sub-project through the normal design flow. Each sub-project gets its own Workstream Document → implementation cycle.
- Ask clarifying questions one at a time to refine the idea, focusing on purpose, constraints, and success criteria.

**Exploring approaches:**

- Propose 2-3 different approaches with trade-offs, leading with your recommended option and explaining why.

**Presenting the design & slice breakdown:**

- Once you understand what you're building, present the design.
- Scale each section to its complexity: cover architecture, components, data flow, testing.
- **Decompose into slices**: Break down the execution plan into sequential, logical groupings of tasks (Slice A, Slice B, Slice C...). Slices must represent clean milestones that can be independently developed, compiled, and tested.
- **Structure tasks for TDD**: Each slice should make the red → green → broader verification flow explicit. Do not leave testing as an afterthought or a vague final bullet.

**Working in existing codebases:**

- Explore the current structure before proposing changes. Follow existing patterns.
- Where existing code has problems that affect the work (e.g., a file that's grown too large, unclear boundaries, tangled responsibilities), include targeted improvements as part of the design — the way a good developer improves code they're working in.
- Don't propose unrelated refactoring. Stay focused on what serves the current goal.

**Slice sizing principles:**

- Slices are executed by low-cost models with limited context windows. Each slice must be small enough for a lightweight agent to implement without being overwhelmed.
- A well-sized slice typically touches 1-5 files and can be described in a few task bullet points without needing code snippets.
- Each task group should be small enough to carry its own TDD loop: write the failing test, verify the failure, implement the minimum change, verify the pass, then run broader slice verification.
- If a slice requires extensive explanation to be unambiguous, it is too large — split it.
- The workstream document intentionally contains no implementation code or pseudo-code. Key file paths, API contracts, database column names, schema definitions, test targets, and exact verification commands are encouraged when needed to eliminate ambiguity, but raw code generation is offloaded entirely to the implementer. This means task descriptions must be precise enough to implement without being pseudo-code themselves.

**Decision completeness:**

- By the time the workstream document is finished, all design decisions that could require rework if chosen wrong MUST be resolved. If there are two or more valid ways to implement a task, and picking the wrong one would require rework — resolve it in the document. Pick one and state it explicitly.
- The only decisions left to the implementer should be ones where any reasonable pick works fine (e.g., variable naming, internal helper decomposition, log message wording).
- If you notice ambiguity during slice authoring where "there are two ways to do this," ask: would choosing wrong cause rework? If yes, resolve it now.
- As consequential decisions are resolved during brainstorming, record them in the Design decisions and assumptions table under Context. Pass these explicitly to the document-writer — do not rely on the writer inheriting conversation history.

## Document Structure & Schema

Use this exact structure for the Workstream Document written to `docs/workstreams/YYYY-MM-DD-<topic>.md`:

````markdown
# <Topic> Workstream

**Date**: YYYY-MM-DD
**Status**: Planned / In Progress / Complete
**Merged**: Target branch (e.g. `dev` or `main`)
**Objective**: Clear, concise statement of the ultimate goal.

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

*(Repeat for Slice B, Slice C, etc.)*

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
````

## Adversarial Review and Approval

After writing the workstream document, it must pass an adversarial review using two harnesses:

- **Harness A — adversarial reviewer:** discovers and classifies evidence-backed findings.
- **Harness B — reviser/gatekeeper:** adjudicates classification, accepts or rejects findings with reasons, updates the document only for accepted blockers, and applies the convergence rule.

### Review protocol

1. Dispatch the reviewer subagent using the template in `workstream-document-reviewer-prompt.md`.
2. The reviewer classifies every finding into one of three categories:

   - **Design blocker** — must cite evidence and explain the rework/safety consequence. Includes: unresolved or contradictory behavior; safety, correctness, data-loss, architecture, or scope flaw; unsupported assumption whose failure would invalidate the design; infeasible slice sequencing or missing contract likely to cause meaningful rework.
   - **Implementation concern — deferred to WDD** — locally resolvable through TDD, compilation, slice review, or smoke testing without changing a settled decision, invariant, public contract, scope, or slice dependency. May be placed in a slice's Watch out when useful but does not block approval.
   - **Advisory** — optional clarity or polish. Never triggers another review round by itself.

3. **Approval condition:** zero unresolved design blockers. Implementation concerns and advisory findings may coexist with approval.
4. Only accepted design blockers trigger document revision.
5. After the last blocker is fixed, run one confirmation review.
6. Stop when the confirmation review reports zero design blockers.

### Round budget

Use a default budget of **three full adversarial rounds**. Reaching the budget with blockers still open triggers human escalation: narrow scope, revisit the design, accept an explicit risk, or abandon the workstream. It does not auto-approve.

The budget only bounds how long unresolved blockers may persist. It is not a minimum: approval happens as soon as a review round reports zero design blockers (see Review protocol above), without needing to exhaust the budget or repeat a clean round.

A settled decision may be challenged only with:

- new or contradictory evidence;
- identification of an undocumented dependency or inconsistency; or
- evidence that a documented revisit condition already holds.

"Another implementation might be cleaner" is insufficient.

### Pre-review checks

Before dispatching the reviewer, verify:

1. **Placeholder scan:** Any "TBD", "TODO", or vague requirements? Fix them.
2. **Slice sizing:** Could a low-cost model with limited context implement each slice from these task descriptions alone? If a slice is too large or requires too much background, split it.
3. **Decision completeness:** Are there any points where multiple valid approaches exist? For each, ask: would choosing wrong cause rework? If yes, resolve it here.
4. **Slice logical flow:** Does Slice B properly build on Slice A's carry-forward?
5. **No implementation code in the document:** Tasks describe WHAT to do, not HOW in production code.
6. **Manual smoke test quality:** Does every slice include a concrete manual smoke test with setup/preconditions, explicit user actions, and expected outcomes?

### After review

Ask the user to review the written Workstream Document:

> "Workstream Document written and committed to `docs/workstreams/YYYY-MM-DD-<topic>.md`. Please review it and let me know if you want to make any changes before we transition to `workstream-driven-development`."

Wait for approval. Once approved, invoke `workstream-driven-development` to execute.
