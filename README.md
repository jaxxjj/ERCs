# Overview

This repository contains a collection of ERC standards, each in its own directory. Each standard is implemented in a separate foundry project and includes:
- a README file explaining the purpose, features, and use cases of the standard
- a src folder:
  - interfaces: contains the interface of the standards
  - base: contains the implementation of the standards
  - examples: contains examples of the standards
- a test folder:
  - unit tests
  - fuzz tests
  - invariant tests
- a script folder:
  - deployment scripts
  - interaction scripts
- a gas report

# Contents

## Core Token Standards

### [ERC-20: Fungible Token Standard](https://github.com/jaxxjj/ERCs/tree/main/Core%20Token%20Standards/ERC-20)
- **Purpose**: Standard for fungible tokens
- **Use Cases**: Cryptocurrencies, governance tokens, stablecoins
- **Examples**: USDT, USDC, UNI, LINK

### [ERC-721: Non-Fungible Token Standard](https://github.com/jaxxjj/ERCs/tree/main/Core%20Token%20Standards/ERC-721)
- **Purpose**: Standard for unique tokens (NFTs)
- **Use Cases**: Digital art, game items, virtual real estate
- **Examples**: BAYC, CryptoPunks

### [ERC-777: Advanced Token Standard](https://github.com/jaxxjj/ERCs/tree/main/Core%20Token%20Standards/ERC-777)
- **Purpose**: Enhanced fungible token standard
- **Features**: Hooks for token operations
- **Use Cases**: Advanced token functionality

### [ERC-1155: Multi-Token Standard](https://github.com/jaxxjj/ERCs/tree/main/Core%20Token%20Standards/ERC-1155)
- **Purpose**: Combines functionality of ERC-20 and ERC-721
- **Features**: Efficient for multiple token types
- **Use Cases**: Gaming assets, mixed collections

## DeFi-Related Standards

### [ERC-2612: Permit Extension for ERC-20](https://github.com/jaxxjj/ERCs/tree/main/DeFi-Related%20Standards/ERC-2612)
- **Purpose**: Gasless token approvals
- **Features**: 
  - Allows meta-transactions for ERC-20
  - Improves UX by eliminating double transactions

### [ERC-3156: Flash Loan Standard](https://github.com/jaxxjj/ERCs/tree/main/DeFi-Related%20Standards/ERC-3156)
- **Purpose**: Standardizes flash loan operations
- **Use Cases**: Arbitrage and liquidations
- **Feature**: Ensures composability between protocols

### [ERC-4626: Tokenized Vault Standard](https://github.com/jaxxjj/ERCs/tree/main/DeFi-Related%20Standards/ERC-4626)
- **Purpose**: Standard for yield-bearing vaults
- **Use Cases**: Lending protocols, yield aggregators
- **Feature**: Standardizes yield-bearing tokens

## Governance Standards

### [ERC-1202: Voting Standard](https://github.com/jaxxjj/ERCs/tree/main/Governance%20Standards/ERC-1202)
- **Purpose**: Standardizes voting mechanisms
- **Features**: Flexible voting schemes
- **Use Cases**: DAO governance, token voting

### [ERC-2767: Governance Token Standard](https://github.com/jaxxjj/ERCs/tree/main/Governance%20Standards/ERC-2767)
- **Purpose**: Standard for governance tokens
- **Features**: Quorum tracking, vote delegation
- **Use Cases**: Protocol governance

## Infrastructure Standards

### [ERC-165: Interface Detection](https://github.com/jaxxjj/ERCs/tree/main/Infrastructure%20Standards/ERC-165)
- **Purpose**: Standard for interface support detection
- **Features**: Enables contract feature discovery
- **Use Cases**: Contract compatibility checking

### [ERC-1167: Minimal Proxy Contract](https://github.com/jaxxjj/ERCs/tree/main/Infrastructure%20Standards/ERC-1167)
- **Purpose**: Standard for contract cloning
- **Features**: Reduces deployment costs
- **Use Cases**: Factory patterns

### [ERC-1271: Contract Signature Validation](https://github.com/jaxxjj/ERCs/tree/main/Infrastructure%20Standards/ERC-1271)
- **Purpose**: Standard for contract signatures
- **Features**: Enables smart contract wallets
- **Use Cases**: Signature verification

### [ERC-1967: Proxy Storage](https://github.com/jaxxjj/ERCs/tree/main/Infrastructure%20Standards/ERC-1967)
- **Purpose**: Standard proxy storage slots
- **Features**: Consistent proxy implementations
- **Use Cases**: Contract upgradeability

### [ERC-2535: Diamond Standard](https://github.com/jaxxjj/ERCs/tree/main/Infrastructure%20Standards/ERC-2535)
- **Purpose**: Multi-facet proxy pattern
- **Features**: Modular contract architecture
- **Use Cases**: Complex contract systems

## NFT Enhancement Standards

### [ERC-721A: Gas Optimized NFT](https://github.com/jaxxjj/ERCs/tree/main/NFT%20Enhancement%20Standards/ERC-721A)
- **Purpose**: Gas efficient NFT standard
- **Features**: Batch minting optimization
- **Use Cases**: Large NFT collections

### [ERC-2981: NFT Royalty Standard](https://github.com/jaxxjj/ERCs/tree/main/NFT%20Enhancement%20Standards/ERC-2981)
- **Purpose**: Standardizes royalty payments
- **Features**: On-chain royalty information
- **Use Cases**: Creator compensation

### [ERC-4907: Rentable NFT Standard](https://github.com/jaxxjj/ERCs/tree/main/NFT%20Enhancement%20Standards/ERC-4907)
- **Purpose**: Enables NFT rental functionality
- **Features**: Time-based user rights
- **Use Cases**: NFT lending and renting

### [ERC-5192: Soulbound Token](https://github.com/jaxxjj/ERCs/tree/main/NFT%20Enhancement%20Standards/ERC-5192)
- **Purpose**: Non-transferable tokens
- **Use Cases**: Credentials and reputation
- **Feature**: Permanent association with an address

## Payment and Account Standards

### [ERC-681: Payment Request](https://github.com/jaxxjj/ERCs/tree/main/Payment%20and%20Account%20Standards/ERC-681)
- **Purpose**: Payment request standard
- **Features**: URL format for payments
- **Use Cases**: Payment integrations

### [ERC-2771: Meta Transactions](https://github.com/jaxxjj/ERCs/tree/main/Payment%20and%20Account%20Standards/ERC-2771)
- **Purpose**: Gasless transaction standard
- **Features**: Relayer support
- **Use Cases**: Gas abstraction

### [ERC-4337: Account Abstraction](https://github.com/jaxxjj/ERCs/tree/main/Payment%20and%20Account%20Standards/ERC-4337)
- **Purpose**: Smart contract wallet standard
- **Features**: Programmable accounts
- **Use Cases**: Advanced wallet functionality

## Security and Access Standards

### [ERC-5267: Rejection Standard](https://github.com/jaxxjj/ERCs/tree/main/Security%20and%20Access%20Standards/ERC-5267)
- **Purpose**: Standardizes transaction rejection
- **Features**: Clear rejection reasons
- **Use Cases**: Transaction validation

### [ERC-6372: Contract Clock Standard](https://github.com/jaxxjj/ERCs/tree/main/Security%20and%20Access%20Standards/ERC-6372)
- **Purpose**: Standardizes time handling
- **Features**: Unified timing interface
- **Use Cases**: Time-dependent operations


# Getting Started

## Installation

1. Clone the repository:
```bash
git clone https://github.com/jaxxjj/ERCs
cd ERCs
```

2. Install Foundry dependencies:
```bash
forge install
```

## Usage

### Compile Contracts
```bash
forge build
```

### Run Tests
<details>
<summary>Click to see test commands</summary>

```bash
# Run all tests
forge test

# Run specific test file
forge test --match-path test/ERC20/ERC20.t.sol

# Run with verbosity
forge test -vvv

# Run with gas report
forge test --gas-report
```
</details>

### Deploy Contracts
<details>
<summary>Click to see deployment commands</summary>

```bash
# Deploy to local network
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast

# Deploy to testnet (e.g., Sepolia)
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast --verify

# Deploy to mainnet
forge script script/Deploy.s.sol --rpc-url $MAINNET_RPC_URL --broadcast --verify
```
</details>

### Project Structure
```
ERCs/
├── src/                    # Source contracts
│   ├── interfaces/         # Contract interfaces
│   ├── base/              # Base implementations
│   └── examples/          # Example implementations
├── test/                  # Test files
├── script/                # Deployment scripts
└── README.md             # Documentation
```

### Environment Setup
1. Create a `.env` file in the root directory:
```env
SEPOLIA_RPC_URL=your_sepolia_rpc_url
MAINNET_RPC_URL=your_mainnet_rpc_url
PRIVATE_KEY=your_private_key
ETHERSCAN_API_KEY=your_etherscan_api_key
```

2. Load environment variables:
```bash
source .env
```

### Examples
Each ERC standard includes example implementations in the `src/examples` directory. To use them:

1. Navigate to the specific standard:
```bash
cd src/examples
```

2. Review the example implementation:
```bash
cat MyERC20.sol
```

3. Run the example tests:
```bash
forge test --match-path test/examples/MyERC20.t.sol
```

# Structure

## src
- interfaces: contains the interface of the standards
<summary>Example: IERC1271.sol</summary>

```javascript
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IERC1271
 * @dev Standard interface for contract signature validation
 */
interface IERC1271 {
    /**
     * @dev Should return whether the signature provided is valid for the provided data
     * @param hash      Hash of the data to be signed
     * @param signature Signature byte array associated with _data
     */
    function isValidSignature(
        bytes32 hash, 
        bytes memory signature
    ) external view returns (bytes4 magicValue);
}

```

- base: contains the implementation of the standards
<summary>Example: ERC6372Implementation.sol</summary>

```javascript
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC6372} from "../interfaces/IERC6372.sol";

/**
 * @title ERC6372 Implementation
 * @dev Implementation of the ERC6372 Clock Mode standard
 */
contract ERC6372Implementation is IERC6372 {

    function clock() public view virtual returns (uint48) {
        return uint48(block.timestamp);
    }
    function CLOCK_MODE() public view virtual returns (string memory) {
        return "mode=timestamp";
    }
}

/**
 * @title Block Number Based ERC6372
 * @dev Alternative implementation using block numbers instead of timestamps
 */
contract BlockNumberERC6372 is IERC6372 {
    function clock() public view virtual returns (uint48) {
        return uint48(block.number);
    }

    function CLOCK_MODE() public view virtual returns (string memory) {
        return "mode=block";
    }
}
```

- examples: contains examples of the standards
<summary>Example: MyNFT.sol</summary>

```javascript
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../base/ERC721.sol";

contract MyNFT is ERC721 {
    uint256 private s_tokenIds;
    
    constructor() ERC721("MyNFT", "MNFT") {
        s_tokenIds = 0;
    }
    
    function mint() public returns (uint256) {
        s_tokenIds += 1;
        _safeMint(msg.sender, s_tokenIds);
        return s_tokenIds;
    }
}
```

## test
contains the test of the standards

### unit test
unit test is a test that tests a single function or a small part of the contract.
<details>
<summary>Example: MyNFT.t.sol</summary>

```javascript
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/examples/MyNFT.sol";
import "../../src/interfaces/IERC721.sol";

contract MyNFTTest is Test {
    MyNFT public nft;
    address public owner;
    address public user1;
    address public user2;
    
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
    
    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        nft = new MyNFT();
    }

    function testTokenMetadata() public {
        assertEq(nft.name(), "MyNFT");
        assertEq(nft.symbol(), "MNFT");
    }

    function testMint() public {
        uint256 tokenId = nft.mint();
        assertEq(tokenId, 1);
        assertEq(nft.balanceOf(owner), 1);
        assertEq(nft.ownerOf(tokenId), owner);
    }

    function testMintIncrements() public {
        uint256 firstToken = nft.mint();
        uint256 secondToken = nft.mint();
        assertEq(firstToken, 1);
        assertEq(secondToken, 2);
    }

    function testMintEmitsTransferEvent() public {
        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0), owner, 1);
        nft.mint();
    }

    function testTransfer() public {
        uint256 tokenId = nft.mint();
        nft.transferFrom(owner, user1, tokenId);
        
        assertEq(nft.balanceOf(owner), 0);
        assertEq(nft.balanceOf(user1), 1);
        assertEq(nft.ownerOf(tokenId), user1);
    }

    function testApprove() public {
        uint256 tokenId = nft.mint();
        nft.approve(user1, tokenId);
        
        assertEq(nft.getApproved(tokenId), user1);
    }

    function testApproveEmitsEvent() public {
        uint256 tokenId = nft.mint();
        
        vm.expectEmit(true, true, true, true);
        emit Approval(owner, user1, tokenId);
        
        nft.approve(user1, tokenId);
    }

    function testFailTransferUnownedToken() public {
        nft.transferFrom(owner, user1, 1);
    }

    function testFailTransferUnauthorized() public {
        uint256 tokenId = nft.mint();
        vm.prank(user1);
        nft.transferFrom(owner, user2, tokenId);
    }

    function testFailTransferToZeroAddress() public {
        uint256 tokenId = nft.mint();
        nft.transferFrom(owner, address(0), tokenId);
    }

    function testFailGetApprovedUnminted() public {
        nft.getApproved(1);
    }

    function testFailApproveUnminted() public {
        nft.approve(user1, 1);
    }

    
}
```
</details>

### fuzz test
fuzz test is a test that tests the contract with random data.
<details>
<summary>Example: MyNFT.fuzz.t.sol</summary>

```javascript
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/examples/MyNFT.sol";
import "../../src/interfaces/IERC721.sol";

contract MyNFTFuzzTest is Test {
    MyNFT public nft;
    address public owner;
    
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function setUp() public {
        owner = address(this);
        nft = new MyNFT();
    }

    function testFuzzMintToEOA(address to) public {
        vm.assume(to != address(0));
        vm.assume(!_isContract(to));
        
        uint256 tokenId = nft.mint();
        nft.transferFrom(owner, to, tokenId);
        
        assertEq(nft.ownerOf(tokenId), to);
        assertEq(nft.balanceOf(to), 1);
    }

    function testFuzzApproval(address to, address spender) public {
        vm.assume(to != address(0));
        vm.assume(spender != address(0));
        vm.assume(to != spender);
        
        uint256 tokenId = nft.mint();
        nft.transferFrom(owner, to, tokenId);
        
        vm.prank(to);
        nft.approve(spender, tokenId);
        
        assertEq(nft.getApproved(tokenId), spender);
    }

    function testFuzzTransferFrom(address from, address to) public {
        vm.assume(from != address(0));
        vm.assume(to != address(0));
        vm.assume(from != to);
        vm.assume(!_isContract(to));
        
        uint256 tokenId = nft.mint();
        nft.transferFrom(owner, from, tokenId);
        
        // Track initial states
        uint256 fromBalanceBefore = nft.balanceOf(from);
        uint256 toBalanceBefore = nft.balanceOf(to);
        
        // Approve test contract for transfer
        vm.prank(from);
        nft.approve(address(this), tokenId);
        
        // Perform transfer
        nft.transferFrom(from, to, tokenId);
        
        // Verify final state
        assertEq(nft.ownerOf(tokenId), to);
        assertEq(nft.balanceOf(from), fromBalanceBefore - 1);
        assertEq(nft.balanceOf(to), toBalanceBefore + 1);
        assertEq(nft.getApproved(tokenId), address(0));
    }

    function testFuzzApprovalForAll(address owner, address operator, bool approved) public {
        vm.assume(owner != address(0));
        vm.assume(operator != address(0));
        vm.assume(owner != operator);
        
        vm.prank(owner);
        nft.setApprovalForAll(operator, approved);
        
        assertEq(nft.isApprovedForAll(owner, operator), approved);
    }

    function testFuzzMultipleTransfers(address[3] memory recipients) public {
        for(uint i = 0; i < recipients.length; i++) {
            vm.assume(recipients[i] != address(0));
            vm.assume(!_isContract(recipients[i]));
            
            uint256 tokenId = nft.mint();
            nft.transferFrom(owner, recipients[i], tokenId);
            
            assertEq(nft.ownerOf(tokenId), recipients[i]);
            assertEq(nft.balanceOf(recipients[i]), 1);
        }
    }

    function testFailFuzzTransferUnauthorized(address from, address to, uint256 tokenId) public {
        vm.assume(from != address(0));
        vm.assume(to != address(0));
        
        vm.prank(from);
        nft.transferFrom(from, to, tokenId);
    }

    // Helper function to check if address is a contract
    function _isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}
```
</details>

### invariant test

invariant test is a test that tests the unbreakable invariants of the contract.
<details>
<summary>Example: ERC6372Implementation.sol</summary>

```javascript
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/examples/MyNFT.sol";

contract NFTHandler {
    MyNFT public nft;
    address[] public users;
    mapping(uint256 => bool) public tokenExists;
    mapping(address => uint256[]) internal userTokens;
    
    constructor(MyNFT _nft) {
        nft = _nft;
        for(uint i = 0; i < 5; i++) {
            users.push(address(uint160(i + 1)));
        }
    }
    
    function getUserTokenCount(address user) public view returns (uint256) {
        return userTokens[user].length;
    }
    
    function getUserTokenAt(address user, uint256 index) public view returns (uint256) {
        require(index < userTokens[user].length, "Index out of bounds");
        return userTokens[user][index];
    }
    
    function mint() public {
        uint256 tokenId = nft.mint();
        tokenExists[tokenId] = true;
        userTokens[msg.sender].push(tokenId);
    }
    
    function transfer(uint256 userSeed, uint256 tokenIndex) public {
        if (getUserTokenCount(msg.sender) == 0) return;
        if (users.length == 0) return;
        
        uint256 tokenId = getUserTokenAt(msg.sender, tokenIndex % getUserTokenCount(msg.sender));
        address to = users[userSeed % users.length];
        
        nft.transferFrom(msg.sender, to, tokenId);
        
        userTokens[to].push(tokenId);
        removeTokenFromUser(msg.sender, tokenId);
    }
    
    function removeTokenFromUser(address user, uint256 tokenId) internal {
        uint256[] storage tokens = userTokens[user];
        for (uint i = 0; i < tokens.length; i++) {
            if (tokens[i] == tokenId) {
                tokens[i] = tokens[tokens.length - 1];
                tokens.pop();
                break;
            }
        }
    }
}

contract MyNFTInvariantTest is Test {
    MyNFT public nft;
    NFTHandler public handler;
    
    function setUp() public {
        nft = new MyNFT();
        handler = new NFTHandler(nft);
        targetContract(address(handler));
    }
    
    function invariant_balanceEqualsTokenCount() public {
        for(uint i = 0; i < 5; i++) {
            address user = address(uint160(i + 1));
            assertEq(
                nft.balanceOf(user),
                handler.getUserTokenCount(user),
                "Balance should equal owned token count"
            );
        }
    }
    
    function invariant_tokenHasOneOwner() public {
        for(uint256 tokenId = 1; tokenId <= 100; tokenId++) {
            if (handler.tokenExists(tokenId)) {
                address owner = nft.ownerOf(tokenId);
                uint256 ownerCount = 0;
                
                for(uint i = 0; i < 5; i++) {
                    address user = address(uint160(i + 1));
                    for(uint j = 0; j < handler.getUserTokenCount(user); j++) {
                        if (handler.getUserTokenAt(user, j) == tokenId) {
                            ownerCount++;
                            assertEq(owner, user, "Token owner mismatch");
                        }
                    }
                }
                
                assertEq(ownerCount, 1, "Token must have exactly one owner");
            }
        }
    }
    
    function invariant_approvalStateConsistency() public {
        for(uint256 tokenId = 1; tokenId <= 100; tokenId++) {
            if (handler.tokenExists(tokenId)) {
                address approved = nft.getApproved(tokenId);
                if (approved != address(0)) {
                    address owner = nft.ownerOf(tokenId);
                    assertTrue(
                        approved != owner,
                        "Owner cannot be approved for their own token"
                    );
                }
            }
        }
    }
}
```
</details>

## Scripts
contains the scripts of deployment and other interactive scripts.
<details>
<summary>Example: DeployERC2767.s.sol</summary>

```javascript
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script,console2} from "forge-std/Script.sol";
import {ERC2767Governance} from "../src/base/ERC2767.sol";
import {MockToken} from "../test/unit/ERC2767.t.sol";

contract DeployERC2767 is Script {
    // Configuration
    uint256 public constant INITIAL_QUORUM = 70; // 70% quorum requirement
    uint256 public constant GOVERNOR_POWER = 40; // Equal voting power for each governor

    function run() external {
        // Get deployment private key from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // Start broadcast
        vm.startBroadcast(deployerPrivateKey);

        // Deploy mock token first (for testing)
        MockToken token = new MockToken();

        // Setup initial governors (example with 3 governors)
        address[] memory governors = new address[](3);
        governors[0] = vm.envAddress("GOVERNOR_1");
        governors[1] = vm.envAddress("GOVERNOR_2");
        governors[2] = vm.envAddress("GOVERNOR_3");

        // Setup initial voting powers
        uint256[] memory powers = new uint256[](3);
        powers[0] = GOVERNOR_POWER;
        powers[1] = GOVERNOR_POWER;
        powers[2] = GOVERNOR_POWER;

        // Deploy governance contract
        ERC2767Governance governance = new ERC2767Governance(
            governors,
            powers,
            INITIAL_QUORUM,
            address(token)
        );

        // End broadcast
        vm.stopBroadcast();

        // Log deployment information
        console2.log("Deployment Summary:");
        console2.log("------------------");
        console2.log("Token deployed to:", address(token));
        console2.log("Governance deployed to:", address(governance));
        console2.log("Initial governors:");
        console2.log("- Governor 1:", governors[0]);
        console2.log("- Governor 2:", governors[1]);
        console2.log("- Governor 3:", governors[2]);
        console2.log("Quorum requirement:", INITIAL_QUORUM);
        console2.log("Individual voting power:", GOVERNOR_POWER);
    }
}

```
</details>

## gas report
contains the gas report of the standards.
<details>
<summary>Example: gas-report.txt</summary>

```
No files changed, compilation skipped

Ran 8 tests for test/unit/RentableNFT.t.sol:RentableNFTTest
[PASS] testGetRemainingRentalTime() (gas: 66664)
[PASS] testIsRented() (gas: 66883)
[PASS] testMint() (gas: 12985)
[PASS] testRentOut() (gas: 65208)
[PASS] testRentOutNotOwner() (gas: 35651)
[PASS] testRentalExpiration() (gas: 66973)
[PASS] testSetUser() (gas: 63161)
[PASS] testSetUserNotOwner() (gas: 40643)
Suite result: ok. 8 passed; 0 failed; 0 skipped; finished in 2.47ms (8.88ms CPU time)
| src/examples/RentableNFT.sol:RentableNFT contract |                 |       |        |       |         |
|---------------------------------------------------|-----------------|-------|--------|-------|---------|
| Deployment Cost                                   | Deployment Size |       |        |       |         |
| 1182741                                           | 5474            |       |        |       |         |
| Function Name                                     | min             | avg   | median | max   | # calls |
| getRemainingRentalTime                            | 553             | 601   | 625    | 625   | 3       |
| isRented                                          | 589             | 1099  | 773    | 2589  | 5       |
| mint                                              | 68413           | 68413 | 68413  | 68413 | 8       |
| ownerOf                                           | 2602            | 2602  | 2602   | 2602  | 1       |
| rentOut                                           | 24380           | 43992 | 48896  | 48896 | 5       |
| setUser                                           | 29295           | 38880 | 38880  | 48466 | 2       |
| userOf                                            | 592             | 710   | 770    | 770   | 3       |




Ran 1 test suite in 3.41ms (2.47ms CPU time): 8 tests passed, 0 failed, 0 skipped (8 total tests)

```
</details>

# Contributing

1. Fork the repository
2. Create your feature branch:
```bash
git checkout -b feature/my-new-feature
```

3. Commit your changes:
```bash
git commit -am 'Add some feature'
```

4. Push to the branch:
```bash
git push origin feature/my-new-feature
```

5. Submit a pull request

# License
MIT

# Contact
- @jaxonc.eth
- Telegram: [@jaxon_275](https://t.me/jaxon_275)