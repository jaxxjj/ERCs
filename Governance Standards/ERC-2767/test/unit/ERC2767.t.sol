// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/base/ERC2767.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MockToken {
    function transfer(address to, uint256 amount) external returns (bool) {
        return true;
    }
}

contract ERC2767Test is Test {
    using ECDSA for bytes32;

    ERC2767Governance public governance;
    MockToken public token;
    
    // Test accounts
    address public governor1;
    address public governor2;
    address public governor3;
    uint256 public governor1Key;
    uint256 public governor2Key;
    uint256 public governor3Key;
    
    // Test parameters
    uint256 constant QUORUM = 70; // 70% quorum
    uint256 constant INITIAL_POWER = 40;
    
    event ProposalExecuted(bytes32 indexed proposalId, address indexed target, bytes data);
    event GovernorUpdated(address indexed governor, uint256 newVotingPower);
    
    function setUp() public {
        // Create mock token
        token = new MockToken();
        
        // Generate test accounts
        (governor1, governor1Key) = makeAddrAndKey("governor1");
        (governor2, governor2Key) = makeAddrAndKey("governor2");
        (governor3, governor3Key) = makeAddrAndKey("governor3");
        
        // Setup initial governors
        address[] memory governors = new address[](3);
        governors[0] = governor1;
        governors[1] = governor2;
        governors[2] = governor3;
        
        uint256[] memory powers = new uint256[](3);
        powers[0] = INITIAL_POWER;
        powers[1] = INITIAL_POWER;
        powers[2] = INITIAL_POWER;
        
        // Deploy governance contract
        governance = new ERC2767Governance(
            governors,
            powers,
            QUORUM,
            address(token)
        );
    }

    function testInitialState() public {
        assertEq(governance.quorumVotes(), QUORUM);
        assertEq(governance.token(), address(token));
        assertEq(governance.totalVotingPower(), INITIAL_POWER * 3);
        
        assertEq(governance.votingPowers(governor1), INITIAL_POWER);
        assertEq(governance.votingPowers(governor2), INITIAL_POWER);
        assertEq(governance.votingPowers(governor3), INITIAL_POWER);
    }

    function testProposalExecution() public {
        // Create proposal data
        address target = address(token);
        bytes memory data = abi.encodeWithSignature(
            "transfer(address,uint256)", 
            address(this), 
            100
        );
        
        // Create proposal hash
        bytes32 proposalId = keccak256(abi.encodePacked(
            governance.PREFIX(),
            governance.transactionsCount(),
            target,
            data
        ));
        
        // Sign with governors
        bytes[] memory signatures = new bytes[](2);
        signatures[0] = _sign(proposalId, governor1Key);
        signatures[1] = _sign(proposalId, governor2Key);
        
        // Expect event
        vm.expectEmit(true, true, false, true);
        emit ProposalExecuted(proposalId, target, data);
        
        // Execute proposal
        governance.executeProposal(target, data, signatures);
        
        assertEq(governance.transactionsCount(), 1);
        assertTrue(governance.proposalExecuted(proposalId));
    }

    function testFailInsufficientSignatures() public {
        address target = address(token);
        bytes memory data = abi.encodeWithSignature(
            "transfer(address,uint256)", 
            address(this), 
            100
        );
        
        bytes32 proposalId = keccak256(abi.encodePacked(
            governance.PREFIX(),
            governance.transactionsCount(),
            target,
            data
        ));
        
        // Only one signature (insufficient for quorum)
        bytes[] memory signatures = new bytes[](1);
        signatures[0] = _sign(proposalId, governor1Key);
        
        governance.executeProposal(target, data, signatures);
    }

    function testFailDuplicateExecution() public {
        address target = address(token);
        bytes memory data = abi.encodeWithSignature(
            "transfer(address,uint256)", 
            address(this), 
            100
        );
        
        bytes32 proposalId = keccak256(abi.encodePacked(
            governance.PREFIX(),
            governance.transactionsCount(),
            target,
            data
        ));
        
        bytes[] memory signatures = new bytes[](2);
        signatures[0] = _sign(proposalId, governor1Key);
        signatures[1] = _sign(proposalId, governor2Key);
        
        // First execution
        governance.executeProposal(target, data, signatures);
        
        // Should fail on second execution
        governance.executeProposal(target, data, signatures);
    }

    function testFailUnsortedSignatures() public {
        address target = address(token);
        bytes memory data = abi.encodeWithSignature(
            "transfer(address,uint256)", 
            address(this), 
            100
        );
        
        bytes32 proposalId = keccak256(abi.encodePacked(
            governance.PREFIX(),
            governance.transactionsCount(),
            target,
            data
        ));
        
        // Signatures in wrong order
        bytes[] memory signatures = new bytes[](2);
        signatures[0] = _sign(proposalId, governor2Key);
        signatures[1] = _sign(proposalId, governor1Key);
        
        governance.executeProposal(target, data, signatures);
    }

    function testSupportsInterface() public {
        assertTrue(governance.supportsInterface(0xd8b04e0e)); // ERC2767
        assertTrue(governance.supportsInterface(0x01ffc9a7)); // ERC165
        assertFalse(governance.supportsInterface(0xffffffff));
    }

    // Helper function to sign messages
    function _sign(bytes32 hash, uint256 privateKey) internal pure returns (bytes memory) {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, hash);
        return abi.encodePacked(r, s, v);
    }
}