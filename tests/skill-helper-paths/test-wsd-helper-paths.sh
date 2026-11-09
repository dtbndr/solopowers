#!/usr/bin/env bash
# Fails when a file under skills/ names a solopowers helper script
# (slice-brief, review-package, wsd-workspace, wsd-repo, external-review-*) by a
# skill-relative `scripts/<helper>` path without telling the agent to run
# helpers by their absolute path from the working tree.
#
# Why: a relative path invites the agent to cd into the skill's own directory
# (the installed plugin cache) to make it work, so the helpers then act on the
# plugin's files instead of the working tree it is executing in.
#
# Rule (per file, not per mention): any file containing a relative helper
# invocation must also contain "by its absolute path" or "by their absolute
# path" (whitespace-squeezed, so line wraps do not split it). One statement per
# file covers every mention in that file, because each skill/reference/prompt
# file may be read on its own. A bare "absolute path" elsewhere does not count.
# Limitation: a second, unqualified mention in an already-qualified file is not
# caught; a per-mention window would be flaky across the differing doc layouts.
#
# Usage: tests/skill-helper-paths/test-wsd-helper-paths.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

invocation='(bash )?(\.\./[a-z-]+/)?scripts/(slice-brief|review-package|wsd-workspace|wsd-repo|external-review-(workspace|package|report))'
phrase='by (its|their) absolute path'

failed=0
checked=0
while IFS= read -r file; do
  checked=$((checked + 1))
  if ! tr -s '[:space:]' ' ' <"$file" | grep -qE "$phrase"; then
    echo "FAIL: ${file#"$REPO_ROOT"/} names a helper by a relative scripts/ path without saying \"by its/their absolute path\"" >&2
    failed=1
  fi
done < <(grep -rlE --include='*.md' "$invocation" "$REPO_ROOT/skills" | sort)

if ((checked == 0)); then
  echo "FAIL: found no helper invocations under skills/; the pattern is stale" >&2
  exit 1
fi
if ((failed)); then
  echo "Say to run helpers by their absolute path, from the working tree you're executing in." >&2
  exit 1
fi
echo "PASS: all $checked files with relative helper references say to run them by absolute path"
