/*
This file is part of the DAO.

The DAO is free software: you can redistribute it and/or modify
it under the terms of the GNU lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

The DAO is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU lesser General Public License for more details.

You should have received a copy of the GNU lesser General Public License
along with the DAO.  If not, see <http://www.gnu.org/licenses/>.
*/


/*
Basic, standardized Token contract with no "premine". Defines the functions to
check token balances, send tokens, send tokens on behalf of a 3rd party and the
corresponding approval process. Tokens need to be created by a derived
contract (e.g. TokenCreation.sol).

Thank you ConsenSys, this contract originated from:
https://github.com/ConsenSys/Tokens/blob/master/Token_Contracts/contracts/Standard_Token.sol
Which is itself based on the Ethereum standardized contract APIs:
https://github.com/ethereum/wiki/wiki/Standardized_Contract_APIs
*/

/// @title Standard Token Contract.

pragma solidity >=0.4.22 <0.9.0;

abstract contract Plutocracy {
    function getOrModifyBlocked(address _account) public virtual returns (bool);
}

abstract contract TokenInterface {
    mapping(address => uint256) public balances;  // Changed to public for direct access
    mapping(address => mapping(address => uint256)) public allowed;  // Changed to public for direct access

    string public name;
    string public symbol;
    uint256 public decimals;  // Use uint256 for clarity

    /// Total amount of tokens
    uint256 public totalSupply;

    /// Governance contract
    Plutocracy public plutocracy;  // Made public for access

    /// @param _owner The address from which the balance will be retrieved
    /// @return balance The balance
    function balanceOf(address _owner) public view virtual returns (uint256 balance);

    /// @notice Send `_amount` tokens to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return success Whether the transfer was successful or not
    function transfer(address _to, uint256 _amount) public virtual returns (bool success);

    /// @notice Send `_amount` tokens to `_to` from `_from` on the condition it
    /// is approved by `_from`
    /// @param _from The address of the origin of the transfer
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return success Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _amount) public virtual returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_amount` tokens on
    /// its behalf
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _amount The amount of tokens to be approved for transfer
    /// @return success Whether the approval was successful or not
    function approve(address _spender, uint256 _amount) public virtual returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return remaining Amount of remaining tokens of _owner that _spender is allowed
    /// to spend
    function allowance(address _owner, address _spender) public view virtual returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event Approval(address indexed _owner, address indexed _spender, uint256 _amount);
}

contract Token is TokenInterface {

    constructor(Plutocracy _plutocracy) {
        plutocracy = _plutocracy;
    }

    function balanceOf(address _owner) public override view returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _amount) public override returns (bool success) {
        if (balances[msg.sender] >= _amount
            && _amount > 0
            && plutocracy.getOrModifyBlocked(_to)) {

            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            emit Transfer(msg.sender, _to, _amount);
            return true;
        } else {
           return false;
        }
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public override returns (bool success) {

        if (balances[_from] >= _amount
            && allowed[_from][msg.sender] >= _amount
            && _amount > 0
            && plutocracy.getOrModifyBlocked(_to)
            && plutocracy.getOrModifyBlocked(_from)) {

            balances[_to] += _amount;
            balances[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            emit Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    function approve(address _spender, uint256 _amount) public override returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) public override view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

