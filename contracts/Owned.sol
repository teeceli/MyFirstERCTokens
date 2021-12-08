// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.9;

contract Owned {
    
    address public owner;
    mapping(address => bool) admins;
   
    constructor () {
        owner = msg.sender;
        admins[msg.sender] = true;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyAdmin {
        require(admins[msg.sender] == true);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }

    function isAdmin(address account) onlyOwner public view returns (bool) {
        return admins[account];
    }

    function addAdmin(address account) onlyOwner public {
        require(account != address(0) && !admins[account]);
        admins[account] = true;
    }

    function removeAdmin(address account) onlyOwner public {
        require(account != address(0) && admins[account]);
        admins[account] = false;  
    }
}