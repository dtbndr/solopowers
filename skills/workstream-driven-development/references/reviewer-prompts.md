# Constructing Reviewer Prompts

Part of `solopowers:workstream-driven-development`.

Run helpers by their absolute path, from the working tree you are executing in.

Per-slice reviews are slice-scoped gates; the broad review happens once at the final whole-workstream review. When filling the reviewer template:

- Do not add open-ended directives like "check all uses" or "run race tests if useful" without a slice-specific reason.
- Do not ask a reviewer to re-run tests the worker already ran — the worker's report carries the test evidence.
- Do not pre-judge findings — never instruct a reviewer to ignore or not flag a specific issue. If the prompt contains "do not flag," "don't treat X as a defect," or "the workstream chose" — stop: you are pre-judging.
- The controller fills `[ACCEPTANCE_BOUNDARY]` from `brief.md`'s "Happy path and acceptance boundary" section.
- Copy binding requirements verbatim from the slice header in `slices.md` into the global-constraints block.
- Pass the diff as a file using `bash scripts/review-package BASE HEAD <workspace-slug> WORKSTREAM_FILE` with the recorded `BASE` commit (never `HEAD~1`).
- Do not paste accumulated prior-slice history into later dispatches.
- Dispatch fix subagents for Critical and Important findings. Record Minor findings in the progress ledger as deferred minors.
- Findings labeled workstream-mandated are the user's decision: present the finding and the workstream text to the user.
