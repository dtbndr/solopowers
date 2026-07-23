# Workstream Document Writer Prompt Template

Use this template when dispatching a document-writer subagent (usually mapped to Pi's built-in `delegate` role) to write the finalized Workstream Document.

**Purpose:** Take the approved brainstorming, design decisions, and slice breakdowns, and structure them into the formal canonical Workstream Document.

**Dispatch after:** The brainstorming/design has been discussed, sliced, and approved by the user.

```
Dispatch a document-writer subagent with this prompt:
    You are a Workstream Document writer. Your task is to compile the approved design decisions, context, scope, and slice breakdowns from our brainstorming into the official Workstream Document.

    **Output File Path:** Write the completed document directly to the designated file path under `docs/workstreams/YYYY-MM-DD-[topic].md`.
    **Context and Brainstorming Summary:** [BRAINSTORMING_SUMMARY_AND_SLICES]

    ## Invariant Constraints

    1. **Single-Artifact Invariant:** This is a Workstream Document, which serves as both the design AND the implementation plan. This is NOT a separate plan or design specification. Do NOT create a separate `plan.md` or `spec.md`.
    2. **No Implementation Code Constraint:** The workstream document must contain NO production implementation code or pseudo-code. Key file paths, test commands, API contracts, column names, and verification instructions are highly encouraged, but actual logic/code generation must be offloaded entirely to the subsequent implementer.
    3. **Actionable Slices:** Ensure each slice is sized appropriately for a lightweight, low-context implementer, with clear TDD tasks (red -> green loop) and manual smoke tests.
    4. **Commit the File:** Once the file is written or revised, commit the canonical document to the repository.
    5. **Decision Record:** Every consequential choice—one affecting rework, safety/correctness, data/package boundaries, public or inter-slice contracts, or later-slice dependencies—must have a complete decision-table row. Keep incidental local choices under Implementation discretion. State `None` when no Unresolved design blockers remain.

    ## Required Structure & Schema

    You MUST write the document using this exact Markdown structure:

    ```markdown
    # [Topic] Workstream

    **Date**: YYYY-MM-DD
    **Status**: Planned
    **Merged**: [Target branch, e.g. dev or main]
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
    | D1 | [decision] | [rationale] | [what was rejected] | [what this depends on] | [condition that reopens it] |

    Include a complete row for every consequential choice.

    ### Implementation discretion
    List intentionally local choices for WDD, such as naming, helper decomposition, local type/import mechanics, and fixture construction, where they do not affect an architecture boundary.

    ### Unresolved design blockers
    List remaining approval-blocking questions, or state `None`.

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

    ### Slice A: [Slice Title]

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
    ```
```
