// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/examples/SoulboundCertificate.sol";

contract SoulboundCertificateTest is Test {
    SoulboundCertificate public certificate;
    address public issuer = address(1);
    address public recipient = address(2);
    address public unauthorized = address(3);

    event Locked(uint256 tokenId);
    event Unlocked(uint256 tokenId);
    
    function setUp() public {
        vm.startPrank(issuer);
        certificate = new SoulboundCertificate();
        vm.stopPrank();
    }

    function testInitialState() public {
        assertEq(certificate.issuer(), issuer);
        assertEq(certificate.name(), "SoulboundCertificate");
        assertEq(certificate.symbol(), "CERT");
    }

    function testIssueCertificate() public {
        vm.startPrank(issuer);
        uint256 tokenId = certificate.issueCertificate(
            recipient,
            "Solidity 101",
            "A+"
        );
        vm.stopPrank();

        assertEq(certificate.ownerOf(tokenId), recipient);
        assertTrue(certificate.locked(tokenId));

        (string memory courseName, uint256 issueDate, string memory grade) = certificate.getCertificate(tokenId);
        assertEq(courseName, "Solidity 101");
        assertEq(issueDate, block.timestamp);
        assertEq(grade, "A+");
    }

    function testUnauthorizedIssuance() public {
        vm.startPrank(unauthorized);
        vm.expectRevert("Only issuer can call this function");
        certificate.issueCertificate(recipient, "Solidity 101", "A+");
        vm.stopPrank();
    }

    function testTokenURI() public {
        vm.startPrank(issuer);
        uint256 tokenId = certificate.issueCertificate(
            recipient,
            "Solidity 101",
            "A+"
        );
        vm.stopPrank();

        string memory expectedURI = string(abi.encodePacked("https://api.certificates.com/", tokenId));
        assertEq(certificate.tokenURI(tokenId), expectedURI);
    }

    function testFailTransferLockedToken() public {
        vm.startPrank(issuer);
        uint256 tokenId = certificate.issueCertificate(
            recipient,
            "Solidity 101",
            "A+"
        );
        vm.stopPrank();

        vm.startPrank(recipient);
        vm.expectRevert("Token is soul bound");
        certificate.transferFrom(recipient, unauthorized, tokenId);
        vm.stopPrank();
    }

    function testRevokeCertificate() public {
        vm.startPrank(issuer);
        uint256 tokenId = certificate.issueCertificate(
            recipient,
            "Solidity 101",
            "A+"
        );
        
        certificate.revokeCertificate(tokenId);
        vm.stopPrank();

        vm.expectRevert("ERC721: invalid token ID");
        certificate.ownerOf(tokenId);
    }

    function testUnauthorizedRevocation() public {
        vm.startPrank(issuer);
        uint256 tokenId = certificate.issueCertificate(
            recipient,
            "Solidity 101",
            "A+"
        );
        vm.stopPrank();

        vm.startPrank(unauthorized);
        vm.expectRevert("Only issuer can call this function");
        certificate.revokeCertificate(tokenId);
        vm.stopPrank();
    }

    function testMultipleCertificates() public {
        vm.startPrank(issuer);
        
        uint256 tokenId1 = certificate.issueCertificate(
            recipient,
            "Solidity 101",
            "A+"
        );

        uint256 tokenId2 = certificate.issueCertificate(
            recipient,
            "Smart Contract Security",
            "A"
        );

        vm.stopPrank();

        assertEq(certificate.ownerOf(tokenId1), recipient);
        assertEq(certificate.ownerOf(tokenId2), recipient);
        assertTrue(tokenId2 > tokenId1);

        (string memory courseName1,,) = certificate.getCertificate(tokenId1);
        (string memory courseName2,,) = certificate.getCertificate(tokenId2);
        
        assertEq(courseName1, "Solidity 101");
        assertEq(courseName2, "Smart Contract Security");
    }

    function testLockStatus() public {
        vm.startPrank(issuer);
        uint256 tokenId = certificate.issueCertificate(
            recipient,
            "Solidity 101",
            "A+"
        );
        vm.stopPrank();

        assertTrue(certificate.locked(tokenId));
    }
}