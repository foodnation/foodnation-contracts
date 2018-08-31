pragma solidity ^0.4.22;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../Crowdsale.sol";
/**
* @title USDPriceStrategy
* @dev Extension of Crowdsale contract that calculates the price of tokens in USD cents.
* Note that this contracts needs to be updated
* Once this contract is used, the rate of crowdsale needs to be in USD cents
*/
contract USDPriceStrategy is Ownable {

    using SafeMath for uint256;

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

    function getHistoricPrice(uint256 time) public view returns (uint256) {
        return priceHistory[time];
    } 

    function updatePrice(uint256 price) public onlyOwner {
        require(price > 0);

        priceHistory[updatedTime] = ETHUSD;

        ETHUSD = price;
        // solium-disable-next-line security/no-block-members
        updatedTime = block.timestamp;

        emit PriceUpdated(ETHUSD);
    }

    /**
    * @dev Override to extend the way in which ether is converted to USD.
    * @param _weiAmount Value in wei to be converted into tokens
    * @return The value of wei amount in USD cents
    */
    function getPrice(uint256 _weiAmount)
        internal view returns (uint256)
    {
        return _weiAmount.mul(ETHUSD);
    }
    
}

