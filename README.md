
# Ondo Finance audit details
- Total Prize Pool: $36,500 in USDC
  - HM awards: $28,800 in USDC
  - QA awards: $1,200 in USDC
  - Judge awards: $3600 in USDC
  - Lookout awards: $2,400 in USDC
  - Scout awards: $500 in USDC

- Join [C4 Discord](https://discord.gg/code4rena) to register
- Submit findings [using the C4 form](https://code4rena.com/contests/2024-03-ondo-finance/submit)
- [Read our guidelines for more details](https://docs.code4rena.com/roles/wardens)
- Starts March 29, 2024 20:00 UTC
- Ends April 3, 2024 20:00 UTC

## Automated Findings / Publicly Known Issues

The 4naly3er report can be found [here](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/4naly3er-report.md).



_Note for C4 wardens: Anything included in this `Automated Findings / Publicly Known Issues` section is considered a publicly known issue and is ineligible for awards._

* Price/Rebasing Arbitrage Risk - We are aware that KYC’d users (using MEV or not) can purchase OUSG or rOUSG before a price increase and then sell OUSG or rOUSG after, resulting in a profit in the form of USDC. This will be mitigated in the short term through off chain agreements with KYC’d investors, mint and redeem fees, and global rate limits.
* OUSG Price - The OUSG price tracks an off chain portfolio of cash equivalents and treasury bills, price changes are heavily constrained in the OUSG Oracle, which uses the change in the price of SHV to set the allowable OUSG price in between updates. We are aware that the SHV price could differ from the OUSG portfolio, so any findings related to this price discrepancy is out of scope. Also, scenarios where the OUSG price increases by many orders of magnitudes are not realistic and consequently not considered valid.
* Price Decreases - We are aware that an extreme change in the price of SHV could prevent Ondo Finance from accurately reporting the OUSG price in its oracle. We are also aware that the code does not prevent a “negative rebase” in the event that the OUSG price goes down.
* DDOS-ing OUSGInstantManager Rate limiter - We are aware that KYC’d investors can DDOS the instant mint/redeem contract.
* Centralization Risk - we are aware that our management functions and contract upgradeability results in a centralized system.
* Sanction or KYC related edge cases - specifically when a user’s `KYCRegistry` or Sanction status changes in between different actions, leaving them at risk of their funds being locked. If someone gets sanctioned on the Chainalysis Sanctions Oracle or removed from Ondo Finance’s KYC Registry their funds are locked.
* Malicious Admin/Operator - we are aware that admins have the ability to call various unrestrained setters, rOUSG burns, a retrieve Tokens function, and a multicall function. We would be open to suggestions on ways we can further restrain the setters without decreasing operational overhead, convenience, or flexibility of the code. The permissioned multicall function on OUSGInstantManager will only be used to transfer non-ERC20 assets out of the contract if the assets are accidentally deposited. Other permissioned usages of the multicall function resulting in problems are not valid.
* Third party integrations - The BUIDL token and existing BUIDL redeemer contract are not explicitly included and can be assumed to be “correct” for the sake of this audit.  However, if one can find flaws in the integration or even discover a path for a user (KYC’d or not) to cause a loss of funds for the protocol, it would be valid. At this time the BUIDL redeemer contract is not verified on Etherscan nor public, and its interface is inferred from existing on chain history associated with the BUIDL token.
* Rebasing Precision Issue - rOUSG is a rebasing tokens and some precision can be lost when wrapping and unwrapping. We expect this to only result in extremely small precision discrepancies. However, if one can find a realistic usage of the contracts that results in a non-trivial amount of imprecision, it would be valid.
* We are aware that USDC may be leftover and held within OUSGInstantManager when a user performs a redemption that is more than the minimumRedemption amount and less than the minimumBUIDLRedemption amount. We are also aware that this may cause temporary "cash drag" for the overall OUSG portfolio as USDC in the OUSGInstantManager contract does not earn yield.  USDC may be utilized at a later time for servicing redemptions less than the minimumBUIDLRedemption amount OR retrieved through the permissioned retrieveTokens function.
* We are aware that if all BUIDL has been redeemed from our contract, we would not be able to provide instant redemptions for OUSG or rOUSG. We are also aware that there may be some USDC leftover in the contract that wouldn't be redeemable in this scenario.
* KYCRegistry.sol (Signature replay attack) - [ 2023-01-ondo#m-04](https://code4rena.com/reports/2023-01-ondo#m-04-kycregistry-is-susceptible-to-signature-replay-attack) is out of scope.

Note: Invalid code paths will be weighted more heavily if they are publicly accessible versus if they are only accessible via a permissioned address.


# Overview

## Background on KYCRegistry
The KYCRegistry acts as a whitelist for Ondo's permissioned tokens. OUSG and rOUSG token contracts query this registry to check that addresses are KYC verified before executing certain actions.
Users are added and removed from the KYC list via permissioned functions.

### Background on OUSG
The OUSG contract is an upgradeable (Transparent Upgradeable Proxy) with transfer restrictions based on a KYC Registry. In order to hold, send and receive OUSG. A user will need to be added the [KYCRegistry](https://etherscan.io/address/0x7cE91291846502D50D635163135B2d40a602dc70), and not be on the Chainalsysis [sanctions list](https://etherscan.io/address/0x40C57923924B5c5c5455c48D93317139ADDaC8fb)

OUSG is backed by an off chain portfolio comprised of cash equivalents. The price of OUSG tracks this portfolio's performance minus management fees. OUSG is supported in collateral-only mode on the Flux Finance protocol.

### Background on the OUSG Price Oracle
The current price of OUSG is pulled from the oracle contract [`RWAOracleExternalComparisonCheck.sol`](https://etherscan.io/address/0x0502c5ae08E7CD64fe1AEDA7D6e229413eCC6abe). This oracle uses the change in the SHV ETF price (determined by pulling from a Chainlink Oracle) to constrain what price can be set by Ondo Finance.

### New Code: Introduction to Rebasing OUSG (rOUSG)
`rOUSG` Is an upgradeable rebasing token that be thought of as a "reverse wrapped" version of OUSG. It allows users to hold a rebasing variant of Ondo's OUSG (Ondo US Short Term Government Bond) token.  Each rOUSG token is worth 1 dollar, as OUSG accrues value (appreciates in price) rOUSG will rebase accordingly. Where as the price of a single OUSG token varies over time, the price of a single rOUSG token is fixed at a price of 1 dollar, with yield being accrued in the form of additional rOUSG tokens.

Individuals who hold OUSG are able to wrap their OUSG tokens by calling `rOUSG::wrap(uint256)` and receive a proportional amount of rOUSG tokens based on the current OUSG Oracle price. Similarly, when a user wishes to convert their `rOUSG` to `OUSG` they are able to call the `rOUSG::unwrap(uint256)` and receive the corresponding amount of `OUSG`.

It inherits the KYC restrictions of OUSG in that a user will need to be added the [KYCRegistry](https://etherscan.io/address/0x7cE91291846502D50D635163135B2d40a602dc70) in order to hold, send and receive rOUSG.
Much of rOUSG's code was taken from rUSDY, which was audited by C4 [here](https://code4rena.com/reports/2023-09-ondo). Much of the `rUSDY`'s code was influenced from Lido's `stETH`.

### New Code: Introduction to OUSGInstantManager
This contract allows for instant mints and instant redemptions of OUSG and rOUSG. It optionally supports mint fees, redemption fees, fine grained pausing and access control, mint minimums, redemption minimums, and a global interval based rate limiter. It also has a hook for investor based rate limits to be integrated with on a later date. For minting OUSG and rOUSG, KYC'd users will grant USDC approval to this contract and then call `OUSGInstantManager::mint(uint256)` or `OUSGInstantManager::mintRebasingOUSG(uint256)` respectively. These functions will transfer fees in the form of USDC to `feeReceiver`, route the remaining USDC to `usdcReceiver`, and then use the Oracle price to mint the appropriate amount of OUSG to the investor. If `OUSGInstantManager::mintRebasingOUSG(uint256)` is called, they code will wrap the `OUSG` into `rOUSG` for the user as well.

Redemptions work similarly in that `OUSG` or `rOUSG` is burned and USDC is returned to the user. To source the USDC liquidity, this contract will hold the [BUIDL token](https://etherscan.io/token/0x7712c34205737192402172409a8f7ccef8aa2aec) and interact with a currently unknown third party contract that swaps BUIDL for USDC. Unfortunately, the third party `BUIDL`-to-`USDC` swap functionality is not yet verified or confirmed as this time, but for the sake of this audit it can be assumed to be correct. The interface that this contract uses for `BUIDL`-to-`USDC` swaps has been inferred from public [transactions](https://etherscan.io/tx/0xf723727e0a6e779d20581c19c2c7d78354b24d744ce3acbca23ac6242a054fb4) on Etherscan. 1 BUIDL can always be assumed to be worth 1 USDC.

There is a BUIDL redemption minimum requirement that can assumed to be 250,000 BUIDL tokens that we do not to inherit for `OUSG`/`rOUSG` holders. To bypass this,
we have added logic to ensure that the minimum amount of BUIDL that this contract redeems is always at least 250,000. As a consequence, there will sometimes be leftover USDC held inthe contract. (e.g. An investor redeems $200k worth of OUSG, resulting in a $250k redemption worth of BUIDL, and 50k USDC leftover in the contract). We also have logic to use the USDC to cover the redemptions when the redemption amount is less than the contracts USDC balance.

Ondo Finance will be responsible for ensuring enough BUIDL is in the contract at all times to satisfy investor redemptions.

## Links

- **Previous audits:**  N/A
- **Documentation:** https://docs.ondo.finance/
- **Website:** https://ondo.finance/
- **X/Twitter:** https://twitter.com/OndoFinance

---

# Scope

### Files in scope


| File                                   | Logic Contracts | Interfaces | SLOC | Purpose | Libraries used |
|----------------------------------------|-----------------|------------|------|---------|----------------|
| contracts/ousg/ousgInstantManager.sol | 1               | ****       | 469  |   Allows for instant mints and redemptions for OUSG and rOUSG      |   OZ:AccessControlEnumerable,ReentrancyGuard          |
| contracts/ousg/rOUSG.sol              | 1               | ****       | 305  |   A rebasing version of OUSG      |  OZ: Initializable,ContextUpgradeable,PausableUpgradeable,AccessControlEnumerableUpgradeable              |
| contracts/ousg/rOUSGFactory.sol       | 1               | ****       | 77   |  Helper for a safe rOUSG deployment       |                |
| Totals                                 | 5               | ****      | 851  |         |                |

### Files out of scope

Anything not listed in the table above

## Scoping Q &amp; A

### General questions


| Question                                | Answer                       |
| --------------------------------------- | ---------------------------- |
| Test coverage                           | 79.8% (217/272 statements) |
| ERC20 used by the protocol              |       BUIDL, USDC, OUSG, rOUSG             |
| ERC721 used  by the protocol            |           None              |
| ERC777 used by the protocol             |           None                |
| ERC1155 used by the protocol            |           None            |
| Chains the protocol will be deployed on | Ethereum                      |

### ERC20 token behaviors in scope

- The only tokens in scope are: BUIDL, USDC, OUSG, rOUSG.
- Vulnerabilities related to these token behaviours are only considered valid if they actually exist in tokens which are used, i.e. BUIDL.

| Question                                                                                                                                                   | Answer |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| [Missing return values](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#missing-return-values)                                                      | ❌ No  |
| [Fee on transfer](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#fee-on-transfer)                                                                  | ❌ No  |
| [Balance changes outside of transfers](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#balance-modifications-outside-of-transfers-rebasingairdrops) | ✅Yes    |
| [Upgradeability](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#upgradable-tokens)                                                                 | ❌ No  |
| [Flash minting](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#flash-mintable-tokens)                                                              | ✅ Yes    |
| [Pausability](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#pausable-tokens)                                                                      | ✅ Yes    |
| [Approval race protections](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#approval-race-protections)                                              | ✅ Yes    |
| [Revert on approval to zero address](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-approval-to-zero-address)                            | ✅ Yes    |
| [Revert on zero value approvals](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-zero-value-approvals)                                    | ✅ Yes    |
| [Revert on zero value transfers](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-zero-value-transfers)                                    | ✅ Yes    |
| [Revert on transfer to the zero address](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-transfer-to-the-zero-address)                    | ✅ Yes    |
| [Revert on large approvals and/or transfers](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-large-approvals--transfers)                  | ✅ Yes    |
| [Doesn't revert on failure](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#no-revert-on-failure)                                                   | ✅ Yes   |
| [Multiple token addresses](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-zero-value-transfers)                                          | ✅ Yes    |
| [Low decimals ( < 6)](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#low-decimals)                                                                 | ✅ Yes  |
| [High decimals ( > 18)](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#high-decimals)                                                              | ✅ Yes    |
| [Blocklists](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#tokens-with-blocklists)                                                                | ❌ No    |

### External integrations (e.g., Uniswap) behavior in scope:


| Question                                                  | Answer |
| --------------------------------------------------------- | ------ |
| Enabling/disabling fees (e.g. Blur disables/enables fees) | No   |
| Pausability (e.g. Uniswap pool gets paused)               |  No   |
| Upgradeability (e.g. Uniswap gets upgraded)               |   No  |


### EIP compliance checklist
We strive to keep rOUSG as ERC20 compliant as possible.


# Additional context

## Main invariants

* OUSG & rOUSG can not be instant minted .
* BUIDL and USDC can not be transferred to arbitrary addresses.
* USDC is not permanently locked.


## Attack ideas (where to focus for bugs)
- Anything that results in a loss of funds for Ondo Finance, its token holders, or any other third parties that we integrate with.
- Anything that results in funds being frozen (outside of centralized whitelist or blockslists)
- Any ways for malicious investors to use redemptions to convert all of Ondo's BUIDL tokens to USDC sitting in the OUSGInstantManager contract.
- Any issues with rebasing logic that would result in "accounting discrpecancies."
- Any ways to subvert the KYC whitelist.


## All trusted roles in the protocol

Roles for contracts under audit:
### OUSGInstantManager.sol
| Role                                | Description                       |
| --------------------------------------- | ---------------------------- |
| Default Admin                          | Can grant all other roles and call critical admin functions for the contract  (`setOracle`, `setFeeReceiver`, `setMinimumBUIDLRedemptionAmount`, `setInvestorBasedRateLimiter`)              |
| Configurer                             | Can call semi-critical admin functions for the contract (`setMinimumRedemptionAmount`, `setMinimumDepositAmount`, `setRedeemFee`, `setMintFee`, and all global rate limiter based setters from `InstantMintTimeBasedRateLimiter.sol` )                      |
| Pauser                                 | Can pause mints or redeems                       |

## rOUSG.sol
| Role                                | Description                       |
| --------------------------------------- | ---------------------------- |
| Default Admin                          | Can grant all other roles and call critical admin functions for the contract  (`setOracle`,)              |
| Configurer                             | Can call semi-critical admin functions for the contract (`setKYCRegistry`, `setKYCRequirementGroup` )                      |
| Burner                                 | Can admin burn other holders' rOUSG tokens |
| Pauser                                 | Can pause the token contract |

## Describe any novel or unique curve logic or mathematical models implemented in the contracts:

N/A


## Running tests


```bash
## - Install forge
## - Install Node >= 16
git clone https://github.com/code-423n4/2024-03-ondo-finance.git
git submodule update --init --recursive
cd 2024-03-ondo-finance.git
foundryup
yarn install
cp .env.example .env

### In the .env file:
###          - Ensure `FORK_FROM_BLOCK_NUMBER` is set to 19505904
###          - Fill in a dummy menmonic
###          - Add an RPC URL to populate `MAINNET_RPC_URL`

yarn init-repo
npm run test-forge
```

To run gas benchmarks:
```bash
npm run test-forge -- --gas-report

## OR

### This only shows gas per test
forge snapshot --fork-url $(grep -w ETHEREUM_RPC_URL .env | cut -d '=' -f2) --fork-block-number $(grep -w FORK_FROM_BLOCK_NUMBER_MAINNET .env | cut -d '=' -f2) --nmc ASSERT_FORK
```

To run coverage:
```bash
forge coverage --fork-url $(grep -w ETHEREUM_RPC_URL .env | cut -d '=' -f2) --fork-block-number $(grep -w FORK_FROM_BLOCK_NUMBER_MAINNET .env | cut -d '=' -f2) --nmc ASSERT_FORK
```


#### Gas report
See [gas-report.txt](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/gas-report.txt)

#### Coverage 
| File                                  | % Lines           | % Statements      | % Branches       | % Funcs          |
|---------------------------------------|-------------------|-------------------|------------------|------------------|
| contracts/ousg/ousgInstantManager.sol | 74.77% (83/111)   | 77.21% (105/136)  | 50.00% (25/50)   | 90.62% (29/32)   |
| contracts/ousg/rOUSG.sol              | 86.67% (91/105)   | 86.21% (100/116)  | 70.00% (28/40)   | 88.57% (31/35)   |
| contracts/ousg/rOUSGFactory.sol       | 68.75% (11/16)    | 60.00% (12/20)    | 33.33% (2/6)     | 50.00% (1/2)     |


## Miscellaneous
Employees of Ondo Finance and employees' family members are ineligible to participate in this audit.
