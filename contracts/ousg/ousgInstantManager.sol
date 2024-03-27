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

import "contracts/external/openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "contracts/external/openzeppelin/contracts/security/ReentrancyGuard.sol";
import "contracts/external/openzeppelin/contracts/token/IERC20Metadata.sol";
import "contracts/ousg/rOUSG.sol";
import "contracts/interfaces/IRWALike.sol";
import "contracts/interfaces/IBUIDLRedeemer.sol";
import "contracts/InstantMintTimeBasedRateLimiter.sol";
import "contracts/interfaces/IOUSGInstantManager.sol";
import "contracts/interfaces/IMulticall.sol";
import "contracts/interfaces/IInvestorBasedRateLimiter.sol";

/**
 * @title OUSGInstantManager
 * @author Ondo Finance
 * @notice This contract is responsible for minting
 *         and redeeming OUSG and rOUSG against USDC. Addresses
 *         with the DEFAULT_ADMIN_ROLE able to set optional mint and
 *         redeem fees. It is implemented in terms of a
 *         InstantMintTimeBasedRateLimiter, which imposes mint and redeem limits within
 *         specified intervals. Additionally, addresses with the PAUSER role in
 *         the registry can pause mints and redemptions, while addresses with
 *         the DEFAULT_ADMIN role can unpause mints or redemptions.
 *
 * @dev Please be aware of the differences of decimals representations between
 *      OUSG, rOUSG, USDC, and BUIDL. This contract multiplies
 *      or divides quantities by a scaling factor (see `decimalsMultiplier`) to
 *      account for this. Due to the way the difference in decimals is
 *      calculated, the decimals value of the usdc token MUST be less
 *      than or equal to OUSG's decimals value or else contract deployment
 *      will fail.
 */
contract OUSGInstantManager is
  ReentrancyGuard,
  InstantMintTimeBasedRateLimiter,
  AccessControlEnumerable,
  IOUSGInstantManager,
  IMulticall
{
  // Role to configure the contract
  bytes32 public constant CONFIGURER_ROLE = keccak256("CONFIGURER_ROLE");

  // Role to pause minting and redemptions
  bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

  // Safety circuit breaker in case of Oracle malfunction
  uint256 public constant MINIMUM_OUSG_PRICE = 105e18;

  // Helper constant that allows us to precisely specify fees in basis points
  uint256 public constant FEE_GRANULARITY = 10_000;

  // Helper constant that allows us to convert between OUSG and rOUSG shares
  uint256 public constant OUSG_TO_ROUSG_SHARES_MULTIPLIER = 10_000;

  // USDC contract
  IERC20 public immutable usdc; // 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

  // OUSG contract
  IRWALike public immutable ousg;

  // Rebasing OUSG Contract
  ROUSG public immutable rousg;

  // BUIDL token contract
  IERC20 public immutable buidl;

  // Redeemer contract used for instant redemptions of BUIDL
  IBUIDLRedeemer public immutable buidlRedeemer;

  // Scaling factor to account for differences in decimals between OUSG/rOUSG and BUIDL/USDC
  uint256 public immutable decimalsMultiplier;

  // The address that receives USDC for subscriptions
  address public immutable usdcReceiver;

  // Address of the oracle that provides the `ousgPrice`
  IRWAOracle public oracle;

  // The address in which USDC should be sent to as a fee for minting and redeeming
  address public feeReceiver;

  // Fee collected when minting OUSG (in basis points)
  uint256 public mintFee = 0;

  // Fee collected when redeeming OUSG (in basis points)
  uint256 public redeemFee = 0;

  // Minimum amount of USDC that must be deposited to mint OUSG or rOUSG
  // Denoted in 6 decimals for USDC
  uint256 public minimumDepositAmount = 100_000e6;

  // Minimum amount of USDC that must be redeemed for to redeem OUSG or rOUSG
  // Denoted in 6 decimals for USDC
  uint256 public minimumRedemptionAmount = 50_000e6;

  // Whether minting is paused for this contract
  bool public mintPaused;

  // Whether redemptions are paused for this contract
  bool public redeemPaused;

  // Optional investor-based rate limiting contract reference
  IInvestorBasedRateLimiter public investorBasedRateLimiter;

  /**
   * @notice Constructor.
   *
   * @param defaultAdmin        Address that receives all roles during init DEFAULT_ADMIN_ROLE
   * @param _usdc               USDC's token contract address
   * @param _usdcReciever       Address that receives USDC during minting
   * @param _feeReceiver        Address that receives mint and redemption fees
   * @param _ousgOracle         OUSG's oracle contract address
   * @param _ousg               OUSG's token contract address
   * @param _rousg              rOUSG's token contract address
   * @param _buidl              BUIDL token contract address
   * @param _buidlRedeemer      Contract address used for instant redemptions of BUIDL
   * @param rateLimiterConfig   See IOUSGInstantManager.sol & InstantMintTimeBasedRateLimiter.sol
   *
   * @dev We calculate `decimalsMultiplier` by subtracting OUSG's decimals by
   *      the `usdc` contract's decimals and performing 10 ^ difference.
   *      Deployment will fail if the difference is a negative number via
   *      runtime underflow protections provided by our solidity version.
   */
  constructor(
    address defaultAdmin,
    address _usdc,
    address _usdcReciever,
    address _feeReceiver,
    address _ousgOracle,
    address _ousg,
    address _rousg,
    address _buidl,
    address _buidlRedeemer,
    RateLimiterConfig memory rateLimiterConfig
  )
    InstantMintTimeBasedRateLimiter(
      rateLimiterConfig.mintLimitDuration,
      rateLimiterConfig.redeemLimitDuration,
      rateLimiterConfig.mintLimit,
      rateLimiterConfig.redeemLimit
    )
  {
    require(
      address(_usdc) != address(0),
      "OUSGInstantManager: USDC cannot be 0x0"
    );
    require(
      address(_usdcReciever) != address(0),
      "OUSGInstantManager: USDC Receiver cannot be 0x0"
    );
    require(
      address(_feeReceiver) != address(0),
      "OUSGInstantManager: feeReceiver cannot be 0x0"
    );
    require(
      address(_ousgOracle) != address(0),
      "OUSGInstantManager: OUSG Oracle cannot be 0x0"
    );
    require(_ousg != address(0), "OUSGInstantManager: OUSG cannot be 0x0");
    require(_rousg != address(0), "OUSGInstantManager: rOUSG cannot be 0x0");
    require(_buidl != address(0), "OUSGInstantManager: BUIDL cannot be 0x0");
    require(
      address(_buidlRedeemer) != address(0),
      "OUSGInstantManager: BUIDL Redeemer cannot be 0x0"
    );
    require(
      IERC20Metadata(_ousg).decimals() == IERC20Metadata(_rousg).decimals(),
      "OUSGInstantManager: OUSG decimals must be equal to USDC decimals"
    );
    require(
      IERC20Metadata(_usdc).decimals() == IERC20Metadata(_buidl).decimals(),
      "OUSGInstantManager: USDC decimals must be equal to BUIDL decimals"
    );
    usdc = IERC20(_usdc);
    usdcReceiver = _usdcReciever;
    feeReceiver = _feeReceiver;
    oracle = IRWAOracle(_ousgOracle);
    ousg = IRWALike(_ousg);
    rousg = ROUSG(_rousg);
    buidl = IERC20(_buidl);
    buidlRedeemer = IBUIDLRedeemer(_buidlRedeemer);
    decimalsMultiplier =
      10 **
        (IERC20Metadata(_ousg).decimals() - IERC20Metadata(_usdc).decimals());
    require(
      OUSG_TO_ROUSG_SHARES_MULTIPLIER ==
        rousg.OUSG_TO_ROUSG_SHARES_MULTIPLIER(),
      "OUSGInstantManager: OUSG to rOUSG shares multiplier must be equal to rOUSG's"
    );

    _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
    _grantRole(CONFIGURER_ROLE, defaultAdmin);
    _grantRole(PAUSER_ROLE, defaultAdmin);
  }

  /*//////////////////////////////////////////////////////////////
                            Mint/Redeem
  //////////////////////////////////////////////////////////////*/
  /**
   * @notice Calculates fees and triggers minting OUSG for a given amount of USDC
   *
   * @dev Please note that the fees are accumulated in `feeReceiver`
   *
   * @param usdcAmountIn amount of USDC exchanged for OUSG (in whatever decimals
   *                     specifed by usdc token contract)
   *
   * @return ousgAmountOut The quantity of OUSG minted for the user
   *                       (18 decimals per OUSG contract)
   */
  function mint(
    uint256 usdcAmountIn
  )
    external
    override
    nonReentrant
    whenMintNotPaused
    returns (uint256 ousgAmountOut)
  {
    ousgAmountOut = _mint(usdcAmountIn, msg.sender);
    emit InstantMintOUSG(msg.sender, usdcAmountIn, ousgAmountOut);
  }

  /**
   * @notice Calculates fees and triggers minting rOUSG for a given amount of USDC
   *
   * @dev Please note that the fees are accumulated in `feeReceiver`
   *
   * @param usdcAmountIn amount of USDC exchanged for rOUSG (in whatever decimals
   *                     specifed by usdc token contract)
   *
   * @return rousgAmountOut The quantity of rOUSG minted for the user
   *                        (18 decimals per rOUSG contract)
   */
  function mintRebasingOUSG(
    uint256 usdcAmountIn
  )
    external
    override
    nonReentrant
    whenMintNotPaused
    returns (uint256 rousgAmountOut)
  {
    uint256 ousgAmountOut = _mint(usdcAmountIn, address(this));
    ousg.approve(address(rousg), ousgAmountOut);
    rousg.wrap(ousgAmountOut);
    rousgAmountOut = rousg.getROUSGByShares(
      ousgAmountOut * OUSG_TO_ROUSG_SHARES_MULTIPLIER
    );
    rousg.transfer(msg.sender, rousgAmountOut);
    emit InstantMintRebasingOUSG(
      msg.sender,
      usdcAmountIn,
      ousgAmountOut,
      rousgAmountOut
    );
  }

  function _mint(
    uint256 usdcAmountIn,
    address to
  ) internal returns (uint256 ousgAmountOut) {
    require(
      IERC20Metadata(address(usdc)).decimals() == 6,
      "OUSGInstantManager::_mint: USDC decimals must be 6"
    );
    require(
      usdcAmountIn >= minimumDepositAmount,
      "OUSGInstantManager::_mint: Deposit amount too small"
    );
    _checkAndUpdateInstantMintLimit(usdcAmountIn);
    if (address(investorBasedRateLimiter) != address(0)) {
      investorBasedRateLimiter.checkAndUpdateMintLimit(
        msg.sender,
        usdcAmountIn
      );
    }

    require(
      usdc.allowance(msg.sender, address(this)) >= usdcAmountIn,
      "OUSGInstantManager::_mint: Allowance must be given to OUSGInstantManager"
    );

    uint256 usdcfees = _getInstantMintFees(usdcAmountIn);
    uint256 usdcAmountAfterFee = usdcAmountIn - usdcfees;

    // Calculate the mint amount based on mint fees and usdc quantity
    uint256 ousgPrice = getOUSGPrice();
    ousgAmountOut = _getMintAmount(usdcAmountAfterFee, ousgPrice);

    require(
      ousgAmountOut > 0,
      "OUSGInstantManager::_mint: net mint amount can't be zero"
    );

    // Transfer USDC
    if (usdcfees > 0) {
      usdc.transferFrom(msg.sender, feeReceiver, usdcfees);
    }
    usdc.transferFrom(msg.sender, usdcReceiver, usdcAmountAfterFee);

    emit MintFeesDeducted(msg.sender, feeReceiver, usdcfees, usdcAmountIn);

    ousg.mint(to, ousgAmountOut);
  }

  /**
   * @notice Calculates fees and triggers a redemption of OUSG for a given amount of USDC
   *
   * @dev Please note that the fees are accumulated in `feeReceiver`
   *
   * @param ousgAmountIn Amount of OUSG to redeem
   *
   * @return usdcAmountOut The amount of USDC returned to the user
   */
  function redeem(
    uint256 ousgAmountIn
  )
    external
    override
    nonReentrant
    whenRedeemNotPaused
    returns (uint256 usdcAmountOut)
  {
    require(
      ousg.allowance(msg.sender, address(this)) >= ousgAmountIn,
      "OUSGInstantManager::redeem: Insufficient allowance"
    );
    ousg.transferFrom(msg.sender, address(this), ousgAmountIn);
    usdcAmountOut = _redeem(ousgAmountIn);
    emit InstantRedemptionOUSG(msg.sender, ousgAmountIn, usdcAmountOut);
  }

  /**
   * @notice Calculates fees and triggers minting rOUSG for a given amount of USDC
   *
   * @dev Please note that the fees are actually accumulated in `feeReceiver`
   *
   * @param rousgAmountIn Amount of rOUSG to redeem
   *
   * @return usdcAmountOut The amount of USDC returned to the user
   */
  function redeemRebasingOUSG(
    uint256 rousgAmountIn
  )
    external
    override
    nonReentrant
    whenRedeemNotPaused
    returns (uint256 usdcAmountOut)
  {
    require(
      rousg.allowance(msg.sender, address(this)) >= rousgAmountIn,
      "OUSGInstantManager::redeemRebasingOUSG: Insufficient allowance"
    );
    rousg.transferFrom(msg.sender, address(this), rousgAmountIn);
    rousg.unwrap(rousgAmountIn);
    uint256 ousgAmountIn = rousg.getSharesByROUSG(rousgAmountIn) /
      OUSG_TO_ROUSG_SHARES_MULTIPLIER;
    usdcAmountOut = _redeem(ousgAmountIn);
    emit InstantRedemptionRebasingOUSG(
      msg.sender,
      rousgAmountIn,
      ousgAmountIn,
      usdcAmountOut
    );
  }

  function _redeem(
    uint256 ousgAmountIn
  ) internal returns (uint256 usdcAmountOut) {
    require(
      IERC20Metadata(address(usdc)).decimals() == 6,
      "OUSGInstantManager::_redeem: USDC decimals must be 6"
    );
    require(
      IERC20Metadata(address(buidl)).decimals() == 6,
      "OUSGInstantManager::_redeem: BUIDL decimals must be 6"
    );

    uint256 ousgPrice = getOUSGPrice();
    uint256 usdcAmountToRedeem = _getRedemptionAmount(ousgAmountIn, ousgPrice);

    require(
      usdcAmountToRedeem >= minimumRedemptionAmount,
      "OUSGInstantManager::_redeem: Redemption amount too small"
    );
    _checkAndUpdateInstantRedemptionLimit(usdcAmountToRedeem);

    if (address(investorBasedRateLimiter) != address(0)) {
      investorBasedRateLimiter.checkAndUpdateRedeemLimit(
        msg.sender,
        usdcAmountToRedeem
      );
    }

    uint256 usdcFees = _getInstantRedemptionFees(usdcAmountToRedeem);
    usdcAmountOut = usdcAmountToRedeem - usdcFees;
    require(
      usdcAmountOut > 0,
      "OUSGInstantManager::_redeem: redeem amount can't be zero"
    );

    require(
      buidl.balanceOf(address(this)) > usdcAmountToRedeem,
      "OUSGInstantManager::_redeem: Insufficient BUIDL balance"
    );

    ousg.burn(ousgAmountIn);
    buidl.approve(address(buidlRedeemer), usdcAmountToRedeem);

    buidlRedeemer.redeem(usdcAmountToRedeem);

    if (usdcFees > 0) {
      usdc.transfer(feeReceiver, usdcFees);
    }

    emit RedeemFeesDeducted(msg.sender, feeReceiver, usdcFees, usdcAmountOut);
    usdc.transfer(msg.sender, usdcAmountOut);
  }

  /**
   * @notice Returns the current price of OUSG in USDC
   *
   * @dev Sanity check: this function will revert if the price is unexpectedly low
   *
   * @return price The current price of OUSG in USDC
   */
  function getOUSGPrice() public view returns (uint256 price) {
    (price, ) = oracle.getPriceData();
    require(
      price > MINIMUM_OUSG_PRICE,
      "OUSGInstantManager::getOUSGPrice: Price unexpectedly low"
    );
  }

  /*//////////////////////////////////////////////////////////////
                    Rate Limiter Configuration
  //////////////////////////////////////////////////////////////*/
  /**
   * @notice Set the mintLimit constraint inside the InstantMintTimeBasedRateLimiter
   *         base contract
   *
   * @param _instantMintLimit New limit that dicates how much USDC can be transfered
   *                     for minting in a specified duration
   *                     (in 6 decimals per the USDC contract)
   */
  function setInstantMintLimit(
    uint256 _instantMintLimit
  ) external override onlyRole(CONFIGURER_ROLE) {
    _setInstantMintLimit(_instantMintLimit);
  }

  /**
   * @notice Set the redeemLimit constraint inside the InstantMintTimeBasedRateLimiter
   *         base contract
   *
   * @param _instantRedemptionLimit New limit that dicates how much USDC
   *                       can be redeemed in a specified duration
   *                       (in 6 decimals per the USDC contract)
   */
  function setInstantRedemptionLimit(
    uint256 _instantRedemptionLimit
  ) external override onlyRole(CONFIGURER_ROLE) {
    _setInstantRedemptionLimit(_instantRedemptionLimit);
  }

  /**
   * @notice Sets mintLimitDuration constraint inside the InstantMintTimeBasedRateLimiter
   *         base contract
   *
   * @param _instantMintLimitDuration New limit that specifies the interval
   *                             (in seconds) in which only `mintLimit` USDC
   *                             can be used for minting within
   */
  function setInstantMintLimitDuration(
    uint256 _instantMintLimitDuration
  ) external override onlyRole(CONFIGURER_ROLE) {
    _setInstantMintLimitDuration(_instantMintLimitDuration);
  }

  /**
   * @notice Sets redeemLimitDuration inside the InstantMintTimeBasedRateLimiter
   *         base contract
   *
   * @param _instantRedemptionLimitDuratioin New limit that specifies the interval
   *                               (in seconds) in which only `redeemLimit` USDC
   *                               can be redeemed within
   */
  function setInstantRedemptionLimitDuration(
    uint256 _instantRedemptionLimitDuratioin
  ) external override onlyRole(CONFIGURER_ROLE) {
    _setInstantRedemptionLimitDuration(_instantRedemptionLimitDuratioin);
  }

  /*//////////////////////////////////////////////////////////////
                    Mint/Redeem Configuration
  //////////////////////////////////////////////////////////////*/
  /**
   * @notice Sets the mint fee
   *
   * @param _mintFee new mint fee specified in basis points
   */
  function setMintFee(
    uint256 _mintFee
  ) external override onlyRole(CONFIGURER_ROLE) {
    require(mintFee < 200, "OUSGInstantManager::setMintFee: Fee too high");
    emit MintFeeSet(mintFee, _mintFee);
    mintFee = _mintFee;
  }

  /**
   * @notice Sets the redeem fee.
   *
   * @param _redeemFee new redeem fee specified in basis points
   */
  function setRedeemFee(
    uint256 _redeemFee
  ) external override onlyRole(CONFIGURER_ROLE) {
    require(redeemFee < 200, "OUSGInstantManager::setRedeemFee: Fee too high");
    emit RedeemFeeSet(redeemFee, _redeemFee);
    redeemFee = _redeemFee;
  }

  /**
   * @notice Admin function to set the minimum amount required for a deposit
   *
   * @param _minimumDepositAmount The minimum amount required to submit a deposit
   *                          request
   */
  function setMinimumDepositAmount(
    uint256 _minimumDepositAmount
  ) external override onlyRole(CONFIGURER_ROLE) {
    require(
      _minimumDepositAmount >= FEE_GRANULARITY,
      "setMinimumDepositAmount: Amount too small"
    );

    emit MinimumDepositAmountSet(minimumDepositAmount, _minimumDepositAmount);
    minimumDepositAmount = _minimumDepositAmount;
  }

  /**
   * @notice Admin function to set the minimum amount to redeem
   *
   * @param _minimumRedemptionAmount The minimum amount required to submit a
   *                                 redemption request
   */
  function setMinimumRedemptionAmount(
    uint256 _minimumRedemptionAmount
  ) external override onlyRole(CONFIGURER_ROLE) {
    require(
      _minimumRedemptionAmount >= FEE_GRANULARITY,
      "setMinimumRedemptionAmount: Amount too small"
    );
    emit MinimumRedemptionAmountSet(
      minimumRedemptionAmount,
      _minimumRedemptionAmount
    );
    minimumRedemptionAmount = _minimumRedemptionAmount;
  }

  /*//////////////////////////////////////////////////////////////
                    General Configuration
  //////////////////////////////////////////////////////////////*/
  /**
   * @notice Admin function to set the oracle address
   *
   * @param _oracle The address of the oracle that provides the OUSG price
   *                in USDC
   */
  function setOracle(
    address _oracle
  ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
    emit OracleSet(address(oracle), _oracle);
    oracle = IRWAOracle(_oracle);
  }

  /**
   * @notice Admin function to set the fee receiver address

   * @param _feeReceiver The address to receive the mint and redemption fees
   */
  function setFeeReceiver(
    address _feeReceiver
  ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
    require(_feeReceiver != address(0), "FeeReceiver cannot be 0x0");
    emit FeeReceiverSet(feeReceiver, _feeReceiver);
    feeReceiver = _feeReceiver;
  }

  function setInvestorBasedRateLimiter(
    address _investorBasedRateLimiter
  ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
    emit InvestorBasedRateLimiterSet(
      address(investorBasedRateLimiter),
      _investorBasedRateLimiter
    );
    investorBasedRateLimiter = IInvestorBasedRateLimiter(
      _investorBasedRateLimiter
    );
  }

  /*//////////////////////////////////////////////////////////////
                  Helper fee conversion functions
  //////////////////////////////////////////////////////////////*/

  /**
   * @notice Given a deposit amount and a price, returns the OUSG amount due
   *
   * @param usdcAmountIn The amount deposited in units of USDC
   * @param price        The price at which to mint
   */
  function _getMintAmount(
    uint256 usdcAmountIn,
    uint256 price
  ) internal view returns (uint256 ousgAmountOut) {
    uint256 amountE36 = _scaleUp(usdcAmountIn) * 1e18;
    ousgAmountOut = amountE36 / price;
  }

  /**
   * @notice Given a redemption amount and a price, returns the USDC amount due
   *
   * @param ousgAmountBurned The amount of OUSG burned for a redemption
   * @param price            The price at which to redeem
   */
  function _getRedemptionAmount(
    uint256 ousgAmountBurned,
    uint256 price
  ) internal view returns (uint256 usdcOwed) {
    uint256 amountE36 = ousgAmountBurned * price;
    usdcOwed = _scaleDown(amountE36 / 1e18);
  }

  /**
   * @notice Given amount of USDC, returns how much in fees are owed
   *
   * @param usdcAmount Amount of USDC to calculate fees
   *                   (in 6 decimals)
   */
  function _getInstantMintFees(
    uint256 usdcAmount
  ) internal view returns (uint256) {
    return (usdcAmount * mintFee) / FEE_GRANULARITY;
  }

  /**
   * @notice Given amount of USDC, returns how much in fees are owed
   *
   * @param usdcAmount Amount USDC to calculate fees
   *                   (in decimals of USDC)
   */
  function _getInstantRedemptionFees(
    uint256 usdcAmount
  ) internal view returns (uint256) {
    return (usdcAmount * redeemFee) / FEE_GRANULARITY;
  }

  /**
   * @notice Scale provided amount up by `decimalsMultiplier`
   *
   * @dev This helper is used for converting a USDC amount's decimals
   *      representation to the rOUSG/OUSG decimals representation.
   */
  function _scaleUp(uint256 amount) internal view returns (uint256) {
    return amount * decimalsMultiplier;
  }

  /**
   * @notice Scale provided amount down by `decimalsMultiplier`
   *
   * @dev This helper is used for converting an rOUSG/OUSG amount's decimals
   *      representation to the USDC decimals representation.
   */
  function _scaleDown(uint256 amount) internal view returns (uint256) {
    return amount / decimalsMultiplier;
  }

  /*//////////////////////////////////////////////////////////////
                          Pause/Unpause
  //////////////////////////////////////////////////////////////*/

  /// @notice Ensure that the mint functionality is not paused
  modifier whenMintNotPaused() {
    require(!mintPaused, "OUSGInstantManager: Mint paused");
    _;
  }

  /// @notice Ensure that the redeem functionality is not paused
  modifier whenRedeemNotPaused() {
    require(!redeemPaused, "OUSGInstantManager: Redeem paused");
    _;
  }

  /// @notice Pause the mint functionality
  function pauseMint() external onlyRole(PAUSER_ROLE) {
    mintPaused = true;
    emit MintPaused();
  }

  /// @notice Unpause the mint functionality
  function unpauseMint() external onlyRole(DEFAULT_ADMIN_ROLE) {
    mintPaused = false;
    emit MintUnpaused();
  }

  /// @notice Pause the redeem functionality
  function pauseRedeem() external onlyRole(PAUSER_ROLE) {
    redeemPaused = true;
    emit RedeemPaused();
  }

  /// @notice Unpause the redeem functionality
  function unpauseRedeem() external onlyRole(DEFAULT_ADMIN_ROLE) {
    redeemPaused = false;
    emit RedeemUnpaused();
  }

  /*//////////////////////////////////////////////////////////////
                          Miscellaneous
  //////////////////////////////////////////////////////////////*/
  function multiexcall(
    ExCallData[] calldata exCallData
  )
    external
    payable
    override
    onlyRole(DEFAULT_ADMIN_ROLE)
    returns (bytes[] memory results)
  {
    results = new bytes[](exCallData.length);
    for (uint256 i = 0; i < exCallData.length; ++i) {
      (bool success, bytes memory ret) = address(exCallData[i].target).call{
        value: exCallData[i].value
      }(exCallData[i].data);
      require(success, "Call Failed");
      results[i] = ret;
    }
  }

  /**
   * @notice Rescue and transfer tokens locked in this contract
   * @param token The address of the token
   * @param to The address of the recipient
   * @param amount The amount of token to transfer
   */
  function retrieveTokens(
    address token,
    address to,
    uint256 amount
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    IERC20(token).transfer(to, amount);
  }
}
