import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { ZERO_ADDRESS } from "../../../constants/constants";
import { parseUnits } from "ethers/lib/utils";
import Network from "../../../network.config";
const { ethers } = require("hardhat");

const deploy_usdyManager: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  const { deployments, getNamedAccounts } = hre;
  const { deployer } = await getNamedAccounts();
  const { deploy } = deployments;

  const factoryUSDY = await ethers.getContract("USDYFactory");
  const factoryAllow = await ethers.getContract("AllowlistFactory");
  const blocklist = await ethers.getContract("Blocklist");

  const usdyAddress = await factoryUSDY.usdyProxy();
  const allowlistAddress = await factoryAllow.allowlistProxy();

  const usdyConfig = Network.addressConfig().USDY;

  if (usdyAddress == ZERO_ADDRESS) {
    throw new Error("USDY Token not deployed through factory!");
  }
  if (usdyConfig.USE_ALLOWLIST) {
    await deploy("USDYManager", {
      from: deployer,
      args: [
        usdyConfig.COLLATERAL, // _collateral
        usdyAddress, // _rwa
        usdyConfig.PROD_MANAGER_ADMIN_USDY, // managerAdmin
        usdyConfig.PROD_PAUSER_USDY, // pauser
        usdyConfig.PROD_ASSET_SENDER_USDY, // _assetSender
        usdyConfig.PROD_FEE_RECIPIENT_USDY, // _feeRecipient
        parseUnits("500", 6), // _minimumDepositAmount
        parseUnits("500", 18), // _minimumRedemptionAmount
        blocklist.address, // blocklist
        usdyConfig.PROD_SANCTIONS_ADDRESS, // sanctionsList
      ],
      log: true,
    });
  } else {
    console.log("⚠️ USDYManager is not to be deployed as part of this config");
  }
};
deploy_usdyManager.tags = ["Prod-USDYManager", "Prod-USDY-4"];
export default deploy_usdyManager;
