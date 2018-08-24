pragma solidity ^0.4.22;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract ETHUSDPricing is Ownable {

    // PRICE of 1 ETHER in USD in cents
    // So, if price is: $271.90, the value in variable will be: 27190
    uint256 public ETHUSD;

    // Time of Last Updated Price
    uint256 public updatedTime;

    // Historic price of ETH in USD in cents
    mapping (uint256 => uint256) public priceHistory;

    event PriceUpdated(uint256 price);

    constructor() public {
    }

    function getPrice(uint256 time) public view returns (uint256 price) {
        return priceHistory[time];
    } 

    function updatePrice(uint256 time, uint256 price) public onlyOwner {
        require(time > updatedTime, "Time must be greater than last update");
        require(price > 0, "ETHUSD price is non-zero");

        priceHistory[updatedTime] = ETHUSD;

        ETHUSD = price;
        updatedTime = time;

        emit PriceUpdated(ETHUSD);
    }


    
}

