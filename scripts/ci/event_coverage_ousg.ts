import { waitNSecondsUntilNodeUp } from "../utils/util";
import { parseUnits } from "ethers/lib/utils";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signers";
import { expect } from "chai";
import { mine, time } from "@nomicfoundation/hardhat-network-helpers";

import { getImpersonatedSigner, setUSDCBalance } from "../utils/util";

import { ethers } from "hardhat";

import { BigNumber } from "ethers";
import { OUSG_PROD, USDC_MAINNET } from "../../deploy/mainnet_constants";

async function main() {
  // This script is assumes you have an eth node hosted at localhost ip.
  await waitNSecondsUntilNodeUp("http://127.0.0.1:8545", 30);

  const signers = await ethers.getSigners();
  const guardian = signers[1];
  const managerAdmin = signers[2];
  const assetSender = signers[4];

  const usdc = await ethers.getContractAt("ERC20", USDC_MAINNET);
  const ousgManager = await ethers.getContract("OUSGManager");
  const pricer = await ethers.getContract("PricerWithOracle");
  const ousg = await ethers.getContractAt("IRWALike", OUSG_PROD);

  const usdcWhaleSigner: SignerWithAddress = await getImpersonatedSigner(
    "0x79234Ca502Ed0BeDf575dDD504fDDD78d785A50D"
  );
  const user: SignerWithAddress = await getImpersonatedSigner(
    "0xECE6bC29F718085a30b7bC14162B0fad4737e5d0"
  );

  const FIRST_DEPOSIT_ID = ethers.utils.hexZeroPad(ethers.utils.hexlify(1), 32);

  console.log(await ousgManager.pricer());
  const rwaOracle = await ethers.getContract("RWAOracleTestOnly");
  await rwaOracle.connect(guardian).setPrice(parseUnits("1", 18));
  await pricer
    .connect(managerAdmin)
    .addPrice(parseUnits("1", 18), await time.latest());
  const oracleTime = await rwaOracle.timestamp();
  // The block timestamps for deployment are drastically different than the block timestamps when being
  // run in this script. We set the prices to the current block timestamp to avoid the timestamp-based
  // constraints within the PriceWithOracle contract that would otherwise prevent us from setting the price.
  console.log("oracle timestamp ", oracleTime.toString());
  console.log(
    "prices timestamp ",
    (await pricer.connect(managerAdmin).prices(2)).timestamp.toString()
  );
  console.log("current timestamp ", await time.latest());

  const userStartingBal = await ousg.balanceOf(user.address);
  await ousg.connect(user).transfer(ousgManager.address, userStartingBal);

  const DEPOSIT_AMT = parseUnits("200000", 6);
  await setUSDCBalance(user, usdcWhaleSigner, DEPOSIT_AMT);

  // Have the user request a subscription
  await usdc.connect(user).approve(ousgManager.address, DEPOSIT_AMT);
  await ousgManager.connect(user).requestSubscription(DEPOSIT_AMT);
  console.log("current timestamp ", await time.latest());

  await ousgManager
    .connect(managerAdmin)
    ["setPriceIdForDeposits(bytes32[],uint256[])"](
      [FIRST_DEPOSIT_ID],
      [BigNumber.from(2)]
    );

  await ousgManager.connect(user).claimMint([FIRST_DEPOSIT_ID]);
  const balAfterClaim = await ousg.balanceOf(user.address);

  console.log(
    `The amount of OUSG claimed from the first depositId ${balAfterClaim.toString()}`
  );

  await ousg.connect(user).approve(ousgManager.address, balAfterClaim);
  await ousgManager.connect(user).requestRedemption(balAfterClaim);

  await ousgManager
    .connect(managerAdmin)
    ["setPriceIdForRedemptions(bytes32[],uint256[])"](
      [FIRST_DEPOSIT_ID],
      [BigNumber.from(2)]
    );

  await setUSDCBalance(assetSender, usdcWhaleSigner, parseUnits("200000", 6));
  expect(await usdc.balanceOf(assetSender.address)).to.eq(
    parseUnits("200000", 6)
  );

  await usdc
    .connect(assetSender)
    .approve(ousgManager.address, parseUnits("200000", 6));

  await ousgManager.connect(user).claimRedemption([FIRST_DEPOSIT_ID]);
  const balAfterRedeem = await usdc.balanceOf(user.address);
  console.log(
    `The amount of USDC claimed from the first redemptionId ${balAfterRedeem.toString()}`
  );
}

main();
