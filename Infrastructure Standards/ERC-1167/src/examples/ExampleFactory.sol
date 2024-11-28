// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../base/CloneFactory.sol";
import "./ExampleImplementation.sol";
import "./ExampleImplementationV2.sol";
contract ExampleFactory is CloneFactory {
    // Implementation contract address
    address public implementation;
    
    // Factory owner
    address public owner;
    
    // Keep track of all clones
    address[] public clones;
    
    // Mapping to check if an address is a clone
    mapping(address => bool) public isClone;

    // Mapping to track clone versions
    mapping(address => uint256) public cloneVersions;

    event CloneCreated(address indexed clone, address indexed cloneOwner);
    event ImplementationUpgraded(address indexed oldImpl, address indexed newImpl);
    event CloneUpgraded(address indexed clone, uint256 oldVersion, uint256 newVersion);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _implementation) {
        implementation = _implementation;
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Upgrades the implementation contract
     * @param _newImplementation Address of the new implementation
     */
    function upgradeImplementation(address _newImplementation) external onlyOwner {
        require(_newImplementation != address(0), "Invalid implementation");
        
        address oldImplementation = implementation;
        implementation = _newImplementation;
        
        emit ImplementationUpgraded(oldImplementation, _newImplementation);
    }

    /**
     * @dev Upgrades a specific clone to the new implementation
     * @param clone Address of the clone to upgrade
     */
    function upgradeClone(address clone) external {
        require(isClone[clone], "Not a clone");
        require(msg.sender == ExampleImplementation(clone).owner(), "Not clone owner");
        
        uint256 oldVersion = ExampleImplementation(clone).version();
        uint256 newVersion = ExampleImplementation(implementation).version();
        require(newVersion > oldVersion, "Invalid version");

        // Store current state
        address currentOwner = ExampleImplementation(clone).owner();
        uint256 currentValue = ExampleImplementation(clone).value();

        // Create new clone
        address newClone = createClone(implementation);
        
        // Initialize new clone with previous state
        ExampleImplementation(newClone).initialize(currentOwner);
        ExampleImplementation(newClone).setValue(currentValue);

        // If V2, copy additional state
        if (newVersion == 2) {
            try ExampleImplementationV2(newClone).setDescription(
                ExampleImplementationV2(clone).description()
            ) {} catch {}
        }

        // Update mappings
        isClone[clone] = false;
        isClone[newClone] = true;
        cloneVersions[newClone] = newVersion;

        // Replace clone in array
        for (uint i = 0; i < clones.length; i++) {
            if (clones[i] == clone) {
                clones[i] = newClone;
                break;
            }
        }

        emit CloneUpgraded(clone, oldVersion, newVersion);
    }

    /**
     * @dev Creates a new clone with initialization
     */
    function createNewClone(address _cloneOwner) external returns (address) {
        address clone = createClone(implementation);
        
        ExampleImplementation(clone).initialize(_cloneOwner);
        
        clones.push(clone);
        isClone[clone] = true;
        cloneVersions[clone] = ExampleImplementation(implementation).version();
        
        emit CloneCreated(clone, _cloneOwner);
        
        return clone;
    }

    /**
     * @dev Creates a deterministic clone with initialization
     */
    function createDeterministicClone(
        address _cloneOwner,
        bytes32 salt
    ) external returns (address) {
        address clone = createCloneDeterministic(implementation, salt);
        
        ExampleImplementation(clone).initialize(_cloneOwner);
        
        clones.push(clone);
        isClone[clone] = true;
        cloneVersions[clone] = ExampleImplementation(implementation).version();
        
        emit CloneCreated(clone, _cloneOwner);
        
        return clone;
    }

    /**
     * @dev Returns all clones
     */
    function getAllClones() external view returns (address[] memory) {
        return clones;
    }

    /**
     * @dev Predicts clone address
     */
    function predictCloneAddress(bytes32 salt) external view returns (address) {
        return predictDeterministicAddress(implementation, salt, address(this));
    }

    /**
     * @dev Returns the version of a clone
     */
    function getCloneVersion(address clone) external view returns (uint256) {
        require(isClone[clone], "Not a clone");
        return cloneVersions[clone];
    }
}