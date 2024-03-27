import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
const { ethers } = require("hardhat");
import Network from "../../../network.config";

const deploy_usdyPricer: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  const { deployments, getNamedAccounts } = hre;
  const { deployer } = await getNamedAccounts();
  const { deploy } = deployments;
  const usdyConfig = Network.addressConfig().USDY;

  if (usdyConfig.USE_ALLOWLIST) {
    await deploy("USDY_Pricer", {
      from: deployer,
      contract: "USDYPricer",
      args: [usdyConfig.PROD_GUARDIAN_USDY, usdyConfig.PROD_GUARDIAN_USDY],
      log: true,
    });
  } else {
    console.log(
      "⚠️ The USDY_Pricer is not to be deployed as part of this config"
    );
  }
};

deploy_usdyPricer.tags = ["Prod-USDY-Pricer", "Prod-USDY-5"];
export default deploy_usdyPricer;
