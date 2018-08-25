pragma solidity ^0.4.24;

import "../Crowdsale.sol";


/**
 * @title MinimumPurchaseCrowdsale
 * @dev Crowdsale with a minimium contribution per purchase.
 */
contract MinimumPurchaseCrowdsale is Crowdsale {

    uint256 public minimumContribution;

    /**
    * @dev Constructor, takes minimum amount of wei accepted in the crowdsale.
    * @param _minimumContribution Min amount of wei to be contributed per purchase
    */
    constructor(uint256 _minimumContribution) public {
        require(_minimumContribution > 0);
        minimumContribution = _minimumContribution;
    }

    /**
    * @dev Extend parent behavior requiring the purchase has a minimum value in wei
    * @param _beneficiary Token purchaser
    * @param _weiAmount Amount of wei contributed
    * @param _tokenAmount Amount of token purchased
    */
    function _preValidatePurchase(
        address _beneficiary,
        uint256 _weiAmount,
        uint256 _tokenAmount
    )
        internal
    {
        super._preValidatePurchase(_beneficiary, _weiAmount, _tokenAmount);
        require(_weiAmount >= minimumContribution);
    }

}
