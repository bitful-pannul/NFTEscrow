// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "../src/NFTEscrow.sol";

contract NFTEscrowTest is Test {
    function testEncodeAndHash() public {
        address nftAddress = address(
            0x123456789ABcDef1234567890AbCdeF123456789
        );

        uint256 tokenId = 1;
        uint256 price = 1 ether;
        uint256 uid = 999;
        address buyer = address(0x987654321ABcdEF9876543210abCDEf987654321);
        bytes32 messageHash = keccak256(
            abi.encodePacked(nftAddress, tokenId, price, uid, buyer)
        );

        bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(
            messageHash
        );

        // Print the results
        console.logBytes32(messageHash);
        console.logBytes32(ethSignedMessageHash);
    }
}
