#!/usr/bin/env bash
set -euo pipefail

# scripts/compile.sh - compile circom circuit to r1cs, wasm, and sym
# Usage: ./compile.sh <circuit.circom> [outdir]

CIRCUIT_FILE=${1:-}
OUT_DIR=${2:-dist}

if [[ -z "$CIRCUIT_FILE" ]]; then
  echo "Usage: $0 <circuit.circom> [outdir]"
  exit 1
fi

mkdir -p "$OUT_DIR"

echo "Compiling $CIRCUIT_FILE -> $OUT_DIR"

circom "$CIRCUIT_FILE" --r1cs --wasm --sym -o "$OUT_DIR"

R1CS_FILE="$OUT_DIR/$(basename "$CIRCUIT_FILE" .circom).r1cs"
WASM_DIR="$OUT_DIR/$(basename "$CIRCUIT_FILE" .circom)_js"
SYM_FILE="$OUT_DIR/$(basename "$CIRCUIT_FILE" .circom).sym"

echo "Wrote:
 - R1CS: $R1CS_FILE
 - WASM dir: $WASM_DIR
 - SYM: $SYM_FILE"

exit 0
