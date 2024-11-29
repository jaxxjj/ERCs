// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {ERC1967Proxy} from "../base/ERC1967Proxy.sol";

/**
 * @title ProxyAdmin
 * @dev Admin contract for proxy management
 */
contract ProxyAdmin {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function upgrade(
        ERC1967Proxy proxy,
        address implementation
    ) external onlyOwner {
        proxy.upgradeTo(implementation);
    }

    function upgradeAndCall(
        ERC1967Proxy proxy,
        address implementation,
        bytes memory data
    ) external payable onlyOwner {
        proxy.upgradeToAndCall{value: msg.value}(implementation, data);
    }
}