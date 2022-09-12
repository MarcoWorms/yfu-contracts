// SPDX-License-Identifier: GPL3
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract YFUtechne is ERC721, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    uint256 public MAX_SUPPLY = 10;
    uint256 public PRICE = 1 ether;
    address payable public depositAddress;
    bool public transfers_frozen = true;
    string public ipfsBaseURI;

    constructor(address payable adminAddress, string memory ipfsURI) ERC721("YFU Techne", "YFU_1") {
        ipfsBaseURI = ipfsURI;
        depositAddress = adminAddress;
    }

    function set_ipfs_base_uri(string memory ipfsURI) external onlyOwner {
        ipfsBaseURI = ipfsURI;
    }

    function set_deposit_address(address payable to) external onlyOwner {
        depositAddress = to;
    }

    function unfreeze_transfers() external onlyOwner {
        transfers_frozen = false;
    }

    function _baseURI() internal view override returns (string memory) {
        return ipfsBaseURI;
    }

    function safeMint(address to) external payable {
        require(_tokenIdCounter.current() < MAX_SUPPLY, "Maximum token supply reached");
        require(msg.value == PRICE, "Invalid amount");

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        depositAddress.call{value: balance}("");
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
    
}