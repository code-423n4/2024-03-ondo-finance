import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import Network from "../../../network.config";
const { ethers } = require("hardhat");

const deployAllowlist_Factory: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  const { deployments, getNamedAccounts } = hre;
  const { deployer } = await getNamedAccounts();
  const { deploy } = deployments;
  const usdyConfig = Network.addressConfig().USDY;

  // Deploy the factory
  if (usdyConfig.USE_ALLOWLIST) {
    await deploy("AllowlistFactory", {
      from: deployer,
      args: [usdyConfig.PROD_GUARDIAN_USDY],
      log: true,
    });
  } else {
    console.log(
      "⚠️ The Allowlist is not to be deployed as part of this config"
    );
  }
};

deployAllowlist_Factory.tags = ["Prod-Allowlist-Factory", "Prod-USDY-1"];
export default deployAllowlist_Factory;
