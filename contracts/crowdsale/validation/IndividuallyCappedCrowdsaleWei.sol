pragma solidity ^0.4.24;

import "../../math/SafeMath.sol";
import "../IndividuallyCappedCrowdsale.sol";


/**
 * @title IndividuallyCappedCrowdsaleWei
 * @dev Crowdsale with per-user caps.
 */
contract IndividuallyCappedCrowdsaleWei is IndividuallyCappedCrowdsale {
  using SafeMath for uint256;

  constructor (
    uint256 _individualCap
  ) 
    IndividuallyCappedCrowdsale(_individualCap)
    public 
  {
    
  }

  /**
   * @dev Extend parent behavior requiring purchase to respect the user's funding cap.
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
    require(contributions[_beneficiary].add(_weiAmount) <= maxIndividualCap);
  }

  /**
   * @dev Extend parent behavior to update user contributions
   * @param _beneficiary Token purchaser
   * @param _weiAmount Amount of wei contributed
   * @param _tokenAmount Amount of token purchased
   */
  function _updatePurchasingState(
    address _beneficiary,
    uint256 _weiAmount,
    uint256 _tokenAmount
  )
    internal
  {
    super._updatePurchasingState(_beneficiary, _weiAmount, _tokenAmount);
    contributions[_beneficiary] = contributions[_beneficiary].add(_weiAmount);
  }

}
