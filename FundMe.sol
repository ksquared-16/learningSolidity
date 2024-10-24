// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";

//constant, immutable 

error NotOwner();

contract FundMe {

    using PriceConverter for uint256; 

    //uint256 public minimumUsd = 5e18; --> constant can save on gas costs
    uint256 public constant MINIMUM_USD = 5e18;

    address[] public funders;
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;

    //address public owner;
    address public immutable i_owner;

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable{
        require(msg.value.getConversionRate() >= MINIMUM_USD, "didn't send enough ETH"); //1e18 = 1 ETH = 1000000000000 = 1 * 10 ** 18
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        //for loop
        //* starting index, ending index, step amount */
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        //reset the array
        //funders = new address[](0);
        //withdraw the funds 
        //transfer (auto reverts)
        //payable(msg.sender).transfer(address(this).balance);
        //send (only reverts with the require statement)
        //bool sendSuccess = payable(msg.sender).send(address(this).balance);
        //require(sendSuccess, "Send Failed");
        //call
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    modifier onlyOwner() {
        //runs this first and the _; will run everything else afterward. If the other way then code first and then the require
        //require(msg.sender == i_owner, "Sender is not the owner!"); --> more gas efficient below
        if(msg.sender != i_owner) { revert NotOwner(); }
        _;
    }

    //What happens if someone sends this contrat ETH without calling the fund function? 

    // receive()
    receive() external payable {
        fund();
    }
    // fallback()
    fallback() external payable {
        fund();
    }
}