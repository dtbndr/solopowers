# Brainstorming Opt-Ins

Part of `solopowers:workstream-brainstorming`. Two ceremonies are off unless the operator opts in. Everything else (internal document review, builder check, `brief.md` approval) always runs.

| Opt-in | If on | If off (default) |
|---|---|---|
| Design playback | Concise playback (~200 words) and approval before drafting | Go from clarified scope straight to drafting the folder; the operator's only approval is `brief.md` |
| External review | Supplemental review of the drafted folder by Harness B ([external-review.md](external-review.md)) | Skipped |

## The question

Ask once, at the start: with the first clarifying question, or right after context exploration if nothing is open. One combined question that gives your recommendation and a one-line reason for each, based on the workstream's size and risk:

> "Two optional steps, both off unless you want them. Design playback (I show the design for approval before drafting): I recommend <skip|opt in> because <reason>. External review of the drafted folder in a second session: I recommend <skip|opt in> because <reason>. Which do you want?"

Recommend skip for small, low-risk, well-understood work; recommend opt in for large, cross-cutting, irreversible, or ambiguous work (playback), and for safety-, data-, or contract-critical work (external review). Operator decides. If they don't care or don't answer the choice, both are off. Ask once; do not re-ask later unless scope changes materially. If the operator opts in later, honor it.

## Recording

When creating `log.md`, include the line `Opt-ins: playback=<on|off>, external review=<on|off>` after the header. Execution appends below it.

## Playback on

Follow SKILL.md "Design Playback (Opt-In)". The operator's "just write it" still skips playback approval for that run.
