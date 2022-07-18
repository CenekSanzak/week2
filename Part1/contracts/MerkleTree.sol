//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves
        hashes = new uint256[](15);
        // 0 1 2 3 4 5 6 7 
        //  8   9   10  11
        //    12      13           
        //        14
        for(uint i = 0; i < 15; i++) {
            if(i <= 7) {
                hashes[i] = 0;
            } 
            else if (i <= 11) {
                hashes[i] = PoseidonT3.poseidon([hashes[(i-8)*2], hashes[(i-8)*2 + 1]]);
            }
            else if (i <= 13) {
                hashes[i] = PoseidonT3.poseidon([hashes[(i-12)*2 + 8], hashes[(i-12)*2 + 9]]);
            }
            else {
                hashes[i] = PoseidonT3.poseidon([hashes[12], hashes[13]]);
            }
        }
        root = hashes[0];
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        require(index < 8);
        uint i = index;
        index++;
        hashes[i] = hashedLeaf;
        while(i < 15){
            if(i <= 7) {
                hashes[i] = 0;
                i = i/2 + 8;
            } 
            else if (i <= 11) {
                hashes[i] = PoseidonT3.poseidon([hashes[(i-8)*2], hashes[(i-8)*2 + 1]]);
                i = (i-8)/2 + 12;
            }
            else if (i <= 13) {
                hashes[i] = PoseidonT3.poseidon([hashes[(i-12)*2 + 8], hashes[(i-12)*2 + 9]]);
                i = (i-12)/2 + 14;
            }
            else {
                hashes[i] = PoseidonT3.poseidon([hashes[12], hashes[13]]);
                i = 15;
            }
        }
        return 0;
    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {
            
        // [assignment] verify an inclusion proof and check that the proof root matches current root
        return Verifier.verifyProof(a, b, c, input);
    }
}
