// SPDX-License-Identifier: GPL3
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract YFUtechne is ERC721, AccessControl {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    uint256 public MAX_SUPPLY = 10;
    uint256 public PRICE = 1 ether;
    address payable public depositAddress;
    bool public transfers_frozen = true;
    string public uri = "https://ipfs.io/ipfs/QmSt5CVksdLfvaDCHwPvTGtXs7YrSGcQ2raE3M9nXPifZH/";

    constructor(address payable adminAddress) ERC721("YFU Techne", "YFU_1") {
        depositAddress = adminAddress;
        _grantRole(DEFAULT_ADMIN_ROLE, adminAddress);
    }

    function set_base_uri(string memory newUri) public onlyRole(DEFAULT_ADMIN_ROLE) {
        uri = newUri;
    }

    function set_deposit_address(address payable to) public onlyRole(DEFAULT_ADMIN_ROLE) {
        depositAddress = to;
    }

    function unfreeze_transfers() public onlyRole(DEFAULT_ADMIN_ROLE) {
        transfers_frozen = false;
    }

    function _baseURI() internal view override returns (string memory) {
        return uri;
    }

    function safeMint(address to) public payable {
        require(_tokenIdCounter.current() < MAX_SUPPLY, "Maximum token supply reached");
        require(msg.value == PRICE, "Invalid amount");

        depositAddress.transfer(PRICE);

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721)
    {
        // if transfer comes from 0 it means it's a mint and we dont want to freeze mints when only transfers are fronzen, so we skip the require
        if (address(0) == from) {
            return;
        }
        require(!transfers_frozen, "Transfers are paused");
    }
    
    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}