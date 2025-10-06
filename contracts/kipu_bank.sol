// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/AccessControl.sol";

/// @title KipuBank
/// @author Bricio Cardoso
/// @notice A simple contract where users can deposit, withdraw and check the balance ETH
/// @dev Simulate a simple bank system
contract KipuBank is AccessControl {
  /// @notice The bank capacity amount to receive deposits in Wei
  uint immutable public bankCapacity;
  /// @notice The withdraw limit in Wei
  uint immutable public withdrawLimit;

  /// @notice The number of deposits
  uint private depositCount;
  /// @notice The number of withdraws
  uint private withdrawCount;
  /// @notice The total value of deposits
  uint private totalDeposits;

  /// @notice The mapping of addresses to individual balances
  mapping(address => uint) private balances;

  /// @notice The event when a user makes a deposit
  /// @param account The address of the account where the deposit was made
  /// @param amount The amount that was deposited
  event Deposited(address account, uint256 amount);

  /// @notice The event when a user makes a withdraw
  /// @param account The address of the account where the withdraw was made
  /// @param amount The amount that was withdrawn
  event Withdrawn(address account, uint256 amount);

  /// @notice Error returned when the amount to deposit is zero
  error DepositAmountIsZero();
  /// @notice Error returned when the bank capacity is exceeded
  /// @param availableCapacity The available capacity in Wei
  error BankCapacityExceeded(uint availableCapacity);
  /// @notice Error returned when the amount to withdraw is zero
  error WithdrawalAmountIsZero();
  /// @notice Error returned when doesnt have enough balance
  /// @param accountBalance The current balance from the account
  error WithdrawalInsufficientBalance(uint accountBalance);
  /// @notice Error returned when the withdraw exceed the limit per transaction
  /// @param amount The amount requested
  /// @param withdrawLimit The limit to withdraw per transaction
  error WithdrawalAmountExceededLimit(uint amount, uint withdrawLimit);
  /// @notice Error returned when a transfer failed
  error WithdrawalTransferFalied();
  /// @notice Error returned when a function attempted to access an account through an unauthorized address
  error NotAccountOwner();

  /// @notice The contract constructor
  /// @param _bankCapacity The bank capacity amount to receive deposits in Wei
  /// @param _withdrawLimit The withdraw limit in Wei
  constructor(address defaultAdmin, uint _bankCapacity, uint _withdrawLimit) {
    _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
    bankCapacity = _bankCapacity;
    withdrawLimit = _withdrawLimit;
  }

  /// @notice Restricts the execution of a function to the account owner
  modifier onlyAccountOwner(address _account) {
    if (msg.sender != _account)
      revert NotAccountOwner();
    _;
  }

  /// @notice Allow deposit some value in the sender account
  function deposit() external payable {
    if (msg.value == 0)
      revert DepositAmountIsZero();
    if((totalDeposits + msg.value) > bankCapacity)
      revert BankCapacityExceeded(bankCapacity - totalDeposits);

    _makeDeposit(msg.sender, msg.value);
  }

  /// @notice Allows withdraw some value from the sender account
  /// @param _amount The amount in wei to be withdrawn
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

  /// @notice Updates the contract state with the deposit
  /// @param _account The account address to deposit
  /// @param _amount The amount to deposit
  function _makeDeposit(address _account, uint _amount) private {
    balances[_account] += _amount;
    totalDeposits += _amount;
    depositCount++;

    emit Deposited(_account, _amount);
  }

  /// @notice Updates the contract state with the withdraw
  /// @param _account The account address to withdraw
  /// @param _amount The amount to withdraw
  function _makeWithdraw(address _account, uint _amount) private {
    balances[_account] -= _amount;
    totalDeposits -= _amount;
    withdrawCount++;

    (bool success, ) = msg.sender.call{ value: _amount }("");

    if (!success)
      revert WithdrawalTransferFalied();

    emit Withdrawn(msg.sender, _amount);
  }

  /// @notice Returns the current balance from an account
  /// @param _account The address from an account
  function getBalance(address _account) external view onlyAccountOwner(_account) returns (uint) {
    return balances[_account];
  }
}
