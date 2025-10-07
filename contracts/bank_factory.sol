// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title KipuFactory
/// @author Bricio Cardoso
/// @notice Factory for a simple bank
/// @dev Simulate a simple bank system
contract BankFactory is AccessControl {
  using SafeERC20 for IERC20;

  /// @notice The bank capacity amount to receive deposits in Wei
  uint immutable public usdBankCapacity;
  /// @notice The withdraw limit in Wei
  uint immutable public usdWithdrawLimit;
  /// @notice The mapping of addresses to individual balances
  mapping(address => uint) internal balances;

  mapping(address => address) internal priceFeeds;

  mapping(address => bool) public isTokenAllowed;

  event TokenAdded(address indexed token, address indexed priceFeed);

  constructor(uint _usdBankCapacity, uint _usdWithdrawLimit) {    
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    usdBankCapacity = _usdBankCapacity;
    usdWithdrawLimit = _usdWithdrawLimit;
  }

  function addToken(address _token, address _priceFeed) external onlyRole(DEFAULT_ADMIN_ROLE) {
    require(_token != address(0), "Cannot add ETH address again");
    priceFeeds[_token] = _priceFeed;
    isTokenAllowed[_token] = false;
    emit TokenAdded(_token, _priceFeed);
  }

  function removeToken(address _token) external onlyRole(DEFAULT_ADMIN_ROLE) {
    require(_token != address(0), "Cannot remove ETH");
    isTokenAllowed[_token] = false;
    emit TokenRemoved(_token);
  }
}