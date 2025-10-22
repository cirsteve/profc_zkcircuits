#!/usr/bin/env bash
set -euo pipefail

# phase2_ceremony.sh - run full Phase 2 ceremony (prepare ptau, setup, contributions, beacon, export vkey)
# Usage:
#   ./phase2_ceremony.sh <r1cs> <ptau> <out_final_zkey> [contributors_csv] [beacon_hex] [--skip-prepare]
#
# - ptau: can be either a raw ptau or a phase2-prepared ptau. If not prepared, the script will prepare it.
# - contributors_csv: optional comma-separated contributor names (e.g. "Alice,Bob,Carol").
#   For each contributor an intermediate zkey will be produced and used for the next contribution.
# - beacon_hex: optional hex string to apply a beacon at the end (finalize ceremony). If omitted
#   the last contributed zkey (or initial zkey if no contributors) will be used as the final zkey.
# - --skip-prepare: optional flag to skip the ptau prepare phase2 step if you know the ptau is already prepared.

R1CS=${1:-}
PTAU=${2:-}
OUT_FINAL=${3:-}
CONTRIB_CSV=${4:-}
BEACON=${5:-}
SKIP_PREPARE=${6:-}

if [[ -z "$R1CS" || -z "$PTAU" || -z "$OUT_FINAL" ]]; then
  echo "Usage: $0 <r1cs> <ptau> <out_final_zkey> [contributors_csv] [beacon_hex] [--skip-prepare]"
  exit 1
fi

tmp_prefix="$(basename "$OUT_FINAL" .zkey)"
prepared_ptau="${tmp_prefix}_prepared_phase2.ptau"

# Phase 0: Prepare ptau for phase2 if needed
if [[ "$SKIP_PREPARE" != "--skip-prepare" ]]; then
  echo "Phase2 Step 0: Preparing ptau for phase2 -> $prepared_ptau"
  snarkjs powersoftau prepare phase2 "$PTAU" "$prepared_ptau" -v
  PTAU_TO_USE="$prepared_ptau"
else
  echo "Skipping ptau preparation (using provided ptau as-is)"
  PTAU_TO_USE="$PTAU"
fi

z0="${tmp_prefix}_0000.zkey"

echo "Phase2 Step 1: initial setup (groth16 setup) -> $z0"
snarkjs groth16 setup "$R1CS" "$PTAU_TO_USE" "$z0"

echo "Verifying initial zkey..."
snarkjs zkey verify "$R1CS" "$PTAU_TO_USE" "$z0"

prev_z="$z0"
idx=0
if [[ -n "$CONTRIB_CSV" ]]; then
  IFS=',' read -r -a contribs <<< "$CONTRIB_CSV"
  for name in "${contribs[@]}"; do
    idx=$((idx+1))
    next_z="${tmp_prefix}_$(printf "%04d" $idx).zkey"
    echo "Phase2 Step 2: Contributing as '$name' -> $next_z"
    snarkjs zkey contribute "$prev_z" "$next_z" --name="$name" -v
    echo "Verifying contributed zkey..."
    snarkjs zkey verify "$R1CS" "$PTAU_TO_USE" "$next_z"
    prev_z="$next_z"
  done
fi

# If a beacon is provided, apply it to the last zkey and produce OUT_FINAL, else move/copy last zkey to OUT_FINAL.
if [[ -n "$BEACON" ]]; then
  echo "Phase2 Step 3: Applying beacon to $prev_z -> $OUT_FINAL"
  snarkjs zkey beacon "$prev_z" "$OUT_FINAL" --beacon="$BEACON" --iterations=10 -v
  echo "Verifying final zkey after beacon..."
  snarkjs zkey verify "$R1CS" "$PTAU_TO_USE" "$OUT_FINAL"
  final_z="$OUT_FINAL"
else
  echo "No beacon provided; using $prev_z as final zkey -> $OUT_FINAL"
  cp -f "$prev_z" "$OUT_FINAL"
  final_z="$OUT_FINAL"
fi

# export verification key
vkey_out="${OUT_FINAL%.zkey}_vkey.json"
echo "Phase2 Step 4: Exporting verification key to $vkey_out"
snarkjs zkey export verificationkey "$final_z" "$vkey_out"

echo "Phase2 ceremony complete. Final zkey: $final_z, vkey: $vkey_out"
exit 0
