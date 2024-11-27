ERC-777 Token Standard & Hook Implementations
Overview
ERC-777 is an advanced token standard that extends ERC-20 functionality with hooks - callbacks that execute when tokens are sent or received. This enables tokens to react to transfers, enabling more complex token behaviors while maintaining backwards compatibility with ERC-20.
Hook Mechanisms
TokenSender
Implements tokensToSend hook
Called before tokens leave an address
Can be used to validate/prepare for outgoing transfers
Must return successfully or transfer fails
TokenRecipient
Implements tokensReceived hook
Called after tokens arrive at an address
Can perform post-transfer logic
Must return successfully or transfer fails
Implementation Examples
Basic Recipient
}
2. Escrow Recipient
}
Rejecting Recipient
}
Security Considerations
1. Always register implementations with ERC1820 registry
2. Protect against reentrance attacks in hooks
Validate operators in sender hooks
Handle failed hook executions gracefully
Test hook behavior thoroughly before deployment
Key Benefits
Enhanced control over token movement
Ability to reject unwanted transfers
Complex token behaviors like escrow
Backwards compatibility with ERC-20
For implementation examples and testing, see the examples/ directory.
