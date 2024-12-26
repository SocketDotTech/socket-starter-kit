// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "solady/utils/SafeTransferLib.sol";
import "solady/tokens/ERC20.sol";
import "solady/auth/Ownable.sol";

contract Vault is Ownable {
    using SafeTransferLib for address;

    // Custom Errors
    error ZeroDepositAmount();
    error ZeroWithdrawAmount();
    error InsufficientBalance();
    error NotSOCKET();

    // Events
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    mapping(address => uint256) public balances;
    address public _SOCKET;
    address public token;

    modifier onlySOCKET() {
        if (msg.sender != _SOCKET) revert NotSOCKET();
        _;
    }

    constructor(address owner_, address token_) Ownable() {
        _initializeOwner(owner_);
        token = token_;
        _SOCKET = msg.sender;
    }

    /**
     * @notice Deposit ERC20 tokens into the vault
     * @param amount Amount of tokens to deposit
     */
    function deposit(uint256 amount) external onlySOCKET {
        if (amount == 0) revert ZeroDepositAmount();

        balances[msg.sender] += amount;

        SafeTransferLib.safeTransferFrom(token, msg.sender, address(this), amount);

        emit Deposited(msg.sender, amount);
    }

    /**
     * @notice Withdraw ERC20 tokens from the vault
     * @param amount Amount of tokens to withdraw
     */
    function withdraw(uint256 amount) external onlySOCKET {
        if (amount == 0) revert ZeroWithdrawAmount();

        if (balances[msg.sender] < amount) revert InsufficientBalance();

        balances[msg.sender] -= amount;

        SafeTransferLib.safeTransfer(token, msg.sender, amount);

        emit Withdrawn(msg.sender, amount);
    }

    /**
     * @notice Get user's balance for the token
     * @param user Address of the user
     * @return User's balance of the specified token
     */
    function getBalance(address user) external view returns (uint256) {
        return balances[user];
    }

    /**
     * @notice Allows the owner to rescue tokens accidentally sent to the contract
     * @param token_ Address of the token to rescue
     * @param amount Amount of tokens to rescue
     * @param recipient Address to send rescued tokens to
     */
    function rescueTokens(address token_, uint256 amount, address recipient) external onlyOwner {
        SafeTransferLib.safeTransfer(token_, recipient, amount);
    }
}
