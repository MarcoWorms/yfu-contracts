// SPDX-License-Identifier: GPL3
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract YFUtechne is ERC721, Pausable, AccessControl {
    using Counters for Counters.Counter;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant TRANSFER_FREEZER_ROLE = keccak256("TRANSFER_FREEZER_ROLE");
    Counters.Counter private _tokenIdCounter;

    uint256 public MAX_SUPPLY = 10;
    uint256 public PRICE = 1 ether;
    address payable public depositAddress;
    bool public transfers_frozen = true;

    constructor() ERC721("YFU Techne", "YFU_1") {
        depositAddress = payable(msg.sender);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(TRANSFER_FREEZER_ROLE, msg.sender);
    }

    function _baseURI() internal view override returns (string memory) {
        return "https://ipfs.io/ipfs/QmSt5CVksdLfvaDCHwPvTGtXs7YrSGcQ2raE3M9nXPifZH";
    }

    function setDepositAddress(address payable to) public onlyRole(DEFAULT_ADMIN_ROLE) {
        depositAddress = to;
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function freeze_transfers() public onlyRole(TRANSFER_FREEZER_ROLE) {
        transfers_frozen = true;
    }

    function unfreeze_transfers() public onlyRole(TRANSFER_FREEZER_ROLE) {
        transfers_frozen = false;
    }

    function safeMint(address to) public whenNotPaused payable {
        require(_tokenIdCounter.current() < MAX_SUPPLY, "Maximum token supply reached");
        require(msg.value == PRICE, "Invalid amount");

        depositAddress.transfer(PRICE);

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721)
    {
        // if transfer comes from 0 it means it's a mint and we dont want to freeze mints when only transfers are fronzen, so we skip the require
        if (address(0) == from) {
            return;
        }
        require(!transfers_frozen, "Transfers are paused");
    }
}