// SPDX-License-Identifier: MIT

// I WAS TOO LAZY TO DECODE THI BECAUSE IT WAS THE CHERRY ON THE CAKE
// THE CAKE IS ALREADY AMAZING WITHOUT THE CHERRY SO I ATE IT AS IS :)
// THIS IS JUST A SCRIPT TO CALL THE CLAIM FUNCTION ON THE DEPLOYED CONTRACT, NOT NEEDED TO OVERTHINK IT
pragma solidity ^0.8.24;  

import {Script} from "lib/forge-std/src/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {Merkle_Airdrop} from "../src/MerkleAirdrop.sol";

contract ClaimAirdrop is Script, DevOpsTools {


    error _claimSignatureLengthError();

    // Example data for claiming
    // bytes32 Signature = hex'b1f3a5f4e1c3d5e6f7a8b9c0d1e2f30405060708090a0b0c0d0e0f1011121314';
    address CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    // ^ Using default anvil address as a claimant for testing
    uint256 AMOUNT = 18 * 1e18;
    bytes32[] PROOF = [
        bytes32(0x0aa9b52b27f96e64962ddd6dae018737055e6074e52fad4d5b64ae48591e1df9),
        bytes32(0xf1982b79598804ea67f798dc6f3cd4d593e83ee29415d08ab98dc627b506af10)
    ];

    function claimAirdrop(address merkleAirdropAddress) internal {
            vm.startBroadcast();
            (uint 8 v, bytes32 r, bytes32 s) = splitSignature(signature);
            Merkle_Airdrop(merkleAirdropAddress).claim(CLAIMING_ADDRESS, AMOUNT, PROOF, v, r, s);
            vm.stopBroadcast();
    }

    function run() external {

        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("Merkle_Airdrop", block.chainid);
        console.log("Most recently deployed Merkle_Airdrop found at:", mostRecentlyDeployed);
        claimAirdrop(mostRecentlyDeployed);
    }

    function splitSignature (bytes memory sig) internal pure returns (uint8, bytes32, bytes32) {
        // require(sig.length == 65, "invalid signature length");
        if (sig.length != 65) {
            revert _claimSignatureLengthError();
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32)) // mload loads next 32 bytes starting at the pointer
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }
    



}

