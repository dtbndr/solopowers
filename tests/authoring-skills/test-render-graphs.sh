#!/usr/bin/env bash
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPT_UNDER_TEST="$REPO_ROOT/skills/authoring-skills/render-graphs.js"
NODE_BIN="$(command -v node)"

PASSES=0
FAILURES=0
TEST_ROOT="$(mktemp -d)"

cleanup() {
  rm -rf "$TEST_ROOT"
}
trap cleanup EXIT

pass() {
  echo "  [PASS] $1"
  PASSES=$((PASSES + 1))
}

fail() {
  echo "  [FAIL] $1"
  FAILURES=$((FAILURES + 1))
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local description="$3"

  if printf '%s' "$haystack" | grep -Fq -- "$needle"; then
    pass "$description"
  else
    fail "$description"
    echo "    expected to find: $needle"
  fi
}

assert_not_contains() {
  local haystack="$1"
  local needle="$2"
  local description="$3"

  if printf '%s' "$haystack" | grep -Fq -- "$needle"; then
    fail "$description"
    echo "    did not expect to find: $needle"
  else
    pass "$description"
  fi
}

fixture="$TEST_ROOT/fixture-skill"
mkdir -p "$fixture" "$TEST_ROOT/empty-path"
cat >"$fixture/SKILL.md" <<'EOF'
---
name: fixture-skill
---

# Fixture Skill

```dot
digraph fixture_graph {
  start -> end;
}
```
EOF

echo "Authoring-skills render-graphs tests"

missing_dot_output="$(PATH="$TEST_ROOT/empty-path" "$NODE_BIN" "$SCRIPT_UNDER_TEST" "$fixture" 2>&1)"
missing_dot_status=$?

if [[ "$missing_dot_status" -ne 0 ]]; then
  pass "missing Graphviz exits non-zero"
else
  fail "missing Graphviz exits non-zero"
fi
assert_contains "$missing_dot_output" "Error: graphviz (dot) not found." "missing Graphviz reports install guidance"
assert_not_contains "$missing_dot_output" "Cannot use import statement outside a module" "script runs in CommonJS mode"
assert_not_contains "$missing_dot_output" "ReferenceError: require is not defined" "script runs in CommonJS mode"

# Test isolated PATH with mock dot and NO which utility
custom_bin="$TEST_ROOT/custom-bin"
mkdir -p "$custom_bin"
cat >"$custom_bin/dot" <<'EOF'
#!/bin/sh
if [ "${1:-}" = "-V" ]; then
  echo "dot - graphviz version mock" >&2
  exit 0
fi
if [ "${1:-}" = "-Tsvg" ]; then
  while read -r line; do :; done
  echo '<svg viewBox="0 0 100 100"><circle cx="50" cy="50" r="40"/></svg>'
  exit 0
fi
exit 0
EOF
chmod +x "$custom_bin/dot"
ln -s "$NODE_BIN" "$custom_bin/node"

mock_fixture="$TEST_ROOT/mock-fixture-skill"
mkdir -p "$mock_fixture"
cat >"$mock_fixture/SKILL.md" <<'EOF'
---
name: mock-fixture-skill
---

# Mock Fixture Skill

```dot
digraph mock_graph {
  a -> b;
}
```
EOF

mock_dot_output="$(PATH="$custom_bin" "$NODE_BIN" "$SCRIPT_UNDER_TEST" "$mock_fixture" 2>&1)"
mock_dot_status=$?

if [[ "$mock_dot_status" -eq 0 ]]; then
  pass "runs successfully with dot in PATH without which utility"
else
  fail "runs successfully with dot in PATH without which utility"
  printf '%s\n' "$mock_dot_output"
fi
assert_contains "$mock_dot_output" "Found 1 diagram(s)" "mock dot reports discovered diagram"
assert_contains "$mock_dot_output" "Rendered: mock_graph.svg" "mock dot reports rendered SVG"
if [[ -f "$mock_fixture/diagrams/mock_graph.svg" ]] && grep -Fq "<svg" "$mock_fixture/diagrams/mock_graph.svg"; then
  pass "mock dot generates valid SVG output"
else
  fail "mock dot generates valid SVG output"
fi

render_output="$("$NODE_BIN" "$SCRIPT_UNDER_TEST" "$fixture" 2>&1)"
render_status=$?

if [[ "$render_status" -eq 0 ]]; then
  pass "fixture diagram renders"
else
  fail "fixture diagram renders"
  printf '%s\n' "$render_output"
fi

assert_contains "$render_output" "Found 1 diagram(s)" "reports discovered diagram"
assert_contains "$render_output" "Rendered: fixture_graph.svg" "reports rendered SVG"

if [[ -f "$fixture/diagrams/fixture_graph.svg" ]]; then
  pass "writes SVG output"
else
  fail "writes SVG output"
fi

if [[ -f "$fixture/diagrams/fixture_graph.svg" ]] && grep -Fq "<svg" "$fixture/diagrams/fixture_graph.svg"; then
  pass "SVG output has SVG markup"
else
  fail "SVG output has SVG markup"
fi

echo
echo "Results: $PASSES passed, $FAILURES failed"

if [[ "$FAILURES" -gt 0 ]]; then
  exit 1
fi
