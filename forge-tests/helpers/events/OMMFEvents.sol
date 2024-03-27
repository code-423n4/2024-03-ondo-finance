pragma solidity 0.8.16;

import "forge-tests/helpers/events/ERC20Events.sol";

contract OMMFEvents is ERC20Events {
  event OracleReportHandled(uint256 oldDepositedCash, uint256 newDepositedCash);

  event TransferShares(
    address indexed from,
    address indexed to,
    uint256 sharesValue
  );
}
