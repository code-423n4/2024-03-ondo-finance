pragma solidity 0.8.16;

import "contracts/test/RWAOracleTestOnly.sol";
import "forge-tests/helpers/DSTestPlus.sol";

contract Test_TestRWAOracle is DSTestPlus {
  RWAOracleTestOnly oracle;

  function setUp() public {
    oracle = new RWAOracleTestOnly(address(this), 100);
  }

  function test_getPriceData() public {
    (uint256 price, uint256 timestamp) = oracle.getPriceData();
    assertEq(price, 100);
    assertEq(timestamp, block.timestamp);
  }

  function test_setPrice() public {
    oracle.setPrice(200);
    (uint256 price, uint256 timestamp) = oracle.getPriceData();
    assertEq(price, 200);
    assertEq(timestamp, block.timestamp);
  }
}
