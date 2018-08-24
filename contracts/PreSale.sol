pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/crowdsale/Crowdsale.sol";
import "openzeppelin-solidity/contracts/crowdsale/validation/TimedCrowdsale.sol";
import "openzeppelin-solidity/contracts/crowdsale/distribution/RefundableCrowdsale.sol";
import "openzeppelin-solidity/contracts/crowdsale/emission/AllowanceCrowdsale.sol";
import "./ETHUSDPricing.sol";


contract PreSale is Crowdsale, TimedCrowdsale, RefundableCrowdsale, AllowanceCrowdsale {

    ETHUSDPricing public ETHUSD;

    uint256 public tokensSold;

    constructor(
        uint256 _rate,
        address _wallet,
        ERC20 _token,
        uint256 _openingTime,
        uint256 _closingTime,
        uint256 _goal,
        address _tokenWallet,
        address _pricing
    )
        Crowdsale(_rate, _wallet, _token)
        TimedCrowdsale(_openingTime, _closingTime)
        RefundableCrowdsale(_goal)
        AllowanceCrowdsale(_tokenWallet)
        public
    {
        ETHUSD = ETHUSDPricing(_pricing);
    }

    /**
    * @dev Overrides parent method calculating the goal in tokens. 
    * @return Whether funding goal was reached
    */
    function goalReached() public view returns (bool) {
        return tokensSold >= goal;
    }

    /**
    * @dev Overrides parent method taking into account variable rate.
    * @param _weiAmount The value in wei to be converted into tokens
    * @return The number of tokens _weiAmount wei will buy at present time
    */
    function _getTokenAmount(uint256 _weiAmount)
        internal view returns (uint256)
    {
        uint256 currentRate = getCurrentRate();
        return currentRate.mul(_weiAmount);
    }

    /**
    * @dev Override to extend the way in which ether is converted to tokens.
    * @param _weiAmount Value in wei to be converted into tokens
    * @return Number of tokens that can be purchased with the specified _weiAmount
    */
    function _getTokenAmount(uint256 _weiAmount)
        internal view returns (uint256)
    {
        return _weiAmount.mul(rate);
    }
}