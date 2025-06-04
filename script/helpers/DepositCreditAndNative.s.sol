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
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address sender = vm.addr(privateKey);
        console.log("Sender address:", sender);

        FeesPlug feesPlug = FeesPlug(payable(vm.envAddress("ARBITRUM_FEES_PLUG")));
        address arbitrumUSDC = vm.envAddress("ARBITRUM_USDC");
        IERC20 USDCContract = IERC20(arbitrumUSDC);

        vm.createSelectFork(vm.envString("ARBITRUM_RPC"));
        vm.startBroadcast(privateKey);
        uint256 balance = USDCContract.balanceOf(sender);

        uint256 feesAmount = 1000000; // 1 USDC
        if (balance < feesAmount) {
            console.log("Sender USDC balance:", balance);
            revert("Sender does not have enough USDC. Requires 1 USDC.");
        }

        console.log("Depositing", feesAmount, " - 1 USDC to Arbitrum FeesPlug:", address(feesPlug));
        console.log("Approving Spending...");
        USDCContract.approve(address(feesPlug), feesAmount);

        feesPlug.depositCreditAndNative(arbitrumUSDC, sender, feesAmount);
        console.log("Corresponding EVMx credits will show up on your account");
    }
}
