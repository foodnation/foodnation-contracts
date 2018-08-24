pragma solidity ^0.4.24;

import "../../math/SafeMath.sol";
import "../CappedCrowdsale.sol";


/**
 * @title CappedCrowdsaleToken
 * @dev Crowdsale with a limit for total contributions in Token.
 */
contract CappedCrowdsaleToken is CappedCrowdsale {
  using SafeMath for uint256;

  /**
   * @dev Constructor, takes maximum amount of wei accepted in the crowdsale.
   * @param _cap Max amount of token to be contributed
   */
  constructor(uint256 _cap) public {
    CappedCrowdsale(_cap);
  }

  /**
   * @dev Checks whether the cap has been reached.
   * @return Whether the cap was reached
   */
  function capReached() public view returns (bool) {
    return tokensSold >= cap;
  }

  /**
   * @dev Extend parent behavior requiring purchase to respect the funding cap.
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
    require(tokensSold.add(_tokenAmount) <= cap);
  }

}