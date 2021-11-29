// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "./TokenStake.sol";

interface Token {

    /// @param _owner The address from which the balance will be retrieved
    /// @return balance the balance
    function balanceOf(address _owner) external view returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return success Whether the transfer was successful or not
    function transfer(address _to, uint256 _value)  external returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return success Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return success Whether the approval was successful or not
    function approve(address _spender  , uint256 _value) external returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return remaining Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract TeebsToken is Token, Stakeable{

    mapping(address => mapping(address => uint256)) public allowed;
    mapping(address => uint256) public balances;
    mapping(address => bool) public hasClaimed;
    address creator;
    uint256 public totalSupply;


    constructor(uint256 _totalSupply){
        creator = msg.sender;
        balances[creator] = _totalSupply;
        totalSupply = _totalSupply;
    }

    /// @param _owner The address from which the balance will be retrieved
    /// @return balance the balance
    function balanceOf(address _owner) public view returns (uint256 balance){
        return balances[_owner]; 
    }

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return success Whether the transfer was successful or not
    function transfer(address _to, uint256 _value)  public returns (bool success){
        require(balances[msg.sender] >= _value, "You don't have enough tokens");

        balances[msg.sender] -= _value;
        balances[_to] += _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return success Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success){
        require(allowed[_from][msg.sender] <= _value);
        require(balances[_from] >= _value, "Not enough tokens");

        balances[_from] -= _value;
        balances[_to] += _value;

        allowed[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return success Whether the approval was successful or not
    function approve(address _spender  , uint256 _value) external returns (bool success){

        allowed[msg.sender][_spender] += _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return remaining Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) external view returns (uint256 remaining){
        return allowed[_owner][_spender];
    }

    function claimTokens() external returns(bool success){
        require(!hasClaimed[msg.sender] && balances[creator] >= 50);

        balances[msg.sender] += 50;
        balances[creator] -= 50;
        hasClaimed[msg.sender] = true;

        emit Transfer(creator, msg.sender, 50);
        return true;
    }

    function stake(uint256 amount) public {
        require(amount <= balances[msg.sender], "Can't stake more than you own");

        _stake(amount);

        transfer(owner, amount);
    }

}