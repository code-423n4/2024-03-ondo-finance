import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { KYC_REGISTRY } from "../../../constants/constants";
const { ethers } = require("hardhat");

const deployWOMMF_Factory: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  const { deployments, getNamedAccounts } = hre;
  const { save } = deployments;
  const { deployer } = await getNamedAccounts();
  const { deploy } = deployments;
  const signers = await ethers.getSigners();

  const guardian = signers[1];

  // Deploy the factory
  await deploy("WOMMFFactory", {
    from: deployer,
    args: [guardian.address],
    log: true,
  });

  // Read in OUSG Registry
  const registry = await ethers.getContractAt("KYCRegistry", KYC_REGISTRY);

  // Read in prev deployed factory
  const factory = await ethers.getContract("WOMMFFactory");
  const ommf = await ethers.getContract("OMMF");

  // Deploy the ommf Instance
  await factory
    .connect(guardian)
    .deployWOMMF("Wrapped OMMF", "WOMMF", ommf.address, registry.address, 1);

  const wommfProxy = await factory.wommfProxy();
  const wommfProxyAdmin = await factory.wommfProxyAdmin();
  const wommfImplementation = await factory.wommfImplementation();

  console.log(`\nThe wOMMF Proxy is deployed @: ${wommfProxy}`);
  console.log(`The wOMMF Proxy Admin is deployed @: ${wommfProxyAdmin}`);
  console.log(
    `The wOMMF Implementation is deployed @: ${wommfImplementation}\n`
  );

  const wommfArtifact = await deployments.getExtendedArtifact("WOMMF");
  const paAtrifact = await deployments.getExtendedArtifact("ProxyAdmin");
  let wommfProxied = {
    address: wommfProxy,
    ...wommfArtifact,
  };
  let wommfAdmin = {
    address: wommfProxyAdmin,
    ...paAtrifact,
  };
  let wommfImpl = {
    address: wommfImplementation,
    ...wommfArtifact,
  };

  await save("WOMMF", wommfProxied);
  await save("ProxyAdminWOMMF", wommfAdmin);
  await save("WOMMFImplementation", wommfImpl);
};

deployWOMMF_Factory.tags = ["Local", "WOMMF"];
deployWOMMF_Factory.dependencies = ["OMMF"];
export default deployWOMMF_Factory;
