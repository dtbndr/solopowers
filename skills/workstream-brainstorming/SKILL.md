---
name: workstream-brainstorming
description: "Use when exploring feature ideas, multi-file changes, or behavior changes that need a project-specific design and an approved workstream brief before implementation."
---

# Workstream Brainstorming

Help turn ideas into fully formed designs and sequential execution slices through natural collaborative dialogue, culminating in a canonical **workstream folder** whose one-screen `brief.md` is the only file the operator approves.

People often haven't finished working out everything they want. Good questions help them think it through. When you understand the underlying purpose, you can make the hundreds of small decisions they never mention the way they would have made them.

<HARD-GATE>
Do NOT invoke any implementation skill, write any code, scaffold any project, or take any implementation action until you have presented a design/workstream and the user has approved it. This applies to EVERY project regardless of perceived simplicity.
</HARD-GATE>

## Anti-Pattern: "This Is Too Simple To Need A Design"

Every project goes through this process. A single-function utility, a config change, a small refactoring — all of them. "Simple" projects are where unexamined assumptions cause the most wasted work. The design can be short for truly simple projects, but you MUST present it and get user approval.

## First: Look Before You Ask

In an existing project, or when the user has provided context (docs, issue descriptions, code pointers, recent commits), inspect repository state first before asking questions. Read until you understand how relevant parts work today and what this change would touch. **Never ask what the codebase or existing docs already answer.** Do recon instead of offering it: go look deeper (code, files, or the web) and say what you looked for and found. Never reopen what the user has already decided.

## Question Craft and Conversational Rhythm

- **Ask only when it changes the build:** Ask a question only when the answer would change what gets built and neither the request nor the project answers it. Otherwise state your call and reason as a proposal the user can correct, and move forward.
- **One question per turn:** When you ask, end the message with exactly one focused question; a message that just states your call or proceeds needs none. Do not bury questions in long paragraphs or append open-ended lists of alternatives to a question.
- **Open questions first:** If the user hasn't said why they want it, ask that first, even if you can guess: one open question in their own terms, with no example answers. Use open questions for intent, core problems, and success criteria; let their words guide the design. Never add a second question in the same turn.
- **Options only when bounded:** Once the why is known and a choice can be named, sketch each option concretely enough to picture, with its trade-offs and your recommendation. Do this only for a genuine, bounded set of alternatives (e.g. database choices, protocol variants); never manufacture options for open questions. If the user has handed over the how, say you'll go with your pick.
- **Recommend when deferred:** When the user says "you decide", "just guess", or defers a choice, do not bounce the question back. Make a concrete pick, state it with brief rationale as your call, and move forward; the user can still correct it.
- **Understand how it gets made:** Read from how the user talks whether they want to discuss technical choices (give options with your pick) or hand them over (decide, and state each in one line). When there's existing work, build on what it already uses. Choices the user hasn't confirmed go in the document as your calls, not as agreed decisions.
- **Process is your call:** Where supporting files go (the workstream folder's location is fixed: `docs/workstreams/YYYY-MM-DD-<topic>/`), whether to look further, how to show something, and dispatching the writer or reviewer are yours: state them, don't ask (the internal review itself is mandatory). Approval of the design and of `brief.md` stays the user's.
- **Show, don't tell:** Whenever seeing would help more than reading (a screen, a page, a layout, a schedule), sketch it in a few lines of text next to the description.
- **Socratic probing:** Build each question on their last answer or on what you discovered in the codebase, helping them think through edge cases and failure modes.

## Exploring Approaches

Once you understand what the user wants, and before drafting the workstream folder:
- Propose 2–3 distinct approaches grounded in the codebase.
- State clear trade-offs for each option (complexity, maintenance burden, performance, risk).
- Lead with your recommended option and why.
- If the user wants to discuss technical choices, ask which direction they prefer; otherwise say you'll go with your pick. When there is genuinely only one sensible way forward, state that clearly and explain why alternatives are ill-suited.

## Concise Design Playback (~200 Words) With Opt-Out

**When nothing is open** (the user has told you why they want it, the request and project answer everything that would change what gets built, and there is one sensible way), your first message is this short design: the approach, one line on why alternatives do not fit, the design in a few lines, and the proposed sequential slice breakdown. It is the playback below, with the same opt-out and user approval.

Before writing the full Workstream Document, present a concise (~200-word) playback summarizing:
- The objective and architecture: agreed ones, or proposed ones when nothing was open
- Key design decisions: the user's settled ones, with your unconfirmed calls marked as your calls
- The proposed sequential slice breakdown

End the playback with its single approval question, which doubles as the opt-out: *"Shall I draft the Workstream Document from this, or adjust something first?"* If the user says "just write it", proceed directly to writing the Workstream Document. If they said it before seeing the approach, still send the playback, but end it with a statement such as *"Drafting the Workstream Document from this now."* instead of the question, then proceed without waiting. "Just write it" skips only the playback approval; the internal review and the user's review of `brief.md` still apply. For small tasks, the playback is short, but still wait for approval.

## Sizing the Work and Slices

- **Decompose into sequential slices:** Break the work into sequential milestones (e.g., Slice A, Slice A1, Slice A2). Slice IDs use `[A-Z][0-9]*`; IDs do not establish ordering. Each slice represents a clean milestone that can be independently developed, compiled, and tested.
- **Slice sizing principles:** Slices are executed by standard-tier workers with limited context. Each slice should touch 1–5 files and carry its own TDD cycle (failing test → minimal implementation → verification). If a slice requires extensive explanation to be unambiguous, it is too large — split it.
- **No implementation code in the document:** Key file paths, interfaces, column names, schema definitions, test targets, and exact verification commands belong in the document, but raw code generation is offloaded entirely to the slice implementer.
- **Decision completeness:** All design choices that would require rework if decided wrong MUST be settled in the document. Incidental choices (internal helpers, variable names, log message wording) are explicitly left to implementation discretion.

## The Canonical Workstream Folder

We explicitly do NOT split design and implementation planning into separate artifacts. Instead, we capture both in a single **workstream folder** written under `docs/workstreams/YYYY-MM-DD-<topic>/` with three files:

1. **`brief.md`** (the operator's file, the only one they approve; one screen, about 40 lines max, no tables): title/date/status; Why; Happy path and acceptance boundary (testable bullets); Key decisions as one-line bullets (`decision — why`); Open questions; Final smoke checks (only P0/P1 checks agents cannot perform or are not authorized to perform, else `None`); Pointers to `slices.md` and `log.md`.
2. **`slices.md`** (agents only, as verbose as needed): agent preamble (Objective, scope in/out, key files, architecture invariant, fuller assumptions and design decisions, implementation discretion, unresolved blockers, final-verification commands) followed by the sequential slices (`### Slice <ID>: <title>`, ID `[A-Z][0-9]*`) with Goal, TDD Tasks, Watch out, Verification, and Carry-forward.
3. **`log.md`** (agents only): created with the header `# <Topic> Workstream Log` only; the execution skill appends its content (`Isolation:` line first, then pre-flight result, review verdicts, P2/P3 findings, carry-forward).

For the full markdown schema, section requirements, and examples, read [references/workstream-folder-template.md](references/workstream-folder-template.md).

## Process Checklist

You MUST create a task for each of these items and complete them in order:

1. **Explore project context** — check files, docs, recent commits (look before asking).
2. **Clarifying questions** — one question per turn, open questions first. May be empty: when the why is known and nothing that changes the build is open, go straight to step 3. (Skipped with step 3 when nothing is open and there is one sensible way.)
3. **Propose 2–3 approaches** — with trade-offs and your recommendation.
4. **Design playback (~200 words)** — concise playback with opt-out before drafting.
5. **Write workstream folder** — dispatch a `document-writer` subagent to write `brief.md`, `slices.md`, and `log.md` under `docs/workstreams/YYYY-MM-DD-<topic>/` following [references/workstream-folder-template.md](references/workstream-folder-template.md) and commit.
6. **Mandatory Internal Document Review** — dispatch a `document-reviewer` subagent using `skills/workstream-brainstorming/workstream-document-reviewer-prompt.md`. This in-process gate is strict and never optional: evaluate adversarial probes and the **builder perspective** ("what would a slice implementer have to guess?"). Revise accepted issues and re-review until `Approved`. Commit the resulting workstream folder.
7. **Operator reviews `brief.md`** — ask the operator to review and approve ONLY `brief.md`; `slices.md` and `log.md` need no approval. The user may optionally run the supplemental External Harness Review (see below and [references/external-review.md](references/external-review.md)).
8. **Transition to implementation** — invoke `solopowers:workstream-driven-development`.

## Process Flow

```dot
digraph workstream_brainstorming {
    "Explore project context\n(look before asking)" [shape=box];
    "Clarifying questions\n(one per turn)" [shape=box];
    "Propose 2-3 approaches\n(with recommendation)" [shape=box];
    "Design playback (~200 words)\n(with opt-out)" [shape=box];
    "User approves approach?" [shape=diamond];
    "Dispatch document-writer\n(references/workstream-folder-template.md)" [shape=box];
    "Dispatch document-reviewer\n(workstream-document-reviewer-prompt.md)" [shape=box];
    "Reviewer reports Approved?" [shape=diamond];
    "Revise folder & commit" [shape=box];
    "Operator reviews brief.md" [shape=box];
    "Operator approves brief.md?" [shape=diamond];
    "Invoke workstream-driven-development" [shape=doublecircle style=filled fillcolor=lightgreen];

    "Explore project context\n(look before asking)" -> "Clarifying questions\n(one per turn)";
    "Explore project context\n(look before asking)" -> "Design playback (~200 words)\n(with opt-out)" [label="nothing open, one way"];
    "Explore project context\n(look before asking)" -> "Propose 2-3 approaches\n(with recommendation)" [label="nothing to ask, several approaches"];
    "Clarifying questions\n(one per turn)" -> "Propose 2-3 approaches\n(with recommendation)";
    "Propose 2-3 approaches\n(with recommendation)" -> "Design playback (~200 words)\n(with opt-out)";
    "Design playback (~200 words)\n(with opt-out)" -> "User approves approach?";
    "User approves approach?" -> "Clarifying questions\n(one per turn)" [label="no, revise"];
    "User approves approach?" -> "Dispatch document-writer\n(references/workstream-folder-template.md)" [label="yes"];
    "Dispatch document-writer\n(references/workstream-folder-template.md)" -> "Dispatch document-reviewer\n(workstream-document-reviewer-prompt.md)";
    "Dispatch document-reviewer\n(workstream-document-reviewer-prompt.md)" -> "Reviewer reports Approved?";
    "Reviewer reports Approved?" -> "Revise folder & commit" [label="no, issues found"];
    "Revise folder & commit" -> "Dispatch document-reviewer\n(workstream-document-reviewer-prompt.md)" [label="re-review"];
    "Reviewer reports Approved?" -> "Operator reviews brief.md" [label="yes"];
    "Operator reviews brief.md" -> "Operator approves brief.md?";
    "Operator approves brief.md?" -> "Revise folder & commit" [label="changes requested"];
    "Operator approves brief.md?" -> "Invoke workstream-driven-development" [label="approved"];
}
```

**The terminal state is invoking solopowers:workstream-driven-development.** Do NOT invoke `writing-plans` or standard implementation skills.

## Platform-Specific Subagent Dispatch

Use the table below to dispatch document-writer and document-reviewer subagents on your harness:

| Platform | Dispatch document-writer | Dispatch document-reviewer |
|---|---|---|
| Pi | built-in `delegate` role (`context: "fork"`) | built-in `oracle` role (`context: "fresh"`) |
| kiro-cli | `orchestrate_subagent(role: plan-composer)` | `orchestrate_subagent(role: architecture-oracle)` |
| claude-code | `Task` tool with document-writer prompt | `Task` tool with document-reviewer prompt |
| Antigravity | describe the document-writing task in natural language | describe the adversarial review task in natural language |

## Mandatory Internal Review & The Builder Perspective

The mandatory internal document review is Harness A’s in-process, read-only gate. Dispatch it with `workstream-document-reviewer-prompt.md`; its result is `Approved | Issues Found`.

In addition to standard compliance checks, the review evaluates the document from the **builder perspective**:
- *Read this as the subagent implementing each slice without talking to the author: what would you have to guess?*
- *Which file paths, interfaces, data models, error states, or test commands are ambiguous or missing?*
- *Where would an ambiguous requirement lead to rework or architectural drift?*

Address any findings, commit the updated workstream folder, and re-review until the reviewer reports `Approved`. (For ad-hoc standalone probing, `builder-check-prompt.md` is also available).

## Optional External Harness Review

External review is optional and user-coordinated. Harness A owns brainstorming, internal review, commits, package creation, report verification, finding adjudication, and WDD handoff. Harness B is an independent, user-launched reviewer session with no direct bridge; it reads only Git objects anchored at the package commit.

Run these helpers by their absolute path, from the working tree you're executing in (never `cd` into the skill directory):
- `bash scripts/external-review-workspace WORKSTREAM_FILE`
- `bash scripts/external-review-package initial WORKSTREAM_FILE`
- `external-workstream-document-reviewer-prompt.md`
- `bash scripts/external-review-report publish PACKAGE DRAFT`
- `bash scripts/external-review-report verify PACKAGE REPORT`

For full protocol details, state machine transitions, and confirmation package handling, read [references/external-review.md](references/external-review.md).

## Handoff to Implementation

Once the folder has passed internal review (and optional external review), present `brief.md` to the operator:

> "Workstream folder written and committed to `docs/workstreams/YYYY-MM-DD-<topic>/`. Please review `brief.md` (the only file that needs your approval) and let me know if you want any changes before we transition to `workstream-driven-development`."

Wait for approval of `brief.md`. Once approved, invoke `solopowers:workstream-driven-development`, handing over the workstream folder path; execution uses `<folder>/slices.md`, reads `<folder>/brief.md` for the acceptance boundary and final smoke checks, and writes `<folder>/log.md`.
