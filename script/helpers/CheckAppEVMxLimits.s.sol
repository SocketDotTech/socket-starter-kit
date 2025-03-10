// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {WatcherPrecompile} from "socket-protocol/contracts/protocol/watcherPrecompile/WatcherPrecompile.sol";
import {LimitParams} from "socket-protocol/contracts/protocol/utils/common/Structs.sol";
import {SCHEDULE, QUERY, FINALIZE} from "socket-protocol/contracts/protocol/utils/common/Constants.sol";

contract CheckLimitsScript is Script {
    function run() external {
        string memory rpc = vm.envString("EVMX_RPC");
        vm.createSelectFork(rpc);

        address watcherPrecompile = vm.envAddress("WATCHER_PRECOMPILE");
        address appGateway = vm.envAddress("APP_GATEWAY");

        console.log("WatcherPrecompile address:", watcherPrecompile);
        console.log("AppGateway address:", appGateway);
        WatcherPrecompile watcherContract = WatcherPrecompile(watcherPrecompile);

        LimitParams memory scheduleLimit = watcherContract.getLimitParams(SCHEDULE, appGateway);
        LimitParams memory queryLimit = watcherContract.getLimitParams(QUERY, appGateway);
        LimitParams memory finalizeLimit = watcherContract.getLimitParams(FINALIZE, appGateway);

        uint256 scheduleCurrentLimit = watcherContract.getCurrentLimit(SCHEDULE, appGateway);
        uint256 queryCurrentLimit = watcherContract.getCurrentLimit(QUERY, appGateway);
        uint256 finalizeCurrentLimit = watcherContract.getCurrentLimit(FINALIZE, appGateway);

        console.log("Schedule max limit:");
        console.log(scheduleLimit.maxLimit);
        console.log("Schedule rate per second:");
        console.log(scheduleLimit.ratePerSecond);
        console.log("Schedule current limit:");
        console.log(scheduleCurrentLimit);

        console.log("Query max limit:");
        console.log(queryLimit.maxLimit);
        console.log("Query rate per second:");
        console.log(queryLimit.ratePerSecond);
        console.log("Query current limit:");
        console.log(queryCurrentLimit);

        console.log("Finalize max limit:");
        console.log(finalizeLimit.maxLimit);
        console.log("Finalize rate per second:");
        console.log(finalizeLimit.ratePerSecond);
        console.log("Finalize current limit:");
        console.log(finalizeCurrentLimit);
    }
}
