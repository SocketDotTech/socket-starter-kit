// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {FeesManager} from "socket-protocol/contracts/protocol/payload-delivery/FeesManager.sol";
import {Fees} from "socket-protocol/contracts/protocol/utils/common/Structs.sol";
import {ETH_ADDRESS} from "socket-protocol/contracts/protocol/utils/common/Constants.sol";

contract CheckDepositedFees is Script {
    function run() external {
        vm.createSelectFork(vm.envString("EVMX_RPC"));
        FeesManager feesManager = FeesManager(payable(vm.envAddress("FEES_MANAGER")));
        address appGateway = vm.envAddress("APP_GATEWAY");

        (uint256 deposited, uint256 blocked) = feesManager.appGatewayFeeBalances(appGateway, 421614, ETH_ADDRESS);
        console.log("AppGateway:", appGateway);
        console.log("Deposited fees:", deposited);
        console.log("Blocked fees:", blocked);

        uint256 availableFees = feesManager.getAvailableFees(421614, appGateway, ETH_ADDRESS);
        console.log("Available fees:", availableFees);
    }
}
