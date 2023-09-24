// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract CredentialNFT is ERC721Enumerable, Ownable {
    using Strings for uint256;

    // Mapping from token ID to NFT type (e.g., "studio", "wood", "metal")
    mapping(uint256 => string) private _nftTypes;

    // Mapping from NFT type to the associated IPFS image URL
    mapping(string => string) private _typeToImageUrl;

    // Mapping from user address to the permit list for each NFT type
    mapping(string => mapping(address => bool)) private _permitList;

    // Base URI for metadata (can be a URL or IPFS hash)
    string private _baseTokenURI;

    constructor(string memory _name, string memory _symbol, string memory baseURI) ERC721(_name, _symbol) {
        _baseTokenURI = baseURI;
    }

    // Set the base URI for metadata
    function setBaseTokenURI(string memory baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    // Get the base URI for metadata
    function baseTokenURI() public view returns (string memory) {
        return _baseTokenURI;
    }

    // Mint a new Credential NFT of a specific type
    function mint(
        address to,
        uint256 tokenId,
        string memory nftType
    ) external onlyPermitted(nftType) onlyOwner {
        _mint(to, tokenId);
        _nftTypes[tokenId] = nftType;
    }

    // Associate an image URL with an NFT type (IPFS information)
    function associateImage(string memory nftType, string memory imageUrl) external onlyOwner {
        _typeToImageUrl[nftType] = imageUrl;
    }

    // Check if a user is permitted to mint a specific NFT type
    function isPermitted(string memory nftType, address user) external view returns (bool) {
        return _permitList[nftType][user];
    }

    // Add a user to the permit list for a specific NFT type
    function addToPermitList(string memory nftType, address user) external onlyOwner {
        _permitList[nftType][user] = true;
    }

    // Remove a user from the permit list for a specific NFT type
    function removeFromPermitList(string memory nftType, address user) external onlyOwner {
        _permitList[nftType][user] = false;
    }

    // Get the NFT type for a Credential NFT
    function getNFTType(uint256 tokenId) external view returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        return _nftTypes[tokenId];
    }

    // Get the associated image URL for an NFT type
    function getImageUrl(string memory nftType) external view returns (string memory) {
        return _typeToImageUrl[nftType];
    }

    // Returns the URI for a token ID
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        return string(abi.encodePacked(baseTokenURI(), tokenId.toString()));
    }

    // Modifier to ensure that only permitted users can mint an NFT of a specific type
    modifier onlyPermitted(string memory nftType) {
        require(_permitList[nftType][msg.sender], "Not permitted to mint this type");
        _;
    }
}
