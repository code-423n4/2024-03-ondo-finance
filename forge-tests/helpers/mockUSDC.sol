pragma solidity 0.8.16;

import "contracts/external/openzeppelin/contracts/token/ERC20.sol";

contract MockUSDC is ERC20 {
  constructor() ERC20("USDC", "USDC") {}

  function decimals() public pure override returns (uint8) {
    return 6;
  }
}
