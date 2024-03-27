import { waitNSecondsUntilNodeUp } from "../utils/util";
import { keccak256, parseUnits } from "ethers/lib/utils";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signers";
import { expect } from "chai";

import { getImpersonatedSigner, setUSDCBalance } from "../utils/util";

import { ethers } from "hardhat";
import { BigNumber } from "ethers";
import { KYC_REGISTRY, USDC_MAINNET } from "../../constants/constants";
async function main() {
  // This script is assumes you have an eth node hosted at localhost ip.
  await waitNSecondsUntilNodeUp("http://127.0.0.1:8545", 30);
  // const hre = require("hardhat");

  const signers = await ethers.getSigners();

  const guardian = signers[1];
  const managerAdmin = signers[2];
  const pauser = signers[3];
  const assetSender = signers[4];

  const usdc = await ethers.getContractAt("ERC20", USDC_MAINNET);
  const ommfManager = await ethers.getContract("OMMFManager");
  const pricer = await ethers.getContract("OMMF_Pricer");
  const registry = await ethers.getContractAt("KYCRegistry", KYC_REGISTRY);
  const ommf = await ethers.getContract("OMMF");
  const wOMMF = await ethers.getContract("WOMMF");

  const usdcWhaleSigner: SignerWithAddress = await getImpersonatedSigner(
    "0x79234Ca502Ed0BeDf575dDD504fDDD78d785A50D"
  );
  const user: SignerWithAddress = await getImpersonatedSigner(
    "0xECE6bC29F718085a30b7bC14162B0fad4737e5d0"
  );

  const other_user: SignerWithAddress = await getImpersonatedSigner(
    "0xaA1E4eef723ceaDd137B3AD39ea540dA4B092f8e"
  );

  const registryAdmin: SignerWithAddress = await getImpersonatedSigner(
    "0xAEd4caF2E535D964165B4392342F71bac77e8367"
  );

  // Pause|Unpause
  await ommfManager.connect(pauser).pauseSubscription();
  await ommfManager.connect(pauser).pauseRedemption();
  await ommfManager.connect(managerAdmin).unpauseSubscription();
  await ommfManager.connect(managerAdmin).unpauseRedemption();

  // Admin setters
  await ommfManager
    .connect(managerAdmin)
    .setMinimumDepositAmount(parseUnits("1", 6));
  await ommfManager
    .connect(managerAdmin)
    .setMinimumRedemptionAmount(parseUnits("1", 18));
  await ommfManager
    .connect(managerAdmin)
    .setOffChainRedemptionMinimum(parseUnits("1", 6));

  // Send some eth to the registry admin for gas
  await guardian.sendTransaction({
    to: registryAdmin.address,
    value: parseUnits("10", 18),
  });

  await ommfManager
    .connect(managerAdmin)
    .grantRole(
      keccak256(Buffer.from("PRICE_ID_SETTER_ROLE", "utf-8")),
      managerAdmin.address
    );
  await ommf
    .connect(guardian)
    .grantRole(
      keccak256(Buffer.from("MINTER_ROLE", "utf-8")),
      guardian.address
    );
  await registry
    .connect(registryAdmin)
    .addKYCAddresses(BigNumber.from(1), [ommfManager.address]);
  await registry
    .connect(registryAdmin)
    .addKYCAddresses(BigNumber.from(1), [wOMMF.address]);
  await registry
    .connect(registryAdmin)
    .addKYCAddresses(BigNumber.from(1), [managerAdmin.address]);
  await registry
    .connect(registryAdmin)
    .addKYCAddresses(BigNumber.from(1), [guardian.address]);
  await registry
    .connect(registryAdmin)
    .addKYCAddresses(BigNumber.from(1), [user.address]);
  await registry
    .connect(registryAdmin)
    .addKYCAddresses(BigNumber.from(1), [other_user.address]);

  /**
   * Basic rwaHub flow:
   * 1) user: Request subscription to RWA
   * 2) manager: sets price Id for mint
   * 3) user: claims subscription
   * 4) token rebases
   * 5) user: requests to redeem
   * 6) manager: sets price Id for redeem
   * 7) user: claims redemption
   */
  async function happyCases() {
    await setUSDCBalance(user, usdcWhaleSigner, parseUnits("10000", 6));
    // Address setters
    await usdc
      .connect(user)
      .approve(ommfManager.address, parseUnits("10000", 6));
    await ommfManager.connect(user).requestSubscription(parseUnits("10000", 6));

    const FIRST_DEPOSIT_ID = ethers.utils.hexZeroPad(
      ethers.utils.hexlify(1),
      32
    );

    // Have the manager Admin set the price
    await ommfManager
      .connect(managerAdmin)
      ["setPriceIdForDeposits(bytes32[],uint256[])"](
        [FIRST_DEPOSIT_ID],
        [BigNumber.from(1)]
      );

    let depositRequest = await ommfManager.depositIdToDepositor(
      FIRST_DEPOSIT_ID
    );
    // Assert check the data returned
    expect(depositRequest[0]).to.eq(user.address);
    expect(depositRequest[1]).to.eq(parseUnits("10000", 6));
    expect(depositRequest[2]).to.eq(BigNumber.from(1));

    // Have the user claim their deposit
    await ommfManager.connect(user).claimMint([FIRST_DEPOSIT_ID]);

    let bal = await ommf.balanceOf(user.address);
    expect(bal).to.eq(parseUnits("10000", 18));

    // Rebase the token
    await ommf.connect(guardian).handleOracleReport(parseUnits("20000", 18));

    let balAfterRebase = await ommf.balanceOf(user.address);
    expect(balAfterRebase).to.eq(parseUnits("20000", 18));

    await ommf
      .connect(user)
      .approve(ommfManager.address, parseUnits("20000", 18));
    await ommfManager.connect(user).requestRedemption(parseUnits("20000", 18));

    let redeemRequest = await ommfManager.redemptionIdToRedeemer(
      FIRST_DEPOSIT_ID
    );
    expect(redeemRequest[0]).to.eq(user.address);
    expect(redeemRequest[1]).to.eq(parseUnits("20000", 18));
    expect(redeemRequest[2]).to.eq(BigNumber.from(0));

    await ommfManager
      .connect(managerAdmin)
      ["setPriceIdForRedemptions(bytes32[],uint256[])"](
        [FIRST_DEPOSIT_ID],
        [BigNumber.from(1)]
      );

    await setUSDCBalance(assetSender, usdcWhaleSigner, parseUnits("20000", 6));
    expect(await usdc.balanceOf(assetSender.address)).to.eq(
      parseUnits("20000", 6)
    );

    await usdc
      .connect(assetSender)
      .approve(ommfManager.address, parseUnits("20000", 6));

    const FIRST_REDEEM_ID = ethers.utils.hexZeroPad(
      ethers.utils.hexlify(1),
      32
    );

    let res = await ommfManager.redemptionIdToRedeemer(FIRST_DEPOSIT_ID);
    expect(res[0]).to.eq(user.address);
    expect(res[1]).to.eq(parseUnits("20000", 18));
    expect(res[2]).to.eq(BigNumber.from(1));

    await ommfManager.connect(user).claimRedemption([FIRST_REDEEM_ID]);

    let balRedeemed = await usdc.balanceOf(user.address);
    expect(balRedeemed).to.eq(parseUnits("20000", 6));
  }

  /**
   * Enhanced RwaHub Flow to cover edge cases
   * 1) manager : add Deposit proof
   * 2) manager : overwrite Deposit
   * 3) User : Claim mint (wrapped)
   * 4) manager : add Redemption proof
   * 5) manager : overwrite Redemption
   * 6) User : Claim redemption
   * 7) User : request Redemption (wrapped)
   * 8) manager : set price id for redemption
   * 9) User : claim redemption
   * 10) User : request redemption to be serviced off chain
   */
  async function edgeCases() {
    const SECOND_DEPOSIT_ID = ethers.utils.hexZeroPad(
      ethers.utils.hexlify(2),
      32
    );
    // Allows Manager Admin to add deposit proofs
    await ommfManager
      .connect(managerAdmin)
      .grantRole(
        keccak256(Buffer.from("RELAYER_ROLE", "utf-8")),
        managerAdmin.address
      );

    await ommfManager
      .connect(managerAdmin)
      .addProof(
        SECOND_DEPOSIT_ID,
        user.address,
        parseUnits("10000", 6),
        parseUnits("1", 6),
        BigNumber.from(1695238126)
      );

    await ommfManager.connect(managerAdmin).overwriteDepositor(
      SECOND_DEPOSIT_ID,
      other_user.address, // changes user
      parseUnits("9999", 6), // Changes value
      BigNumber.from(1)
    ); // Sets price ID

    let depositRequest = await ommfManager.depositIdToDepositor(
      SECOND_DEPOSIT_ID
    );
    // Assert check the data returned
    expect(depositRequest[0]).to.eq(other_user.address);
    expect(depositRequest[1]).to.eq(parseUnits("9999", 6));
    expect(depositRequest[2]).to.eq(BigNumber.from(1));
    await ommfManager
      .connect(managerAdmin)
      .claimMint_wOMMF([SECOND_DEPOSIT_ID]);

    let wOMMFBalance = await wOMMF.balanceOf(other_user.address);

    // convert wOMMF to OMMF so other user can redeem
    await wOMMF.connect(other_user).unwrap(wOMMFBalance);
    let ommfBalance = await ommf.balanceOf(other_user.address);
    // Initiate full redemption by sending to ondo controlled redemptions multisig.
    await ommf.connect(other_user).transfer(managerAdmin.address, ommfBalance);

    const SECOND_REDEMPTION_ID =
      "0xa4896a3f93bf4bf58378e579f3cf193bb4af1022af7d2089f37d8bae7157b85f";
    await ommfManager
      .connect(managerAdmin)
      .grantRole(
        keccak256(Buffer.from("REDEMPTION_PROVER_ROLE", "utf-8")),
        managerAdmin.address
      );
    await ommf.connect(managerAdmin).approve(ommfManager.address, ommfBalance);
    await ommfManager
      .connect(managerAdmin)
      .addRedemptionProof(
        SECOND_REDEMPTION_ID,
        other_user.address,
        ommfBalance,
        BigNumber.from(1695238126)
      );
    await registry
      .connect(registryAdmin)
      .addKYCAddresses(BigNumber.from(1), [user.address]);
    await ommfManager
      .connect(managerAdmin)
      .overwriteRedeemer(
        SECOND_REDEMPTION_ID,
        user.address,
        parseUnits("10000", 18),
        BigNumber.from(1)
      );
    // Intentionally do not claim this redemption for better subgraph coverage.

    // Request a new redemption via requestRedemption_wOMMF
    let counter = await ommfManager.redemptionRequestCounter();
    console.log(counter - 1);
    // construct expected redemption ID
    const THIRD_REDEMPTION_ID = ethers.utils.hexZeroPad(
      ethers.utils.hexlify(counter),
      32
    );

    ommf.connect(guardian).mint(user.address, parseUnits("123", 18));
    await ommf.connect(user).approve(wOMMF.address, parseUnits("123", 18));
    await wOMMF.connect(user).wrap(parseUnits("123", 18));
    await wOMMF
      .connect(user)
      .approve(ommfManager.address, parseUnits("123", 18));
    await ommfManager
      .connect(user)
      .requestRedemption_wOMMF(parseUnits("123", 18));
    await ommfManager
      .connect(managerAdmin)
      ["setPriceIdForRedemptions(bytes32[],uint256[])"](
        [THIRD_REDEMPTION_ID],
        [BigNumber.from(1)]
      );

    await setUSDCBalance(assetSender, usdcWhaleSigner, parseUnits("123", 6));
    await usdc
      .connect(assetSender)
      .approve(ommfManager.address, parseUnits("123", 6));

    await ommfManager.connect(user).claimRedemption([THIRD_REDEMPTION_ID]);

    // Finally, user to request off chain redemption
    ommf.connect(guardian).mint(user.address, parseUnits("123", 18));
    await ommf
      .connect(user)
      .approve(ommfManager.address, parseUnits("123", 18));
    let DESTINATION =
      "0x33a272731107d4e69fecea1b8518d70b6ce928238b13afe10ef7b9ec0e9886c3";
    await ommfManager
      .connect(user)
      .requestRedemptionServicedOffchain(parseUnits("123", 18), DESTINATION);
  }

  await happyCases();
  await edgeCases();
}

main();
