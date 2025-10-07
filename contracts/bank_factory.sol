// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/// @title KipuFactory
/// @author Bricio Cardoso
/// @notice Factory for a simple bank
/// @dev Simulate a simple bank system
contract BankFactory is AccessControl {
  using SafeERC20 for IERC20;

  address public constant ETH_ADDRESS = address(0);
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

  function getTokenUsdValue(address _token, uint _amount) public view returns (uint) {
    address priceFeedAddress = priceFeeds[_token];
    
    if (priceFeedAddress == address(0)) revert InvalidPriceFeed(_token);

    AggregatorV3Interface priceFeed = AggregatorV3Interface(priceFeedAddress);
    (, int256 price, , , ) = priceFeed.latestRoundData();
    uint256 priceFeedDecimals = priceFeed.decimals();
    uint256 tokenDecimals = (_token == ETH_ADDRESS) ? 18 : IERC20Metadata(_token).decimals();

    return (_amount * uint(price) * (10**18)) / ((10**tokenDecimals) * (10**priceFeedDecimals));
    }
}