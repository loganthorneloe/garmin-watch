#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FACE="${1:-}"
case "$FACE" in
    sector|ember) ;;
    *) echo 'Usage: scripts/build.sh <sector|ember> [device] [release|debug|test|preview]' >&2; exit 1 ;;
esac
shift
exec "$ROOT/faces/$FACE/scripts/build.sh" "$@"
