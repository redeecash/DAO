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

abstract contract DAO {
    // Function to get the balance of a given address
    function balanceOf(address addr) public view virtual returns (uint256);

    // Function to transfer tokens from one address to another
    function transferFrom(address from, address to, uint256 balance) public virtual returns (bool);

    // Total supply of tokens
    uint256 public totalSupply;
}

contract WithdrawDAO {
    DAO public constant mainDAO = DAO(0xBB9bc244D798123fDe783fCc1C72d3Bb8C189413);
    address payable public trustee = payable(0xDa4a4626d3E16e094De3225A751aAb7128e96526); // curator multisig

    function withdraw() public {
        uint256 balance = mainDAO.balanceOf(msg.sender);

        require(mainDAO.transferFrom(msg.sender, address(this), balance), "Transfer failed");
        (bool sent, ) = msg.sender.call{value: balance}("");
        require(sent, "Ether transfer failed");
    }

    function trusteeWithdraw() public {
        uint256 amount = (address(this).balance + mainDAO.balanceOf(address(this))) - mainDAO.totalSupply();
        require(amount > 0, "No funds available for withdrawal");
        (bool sent, ) = trustee.call{value: amount}("");
        require(sent, "Trustee Ether transfer failed");
    }

    // Fallback function to receive Ether
    receive() external payable {}
}