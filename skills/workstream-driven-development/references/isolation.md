# Isolation Choice

Part of `solopowers:workstream-driven-development`. Run it once per workstream, after the pre-flight scan and before dispatching the first implementer. Never ask again on resume (read the mode from `log.md`).

The agent recommends with a one-line reason; the operator decides:

- Recommend **worktree** when the main checkout must stay usable (other work in flight, dirty tree, long workstream). Recommend **branch** when the work is small and the tree is clean.
- Mention that worktrees do not carry gitignored files (`.env`, virtualenvs, `node_modules`), so the final smoke check is cheaper in the operator's normal checkout; that is a reason to lean toward branch for small work.
- Example: "I recommend a branch: the tree is clean and this is three small slices, so the final smoke check can run in your normal checkout. Branch or worktree?"
- **Worktree mode:** invoke `solopowers:using-git-worktrees` ONCE.
- **Branch mode (inline, no call to `using-git-worktrees`):** require a clean working tree (the workstream folder itself may be the only uncommitted content). Never commit workstream work directly onto the repo's default branch: if currently on the default branch, create the branch from it; if on another branch, stop and ask. Create it with `git switch -c ws/<slug>`, where `<slug>` is the workstream folder name with its leading `YYYY-MM-DD-` stripped (the same slug used for `WORKSPACE_SLUG`).

## log.md

Right after isolation setup, create `<folder>/log.md` INSIDE the isolation unit and commit it as the first commit on the feature branch or worktree (never on the default branch). Line 1 is the `# Log` header; the first body line is `Isolation: <branch|worktree> — branch <name>`. If the workstream folder is not yet committed on the base, include it in this first commit. Apply any pre-flight edits agreed with the operator inside the isolation unit and commit them with it.
