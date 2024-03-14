// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../src/NFTEscrow.sol";

contract TestToken is ERC721 {
    constructor() ERC721("TestToken", "TST") {}

    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }
}

contract NFTEscrowTest is Test {
    NFTEscrow escrow;
    TestToken testToken;
    address seller = address(this);
    address buyer = address(0xBEEF);
    address randomUser = address(0xCAFE);
    uint256 tokenId = 1;
    uint256 price = 1 ether;

    function setUp() public {
        escrow = new NFTEscrow();
        testToken = new TestToken();
        testToken.mint(seller, tokenId);
        testToken.approve(address(escrow), tokenId);
    }

    function testNFTDeposit() public {
        vm.prank(seller);
        escrow.depositNFT(address(testToken), tokenId, buyer, price);

        // Assuming your contract keeps track of sales info,
        // and you have a function to retrieve it.
        (address _seller, address _buyer, uint256 _price) = escrow.sales(address(testToken), tokenId);
        assertEq(_seller, seller, "Seller mismatch");
        assertEq(_buyer, buyer, "Buyer mismatch");
        assertEq(_price, price, "Price mismatch");
    }

    function testNFTPurchase() public {
        testNFTDeposit(); // First, deposit the NFT

        vm.prank(buyer);
        vm.deal(buyer, price);
        escrow.buyNFT{value: price}(address(testToken), tokenId);

        // Check if the buyer is now the owner
        assertEq(testToken.ownerOf(tokenId), buyer, "Buyer should now own the NFT");
    }

    function testUnauthorizedPurchaseAttempt() public {
        testNFTDeposit(); // First, deposit the NFT

        vm.prank(randomUser);
        vm.expectRevert("You are not the designated buyer.");
        escrow.buyNFT{value: price}(address(testToken), tokenId);
    }

    // Additional tests as needed...
}

