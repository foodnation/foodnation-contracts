pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

import "./crowdsale/Crowdsale.sol";
import "./crowdsale/emission/MintedCrowdsale.sol";
import "./crowdsale/distribution/RefundableCrowdsale.sol";
import "./crowdsale/validation/CappedCrowdsaleToken.sol";
import "./crowdsale/validation/MinimumPurchaseCrowdsale.sol";
import "./crowdsale/validation/MilestoneCrowdsale.sol";
import "./crowdsale/price/USDPriceCrowdsale.sol";
import "./FoodNationToken.sol";

interface FoodNationTokenERC20 {
    function heartbeat() public;
}

contract PreSale is Crowdsale, MintedCrowdsale, RefundableCrowdsale, CappedCrowdsaleToken, MinimumPurchaseCrowdsale, MilestoneCrowdsale, USDPriceCrowdsale {

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
        uint256 _minimumContribution
    )
        Crowdsale(_rate, _wallet, _token)
        RefundableCrowdsale(_goal)
        CappedCrowdsaleToken(_cap)
        MinimumPurchaseCrowdsale(_minimumContribution)
        MilestoneCrowdsale(_openingTime, _closingTime, _milestoneStartTime, _milestoneCap, _milestoneRate)
        public
    {
        token = _token;
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

    /**
    * @dev Extend parent behavior sending heartbeat to token.
    * @param _beneficiary Address receiving the tokens
    * @param _weiAmount Value in wei involved in the purchase
    * @param _tokenAmount Value in token involved in the purchase
    */
    function _updatePurchasingState(
        address _beneficiary,
        uint256 _weiAmount,
        uint256 _tokenAmount
    )
        internal
    {
        super._updatePurchasingState(_beneficiary, _weiAmount, _tokenAmount);
        FoodNationTokenERC20 foodNationToken = FoodNationTokenERC20(token);
        foodNationToken.heartbeat();
    }

    /**
    * @dev Must be called after crowdsale ends, to do some extra finalization
    * work. Calls the contract's finalization function.
    */
    function finalize() public onlyOwner {
        require(!isFinalized);
        require(hasClosed() || capReached());

        finalization();
        emit Finalized();

        isFinalized = true;
    }

}