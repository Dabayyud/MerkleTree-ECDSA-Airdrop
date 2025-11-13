// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "lib/forge-std/src/Script.sol";
import {Merkle} from "lib/murky/src/Merkle.sol";
import {console} from "lib/forge-std/src/console.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";

abstract contract NetworkID {

    uint256 internal constant ZKSYNC_MAINNET_ID = 324;
    uint256 internal constant ZKSYNC_TESTNET_ID = 280;
    uint256 internal constant LOCALHOST_ID = 31337;
    uint256 internal constant SEPOLIA_ID = 11155111;
}

struct NetworkConfig {
    bytes32 merkleRoot;
    uint256 amountToTransfer;
    Merkle merkleInstance;
}

contract HelperConfig is Script, NetworkID, ZkSyncChainChecker {
    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == SEPOLIA_ID) {
            activeNetworkConfig = getSepoliaConfig();
        } else if (block.chainid == ZKSYNC_MAINNET_ID) {
            activeNetworkConfig = getZkSyncMainnetConfig();
        } else if (block.chainid == ZKSYNC_TESTNET_ID) {
            activeNetworkConfig = getZkSyncTestnetConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilConfig();
        }
    }

    function getSepoliaConfig() public returns (NetworkConfig memory) {
        return NetworkConfig({
            merkleRoot: 0x7cf5e1f2dbbf2f33954bb2ce572644b0f601f98e57b8f89d0d754739aa6940cd,
            amountToTransfer: 72 * 1e18,
            merkleInstance: new Merkle()
        });
    }

    function getZkSyncMainnetConfig() public returns (NetworkConfig memory) {
        return NetworkConfig({
            merkleRoot: 0x7cf5e1f2dbbf2f33954bb2ce572644b0f601f98e57b8f89d0d754739aa6940cd,
            amountToTransfer: 72 * 1e18,
            merkleInstance: new Merkle()
        });
    }

    function getZkSyncTestnetConfig() public returns (NetworkConfig memory) {
        return NetworkConfig({
            merkleRoot: 0x7cf5e1f2dbbf2f33954bb2ce572644b0f601f98e57b8f89d0d754739aa6940cd,
            amountToTransfer: 72 * 1e18,
            merkleInstance: new Merkle()
        });
    }

    function getOrCreateAnvilConfig() public returns (NetworkConfig memory) {
        // This is for local development (Anvil/Hardhat)
        return NetworkConfig({
            merkleRoot: 0x7cf5e1f2dbbf2f33954bb2ce572644b0f601f98e57b8f89d0d754739aa6940cd,
            amountToTransfer: 72 * 1e18,
            merkleInstance: new Merkle()
        });
    }

    function getActiveNetworkConfig() external view returns (NetworkConfig memory) {
        return activeNetworkConfig;
    }
}