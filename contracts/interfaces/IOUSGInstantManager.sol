/**SPDX-License-Identifier: BUSL-1.1
      ▄▄█████████▄
   ╓██▀└ ,╓▄▄▄, '▀██▄
  ██▀ ▄██▀▀╙╙▀▀██▄ └██µ           ,,       ,,      ,     ,,,            ,,,
 ██ ,██¬ ▄████▄  ▀█▄ ╙█▄      ▄███▀▀███▄   ███▄    ██  ███▀▀▀███▄    ▄███▀▀███,
██  ██ ╒█▀'   ╙█▌ ╙█▌ ██     ▐██      ███  █████,  ██  ██▌    └██▌  ██▌     └██▌
██ ▐█▌ ██      ╟█  █▌ ╟█     ██▌      ▐██  ██ └███ ██  ██▌     ╟██ j██       ╟██
╟█  ██ ╙██    ▄█▀ ▐█▌ ██     ╙██      ██▌  ██   ╙████  ██▌    ▄██▀  ██▌     ,██▀
 ██ "██, ╙▀▀███████████⌐      ╙████████▀   ██     ╙██  ███████▀▀     ╙███████▀`
  ██▄ ╙▀██▄▄▄▄▄,,,                ¬─                                    '─¬
   ╙▀██▄ '╙╙╙▀▀▀▀▀▀▀▀
      ╙▀▀██████R⌐
 */
pragma solidity 0.8.16;

/**
 * @title IOUSGInstantManager
 * @author Ondo Finance
 * @notice The interface for Ondo's conversion modules for between OUSG and USDC
 */
interface IOUSGInstantManager {
  struct RateLimiterConfig {
    uint256 mintLimitDuration;
    uint256 redeemLimitDuration;
    uint256 mintLimit;
    uint256 redeemLimit;
  }

  /**
   * @notice Exchange USDC for OUSG token
   *
   * @param usdcAmountIn Amount of USDC to be exchanged for OUSG
   *
   * @return ousgAmountOut Amount of OUSG minted for the user
   */
  function mint(uint256 usdcAmountIn) external returns (uint256 ousgAmountOut);

  /**
   * @notice Exchange USDC for rOUSG token
   *
   * @param usdcAmountIn Amount of USDC to be exchanged for rOUSG
   *
   * @return rousgAmountOut Amount of rOUSG minted for the user
   */

  function mintRebasingOUSG(
    uint256 usdcAmountIn
  ) external returns (uint256 rousgAmountOut);

  /**
   * @notice Exchange OUSG for USDC
   *
   * @param ousgAmountIn Amount of OUSG to redeem for USDC
   *
   * @return usdcAmountOut Amount of USDC returned to the user
   */
  function redeem(
    uint256 ousgAmountIn
  ) external returns (uint256 usdcAmountOut);

  /**
   * @notice Exchange rOUSG for USDC
   *
   * @param rousgAmountIn Amount of rOUSG to redeem for USDC
   *
   * @return usdcAmountOut Amount of USDC returned to the user
   */
  function redeemRebasingOUSG(
    uint256 rousgAmountIn
  ) external returns (uint256 usdcAmountOut);

  /*//////////////////////////////////////////////////////////////
                    Configuration Setters
  //////////////////////////////////////////////////////////////*/
  function setInstantMintLimit(uint256 _instantMintLimit) external;

  function setInstantRedemptionLimit(uint256 _instantRedemptionLimit) external;

  function setInstantMintLimitDuration(
    uint256 _instantMintLimitDuration
  ) external;

  function setInstantRedemptionLimitDuration(
    uint256 _instantRedemptionLimitDuratioin
  ) external;

  function setMintFee(uint256 _mintFee) external;

  function setRedeemFee(uint256 _redeemFee) external;

  function setMinimumDepositAmount(uint256 _minimumDepositAmount) external;

  function setMinimumRedemptionAmount(
    uint256 _minimumRedemptionAmount
  ) external;

  function setMinimumBUIDLRedemptionAmount(
    uint256 _minimumBUIDLRedemptionAmount
  ) external;

  function setOracle(address _oracle) external;

  function setFeeReceiver(address _feeReceiver) external;

  function setInvestorBasedRateLimiter(
    address _investorBasedRateLimiter
  ) external;

  /**
   * @notice Event emitted when a user exchanges USDC for OUSG
   *
   * @param sender        Address of the transaction's message sender
   * @param usdcAmountIn  Amount of the USDC sent from the user
   * @param ousgAmountOut Amount of OUSG sent to user
   */
  event InstantMintOUSG(
    address indexed sender,
    uint256 usdcAmountIn,
    uint256 ousgAmountOut
  );

  /**
   * @notice Event emitted when a user exchanges USDC for rOUSG
   *
   * @param sender         Address of the transaction's message sender
   * @param usdcAmountIn   Amount of the USDC sent from the user
   * @param ousgAmountOut  Amount of OUSG wrapped for the user
   * @param rousgAmountOut Amount of rOUSG sent to user
   */
  event InstantMintRebasingOUSG(
    address indexed sender,
    uint256 usdcAmountIn,
    uint256 ousgAmountOut,
    uint256 rousgAmountOut
  );

  /**
   * @notice Event emitted when a user incurs mint Fees
   *
   * @param sender       Address of the transaction's message sender
   * @param feeReceiver  Address of the USDC fee receiver
   * @param usdcFees     Amount of USDC deducted as fees
   * @param usdcAmountIn Amount of USDC sent from the user
   */
  event MintFeesDeducted(
    address indexed sender,
    address indexed feeReceiver,
    uint256 usdcFees,
    uint256 usdcAmountIn
  );

  /**
   * @notice Event emitted when a user incurs redemption Fees
   *
   * @param sender        Address of the transaction's message sender
   * @param feeReceiver   Address of the USDC fee receiver
   * @param usdcFees      Amount of USDC deducted as fees
   * @param usdcAmountOut Amount of USDC sent to the user
   */
  event RedeemFeesDeducted(
    address indexed sender,
    address indexed feeReceiver,
    uint256 usdcFees,
    uint256 usdcAmountOut
  );

  /**
   * @notice Event emitted when a user exchanges OUSG for USDC
   *
   * @param sender        Address of the transaction's message sender
   * @param ousgAmountIn  Amount of the OUSG burned for the redemption
   * @param usdcAmountOut Amount of usdc sent to the user
   */
  event InstantRedemptionOUSG(
    address indexed sender,
    uint256 ousgAmountIn,
    uint256 usdcAmountOut
  );

  /**
   * @notice Event emitted when a user exchanges rOUSG for USDC
   *
   * @param sender        Address of the transaction's message sender
   * @param rousgAmountIn Amount of the rOUSG burned for the redemption
   * @param ousgAmountIn  Amount of OUSG unwrapped for the user
   * @param usdcAmountOut Amount of USDC sent to the user
   */
  event InstantRedemptionRebasingOUSG(
    address indexed sender,
    uint256 rousgAmountIn,
    uint256 ousgAmountIn,
    uint256 usdcAmountOut
  );

  /**
   * @notice Event emitted for when a user performs a redemption of less than
   *         the minimum BUIDL redemption amount as required by BUIDL and MORE
   *         than the existing amount of USDC in the contract
   *
   * @param sender              Address of the transaction's message sender
   * @param buidlAmountRedeemed Amount of BUIDL that was redeemed
   * @param usdcAmountKept      Portion of USDC that was kept in the contract and
   *                            not sent back to the user
   */
  event MinimumBUIDLRedemption(
    address indexed sender,
    uint256 buidlAmountRedeemed,
    uint256 usdcAmountKept
  );

  /**
   * @notice Event emitted for when a user performs a redemption of less than
   *         the minimum BUIDL redemption amount as required by BUIDL and LESS
   *         than the existing amount of USDC in the contract
   *
   * @param sender              Address of the transaction's message sender
   * @param usdcAmountRedeemed  Amount of USDC sent back to the user
   * @param usdcAmountRemaining Amount of USDC remaining in the contract
   */
  event BUIDLRedemptionSkipped(
    address indexed sender,
    uint256 usdcAmountRedeemed,
    uint256 usdcAmountRemaining
  );

  /**
   * @notice Event emitted when mint functionality is paused
   */
  event MintPaused();

  /**
   * @notice Event emitted when mint functionality is unpaused
   */
  event MintUnpaused();

  /**
   * @notice Event emitted when redeem functionality is paused
   */
  event RedeemPaused();

  /**
   * @notice Event emitted when redeem functionality is unpaused
   */
  event RedeemUnpaused();

  /**
   * @notice Event emitted when mint fee is set
   *
   * @param oldMintFee Old fee collected for minting OUSG
   * @param newMintFee New fee collected for minting OUSG
   *
   * @dev See inheriting contract for representation
   */
  event MintFeeSet(uint256 oldMintFee, uint256 newMintFee);

  /**
   * @notice Event emitted when redeem fee is set
   *
   * @param oldRedeemFee Old fee collected for redeeming OUSG
   * @param newRedeemFee New fee collected for redeeming OUSG
   *
   * @dev See inheriting contract for representation
   */
  event RedeemFeeSet(uint256 oldRedeemFee, uint256 newRedeemFee);

  /**
   * @notice Event emitted when mint limit is set
   *
   * @param oldMinDepositAmount Old mint minimum
   * @param newMinDepositAmount New mint minimum
   */
  event MinimumDepositAmountSet(
    uint256 oldMinDepositAmount,
    uint256 newMinDepositAmount
  );

  /**
   * @notice Event emitted when redeem limit is set
   *
   * @param oldMinRedemptionAmount Old redeem minimum
   * @param newMinRedemptionAmount New redeem minimum
   */
  event MinimumRedemptionAmountSet(
    uint256 oldMinRedemptionAmount,
    uint256 newMinRedemptionAmount
  );

  /**
   * @notice Event emitted when minimum BUIDL redemption amount is set
   *
   * @param oldMinBUIDLRedemptionAmount Old minimum BUIDL minimum redemption amount
   * @param newMinBUIDLRedemptionAmount New minimum BUIDL minimum redemption amount
   */
  event MinimumBUIDLRedemptionAmountSet(
    uint256 oldMinBUIDLRedemptionAmount,
    uint256 newMinBUIDLRedemptionAmount
  );

  /**
   * @notice Event emitted when oracle is set
   *
   * @param oldOracle Old oracle address
   * @param newOracle New oracle address
   */
  event OracleSet(address oldOracle, address newOracle);

  /**
   * @notice Event emitted when fee receiver is set
   *
   * @param oldFeeReceiver Old fee receiver address
   * @param newFeeReceiver New fee receiver address
   */
  event FeeReceiverSet(address oldFeeReceiver, address newFeeReceiver);

  /**
   * @notice Event emitted when investor-based rate limiter is set
   *
   * @param oldInvestorBasedRateLimiter Old rate limiter address
   * @param newInvestorBasedRateLimiter New rate limiter address
   */
  event InvestorBasedRateLimiterSet(
    address oldInvestorBasedRateLimiter,
    address newInvestorBasedRateLimiter
  );
}
