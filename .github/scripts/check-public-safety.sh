#!/usr/bin/env bash
#
# Fail if a tracked file carries something that has no business in a public
# repository: an API key, a real hostname, a real resource id, a real address.
#
# The conventions in README.md say all of this in prose. This is the part a
# reviewer cannot forget to apply — skills here are distilled from real
# sessions against real tenants, and a pasted connector id is the likeliest way
# something leaks.
#
set -uo pipefail

status=0
# Everything tracked by git except this script and the workflow that runs it.
# Portable to the bash 3.2 that ships with macOS, so the check runs the same
# way locally as it does in CI.
files=()
while IFS= read -r f; do files+=("$f"); done < <(
  git ls-files | grep -vE '^\.github/(scripts/check-public-safety\.sh|workflows/public-safety\.yml)$'
)

report() {           # report <label> <matches>
  printf '\n✗ %s\n' "$1" >&2
  printf '%s\n' "$2" >&2
  status=1
}

check() {            # check <label> <extended-regex> [filter-regex-to-drop]
  local label=$1 pattern=$2 allow=${3:-} hits
  hits=$(grep -nEI --color=never "$pattern" "${files[@]}" 2>/dev/null || true)
  [ -n "$allow" ] && hits=$(printf '%s' "$hits" | grep -vE "$allow" || true)
  [ -n "$hits" ] && report "$label" "$hits"
  return 0
}

check "API key" \
  'psk_[A-Za-z0-9_-]{8,}'

check "Resource id (use a <placeholder> instead)" \
  '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}'

check "Real hostname (only <tenant>.<region>.popsink.com is allowed)" \
  '[A-Za-z0-9_<>-]+\.[A-Za-z0-9_<>-]+\.popsink\.com' \
  '<tenant>\.<region>\.popsink\.com'

check "IP address" \
  '(^|[^0-9.])([0-9]{1,3}\.){3}[0-9]{1,3}([^0-9.]|$)' \
  '127\.0\.0\.1|0\.0\.0\.0'

check "Private key" \
  '-----BEGIN [A-Z ]*PRIVATE KEY-----'

if [ "$status" -ne 0 ]; then
  printf '\nSee the Conventions section of README.md. Replace the value with a placeholder.\n' >&2
else
  printf 'public-safety: clean (%d files)\n' "${#files[@]}"
fi
exit "$status"
