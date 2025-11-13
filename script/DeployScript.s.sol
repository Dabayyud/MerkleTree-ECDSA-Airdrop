// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "lib/forge-std/src/Script.sol";
import {DabbayudToken} from "../src/DabayyudToken.sol";
import {console} from "lib/forge-std/src/console.sol";
import {Merkle} from "lib/murky/src/Merkle.sol";
import {ScriptHelper} from "lib/murky/script/common/ScriptHelper.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {Merkle_Airdrop} from "../src/MerkleAirdrop.sol";
import {HelperConfig, NetworkConfig} from "./HelperConfig.s.sol";

contract DeployScript is Script, ScriptHelper {
    HelperConfig public helperConfig;


    function deployMerkleAirdrop() public returns (Merkle_Airdrop, DabbayudToken) {
        // Get configuration based on current chain
        helperConfig = new HelperConfig();
        NetworkConfig memory config = helperConfig.getActiveNetworkConfig();

        console.log("Deploying on chain ID:", block.chainid);
        console.log("Using Merkle Root:", vm.toString(config.merkleRoot));
        console.log("Amount to transfer:", config.amountToTransfer);
        
        vm.startBroadcast();
        DabbayudToken token = new DabbayudToken();
        Merkle_Airdrop merkleAirdrop = new Merkle_Airdrop(config.merkleRoot, IERC20(address(token)));
        token.mint(token.owner(), config.amountToTransfer);
        token.transfer(address(merkleAirdrop), config.amountToTransfer);
        console.log("Deployed Merkle Airdrop at:", address(merkleAirdrop)); 
        console.log("Deployed Dabbayud Token at:", address(token));
        vm.stopBroadcast();
        return (merkleAirdrop, token);
    }

    function run() external returns (Merkle_Airdrop, DabbayudToken) {
        return deployMerkleAirdrop();
    }
}
