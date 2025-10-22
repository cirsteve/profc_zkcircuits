#!/usr/bin/env bash
set -euo pipefail

# scripts/setup_zkey.sh - create zkey from r1cs and ptau, and optionally export verification key
# Usage: ./setup_zkey.sh <r1cs> <ptau> [out.zkey]

R1CS=${1:-}
PTAU=${2:-}
OUT_ZKEY=${3:-circuit_final.zkey}

if [[ -z "$R1CS" || -z "$PTAU" ]]; then
  echo "Usage: $0 <r1cs> <ptau> [out.zkey]"
  exit 1
fi

echo "Running snarkjs groth16 setup"

snarkjs groth16 setup "$R1CS" "$PTAU" "$OUT_ZKEY"

echo "Wrote ZKey: $OUT_ZKEY"

# Optionally export verification key
VK_OUT="${OUT_ZKEY%.zkey}_vkey.json"
if [[ ! -f "$VK_OUT" ]]; then
  snarkjs zkey export verificationkey "$OUT_ZKEY" "$VK_OUT"
  echo "Wrote verification key: $VK_OUT"
else
  echo "Verification key already exists: $VK_OUT"
fi

exit 0
