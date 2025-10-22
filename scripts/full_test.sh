#!/usr/bin/env bash
set -euo pipefail

# scripts/full_test.sh - end-to-end pipeline
# Usage: ./full_test.sh <circuit.circom> <input.json>

CIRCUIT=${1:-}
INPUT=${2:-}
OUT_DIR=dist
PTAU_URL=${PTAU_URL:-https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_10.ptau}

if [[ -z "$CIRCUIT" || -z "$INPUT" ]]; then
  echo "Usage: $0 <circuit.circom> <input.json>"
  exit 1
fi

mkdir -p "$OUT_DIR"

./scripts/compile.sh "$CIRCUIT" "$OUT_DIR"
PTAU=$(basename "$PTAU_URL")
if [[ ! -f "$PTAU" ]]; then
  ./scripts/download_ptau.sh "$PTAU_URL" .
fi

R1CS="$OUT_DIR/$(basename "$CIRCUIT" .circom).r1cs"
WASM_DIR="$OUT_DIR/$(basename "$CIRCUIT" .circom)_js"
ZKEY="$OUT_DIR/$(basename "$CIRCUIT" .circom)_final.zkey"

./scripts/setup_zkey.sh "$R1CS" "$PTAU" "$ZKEY"

./scripts/witness.sh "$WASM_DIR" "$INPUT" "$OUT_DIR/witness.wtns"

./scripts/prove.sh "$ZKEY" "$OUT_DIR/witness.wtns" "$OUT_DIR/proof.json" "$OUT_DIR/public.json"

./scripts/verify.sh "$OUT_DIR/$(basename "$ZKEY" .zkey)_vkey.json" "$OUT_DIR/public.json" "$OUT_DIR/proof.json"

echo "E2E succeeded. Artifacts in $OUT_DIR"
exit 0
