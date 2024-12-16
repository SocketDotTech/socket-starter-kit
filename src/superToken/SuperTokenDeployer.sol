// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "socket-protocol/contracts/base/AppDeployerBase.sol";
import "solady/auth/Ownable.sol";
import "./SuperToken.sol";

/**
 * @title SuperTokenDeployer
 * @notice A contract for deploying SuperToken across multiple chains
 * @dev Extends AppDeployerBase and Ownable to provide cross-chain token deployment functionality
 */
contract SuperTokenDeployer is AppDeployerBase, Ownable {
    /**
     * @notice Unique identifier for the SuperToken contract
     * @dev Used to track and manage the SuperToken contract across different chains
     */
    bytes32 public superToken = _createContractId("superToken");

    /**
     * @notice Constructor to initialize the SuperTokenDeployer
     * @param addressResolver_ Address of the address resolver contract
     * @param owner_ Address of the contract owner
     * @param name_ Name of the token to be deployed
     * @param symbol_ Symbol of the token to be deployed
     * @param decimals_ Number of decimals for the token
     * @param feesData_ Struct containing fee-related data for deployment
     * @dev Sets up the contract with token creation code and initializes ownership
     */
    constructor(
        address addressResolver_,
        address owner_,
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        FeesData memory feesData_
    ) AppDeployerBase(addressResolver_) Ownable() {
        _initializeOwner(owner_);

        creationCodeWithArgs[superToken] = abi.encodePacked(
            type(SuperToken).creationCode,
            abi.encode(name_, symbol_, decimals_)
        );

        _setFeesData(feesData_);
    }

    /**
     * @notice Deploys the SuperToken contract on a specified chain
     * @param chainSlug The unique identifier of the target blockchain
     * @dev Triggers the deployment of the SuperToken contract
     * @custom:modifier Accessible to contract owner or authorized deployers
     */
    function deployContracts(uint32 chainSlug) external async {
        // TODO: Add logic to process if token is already deployed on a chain
        _deploy(superToken, chainSlug);
    }

    /**
     * @notice Initialization function for post-deployment setup
     * @param chainSlug The unique identifier of the blockchain
     * @dev Overrides the initialize function from AppDeployerBase
     * @notice This function is automatically called after all contracts are deployed
     * @dev Currently implemented as a no-op, can be extended for additional initialization logic
     * @custom:note Automatically triggered via AppDeployerBase.allPayloadsExecuted or AppGateway.queueAndDeploy
     */
    function initialize(uint32 chainSlug) public override async {}
}
