// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract CryptedToken {
    string name = 'Crypted Token';
    string symbol = 'CT';
    uint256 decimals = 18;
    uint totalSupply = 10000000;

    //mapping of address to uint to get balance of each account
    mapping(address => uint) public balanceOf;
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
        require(balanceOf[msg.sender] > amount); //requires spender has token balance

        //using helper function
        _transfer(to, msg.sender, amount);
        // returns true
        return true;
    }
    // helper function for transfers

    function _transfer(address _to, address _from, uint amount) internal {
        require(_to != address(0)); // makes sure the to address isnt the contract address
         // transfer the tokens
        balanceOf[_from] -= amount;
        balanceOf[_to] += amount;

        //emit transfer event
        emit Transfer(_to, _from, amount);

    }

    // approval for delegated trading

    function approve(address _spender, uint amount ) public returns(bool success){
        require(_spender != msg.sender);
        allowance[msg.sender][_spender] = amount;

        emit Approval(msg.sender, _spender, amount);
        return true;

    }


}
