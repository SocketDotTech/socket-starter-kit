// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface ISuperTokenDeployer {
    function superToken() external view returns (bytes32);

    function vault() external view returns (bytes32);

    function baseChainSlug() external view returns (uint32);

    function baseTokenAddress() external view returns (address);

    function forwarderAddresses(bytes32, uint32) external view returns (address);
}
