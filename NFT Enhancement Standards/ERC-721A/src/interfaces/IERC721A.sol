// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC721A {
    // Errors
    error TokenAlreadyMinted();
    error ApprovalCallerNotOwnerNorApproved();
    error ApprovalQueryForNonexistentToken();
    error ApprovalToCurrentOwner();
    error ApproveToCaller();
    error BalanceQueryForZeroAddress();
    error MintToZeroAddress();
    error MintZeroQuantity();
    error OwnerQueryForNonexistentToken();
    error TransferCallerNotOwnerNorApproved();
    error TransferFromIncorrectOwner();
    error TransferToNonERC721ReceiverImplementer();
    error TransferToZeroAddress();
    error URIQueryForNonexistentToken();

    // Events (from ERC721 standard)
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    // Read Functions
    
    /**
     * @dev Returns the total number of tokens in existence.
     * Burned tokens will reduce the count.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the number of tokens in `owner`'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     * Requirements:
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    /**
     * @dev Returns the account approved for `tokenId` token.
     * Requirements:
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);

    // Write Functions
    
    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * Requirements:
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call transferFrom or safeTransferFrom for any token owned by the caller.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     * Requirements:
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     * Requirements:
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token.
     * - If `to` refers to a smart contract, it must implement ERC721Receiver.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Same as safeTransferFrom without data parameter
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    // ERC721A Specific Functions

    /**
     * @dev Returns the next token ID to be minted.
     */
    function _currentIndex() external view returns (uint256);

    /**
     * @dev Returns the total amount of tokens minted in the contract.
     */
    function _totalMinted() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens burned.
     */
    function _totalBurned() external view returns (uint256);
}