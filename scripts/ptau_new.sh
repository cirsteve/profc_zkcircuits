#!/usr/bin/env bash
set -euo pipefail

# ptau_new.sh - initialize a new powers of tau file
# Usage:
#   ./ptau_new.sh <power> <out.ptau> [contributor-name]
# If contributor-name is provided the script will:
#  - create a temporary initial ptau
#  - run a contribution with the provided name producing the final out.ptau
#  - remove the temporary initial ptau

POWER=${1:-12}
OUT=${2:-powersOfTau28_hez_final_${POWER}.ptau}
CONTRIB_NAME=${3:-}

if [[ -z "$POWER" ]]; then
  echo "Usage: $0 <power> <out.ptau> [contributor-name]"
  exit 1
fi

if [[ -z "$CONTRIB_NAME" ]]; then
  # create an initial ptau directly as the output
  snarkjs powersoftau new bn128 "$POWER" "$OUT" -v
  echo "Created $OUT"
  exit 0
else
  # create a temporary initial ptau then contribute to produce OUT
  TMP_INIT="${OUT%.ptau}_initial.ptau"
  echo "Creating initial ptau -> $TMP_INIT"
  snarkjs powersoftau new bn128 "$POWER" "$TMP_INIT" -v

  echo "Contributing entropy as '$CONTRIB_NAME' -> $OUT"
  snarkjs powersoftau contribute "$TMP_INIT" "$OUT" --name="$CONTRIB_NAME" -v

  echo "Cleaning up temporary initial ptau: $TMP_INIT"
  rm -f "$TMP_INIT"

  echo "Created contributed ptau: $OUT"
  exit 0
fi
