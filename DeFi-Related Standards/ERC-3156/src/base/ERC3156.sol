// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IERC3156.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title ERC3156 Flash Loan Base Implementation
 * @dev Base contract for ERC3156 flash loans
 */
abstract contract ERC3156FlashLender is IERC3156FlashLender, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // Fee in basis points (1 bp = 0.01%)
    uint256 public constant FEE = 9; // 0.09% fee
    bytes32 public constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");

    // Supported tokens mapping
    mapping(address => bool) public supportedTokens;

    /**
     * @dev Constructor to set up supported tokens
     * @param tokens Array of supported token addresses
     */
    constructor(address[] memory tokens) {
        for (uint256 i = 0; i < tokens.length; i++) {
            supportedTokens[tokens[i]] = true;
        }
    }

    /**
     * @dev Returns the maximum amount of tokens available for flash loan
     * @param token The loan currency
     * @return The amount of `token` that can be borrowed
     */
    function maxFlashLoan(address token) public view override returns (uint256) {
        if (!supportedTokens[token]) {
            return 0;
        }
        return IERC20(token).balanceOf(address(this));
    }

    /**
     * @dev Returns the fee for a flash loan
     * @param token The loan currency
     * @param amount The amount of tokens lent
     * @return The amount of `token` to be charged for the loan, on top of the returned principal
     */
    function flashFee(address token, uint256 amount) public view override returns (uint256) {
        require(supportedTokens[token], "ERC3156: Unsupported token");
        return (amount * FEE) / 10000;
    }

    /**
     * @dev Initiates a flash loan
     * @param receiver The receiver of the tokens in the loan, and the receiver of the callback
     * @param token The loan currency
     * @param amount The amount of tokens lent
     * @param data Arbitrary data structure, intended to contain user-defined parameters
     * @return True if the flash loan was successful
     */
    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external override nonReentrant returns (bool) {
        require(supportedTokens[token], "ERC3156: Unsupported token");
        require(amount <= maxFlashLoan(token), "ERC3156: Amount exceeds max loan");

        uint256 fee = flashFee(token, amount);
        require(IERC20(token).transfer(address(receiver), amount), "ERC3156: Transfer failed");

        require(
            receiver.onFlashLoan(msg.sender, token, amount, fee, data) == CALLBACK_SUCCESS,
            "ERC3156: Callback failed"
        );

        require(
            IERC20(token).transferFrom(address(receiver), address(this), amount + fee),
            "ERC3156: Repayment failed"
        );

        return true;
    }

    /**
     * @dev Function to add supported tokens (can be overridden with access control)
     * @param token The token to add support for
     */
    function _addSupportedToken(address token) internal virtual {
        require(token != address(0), "ERC3156: Token cannot be zero address");
        supportedTokens[token] = true;
    }

    /**
     * @dev Function to remove supported tokens (can be overridden with access control)
     * @param token The token to remove support for
     */
    function _removeSupportedToken(address token) internal virtual {
        supportedTokens[token] = false;
    }
}

/**
 * @title ERC3156 Flash Borrower Base Implementation
 * @dev Base contract for ERC3156 flash borrowers
 */
abstract contract ERC3156FlashBorrower is IERC3156FlashBorrower {
    // Ensures callback is only called by the lender
    modifier onlyLender(address lender) {
        require(msg.sender == lender, "ERC3156: Untrusted lender");
        _;
    }

    /**
     * @dev Receive a flash loan and handle it
     * @param initiator The initiator of the loan
     * @param token The loan currency
     * @param amount The amount of tokens lent
     * @param fee The additional amount of tokens to repay
     * @param data Arbitrary data structure, intended to contain user-defined parameters
     * @return The keccak256 hash of "ERC3156FlashBorrower.onFlashLoan"
     */
    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external virtual override onlyLender(msg.sender) returns (bytes32) {
        // Handle the flash loan
        _handleFlashLoan(initiator, token, amount, fee, data);
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    /**
     * @dev Internal function to handle the flash loan
     * Must be implemented by derived contracts
     */
    function _handleFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) internal virtual;
}
