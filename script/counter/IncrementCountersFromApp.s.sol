// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

import {CounterAppGateway} from "../../src/counter/CounterAppGateway.sol";

/**
 * @title IncrementCounters Script
 * @notice Increments counters across multiple chains through the AppGateway
 * @dev This script:
 *      1. Connects to the EVMx network
 *      2. Retrieves the deployed CounterAppGateway
 *      3. Gets the forwarder addresses for each deployed Counter contract on different chains
 *      4. Calls incrementCounters to increment all non-zero counter instances
 *
 *      This demonstrates chain-abstracted interaction where a single transaction on EVMx
 *      can update state on multiple other chains through SOCKET Protocol.
 *
 *      Required environment variables:
 *      - EVMX_RPC: RPC URL for the EVMx network
 *      - PRIVATE_KEY: Private key of the deployer account
 *      - APP_GATEWAY: Address of the deployed CounterAppGateway
 */
contract IncrementCounters is Script {
    function run() external {
        string memory socketRPC = vm.envString("EVMX_RPC");
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.createSelectFork(socketRPC);

        CounterAppGateway appGateway = CounterAppGateway(vm.envAddress("APP_GATEWAY"));
        console.log("See AppGateway on EVMx: https://evmx.cloud.blockscout.com/address/%s", address(appGateway));

        // Read https://docs.socket.tech/forwarder-addresses to learn more about
        // how forwarder addresses are assigned on the EVMx to represent onchain contracts
        address counterForwarderArbitrumSepolia = appGateway.forwarderAddresses(appGateway.counter(), 421614);
        address counterForwarderOptimismSepolia = appGateway.forwarderAddresses(appGateway.counter(), 11155420);
        address counterForwarderBaseSepolia = appGateway.forwarderAddresses(appGateway.counter(), 84532);

        // Count non-zero addresses
        uint256 nonZeroCount = 0;
        if (counterForwarderArbitrumSepolia != address(0)) nonZeroCount++;
        if (counterForwarderOptimismSepolia != address(0)) nonZeroCount++;
        if (counterForwarderBaseSepolia != address(0)) nonZeroCount++;

        address[] memory instances = new address[](nonZeroCount);
        uint256 index = 0;
        if (counterForwarderArbitrumSepolia != address(0)) {
            instances[index] = counterForwarderArbitrumSepolia;
            index++;
        } else {
            console.log("Arbitrum Sepolia forwarder not yet deployed");
        }
        if (counterForwarderOptimismSepolia != address(0)) {
            instances[index] = counterForwarderOptimismSepolia;
            index++;
        } else {
            console.log("Optimism Sepolia forwarder not yet deployed");
        }
        if (counterForwarderBaseSepolia != address(0)) {
            instances[index] = counterForwarderBaseSepolia;
            index++;
        } else {
            console.log("Base Sepolia forwarder not yet deployed");
        }

        if (instances.length > 0) {
            vm.startBroadcast(deployerPrivateKey);
            appGateway.incrementCounters(instances);
        } else {
            console.log("No forwarder addresses found");
        }
    }
}
