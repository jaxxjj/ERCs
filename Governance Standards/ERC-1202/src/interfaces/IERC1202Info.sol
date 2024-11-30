// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC1202Info {
    function votingPeriodFor(uint256 proposalId) external view returns (uint256 startPointOfTime, uint256 endPointOfTime);
    function eligibleVotingWeight(uint256 proposalId, address voter) external view returns (uint256);
}