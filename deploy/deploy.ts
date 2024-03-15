import { ethers } from "hardhat";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const network = hre.hardhatArguments.network ? hre.hardhatArguments.network : "ropsten";
  const greeterFactory = await ethers.getContractFactory("Greeter");
  const greeter = await greeterFactory.deploy("Hello, World!");
  await greeter.deployed();

  console.log(`Greeter is deployed on ${network} at address ${greeter.address}. `);
};

func.tags = ["Greeter"];

module.exports = func;
