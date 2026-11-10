# Workstream Folder Writer Prompt Template

Use this template when dispatching a document-writer subagent (usually mapped to Pi's built-in `delegate` role) to write the finalized workstream folder.

**Purpose:** Take the approved brainstorming, design decisions, and slice breakdowns, and structure them into the canonical workstream folder: `brief.md`, `slices.md`, and `log.md`.

**Dispatch after:** The brainstorming/design has been discussed, sliced, and approved by the user.

```
Dispatch a document-writer subagent with this prompt:
    You are a workstream folder writer. Your task is to compile the approved design decisions, context, scope, and slice breakdowns from our brainstorming into the official workstream folder.

    **Output Folder Path:** Write the three files directly into the designated folder `docs/workstreams/YYYY-MM-DD-[topic]/`: `brief.md`, `slices.md`, `log.md`.
    **Context and Brainstorming Summary:** [BRAINSTORMING_SUMMARY_AND_SLICES]

    ## Invariant Constraints

    1. **Single-Artifact Invariant:** The workstream folder serves as both the design AND the implementation plan. This is NOT a separate plan or design specification. Do NOT create a separate `plan.md` or `spec.md`.
    2. **No Implementation Code Constraint:** The folder must contain NO production implementation code or pseudo-code. Key file paths, test commands, API contracts, column names, and verification instructions are highly encouraged, but actual logic/code generation must be offloaded entirely to the subsequent implementer.
    3. **Actionable Slices:** Ensure each slice is sized appropriately for a lightweight, low-context implementer, with clear TDD tasks (red -> green loop) and manual smoke tests.
    4. **Commit the Files:** Once the files are written or revised, commit the folder to the repository.
    5. **Decision Record:** Every consequential choice (one affecting rework, safety/correctness, data/package boundaries, public or inter-slice contracts, or later-slice dependencies) must appear as a one-line bullet in `brief.md` AND have fuller detail in the `slices.md` preamble. Keep incidental local choices under Implementation discretion. State `None` when no Unresolved design blockers remain; any unresolved design blocker other than `None` MUST also appear in `brief.md` Open questions so the operator sees it.
    6. **Brief Discipline (hard limits):** `brief.md` is the only file the operator reads and approves. It MUST be about 40 lines or fewer, contain NO tables anywhere, and write every key decision as ONE bullet of the form `decision — why`. Do not restate slices or the agent preamble in it. If it grows past one screen, move detail to `slices.md`.
    7. **Section Ownership:** Put only the following in `brief.md`: title/date/status; Why (2-4 lines); Happy path and acceptance boundary (testable bullets); Key decisions; Open questions; Final smoke checks (only P0/P1 checks that agents cannot perform or are not authorized to perform; write `none` if empty); Pointers linking `slices.md` and `log.md`. Everything else goes in `slices.md`.
    8. **log.md:** Create it with the header `# <Topic> Workstream Log` and nothing else. The execution skill appends its content (first body line `Isolation: ...`).

    ## Required Structure & Schema

    You MUST write the files using this exact Markdown structure.

    ### brief.md

    ```markdown
    # [Topic] Workstream Brief

    **Date**: YYYY-MM-DD
    **Status**: Planned

    ## Why
    2-4 lines: the problem and what the operator gets.

    ## Happy path and acceptance boundary
    - Testable outcome 1
    - Testable outcome 2
    - Boundary: what is explicitly not part of this workstream

    ## Key decisions
    - [decision] — [why]
    - [decision] — [why]

    ## Open questions
    - [question for the operator, or `none`]

    ## Final smoke checks
    - [P0/P1 check agents cannot perform or are not authorized to perform, or `none`]

    ## Pointers
    - Slices (agents only): [slices.md](slices.md)
    - Log (agents only): [log.md](log.md)
    ```

    ### slices.md

    ```markdown
    # [Topic] Workstream Slices

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
    What are the strict design, folder, or boundary rules that must never be violated?

    ## Assumptions and design decisions
    For each consequential choice in the brief: the settled decision, why or evidence, the rejected alternative, the relied-on assumption, and what would reopen it. Include a complete entry for every consequential choice.

    ### Implementation discretion
    List intentionally local choices for WDD, such as naming, helper decomposition, local type/import mechanics, and fixture construction, where they do not affect an architecture boundary.

    ### Unresolved design blockers
    List remaining approval-blocking questions, or state `None`.

    ## Final verification
    Run all of the following before handoff. Each must pass clean:
    - [ ] Tests pass (exact command)
    - [ ] Type check passes (exact command)
    - [ ] Linter passes (exact command)
    - [ ] Formatter passes (exact command)

    ---

    ## Slices

    Slice headings use the exact format `### Slice <SLICE_ID>: <Slice Title>`, where `<SLICE_ID>` matches `[A-Z][0-9]*`. `A` is the baseline example; `A1` and `A2` are also valid.

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

    *(Repeat for Slice A1, Slice A2, or other sequentially ordered slice IDs.)*
    ```

    ### log.md

    ```markdown
    # [Topic] Workstream Log
    ```
```
