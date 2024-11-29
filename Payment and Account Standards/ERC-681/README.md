# ERC-681 Technical Specification & Implementation Details

## Standard Overview

ERC-681 defines a standardized URL format for payment requests in Ethereum, similar to Bitcoin's BIP-21. This standard enables interoperable payment requests across different wallets and applications.

## URL Format Specification

### ETH Payment Format
```
ethereum:<address>[?value=<wei>]
```

Example:
```
ethereum:0x8932...?value=1000000000000000000
```

### Token Payment Format
```
ethereum:<token_address>/transfer?to=<recipient>&amount=<amount>
```

Example:
```
ethereum:0x6b175474e89094c44da98b954eedeac495271d0f/transfer?to=0x8932...&amount=100000000
```

## Core Components

### 1. URL Generator

The URL generator handles the creation of compliant payment URLs:

```solidity
function createPaymentRequest(
    uint256 amount,
    bool isToken,
    address tokenAddress
) public view returns (string memory) {
    if (isToken) {
        return generateTokenURL(tokenAddress, amount);
    }
    return generateEthURL(amount);
}
```

Key features:
- Amount validation
- Address checksum verification
- Token detection and handling
- URL encoding

### 2. URL Parser

The parser breaks down payment URLs into their components:

```solidity
struct TransactionRequest {
    address targetAddress;  // recipient or token contract
    uint256 value;         // amount in wei or tokens
    uint256 gasLimit;      // optional gas limit
    string functionName;   // "transfer" for tokens
    bytes parameters;      // encoded parameters
    bool isContract;       // true for token transfers
}
```

Parsing process:
1. URL validation
2. Scheme verification
3. Address extraction
4. Parameter parsing
5. Data validation

### 3. Payment Executor

The executor handles the actual payment processing:

```solidity
function executeFromURL(string calldata url) external payable {
    TransactionRequest memory request = parser.parseURL(url);
    
    if (request.isContract) {
        // Handle token transfer
        IERC20(request.targetAddress).transferFrom(
            msg.sender,
            address(this),
            request.value
        );
    } else {
        // Handle ETH transfer
        payable(request.targetAddress).transfer(request.value);
    }
}
```

Security measures:
- Reentrancy protection
- Amount validation
- Address validation
- Gas limit checks
- Token approval verification

## Implementation Details

### 1. String Handling

The implementation uses efficient string manipulation:

```solidity
function toString(uint256 value) internal pure returns (string memory) {
    if (value == 0) {
        return "0";
    }
    uint256 temp = value;
    uint256 digits;
    while (temp != 0) {
        digits++;
        temp /= 10;
    }
    bytes memory buffer = new bytes(digits);
    while (value != 0) {
        digits -= 1;
        buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
        value /= 10;
    }
    return string(buffer);
}
```

### 2. Parameter Encoding

Token transfers require proper parameter encoding:

```solidity
function encodeTransferParams(
    address to,
    uint256 amount
) internal pure returns (bytes memory) {
    return abi.encodeWithSelector(
        IERC20.transfer.selector,
        to,
        amount
    );
}
```

### 3. Gas Optimization

Key optimization techniques:
- Minimal string operations
- Efficient memory usage
- Optimized loops
- Storage vs. memory trade-offs

## Testing Strategy

### 1. Unit Tests

```solidity
function testBasicEthPayment() public {
    string memory url = executor.createPaymentRequest(
        1 ether,
        false,
        address(0)
    );
    
    vm.deal(address(this), 1 ether);
    executor.executeFromURL{value: 1 ether}(url);
}
```

### 2. Integration Tests

```solidity
function testTokenPaymentFlow() public {
    // Setup token
    MockERC20 token = new MockERC20();
    
    // Create payment request
    string memory url = executor.createPaymentRequest(
        100e18,
        true,
        address(token)
    );
    
    // Execute payment
    token.approve(address(executor), 100e18);
    executor.executeFromURL(url);
}
```

### 3. Edge Cases

Test coverage includes:
- Zero amounts
- Invalid addresses
- Malformed URLs
- Insufficient balances
- Failed transfers
- Gas limitations

## Security Considerations

### 1. Input Validation

All inputs must be validated:
- Address checksums
- Amount ranges
- URL format
- Parameter types

### 2. Access Control

```solidity
modifier onlyAuthorized() {
    require(
        msg.sender == owner || authorized[msg.sender],
        "Unauthorized"
    );
    _;
}
```

### 3. Reentrancy Protection

```solidity
modifier nonReentrant() {
    require(!locked, "Reentrant call");
    locked = true;
    _;
    locked = false;
}
```

## Gas Optimization Tips

1. URL Generation
   - Pre-calculate string lengths
   - Minimize concatenations
   - Use memory efficiently

2. Parsing
   - Avoid redundant checks
   - Optimize string operations
   - Use assembly when beneficial

3. Execution
   - Batch operations when possible
   - Minimize storage operations
   - Use events efficiently

## Common Integration Patterns

### 1. Wallet Integration

```solidity
interface IWallet {
    function handlePaymentRequest(string calldata url) external payable;
}
```

### 2. dApp Integration

```javascript
const paymentUrl = await contract.createPaymentRequest(
    ethers.utils.parseEther("1.0"),
    false,
    ethers.constants.AddressZero
);
```

### 3. Payment Processing

```solidity
function processPayment(string memory url) external payable {
    require(isValidUrl(url), "Invalid URL");
    TransactionRequest memory request = parseUrl(url);
    executePayment(request);
    emit PaymentProcessed(request.targetAddress, request.value);
}
```

## Future Improvements

1. Enhanced Features
   - Multi-token payments
   - Recurring payments
   - Payment scheduling
   - Batch processing

2. Optimizations
   - Gas optimization
   - Memory efficiency
   - String handling
   - URL parsing

3. Security
   - Additional validations
   - Improved error handling
   - Enhanced access control
   - Audit recommendations

---

This document serves as a comprehensive guide to understanding and implementing the ERC-681 standard. For specific implementation details, please refer to the source code and tests.



