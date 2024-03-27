import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
const { ethers } = require("hardhat");
import Network from "../../../network.config";

const deploy_rUSDY_factory: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  const { deployments, getNamedAccounts } = hre;
  const { deployer } = await getNamedAccounts();
  const { deploy } = deployments;
  const signers = await ethers.getSigners();

  const usdyConfig = Network.addressConfig().USDY;

  if (usdyConfig.USE_ALLOWLIST) {
    await deploy("rUSDYFactory", {
      from: deployer,
      args: [usdyConfig.PROD_GUARDIAN_USDY],
      log: true,
    });
  } else {
    await deploy("rUSDYW_Factory", {
      from: deployer,
      args: [usdyConfig.PROD_GUARDIAN_USDY],
      log: true,
    });
  }
};

deploy_rUSDY_factory.tags = ["Prod-rUSDY-Factory", "Prod-USDY-9"];
export default deploy_rUSDY_factory;
