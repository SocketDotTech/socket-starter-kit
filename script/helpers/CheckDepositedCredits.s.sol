// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {FeesManager} from "socket-protocol/contracts/evmx/fees/FeesManager.sol";

contract CheckDepositedFees is Script {
    function run() external {
        vm.createSelectFork(vm.envString("EVMX_RPC"));
        FeesManager feesManager = FeesManager(payable(vm.envAddress("FEES_MANAGER")));
        address appGateway = vm.envAddress("APP_GATEWAY");

        (uint256 deposited, uint256 blocked) = feesManager.userCredits(appGateway);
        console.log("AppGateway:", appGateway);
        console.log("Total balance of available fees for this AppGateway: %s", deposited);
        console.log("Fees being locked due to existing transactions: %s", blocked);

        uint256 availableFees = feesManager.getAvailableCredits(appGateway);
        console.log("Fees available to be spent on transactions: %s", availableFees);
    }
}
