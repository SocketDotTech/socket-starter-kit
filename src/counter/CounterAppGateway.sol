// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "socket-protocol/contracts/evmx/base/AppGatewayBase.sol";
import "socket-protocol/contracts/evmx/interfaces/IForwarder.sol";
import "socket-protocol/contracts/evmx/interfaces/IPromise.sol";
import "./Counter.sol";
import "./ICounter.sol";

/**
 * @title CounterAppGateway
 * @dev Gateway contract for the Counter application that manages multi-chain counter contract deployments
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
     * and initializes ownership.
     * For more information on how contract bytecode is stored in the AppGateway, see:
     * https://docs.socket.tech/writing-apps#onchain-contract-bytecode-stored-in-the-appgateway-contract
     * @param addressResolver_ Address of the SOCKET Protocol's AddressResolver contract
     * @param fees_ Fee configuration for multi-chain operations
     */
    constructor(address addressResolver_, uint256 fees_) {
        creationCodeWithArgs[counter] = abi.encodePacked(type(Counter).creationCode);
        _setMaxFees(fees_);
        _initializeOwner(msg.sender);
        _initializeAppGateway(addressResolver_);
    }

    /**
     * @notice Deploys Counter contracts to a specified chain
     * @dev Triggers an asynchronous multi-chain deployment via SOCKET Protocol.
     * For more information on onchain contract deployment with the AppGateway, see:
     * https://docs.socket.tech/writing-apps#onchain-contract-deployment-with-the-appgateway-contract
     * @param chainSlug_ The identifier of the target chain
     */
    function deployContracts(uint32 chainSlug_) external async {
        // This ensures the msg.sender is the one paying for the fees
        // for more information see: https://docs.socket.tech/fees
        _setOverrides(msg.sender);
        _deploy(counter, chainSlug_, IsPlug.YES);
    }

    /**
     * @notice Initialize function required by AppGatewayBase
     * @dev No initialization needed for this application, so implementation is empty.
     *      The chainSlug parameter is required by the interface but not used.
     *      For more information on the initialize function, see:
     *      https://docs.socket.tech/deploy#initialize
     */
    function initializeOnChain(uint32 /* chainSlug_ */ ) public pure override {
        return;
    }

    /**
     * @notice Increments counter values on multiple instances across chains
     * @dev Calls the increase function on each counter instance provided
     * @param instances_ Array of counter contract addresses to increment
     */
    function incrementCounters(address[] memory instances_) public async {
        // This ensures the msg.sender is the one paying for the fees
        // for more information see: https://docs.socket.tech/fees
        _setOverrides(msg.sender);
        for (uint256 i = 0; i < instances_.length; i++) {
            ICounter(instances_[i]).increase();
        }
    }

    /**
     * @notice Updates the fee configuration
     * @dev Allows the owner to modify fee settings for multi-chain operations
     * @param fees_ New fee configuration
     */
    function setMaxFees(uint256 fees_) public {
        maxFees = fees_;
    }
}
