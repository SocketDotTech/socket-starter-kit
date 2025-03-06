// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "socket-protocol/contracts/base/AppGatewayBase.sol";
import "socket-protocol/contracts/interfaces/IForwarder.sol";
import "socket-protocol/contracts/interfaces/IPromise.sol";
import "./Counter.sol";
import "./ICounter.sol";

/**
 * @title CounterAppGateway
 * @dev Gateway contract for the Counter application that manages cross-chain counter contract deployments
 * and interactions through SOCKET Protocol.
 * Inherits from AppGatewayBase for SOCKET Protocol integration and Ownable for access control.
 */
contract CounterAppGateway is AppGatewayBase, Ownable {
    /**
     * @notice Identifier for the counter contract
     * @dev Used to track counter contract instances across chains
     */
    bytes32 public counter = _createContractId("counter");

    /**
     * @notice Constructs the CounterAppGateway
     * @dev Sets up the creation code for the Counter contract, configures fee overrides,
     * and initializes ownership
     * @param addressResolver_ Address of the SOCKET Protocol's AddressResolver contract
     * @param fees_ Fee configuration for multi-chain operations
     */
    constructor(address addressResolver_, Fees memory fees_) AppGatewayBase(addressResolver_) {
        creationCodeWithArgs[counter] = abi.encodePacked(type(Counter).creationCode);
        _setOverrides(fees_);
        _initializeOwner(msg.sender);
    }

    /**
     * @notice Deploys Counter contracts to a specified chain
     * @dev Triggers an asynchronous multi-chain deployment via SOCKET Protocol
     * @param chainSlug_ The identifier of the target chain
     */
    function deployContracts(uint32 chainSlug_) external async {
        _deploy(counter, chainSlug_, IsPlug.YES);
    }

    /**
     * @notice Initialize function required by AppGatewayBase
     * @dev No initialization needed for this application, so implementation is empty.
     *      The chainSlug parameter is required by the interface but not used.
     */
    function initialize(uint32 /* chainSlug_ */ ) public pure override {
        return;
    }

    /**
     * @notice Increments counter values on multiple instances across chains
     * @dev Calls the increase function on each counter instance provided
     * @param instances_ Array of counter contract addresses to increment
     */
    function incrementCounters(address[] memory instances_) public async {
        for (uint256 i = 0; i < instances_.length; i++) {
            ICounter(instances_[i]).increase();
        }
    }

    /**
     * @notice Updates the fee configuration
     * @dev Allows the owner to modify fee settings for multi-chain operations
     * @param fees_ New fee configuration
     */
    function setFees(Fees memory fees_) public {
        fees = fees_;
    }

    /**
     * @notice Withdraws fee tokens from the SOCKET Protocol
     * @dev Allows withdrawal of accumulated fees to a specified receiver
     * @param chainSlug_ The chain from which to withdraw fees
     * @param token_ The token address to withdraw
     * @param amount_ The amount to withdraw
     * @param receiver_ The address that will receive the withdrawn fees
     */
    function withdrawFeeTokens(uint32 chainSlug_, address token_, uint256 amount_, address receiver_) external {
        _withdrawFeeTokens(chainSlug_, token_, amount_, receiver_);
    }
}
