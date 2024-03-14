// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract NFTEscrow {
    event NFTPurchased(
        address indexed nftAddress,
        uint256 indexed tokenId,
        address indexed buyer,
        uint256 price
    );

    mapping(uint256 => bool) private usedUIDs;

    /**
     * @dev Completes the purchase of an NFT based on a signed message from the seller,
     * validating the sale terms (including price) against the provided signature.
     * @param nftAddress The address of the NFT contract.
     * @param tokenId The token ID of the NFT being purchased.
     * @param price The agreed sale price of the NFT.
     * @param uid A unique identifier for this specific sale.
     * @param signature The seller's signature over the sale terms, including the price and UID.
     */
    function buyNFT(
        address nftAddress,
        uint256 tokenId,
        uint256 price,
        uint256 uid,
        bytes memory signature
    ) external payable {
        require(msg.value >= price, "Sent value does not meet the sale price.");

        require(!usedUIDs[uid], "UID has already been used");
        usedUIDs[uid] = true;

        // Construct the signed message from sale details, including the price and uid
        bytes32 messageHash = keccak256(
            abi.encodePacked(nftAddress, tokenId, price, uid, msg.sender)
        );
        bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(
            messageHash
        );

        // Recover the seller's address from the signature
        address recoveredSeller = ECDSA.recover(
            ethSignedMessageHash,
            signature
        );

        // Verify the recovered address is the seller

        // Transfer the NFT to the buyer
        IERC721(nftAddress).transferFrom(recoveredSeller, msg.sender, tokenId);

        // Transfer the sale amount to the seller
        payable(recoveredSeller).transfer(msg.value);

        emit NFTPurchased(nftAddress, tokenId, msg.sender, price);
    }
}
