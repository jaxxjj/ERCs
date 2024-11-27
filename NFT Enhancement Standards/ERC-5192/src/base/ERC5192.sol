// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IERC5192.sol";
import "./ERC721.sol";

contract ERC5192 is ERC721, IERC5192 {
    // Mapping from token ID to locked status
    mapping(uint256 => bool) private _locked;
    
    // Error to be thrown when attempting to transfer a locked token
    error ErrSoulbound();

    constructor(string memory name_, string memory symbol_) 
        ERC721(name_, symbol_) 
    {}

    /**
     * @dev See {IERC5192-locked}.
     */
    function locked(uint256 tokenId) external view override returns (bool) {
        require(_exists(tokenId), "ERC5192: Query for nonexistent token");
        return _locked[tokenId];
    }

    /**
     * @dev Locks a token
     * @param tokenId The identifier for an NFT
     */
    function _lock(uint256 tokenId) internal virtual {
        _locked[tokenId] = true;
        emit Locked(tokenId);
    }

    /**
     * @dev Unlocks a token
     * @param tokenId The identifier for an NFT
     */
    function _unlock(uint256 tokenId) internal virtual {
        _locked[tokenId] = false;
        emit Unlocked(tokenId);
    }

    /**
     * @dev Override ERC721 transfer functions to implement soulbound behavior
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        if (_locked[tokenId]) revert ErrSoulbound();
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        if (_locked[tokenId]) revert ErrSoulbound();
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        if (_locked[tokenId]) revert ErrSoulbound();
        super.safeTransferFrom(from, to, tokenId, data);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC5192).interfaceId;
    }
}