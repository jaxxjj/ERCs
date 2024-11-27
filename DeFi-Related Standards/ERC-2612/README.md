# ERC-2612: Permit Extension for ERC-20 Tokens

ERC-2612 extends ERC-20 tokens by adding a `permit` function that allows users to modify the allowance mapping using a signed message instead of calling `approve` directly. This enables gasless token approvals and enhanced UX.

## Key Features

1. **Gasless Approvals**: 
   - Users can sign permit messages offline
   - Relayers can submit transactions
   - No ETH needed for approvals

2. **Enhanced Security**:
   - Signed messages include deadline
   - Nonce prevents replay attacks
   - EIP-712 typed data signing

## Core Functions

1. `permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)`
   - Sets allowance through signed permit
   - Validates signature and deadline
   - Updates nonce after use

2. `nonces(address owner) → uint256`
   - Returns current nonce for owner
   - Used in permit signature generation

3. `DOMAIN_SEPARATOR() → bytes32`
   - Returns domain separator for EIP-712
   - Chain-specific to prevent cross-chain replays

## Use Cases

1. **DeFi Applications**:
   - One-click token approvals
   - Meta-transactions
   - Batched operations

2. **Gasless Transactions**:
   - Relayer networks
   - Sponsored transactions
   - UX improvements

3. **Smart Contract Integration**:
   - Atomic multi-step operations
   - Delegated token operations
   - Protocol automation

## Implementation Example

```solidity
contract PermitToken is ERC2612 {
    constructor() ERC2612("PermitToken", "PT") {
        _mint(msg.sender, 1000000 * 10**18);
    }
}

contract PermitExample {
    function transferWithPermit(
        address from,
        address to,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        token.permit(from, address(this), amount, deadline, v, r, s);
        token.transferFrom(from, to, amount);
    }
}
```

## Deployment

### Sepolia (11155111)
- PermitToken deployed at: [0xA5857c4b9730D159a2bC0c3De1B024780ff2aF69](https://sepolia.etherscan.io/address/0xA5857c4b9730D159a2bC0c3De1B024780ff2aF69)

### Arbitrum Sepolia (421611)
- PermitToken deployed at: [0x245ebb6F737A09E5C9A4C27498510930102aAD27](https://sepolia.arbiscan.io/address/0x245ebb6F737A09E5C9A4C27498510930102aAD27)

### Base Sepolia (84632)
- PermitToken deployed at: [0xcE6703F261ed4888EFEcF772f519C0971044F15F](https://sepolia.basescan.org/address/0xcE6703F261ed4888EFEcF772f519C0971044F15F)

## Important Considerations

1. **Signature Validation**:
   - EIP-712 structured data
   - Deadline validation
   - Nonce management

2. **Gas Efficiency**:
   - Optimized storage layout
   - Minimal state changes
   - Efficient signature verification

3. **Security**:
   - Replay protection
   - Deadline enforcement
   - Chain ID validation

4. **Integration**:
   - Wallet support required
   - Relayer infrastructure
   - Front-end considerations

## Events

1. `Approval(address indexed owner, address indexed spender, uint256 value)`
   - Emitted when allowance is modified
   - Includes permit-based approvals

## Resources

- [EIP-2612: Permit Extension for ERC-20 Tokens](https://eips.ethereum.org/EIPS/eip-2612)
- [EIP-712: Typed structured data hashing and signing](https://eips.ethereum.org/EIPS/eip-712)
- [ERC-20 Standard](https://eips.ethereum.org/EIPS/eip-20)
