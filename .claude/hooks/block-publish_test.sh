#!/usr/bin/env bash

# Tests for block-publish.sh hook
# Run: bash .claude/hooks/block-publish_test.sh

HOOK=".claude/hooks/block-publish.sh"
pass=0
fail=0

assert() {
  local description="$1" expected="$2" actual="$3"
  if [ "$actual" = "$expected" ]; then
    echo "PASS: $description"
    pass=$((pass + 1))
  else
    echo "FAIL: $description (expected exit $expected, got exit $actual)"
    fail=$((fail + 1))
  fi
}

# Block cases
echo '{"tool_input":{"command":"bundle exec rake release"}}' | bash "$HOOK" 2>/dev/null
assert "blocks 'bundle exec rake release'" "2" "$?"

echo '{"tool_input":{"command":"rake release"}}' | bash "$HOOK" 2>/dev/null
assert "blocks 'rake release'" "2" "$?"

echo '{"tool_input":{"command":"gem push riteway-0.1.0.gem"}}' | bash "$HOOK" 2>/dev/null
assert "blocks 'gem push'" "2" "$?"

# Allow cases
echo '{"tool_input":{"command":"bundle exec rake test"}}' | bash "$HOOK" 2>/dev/null
assert "allows 'bundle exec rake test'" "0" "$?"

echo '{"tool_input":{"command":"git commit -m blocks rake release"}}' | bash "$HOOK" 2>/dev/null
assert "allows commit message mentioning rake release" "0" "$?"

echo '{"tool_input":{"command":"git status"}}' | bash "$HOOK" 2>/dev/null
assert "allows 'git status'" "0" "$?"

echo '{"tool_input":{"command":"bundle exec rake rspec"}}' | bash "$HOOK" 2>/dev/null
assert "allows 'bundle exec rake rspec'" "0" "$?"

echo ""
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ] || exit 1
