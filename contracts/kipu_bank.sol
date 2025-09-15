// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

contract KipuBank {

  mapping(address => uint) balances;
  uint depositCount;
  uint withdrawCount;
  uint totalDeposits;

  uint immutable bankCapacity;
  uint immutable withdrawLimit;

  event Deposited(address account, uint256 amount);
  event Withdrawn(address account, uint256 amount);

  constructor(uint _bankCapacity, uint _withdrawLimit) {
    bankCapacity = _bankCapacity;
    withdrawLimit = _withdrawLimit;
  }

  function _makeDeposit(uint _amount) private {
    if (_amount == 0)
      revert("Deposit amount is zero");
    if((totalDeposits + _amount) > bankCapacity)
      revert("Bank capacity execeeded");

    balances[msg.sender] += _amount;
    totalDeposits += _amount;
    depositCount++;

    emit Deposited(msg.sender, _amount);
  }

  function _makeWithdraw(uint _amount) private {
    if (_amount == 0)
      revert("Withdrawal amount is zero");
    if(_amount > withdrawLimit)
      revert("Withdrawal amount exceeds limit");

    balances[msg.sender] -= _amount;
    totalDeposits -= _amount;
    withdrawCount++;

    emit Withdrawn(msg.sender, _amount);
  }

  function getBalance(address account) external view returns (uint) {
    return balances[account];
  }
}
