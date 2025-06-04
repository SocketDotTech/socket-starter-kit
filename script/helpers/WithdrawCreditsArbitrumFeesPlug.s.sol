// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {FeesManager} from "socket-protocol/contracts/evmx/fees/FeesManager.sol";

import {CounterAppGateway} from "../../src/counter/CounterAppGateway.sol";

/**
 * @title WithdrawFees Script
 * @notice Withdraws accumulated fees from EVMX to Arbitrum Sepolia
 * @dev This script:
 *      1. Checks available fees on EVMX
 *      2. Switches to Arbitrum Sepolia to estimate gas costs
 *      3. Calculates a safe amount to withdraw (fees minus estimated gas costs)
 *      4. Performs the withdrawal if the amount is positive
 *      5. Verifies final balance on Arbitrum Sepolia
 *
 *      This demonstrates how developers can retrieve fees that their application has earned
 *      through Socket Protocol's fee system.
 *
 *      Required environment variables:
 *      - EVMX_RPC: RPC URL for the EVMx network
 *      - ARBITRUM_SEPOLIA_RPC: RPC URL for Arbitrum Sepolia
 *      - PRIVATE_KEY: Private key of the deployer account
 *      - FEES_MANAGER: Address of Socket Protocol's FeesManager contract
 *      - APP_GATEWAY: Address of the deployed CounterAppGateway
 * @notice Ensure your app has withdrawFeeTokens() function implemented. You can check its implementation in CounterAppGateway.sol
 */
contract WithdrawFees is Script {
    function run() external {
        // EVMX Check available fees
        vm.createSelectFork(vm.envString("EVMX_RPC"));
        FeesManager feesManager = FeesManager(payable(vm.envAddress("FEES_MANAGER")));
        address appGatewayAddress = vm.envAddress("APP_GATEWAY");
        address token = vm.envAddress("USDC");

        CounterAppGateway appGateway = CounterAppGateway(appGatewayAddress);
        uint256 availableFees = feesManager.getAvailableCredits(appGatewayAddress);
        console.log("Available fees:", availableFees);

        if (availableFees > 0) {
            // Switch to Arbitrum Sepolia to get gas price
            vm.createSelectFork(vm.envString("ARBITRUM_SEPOLIA_RPC"));
            uint256 privateKey = vm.envUint("PRIVATE_KEY");
            address sender = vm.addr(privateKey);

            // Gas price from Arbitrum
            uint256 arbitrumGasPrice = block.basefee + 0.1 gwei; // With buffer
            uint256 gasLimit = 5_000_000; // Estimate
            uint256 estimatedGasCost = gasLimit * arbitrumGasPrice;

            console.log("Arbitrum gas price (wei):", arbitrumGasPrice);
            console.log("Gas limit:", gasLimit);
            console.log("Estimated gas cost:", estimatedGasCost);

            // Calculate amount to withdraw
            uint256 amountToWithdraw = availableFees > estimatedGasCost ? availableFees - estimatedGasCost : 0;

            if (amountToWithdraw > 0) {
                // Switch back to EVMX to perform withdrawal
                vm.createSelectFork(vm.envString("EVMX_RPC"));
                vm.startBroadcast(privateKey);
                console.log("Withdrawing amount:", amountToWithdraw);
                appGateway.withdrawCredits(421614, token, amountToWithdraw, sender);
                vm.stopBroadcast();
            } else {
                console.log("Available fees less than estimated gas cost");
            }
        }
    }
}
