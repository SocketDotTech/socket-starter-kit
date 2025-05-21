// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {FeesPlug} from "socket-protocol/contracts/evmx/payload-delivery/FeesPlug.sol";
import {TestUSDC} from "socket-protocol/contracts/evmx/helpers/TestUSDC.sol";

contract DepositFees is Script {
    function run() external {
        vm.createSelectFork(vm.envString("ARBITRUM_SEPOLIA_RPC"));

        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address sender = vm.addr(privateKey);

        uint256 feesAmount = 100000000; // 10 USDC
        FeesPlug feesPlug = FeesPlug(payable(vm.envAddress("ARBITRUM_FEES_PLUG")));
        address appGateway = vm.envAddress("APP_GATEWAY");
        TestUSDC testUSDCContract = TestUSDC(vm.envAddress("ARBITRUM_TEST_USDC"));

        vm.startBroadcast(privateKey);
        // mint test USDC to sender
        testUSDCContract.mint(sender, feesAmount);
        // approve fees plug to spend test USDC
        testUSDCContract.approve(address(feesPlug), feesAmount);

        uint256 balance = testUSDCContract.balanceOf(sender);
        console.log("Using address %s with %s balance in wei", sender, balance);

        console.log("Depositing 100 TestUSDC on Arbitrum FeesPlug %s", address(feesPlug));
        feesPlug.depositToFeeAndNative(address(testUSDCContract), appGateway, feesAmount);
        console.log("Added fee balance for AppGateway %s", feesAmount, appGateway);
    }
}
