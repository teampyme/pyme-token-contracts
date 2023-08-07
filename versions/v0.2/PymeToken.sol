// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/*
Contract: PYME Token Smart Contract
Version: v0.2
Date: 6th of August, 2023
Author: Bilal Motiwala
Security Contact: bilal@pyme.id

===============================================
Built Using OpenZeppelin's Contract Wizard v4.x
===============================================
*/

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20SnapshotUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/draft-ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./ERC20CappedUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PymeToken is Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable, ERC20SnapshotUpgradeable, OwnableUpgradeable, PausableUpgradeable, ERC20PermitUpgradeable, ERC20VotesUpgradeable, UUPSUpgradeable, ERC20CappedUpgradeable {

    // Creating A Whitelist Mapping
    mapping (address => bool) public whitelist;

    // Creating A Blacklist Mapping
    mapping (address => bool) public blacklist;

    
    constructor() {
        _disableInitializers();
    }

    function initialize() initializer public {
        __ERC20_init("PymeDAO", "PYME");
        __ERC20Burnable_init();
        __ERC20Snapshot_init();
        __Ownable_init();
        __Pausable_init();
        __ERC20Permit_init("PymeDAO");
        __ERC20Votes_init();
        __UUPSUpgradeable_init();
        __ERC20Capped_init(1000000000 * 10 ** decimals());
        _mint(msg.sender, 510000000 * 10 ** decimals());
    }

    function snapshot() public onlyOwner {
        _snapshot();
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function setWhitelist(address _address, bool _state) public onlyOwner {
        whitelist[_address] = _state;
    }

    function setBlacklist(address _address, bool _state) public onlyOwner {
        blacklist[_address] = _state;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20Upgradeable, ERC20SnapshotUpgradeable)
    {
        require(!blacklist[from] && !blacklist[to], "ERC20Pausable: token transfer to/from blacklisted address");
        if (!whitelist[from] && !whitelist[to]) {
            require(!paused(), "ERC20Pausable: token transfer while paused");
        }
        super._beforeTokenTransfer(from, to, amount);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

    // The following functions are overrides required by Solidity.

    function _afterTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20Upgradeable, ERC20VotesUpgradeable)
    {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount)
        internal
        override(ERC20Upgradeable, ERC20VotesUpgradeable, ERC20CappedUpgradeable)
    {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20Upgradeable, ERC20VotesUpgradeable)
    {
        super._burn(account, amount);
    }
}