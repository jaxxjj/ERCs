// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface IERC2612 {
    /**
     * @dev Returns the domain separator used for signing permits
     */
    function DOMAIN_SEPARATOR() external view returns (bytes32);

    /**
     * @dev Returns the nonce used for permit signatures for a given address
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Sets approval using a signed permit
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}
