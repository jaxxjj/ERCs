// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../base/ERC721.sol";

contract MyNFT is ERC721 {
    uint256 private s_tokenIds;
    
    constructor() ERC721("MyNFT", "MNFT") {
        s_tokenIds = 0;
    }
    
    function mint() public returns (uint256) {
        s_tokenIds += 1;
        _safeMint(msg.sender, s_tokenIds);
        return s_tokenIds;
    }
}