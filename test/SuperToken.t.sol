// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "socket-protocol/test/AuctionHouse.sol";

import {SuperTokenDeployer} from "../src/superToken/SuperTokenDeployer.sol";
import {SuperTokenAppGateway} from "../src/superToken/SuperTokenAppGateway.sol";

contract SuperTokenTest is AuctionHouseTest {
    struct AppContracts {
        SuperTokenAppGateway superTokenApp;
        SuperTokenDeployer superTokenDeployer;
        bytes32 superToken;
        bytes32 vault;
    }

    AppContracts appContracts;
    uint256 srcAmount = 0.01 ether;
    SuperTokenAppGateway.UserOrder userOrder;

    event BatchCancelled(bytes32 indexed asyncId);
    event FinalizeRequested(bytes32 indexed payloadId, AsyncRequest asyncRequest);

    function setUp() public {
        // set up infrastructure
        setUpAuctionHouse();
        // TODO: Will need to deploy an initial ERC20
        // Deploy Deployer and AppGateway
        deploySuperTokenApp();
    }

    function deploySuperTokenApp() internal {
        SuperTokenDeployer superTokenDeployer = new SuperTokenDeployer(
            uint32(0), // TODO: Add some chain address like ArbSepolia
            address(0), // TODO: Add token address deployed on setUp
            owner,
            "SUPER TOKEN",
            "SUPER",
            18,
            address(addressResolver),
            createFeesData(maxFees)
        );
        SuperTokenAppGateway superTokenApp =
            new SuperTokenAppGateway(address(addressResolver), address(superTokenDeployer), createFeesData(maxFees));

        appContracts = AppContracts({
            superTokenApp: superTokenApp,
            superTokenDeployer: superTokenDeployer,
            superToken: superTokenDeployer.superToken(),
            vault: superTokenDeployer.vault()
        });
    }
}
