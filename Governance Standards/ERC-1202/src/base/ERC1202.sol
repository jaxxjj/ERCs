// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IERC1202Info.sol";
import "../interfaces/IERC1202Core.sol";
import "../interfaces/IERC1202MultiVote.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract ERC1202Implementation is IERC1202Info, IERC1202Core, IERC1202MultiVote, AccessControl, ReentrancyGuard {
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");
    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");

    struct Proposal {
        uint256 startTime;
        uint256 endTime;
        bool executed;
        mapping(uint8 => uint256) voteCount;
        mapping(address => bool) hasVoted;
        mapping(address => VoteInfo) votes;
    }

    struct VoteInfo {
        uint8 support;
        uint256 weight;
        string reason;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(address => mapping(uint256 => uint256)) public votingWeights;
    
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    // IERC1202Info Implementation
    function votingPeriodFor(uint256 proposalId) external view returns (uint256 startTime, uint256 endTime) {
        Proposal storage proposal = proposals[proposalId];
        return (proposal.startTime, proposal.endTime);
    }

    function eligibleVotingWeight(uint256 proposalId, address voter) external view returns (uint256) {
        return votingWeights[voter][proposalId];
    }

    // IERC1202Core Implementation
    function castVote(
        uint256 proposalId,
        uint8 support,
        uint256 weight,
        string calldata reasonUri,
        bytes calldata extraParams
    ) external payable nonReentrant returns (bool) {
        return _castVote(msg.sender, proposalId, support, weight, reasonUri, extraParams);
    }

    function castVoteFrom(
        address from,
        uint256 proposalId,
        uint8 support,
        uint256 weight,
        string calldata reasonUri,
        bytes calldata extraParams
    ) external payable nonReentrant returns (bool) {
        require(hasRole(EXECUTOR_ROLE, msg.sender), "Not authorized to vote on behalf");
        return _castVote(from, proposalId, support, weight, reasonUri, extraParams);
    }

    function execute(
        uint256 proposalId,
        bytes calldata extraParams
    ) external payable nonReentrant {
        require(hasRole(EXECUTOR_ROLE, msg.sender), "Not authorized to execute");
        require(!proposals[proposalId].executed, "Already executed");
        require(block.timestamp > proposals[proposalId].endTime, "Voting period not ended");

        proposals[proposalId].executed = true;
        
        // Execute proposal logic using extraParams
        (bool success, ) = address(this).call{value: msg.value}(extraParams);
        require(success, "Execution failed");
    }

    // IERC1202MultiVote Implementation
    function castMultiVote(
        uint256 proposalId,
        uint8[] calldata support,
        uint256[] calldata weights,
        string calldata reasonUri,
        bytes calldata extraParams
    ) external payable nonReentrant {
        require(support.length == weights.length, "Arrays length mismatch");
        require(!proposals[proposalId].hasVoted[msg.sender], "Already voted");
        require(block.timestamp >= proposals[proposalId].startTime, "Voting not started");
        require(block.timestamp <= proposals[proposalId].endTime, "Voting ended");

        uint256 totalWeight = 0;
        for(uint256 i = 0; i < weights.length; i++) {
            totalWeight += weights[i];
            proposals[proposalId].voteCount[support[i]] += weights[i];
        }

        require(totalWeight <= votingWeights[msg.sender][proposalId], "Exceeds voting weight");

        proposals[proposalId].hasVoted[msg.sender] = true;

        emit MultiVoteCast(
            msg.sender,
            proposalId,
            support,
            weights,
            reasonUri,
            extraParams
        );
    }

    // Internal functions
    function _castVote(
        address voter,
        uint256 proposalId,
        uint8 support,
        uint256 weight,
        string calldata reasonUri,
        bytes calldata extraParams
    ) internal returns (bool) {
        require(!proposals[proposalId].hasVoted[voter], "Already voted");
        require(block.timestamp >= proposals[proposalId].startTime, "Voting not started");
        require(block.timestamp <= proposals[proposalId].endTime, "Voting ended");
        require(weight <= votingWeights[voter][proposalId], "Exceeds voting weight");

        proposals[proposalId].hasVoted[voter] = true;
        proposals[proposalId].votes[voter] = VoteInfo({
            support: support,
            weight: weight,
            reason: reasonUri
        });
        proposals[proposalId].voteCount[support] += weight;

        emit VoteCast(
            voter,
            proposalId,
            support,
            weight,
            reasonUri,
            extraParams
        );

        return true;
    }

    // Admin functions
    function createProposal(
        uint256 proposalId,
        uint256 startTime,
        uint256 endTime
    ) external onlyRole(PROPOSER_ROLE) {
        require(startTime >= block.timestamp, "Start time must be future");
        require(endTime > startTime, "End time must be after start");
        
        proposals[proposalId].startTime = startTime;
        proposals[proposalId].endTime = endTime;
    }

    function setVotingWeight(
        address voter,
        uint256 proposalId,
        uint256 weight
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        votingWeights[voter][proposalId] = weight;
    }
}