pragma circom 2.0.0;

/*This circuit template checks that c is the multiplication of a and b.*/  

template isZero () {  

   // Declaration of signals.  
   signal input in;  
 
   signal output out;
   signal inv;  
   inv <-- in !=0 ? 1/in : 1;
   // Constraints.  
   out <== -in * inv + 1;
   in * out === 0;  
}

component main = isZero();