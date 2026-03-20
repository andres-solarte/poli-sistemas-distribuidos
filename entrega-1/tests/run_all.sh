#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

tests=(
  "test_ip_static.sh"
  "test_nfs_export.sh"
  "test_nfs_mount.sh"
  "test_resources.sh"
  "test_java_eclipse.sh"
)

cd "$DIR"

overall=0
for t in "${tests[@]}"; do
  echo "Running: $t"
  if "bash" "$t"; then
    :
  else
    overall=1
  fi
done

if [[ "$overall" -ne 0 ]]; then
  echo "Some tests FAILED" >&2
  exit 1
fi

echo "All tests PASS"

