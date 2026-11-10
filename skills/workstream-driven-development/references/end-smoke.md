# End Smoke Checks

Part of `solopowers:workstream-driven-development`. Human smoke testing happens once, here: after Final verification passes, before the final review ([final-review.md](final-review.md)). No per-slice smoke pauses.

1. Read `Final smoke checks` in `<folder>/brief.md`. Write `End smoke: pending` to `progress.md`.
2. For each check, run it yourself if you can and are authorized to; record the result.
3. The remaining checks are P0/P1 checks the operator must do. Present them as a short numbered list, each with exact steps and the expected result, and ask the operator to report pass or fail per item.
4. If none remain (or the section says `None`), skip: append `Smoke: skipped (agent-verified)` to `log.md` and write `End smoke: skipped`.
5. Record the outcome in `log.md` as `Smoke: passed|failed — <one-liner>` and write `End smoke: passed` on a pass.
6. A failure is a P0/P1 finding: enter the fix loop ([fix-loop.md](fix-loop.md)) with a fresh 4-round budget and `FIX_BASE` = current `HEAD`, the operator's report as findings. When review clean, re-run the failed check (write `End smoke: pending` meanwhile).
7. Never run provider-quota, deploy, DNS, email, or account actions without explicit operator authorization.
