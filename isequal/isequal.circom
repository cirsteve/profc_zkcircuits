pragma circom 2.0.0;

// First, copy your IsZero template here
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

// component main = IsEqual();