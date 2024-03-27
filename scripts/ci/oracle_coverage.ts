import { parseUnits } from "ethers/lib/utils";
import { expect } from "chai";

import { increaseBlockTimestamp } from "../utils/util";

import { ethers } from "hardhat";
import { USDC_MAINNET } from "../../constants/constants";

let prices_August = [
  1.0, 1.00013368, 1.00026738, 1.00040109, 1.00053483, 1.00066858, 1.00080235,
  1.00093614, 1.00106994, 1.00120376, 1.0013376, 1.00147146, 1.00160534,
  1.00173923, 1.00187315, 1.00200708, 1.00214103, 1.00227499, 1.00240898,
  1.00254298, 1.002677, 1.00281104, 1.00294509, 1.00307917, 1.00321326,
  1.00334737, 1.00348149, 1.00361564, 1.0037498, 1.00388398, 1.00401818,
  1.00401818, 1.00401818,
];

async function main() {
  const signers = await ethers.getSigners();
  const augStart = 1690833600;
  const DAY = 86400;

  const guardian = signers[1];
  const setter = signers[2];
  const pauser = signers[3];
  const alice = signers[11];

  const usdc = await ethers.getContractAt("ERC20", USDC_MAINNET);
  const usdy = await ethers.getContract("USDY");
  const rusdy = await ethers.getContract("rUSDY");
  const oracle = await ethers.getContract("RWADynamicOracle");

  let currentStamp = await ethers.provider.getBlock("latest");
  console.log("The current block timestamp: ", currentStamp.timestamp);
  let diff = augStart - currentStamp.timestamp;
  console.log("The calculated diff is: ", diff);
  await increaseBlockTimestamp(diff);

  const allowlist = await ethers.getContract("Allowlist");
  await allowlist.connect(guardian).addTerm("Test Term 1");
  await allowlist.connect(guardian).setValidTermIndexes([0]);
  if (!(await allowlist.isAllowed(alice.address)))
    await allowlist.connect(alice).addSelfToAllowlist(0);
  if (!(await allowlist.isAllowed(guardian.address)))
    await allowlist.connect(guardian).addSelfToAllowlist(0);

  let MINTER_ROLE = await usdy.MINTER_ROLE();
  await usdy.connect(guardian).grantRole(MINTER_ROLE, guardian.address);
  await usdy.connect(guardian).mint(alice.address, parseUnits("100", 18));

  let balAlice = await usdy.balanceOf(alice.address);

  console.log(`Alice's balance is: ${balAlice.toString()}`);
  expect(balAlice, parseUnits("100", 18).toString());

  await usdy.connect(alice).approve(rusdy.address, parseUnits("100", 18));
  await rusdy.connect(alice).wrap(parseUnits("100", 18));

  let oraclePrice = await oracle.getPrice();
  console.log(`The oracle price is: `, oraclePrice.toString());
  console.log((await ethers.provider.getBlock("latest")).timestamp);

  for (let i = 0; i < 32; i++) {
    let price = await oracle.getPrice();
    let currentStamp = await ethers.provider.getBlock("latest");
    expect(price.toString()).to.be.eq(
      parseUnits(prices_August[i].toString(), 18).toString()
    );
    let rUSDYBalanceAlice = await rusdy.balanceOf(alice.address);
    let expectedBalanceAlice = parseUnits(
      prices_August[i].toString(),
      20
    ).toString();
    expect(rUSDYBalanceAlice.toString()).to.be.eq(expectedBalanceAlice);
    console.log(`\n The expected bal of alice ${expectedBalanceAlice}`);
    console.log(`Alice's rUSDY bal: ${rUSDYBalanceAlice.toString()}`);
    console.log(`The blocktimestamp is: ${currentStamp.timestamp}`);
    console.log(`Period ${i}: reports an oracle price of: ${price.toString()}`);
    await increaseBlockTimestamp(DAY, true);
  }
}

main();
