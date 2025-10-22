#!/usr/bin/env bash
set -euo pipefail

# scripts/witness.sh - compute witness using wasm and input.json
# Usage: ./witness.sh <wasm_dir> <input.json> [out.wtns]

WASM_DIR=${1:-}
INPUT_JSON=${2:-}
OUT_WTNS=${3:-witness.wtns}

# Trim helper: remove leading/trailing whitespace
trim() {
  local var="$*"
  # remove leading whitespace
  var="${var#${var%%[![:space:]]*}}"
  # remove trailing whitespace
  var="${var%${var##*[![:space:]]}}"
  printf '%s' "$var"
}

# Trim input parameters to be robust against accidental spaces
WASM_DIR="$(trim "$WASM_DIR")"
INPUT_JSON="$(trim "$INPUT_JSON")"
OUT_WTNS="$(trim "$OUT_WTNS")"

if [[ -z "$WASM_DIR" || -z "$INPUT_JSON" ]]; then
  echo "Usage: $0 <wasm_dir> <input.json> [out.wtns]"
  exit 1
fi

WASM_EXEC="$WASM_DIR/generate_witness.js"
if [[ ! -f "$WASM_EXEC" ]]; then
  echo "Cannot find $WASM_EXEC. Ensure you compiled the circuit and node has the wasm folder."
  exit 1
fi

# Try to find the wasm file - circom generates different naming patterns
WASM_FILE=""
if [[ -f "$WASM_DIR/$(basename "$WASM_DIR").wasm" ]]; then
  WASM_FILE="$WASM_DIR/$(basename "$WASM_DIR").wasm"
elif [[ -f "$WASM_DIR/$(basename "$WASM_DIR")_wasm.wasm" ]]; then
  WASM_FILE="$WASM_DIR/$(basename "$WASM_DIR")_wasm.wasm"
else
  # Fall back to first .wasm file found
  WASM_FILE=$(find "$WASM_DIR" -maxdepth 1 -name "*.wasm" -type f | head -n 1)
fi

if [[ -z "$WASM_FILE" || ! -f "$WASM_FILE" ]]; then
  echo "Error: Cannot find .wasm file in $WASM_DIR"
  exit 1
fi

node "$WASM_EXEC" "$WASM_FILE" "$INPUT_JSON" "$OUT_WTNS"

echo "Wrote witness: $OUT_WTNS"
exit 0
