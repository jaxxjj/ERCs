// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {ERC1967Storage} from "./ERC1967Storage.sol";
import {IUpgradeable} from "../interfaces/IUpgradeable.sol";
/**
 * @title ERC1967Proxy
 * @dev Basic implementation of an upgradeable proxy following ERC1967
 */
contract ERC1967Proxy is ERC1967Storage, IUpgradeable {
    /**
     * @dev Initializes the upgradeable proxy with an initial implementation
     */
    constructor(address _logic, bytes memory _data) payable {
        _setImplementation(_logic);
        if(_data.length > 0) {
            (bool success,) = _logic.delegatecall(_data);
            require(success, "Initialization failed");
        }
    }

    /**
     * @dev Delegates all calls to the current implementation
     */
    fallback() external payable virtual {
        _delegate(_getImplementation());
    }

    receive() external payable virtual {
        _delegate(_getImplementation());
    }

    /**
     * @dev Sets the implementation address
     */
    function _setImplementation(address newImplementation) private {
        require(newImplementation.code.length > 0, "Implementation must be a contract");
        assembly {
            sstore(_IMPLEMENTATION_SLOT, newImplementation)
        }
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Gets the current implementation address
     */
    function _getImplementation() internal view returns (address implementation) {
        assembly {
            implementation := sload(_IMPLEMENTATION_SLOT)
        }
    }

    /**
     * @dev Delegates execution to the implementation contract
     */
    function _delegate(address implementation) internal virtual {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    event Upgraded(address indexed implementation);

    function upgradeTo(address newImplementation) external override {
        require(msg.sender == _getAdmin(), "Not authorized");
        _setImplementation(newImplementation);
    }

    function upgradeToAndCall(
        address newImplementation, 
        bytes memory data
    ) external payable override {
        require(msg.sender == _getAdmin(), "Not authorized");
        _setImplementation(newImplementation);
        if(data.length > 0) {
            (bool success,) = newImplementation.delegatecall(data);
            require(success, "Call failed");
        }
    }

    function _getAdmin() internal view returns (address admin) {
        assembly {
            admin := sload(_ADMIN_SLOT)
        }
    }
}