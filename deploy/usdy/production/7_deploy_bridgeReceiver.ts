import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { parseUnits } from "ethers/lib/utils";
const { ethers } = require("hardhat");
const inquire = require("inquirer");
import Network from "../../../network.config";

const deployReceiver_prod: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  const { deployments, getNamedAccounts } = hre;
  const { deployer } = await getNamedAccounts();
  const { deploy } = deployments;

  const usdyConfig = Network.addressConfig().USDY;
  const NULL = "0x0000000000000000000000000000000000000000";

  console.log(
    `\n The following address for Axelar gateway is \n AXELAR_GATEWAY: ${usdyConfig.AXELAR_GATEWAY}`
  );
  let result = await inquire.prompt({
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

  const useAllowList = usdyConfig.USE_ALLOWLIST;
  const allowList = useAllowList
    ? (await ethers.getContract("Allowlist")).address
    : NULL;

  console.log(
    `\n The following address for allowlist is \n allowlist address: ${allowList}`
  );
  result = await inquire.prompt({
    type: "confirm",
    message: "The address above is correct",
    name: `val`,
  });
  if (!result.val) throw "error";

  await deploy("DestinationBridge", {
    from: deployer,
    args: [
      usdy.address, // _token
      usdyConfig.AXELAR_GATEWAY, // _axelarGateway
      allowList, // _allowlist
      usdyConfig.PROD_BRIDGE_APPROVER_ONDO, // _ondoApprover
      usdyConfig.PROD_GUARDIAN_USDY, // _owner
      parseUnits("100000", 18), // _mintLimit
      86400, // _mintDuration
    ],
    log: true,
  });
};

deployReceiver_prod.tags = ["Prod-USDY-Receiver", "Prod-USDY-7"];
export default deployReceiver_prod;
