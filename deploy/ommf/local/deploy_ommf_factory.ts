import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { KYC_REGISTRY } from "../../../constants/constants";
const { ethers } = require("hardhat");

const deployOMMF_Factory: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  const { deployments, getNamedAccounts } = hre;
  const { save } = deployments;
  const { deployer } = await getNamedAccounts();
  const { deploy } = deployments;
  const signers = await ethers.getSigners();

  const guardian = signers[1];

  // Deploy the factory
  await deploy("OMMFFactory", {
    from: deployer,
    args: [guardian.address],
    log: true,
  });

  const registry = await ethers.getContractAt("KYCRegistry", KYC_REGISTRY);

  const factory = await ethers.getContract("OMMFFactory");

  // Deploy ommf Instance
  await factory.connect(guardian).deployOMMF(registry.address, 1);

  const ommfProxy = await factory.ommfProxy();
  const ommfProxyAdmin = await factory.ommfProxyAdmin();
  const ommfImplementation = await factory.ommfImplementation();

  console.log(`\nThe OMMF Proxy is deployed @: ${ommfProxy}`);
  console.log(`The OMMF Proxy Admin is deployed @: ${ommfProxyAdmin}`);
  console.log(`The OMMF Implementation is deployed @: ${ommfImplementation}\n`);

  // Save the deployed instances
  const ommfArtifact = await deployments.getExtendedArtifact("OMMF");
  const paAtrifact = await deployments.getExtendedArtifact("ProxyAdmin");

  let ommfProxied = {
    address: ommfProxy,
    ...ommfArtifact,
  };
  let ommfAdmin = {
    address: ommfProxyAdmin,
    ...paAtrifact,
  };
  let ommfImpl = {
    address: ommfImplementation,
    ...ommfArtifact,
  };

  await save("OMMF", ommfProxied);
  await save("ProxyAdminOMMF", ommfAdmin);
  await save("OMMFImplementation", ommfImpl);
};

deployOMMF_Factory.tags = ["Local", "OMMF"];
export default deployOMMF_Factory;
