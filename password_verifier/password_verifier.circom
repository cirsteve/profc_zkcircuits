pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";

// You can also use your IsEqual from before!
template IsZero() {
    
    // Declaration of signals.  
   signal input in;  
 
   signal output out;
   signal inv;  
   inv <-- in !=0 ? 1/in : 1;
   // Constraints.  
   out <== -in * inv + 1;
   in * out === 0;  
}

// Now build IsEqual using IsZero!
template IsEqual() {
    signal input in[2];  // Two inputs to compare
    signal output out;   // 1 if equal, 0 if not
    signal inter;
    
    // YOUR CODE HERE
    // Hint: If in[0] == in[1], then in[0] - in[1] == 0
    // You can use IsZero as a component!
    inter <== in[0] - in[1];
    component isZero = IsZero();
    isZero.in <== inter;
    out <== isZero.out;

}

template PasswordVerifier() {
    signal input password;        // Private
    signal input expectedHash;    // Public
    signal output isValid;        // 1 if correct, 0 if wrong
    
    // YOUR CODE HERE
    // Steps:
    component poseidon = Poseidon(1);
    poseidon.inputs[0] <== password;
    component isEqual = IsEqual();
    isEqual.in <== [poseidon.out, expectedHash];
    isValid <== isEqual.out;
}

// Make expectedHash public (verifier can see it)
component main {public [expectedHash]} = PasswordVerifier();