// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.1;

/**
 * Should allow the owner to withdraw Eth from the contract
   If owner does not withdraw Eth from the contract for more than 1 month ->
    an heir can take control of the contract and designate a new heir
   The owner can withdraw 0 Eth to reset the 1 month counter 
 */



contract Inheritance {

    address payable public owner;
    uint public heirloom;
    mapping(address => bool) public heirs_map; 
    address[] public heirs_arr;
    bool internal locked;
    uint public start_time;
    uint public DELAY = 10 seconds; // seconds
    uint public end_time;


    constructor() payable {
        owner = payable(msg.sender);
        heirloom += msg.value;
        start_time = block.timestamp;
        end_time = start_time + DELAY;
    }

    receive() external payable {}


    modifier onlyOwner(){
        require(msg.sender == owner, "Not owner"); 
        _;
    }

    modifier onlyHeirs() {
        require(heirs_map[msg.sender], "Not an heir");
        _;
    }

    modifier noReentrancy() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
        }

    modifier counter_ended(){
        require (block.timestamp >= end_time);
        _;
    }

    modifier counter_not_ended(){
        require (block.timestamp < end_time);
        _;
    }

    function withdraw(uint _amount) external onlyOwner noReentrancy {
        if (_amount <= heirloom) {
            heirloom -= _amount;
            (bool success, ) = owner.call{value:_amount}("");
            require(success, "Transfer failed.");
        }
    }

    
    function add_heir(address _heir) public onlyOwner {
        heirs_map[_heir] = true;
        heirs_arr.push(_heir);
    }


    function remove_heir(address _heir) public onlyOwner {
        delete heirs_map[_heir];
    }

    function get_heir_count() public view returns (uint){
        return heirs_arr.length;
    }

    function check_heir(address _possible_heir) public view returns (bool) {
        return heirs_map[_possible_heir];
    }

    function resetCounterOwner() public payable onlyOwner noReentrancy counter_not_ended {
        (bool success, ) = owner.call{value:0}("");
        require(success, "Transfer Failed");
        if (success){
            end_time = 30 days;
        }
    }

    function resetCounterHeir() public onlyOwner {
        end_time = 30 days;
        }
      
    
    function delete_all_heirs() public onlyOwner {
        for (uint i=0; i < heirs_arr.length; i++){
            delete heirs_map[heirs_arr[i]];
            }
    }

    function setNewOwner() public counter_ended onlyHeirs{
        // If prevous owner does not withdraw for more than 1 month -> counter_ended modifier
        // Check if it is an heir -> modifier onlyHeirs
        
        owner = payable(msg.sender);
        delete_all_heirs();
        resetCounterHeir();
    }   
}