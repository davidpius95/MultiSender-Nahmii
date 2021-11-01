// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
	const [Owner,addr1,addr2] = await ethers.getSigners();

  
  const Token = await hre.ethers.getContractFactory("Token");
  const amount = ethers.utils.parseUnits('30000', 'ether')
  const token = await Token.deploy(amount);
  await token.deployed();
  console.log("token deployed address:", token.address);


  const Multisender = await hre.ethers.getContractFactory("MultiSender");
  const multisender = await Multisender.deploy(Owner.address,addr1.address);
  await multisender.deployed();
  console.log("multisender deployed address:", multisender.address);

//   const { ethers } = require("hardhat");

// module.exports = async ({ getNamedAccounts, deployments }) => {
//     const { deploy } = deployments;
//     const { deployer } = await getNamedAccounts();

//     await deploy("Currency", {
//         from: deployer,
//         log: true,
//     });
//     const currency = await ethers.getContract("Currency");

//     await deploy("Fruit", {
//         from: deployer,
//         args: [currency.address],
//         log: true,
//     });


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
