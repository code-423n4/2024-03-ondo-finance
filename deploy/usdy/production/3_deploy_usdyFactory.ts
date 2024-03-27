import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
const { ethers } = require("hardhat");
import Network from "../../../network.config";

const deployUSDY_Factory: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  const { deployments, getNamedAccounts } = hre;
  const { deployer } = await getNamedAccounts();
  const { deploy } = deployments;
  const usdyConfig = Network.addressConfig().USDY;

  // Deploy the factory
  if (usdyConfig.USE_ALLOWLIST) {
    await deploy("USDYFactory", {
      from: deployer,
      args: [usdyConfig.PROD_GUARDIAN_USDY],
      log: true,
    });
  } else {
    await deploy("USDYW_Factory", {
      from: deployer,
      args: [usdyConfig.PROD_GUARDIAN_USDY],
      log: true,
    });
  }
};

deployUSDY_Factory.tags = ["Prod-USDY-Factory", "Prod-USDY-3"];
export default deployUSDY_Factory;
