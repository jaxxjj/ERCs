# ERC-1271: Standard Signature Validation Method for Contracts

## Introduction

ERC-1271 is a standard interface for smart contracts to validate signatures. This standard allows smart contracts to verify whether a signature is valid for a given message, enabling contracts to act as signers in various protocols and applications.

## Why ERC-1271?

Traditional signature verification (ecrecover) only works with Externally Owned Accounts (EOAs). However, smart contracts cannot generate ECDSA signatures as they don't have private keys. ERC-1271 solves this by:

1. Allowing smart contracts to define their own signature validation logic
2. Enabling protocols to treat both EOAs and smart contracts uniformly when validating signatures
3. Supporting various signature schemes and validation methods

## Key Features

- **Flexible Validation**: Contracts can implement custom signature validation logic
- **Standardized Interface**: Common interface for all contract-based signature validation
- **Backwards Compatible**: Works alongside existing ECDSA signatures
- **Multi-Signature Support**: Enables complex signing schemes like multisig wallets
- **Cross-Protocol Compatibility**: Standard interface for all protocols requiring signature validation

## Implementation

The core interface is simple:

```solidity
interface IERC1271 {
    function isValidSignature(
        bytes32 hash,
        bytes calldata signature
    ) external view returns (bytes4 magicValue);
}
```

Where:
- `hash`: Message hash that was signed
- `signature`: Signature bytes to validate
- Returns `0x1626ba7e` if valid, any other value if invalid

## Example Use Cases

1. **Smart Contract Wallets**
   - Multi-signature wallets
   - Social recovery wallets
   - Programmatic authorization

2. **DAOs**
   - Proposal signing
   - Vote delegation
   - Permission management

3. **DeFi Applications**
   - Permit-style approvals
   - Meta-transactions
   - Signature-based actions

## Deployed Contracts

### Sepolia (11155111)
- PermitToken: [`0xaE890542aEEFcB350fA9D6Fb933aA470B9aD819c`](https://sepolia.etherscan.io/address/0xaE890542aEEFcB350fA9D6Fb933aA470B9aD819c)

### Arbitrum Sepolia (421611)
- PermitToken: [`0x4D02b24ccE4C047Ab2AEeC55b2a53c6820CC4274`](https://sepolia.arbiscan.io/address/0x4D02b24ccE4C047Ab2AEeC55b2a53c6820CC4274)

### Base Sepolia (84632)
- PermitToken: [`0xEEceD3e2aE266B46dEcc1627D31855CdCDB02524`](https://sepolia.basescan.org/address/0xEEceD3e2aE266B46dEcc1627D31855CdCDB02524)

## Security Considerations

1. **Signature Malleability**: Implement checks against signature replay attacks
2. **Gas Costs**: Validation logic should be gas-efficient
3. **Access Control**: Properly manage who can update signature validation logic
4. **Upgrade Safety**: Consider implications of upgrading validation logic

## Resources

- [ERC-1271 Standard](https://eips.ethereum.org/EIPS/eip-1271)
- [OpenZeppelin Implementation](https://docs.openzeppelin.com/contracts/4.x/api/interfaces#IERC1271)
- [ERC-1271 Discussion](https://ethereum-magicians.org/t/erc-1271-standard-signature-validation-method-for-contracts/1258)

## License

MIT License