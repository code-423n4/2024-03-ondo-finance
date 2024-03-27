// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "contracts/external/openzeppelin/contracts/token/IERC20.sol";
import "contracts/interfaces/IBUIDLRedeemer.sol";

contract BUIDLRedeemerMock is IBUIDLRedeemer {
  IERC20 public buidl;
  IERC20 public USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

  constructor(address _buidl) {
    buidl = IERC20(_buidl);
  }

  function redeem(uint256 tokens) external override {
    buidl.transferFrom(msg.sender, address(this), tokens);
    USDC.transfer(msg.sender, tokens);
  }
}
