// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721 {
    function transferFrom(address from, address to, uint256 tokenId) external;
}

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

    function depositNFT(address nftAddress, uint256 tokenId, address buyer, uint256 price) external {
        IERC721(nftAddress).transferFrom(msg.sender, address(this), tokenId);
        sales[nftAddress][tokenId] = Sale(msg.sender, buyer, price);

        emit NFTDeposited(nftAddress, tokenId, msg.sender, buyer, price);
    }

    function buyNFT(address nftAddress, uint256 tokenId) external payable {
        Sale memory sale = sales[nftAddress][tokenId];
        require(msg.sender == sale.buyer, "You are not the designated buyer.");
        require(msg.value >= sale.price, "Insufficient funds sent.");

        IERC721(nftAddress).transferFrom(address(this), msg.sender, tokenId);
        payable(sale.seller).transfer(sale.price);

        delete sales[nftAddress][tokenId];

        emit NFTPurchased(nftAddress, tokenId, msg.sender, sale.price);
    }

    function withdrawNFT(address nftAddress, uint256 tokenId) external {
        Sale memory sale = sales[nftAddress][tokenId];
        require(msg.sender == sale.seller, "Only the seller can withdraw the NFT.");

        IERC721(nftAddress).transferFrom(address(this), msg.sender, tokenId);
        delete sales[nftAddress][tokenId];

        emit NFTWithdrawn(nftAddress, tokenId, msg.sender);
    }
}

