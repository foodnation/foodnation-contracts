pragma solidity ^0.4.24;

import "../../math/SafeMath.sol";
import "../Crowdsale.sol";
import "../../ownership/Ownable.sol";


/**
 * @title IndividuallyCappedCrowdsale
 * @dev Crowdsale with per-user caps.
 */
contract IndividuallyCappedCrowdsale is Ownable, Crowdsale {
  using SafeMath for uint256;

  mapping(address => uint256) public contributions;
  uint256 public individualCap;

  constructor (
    uint256 _individualCap
  ) 
    public 
  {
    require(_individualCap > 0, "Individual Cap must be non-zero");
    individualCap = _individualCap;
  }

  /**
   * @dev Returns the amount contributed so far by a sepecific user.
   * @param _beneficiary Address of contributor
   * @return User contribution so far
   */
  function getUserContribution(address _beneficiary)
    public view returns (uint256)
  {
    return contributions[_beneficiary];
  }

}
