import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { parseUnits } from "ethers/lib/utils";
import { ZERO_ADDRESS } from "../../../constants/constants";
const { ethers } = require("hardhat");
import Network from "../../../network.config";

const deployOMMFManager: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  const { deployments, getNamedAccounts } = hre;
  const { deployer } = await getNamedAccounts();
  const { deploy } = deployments;

  const factoryOMMF = await ethers.getContract("OMMFFactory");
  const factoryWOMMF = await ethers.getContract("WOMMFFactory");

  const ommfAddress = await factoryOMMF.ommfProxy();
  const wommfAddress = await factoryWOMMF.wommfProxy();

  const ommfConfig = Network.addressConfig().OMMF;

  if (ommfAddress == ZERO_ADDRESS) {
    throw new Error("OMMF Token not deployed through factory!");
  } else if (wommfAddress == ZERO_ADDRESS) {
    throw new Error("WOMMF Token not deployed through factory!");
  }

  await deploy("OMMFManager", {
    from: deployer,
    args: [
      ommfConfig.COLLATERAL, // _collateral
      ommfAddress, // _rwa
      ommfConfig.PROD_MANAGER_ADMIN_OMMF, // managerAdmin
      ommfConfig.PROD_PAUSER_OMMF, // pauser
      ommfConfig.PROD_ASSET_SENDER_OMMF, // _assetSender
      ommfConfig.PROD_FEE_RECIPIENT_OMMF, // _feeRecipient
      parseUnits("10", 6), // _minimumDepositAmount
      parseUnits("10", 18), // _minimumRedemptionAmount
      ommfConfig.PROD_INSTANT_MINTER_ADMIN_OMMF, // _instantMintAssetManager
      ommfConfig.PROD_KYC_REGISTRY, // _kycRegistry
      1, //_kycRequirementGroup
      wommfAddress, // _wommf
    ],
    log: true,
  });
};

deployOMMFManager.tags = ["Prod-OMMFManager", "Prod-OMMF-3"];
export default deployOMMFManager;
