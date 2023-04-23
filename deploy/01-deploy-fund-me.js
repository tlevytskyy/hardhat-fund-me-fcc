//imports
//main function
//calling of main

const {
  networkConfig,
  developementChains,
} = require("../helper-hardhat-config");
const { network } = require("hardhat");
const { verify } = require("../Utils/verify");

//if the contract doesnt exist, we deploy a minimal version of it for out testing

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = network.config.chainId;

  let ethUsdPriceFeedAddress;
  if (developementChains.includes(network.name)) {
    const ethUsdAggregator = await deployments.get("MockV3Aggregator");
    ethUsdPriceFeedAddress = ethUsdAggregator.address;
  } else {
    ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"];
  }
  // when going for localhost or hardhat network we want to use a mock
  //what happens when we want to change chains?
  const args = [ethUsdPriceFeedAddress];
  const fundMe = await deploy("FundMe", {
    from: deployer,
    args: args, //put price feed address
    log: true,
    waitConfirmations: network.config.blockConfirmations || 1,
  });

  if (
    !developementChains.includes(network.name) &&
    process.env.ETHERSCAN_API_KEY
  ) {
    await verify(fundMe.address, args);
  }

  log(
    "------------------------------------------------------------------------------"
  );
};

module.exports.tags = ["all", "fundme"];
