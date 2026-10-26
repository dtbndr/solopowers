## Description

<!-- Briefly describe the purpose and scope of this pull request. -->

## Decision Grounding (`AGENTS.md`)

- [ ] Planning artifact is a single workstream document (no separate spec/plan artifacts)
- [ ] Follows sequential, slice-based execution with one worktree per workstream
- [ ] Preserves manual smoke-test pause after review pass
- [ ] No leaked superpowers-specific artifact references (`docs/superpowers/specs`, `docs/superpowers/plans`)
- [ ] Uses `solopowers:` namespace for normative skill cross-references

## Verification Checklist

Run locally before requesting review:

```bash
grep -rn "human partner" skills/        # must be 0
grep -rn "superpowers:" skills/         # must be 0
diff \
  <(find skills -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort) \
  <(awk -F'`' '/^## Superseded Skills/{exit} /^\| `/{print $2}' \
    skills/using-solopowers/SKILL.md | sort)
bash tests/authoring-skills/test-render-graphs.sh
bash tests/skill-size/test-skill-size.sh
```

- [ ] `grep -rn "human partner" skills/` returned 0 matches
- [ ] `grep -rn "superpowers:" skills/` returned 0 matches
- [ ] Skill directory inventory matches `skills/using-solopowers/SKILL.md`
- [ ] `bash tests/authoring-skills/test-render-graphs.sh` passed
- [ ] `bash tests/skill-size/test-skill-size.sh` passed
