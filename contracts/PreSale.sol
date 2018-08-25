pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

import "./crowdsale/Crowdsale.sol";
import "./crowdsale/emission/AllowanceCrowdsale.sol";
import "./crowdsale/distribution/RefundableCrowdsale.sol";
import "./crowdsale/validation/CappedCrowdsaleToken.sol";
import "./crowdsale/validation/MinimumPurchaseCrowdsale.sol";
import "./crowdsale/validation/MilestoneCrowdsale.sol";
import "./crowdsale/price/USDPriceCrowdsale.sol";


contract PreSale is Crowdsale, AllowanceCrowdsale, RefundableCrowdsale, CappedCrowdsaleToken, MinimumPurchaseCrowdsale, MilestoneCrowdsale, USDPriceCrowdsale {

    uint256 public tokensSold;

    constructor(
        uint256 _rate,
        address _wallet,
        ERC20 _token,
        uint256 _openingTime,
        uint256 _closingTime,
        uint256[] _milestoneStartTime, 
        uint256[] _milestoneCap, 
        uint256[] _milestoneRate,
        uint256 _goal,
        uint256 _cap,
        uint256 _individualCap,
        address _tokenWallet,
        address _pricing
    )
        Crowdsale(_rate, _wallet, _token)
        AllowanceCrowdsale(_tokenWallet)
        RefundableCrowdsale(_goal)
        CappedCrowdsaleToken(_cap)
        IndividuallyCappedCrowdsaleToken(_individualCap)
        MilestoneCrowdsale(_openingTime, _closingTime, _milestoneStartTime, _milestoneCap, _milestoneRate)
        public
    {
        ETHUSD = ETHUSDPricing(_pricing);
    }

    /**
    * @dev Override to extend the way in which ether is converted to tokens.
    * @param _weiAmount Value in wei to be converted into tokens
    * @return Number of tokens that can be purchased with the specified _weiAmount
    */
    function _getTokenAmount(uint256 _weiAmount)
        internal view returns (uint256)
    {
        return _getPrice(_weiAmount).div(getCurrentRate());
    }
}