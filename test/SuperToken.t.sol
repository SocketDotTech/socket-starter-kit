// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "socket-protocol/test/AuctionHouse.sol";

import {SuperTokenDeployer} from "../src/superToken/SuperTokenDeployer.sol";
import {SuperTokenAppGateway} from "../src/superToken/SuperTokenAppGateway.sol";

import {MockERC20} from "./mocks/MockERC20.sol";

contract SuperTokenTest is AuctionHouseTest {
    uint256 srcAmount = 0.01 ether;

    MockERC20 public token;

    struct AppContracts {
        SuperTokenAppGateway superTokenApp;
        SuperTokenDeployer superTokenDeployer;
        bytes32 superToken;
        bytes32 vault;
    }

    AppContracts appContracts;
    SuperTokenAppGateway.UserOrder userOrder;

    event BatchCancelled(bytes32 indexed asyncId);
    event FinalizeRequested(bytes32 indexed payloadId, AsyncRequest asyncRequest);

    function setUp() public {
        // set up infrastructure
        setUpAuctionHouse();

        // Deploy mock ERC20
        token = new MockERC20("Mock Token", "MCK", 18);
        token.mint(address(this), 1000 * 10 ** 18);

        // Deploy Deployer and AppGateway
        deploySuperTokenApp();
    }

    function deploySuperTokenApp() internal {
        SuperTokenDeployer superTokenDeployer = new SuperTokenDeployer(
            optChainSlug,
            address(token),
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

    ////////////////////////
    //  HELPER FUNCTIONS  //
    ////////////////////////

    // To mint tokens for testing to any user if needed
    function mintTokens(address to, uint256 amount) internal {
        token.mint(to, amount);
    }
}
