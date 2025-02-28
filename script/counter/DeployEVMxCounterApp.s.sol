// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Fees} from "socket-protocol/contracts/protocol/utils/common/Structs.sol";
import {ETH_ADDRESS, FAST} from "socket-protocol/contracts/protocol/utils/common/Constants.sol";

import {CounterAppGateway} from "../../src/counter/CounterAppGateway.sol";

contract CounterDeploy is Script {
    function run() external {
        address addressResolver = vm.envAddress("ADDRESS_RESOLVER");
        address auctionManager = vm.envAddress("AUCTION_MANAGER");
        string memory rpc = vm.envString("EVMX_RPC");
        vm.createSelectFork(rpc);

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Setting fee payment on Arbitrum Sepolia
        // amount: Minimum fee required in contract and maximum user is willing to pay
        // User must have deposited >= amount, ensuring transmitter gets compensated for including this tx in a batch
        // Current Counter example costs 0.000105 eth
        Fees memory fees = Fees({feePoolChain: 421614, feePoolToken: ETH_ADDRESS, amount: 0.0005 ether});

        CounterAppGateway gateway = new CounterAppGateway(addressResolver, auctionManager, FAST, fees);

        console.log("Contracts deployed:");
        console.log("CounterAppGateway:", address(gateway));
        console.log("counterId:");
        console.logBytes32(gateway.counter());
    }
}
