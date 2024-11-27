# ERC-20 Token Standard Implementation

A reference implementation of the ERC-20 token standard, following the [EIP-20](https://eips.ethereum.org/EIPS/eip-20) specification.

## Deployed Contracts

### Testnet Deployments

Sepolia (11155111): 
- MyToken deployed at: [0x56e0E9773D23E8AA4e722b5C2a71B11ad70deD4D](https://sepolia.etherscan.io/address/0x56e0E9773D23E8AA4e722b5C2a71B11ad70deD4D)

Arbitrum Sepolia (421611):
- MyToken deployed at: [0x33322659739034C907FC25102d79eF4b4F285ff4](https://sepolia.arbiscan.io/address/0x33322659739034C907FC25102d79eF4b4F285ff4)

Base Sepolia (84632):
- MyToken deployed at: [0xD4BE463d1f9f0e974f3265ED63c793a582b2e123](https://sepolia.basescan.org/address/0xD4BE463d1f9f0e974f3265ED63c793a582b2e123)

## Development

### Prerequisites

- [Git](https://git-scm.com/)
- [Foundry](https://book.getfoundry.sh/getting-started/installation)

### Setup

1. Clone the repository
2. Install dependencies:
```bash
forge install
```

3. Copy the environment file and configure it:
```bash
cp .env.example .env
```

### Testing

Run the test suite:

```bash
# Run basic tests
forge test

# Run with verbosity
forge test -vvv

# Run with gas reporting
forge test --gas-report
```

### Deployment

To deploy the contract:

```bash
forge script script/Deploy.s.sol --rpc-url <RPC_URL> --broadcast
```

## License

This project is licensed under the MIT License.



