// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

contract SecureVault is ERC4626 {
    using Math for uint256;

    // Fees in basis points (1 bp = 0.01%)
    uint256 public constant DEPOSIT_FEE = 10;    // 0.1%
    uint256 public constant WITHDRAW_FEE = 20;   // 0.2%
    
    // Initial deposit to prevent share price manipulation
    uint256 private constant INITIAL_DEPOSIT = 1000 * 10**18;

    constructor(
        IERC20 asset_
    ) ERC4626(asset_) ERC20("Secure Vault Token", "svToken") {
        // Make initial deposit from deployer to prevent share price manipulation
        require(
            asset_.transferFrom(msg.sender, address(this), INITIAL_DEPOSIT),
            "Initial deposit failed"
        );
        _mint(msg.sender, INITIAL_DEPOSIT);
    }

    /**
     * @dev Implements 6 decimal offset for additional protection against share price manipulation
     */
    function _decimalsOffset() internal pure override returns (uint8) {
        return 6;
    }

    function _convertToShares(uint256 assets, Math.Rounding rounding)
        internal
        view
        override
        returns (uint256)
    {
        // Apply deposit fee
        uint256 feeAdjustedAssets = assets - ((assets * DEPOSIT_FEE) / 10000);
        return super._convertToShares(feeAdjustedAssets, rounding);
    }

    function _convertToAssets(uint256 shares, Math.Rounding rounding)
        internal
        view
        override
        returns (uint256)
    {
        uint256 assets = super._convertToAssets(shares, rounding);
        // Apply withdrawal fee
        return assets - ((assets * WITHDRAW_FEE) / 10000);
    }

    /**
     * @dev Preview functions should show fee-adjusted amounts
     */
    function previewDeposit(uint256 assets) public view override returns (uint256) {
        return _convertToShares(assets, Math.Rounding.Floor);
    }

    function previewMint(uint256 shares) public view override returns (uint256) {
        uint256 assets = super._convertToAssets(shares, Math.Rounding.Ceil);
        return assets + ((assets * DEPOSIT_FEE) / (10000 - DEPOSIT_FEE));
    }

    function previewWithdraw(uint256 assets) public view override returns (uint256) {
        uint256 grossAssets = assets + ((assets * WITHDRAW_FEE) / (10000 - WITHDRAW_FEE));
        return super._convertToShares(grossAssets, Math.Rounding.Ceil);
    }

    function previewRedeem(uint256 shares) public view override returns (uint256) {
        return _convertToAssets(shares, Math.Rounding.Floor);
    }
}