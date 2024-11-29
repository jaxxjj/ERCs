// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {ERC1967Storage} from "./ERC1967Storage.sol";
/**
 * @title UUPSUpgradeable
 * @dev Implementation contract with upgrade functionality
 */
abstract contract UUPSUpgradeable is ERC1967Storage {
    /**
     * @dev Upgrade the implementation of the proxy
     */
    function upgradeTo(address newImplementation) external virtual {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCall(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy with a call
     */
    function upgradeToAndCall(
        address newImplementation,
        bytes memory data
    ) external payable virtual {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCall(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when msg.sender is not authorized to upgrade
     */
    function _authorizeUpgrade(address) internal virtual;

    /**
     * @dev Perform implementation upgrade with security checks
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        require(newImplementation.code.length > 0, "New implementation must be a contract");
        
        address oldImplementation = _getImplementation();
        
        // Store the new implementation
        assembly {
            sstore(_IMPLEMENTATION_SLOT, newImplementation)
        }
        
        emit Upgraded(newImplementation);

        // Call initialize function if data is provided
        if (data.length > 0 || forceCall) {
            (bool success, ) = newImplementation.delegatecall(data);
            require(success, "Call to new implementation failed");
        }
    }

    /**
     * @dev Get current implementation address
     */
    function _getImplementation() internal view returns (address implementation) {
        assembly {
            implementation := sload(_IMPLEMENTATION_SLOT)
        }
    }

    event Upgraded(address indexed implementation);
}