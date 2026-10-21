#!/usr/bin/env bash
set -euo pipefail
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SDK_DIR="${CIQ_SDK:?Set CIQ_SDK to your installed Connect IQ SDK directory}"
JAVA_BIN="${CIQ_JAVA:-java}"
KEY_PATH="${CIQ_KEY:-$PROJECT_DIR/.private/developer_key.der}"
DEVICE="${1:-fenix9pro51mm}"
MODE="${2:-release}"
JUNGLE="monkey.jungle"
FLAGS=(-r)
case "$MODE" in
    release) ;;
    debug) FLAGS=(-O 1) ;;
    preview) JUNGLE="preview.jungle"; FLAGS=(-O 1) ;;
    test) JUNGLE="test.jungle"; FLAGS=(-t) ;;
    *) echo 'Usage: scripts/build.sh [device] [release|debug|test|preview]' >&2; exit 1 ;;
esac
if [[ ! -f "$SDK_DIR/bin/monkeybrains.jar" ]]; then
    echo 'CIQ_SDK must contain bin/monkeybrains.jar.' >&2
    exit 1
fi
if ! "$JAVA_BIN" -version >/dev/null 2>&1; then
    echo 'Java is missing. Set CIQ_JAVA to a Java 17+ executable.' >&2
    exit 1
fi
if [[ ! -f "$KEY_PATH" ]]; then
    mkdir -p "$(dirname "$KEY_PATH")"
    (umask 077; openssl genrsa 4096 2>/dev/null | openssl pkcs8 -topk8 -inform PEM -outform DER -nocrypt -out "$KEY_PATH")
    echo 'Created a private signing key. Keep it out of version control and retain it for updates.'
fi
mkdir -p "$PROJECT_DIR/build"
cd "$PROJECT_DIR"
"$JAVA_BIN" -Djava.awt.headless=true -Dfile.encoding=UTF-8 \
    -jar "$SDK_DIR/bin/monkeybrains.jar" \
    -f "$JUNGLE" -d "$DEVICE" -y "$KEY_PATH" \
    -o "build/Ember-$DEVICE-$MODE.prg" -w -l 1 "${FLAGS[@]}"
echo "Built: $PROJECT_DIR/build/Ember-$DEVICE-$MODE.prg"
