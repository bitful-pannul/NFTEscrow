// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTEscrow {
    struct Sale {
        address seller;
        address buyer;
        uint256 price;
    }

    mapping(address => mapping(uint256 => Sale)) public sales;

    event NFTDeposited(address indexed nftAddress, uint256 indexed tokenId, address indexed seller, address buyer, uint256 price);
    event NFTPurchased(address indexed nftAddress, uint256 indexed tokenId, address indexed buyer, uint256 price);
    event NFTWithdrawn(address indexed nftAddress, uint256 indexed tokenId, address indexed seller);
    event SaleUpdated(address indexed nftAddress, uint256 indexed tokenId, address newBuyer, uint256 newPrice);

    /**
     * @dev Allows a seller to deposit an NFT into the escrow contract and list it for sale to a specific buyer at a specified price.
     * @param nftAddress The address of the NFT contract.
     * @param tokenId The token ID of the NFT to be sold.
     * @param buyer The designated buyer's address.
     * @param price The sale price of the NFT.
     */
    function depositNFT(address nftAddress, uint256 tokenId, address buyer, uint256 price) external {
        IERC721(nftAddress).transferFrom(msg.sender, address(this), tokenId);
        sales[nftAddress][tokenId] = Sale(msg.sender, buyer, price);

        emit NFTDeposited(nftAddress, tokenId, msg.sender, buyer, price);
    }

    /**
     * @dev Allows the designated buyer to purchase the NFT by sending the correct amount of ETH.
     * @param nftAddress The address of the NFT contract.
     * @param tokenId The token ID of the NFT being purchased.
     */
    function buyNFT(address nftAddress, uint256 tokenId) external payable {
        Sale memory sale = sales[nftAddress][tokenId];
        require(msg.sender == sale.buyer, "You are not the designated buyer.");
        require(msg.value >= sale.price, "Insufficient funds sent.");

        IERC721(nftAddress).transferFrom(address(this), msg.sender, tokenId);
        payable(sale.seller).transfer(sale.price);

        delete sales[nftAddress][tokenId];

        emit NFTPurchased(nftAddress, tokenId, msg.sender, sale.price);
    }

    /**
     * @dev Allows a seller to withdraw their NFT from the escrow if it has not been sold.
     * @param nftAddress The address of the NFT contract.
     * @param tokenId The token ID of the NFT being withdrawn.
     */
    function withdrawNFT(address nftAddress, uint256 tokenId) external {
        Sale memory sale = sales[nftAddress][tokenId];
        require(msg.sender == sale.seller, "Only the seller can withdraw the NFT.");

        IERC721(nftAddress).transferFrom(address(this), msg.sender, tokenId);
        delete sales[nftAddress][tokenId];

        emit NFTWithdrawn(nftAddress, tokenId, msg.sender);
    }

    /**
     * @dev Allows the seller to change the buyer and the price for an NFT sale.
     * @param nftAddress The address of the NFT contract.
     * @param tokenId The token ID of the NFT.
     * @param newBuyer The new buyer's address.
     * @param newPrice The new price for the NFT.
     */
    function updateSaleDetails(address nftAddress, uint256 tokenId, address newBuyer, uint256 newPrice) public {
        Sale storage sale = sales[nftAddress][tokenId];

        // Check that the caller is the seller of the NFT
        require(msg.sender == sale.seller, "Only the seller can update the sale details.");

        // Check that the NFT is still in escrow (hasn't been sold)
        // This could be a specific check depending on how you handle NFT transfers
        // For simplicity, we're just ensuring the buyer is not address(0) or checking another condition
        require(sale.buyer != address(0), "NFT is not listed for sale.");

        // Update the sale details
        sale.buyer = newBuyer;
        sale.price = newPrice;

        // Emit an event if you have event definitions for sale updates
        emit SaleUpdated(nftAddress, tokenId, newBuyer, newPrice);
    }
}

