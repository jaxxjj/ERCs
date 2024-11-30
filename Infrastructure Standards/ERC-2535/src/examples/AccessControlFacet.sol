// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../lib/LibAppStorage.sol";

/**
 * @title AccessControlFacet implementing AppStorage
 */
contract AccessControlFacet {
    using LibAppStorage for LibAppStorage.AppStorage;

    function _storage() internal pure returns (LibAppStorage.AppStorage storage) {
        return LibAppStorage.diamondStorage();
    }

    modifier onlyAdmin() {
        require(_storage().admins[msg.sender], "Not admin");
        _;
    }

    function addAdmin(address _admin) external onlyAdmin {
        _storage().admins[_admin] = true;
    }

    function removeAdmin(address _admin) external onlyAdmin {
        _storage().admins[_admin] = false;
    }

    function grantMethodAccess(bytes4 _method, address _user) external onlyAdmin {
        _storage().methodAccess[_method][_user] = true;
    }

    function revokeMethodAccess(bytes4 _method, address _user) external onlyAdmin {
        _storage().methodAccess[_method][_user] = false;
    }
}