// SPDX-License-Identifier: GPL3
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract YFUtechne is ERC721, Ownable {

    uint256 constant internal MAX_SUPPLY = 10;
    uint256 constant internal PRICE = 1 ether;
    uint256 public tokenCount = 0;
    address payable public depositAddress;
    bool public transfers_frozen = true;
    string public ipfsBaseURI;
    mapping(address => mapping(uint256 => uint256)) private _initialOwners;

    constructor(address payable adminAddress, string memory ipfsURI) ERC721("YFU Techne", "YFU_1") {
        ipfsBaseURI = ipfsURI;
        depositAddress = adminAddress;
    }

    function setIpfsBaseUri(string memory ipfsURI) external onlyOwner {
        ipfsBaseURI = ipfsURI;
    }

    function setDepositAddress(address payable to) external onlyOwner {
        depositAddress = to;
    }

    function unfreezeTransfers() external onlyOwner {
        transfers_frozen = false;
    }

    function _baseURI() internal view override returns (string memory) {
        return ipfsBaseURI;
    }

    function safeMint(address to) external payable {
        require(tokenCount < MAX_SUPPLY, "Maximum token supply reached");
        require(msg.value == PRICE, "Invalid amount");
        tokenCount = tokenCount + 1;
        _addTokenToInitialOwner(to, tokenCount);
        _safeMint(to, tokenCount);
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        (bool success, ) = depositAddress.call{value: balance}("");
        require (success, "ETH transfer failed");
    }

    function withdrawTokens(IERC20 token) external onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        require(token.transfer(depositAddress, balance));
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721)
        view
    {
        // if transfer comes from 0 it means it's a mint and we dont want to freeze mints when only transfers are fronzen, so we skip the require
        if (address(0) == from) {
            return;
        }
        require(!transfers_frozen, "Transfers are paused");
    }
    
    function _addTokenToInitialOwner(address to, uint256 tokenId) private {
        uint256 length = balanceOf(to);
        _initialOwners[to][length] = tokenId;
    }

    function tokenOfInitialOwner(address owner, uint256 index) public view returns (uint256) {
        require(index < balanceOf(owner), "index out of bounds");
        return _initialOwners[owner][index];
    }

}
