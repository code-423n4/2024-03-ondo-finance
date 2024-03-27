import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import {
  KYC_REGISTRY,
  OUSG_PROD,
  USDC_MAINNET,
} from "../../../mainnet_constants";
import { keccak256, parseUnits } from "ethers/lib/utils";
import { BigNumber } from "ethers";
import { getImpersonatedSigner } from "../../../../scripts/utils/util";
const { ethers } = require("hardhat");

const deploy_ousgManager: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  const { deployments, getNamedAccounts } = hre;
  const { deployer } = await getNamedAccounts();
  const { deploy } = deployments;
  const signers = await ethers.getSigners();

  const guardian = signers[1];
  const managerAdmin = signers[2];
  const pauser = signers[3];
  const assetSender = signers[4];
  const feeRecipient = signers[5];

  const ousg = await ethers.getContractAt("IAccessControl", OUSG_PROD);
  const registry = await ethers.getContractAt("KYCRegistry", KYC_REGISTRY);
  //   OUSGManager::constructor(
  //     address _collateral,
  //     address _rwa,
  //     address managerAdmin,
  //     address pauser,
  //     address _assetSender,
  //     address _feeRecipient,
  //     uint256 _minimumDepositAmount,
  //     uint256 _minimumRedemptionAmount,
  //     address _kycRegistry,
  //     uint256 _kycRequirementGroup
  //   )
  await deploy("OUSGManager", {
    from: deployer,
    args: [
      USDC_MAINNET,
      ousg.address,
      managerAdmin.address,
      pauser.address,
      assetSender.address,
      feeRecipient.address,
      parseUnits("100000", 6),
      parseUnits("500", 18),
      registry.address,
      1,
    ],
    log: true,
  });

  // POST Deploy Actions
  const ousgManager = await ethers.getContract("OUSGManager");
  const prod_guardian = await getImpersonatedSigner(
    "0xAEd4caF2E535D964165B4392342F71bac77e8367"
  );
  // Seed USDC PROD Guardian
  await guardian.sendTransaction({
    to: prod_guardian.address,
    value: parseUnits("10", 18),
  });
  // Grant MINTER_ROLE OUSG to ousgManager
  await ousg
    .connect(prod_guardian)
    .grantRole(
      keccak256(Buffer.from("MINTER_ROLE", "utf-8")),
      ousgManager.address
    );

  // add ousgManager to KYCRegistry
  await registry
    .connect(prod_guardian)
    .addKYCAddresses(BigNumber.from(1), [ousgManager.address]);

  // Set the pricer in
  const pricer = await ethers.getContract("PricerWithOracle");
  await ousgManager.connect(managerAdmin).setPricer(pricer.address);

  await ousgManager
    .connect(managerAdmin)
    .grantRole(
      keccak256(Buffer.from("PRICE_ID_SETTER_ROLE", "utf-8")),
      managerAdmin.address
    );
};

deploy_ousgManager.tags = ["Local", "OUSGManager"];
deploy_ousgManager.dependencies = ["OUSGPricer"];
export default deploy_ousgManager;
