// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Proxy.sol";
import {ERC1967Utils} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";

/**
 * @dev ERC1967 Proxy implementation with upgrade and admin functionality
 */
contract ERC1967Proxy is Proxy {
    /**
     * @dev Initializes the upgradeable proxy with an initial implementation specified by `_implementation`.
     * 
     * If `_data` is nonempty, it's used as data in a delegate call to `_implementation`. This will typically be
     * an encoded function call, and allows initializing the storage of the proxy like a Solidity constructor.
     */
    constructor(address _implementation, bytes memory _data) payable {
        // Set deployer as admin first
        ERC1967Utils.changeAdmin(msg.sender);
        
        // Then set implementation
        ERC1967Utils.upgradeToAndCall(_implementation, _data);
    }

    /**
     * @dev Returns the current implementation address.
     */
    function _implementation() internal view virtual override returns (address) {
        return ERC1967Utils.getImplementation();
    }

    /**
     * @dev Modifier that checks if caller is the admin
     */
    modifier onlyAdmin() {
        require(msg.sender == ERC1967Utils.getAdmin(), "Not authorized");
        _;
    }

    /**
     * @dev Admin function to upgrade the implementation.
     */
    function upgradeTo(address newImplementation) external onlyAdmin {
        ERC1967Utils.upgradeToAndCall(newImplementation, "");
    }

    /**
     * @dev Admin function to upgrade the implementation and call a function.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable onlyAdmin {
        ERC1967Utils.upgradeToAndCall(newImplementation, data);
    }

    /**
     * @dev Admin function to change the admin.
     */
    function changeAdmin(address newAdmin) external onlyAdmin {
        ERC1967Utils.changeAdmin(newAdmin);
    }

    /**
     * @dev Returns the current admin.
     */
    function admin() external view returns (address) {
        return ERC1967Utils.getAdmin();
    }

    /**
     * @dev Returns the current implementation.
     */
    function getImplementation() external view returns (address) {
        return ERC1967Utils.getImplementation();
    }

    /**
     * @dev Fallback function that delegates calls to the implementation. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable virtual override {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the implementation. Will run if call data
     * is empty.
     */
    receive() external payable virtual {
        _fallback();
    }
}
