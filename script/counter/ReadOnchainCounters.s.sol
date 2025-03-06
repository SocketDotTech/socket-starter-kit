// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

import {CounterAppGateway} from "../../src/counter/CounterAppGateway.sol";
import {Counter} from "../../src/counter/Counter.sol";

/**
 * @title CheckCounters Script
 * @notice Reads the current counter values from deployed Counter contracts across multiple chains
 * @dev This script:
 *      1. Retrieves the deployed CounterAppGateway
 *      2. Gets the onchain addresses of Counter contracts deployed on different chains
 *      3. Connects to each chain and reads the current counter value
 *      4. Outputs the counter values and blockchain explorer links
 *
 *      This demonstrates how to retrieve and read state from contracts deployed through
 *      Socket Protocol across multiple chains.
 *
 *      Required environment variables:
 *      - APP_GATEWAY: Address of the deployed CounterAppGateway
 *      - EVMX_RPC: RPC URL for the EVMx network
 *      - ARBITRUM_SEPOLIA_RPC: RPC URL for Arbitrum Sepolia
 *      - OPTIMISM_SEPOLIA_RPC: RPC URL for Optimism Sepolia
 *      - BASE_SEPOLIA_RPC: RPC URL for Base Sepolia
 */
contract CheckCounters is Script {
    function run() external {
        CounterAppGateway appGateway = CounterAppGateway(vm.envAddress("APP_GATEWAY"));
        console.log("See AppGateway on EVMx: https://evmx.cloud.blockscout.com/address/%s", address(appGateway));

        vm.createSelectFork(vm.envString("EVMX_RPC"));
        // From your AppGateway you can retrieve a contract's onchain address that is used by your AppGateway
        // The input arguments are the bytes32 contract id as well as the uint32 chain id
        address counterInstanceArbitrumSepolia = appGateway.getOnChainAddress(appGateway.counter(), 421614);
        address counterInstanceOptimismSepolia = appGateway.getOnChainAddress(appGateway.counter(), 11155420);
        address counterInstanceBaseSepolia = appGateway.getOnChainAddress(appGateway.counter(), 84532);

        // If there is no onchain address associated with the input params it will return the zero address
        if (counterInstanceArbitrumSepolia != address(0)) {
            vm.createSelectFork(vm.envString("ARBITRUM_SEPOLIA_RPC"));
            uint256 counterValueArbitrumSepolia = Counter(counterInstanceArbitrumSepolia).counter();
            console.log("Counter value on Arbitrum Sepolia: ", counterValueArbitrumSepolia);
            console.log(
                "See Counter on Arbitrum: https://sepolia.arbiscan.io/address/%s", counterInstanceArbitrumSepolia
            );
        } else {
            console.log("Counter not yet deployed on Arbitrum Sepolia");
        }

        if (counterInstanceOptimismSepolia != address(0)) {
            vm.createSelectFork(vm.envString("OPTIMISM_SEPOLIA_RPC"));
            uint256 counterValueOptimismSepolia = Counter(counterInstanceOptimismSepolia).counter();
            console.log("Counter value on Optimism Sepolia: ", counterValueOptimismSepolia);
            console.log(
                "See Counter on Optimism: https://optimism-sepolia.blockscout.com/address/%s",
                counterInstanceOptimismSepolia
            );
        } else {
            console.log("Counter not yet deployed on Optimism Sepolia");
        }

        if (counterInstanceBaseSepolia != address(0)) {
            vm.createSelectFork(vm.envString("BASE_SEPOLIA_RPC"));
            uint256 counterValueBaseSepolia = Counter(counterInstanceBaseSepolia).counter();
            console.log("Counter value on Base Sepolia: ", counterValueBaseSepolia);
            console.log("See Counter on Base: https://sepolia.basescan.org/address/%s", counterInstanceBaseSepolia);
        } else {
            console.log("Counter not yet deployed on Base Sepolia");
        }
    }
}
