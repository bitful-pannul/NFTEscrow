// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/NFTEscrow.sol"; // Update this path to the actual path of your NFTEscrow contract
import "../src/IERC721.sol"; // Update this path as needed

contract MockERC721 is IERC721 {
    mapping(uint256 => address) private _owners;

    function transferFrom(address from, address to, uint256 tokenId) external override {
        require(_owners[tokenId] == from, "Not the owner");
        _owners[tokenId] = to;
        emit Transfer(from, to, tokenId);
    }

    function mint(address to, uint256 tokenId) public {
        _owners[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
    }
}

contract NFTEscrowTest is Test {
    NFTEscrow escrow;
    MockERC721 nft;

    address seller = address(1);
    address buyer = address(2);
    uint256 tokenId = 1;
    uint256 price = 1 ether;

    function setUp() public {
        escrow = new NFTEscrow();
        nft = new MockERC721();
        nft.mint(seller, tokenId);
        vm.startPrank(seller);
        nft.approve(address(escrow), tokenId);
        vm.stopPrank();
    }

    function testDepositNFT() public {
        vm.startPrank(seller);
        escrow.depositNFT(address(nft), tokenId, buyer, price);
        vm.stopPrank();

        // Verify the deposit
        (address actualSeller, address actualBuyer, uint256 actualPrice) = escrow.sales(address(nft), tokenId);
        assertEq(actualSeller, seller);
        assertEq(actualBuyer, buyer);
        assertEq(actualPrice, price);
    }

    function testBuyNFT() public {
        // First, deposit the NFT
        vm.startPrank(seller);
        escrow.depositNFT(address(nft), tokenId, buyer, price);
        vm.stopPrank();

        // Now, simulate the buyer buying the NFT
        vm.startPrank(buyer);
        vm.deal(buyer, price);
        escrow.buyNFT{value: price}(address(nft), tokenId);
        vm.stopPrank();

        // Verify the buyer now owns the NFT
        // This would require implementing a `ownerOf` function in MockERC721 or asserting via events
    }

    function testWithdrawNFT() public {
        // Deposit the NFT first
        vm.startPrank(seller);
        escrow.depositNFT(address(nft), tokenId, buyer, price);
        vm.stopPrank();

        // Withdraw the NFT
        vm.startPrank(seller);
        escrow.withdrawNFT(address(nft), tokenId);
        vm.stopPrank();

        // Verify the withdrawal
        // This would require implementing a `ownerOf` function in MockERC721 or asserting via events
    }
}

