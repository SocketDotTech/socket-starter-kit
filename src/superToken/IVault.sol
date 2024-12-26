// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

interface IVault {
    // Custom Errors
    error ZeroDepositAmount();
    error ZeroWithdrawAmount();
    error InsufficientBalance();
    error NotSOCKET();

    // Events
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    // State Variables
    function balances(address user) external view returns (uint256);
    function _SOCKET() external view returns (address);
    function token() external view returns (address);

    // Functions

    /**
     * @notice Deposit ERC20 tokens into the vault
     * @param amount Amount of tokens to deposit
     */
    function deposit(uint256 amount) external;

    /**
     * @notice Withdraw ERC20 tokens from the vault
     * @param amount Amount of tokens to withdraw
     */
    function withdraw(uint256 amount) external;

    /**
     * @notice Get user's balance for the token
     * @param user Address of the user
     * @return User's balance of the specified token
     */
    function getBalance(address user) external view returns (uint256);

    /**
     * @notice Allows the owner to rescue tokens accidentally sent to the contract
     * @param token_ Address of the token to rescue
     * @param amount Amount of tokens to rescue
     * @param recipient Address to send rescued tokens to
     */
    function rescueTokens(address token_, uint256 amount, address recipient) external;
}
