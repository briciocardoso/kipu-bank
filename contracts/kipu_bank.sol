// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

contract KipuBank {

  mapping(address => uint) balances;
  uint immutable withdrawLimit;
  uint totalDeposits;

  constructor(uint _withdrawLimit) {
    withdrawLimit = _withdrawLimit;
  }

  function _makeDeposit(uint _amount) private {
    balances[msg.sender] += _amount;
    totalDeposits += _amount;
  }

  function _makeWithdraw(uint _amount) private {
    if(_amount > withdrawLimit)
      revert("Withdrawal amount exceeds limit");

    balances[msg.sender] -= _amount;
    totalDeposits -= _amount;
  }
}
