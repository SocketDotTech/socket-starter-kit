// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

import {CounterAppGateway} from "../../src/counter/CounterAppGateway.sol";
import {Counter} from "../../src/counter/Counter.sol";

contract CheckCounters is Script {
    function run() external {
        CounterAppGateway appGateway = CounterAppGateway(vm.envAddress("APP_GATEWAY"));
        console.log("See AppGateway on EVMx: https://evmx.cloud.blockscout.com/address/%s", address(appGateway));

        vm.createSelectFork(vm.envString("EVMX_RPC"));
        address counterInstanceArbitrumSepolia = appGateway.getOnChainAddress(appGateway.counter(), 421614);
        address counterInstanceOptimismSepolia = appGateway.getOnChainAddress(appGateway.counter(), 11155420);
        address counterInstanceBaseSepolia = appGateway.getOnChainAddress(appGateway.counter(), 84532);

        if (counterInstanceArbitrumSepolia != address(0)) {
            vm.createSelectFork(vm.envString("ARBITRUM_SEPOLIA_RPC"));
            uint256 counterValueArbitrumSepolia = Counter(counterInstanceArbitrumSepolia).counter();
            console.log("Counter value on Arbitrum Sepolia: ", counterValueArbitrumSepolia);
            console.log(
                "See Counter on Arbitrum: https://sepolia.arbiscan.io/address/%s", counterInstanceArbitrumSepolia
            );
        } else {
            console.log("Counter not yet deployed on Arbitrum Sepolia");
        }

        if (counterInstanceOptimismSepolia != address(0)) {
            vm.createSelectFork(vm.envString("OPTIMISM_SEPOLIA_RPC"));
            uint256 counterValueOptimismSepolia = Counter(counterInstanceOptimismSepolia).counter();
            console.log("Counter value on Optimism Sepolia: ", counterValueOptimismSepolia);
            console.log(
                "See Counter on Optimism: https://optimism-sepolia.blockscout.com/address/%s",
                counterInstanceOptimismSepolia
            );
        } else {
            console.log("Counter not yet deployed on Optimism Sepolia");
        }

        if (counterInstanceBaseSepolia != address(0)) {
            vm.createSelectFork(vm.envString("BASE_SEPOLIA_RPC"));
            uint256 counterValueBaseSepolia = Counter(counterInstanceBaseSepolia).counter();
            console.log("Counter value on Base Sepolia: ", counterValueBaseSepolia);
            console.log("See Counter on Base: https://sepolia.basescan.org/address/%s", counterInstanceBaseSepolia);
        } else {
            console.log("Counter not yet deployed on Base Sepolia");
        }
    }
}
