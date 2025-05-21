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
        console.log("Minting 100 TestUSDC to %s", sender);
        // approve fees plug to spend test USDC
        testUSDCContract.approve(address(feesPlug), feesAmount);

        uint256 balance = testUSDCContract.balanceOf(sender);
        console.log("Using address %s with %s TestUSDC balance in wei", sender, balance);

        console.log("Depositing 100 TestUSDC on Arbitrum FeesPlug %s", address(feesPlug));
        feesPlug.depositToFeeAndNative(address(testUSDCContract), appGateway, feesAmount);
        console.log("Added 90 credits for fee balance and 10 native credits for AppGateway %s", appGateway);
        console.log("If you want to deposit to fees only, it can be deposited using `depositToFee`");
    }
}
