#!/usr/bin/env bash
set -euo pipefail

# phase2_setup.sh - simplified Phase 2 setup (prepare, setup, verify, export)
# Usage:
#   ./phase2_setup.sh <r1cs> <ptau> <out_zkey> <out_vkey>
#
# This script runs the 4 essential phase2 commands:
# 1. powersoftau prepare phase2 - prepare the ptau for circuit-specific setup
# 2. groth16 setup - create the initial zkey from r1cs and prepared ptau
# 3. zkey verify - verify the zkey is valid
# 4. zkey export verificationkey - export the verification key

R1CS=${1:-}
PTAU=${2:-}
OUT_ZKEY=${3:-}
OUT_VKEY=${4:-}

if [[ -z "$R1CS" || -z "$PTAU" || -z "$OUT_ZKEY" || -z "$OUT_VKEY" ]]; then
  echo "Usage: $0 <r1cs> <ptau> <out_zkey> <out_vkey.json>"
  echo ""
  echo "Example:"
  echo "  $0 circuit.r1cs pot12_final.ptau circuit_final.zkey verification_key.json"
  exit 1
fi

# Create temporary prepared ptau file
tmp_prefix="$(basename "$OUT_ZKEY" .zkey)"
prepared_ptau="${tmp_prefix}_prepared.ptau"

echo "=== Phase2 Step 1/4: Preparing ptau for phase2 ==="
npx snarkjs powersoftau prepare phase2 "$PTAU" "$prepared_ptau" -v

echo ""
echo "=== Phase2 Step 2/4: Groth16 setup (creating zkey) ==="
npx snarkjs groth16 setup "$R1CS" "$prepared_ptau" "$OUT_ZKEY"

echo ""
echo "=== Phase2 Step 3/4: Verifying zkey ==="
npx snarkjs zkey verify "$R1CS" "$prepared_ptau" "$OUT_ZKEY"

echo ""
echo "=== Phase2 Step 4/4: Exporting verification key ==="
npx snarkjs zkey export verificationkey "$OUT_ZKEY" "$OUT_VKEY"

echo ""
echo "✓ Phase2 setup complete!"
echo "  - zkey: $OUT_ZKEY"
echo "  - verification key: $OUT_VKEY"
echo "  - prepared ptau (can be deleted): $prepared_ptau"

exit 0
