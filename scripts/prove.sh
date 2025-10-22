#!/usr/bin/env bash
set -euo pipefail

# scripts/prove.sh - generate proof using zkey and witness
# Usage: ./prove.sh <zkey> <witness.wtns> [out_proof.json] [out_public.json]

ZKEY=${1:-}
WITNESS=${2:-}
OUT_PROOF=${3:-proof.json}
OUT_PUBLIC=${4:-public.json}

if [[ -z "$ZKEY" || -z "$WITNESS" ]]; then
  echo "Usage: $0 <zkey> <witness.wtns> [out_proof.json] [out_public.json]"
  exit 1
fi

snarkjs groth16 prove "$ZKEY" "$WITNESS" "$OUT_PROOF" "$OUT_PUBLIC"

echo "Proof: $OUT_PROOF"
 echo "Public: $OUT_PUBLIC"
exit 0
