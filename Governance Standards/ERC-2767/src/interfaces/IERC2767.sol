// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC165} from "./IERC165.sol";

/// @title ERC-2767 Governance
/// @dev ERC-165 InterfaceID: 0xd8b04e0e
interface IERC2767 is IERC165 {
    /// @notice Gets number votes required for achieving consensus
    /// @dev Should cost less than 30000 gas
    /// @return Required number of votes for achieving consensus
    function quorumVotes() external view returns (uint256);

    /// @notice The address of the Governance ERC20 token
    function token() external view returns (address);
}