// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import "socket-protocol/contracts/evmx/interfaces/IFeesManager.sol";

import {CounterAppGateway} from "../../src/counter/CounterAppGateway.sol";

/**
 * @title WithdrawCredits Script
 * @notice Withdraws accumulated fees from EVMX to Arbitrum Sepolia
 * @dev This script:
 *      1. Checks available fees on EVMX
 *      2. Performs the withdrawal if the amount is positive
 *
 *      This demonstrates how developers can retrieve fees that their application has earned
 *      through SOCKET Protocol's fee system.
 */
contract WithdrawCredits is Script {
    function run() external {
        // EVMX Check available fees
        vm.createSelectFork(vm.envString("EVMX_RPC"));
        IFeesManager feesManager = IFeesManager(payable(vm.envAddress("FEES_MANAGER")));
        address token = vm.envAddress("ARBITRUM_USDC");
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address sender = vm.addr(privateKey);

        uint256 availableCredits = feesManager.getAvailableCredits(sender);
        console.log("Available credits:", availableCredits);
        //consfeesManager.tokenOntokenOnChainBalances[42161][token];

        if (availableCredits > 0) {
            uint256 maxFees = 10000000000000000; // Static 1 cent USDC credit (18 decimals)
            // TODO: Also wrap native amount to be able to max withdraw
            uint256 amountToWithdraw = availableCredits - maxFees;

            if (amountToWithdraw > 0) {
                vm.startBroadcast(privateKey);
                AppGatewayApprovals[] memory approvals = new AppGatewayApprovals[](1);
                approvals[0] = AppGatewayApprovals({appGateway: address(feesManager), approval: true});
                feesManager.approveAppGateways(approvals);
                console.log("Withdrawing amount:", amountToWithdraw);
                feesManager.withdrawCredits(42161, token, amountToWithdraw, maxFees, sender);
                vm.stopBroadcast();
            } else {
                console.log("Available fees less than estimated gas cost");
            }
        }
    }
}
