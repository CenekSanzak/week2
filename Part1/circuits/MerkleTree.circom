pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/mux1.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    component left = CheckRoot(n-1);
    component right = CheckRoot(n-1);
    component poseidon = Poseidon(2);
    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    if(n == 0) {
        root <== leaves[0];
    } else {
        for(var i = 0; i < 2**(n-1); i++) {
            left.leaves[i] <== leaves[i];
            right.leaves[i] <== leaves[i+2**(n-1)];
        }
        poseidon.inputs[0] <== left.root;
        poseidon.inputs[1] <== right.root;
        root <== poseidon.out;
    }

}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    var value = leaf;
    component poseidon[n];
    component mux[n];
    for(var i = n-1; i >=0; i--){
        poseidon[i] = Poseidon(2);
        mux[i] = MultiMux1(2);
        mux[i].c[0][0] <== value;
        mux[i].c[0][1] <== path_elements[i];
        mux[i].c[1][0] <== path_elements[i];
        mux[i].c[1][1] <== value;
        mux[i].s <== path_index[i];
        poseidon[i].inputs[0] <== mux[i].out[0];
        poseidon[i].inputs[1] <== mux[i].out[1];
        value = poseidon[i].out;
    }
    root <== value;
}