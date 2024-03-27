import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { KYC_REGISTRY, USDC_MAINNET } from "../../../constants/constants";
import { parseUnits } from "ethers/lib/utils";
const { ethers } = require("hardhat");

const deployOMMFManager: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  const { deployments, getNamedAccounts } = hre;
  const { save } = deployments;
  const { deployer } = await getNamedAccounts();
  const { deploy } = deployments;
  const signers = await ethers.getSigners();

  const managerAdmin = signers[2];
  const pauser = signers[3];
  const assetSender = signers[4];
  const feeRecipient = signers[5];
  const instantMintAdmin = signers[6];

  const ommf = await ethers.getContract("OMMF");
  const wommf = await ethers.getContract("WOMMF");
  const registry = await ethers.getContractAt("KYCRegistry", KYC_REGISTRY);

  // Deploy the ommf manager
  await deploy("OMMFManager", {
    from: deployer,
    args: [
      USDC_MAINNET,
      ommf.address,
      managerAdmin.address,
      pauser.address,
      assetSender.address,
      feeRecipient.address,
      parseUnits("1000", 6),
      parseUnits("1000", 18),
      instantMintAdmin.address,
      registry.address,
      1,
      wommf.address,
    ],
    log: true,
  });
};

deployOMMFManager.tags = ["Local", "ommfManager"];
deployOMMFManager.dependencies = ["WOMMF"];
export default deployOMMFManager;
