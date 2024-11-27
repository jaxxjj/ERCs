// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../base/ERC5192.sol";

contract SoulboundCertificate is ERC5192 {
    // Certificate metadata
    struct Certificate {
        string courseName;
        uint256 issueDate;
        string grade;
    }
    
    // Mapping from token ID to certificate details
    mapping(uint256 => Certificate) private _certificates;
    
    // Address of the certificate issuer
    address public issuer;
    
    // Counter for certificate IDs
    uint256 private _nextCertificateId;

    constructor() ERC5192("SoulboundCertificate", "CERT") {
        issuer = msg.sender;
    }

    modifier onlyIssuer() {
        require(msg.sender == issuer, "Only issuer can call this function");
        _;
    }

    /**
     * @dev Issues a new certificate to a recipient
     */
    function issueCertificate(
        address recipient,
        string memory courseName,
        string memory grade
    ) external onlyIssuer returns (uint256) {
        uint256 newCertificateId = _nextCertificateId++;
        
        _mint(recipient, newCertificateId);
        _lock(newCertificateId);
        
        _certificates[newCertificateId] = Certificate({
            courseName: courseName,
            issueDate: block.timestamp,
            grade: grade
        });

        return newCertificateId;
    }

    /**
     * @dev Gets certificate details
     */
    function getCertificate(uint256 tokenId) 
        external 
        view 
        returns (
            string memory courseName,
            uint256 issueDate,
            string memory grade
        ) 
    {
        require(_exists(tokenId), "Certificate does not exist");
        Certificate memory cert = _certificates[tokenId];
        return (cert.courseName, cert.issueDate, cert.grade);
    }

    /**
     * @dev Returns the token URI for a given token ID
     */
    function tokenURI(uint256 tokenId) 
        public 
        view 
        virtual  
        returns (string memory) 
    {
        require(_exists(tokenId), "Certificate does not exist");
        // In a real implementation, you would generate dynamic metadata here
        return string(abi.encodePacked("https://api.certificates.com/", tokenId));
    }

    /**
     * @dev Allow issuer to revoke certificates if necessary
     */
    function revokeCertificate(uint256 tokenId) external onlyIssuer {
        require(_exists(tokenId), "Certificate does not exist");
        _burn(tokenId);
    }
}