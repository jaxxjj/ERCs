// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../base/ERC4907.sol";

contract RentableNFT is ERC4907 {
    constructor() ERC4907("RentableNFT", "RNFT") {}

    function mint(address to, uint256 tokenId) external {
        _mint(to, tokenId);
    }

    function setUser(uint256 tokenId, address user, uint64 expires) public virtual override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC4907: caller is not token owner or approved");
        UserInfo storage info = _users[tokenId];
        info.user = user;
        info.expires = expires;
        emit UpdateUser(tokenId, user, expires);
    }

    function rentOut(
        uint256 tokenId,
        address renter,
        uint64 durationInSeconds
    ) external {
        require(ownerOf(tokenId) == msg.sender, "Not token owner");
        uint64 expires = uint64(block.timestamp + durationInSeconds);
        setUser(tokenId, renter, expires);
    }

    function isRented(uint256 tokenId) external view returns (bool) {
        if (uint256(_users[tokenId].expires) >= block.timestamp) {
            return _users[tokenId].user != address(0);
        }
        return false;
    }

    function getRemainingRentalTime(uint256 tokenId) external view returns (uint256) {
        uint256 expires = _users[tokenId].expires;
        if (expires < block.timestamp) {
            return 0;
        }
        return expires - block.timestamp;
    }
}