// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC6372} from "../interfaces/IERC6372.sol";
import {ERC6372Implementation} from "../base/ERC6372.sol";
/**
 * @title Example Voting Contract using ERC6372
 * @dev Shows how to use ERC6372 in a voting contract
 */
contract VotingWithERC6372 is ERC6372Implementation {
    struct Proposal {
        uint48 startTime;
        uint48 endTime;
        uint256 forVotes;
        uint256 againstVotes;
        bool executed;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    event ProposalCreated(uint256 proposalId, uint48 startTime, uint48 endTime);
    event VoteCast(uint256 proposalId, address voter, bool support);
    event ProposalExecuted(uint256 proposalId);

    /**
     * @dev Create a new proposal
     * @param proposalId Unique identifier for the proposal
     * @param duration Duration of the voting period in seconds/blocks
     */
    function createProposal(uint256 proposalId, uint48 duration) external {
        uint48 startTime = clock();
        uint48 endTime = startTime + duration;

        proposals[proposalId] = Proposal({
            startTime: startTime,
            endTime: endTime,
            forVotes: 0,
            againstVotes: 0,
            executed: false
        });

        emit ProposalCreated(proposalId, startTime, endTime);
    }

    /**
     * @dev Cast a vote on a proposal
     * @param proposalId ID of the proposal
     * @param support True for yes, false for no
     */
    function castVote(uint256 proposalId, bool support) external {
        Proposal storage proposal = proposals[proposalId];
        
        require(clock() >= proposal.startTime, "Voting not started");
        require(clock() <= proposal.endTime, "Voting ended");
        require(!hasVoted[proposalId][msg.sender], "Already voted");
        require(!proposal.executed, "Proposal already executed");

        if (support) {
            proposal.forVotes += 1;
        } else {
            proposal.againstVotes += 1;
        }

        hasVoted[proposalId][msg.sender] = true;
        emit VoteCast(proposalId, msg.sender, support);
    }

    /**
     * @dev Check if a proposal is active
     * @param proposalId ID of the proposal
     */
    function isProposalActive(uint256 proposalId) public view returns (bool) {
        Proposal storage proposal = proposals[proposalId];
        uint48 currentTime = clock();
        return currentTime >= proposal.startTime && currentTime <= proposal.endTime;
    }

    /**
     * @dev Execute a proposal if it has passed
     * @param proposalId ID of the proposal
     */
    function executeProposal(uint256 proposalId) external {
        Proposal storage proposal = proposals[proposalId];
        
        require(clock() > proposal.endTime, "Voting still active");
        require(!proposal.executed, "Already executed");
        require(proposal.forVotes > proposal.againstVotes, "Proposal failed");

        proposal.executed = true;
        emit ProposalExecuted(proposalId);
    }
} 