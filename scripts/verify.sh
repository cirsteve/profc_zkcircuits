#!/usr/bin/env bash
set -euo pipefail

# scripts/verify.sh - verify a proof
# Usage: ./verify.sh <vkey.json> <public.json> <proof.json>

VKEY=${1:-}
PUBLIC=${2:-}
PROOF=${3:-}

if [[ -z "$VKEY" || -z "$PUBLIC" || -z "$PROOF" ]]; then
  echo "Usage: $0 <vkey.json> <public.json> <proof.json>"
  exit 1
fi

snarkjs groth16 verify "$VKEY" "$PUBLIC" "$PROOF"

exit 0
