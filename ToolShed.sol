// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ToolToken is ERC721Enumerable, Ownable {
    // Mapping from token ID to tool name
    mapping(uint256 => string) private _toolNames;

    // Mapping from tool name to token ID
    mapping(string => uint256) private _toolNameToId;

    // Credential NFT required for borrowing tools
    address public credentialNFT;

    constructor(string memory _name, string memory _symbol, address _credentialNFT) ERC721(_name, _symbol) {
        credentialNFT = _credentialNFT;
    }

    // Mint a new tool NFT
    function mintTool(address owner, string memory toolName) external onlyOwner {
        require(!_exists(_toolNameToId[toolName]), "Tool with the same name already exists");
        uint256 tokenId = totalSupply() + 1;
        _mint(owner, tokenId);
        _toolNames[tokenId] = toolName;
        _toolNameToId[toolName] = tokenId;
    }

    // Borrow a tool by transferring ownership
    function borrowTool(uint256 tokenId) external {
        require(_exists(tokenId), "Tool does not exist");
        require(msg.sender != ownerOf(tokenId), "You already own this tool");
        require(credentialNFT != address(0), "Credential NFT contract not set");
        require(IERC721(credentialNFT).balanceOf(msg.sender) > 0, "You don't have the required credential");

        // Transfer ownership of the tool NFT
        transferFrom(ownerOf(tokenId), msg.sender, tokenId);
    }

    // Return a borrowed tool to the contract owner
    function returnTool(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "You don't own this tool");
        _transfer(msg.sender, owner(), tokenId);
    }

    // Get the name of a tool by its token ID
    function getToolName(uint256 tokenId) external view returns (string memory) {
        require(_exists(tokenId), "Tool does not exist");
        return _toolNames[tokenId];
    }
}
