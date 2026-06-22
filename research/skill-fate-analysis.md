# Skill Fate Analysis: 8 Superpowers Skills → solopowers

Analysis of 8 obra/superpowers skills not yet addressed in solopowers, evaluated for relevance to solo developer workflows using workstream-doc-driven development with subagent dispatch.

---

## 1. dispatching-parallel-agents

**Purpose:** Run multiple subagents concurrently on independent problem domains (e.g., 3 unrelated test failures → 3 parallel fix agents).

**Solo relevance:** HIGH. The workstream-driven-development skill already dispatches subagents (implementer, reviewer) but always sequentially per slice. Parallel dispatch is valuable for:
- Running multiple independent fix subagents after a final review wave
- Debugging unrelated failures simultaneously
- Running independent research/investigation agents concurrently

**Recommendation: Fork as-is**

**Rationale:** This skill is directly complementary to workstream-driven-development. While WSD handles sequential slice execution, parallel dispatch covers the cases where the controller has multiple independent problems (post-review fix waves, multi-file test failures, independent investigations). The skill is methodology-agnostic — it teaches subagent orchestration patterns that work whether you're in a workstream or ad-hoc context. The content needs no modification; the "your human partner" phrasing should be updated to match solopowers conventions but the patterns are identical.

---

## 2. finishing-a-development-branch

**Purpose:** Guide branch completion through a structured menu: verify tests → detect environment → present options (merge/PR/keep/discard) → execute → clean up worktrees.

**Solo relevance:** HIGH. The workstream-driven-development skill explicitly calls this as a dependency: "Invoke the `finishing-a-development-branch` skill to guide the user through local merging, opening a PR, or branch cleanup." It's used once at the end of every workstream.

**Recommendation: Fork as-is**

**Rationale:** This skill is already a hard dependency of workstream-driven-development. The worktree cleanup logic (provenance checks, `.worktrees/` directory detection) is directly relevant since WSD creates worktrees via `using-git-worktrees`. The structured 4-option menu (merge/PR/keep/discard) is perfect for solo workflows — the solo developer still needs to decide what to do with completed branches. Minor adaptation: references to "your human partner" should be updated, but the process logic is identical.

---

## 3. receiving-code-review

**Purpose:** Handle code review feedback with technical rigor — verify before implementing, push back when wrong, no performative agreement, implement one item at a time.

**Solo relevance:** MEDIUM-LOW. In a pure solo workflow with subagent reviewers, the controller already mediates all review feedback. The workstream-driven-development skill has its own review mediation patterns (implementer fixes reviewer findings, controller adjudicates). There's no external human reviewer sending feedback to the agent. However, the user may provide their own review feedback after seeing results.

**Recommendation: Adapt**

**Rationale:** The core anti-patterns (no performative agreement, verify before implementing, push back with evidence) are universally valuable and should be kept. However, significant portions need modification: remove the "External Reviewers" section (no external team), remove the "your human partner's rule" framing, and integrate with the workstream review loop. The YAGNI-check pattern is useful for when the user requests changes. The skill should be shortened significantly — much of the content is about social dynamics of team review that don't apply to solo work. Recommend folding the useful principles into a shorter solopowers-native skill rather than forking verbatim.

---

## 4. requesting-code-review

**Purpose:** Dispatch a code reviewer subagent with precisely crafted context (diff package, requirements, SHAs) to catch issues before they cascade.

**Solo relevance:** MEDIUM. The workstream-driven-development skill already has its own review mechanism with dedicated prompt templates (`workstream-reviewer-prompt.md`) that produce combined compliance + quality verdicts. The superpowers `code-reviewer.md` template is simpler (single-pass quality review). However, for ad-hoc reviews outside of workstream execution (quick sanity checks, "is this approach sound?" reviews), a lightweight review dispatch is useful.

**Recommendation: Adapt**

**Rationale:** The concept is valuable but the implementation needs to defer to workstream-driven-development's review process for slice-level work. The adaptation should: (1) explicitly state it's for ad-hoc reviews, not workstream slice reviews, (2) reference the workstream-reviewer-prompt.md template for workstream contexts, (3) keep the reviewer dispatch pattern for non-workstream scenarios. The code-reviewer.md template could be simplified or unified with the workstream reviewer template. Alternatively, this could be eliminated if the team decides all reviews should go through workstream processes.

---

## 5. systematic-debugging

**Purpose:** Four-phase debugging methodology: root cause investigation → pattern analysis → hypothesis testing → implementation. Enforces "no fixes without root cause investigation first."

**Solo relevance:** HIGH. Debugging is universal. Solo developers using AI agents need this even more because agents are prone to guess-and-check patterns. The skill is methodology-agnostic and contains no team-specific references. The supporting files (root-cause-tracing.md, defense-in-depth.md, condition-based-waiting.md) are standalone technique references.

**Recommendation: Fork as-is**

**Rationale:** This is one of the most valuable skills in the superpowers pack and translates directly to solo work. The four-phase process is exactly what prevents implementer subagents from thrashing on bugs. The red flags section, rationalization table, and "3+ fixes = question architecture" rule are all applicable. The supporting technique files (root-cause-tracing, defense-in-depth, condition-based-waiting) are excellent standalone references. Only trivial changes needed: update "your human partner" references to match solopowers conventions.

---

## 6. using-git-worktrees

**Purpose:** Set up isolated git worktrees for feature work, with detection of existing isolation, native tool preference, and fallback to manual git worktrees.

**Solo relevance:** HIGH. This is already a hard dependency of workstream-driven-development: "Use the `using-git-worktrees` skill to verify/create an isolated git worktree for the entire workstream." It's called once at the start of every workstream execution.

**Recommendation: Fork as-is**

**Rationale:** This skill is already a hard dependency of workstream-driven-development and is called by name in the WSD process flow. The worktree isolation model is central to the solopowers approach — one worktree per workstream, not per slice. The detection logic (Step 0), native tool preference, git fallback, and cleanup provenance checks are all directly relevant. The submodule guard, .gitignore verification, and baseline test patterns are all good engineering practice. No modifications needed beyond "your human partner" phrasing.

---

## 7. verification-before-completion

**Purpose:** Enforce "evidence before claims" — never claim work is complete without running verification commands and reading output. Prevents "should pass" / "looks correct" assertions.

**Solo relevance:** HIGH. This is fundamental to the workstream-driven-development methodology, which has multiple verification gates (implementer self-review, slice reviewer, manual smoke test, final verification). The skill enforces the discipline that makes those gates meaningful. Without it, agents will claim slices are complete without evidence.

**Recommendation: Fork as-is**

**Rationale:** This skill is the backbone of quality assurance in the workstream flow. The "Iron Law" (no completion claims without fresh verification evidence) directly supports the WSD verification gates. The red flags list, rationalization table, and "agent said success → verify independently" pattern are all critical for solo agent-mediated workflows where there's no human watching every step. The regression test red-green verification pattern directly supports the TDD requirement in workstream-driven-development. No modifications needed.

---

## 8. writing-skills

**Purpose:** Create new skills using TDD methodology — baseline test with subagent (RED), write skill (GREEN), close loopholes (REFACTOR). Covers skill structure, discovery optimization, and bulletproofing against rationalization.

**Solo relevance:** HIGH. The solopowers project itself is about curating and extending skills. The ability to write new skills is essential for growing the solopowers pack. The TDD-for-documentation approach ensures skills actually work with agents before deployment.

**Recommendation: Adapt**

**Rationale:** The core methodology (RED-GREEN-REFACTOR for skills, skill structure, discovery optimization) is essential and should be kept. However, the skill needs significant adaptation: (1) remove/update "your human partner" references throughout, (2) update cross-references from `superpowers:` to `solopowers:` namespace, (3) trim the very long skill — it's ~500 lines and could be more concise for solo use, (4) remove Anthropic-specific references that don't apply, (5) simplify the testing methodology section since solo developers may not have the infrastructure for full pressure-scenario subagent testing. The anthropic-best-practices.md reference and some of the micro-testing patterns are valuable but could be moved to a supporting file.

---

## Summary Table

| Skill | Solo Relevance | Recommendation | Already Referenced By |
|---|---|---|---|
| `dispatching-parallel-agents` | HIGH | **Fork as-is** | Complements WSD |
| `finishing-a-development-branch` | HIGH | **Fork as-is** | WSD (explicit dependency) |
| `receiving-code-review` | MEDIUM-LOW | **Adapt** (trim significantly) | — |
| `requesting-code-review` | MEDIUM | **Adapt** (scope to ad-hoc) | — |
| `systematic-debugging` | HIGH | **Fork as-is** | — |
| `using-git-worktrees` | HIGH | **Fork as-is** | WSD (explicit dependency) |
| `verification-before-completion` | HIGH | **Fork as-is** | WSD (verification gates) |
| `writing-skills` | HIGH | **Adapt** (namespace + trim) | — |

### Tally

- **Fork as-is:** 5 skills (dispatching-parallel-agents, finishing-a-development-branch, systematic-debugging, using-git-worktrees, verification-before-completion)
- **Adapt:** 3 skills (receiving-code-review, requesting-code-review, writing-skills)
- **Eliminate:** 0 skills

### Priority Order for Implementation

1. **using-git-worktrees** + **finishing-a-development-branch** — Already hard dependencies of WSD, needed immediately
2. **verification-before-completion** — Quality backbone of WSD verification gates
3. **systematic-debugging** — Universal value, implementer subagents need this
4. **dispatching-parallel-agents** — Complements WSD for post-review fix waves
5. **writing-skills** — Needed to create new solopowers skills
6. **requesting-code-review** — Useful for ad-hoc reviews, lower priority
7. **receiving-code-review** — Lowest priority, most adaptation needed, least unique value for solo workflows
