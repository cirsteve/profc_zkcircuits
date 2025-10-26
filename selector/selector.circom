pragma circom 2.0.0;

// If s = 0, output in[0]
// If s = 1, output in[1]
template Selector() {
    signal input in[2];   // Two options
    signal input s;       // Selector (must be 0 or 1)
    signal output out;
    signal p1;
    signal p2;

    // YOUR CODE HERE
    // Constraints:
    // 1. Ensure s is 0 or 1
    // 2. Select based on s value
    
    // Hint: Use math trick!
    // If s=0: out = in[0]
    // If s=1: out = in[1]
    // contrain s to 0 or 1
    s * s === s;
    p1 <== in[0]*(1-s);
    p2 <== in[1]*s; 
    out <== p1 + p2;
}

//component main = Selector();