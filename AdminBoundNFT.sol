// SPDX-License-Identifier: MIT

// Author: zac@juicelabs.io

pragma solidity ^0.8.0;

import "./ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract AdminBoundNFT is ERC721 {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
    mapping(uint256 => address) _admins;

    constructor() ERC721("AdminBound", "Admin") {}

    /**
     * STORE THE ADMIN ON MINT
     */

    function mintAdminBound(address owner) public returns (uint256) {
        uint256 newItemId = _tokenIds.current();
        _mint(owner, newItemId);
        _admins[newItemId] = _msgSender();

        _tokenIds.increment();
        return newItemId;
    }

    /**
     * WHO IS THE ADMIN OF A GIVEN TOKEN?
     */
    function adminOf(uint256 tokenId) public view returns (address) {
        address admin = _admins[tokenId];
        require(admin != address(0), "AdminBound: invalid token ID");
        return admin;
    }

    /**
     * OVERRIDE TRANSFER FUNCTIONS TO INCLUDE ADMIN VALIDATION
     */

    function _ensureSenderIsAdmin(uint256 tokenId) internal view {
        address admin = _admins[tokenId];
        require(_msgSender() == admin, "AdminBound: sender is not admin");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        _ensureSenderIsAdmin(tokenId);
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        _ensureSenderIsAdmin(tokenId);
        _safeTransfer(from, to, tokenId, data);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        _ensureSenderIsAdmin(tokenId);
        _transfer(from, to, tokenId);
    }

    /**
     * REMOVE ALL APPROVAL FUNCTIONALITY
     */

    function approve(address to, uint256 tokenId) public virtual override {
        // this is now a no-op
    }

    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {
        // also a no-op now
    }
}
