// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.16;

import "./Owned.sol";

contract Whitelist is Owned {

    mapping (address => bool) whitelist;

    function isWhitelist(address account) public view returns (bool) {
        return whitelist[account];
    }

    function addWhitelist(address account) onlyAdmin public {
        require(account != address(0) && !whitelist[account]);
        whitelist[account] = true;
    }

    function removeWhitelist(address account) onlyAdmin public {
        require(account != address(0) && whitelist[account]);
        whitelist[account] = false;
    }
}