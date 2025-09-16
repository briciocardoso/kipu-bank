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
  error WithdrawalAmountIsZero();
  error WithdrawalInsufficientBalance(uint accountBalance);
  error WithdrawalAmountExceededLimit(uint amount, uint withdrawLimit);
  error WithdrawalTransferFalied();
  error NotAccountOwner();

  constructor(uint _bankCapacity, uint _withdrawLimit) {
    bankCapacity = _bankCapacity;
    withdrawLimit = _withdrawLimit;
  }

  modifier onlyAccountOwner(address account) {
    if (msg.sender != account)
      revert NotAccountOwner();
    _;
  }

  function deposit() external payable {
    if (msg.value == 0)
      revert DepositAmountIsZero();
    if((totalDeposits + msg.value) > bankCapacity)
      revert BankCapacityExceeded(bankCapacity - totalDeposits);

    _makeDeposit(msg.sender, msg.value);
  }

  function withdraw(uint _amount) external {
    uint accountBalance = balances[msg.sender];
    if(_amount > accountBalance)
        revert WithdrawalInsufficientBalance(accountBalance);
    if (_amount == 0)
      revert WithdrawalAmountIsZero();
    if(_amount > withdrawLimit)
      revert WithdrawalAmountExceededLimit(_amount, withdrawLimit);

    _makeWithdraw(msg.sender, _amount);
  }

  function _makeDeposit(address _account, uint _amount) private {
    balances[_account] += _amount;
    totalDeposits += _amount;
    depositCount++;

    emit Deposited(_account, _amount);
  }

  function _makeWithdraw(address _account, uint _amount) private {
    balances[_account] -= _amount;
    totalDeposits -= _amount;
    withdrawCount++;

    (bool success, ) = msg.sender.call{ value: _amount }("");

    if (!success)
      revert WithdrawalTransferFalied();

    emit Withdrawn(msg.sender, _amount);
  }

  function getBalance(address account) external view onlyAccountOwner(account) returns (uint) {
    return balances[account];
  }
}
