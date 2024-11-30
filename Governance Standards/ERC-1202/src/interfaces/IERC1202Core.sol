// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC1202Core {
    event VoteCast(
        address indexed voter,
        uint256 indexed proposalId,
        uint8 support,
        uint256 weight,
        string reason,
        bytes extraParams
    );

    function castVote(
        uint256 proposalId,
        uint8 support,
        uint256 weight,
        string calldata reasonUri,
        bytes calldata extraParams
    ) external payable returns (bool);

    function castVoteFrom(
        address from,
        uint256 proposalId,
        uint8 support,
        uint256 weight,
        string calldata reasonUri,
        bytes calldata extraParams
    ) external payable returns (bool);

    function execute(uint256 proposalId, bytes memory extraParams) payable external;
}
