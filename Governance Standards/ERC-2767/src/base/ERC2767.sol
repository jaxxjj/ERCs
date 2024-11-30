// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC2767} from "../interfaces/IERC2767.sol";
import {IERC165} from "../interfaces/IERC165.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/**
 * @title ERC2767 Governance Implementation
 * @notice Implements ERC2767 with off-chain signature-based governance
 */
contract ERC2767Governance is IERC2767 {
    // EIP-191 Prepend byte + Version byte
    bytes public PREFIX;
    
    // Interface IDs
    bytes4 private constant _INTERFACE_ID_ERC2767 = 0xd8b04e0e;
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;
    
    // State variables
    uint256 private _quorumVotes;
    address private _token;
    uint256 public transactionsCount;
    uint256 public totalVotingPower;
    
    // Governance settings
    mapping(address => uint256) public votingPowers;
    mapping(bytes32 => bool) public proposalExecuted;
    
    // Events
    event ProposalExecuted(bytes32 indexed proposalId, address indexed target, bytes data);
    event GovernorUpdated(address indexed governor, uint256 newVotingPower);
    event QuorumUpdated(uint256 oldQuorum, uint256 newQuorum);
    event TokenUpdated(address oldToken, address newToken);
    
    modifier onlySelf() {
        require(msg.sender == address(this), "ERC2767: caller must be self");
        _;
    }

    constructor(
        address[] memory initialGovernors,
        uint256[] memory initialPowers,
        uint256 initialQuorum,
        address governanceToken
    ) {
        require(initialGovernors.length == initialPowers.length, "ERC2767: invalid input lengths");
        
        PREFIX = abi.encodePacked(hex"1900", address(this));
        _quorumVotes = initialQuorum;
        _token = governanceToken;

        uint256 _totalPower;
        for (uint256 i = 0; i < initialGovernors.length; i++) {
            votingPowers[initialGovernors[i]] = initialPowers[i];
            _totalPower += initialPowers[i];
            emit GovernorUpdated(initialGovernors[i], initialPowers[i]);
        }
        totalVotingPower = _totalPower;
    }

    /**
     * @notice Execute a governance proposal with signatures
     * @param target Address to call
     * @param data Call data
     * @param signatures Array of governor signatures
     */
    function executeProposal(
        address target,
        bytes memory data,
        bytes[] memory signatures
    ) external payable {
        bytes32 proposalId = keccak256(abi.encodePacked(
            PREFIX,
            transactionsCount,
            target,
            data
        ));
        
        require(!proposalExecuted[proposalId], "ERC2767: proposal already executed");
        require(verifySignatures(proposalId, signatures), "ERC2767: insufficient signatures");

        proposalExecuted[proposalId] = true;
        transactionsCount++;

        (bool success, ) = target.call{value: msg.value}(data);
        require(success, "ERC2767: proposal execution failed");

        emit ProposalExecuted(proposalId, target, data);
    }

    /**
     * @notice Update governor voting power
     * @param governor Address of governor
     * @param newVotingPower New voting power
     */
    function updateGovernor(address governor, uint256 newVotingPower) external onlySelf {
        uint256 oldPower = votingPowers[governor];
        votingPowers[governor] = newVotingPower;
        totalVotingPower = totalVotingPower - oldPower + newVotingPower;
        
        emit GovernorUpdated(governor, newVotingPower);
    }

    /**
     * @notice Verify signatures meet quorum
     * @param proposalId Proposal hash
     * @param signatures Array of signatures
     */
    function verifySignatures(bytes32 proposalId, bytes[] memory signatures) 
        internal view returns (bool) 
    {
        uint256 totalWeight;
        address lastSigner = address(0);

        for (uint256 i = 0; i < signatures.length; i++) {
            address signer = ECDSA.recover(proposalId, signatures[i]);
            require(uint160(signer) > uint160(lastSigner), "ERC2767: unsorted signatures");
            
            uint256 weight = votingPowers[signer];
            require(weight > 0, "ERC2767: not a governor");
            
            totalWeight += weight;
            lastSigner = signer;
        }

        return totalWeight >= _quorumVotes;
    }

    /**
     * @inheritdoc IERC2767
     */
    function quorumVotes() external view returns (uint256) {
        return _quorumVotes;
    }

    /**
     * @inheritdoc IERC2767
     */
    function token() external view returns (address) {
        return _token;
    }

    /**
     * @inheritdoc IERC165
     */
    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return interfaceId == _INTERFACE_ID_ERC2767 || interfaceId == _INTERFACE_ID_ERC165;
    }
}