// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "socket-protocol/contracts/base/AppGatewayBase.sol";
import "solady/auth/Ownable.sol";
import {ISuperToken} from "./ISuperToken.sol";

/**
 * @title SuperTokenApp
 * @notice A cross-chain application for bridging tokens
 * @dev Extends AppGatewayBase and Ownable to provide a chain abstracted token bridging functionality
 */
contract SuperTokenApp is AppGatewayBase, Ownable {
    /**
     * @notice Counter to track unique transaction IDs
     * @dev Incremented with each bridging operation
     */
    uint256 public idCounter;

    /**
     * @notice Emitted when a token bridging operation is initiated
     * @param asyncId Unique identifier for the asynchronous cross-chain transaction
     */
    event Bridged(bytes32 asyncId);

    /**
     * @notice Represents a user's token bridging order
     * @dev Contains details of the token transfer across different chains
     */
    struct UserOrder {
        /// @notice Source token contract address
        address srcToken;
        /// @notice Destination token contract address
        address dstToken;
        /// @notice User initiating the bridge transaction
        address user;
        /// @notice Amount of tokens to be bridged from source chain
        uint256 srcAmount;
        /// @notice Deadline for the bridge transaction
        uint256 deadline;
    }

    /**
     * @notice Constructor to initialize the SuperTokenApp
     * @param _addressResolver Address of the cross-chain address resolver
     * @param deployerContract_ Address of the contract deployer
     * @param feesData_ Struct containing fee-related data for bridging
     * @dev Sets up the contract, initializes ownership, and configures gateways
     */
    constructor(
        address _addressResolver,
        address deployerContract_,
        FeesData memory feesData_
    ) AppGatewayBase(_addressResolver) Ownable() {
        _initializeOwner(msg.sender);
        addressResolver.setContractsToGateways(deployerContract_);
        _setFeesData(feesData_);
    }

    /**
     * @notice Validates user's token balance for a cross-chain transaction
     * @param data Encoded user order and async transaction ID
     * @param returnData Balance data returned from the source chain
     * @dev Checks if user has sufficient balance to complete the bridge transaction
     * @custom:modifier onlyPromises Ensures the function can only be called by the promises system
     */
    function checkBalance(
        bytes memory data,
        bytes memory returnData
    ) external onlyPromises {
        (UserOrder memory order, bytes32 asyncId) = abi.decode(
            data,
            (UserOrder, bytes32)
        );

        uint256 balance = abi.decode(returnData, (uint256));
        if (balance < order.srcAmount) {
            _revertTx(asyncId);
            return;
        }
    }

    /**
     * @notice Initiates a cross-chain token bridge transaction
     * @param _order Encoded user order details
     * @return asyncId Unique identifier for the asynchronous cross-chain transaction
     * @dev Handles token bridging logic across different chains
     */
    function bridge(
        bytes memory _order
    ) external async returns (bytes32 asyncId) {
        UserOrder memory order = abi.decode(_order, (UserOrder));
        asyncId = _getCurrentAsyncId();
        /* TODO:
            1. Check user balance on src chain
            2. Check if it was a already deployed contract
                if original contract,
                    transferFrom user to Vault
                    mint to user on dst chain
                if supertoken,
                    burn from user
                    transferFrom Vault to user
        */

        emit Bridged(asyncId);
    }

    /**
     * @notice Allows the owner to withdraw fee tokens from a specific chain
     * @param chainSlug_ Unique identifier of the blockchain
     * @param token_ Address of the token to withdraw
     * @param amount_ Amount of tokens to withdraw
     * @param receiver_ Address receiving the withdrawn tokens
     * @dev Restricted to contract owner
     * @custom:modifier onlyOwner Ensures only the contract owner can withdraw fees
     */
    function withdrawFeeTokens(
        uint32 chainSlug_,
        address token_,
        uint256 amount_,
        address receiver_
    ) external onlyOwner {
        _withdrawFeeTokens(chainSlug_, token_, amount_, receiver_);
    }

    // TODO: Add rescue tokens from Vault in chainSlug
}
