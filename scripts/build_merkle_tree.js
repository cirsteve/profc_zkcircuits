const { buildPoseidon } = require("circomlibjs");

async function buildMerkleTree() {
    const poseidon = await buildPoseidon();
    const F = poseidon.F;
    
    // Helper to hash two values
    function hash(left, right) {
        const h = poseidon([left, right]);
        return F.toString(h);
    }
    
    // Create 4 leaves
    const leaves = [
        BigInt(1),  // L0
        BigInt(2),  // L1
        BigInt(3),  // L2
        BigInt(4)   // L3
    ];
    
    console.log("Leaves:");
    leaves.forEach((l, i) => console.log(`  L${i}: ${l}`));
    
    // Level 1: Hash pairs of leaves
    const h1 = hash(leaves[0], leaves[1]);  // hash(L0, L1)
    const h2 = hash(leaves[2], leaves[3]);  // hash(L2, L3)
    
    console.log("\nLevel 1:");
    console.log(`  h1: ${h1}`);
    console.log(`  h2: ${h2}`);
    
    // Level 2: Hash to get root
    const root = hash(BigInt(h1), BigInt(h2));
    
    console.log("\nRoot:");
    console.log(`  ${root}`);
    
    // Generate proof for L0 (left-most leaf)
    console.log("\n=== Proof for L0 ===");
    console.log("Path: L0 -> h1 -> root");
    console.log("\nInput JSON:");
    console.log(JSON.stringify({
        leaf: leaves[0].toString(),
        pathElements: [
            leaves[1].toString(),  // L1 (sibling at level 0)
            h2                     // h2 (sibling at level 1)
        ],
        pathIndices: [0, 0],       // left, then left
        root: root
    }, null, 2));
    
    // Generate proof for L3 (right-most leaf)
    console.log("\n=== Proof for L3 ===");
    console.log("Path: L3 -> h2 -> root");
    console.log("\nInput JSON:");
    console.log(JSON.stringify({
        leaf: leaves[3].toString(),
        pathElements: [
            leaves[2].toString(),  // L2 (sibling at level 0)
            h1                     // h1 (sibling at level 1)
        ],
        pathIndices: [1, 1],       // right, then right
        root: root
    }, null, 2));
    
    // Generate INVALID proof (wrong leaf)
    console.log("\n=== Invalid Proof (leaf not in tree) ===");
    console.log("\nInput JSON:");
    console.log(JSON.stringify({
        leaf: "999",               // Not in tree!
        pathElements: [
            leaves[1].toString(),
            h2
        ],
        pathIndices: [0, 0],
        root: root
    }, null, 2));
}

buildMerkleTree().catch(console.error);