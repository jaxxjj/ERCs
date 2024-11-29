# ERC-2771: Meta Transaction Processor

## Overview

ERC-2771 is a standard for native meta-transaction functionality that enables gasless transactions through trusted forwarders. This implementation provides a secure way for contracts to accept meta-transactions, allowing users to interact with smart contracts without holding ETH for gas fees.

## Features

- Native meta-transaction support through trusted forwarders
- Gas fee abstraction for end users
- Secure message validation and signature verification
- Foundry-based testing suite
- Compatible with OpenZeppelin contracts

## Installation

```bash
forge install
```

## Architecture

### Components

1. **ERC2771Forwarder**
   - Validates and forwards meta-transactions
   - Maintains nonces for replay protection
   - Verifies signatures using EIP-712

2. **MetaTransactionProcessor**
   - Example implementation of a meta-transaction recipient
   - Handles both ETH and ERC20 token transfers
   - Integrates with ERC2771Context

### Flow

1. User signs a meta-transaction
2. Relayer submits the transaction to the forwarder
3. Forwarder validates and forwards the call
4. Target contract processes the meta-transaction

## Usage

### 1. Deploy Forwarder

```solidity
ERC2771Forwarder forwarder = new ERC2771Forwarder("MyForwarder");
```

### 2. Create Meta-Transaction Compatible Contract

```solidity
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";

contract YourContract is ERC2771Context {
    constructor(address trustedForwarder) ERC2771Context(trustedForwarder) {
        // Your constructor code
    }

    function yourFunction() external {
        address sender = _msgSender(); // Gets original sender
        // Your function code
    }
}
```

### 3. Process Meta-Transactions

```solidity
// Create meta-transaction request
ForwardRequestData memory request = processor.createMetaTransaction(
    from,
    to,
    value,
    gas,
    data,
    deadline
);

// Sign request (client-side)
bytes memory signature = signMetaTransaction(request);

// Process meta-transaction
processor.processMetaTransaction(request, signature);
```

## Testing

Run the test suite:

```bash
forge test
```

For detailed test output:

```bash
forge test -vvv
```

Generate gas reports:

```bash
forge test --gas-report
```

## Security Considerations

1. Only use trusted forwarders
2. Validate signatures carefully
3. Implement proper nonce management
4. Set reasonable deadlines
5. Consider front-running protection

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Resources

- [ERC-2771 Specification](https://eips.ethereum.org/EIPS/eip-2771)
- [OpenZeppelin Documentation](https://docs.openzeppelin.com/contracts/4.x/api/metatx)
- [Meta Transactions Guide](https://docs.openzeppelin.com/learn/sending-gasless-transactions)
