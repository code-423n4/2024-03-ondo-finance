pragma solidity 0.8.16;

import "contracts/PricerWithOracle.sol";
import "contracts/Pricer.sol";
import "contracts/rwaOracles/RWAOracleExternalComparisonCheck.sol";
import "forge-tests/helpers/MockChainlinkPriceOracle.sol";
import "forge-tests/MinimalTestRunner.sol";

contract Test_PricerWithOracle is MinimalTestRunner {
  PricerWithOracle public pricer;
  uint256 newPrice = 1020e17;
  int256 newPriceCL = 1010e8;

  // Oracle Info
  RWAOracleExternalComparisonCheck oracle;
  MockChainlinkPriceOracle mockChainlinkOracle;
  uint80 public currentRoundId = 1;
  int256 public constant INITIAL_CL_PRICE = 1000e8;
  int256 public constant INITIAL_RWA_PRICE = 100e18;
  int256 public constant BPS_DENOMINATOR = 10_000;

  function setUp() public {
    // Deploy Mock Chainlink and SHV Oracles
    mockChainlinkOracle = new MockChainlinkPriceOracle(
      8,
      "Mock oracle for testing"
    );
    mockChainlinkOracle.setRoundData(
      currentRoundId,
      INITIAL_CL_PRICE,
      block.timestamp - 1,
      block.timestamp,
      currentRoundId
    );

    ++currentRoundId;
    oracle = new RWAOracleExternalComparisonCheck(
      INITIAL_RWA_PRICE,
      address(mockChainlinkOracle),
      "CONSTRAINED OUSG ORACLE TEST",
      address(this), //admin
      address(this) //setter role
    );

    // Deploy pricer
    pricer = new PricerWithOracle(
      address(this), // Admin
      address(this), // Pricer
      address(oracle)
    );

    oracle.grantRole(oracle.SETTER_ROLE(), address(pricer));
    pricer.grantRole(pricer.ADD_PRICE_OPS_ROLE(), address(this));
  }

  function setNewChainlinkPrice(int256 bps) private returns (int256) {
    (, int256 last_price, , , ) = mockChainlinkOracle.latestRoundData();
    int256 priceToSet = (last_price * (BPS_DENOMINATOR + bps)) /
      BPS_DENOMINATOR;
    mockChainlinkOracle.setRoundData(
      currentRoundId,
      priceToSet,
      block.timestamp - 1,
      block.timestamp,
      currentRoundId
    );
    ++currentRoundId;
    return priceToSet;
  }

  function test_initialization() public {
    // Check priceId array
    assertEq(pricer.priceIds(0), 1);
    assertEq(pricer.currentPriceId(), 1);

    // Check that priceId 1 is initialized properly
    assertEq(pricer.latestPriceId(), 1);
    (uint256 pricerInitialPrice, uint256 pricerInitialTimestamp) = pricer
      .prices(1);
    assertEq(pricerInitialPrice, uint256(INITIAL_RWA_PRICE));

    // Check that pricer price matches oracle price
    (uint256 oraclePrice, uint256 oracleTimestamp) = oracle.getPriceData();
    assertEq(pricerInitialPrice, oraclePrice);

    // Check that pricer latest timestmap matches oracle timestasmp
    assertEq(pricerInitialTimestamp, oracleTimestamp);
  }

  function test_addPrice_fail_accessControl() public {
    vm.expectRevert(_formatACRevert(alice, pricer.PRICE_UPDATE_ROLE()));
    vm.prank(alice);
    pricer.addPrice(100, block.timestamp);
  }

  function test_addPrice_fail_invalidPrice() public {
    vm.expectRevert(Pricer.InvalidPrice.selector);
    pricer.addPrice(0, block.timestamp);
  }

  function test_addPrice() public {
    // Set Chainlink data
    vm.warp(block.timestamp + oracle.MIN_PRICE_UPDATE_WINDOW() + 1);
    setNewChainlinkPrice(200);
    oracle.setPrice(int256(newPrice));
    vm.warp(block.timestamp + 2 hours);

    vm.expectEmit(true, true, true, true);
    emit PriceAdded(2, newPrice, block.timestamp);
    pricer.addPrice(newPrice, block.timestamp);
  }

  function test_addPrice_checkPricerState() public {
    test_addPrice();
    assertEq(pricer.priceIds(1), 2);
    (uint256 price, uint256 timestamp) = pricer.prices(2);
    assertEq(price, newPrice);
    assertEq(timestamp, block.timestamp);
    assertEq(pricer.latestPriceId(), 2);
  }

  function test_updatePrice_fail_accessControl() public {
    vm.expectRevert(_formatACRevert(alice, pricer.PRICE_UPDATE_ROLE()));
    vm.prank(alice);
    pricer.updatePrice(1, newPrice);
  }

  function test_updatePrice_fail_invalidPrice() public {
    vm.expectRevert(Pricer.InvalidPrice.selector);
    pricer.updatePrice(1, 0);
  }

  function test_updatePrice_fail_priceIDExistence() public {
    vm.expectRevert(Pricer.PriceIdDoesNotExist.selector);
    pricer.updatePrice(2, newPrice);
  }

  function test_updatePrice() public {
    // Add price to pricer
    test_addPrice();

    // Get old data and update price
    (uint256 initialPrice, uint256 initialPriceTimestamp) = pricer.prices(2);
    uint256 updatedPrice = initialPrice + 1;
    vm.expectEmit(true, true, true, true);
    emit PriceUpdated(2, initialPrice, updatedPrice);
    pricer.updatePrice(2, updatedPrice);

    // Check State
    assertEq(pricer.priceIds(1), 2); // PriceId array doesn't change
    assertEq(pricer.latestPriceId(), 2); // Latest price doesn't change
    (uint256 pricerUpdatedPrice, uint256 pricerUpdatedTimestamp) = pricer
      .prices(2);
    assertEq(pricerUpdatedPrice, updatedPrice);
    assertEq(pricerUpdatedTimestamp, initialPriceTimestamp);
  }

  function test_addPriceOps_fail_accessControl() public {
    vm.expectRevert(_formatACRevert(alice, pricer.ADD_PRICE_OPS_ROLE()));
    vm.prank(alice);
    pricer.addPriceOps(newPrice, block.timestamp);
  }

  function test_addPriceOps_fail_timestamp_in_future() public {
    // Add a price to pricer and oracle
    test_addPrice();

    vm.expectRevert(PricerWithOracle.TimeStampInFuture.selector);
    pricer.addPriceOps(newPrice, block.timestamp + 1);
  }

  function test_addPriceOps_fail_timestamp_in_past() public {
    // Add a price to pricer and oracle
    test_addPrice();

    uint256 oldTimestamp = block.timestamp - pricer.maxTimestampDiff() - 1;

    vm.expectRevert(PricerWithOracle.TimeStampTooOld.selector);
    pricer.addPriceOps(newPrice, oldTimestamp);
  }

  function test_isValid() public {
    // Add a price to pricer and oracle
    test_addPrice();

    uint256[] memory priceIds = new uint256[](1);
    priceIds[0] = 2;
    assertEq(pricer.isValid(priceIds), true);
    priceIds[0] = 3;
    assertEq(pricer.isValid(priceIds), false);
  }

  function test_isValid_multiple() public {
    // Add a price to pricer and oracle
    test_addPrice();

    uint256[] memory priceIds = new uint256[](2);
    priceIds[0] = 1;
    priceIds[1] = 2;
    assertEq(pricer.isValid(priceIds), true);
    priceIds[0] = 2;
    priceIds[1] = 3;
    assertEq(pricer.isValid(priceIds), false);
  }

  function test_addPriceOps_fail_stale_oracle() public {
    // Add a price to pricer and oracle
    test_addPrice();

    vm.warp(block.timestamp + pricer.maxTimestampDiff() + 1);

    vm.expectRevert(PricerWithOracle.StaleOraclePrice.selector);
    pricer.addPriceOps(newPrice, block.timestamp);
  }

  function test_setMaxTimestampDiff() public {
    uint256 initialMaxTimestampDiff = 1000;
    pricer.setMaxTimestampDiff(initialMaxTimestampDiff);

    // Check that maxTimestampDiff was set correctly
    assertEq(pricer.maxTimestampDiff(), initialMaxTimestampDiff);

    // Set new maxTimestampDiff
    uint256 newMaxTimestampDiff = 2000;
    pricer.setMaxTimestampDiff(newMaxTimestampDiff);

    // Check that maxTimestampDiff was updated correctly
    assertEq(pricer.maxTimestampDiff(), newMaxTimestampDiff);
  }

  function test_deletePrice() public {
    // Add a price
    uint256 timestamp = block.timestamp;
    test_addPrice();

    // Delete the price
    vm.expectEmit(true, true, true, true);
    emit PriceDeleted(1, 100000000000000000000, timestamp);
    pricer.deletePrice(1);

    // Check state
    assertEq(pricer.latestPriceId(), 2);
    assertEq(pricer.priceIds(0), 1);
    (uint256 price, uint256 timestamp1) = pricer.prices(0);
    assertEq(price, 0);
    assertEq(timestamp1, 0);

    // Try to delete a non-existent price
    vm.expectRevert(Pricer.PriceIdDoesNotExist.selector);
    pricer.deletePrice(1);
  }

  function test_deletePrice_fail_accessControl() public {
    vm.expectRevert(_formatACRevert(alice, bytes32(0)));
    vm.prank(alice);
    pricer.deletePrice(1);
  }

  function test_addPriceOps() public {
    // Set Chainlink data & oracle price
    vm.warp(block.timestamp + oracle.MIN_PRICE_UPDATE_WINDOW() + 1);
    setNewChainlinkPrice(200);
    vm.warp(block.timestamp + 1 hours);

    oracle.setPrice(int256(newPrice));
    (uint256 latestOraclePrice, uint256 latestOracleTimestamp) = oracle
      .getPriceData();

    uint256 wrongPrice = latestOraclePrice + 1e18;

    // Expect revert if you try to add a price to pricer
    vm.expectRevert(PricerWithOracle.PriceChangeTooLarge.selector);
    pricer.addPriceOps(wrongPrice, block.timestamp);

    // Add latest oracle price by catching up
    vm.expectEmit(true, true, true, true);
    emit PriceAdded(2, newPrice, latestOracleTimestamp);
    pricer.addPriceOps(newPrice, latestOracleTimestamp);

    // Check state
    assertEq(pricer.latestPriceId(), 2);
    assertEq(pricer.priceIds(1), 2);
    (uint256 price, uint256 timestamp) = pricer.prices(2);
    assertEq(price, latestOraclePrice);
    assertEq(timestamp, latestOracleTimestamp);
  }

  // Helper Events
  event PriceAdded(uint256 indexed priceId, uint256 price, uint256 timestamp);
  event PriceUpdated(
    uint256 indexed priceId,
    uint256 oldPrice,
    uint256 newPrice
  );
  event PriceDeleted(uint256 indexed priceId, uint256 price, uint256 timestamp);
}
