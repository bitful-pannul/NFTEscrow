// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../src/NFTEscrow.sol";

contract NFTEscrowTest is Test {
    NFTEscrow escrow;
    ERC721 nft;

    function setUp() public {
        escrow = new NFTEscrow();
    }

    function testPlaceholder() public {}
}
