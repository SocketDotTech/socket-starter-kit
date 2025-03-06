// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "solady/auth/Ownable.sol";
import "socket-protocol/contracts/base/PlugBase.sol";

/**
 * @title Counter
 * @dev A simple counter contract that can be deployed to multiple chains via SOCKET Protocol.
 * This contract inherits from Ownable for access control and PlugBase to enable SOCKET Protocol integration.
 * The counter can only be incremented through the SOCKET Protocol via AppGateway.
 */
contract Counter is Ownable, PlugBase {
    /**
     * @notice The current counter value
     * @dev This value can only be incremented by authorized SOCKET Protocol calls via AppGateway
     */
    uint256 public counter;

    /**
     * @notice Increases the counter by 1
     * @dev This function can only be called through the SOCKET Protocol via AppGateway
     * The onlySocket modifier ensures that only the SOCKET Forwarder contract can call this function
     */
    function increase() external onlySocket {
        counter++;
    }
}
