# Diamond Standard (ERC-2535) Implementation

This repository contains a reference implementation of the Diamond Standard (ERC-2535), demonstrating a modular and upgradeable smart contract architecture.

## Current Deployment

### Architecture Overview
| Component | Purpose | Description |
|-----------|---------|-------------|
| Diamond.sol | Entry Point | All external calls are routed through this contract |
| LibDiamond.sol | Core Logic | Manages function routing and diamond cuts |
| LibAppStorage.sol | State Management | Handles shared application state across facets |
| Facets | Business Logic | Implements specific functionality domains |

### Deployed Contracts (Sepolia Network)

#### Core Contracts
| Contract | Address | Purpose |
|----------|---------|---------|
| Diamond | `0xEEceD3e2aE266B46dEcc1627D31855CdCDB02524` | Main proxy contract |
| DiamondInit | `0x8Bfc043B8580eB1a24931873b2A7215077454544` | Initialization logic |

#### System Facets
| Facet | Address | Purpose |
|-------|---------|---------|
| DiamondCutFacet | `0xEB26e8d1D31e5531bB5f977aE0f26743E7B453F1` | Handles contract upgrades |
| DiamondLoupeFacet | `0xcE6703F261ed4888EFEcF772f519C0971044F15F` | Provides contract introspection |

#### Business Facets
| Facet | Address | Purpose |
|-------|---------|---------|
| StorageFacet | `0x0Dc55753CF0079a74140416CD9A4652Bc886b07D` | Manages contract storage |
| AccessControlFacet | `0x28Bc153F6F7370b20731B1397C52C4121E36Fc6F` | Handles access control |

### Interaction Flow
1. Users interact with the Diamond contract (`0xEEceD3e2...`)
2. Diamond delegates calls to appropriate facets
3. Facets execute business logic
4. State changes are stored in LibAppStorage
5. Events are emitted through the Diamond

### Verification
All contracts are verified on [Sepolia Etherscan](https://sepolia.etherscan.io/address/0xEEceD3e2aE266B46dEcc1627D31855CdCDB02524)

### Quick Links
- [Diamond Contract](https://sepolia.etherscan.io/address/0xEEceD3e2aE266B46dEcc1627D31855CdCDB02524)
- [DiamondCut Facet](https://sepolia.etherscan.io/address/0xEB26e8d1D31e5531bB5f977aE0f26743E7B453F1)
- [DiamondLoupe Facet](https://sepolia.etherscan.io/address/0xcE6703F261ed4888EFEcF772f519C0971044F15F)
- [Storage Facet](https://sepolia.etherscan.io/address/0x0Dc55753CF0079a74140416CD9A4652Bc886b07D)
- [Access Control Facet](https://sepolia.etherscan.io/address/0x28Bc153F6F7370b20731B1397C52C4121E36Fc6F)

## What is the Diamond Standard?

The Diamond Standard (ERC-2535) is a smart contract architecture that enables:
- Modular contract development
- Unlimited contract size
- Runtime upgradeability
- Contract reusability
- State management across upgrades

### Key Components

1. **Diamond Contract (`src/base/Diamond.sol`)**
   - Main entry point for all function calls
   - Implements delegatecall routing
   - Manages ownership and access control

2. **LibDiamond (`src/lib/LibDiamond.sol`)**
   - Core diamond functionality
   - Manages function selectors and facet addresses
   - Handles diamond cuts (upgrades)

3. **LibAppStorage (`src/lib/LibAppStorage.sol`)**
   - Centralized storage pattern
   - Shared state across all facets
   - Structured data organization

4. **Facets**
   - `DiamondCutFacet`: Handles upgrades
   - `DiamondLoupeFacet`: Contract introspection
   - `StorageFacet`: Example storage operations
   - `AccessControlFacet`: Permission management

### Architecture Overview

```
                    ┌─────────────────┐
                    │    Diamond.sol  │
                    │  (Entry Point)  │
                    └────────┬────────┘
                             │
              ┌──────────────┴──────────────┐
              │         delegatecall        │
              ▼                             ▼
    ┌─────────────────┐           ┌─────────────────┐
    │   LibDiamond    │           │  LibAppStorage  │
    │ (Core Logic)    │           │  (State Mgmt)   │
    └─────────────────┘           └─────────────────┘
              │
    ┌─────────┴─────────┐
    │      Facets       │
    ▼                   ▼
┌─────────┐       ┌─────────┐
│ Facet A │  ...  │ Facet N │
└─────────┘       └─────────┘
```

## Implementation Details

### 1. Diamond Contract

```solidity
contract Diamond {
    constructor(address _owner) {
        LibDiamond.setContractOwner(_owner);
    }

    // Fallback function handles all calls
    fallback() external payable {
        LibDiamond.DiamondStorage storage ds;
        bytes32 position = LibDiamond.DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
        address facet = ds.selectorToFacetAndPosition[msg.sig].facetAddress;
        require(facet != address(0), "Diamond: Function does not exist");
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}
```

### 2. Storage Management

```solidity
library LibAppStorage {
    struct AppStorage {
        uint256 value;
        string message;
        mapping(address => bool) admins;
        mapping(bytes4 => mapping(address => bool)) methodAccess;
    }

    function diamondStorage() internal pure returns (AppStorage storage ds) {
        bytes32 position = keccak256("diamond.app.storage");
        assembly {
            ds.slot := position
        }
    }
}
```

### 3. Facet Implementation

Example facet showing storage interaction:

```solidity
contract StorageFacet {
    using LibAppStorage for LibAppStorage.AppStorage;

    function setValue(uint256 _value) external {
        LibAppStorage.diamondStorage().value = _value;
    }

    function getValue() external view returns (uint256) {
        return LibAppStorage.diamondStorage().value;
    }
}
```

## Usage Examples

### 1. Deploying a Diamond

```bash
forge script script/Deploy.s.sol --rpc-url sepolia --broadcast --verify
```

### 2. Adding a New Facet

```solidity
IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);
bytes4[] memory selectors = new bytes4[](1);
selectors[0] = bytes4(keccak256("newFunction()"));
cut[0] = IDiamondCut.FacetCut({
    facetAddress: address(newFacet),
    action: IDiamondCut.FacetCutAction.Add,
    functionSelectors: selectors
});
diamondCut.diamondCut(cut, address(0), new bytes(0));
```

### 3. Interacting with Facets

```bash
forge script script/Interact.s.sol --rpc-url sepolia --broadcast
```

## Testing

```bash
forge test
```

## Security Considerations

1. **Storage Collisions**
   - Use structured storage pattern
   - Maintain clear storage layouts
   - Document storage slots

2. **Access Control**
   - Implement proper ownership checks
   - Use modifiers for function access
   - Maintain admin lists

3. **Upgrade Safety**
   - Test all upgrades thoroughly
   - Verify selector conflicts
   - Maintain state consistency

## Best Practices

1. **Facet Organization**
   - Group related functions
   - Keep facets focused
   - Document dependencies

2. **Storage Management**
   - Use LibAppStorage pattern
   - Avoid storage conflicts
   - Document storage layout

3. **Upgrade Process**
   - Test upgrades thoroughly
   - Maintain version control
   - Document changes

## Extending the Diamond

### Adding New Storage Variables

#### Process
1. **Update LibAppStorage.sol**
```solidity
library LibAppStorage {
    struct AppStorage {
        uint256 value;
        string message;
        mapping(address => bool) admins;
        
        // New storage variables
        uint256 newVariable;          // ✅ Append only
        mapping(address => uint) map; // ✅ Append only
        // uint256 value;            // ❌ Never modify existing
    }
}
```

2. **Update Initialization (if needed)**
```solidity
contract DiamondInit {
    function init(Args memory _args) external {
        LibAppStorage.AppStorage storage s = LibAppStorage.diamondStorage();
        s.newVariable = _args.initialValue; // Initialize new storage
    }
}
```

#### Important Considerations
1. **Append-Only Rule**
   - Never modify existing storage layout
   - Only add new variables at the end
   - Never remove or reorder existing variables

2. **Storage Slots**
   - Each storage variable occupies specific slots
   - Mappings and dynamic arrays use hashed slots
   - Maintain storage layout documentation

3. **Initialization**
   - Consider default values
   - Update initialization logic if needed
   - Handle migration of existing data

### Adding New Facets

#### Process
1. **Create New Facet Contract**
```solidity
contract NewFacet {
    using LibAppStorage for LibAppStorage.AppStorage;

    // Storage access
    function getNewVariable() external view returns (uint256) {
        return LibAppStorage.diamondStorage().newVariable;
    }

    // New functionality
    function setNewVariable(uint256 _value) external {
        LibAppStorage.diamondStorage().newVariable = _value;
    }
}
```

2. **Deploy Facet**
```solidity
NewFacet newFacet = new NewFacet();
```

3. **Create Diamond Cut**
```solidity
// Prepare function selectors
bytes4[] memory selectors = new bytes4[](2);
selectors[0] = NewFacet.getNewVariable.selector;
selectors[1] = NewFacet.setNewVariable.selector;

// Create cut struct
IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);
cut[0] = IDiamondCut.FacetCut({
    facetAddress: address(newFacet),
    action: IDiamondCut.FacetCutAction.Add,
    functionSelectors: selectors
});
```

4. **Execute Diamond Cut**
```solidity
// Without initialization
diamondCut.diamondCut(cut, address(0), new bytes(0));

// With initialization
bytes memory initData = abi.encodeWithSelector(
    DiamondInit.init.selector,
    initArgs
);
diamondCut.diamondCut(cut, address(diamondInit), initData);
```

#### Important Considerations

1. **Function Selector Conflicts**
   - Check for selector collisions
   - Use DiamondLoupeFacet to inspect existing selectors
   - Remove old selectors before adding conflicting ones
```solidity
// Check for existing implementation
address facet = diamondLoupe.facetAddress(selector);
require(facet == address(0), "Function already exists");
```

2. **State Management**
   - Use LibAppStorage for state access
   - Follow storage layout rules
   - Document storage usage

3. **Access Control**
   - Implement proper modifiers
   - Update access control lists
   - Consider admin requirements
```solidity
modifier onlyAdmin() {
    require(LibAppStorage.diamondStorage().admins[msg.sender], "Not admin");
    _;
}
```

4. **Testing**
   - Test new functions
   - Test interactions with existing facets
   - Test storage integrity
```solidity
function testNewFacet() public {
    // Deploy
    NewFacet facet = new NewFacet();
    
    // Add to diamond
    addFacet(address(facet), selectors);
    
    // Test functionality
    NewFacet(address(diamond)).setNewVariable(42);
    assertEq(NewFacet(address(diamond)).getNewVariable(), 42);
}
```

5. **Upgrade Safety**
   - Backup existing state
   - Plan for rollback
   - Test in staging environment
```solidity
// Backup important state before upgrade
uint256 oldValue = StorageFacet(address(diamond)).getValue();
// Perform upgrade
// Verify state preservation
assert(StorageFacet(address(diamond)).getValue() == oldValue);
```

### Why This Process Matters

1. **Storage Safety**
   - Prevents storage collisions
   - Maintains data integrity
   - Enables safe upgrades

2. **Function Organization**
   - Clear responsibility separation
   - Easier maintenance
   - Better testing isolation

3. **Upgrade Flexibility**
   - Add/remove functionality
   - Fix bugs
   - Extend features

4. **Gas Optimization**
   - Efficient storage layout
   - Optimized function routing
   - Minimal proxy overhead

5. **Security**
   - Controlled upgrades
   - Access management
   - State protection

## License

MIT

