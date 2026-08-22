---
name: finishing-a-development-branch
description: Use when implementation is complete, all tests pass, and you need to decide how to integrate the work - guides completion of development work by presenting structured options for merge, PR, or cleanup
---

# Finishing a Development Branch

## Overview

Guide completion of development work by presenting clear options and handling chosen workflow.

**Core principle:** Verify tests → Detect environment → Present options → Execute choice → Clean up.

**Announce at start:** "I'm using the finishing-a-development-branch skill to complete this work."

## The Process

### Step 1: Verify Tests

**Before presenting options, verify tests pass:**

```bash
# Run project's test suite
npm test / cargo test / pytest / go test ./...
```

**If tests fail:**

```
Tests failing (<N> failures). Must fix before completing:

[Show failures]

Cannot proceed with merge/PR until tests pass.
```

Stop. Don't proceed to Step 2.

**If tests pass:** Continue to Step 2.

### Step 2: Detect Environment

**Determine workspace state before presenting options:**

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
# Capture now, while still inside the workspace — Step 5 changes directory
# before cleanup (Step 6) needs these values
WORKTREE_PATH=$(git rev-parse --show-toplevel)
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
```

This determines which menu to show and how cleanup works:

| State | Menu | Cleanup |
|-------|------|---------|
| `GIT_DIR == GIT_COMMON` (normal repo) | Standard 3 options | No worktree to clean up |
| `GIT_DIR != GIT_COMMON`, named branch | Standard 3 options | Provenance-based (see Step 6) |
| `GIT_DIR != GIT_COMMON`, detached HEAD | Reduced 2 options (no merge) | No cleanup (externally managed) |

### Step 3: Determine Base Branch

```bash
# Try common base branches
git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null
```

Or ask: "This branch split from main - is that correct?"

### Step 4: Present Options

**Normal repo and named-branch worktree — present exactly these 3 options:**

```
Implementation complete. What would you like to do?

1. Merge back to <base-branch> locally
2. Push and create a Pull Request
3. Keep the branch as-is (I'll handle it later)

Which option?
```

**Detached HEAD — present exactly these 2 options:**

```
Implementation complete. You're on a detached HEAD (externally managed workspace).

1. Push as new branch and create a Pull Request
2. Keep as-is (I'll handle it later)

Which option?
```

**Don't add explanation** - keep options concise. Discarding the work happens only in response to the user explicitly asking for it (see "If user asks to discard" below).

### Step 5: Execute Choice

#### Option 1: Merge Locally

```bash
# Ensure CWD is in the main repository root
cd "$MAIN_ROOT"

# Merge first — verify success before removing anything
git checkout <base-branch>
git pull
git merge <feature-branch>

# Verify tests on merged result
<test command>

# Only after merge succeeds: cleanup worktree (Step 6), then delete branch
```

Then: Cleanup worktree (Step 6), then delete branch:

```bash
git branch -d <feature-branch>
```

#### Option 2: Push and Create PR

```bash
# Push branch
git push -u origin <feature-branch>
```

**Do NOT clean up worktree** — user needs it alive to iterate on PR feedback.

#### Option 3: Keep As-Is

Report: "Keeping branch <name>. Worktree preserved at <path>."

**Don't cleanup worktree.**

#### If user asks to discard

**Confirm first:**

```
This will permanently delete:
- Branch <name>
- All commits: <commit-list>
- Worktree at <path>

Type 'discard' to confirm.
```

Wait for exact confirmation.

If confirmed:

```bash
cd "$MAIN_ROOT"
```

Then: Cleanup worktree (Step 6), then force-delete branch:

```bash
git branch -D <feature-branch>
```

### Step 6: Cleanup Workspace

**Only runs for Option 1 (Merge Locally) and confirmed discard.** Options 2 and 3 always preserve the worktree.

Uses the `GIT_DIR`, `GIT_COMMON`, `WORKTREE_PATH`, and `MAIN_ROOT` values captured in Step 2 before the directory change (do not re-query them here, as `cd "$MAIN_ROOT"` has already changed the working directory).

**If `GIT_DIR == GIT_COMMON`:** Normal repo, no worktree to clean up. Done.

**If worktree path is under `.worktrees/` or `worktrees/`:** Solopowers created this worktree — we own cleanup.

```bash
cd "$MAIN_ROOT"
git worktree remove "$WORKTREE_PATH"
git worktree prune  # Self-healing: clean up any stale registrations
```

**If removal is refused** (`contains modified or untracked files`): The worktree holds uncommitted changes or untracked files that may be lost. Never run `git worktree remove --force` on your own initiative. Inspect what is at stake:

```bash
git -C "$WORKTREE_PATH" status --porcelain -uall
```

Present context-safe options based on the active flow:

**For Option 1 (Merge Locally):**

```
The worktree contains uncommitted changes or untracked files that were not part of the merge:

<file list>

1. Commit them to <feature-branch>, re-merge into <base-branch>, and re-verify tests
2. Move them into <main repo root>
3. Delete them (unrecoverable)

Which?
```

*(Note: If Option 1 is chosen, commit the files, re-run `git merge <feature-branch>` on `<base-branch>`, and re-verify tests before proceeding to worktree removal and branch deletion. `git branch -d` will refuse if new commits remain unmerged.)*

**For Confirmed Discard:**

```
The worktree contains uncommitted changes or untracked files:

<file list>

1. Save them to a new backup branch (e.g. backup/<feature-branch>) before discarding
2. Move them into <main repo root>
3. Delete them (unrecoverable)

Which?
```

*(Note: Do not commit to <feature-branch> during discard, as `git branch -D <feature-branch>` will immediately destroy the branch and any new commit on it. Use a separate backup branch or move them to main repo root if preserving.)*

Carry out the choice, then retry removing the worktree.

**Otherwise:** The host environment (harness) owns this workspace. Do NOT remove it. If your platform provides a workspace-exit tool, use it. Otherwise, leave the workspace in place.

## Quick Reference

| Option | Merge | Push | Keep Worktree | Cleanup Branch |
|--------|-------|------|---------------|----------------|
| 1. Merge locally | yes | - | - | yes |
| 2. Create PR | - | yes | yes | - |
| 3. Keep as-is | - | - | yes | - |
| Discard (on request) | - | - | - | yes (force) |

## Common Mistakes

**Skipping test verification**

- **Problem:** Merge broken code, create failing PR
- **Fix:** Always verify tests before offering options

**Open-ended questions**

- **Problem:** "What should I do next?" is ambiguous
- **Fix:** Present exactly 3 structured options (or 2 for detached HEAD)

**Cleaning up worktree for Option 2**

- **Problem:** Remove worktree user needs for PR iteration
- **Fix:** Only cleanup for Option 1 (Merge Locally) and confirmed discard

**Deleting branch before removing worktree**

- **Problem:** `git branch -d` fails because worktree still references the branch
- **Fix:** Merge first, remove worktree, then delete branch

**Running git worktree remove from inside the worktree**

- **Problem:** Command fails silently when CWD is inside the worktree being removed
- **Fix:** Always `cd` to main repo root before `git worktree remove`

**Re-querying environment variables after changing directories**

- **Problem:** Running `git rev-parse` after `cd "$MAIN_ROOT"` resolves the main repository instead of the worktree, causing cleanup to falsely detect `GIT_DIR == GIT_COMMON` and skip cleanup or target the wrong path
- **Fix:** Use the `GIT_DIR`, `GIT_COMMON`, `WORKTREE_PATH`, and `MAIN_ROOT` values captured in Step 2

**Force-removing a dirty or refused worktree**

- **Problem:** Running `git worktree remove --force` permanently destroys uncommitted changes and untracked files
- **Fix:** List files with `git status --porcelain -uall` and ask the user how to resolve them before removing (re-merging if committing during local merge, or backing up to a separate branch during discard)

**Cleaning up harness-owned worktrees**

- **Problem:** Removing a worktree the harness created causes phantom state
- **Fix:** Only clean up worktrees under `.worktrees/` or `worktrees/`

**No confirmation for discard**

- **Problem:** Accidentally delete work
- **Fix:** Require typed "discard" confirmation

## Red Flags

**Never:**

- Force-remove a refused worktree without user confirmation
- Re-query workspace environment variables after changing directory to the main repo
- Proceed with failing tests
- Merge without verifying tests on result
- Delete work without confirmation
- Force-push without explicit request
- Remove a worktree before confirming merge success
- Clean up worktrees you didn't create (provenance check)
- Run `git worktree remove` from inside the worktree

**Always:**

- Use Step 2 captured variables (`WORKTREE_PATH`, `GIT_DIR`, `GIT_COMMON`, `MAIN_ROOT`) for cleanup in Step 6
- Show uncommitted/untracked files and ask the user before cleaning up a dirty worktree
- Verify tests before offering options
- Detect environment before presenting menu
- Present exactly 3 options (or 2 for detached HEAD)
- Get typed confirmation before discarding
- Clean up worktree for merge and discard only
- `cd` to main repo root before worktree removal
- Run `git worktree prune` after removal
