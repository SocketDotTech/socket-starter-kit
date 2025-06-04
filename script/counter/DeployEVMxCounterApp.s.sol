// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

import {CounterAppGateway} from "../../src/counter/CounterAppGateway.sol";

/**
 * @title CounterDeploy Script
 * @notice Deploys the CounterAppGateway contract to the EVMx network
 * @dev This script:
 *      1. Connects to the EVMx network using the provided RPC URL
 *      2. Sets up fee payment configuration for Arbitrum Sepolia
 *      3. Deploys the CounterAppGateway contract
 *      4. Outputs the contract address for further interaction
 *
 *      Required environment variables:
 *      - ADDRESS_RESOLVER: Address of SOCKET Protocol's AddressResolver
 *      - EVMX_RPC: RPC URL for the EVMx network
 *      - PRIVATE_KEY: Private key of the deployer account
 */
contract CounterDeploy is Script {
    function run() external {
        address addressResolver = vm.envAddress("ADDRESS_RESOLVER");
        string memory rpc = vm.envString("EVMX_RPC");
        vm.createSelectFork(rpc);

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Setting fee payment on Arbitrum Sepolia
        uint256 fees = 10 ether;

        CounterAppGateway appGateway = new CounterAppGateway(addressResolver, fees);

        console.log("CounterAppGateway contract:", address(appGateway));
        console.log("See AppGateway on EVMx: https://evmx.cloud.blockscout.com/address/%s", address(appGateway));
        console.log("Do not forget to add the contract address to the .env file!");
    }
}
