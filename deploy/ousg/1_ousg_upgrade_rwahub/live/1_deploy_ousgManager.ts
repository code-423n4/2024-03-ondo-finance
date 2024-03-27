import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { CONSTANTS } from "../../constants";

const deployOUSGManager: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  const { deployments, getNamedAccounts } = hre;
  const { deployer } = await getNamedAccounts();
  const { deploy } = deployments;
  console.log("deploying from address :", deployer);
  const parameters = CONSTANTS[hre.network.name!].OUSG_MANAGER_CONSTRUCTION;
  console.log("Constructor Parameters: ", parameters);
  //   OUSGManager::constructor(
  //     address _collateral,
  //     address _rwa,
  //     address managerAdmin,
  //     address pauser,
  //     address _assetSender,
  //     address _feeRecipient,
  //     uint256 _minimumDepositAmount,
  //     uint256 _minimumRedemptionAmount,
  //     address _kycRegistry,
  //     uint256 _kycRequirementGroup
  //   )

  await deploy("OUSGManager", {
    from: deployer,
    args: [
      parameters.USDC,
      parameters.OUSG,
      parameters.MANAGEMENT_MULTISIG,
      parameters.PAUSER_MULTISIG,
      parameters.ASSET_SENDER_FOR_REDEMPTIONS,
      parameters.FEE_RECIPIENT,
      parameters.MINIMUM_DEPOSIT_AMOUNT,
      parameters.MINIMUM_REDEMPTION_AMOUNT,
      parameters.KYC_REGISTRY,
      parameters.KYC_REQUIREMENT_GROUP,
    ],
    log: true,
  });
};

deployOUSGManager.tags = ["OUSGManager-live"];
export default deployOUSGManager;
