// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/examples/VotingWithERC6372.sol";

contract ERC6372Test is Test {
    VotingWithERC6372 public voting;
    
    function setUp() public {
        voting = new VotingWithERC6372();
    }

    function testVotingFlow() public {
        // Create proposal
        uint256 proposalId = 1;
        uint48 duration = 100; // 100 seconds/blocks
        voting.createProposal(proposalId, duration);

        // Check proposal is active
        assertTrue(voting.isProposalActive(proposalId));

        // Cast votes
        address voter1 = address(0x1);
        address voter2 = address(0x2);
        address voter3 = address(0x3);

        vm.prank(voter1);
        voting.castVote(proposalId, true);

        vm.prank(voter2);
        voting.castVote(proposalId, true);

        vm.prank(voter3);
        voting.castVote(proposalId, false);

        // Advance time
        skip(duration + 1);

        // Execute proposal
        voting.executeProposal(proposalId);

        // Verify proposal was executed
        (,,,, bool executed) = voting.proposals(proposalId);
        assertTrue(executed);
    }

    function testClockMode() public {
        assertEq(voting.CLOCK_MODE(), "mode=timestamp");
        assertTrue(voting.clock() > 0);
    }
}