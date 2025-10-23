const { buildPoseidon } = require("circomlibjs");

async function computeHash() {
    const poseidon = await buildPoseidon();
    
    // Hash the password
    const password = 123456445128906524n;  // BigInt
    const hash = poseidon([password]);
    
    // Convert to string for JSON
    const hashStr = poseidon.F.toString(hash);
    
    console.log("Password:", password);
    console.log("Hash:", hashStr);
}

computeHash();