import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
const { ethers } = require("hardhat");
const inquire = require("inquirer");
import Network from "../../../network.config";

const deploySourceBridge_prod: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  const { deployments, getNamedAccounts } = hre;
  const { deployer } = await getNamedAccounts();
  const { deploy } = deployments;

  const usdyConfig = Network.addressConfig().USDY;

  console.log(
    `\n The following address for Axelar gateway is \n AXELAR_GATEWAY: ${usdyConfig.AXELAR_GATEWAY}`
  );
  let result = await inquire.prompt({
    type: "confirm",
    message: "The address above is correct",
    name: `val`,
  });
  if (!result.val) throw "error";

  console.log(
    `\n The following address for Axelar gas service is \n AXELAR_GAS_SERVICE: ${usdyConfig.AXELAR_GAS_SERVICE}`
  );
  result = await inquire.prompt({
    type: "confirm",
    message: "The address above is correct",
    name: `val`,
  });
  if (!result.val) throw "error";

  const usdy = await ethers.getContract("USDY");

  console.log(
    `\n The following address for USDY is \n USDY address: ${usdy.address}`
  );
  result = await inquire.prompt({
    type: "confirm",
    message: "The address above is correct",
    name: `val`,
  });
  if (!result.val) throw "error";

  await deploy("SourceBridge", {
    from: deployer,
    args: [
      usdy.address,
      usdyConfig.AXELAR_GATEWAY,
      usdyConfig.AXELAR_GAS_SERVICE,
      usdyConfig.PROD_GUARDIAN_USDY,
    ],
    log: true,
  });
};

deploySourceBridge_prod.tags = ["Prod-USDY-Bridge", "Prod-USDY-6"];
export default deploySourceBridge_prod;
