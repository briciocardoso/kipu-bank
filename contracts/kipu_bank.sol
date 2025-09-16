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

  error DepositAmountIsZero();
  error BankCapacityExceeded(uint availableCapacity);

  constructor(uint _bankCapacity, uint _withdrawLimit) {
    bankCapacity = _bankCapacity;
    withdrawLimit = _withdrawLimit;
  }

  function deposit() external payable {
    if (msg.value == 0)
      revert DepositAmountIsZero();
    if((totalDeposits + msg.value) > bankCapacity)
      revert BankCapacityExceeded(bankCapacity - totalDeposits);

    _makeDeposit(msg.sender, msg.value);
  }

  function _makeDeposit(address _account, uint _amount) private {
    balances[_account] += _amount;
    totalDeposits += _amount;
    depositCount++;

    emit Deposited(_account, _amount);
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
