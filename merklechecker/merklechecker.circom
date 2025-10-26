pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../selector/selector.circom";
include "../isequal/isequal.circom";



template MerkleChecker(levels) {
    // INPUTS
    signal input leaf;                    // Your leaf value (private)
    signal input pathElements[levels];    // Sibling hashes (private)
    signal input pathIndices[levels];     // 0=left, 1=right (private)
    signal input root;                   // Computed root (public)
    signal output isValid;

    signal hashes[levels + 1];
    hashes[0] <== leaf;

    component leftSelector[levels];
    component rightSelector[levels];
    component poseidon[levels];
    
    for (var i = 0; i < levels; i++) {
        leftSelector[i] = Selector();
        rightSelector[i] = Selector();
        poseidon[i] = Poseidon(2);

        leftSelector[i].in[0] <== hashes[i];
        leftSelector[i].in[1] <== pathElements[i];
        leftSelector[i].s <== pathIndices[i];
        poseidon[i].inputs[0] <== leftSelector[i].out;

        rightSelector[i].in[0] <== pathElements[i];
        rightSelector[i].in[1] <== hashes[i];
        rightSelector[i].s <== pathIndices[i];
        poseidon[i].inputs[1] <== rightSelector[i].out;
        
        hashes[i + 1] <== poseidon[i].out;
    }

    component isEqual = IsEqual();
    isEqual.in[0] <== root;
    isEqual.in[1] <== hashes[levels];
    isValid <== isEqual.out; 
    // Goal: Start with leaf, hash up the tree using siblings
    // At each level, use pathIndices to determine left/right position
}

// For a tree of depth 20 (supports 2^20 = ~1 million leaves)
component main {public [root]} = MerkleChecker(2);