# ERC-165: Standard Interface Detection

ERC-165 is a standard for interface detection on the Ethereum blockchain. It enables smart contracts to declare which interfaces they support, allowing other contracts to query and verify interface compatibility before interaction.

## Key Functions

1. `supportsInterface(bytes4 interfaceId) external view returns (bool)`
   - Returns true if the contract implements the interface defined by `interfaceId`
   - The `interfaceId` is calculated as the XOR of all function selectors in the interface

## Use Cases

1. **Safe Contract Interaction**: Verify that a contract supports specific functionality before attempting to use it.

2. **Interface Verification**: Ensure NFT contracts properly implement required interfaces like ERC-721 or ERC-1155.

3. **Protocol Compatibility**: Check if contracts support necessary protocol interfaces before integration.

4. **Dynamic Functionality**: Enable contracts to adapt behavior based on supported interfaces.

5. **Security Checks**: Validate contract compatibility in security-critical operations.

## Implementation Example

```solidity
contract ExampleERC165 is IERC165 {
    // Interface ID for IERC165
    bytes4 private constant INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor() {
        // Register ERC165 interface
        _registerInterface(INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) 
        external 
        view 
        override 
        returns (bool) 
    {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff, "Invalid interface");
        _supportedInterfaces[interfaceId] = true;
    }
}
```

## Important Considerations

1. **Gas Efficiency**: 
   - Interface detection is designed to be gas-efficient
   - Use static calls when checking interfaces
   - Cache results when checking multiple times

2. **Interface Registration**:
   - Register interfaces during contract construction
   - Never register the 0xffffffff interface ID
   - Maintain accurate interface registrations

3. **Compatibility**:
   - Essential for NFT standards (ERC-721, ERC-1155)
   - Used by many protocol standards
   - Required for marketplace integrations

4. **Security**:
   - Don't rely solely on interface detection for security
   - Verify actual implementation behavior
   - Consider interface versioning

5. **Testing**:
   - Test both supported and unsupported interfaces
   - Verify correct interface registration
   - Check gas costs for interface detection

## Resources

- [EIP-165: Standard Interface Detection](https://eips.ethereum.org/EIPS/eip-165)
- [OpenZeppelin ERC165 Implementation](https://docs.openzeppelin.com/contracts/4.x/api/utils#ERC165)
- [Interface Detection Guide](https://docs.openzeppelin.com/contracts/4.x/api/utils#ERC165)

## License

MIT
