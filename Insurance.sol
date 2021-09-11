// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Insurance {
    // Owner of the system
    address public owner;

    // Constructor, can receive one or many variables here; only one allowed
    constructor() {
        // msg provides details about the message that's sent to the contract
        // msg.sender is contract caller (address of contract creator)
        owner = msg.sender;
    }
    
    // TODO Add hospital

    // TODO Update hospital

    // TODO Buy insurance

    // TODO Function Claim
}