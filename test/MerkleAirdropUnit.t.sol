// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Merkle_Airdrop} from "../src/MerkleAirdrop.sol";
import {Test, console} from "lib/forge-std/src/Test.sol";
import {Vm} from "lib/forge-std/src/Vm.sol";
import {DabbayudToken} from "../src/DabayyudToken.sol";
import {DeployScript} from "../script/DeployScript.s.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract MerkleAirdropTest is Test, DeployScript {

    Merkle_Airdrop public merkleAirdrop;
    DabbayudToken public token;

    address public user1;
    address public gasPayer;
    uint256 public user1PrivateKey;


    uint256 public constant AMOUNT_CLAIM = 18 * 1e18;
    uint256 public constant AMOUNT_HOLD = AMOUNT_CLAIM * 4;
    bytes32[] public PROOF = [
        bytes32(0x206c8605be1adb0ad662f04dfe65e2dba59aaf5377086788b47938365ec032bc),
        bytes32(0xf1982b79598804ea67f798dc6f3cd4d593e83ee29415d08ab98dc627b506af10)
    ];

    function setUp() public {
        // Use the deploy script instead of manual deployment
        
        (merkleAirdrop, token) = deployMerkleAirdrop();
        
        // Use the exact address from your whitelist
        (user1, user1PrivateKey) = makeAddrAndKey("user1");
        gasPayer = makeAddr("gasPayer");
        vm.deal(gasPayer, 1 ether); // so that gasPayer has ether to pay for gas
        vm.deal(user1, 0 ether); // Override automatic balance
        // in foundry tests, unnecessary to fund gasPayer as it has unlimited balance automatically

    }

    function testUsersCanClaim() public {
        bytes32 digest = merkleAirdrop.getMessage(user1, AMOUNT_CLAIM);
        console.log("User address:", user1);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(user1PrivateKey, digest);

        // Prank user1 to sign the message and pay gas from gasPayer
        
        // Debug: Calculate what leaf should be using the MakeMerkle method
        bytes32[] memory data = new bytes32[](2);
        data[0] = bytes32(uint256(uint160(user1)));
        data[1] = bytes32(AMOUNT_CLAIM);
        
        // Simulate the MakeMerkle leaf construction (without ltrim64 for now)
        bytes32 makeMerkleLeaf = keccak256(bytes.concat(keccak256(abi.encode(data))));
        console.log("MakeMerkle-style leaf:");
        console.logBytes32(makeMerkleLeaf);
        
        // Original contract method
        bytes32 contractLeaf = keccak256(bytes.concat(keccak256(abi.encodePacked(user1, AMOUNT_CLAIM))));
        console.log("Contract-style leaf:");
        console.logBytes32(contractLeaf);
        
        // Expected from JSON
        console.log("JSON expected leaf: 0x0aa9b52b27f96e64962ddd6dae018737055e6074e52fad4d5b64ae48591e1df9");

        vm.prank(gasPayer);
        merkleAirdrop.claim(user1, AMOUNT_CLAIM, PROOF, v, r, s);

        uint256 endingBalance = token.balanceOf(user1);
        console.log("Ending balance:", endingBalance);

        assertEq(endingBalance, AMOUNT_CLAIM);
    }


    function testCannotDoubleClaim() public {

        bytes32 digest = merkleAirdrop.getMessage(user1, AMOUNT_CLAIM);
        console.log("User address:", user1);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(user1PrivateKey, digest);

        // First claim
        vm.prank(gasPayer);
        merkleAirdrop.claim(user1, AMOUNT_CLAIM, PROOF, v, r, s);

        // Attempt to claim again
        vm.prank(gasPayer);
        vm.expectRevert(Merkle_Airdrop.Merkle_Airdrop__AlreadyClaimed.selector);
        merkleAirdrop.claim(user1, AMOUNT_CLAIM, PROOF, v, r, s);

    }

    function testInvalidProofFails() public {
        bytes32 digest = merkleAirdrop.getMessage(user1, AMOUNT_CLAIM);
        console.log("User address:", user1);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(user1PrivateKey, digest);

        // Modify the proof to be invalid
        bytes32[] memory invalidProof = new bytes32[](2);
        invalidProof[0] = bytes32(0x0); // Invalid value
        invalidProof[1] = PROOF[1];

        vm.prank(gasPayer);
        vm.expectRevert(Merkle_Airdrop.Merkle_Airdrop__InvalidProof.selector);
        merkleAirdrop.claim(user1, AMOUNT_CLAIM, invalidProof, v, r, s);
    } 

    function testGetters() public {
        bytes32 merkleRoot = merkleAirdrop.getMerkleRoot();
        console.log("Merkle Root from getter:", vm.toString(merkleRoot));

        address tokenAddress = address(merkleAirdrop.getAirdropToken());
        console.log("Airdrop Token address from getter:", tokenAddress);

        assertEq(merkleRoot, merkleAirdrop.getMerkleRoot());
        assertEq(tokenAddress, address(token));
    }

}