// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "../src/NFTEscrow.sol";

contract MockERC721 is ERC721 {
    constructor(
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) {}

    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }
}

contract NFTEscrowTest is Test {
    NFTEscrow escrow;
    MockERC721 nft;
    address seller;
    address buyer;

    uint256 internal privateKey;

    function setUp() public {
        // Deploy the mock NFT contract
        nft = new MockERC721("TestNFT", "TNFT");
        // Deploy the escrow contract
        escrow = new NFTEscrow();
        // Define seller and buyer addresses
        privateKey = 0xabc123;
        seller = vm.addr(privateKey);

        buyer = address(0x2);
        vm.deal(buyer, 10 ether); // Ensure the buyer has enough Ether

        // Mint an NFT to the seller
        nft.mint(seller, 1);
        // Approve the escrow contract to transfer NFTs on behalf of the seller
        vm.prank(seller);
        nft.approve(address(escrow), 1);
    }

    function testBuyNFT() public {
        // Seller signs the sale details
        bytes32 messageHash = keccak256(
            abi.encodePacked(
                nft,
                uint256(1),
                uint256(1 ether),
                uint256(block.timestamp + 1 days),
                uint256(123),
                buyer
            )
        );
        bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(
            messageHash
        );

        console.log("Seller address:");
        console.logAddress(seller);
        console.log("Message hash:");
        console.logBytes32(messageHash);
        console.log("eth hash");
        console.logBytes32(ethSignedMessageHash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            privateKey,
            ethSignedMessageHash
        );
        console.log("v");
        console.log(v);
        bytes memory signature = abi.encodePacked(r, s, v);
        console.log("Signature:");
        console.logBytes(signature);
        vm.prank(buyer);
        escrow.buyNFT{value: 1 ether}(
            address(nft),
            uint256(1),
            uint256(1 ether),
            uint256(block.timestamp + 1 days),
            uint256(123),
            signature
        );

        // Asserts
    }
}
