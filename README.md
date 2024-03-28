
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
* KYCRegistry.sol (Signature replay attack) - [see 2023-01-ondo#m-04](https://code4rena.com/reports/2023-01-ondo#m-04-kycregistry-is-susceptible-to-signature-replay-attack) is out of scope.
* Sanction or KYC related edge cases - specifically when a user’s `KYCRegistry` or Sanction status changes in between different actions, leaving them at risk of their funds being locked. If someone gets sanctioned on the Chainalysis Sanctions Oracle or removed from Ondo Finance’s KYC Registry their funds are locked.
* Malicious Admin/Operator - we are aware that admins have the ability to call various unrestrained setters, rOUSG burns, a retrieve Tokens function, and a multicall function. We would be open to suggestions on ways we can further restrain the setters without decreasing operational overhead, convenience, or flexibility of the code. The permissioned multicall function on OUSGInstantManager will only be used to transfer non-ERC20 assets out of the contract if the assets are accidentally deposited. Other permissioned usages of the multicall function resulting in problems are not valid.
* Third party integrations - The BUIDL token and existing BUIDL redeemer contract are not explicitly included and can be assumed to be “correct” for the sake of this audit.  However, if one can find flaws in the integration or even discover a path for a user (KYC’d or not) to cause a loss of funds for the protocol, it would be valid. At this time the BUIDL redeemer contract is not verified on Etherscan nor public, and its interface is inferred from existing on chain history associated with the BUIDL token.
* Rebasing Precision Issue - rOUSG is a rebasing tokens and some precision can be lost when wrapping and unwrapping. We expect this to only result in extremely small precision discrepancies. However, if one can find a realistic usage of the contracts that results in a non-trivial amount of imprecision, it would be valid.

Note: Invalid code paths will be weighted more heavily if they are publicly accessible versus if they are only accessible via a permissioned address.


# Overview

[ ⭐️ SPONSORS: add info here ]

## Links

- **Previous audits:**  N/A
- **Documentation:** https://docs.ondo.finance/
- **Website:** https://ondo.finance/
- **X/Twitter:** https://twitter.com/OndoFinance

---

# Scope

[ ✅ SCOUTS: add scoping and technical details here ]

### Files in scope

[ ⭐️ SPONSORS: please fill in the last 2 columns here ]


| File                                   | Logic Contracts | Interfaces | SLOC | Purpose | Libraries used |
|----------------------------------------|-----------------|------------|------|---------|----------------|
| contracts/ousg/ousg.sol               | 1               | ****       | 59   |         |                |
| contracts/ousg/ousgInstantManager.sol | 1               | ****       | 435  |         |                |
| contracts/ousg/ousgManager.sol        | 1               | ****       | 94   |         |                |
| contracts/ousg/rOUSG.sol              | 1               | ****       | 305  |         |                |
| contracts/ousg/rOUSGFactory.sol       | 1               | ****       | 77   |         |                |
| Totals                                 | 5               | ****       | 970  |         |                |

### Files out of scope

Anything not listed in the table above

## Scoping Q &amp; A

### General questions


| Question                                | Answer                       |
| --------------------------------------- | ---------------------------- |
| Test coverage                           | - |
| ERC20 used by the protocol              |       BUIDL, USDC, OUSG, rOUSG             |
| ERC721 used  by the protocol            |            None              |
| ERC777 used by the protocol             |           None                |
| ERC1155 used by the protocol            |              None            |
| Chains the protocol will be deployed on | Ethereum                      |

### ERC20 token behaviors in scope

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
A loss of funds for Ondo Finance, its token holders, or any other third parties that we integrate with. 


## All trusted roles in the protocol

The full list of roles can be compiled by viewing the various contracts in the system. 
OUSG.sol
rOUSG.sol
KYCRegistry.sol
OUSGInstantManager.sol


✅ SCOUTS: Please format the response above 👆 using the template below👇

| Role                                | Description                       |
| --------------------------------------- | ---------------------------- |
| Owner                          | Has superpowers                |
| Administrator                             | Can change fees                       |

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

To run gas benchmarks
```bash
npm run test-forge --gas-report
```

✅ SCOUTS: Add a screenshot of your terminal showing the gas report
✅ SCOUTS: Add a screenshot of your terminal showing the test coverage

## Miscellaneous
Employees of Ondo Finance and employees' family members are ineligible to participate in this audit.
