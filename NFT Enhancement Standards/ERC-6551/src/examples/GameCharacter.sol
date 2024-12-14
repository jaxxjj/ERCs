// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../lib/Counters.sol";
import "../interfaces/IERC6551Registry.sol";

contract GameCharacter is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    IERC6551Registry public immutable registry;
    address public immutable implementation;

    // Character stats
    mapping(uint256 => uint256) public level;
    mapping(uint256 => uint256) public experience;

    constructor(address _registry, address _implementation) ERC721("GameCharacter", "CHAR") {
        registry = IERC6551Registry(_registry);
        implementation = _implementation;
    }

    function mintCharacter() public returns (uint256) {
        _tokenIds.increment();
        uint256 newCharacterId = _tokenIds.current();
        
        _mint(msg.sender, newCharacterId);
        
        // Create token bound account for the character
        registry.createAccount(
            implementation,
            bytes32(block.chainid),
            uint256(uint160(address(this))),
            address(uint160(newCharacterId)),
            uint256(0)
        );

        level[newCharacterId] = 1;
        experience[newCharacterId] = 0;

        return newCharacterId;
    }

    function getTokenBoundAccount(uint256 tokenId) public view returns (address) {
        return registry.account(
            implementation,
            bytes32(block.chainid),
            uint256(uint160(address(this))),
            address(uint160(tokenId)),
            uint256(0)
        );
    }
}