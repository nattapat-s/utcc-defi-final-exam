// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Insurance {
    // Owner of the system
    address public owner;
    
    // Hospital in system
    mapping(address => address) _nextHospital;
    uint256 private hospitalListSize;
    address constant GUARD = address(1);

    // Constructor, can receive one or many variables here; only one allowed
    constructor() {
        // msg provides details about the message that's sent to the contract
        // msg.sender is contract caller (address of contract creator)
        owner = msg.sender;
        _nextHospital[GUARD] = GUARD;
    }
    
    // **************************************************************************************
    // Hospital
    function isHospital(address hospital) private view returns (bool) {
        return _nextHospital[hospital] != address(0);
    }
    
    function _getPrevHospital(address hospital) internal view returns (address) {
        address currentAddress = GUARD;
        while(_nextHospital[currentAddress] != GUARD) {
            if (_nextHospital[currentAddress] == hospital) {
                return currentAddress;
            }
            currentAddress = _nextHospital[currentAddress];
        }
        return address(0);
    }
    
    function getHospitalListCount() public view returns (uint256) {
        return hospitalListSize;
    }
    
    function getHospital(uint256 indexAt) public view returns (address) {
        require(owner == msg.sender, "You are not authorized");
        address[] memory hospital = new address[](hospitalListSize);
        address currentAddress = _nextHospital[GUARD];
        for(uint256 i = 0; currentAddress != GUARD; ++i) {
            hospital[i] = currentAddress;
            currentAddress = _nextHospital[currentAddress];
        }
        return hospital[indexAt];
    }
    
    // Add hospital
    // add with address
    function addHospital(address hospital) public {
        require(owner == msg.sender, "You are not authorized");
        require(!isHospital(hospital), "Hospital is exist");
        _nextHospital[hospital] = _nextHospital[GUARD];
        _nextHospital[GUARD] = hospital;
        hospitalListSize++;
    }
    
    // add with array of address
    function addHospitalList(address[] memory hospitalList) public {
        require(owner == msg.sender, "You are not authorized");
        for (uint256 i=0; i < hospitalList.length; i++) {
            if (!isHospital(hospitalList[i])) {
                addHospital(hospitalList[i]);
            }
        }
    }
    
    // Remove hospital
    function removeHospital(address hospital) public {
        require(isHospital(hospital), "Hospital is not found");
        address prevHospital = _getPrevHospital(hospital);
        _nextHospital[prevHospital] = _nextHospital[hospital];
        _nextHospital[hospital] = address(0);
        hospitalListSize--;
    }
    
    // **************************************************************************************

    // TODO Buy insurance

    // TODO Function Claim
}
