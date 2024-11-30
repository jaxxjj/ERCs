# ERC-5267: EIP-712 Domain Contract Standard

This project implements the [ERC-5267](https://eips.ethereum.org/EIPS/eip-5267) standard, which provides a standardized interface for retrieving EIP-712 domain parameters from smart contracts.

## Overview

ERC-5267 enhances the EIP-712 signing standard by providing a consistent way to retrieve domain parameters directly from contracts. This is crucial for:

- Dynamic domain parameter retrieval
- Cross-chain signature verification
- Signature validation in smart contracts
- Frontend integration with signing mechanisms

### Key Features

1. **Standardized Domain Retrieval**
   - Consistent interface for domain parameters
   - Runtime domain parameter access
   - Chain-agnostic implementation
   - Backwards compatibility with EIP-712

2. **Domain Parameters**
   - Contract name
   - Version string
   - Chain ID
   - Verifying contract address
   - Salt (optional)
   - Extensions (optional)

3. **Security Features**
   - Immutable domain parameters
   - Cross-chain replay protection
   - Signature validation utilities
   - Permission management

## Contract Architecture

### Core Contracts

1. **EIP712.sol**
   - Base implementation
   - Domain separator calculation
   - Typed data hashing
   - ERC-5267 interface implementation

2. **ExampleContract.sol**
   - Permission management example
   - Signature validation
   - Protected functions
   - Event emission

3. **PermissionManager.sol**
   - Delegated permissions
   - Signature-based authorization
   - Permission validation
   - Multi-user management

### Interfaces

1. **IERC5267.sol**
   ```solidity
   interface IERC5267 {
       function eip712Domain() external view returns (
           bytes1 fields,
           string memory name,
           string memory version,
           uint256 chainId,
           address verifyingContract,
           bytes32 salt,
           uint256[] memory extensions
       );
   }
   ```

## Integration Guide

### 1. Implementing ERC-5267

```solidity
contract YourContract is EIP712 {
    constructor() EIP712("YourContract", "1") {}
    
    // Your contract logic
}
```

### 2. Retrieving Domain Parameters

```solidity
(
    bytes1 fields,
    string memory name,
    string memory version,
    uint256 chainId,
    address verifyingContract,
    bytes32 salt,
    uint256[] memory extensions
) = contract.eip712Domain();
```

### 3. Frontend Integration

```typescript
const domain = await contract.eip712Domain();
const typedData = {
    domain: {
        name: domain.name,
        version: domain.version,
        chainId: domain.chainId,
        verifyingContract: domain.verifyingContract
    },
    // ... message types and values
};
```

## Security Considerations

1. **Domain Immutability**
   - Domain parameters should be immutable
   - Version changes require new deployments
   - Chain ID verification is crucial

2. **Signature Validation**
   - Proper nonce management
   - Expiry timestamp checks
   - Signer verification
   - Replay attack prevention

3. **Permission Management**
   - Access control implementation
   - Permission delegation
   - Signature expiration
   - Revocation mechanisms

4. **Cross-Chain Safety**
   - Chain ID verification
   - Domain separator uniqueness
   - Replay protection across chains

## Best Practices

1. **Domain Parameters**
   - Use meaningful contract names
   - Include version numbers
   - Verify chain ID dynamically
   - Store parameters immutably

2. **Signature Handling**
   - Validate expiry timestamps
   - Check signer authorization
   - Implement nonce mechanisms
   - Verify signature components

3. **Permission System**
   - Implement granular permissions
   - Enable delegation controls
   - Include revocation mechanisms
   - Emit relevant events

## License

MIT
