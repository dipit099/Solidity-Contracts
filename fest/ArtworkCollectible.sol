// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ArtworkCollectible is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    constructor(address initialOwner)
        ERC721("ArtworkCollectible", "AC")
        Ownable(initialOwner)  ///must ensure this !!!
    {}

    struct Certificate {
        uint256 tokenId;
        string tokenURI;
        uint256 issueTime;
        bool isIssued;
        bool isTransferable;
    }

    mapping(uint256 => Certificate) public certificates;

    function issueCertificate(
        address recipient,
        string memory tokenURI
    ) external onlyOwner {
        uint256 newTokenId = _tokenIdCounter.current();
        _safeMint(recipient, newTokenId);
        certificates[newTokenId] = Certificate(
            newTokenId,
            tokenURI,
            block.timestamp,
            true,
            false
        );
        _tokenIdCounter.increment();
    }

    function setTransferable(
        uint256 tokenId,
        bool isTransferable
    ) external onlyOwner {
        require(ownerOf(tokenId)!= address(0), "Token does not exist");
        certificates[tokenId].isTransferable = isTransferable;
    }

    function gettokenURI(
        uint256 tokenId
    ) public view virtual returns (string memory) {
        //require(_requireOwned(tokenId));
       require(ownerOf(tokenId)!= address(0),"ERC721Metadata: URI query for nonexistent token" );
        return certificates[tokenId].tokenURI;
    }

    function transferFromCustom(
        address from,
        address to,
        uint256 tokenId
    ) public  {
        require(
            msg.sender == ownerOf(tokenId) &&
                certificates[tokenId].isTransferable,
            "Transfers not allowed for this token."
        );
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFromCustom(
        address from,
        address to,
        uint256 tokenId
    ) public  {
        require(
            msg.sender == ownerOf(tokenId) &&
                certificates[tokenId].isTransferable,
            "Transfers not allowed for this token."
        );
        super.safeTransferFrom(from, to, tokenId); //calling erc721 functions!!
    }

    
}
