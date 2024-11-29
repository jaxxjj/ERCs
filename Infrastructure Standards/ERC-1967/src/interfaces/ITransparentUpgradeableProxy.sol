// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @dev Interface for the transparent proxy pattern.
 * These functions are only callable by the admin, and are not
 * delegated to the implementation.
 */
interface ITransparentUpgradeableProxy {
    /**
     * @dev Upgrades the proxy to a new implementation.
     * @param newImplementation Address of the new implementation.
     */
    function upgradeTo(address newImplementation) external;

    /**
     * @dev Upgrades the proxy to a new implementation and calls a function on the new implementation.
     * @param newImplementation Address of the new implementation.
     * @param data The calldata to delegatecall the new implementation with.
     */
    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable;

    /**
     * @dev Changes the admin of the proxy.
     * @param newAdmin Address of the new admin.
     */
    function changeAdmin(address newAdmin) external;
}