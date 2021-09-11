// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Insurance {
    // Owner of the system
    address public owner;
    
    // Hospital in system
    mapping(address => address) _nextHospital;
    uint256 private hospitalListSize;
    address constant GUARD = address(1);
    
    // Customers in system
    mapping(address => address) _nextCustomer;
    uint256 private customerListSize;
    address constant CUSTOMERGUARD = address(1);
    
    // dictionary that maps addresses to balances
    mapping (address => uint256) private balances;

    // Constructor, can receive one or many variables here; only one allowed
    constructor() {
        // msg provides details about the message that's sent to the contract
        // msg.sender is contract caller (address of contract creator)
        owner = msg.sender;
        _nextHospital[GUARD] = GUARD;
        _nextCustomer[CUSTOMERGUARD] = CUSTOMERGUARD;
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
        require(isHospital(hospital), "Hospital not found");
        address prevHospital = _getPrevHospital(hospital);
        _nextHospital[prevHospital] = _nextHospital[hospital];
        _nextHospital[hospital] = address(0);
        hospitalListSize--;
    }
    
    // **************************************************************************************

    // Customers
    function isCustomer(address customer) public view returns (bool) {
        require(isHospital(msg.sender), "This function for only hospital.");
        return _nextCustomer[customer] != address(0);
    }
    
    function _getPrevCustomer(address customer) internal view returns (address) {
        address currentAddress = CUSTOMERGUARD;
        while(_nextCustomer[currentAddress] != CUSTOMERGUARD) {
            if (_nextCustomer[currentAddress] == customer) {
                return currentAddress;
            }
            currentAddress = _nextCustomer[currentAddress];
        }
        return address(0);
    }
    
    // Add customer
    function addCustomer(address customer) private {
        _nextCustomer[customer] = _nextCustomer[CUSTOMERGUARD];
        _nextCustomer[CUSTOMERGUARD] = customer;
        customerListSize++;
    }
    
    // Remove customer
    function removeCustomer(address customer) private {
        require(isCustomer(customer), "Customer not found");
        address prevCustomer = _getPrevCustomer(customer);
        _nextCustomer[prevCustomer] = _nextCustomer[customer];
        _nextCustomer[customer] = address(0);
        customerListSize--;
    }
    
    
    // buy insurance
    function buyInsurance() public payable {
        uint256 priceOfInsturance = 1;
        require(msg.value >= priceOfInsturance, "Price require 1");
        require(!isCustomer(msg.sender), "Customer already exist!");
        
        // return money when receive more priceOfInsturance
        uint256 moneyToReturn = msg.value - priceOfInsturance;
        
        // add customer in system 
        addCustomer(msg.sender);
        
        balances[msg.sender] = balances[msg.sender];
        
        if (moneyToReturn > 0) {
            payable(msg.sender).transfer(moneyToReturn);
        }
    }
    
    // **************************************************************************************

    // Claim Insurance
    function claimInsurance(address customer) public {
        require(isHospital(msg.sender), "This function for only hospital.");
        require(isCustomer(customer), "Customer not found");
        
        uint256 moneyToReturn = balances[customer];
        delete balances[customer];
        
        // remove customer in system
        removeCustomer(customer);
        
        // send money to customer
        payable(customer).transfer(moneyToReturn);
    }
    
    // **************************************************************************************
}
