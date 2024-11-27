// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IERC4907.sol";
import "../base/ERC721.sol";

contract ERC4907 is ERC721, IERC4907 {
    struct UserInfo {
        address user;   // address of user role
        uint64 expires; // unix timestamp when user role expires
    }

    mapping(uint256 => UserInfo) internal _users;

    constructor(string memory name_, string memory symbol_) 
        ERC721(name_, symbol_) 
    {}

    /**
     * @dev See {IERC4907-setUser}.
     */
    function setUser(uint256 tokenId, address user, uint64 expires) external virtual override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC4907: caller is not token owner or approved");
        UserInfo storage info = _users[tokenId];
        info.user = user;
        info.expires = expires;
        emit UpdateUser(tokenId, user, expires);
    }

    /**
     * @dev See {IERC4907-userOf}.
     */
    function userOf(uint256 tokenId) external view virtual override returns (address) {
        if (uint256(_users[tokenId].expires) >= block.timestamp) {
            return _users[tokenId].user;
        }
        return address(0);
    }

    /**
     * @dev See {IERC4907-userExpires}.
     */
    function userExpires(uint256 tokenId) external view virtual override returns (uint256) {
        return _users[tokenId].expires;
    }

    /**
     * @dev Hook that is called before any token transfer.
     * Resets user info when token is transferred.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal virtual {
        // Reset user info if the token is being transferred to a new owner
        if (from != to && _users[tokenId].user != address(0)) {
            delete _users[tokenId];
            emit UpdateUser(tokenId, address(0), 0);
        }

        // Implement any additional transfer logic here if needed
        // For example, you might want to check if the transfer is allowed
        // or perform any other operations before the transfer
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC4907).interfaceId;
    }
}