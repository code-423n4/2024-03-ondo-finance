import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
const { ethers } = require("hardhat");
import Network from "../../../network.config";

const deployBlocklist: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  const { deployments, getNamedAccounts } = hre;
  const { save } = deployments;
  const { deployer } = await getNamedAccounts();
  const { deploy } = deployments;
  const usdyConfig = Network.addressConfig().USDY;

  await deploy("Blocklist", {
    from: deployer,
    args: [],
    log: true,
  });
  /// @notice: Need to transfer blocklist Owner Role to guardian.
  const blocklist = await ethers.getContract("Blocklist");
  await blocklist.transferOwnership(usdyConfig.PROD_GUARDIAN_USDY);
  /// @notice: Need to accept ownership on the guardian
};

deployBlocklist.tags = ["Prod-Blocklist", "Prod-USDY-2"];
export default deployBlocklist;
