const networkConfig = {
  11155111: {
    name: "sepolia",
    ethUsdPriceFeed: "0x694AA1769357215DE4FAC081bf1f309aDC325306",
  },
};

const developementChains = ["hardhat", "locahost"];
const DECIMALS = 8;
const INITIAL_ANSWER = 200000000000;

module.exports = {
  networkConfig,
  developementChains,
  DECIMALS,
  INITIAL_ANSWER,
};
