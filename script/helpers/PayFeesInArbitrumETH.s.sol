// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {FeesPlug} from "socket-protocol/contracts/protocol/payload-delivery/FeesPlug.sol";
import {Fees} from "socket-protocol/contracts/protocol/utils/common/Structs.sol";
import {ETH_ADDRESS} from "socket-protocol/contracts/protocol/utils/common/Constants.sol";

contract DepositFees is Script {
    function run() external {
        vm.createSelectFork(vm.envString("ARBITRUM_SEPOLIA_RPC"));

        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);
        FeesPlug feesPlug = FeesPlug(payable(vm.envAddress("ARBITRUM_FEES_PLUG")));
        address appGateway = vm.envAddress("APP_GATEWAY");

        address sender = vm.addr(privateKey);
        uint256 balance = sender.balance;
        console.log("Using address %s with %s balance in wei", sender, balance);

        uint256 feesAmount = 0.001 ether;
        console.log("Depositing 0.001 ether on Arbitrum FeesPlug %s", address(feesPlug));
        feesPlug.deposit{value: feesAmount}(ETH_ADDRESS, appGateway, feesAmount);
        console.log("Added fee balance for AppGateway %s", feesAmount, appGateway);
    }
}
