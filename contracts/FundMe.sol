// SPDX-License-Identifier: MIT
//pragma
pragma solidity ^0.8.4;

//imports
import "./PriceConverter.sol";

//error codes
//errors with revert keyword are another way to do require that is more gas efficient see onlyOwner for example
error FundMe__NotOwner();

//interfaces, Libraries, Contracts

/// @title A contract for crown funding
/// @author Taras Levytskyy
/// @notice This contract is to demo a sample funding contract
/// @dev this implements Pricefeed as our library
contract FundMe {
    //Type Declerations
    using PriceConverter for uint256;

    //State Variables
    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;

    //immutable is the same as readonly. it can be set once
    address private immutable i_owner;
    uint256 public constant MINIMUM_USD = 10 * 1e18;
    AggregatorV3Interface private s_priceFeed;

    //Events and Modifiers
    modifier onlyOwner() {
        //require(msg.sender == i_owner, "Sender not owner!");

        if (msg.sender != i_owner) revert FundMe__NotOwner(); //example of using revert with errors
        //revert(); you can also just revert any transaction like a return statement but reverting all changes

        _; //the _ represents the function code the modifier is attached too
        //in this case the require will run first followerd by the rest of the function
        //putting the underscore above the require will run all the code and then do the require ala do while
    }

    // Functions
    // constructor
    // receive
    // fallback
    // external
    // public
    // internal
    // private
    // view/pure

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    //What happens if someone sends a contract ETH without calling the fund function
    // receive() external payable {
    //     fund();
    // }

    // fallback() external payable {
    //     fund();
    // }

    function fund() public payable {
        // Want to be able to set a minimum fund amount in USD
        // 1. How do we send ETH to this contract
        require(
            msg.value.getConvertionRate(s_priceFeed) >= MINIMUM_USD,
            "Didn't send enough"
        ); // 1e18 = 1*10 ** 18 = 1000000000000000000 wei = 1Eth
        // 1a. If a transaction fails, all changes get reverted and gas is returned. think about a sql transaction. either everything if executed or nothing is commited
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] = msg.value;
    }

    function withdraw() public payable onlyOwner {
        for (uint8 i = 0; i < s_funders.length; i++) {
            s_addressToAmountFunded[s_funders[i]] = 0;
        }

        s_funders = new address[](0);

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    function cheaperWithDraw() public onlyOwner {
        address[] memory funders = s_funders;
        //mappings cant be in memory
        for (uint256 i = 0; i < funders.length; i++) {
            address funder = funders[i];
            s_addressToAmountFunded[funder] = 0;
        }

        s_funders = new address[](0);

        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success, "Call failed");
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getAddressToAmountFunded(
        address funder
    ) public view returns (uint256) {
        return s_addressToAmountFunded[funder];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
