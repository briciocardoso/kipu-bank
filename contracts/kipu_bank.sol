// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

contract KipuBank {

  mapping(address => uint) balances;

  function _makeDeposit(uint _amount) private {
    balances[msg.sender] += _amount;
  }

  function _makeWithdraw(uint _amount) private {
    balances[msg.sender] -= _amount;
  }
}
