// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.21;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {FeesPlug} from "socket-protocol/contracts/evmx/plugs/FeesPlug.sol";
// source .env && forge script script/helpers/DepositCreditAndNative.s.sol --broadcast --skip-simulation

interface IERC20 {
    function approve(address spender, uint256 value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract DepositCredit is Script {
    function run() external {
        uint256 feesAmount = 1000000; // 1 USDC
        console.log("Fees Amount:", feesAmount, "1 USDC");
        FeesPlug feesPlug = FeesPlug(payable(vm.envAddress("ARBITRUM_FEES_PLUG")));
        console.log("Fees Plug:", address(feesPlug));

        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address sender = vm.addr(privateKey);
        console.log("Sender address:", sender);

        address arbitrumUSDC = vm.envAddress("ARBITRUM_USDC");
        IERC20 USDCContract = IERC20(arbitrumUSDC);
        USDCContract.approve(address(feesPlug), feesAmount);
        uint256 balance = USDCContract.balanceOf(sender);
        console.log("Sender USDC balance:", balance);
        if (balance < feesAmount) {
            revert("Sender does not have enough USDC");
        }

        vm.createSelectFork(vm.envString("ARBITRUM_RPC"));
        vm.startBroadcast(privateKey);

        address appGateway = vm.envAddress("APP_GATEWAY");
        console.log("App Gateway:", appGateway);
        feesPlug.depositCreditAndNative(arbitrumUSDC, appGateway, feesAmount);
    }
}
