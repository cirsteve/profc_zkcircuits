Circom helper scripts

Prereqs
- circom installed and on PATH
- node and npm (for running wasm witness generator)
- snarkjs installed (`npm i -g snarkjs`) or available on PATH
- curl (to download ptau)

Scripts
- compile.sh <circuit.circom> [outdir]
  - Runs `circom` to produce .r1cs, wasm, and .sym files in outdir (default dist)

- download_ptau.sh [ptau-url] [outdir]
  - Downloads a powers-of-tau file (default: Hermez final ptau)

- setup_zkey.sh <r1cs> <ptau> [out.zkey]
  - Runs `snarkjs groth16 setup` to create a zkey and exports verification key.

- witness.sh <wasm_dir> <input.json> [out.wtns]
  - Runs the generated `generate_witness.js` to compute witness.wtns.

- prove.sh <zkey> <witness.wtns> [proof.json] [public.json]
  - Runs `snarkjs groth16 prove` to produce proof and public signals.

- verify.sh <vkey.json> <public.json> <proof.json>
  - Runs `snarkjs groth16 verify`.

- full_test.sh <circuit.circom> <input.json>
  - End-to-end: compile -> ptau (download if missing) -> setup -> witness -> prove -> verify

Examples

Compile a circuit:

```bash
cd codes/circom
scripts/compile.sh circuits/isZero/isZero.circom dist
```

Run the full pipeline (expects input.json with circuit inputs):

```bash
cd codes/circom
scripts/full_test.sh circuits/isZero/isZero.circom input.json
```

Notes
- `witness.sh` attempts common wasm filenames. If your `generate_witness.js` expects a different wasm filename, edit the script accordingly.
- These scripts are opinionated but easily modified.

If you'd like, I can also:
- Add a `package.json` + small JS helper to build witness in a consistent Node environment.
- Make the scripts more portable (check for `snarkjs` and `circom` and give actionable errors).
