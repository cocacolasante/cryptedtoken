// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";

contract CryptedToken {
    string public name = 'Crypted Token';
    string public symbol = 'CT';
    uint256 decimals = 18;
    uint public totalSupply = 10000000;
    bool public nftIsStaked;

    // constructor function

    constructor(string memory _name, string memory _symbol, uint _totalSupply) {
        name = _name;
        symbol = _symbol;
        totalSupply = _totalSupply * decimals;
        balances[msg.sender] = totalSupply; // sends total supply to owner

    }

    //mapping of address to uint to get balance of each account
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;

    // transfer event
    event Transfer(
        address indexed _from, 
        address indexed _to, 
        uint256 _value);

    // approval event
    event Approval(
        address indexed _owner, 
        address indexed _spender, 
        uint256 _value);

    // transfer function
    function transfer(address to, uint amount) public returns(bool success) {
        require(balances[msg.sender] > amount); //requires spender has token balance

        //using helper function
        _transfer(to, msg.sender, amount);
        // returns true
        return true;
    }
    // helper function for transfers

    function _transfer(address _to, address _from, uint amount) internal {
        require(_to != address(0)); // makes sure the to address isnt the contract address
         // transfer the tokens
        balances[_from] -= amount;
        balances[_to] += amount;

        //emit transfer event
        emit Transfer(_to, _from, amount);

    }

    // approval for delegated trading

    function approve(address _spender, uint256 amount ) public returns(bool success){
        require(_spender != msg.sender);
        allowance[msg.sender][_spender] = amount;

        emit Approval(msg.sender, _spender, amount);
        return true;

    }

    // transfer from for delegated trading, specifically withdrawal function 

    function transferFrom(address _from, address _to, uint256 amount) public returns(bool success) {
        require(amount < balances[_from]);
        require(amount < allowance[_to][msg.sender]);

        // reset the allowances
        allowance[_from][msg.sender] = allowance[_from][msg.sender] - amount;

        //emit the transfer event
        emit Transfer(_from, _to, amount);
        return true;
    }

    // balance of function

    function balanceOf(address owner) public returns (uint balance){
        balances[owner] = balance;
        return balance;
    }

    // dev and marketing fees

    uint fees;


}
