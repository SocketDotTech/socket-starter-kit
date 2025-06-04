// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {FeesManager} from "socket-protocol/contracts/evmx/fees/FeesManager.sol";

contract CheckAvailableCredits is Script {
    function run() external {
        FeesManager feesManager = FeesManager(payable(vm.envAddress("FEES_MANAGER")));

        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address sender = vm.addr(privateKey);
        console.log("Sender address:", sender);

        vm.createSelectFork(vm.envString("EVMX_RPC"));

        (uint256 deposited, uint256 blocked) = feesManager.userCredits(sender);
        console.log("Total balance of available credits for this address: %s", deposited);
        console.log("Credits being locked due to existing transactions: %s", blocked);

        uint256 availableFees = feesManager.getAvailableCredits(sender);
        console.log("Credits available to be spent on transactions: %s", availableFees);
    }
}
