// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

import {CounterAppGateway} from "../../src/counter/CounterAppGateway.sol";

/**
 * @title CounterDeployOnchain Script
 * @notice Deploys Counter contracts to multiple target chains through the AppGateway
 * @dev This script:
 *      1. Connects to the EVMx network
 *      2. Retrieves the previously deployed AppGateway contract
 *      3. Deploys Counter contracts to Arbitrum Sepolia, Optimism Sepolia, and Base Sepolia chains
 *
 *      This is the second step, after adding fees, in the deployment process after the AppGateway has been deployed.
 *      Each deployment creates a new Counter contract instance on the target chain.
 *
 *      Required environment variables:
 *      - EVMX_RPC: RPC URL for the EVMx network
 *      - PRIVATE_KEY: Private key of the deployer account
 *      - APP_GATEWAY: Address of the previously deployed CounterAppGateway
 */
contract CounterDeployOnchain is Script {
    function run() external {
        string memory rpc = vm.envString("EVMX_RPC");
        vm.createSelectFork(rpc);

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        CounterAppGateway appGateway = CounterAppGateway(vm.envAddress("APP_GATEWAY"));

        console.log("Counter Gateway:", address(appGateway));
        console.log("See AppGateway on EVMx: https://evmx.cloud.blockscout.com/address/%s", address(appGateway));

        console.log("Deploying contracts on Arbitrum Sepolia...");
        appGateway.deployContracts(421614);
        console.log("Deploying contracts on Optimism Sepolia...");
        appGateway.deployContracts(11155420);
        console.log("Deploying contracts on Base Sepolia...");
        appGateway.deployContracts(84532);
    }
}
