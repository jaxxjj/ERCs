// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC1202MultiVote {
    event MultiVoteCast(
        address indexed voter,
        uint256 indexed proposalId,
        uint8[] support,
        uint256[] weight,
        string reason,
        bytes extraParams
    );

    function castMultiVote(
        uint256 proposalId,
        uint8[] calldata support,
        uint256[] calldata weight,
        string calldata reasonUri,
        bytes calldata extraParams
    ) external payable;
}