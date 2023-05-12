// SPDX-License-Identifier: MIT
// On the original tutorial he uses solidity version 0.6, in the github is 0.8.8, but what worked for me was 0.8.0
// https://stackoverflow.com/questions/70096712/trying-to-compile-contract-but-getting-parsererror-source-openzeppelin-contr
// https://stackoverflow.com/questions/70683276/how-can-i-import-aggregatorv3interface
pragma solidity ^0.8.8;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol"; 
import "./PriceConverter.sol";

// The original line below
error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;

    // Could we make this constant?  /* hint: no! We should make it immutable! */
    address public immutable /* immutable */ i_owner;
    uint256 public constant MINIMUM_USD = 50 * 10 ** 18;
    AggregatorV3Interface public priceFeed;
    
    constructor(address _priceFeed) {
        priceFeed = AggregatorV3Interface(_priceFeed);
        i_owner = msg.sender;
    }

    function fund() public payable {
        // require(msg.value.getConversionRate() >= MINIMUM_USD, "You need to spend more ETH!");
        // require(PriceConverter.getConversionRate(msg.value) >= MINIMUM_USD, "You need to spend more ETH!");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }
    
    function getVersion() public view returns (uint256){
        // ETH/USD price feed address of Sepolia Network.
        return priceFeed.version();
    }
    
    modifier onlyOwner {
        // require(msg.sender == owner);
        // if (msg.sender != i_owner)
        // The original line is the one below
        if (msg.sender != i_owner) revert NotOwner();
        _;
    }


    function getEntranceFee() public view returns (uint256) {
        // minimumUSD
        // return 2;
        uint256 minimumUSD = 50 * 10**18;
        // Something is not working correctly when working with version 0.8 - the problem resides in PriceConverter.sol file, getPrice() function, Aggregator version 0.8 with solidity 0.8, the contract works fine when tested in remix
        // uint256 price = PriceConverter.getPrice();
        uint256 precision = 1 * 10**18;
        // Something is not working correctly when working with version 0.8 - the problem resides in PriceConverter.sol file, getPrice() function, Aggregator version 0.8 with solidity 0.8, the contract works fine when tested in remix
        // return (minimumUSD * precision) / price;
        return (minimumUSD * precision) / (2000 * 10**18);
    }
    // 25.000.000.000.000.000.000.000.000.000.000.000
    // 25.000.000.000.000.000
    function withdraw() public onlyOwner {
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        // // transfer
        // payable(msg.sender).transfer(address(this).balance);
        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");
        // call
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }
    // Explainer from: https://solidity-by-example.org/fallback/
    // Ether is sent to contract
    //      is msg.data empty?
    //          /   \ 
    //         yes  no
    //         /     \
    //    receive()?  fallback() 
    //     /   \ 
    //   yes   no
    //  /        \
    //receive()  fallback()

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

}

// Concepts we didn't cover yet (will cover in later sections)
// 1. Enum
// 2. Events
// 3. Try / Catch
// 4. Function Selector
// 5. abi.encode / decode
// 6. Hash with keccak256
// 7. Yul / Assembly

