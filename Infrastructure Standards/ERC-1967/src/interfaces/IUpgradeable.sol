// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IUpgradeable {
    function upgradeTo(address newImplementation) external;
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable;
}