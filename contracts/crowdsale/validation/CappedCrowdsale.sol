pragma solidity ^0.4.24;

import "../Crowdsale.sol";


/**
 * @title CappedCrowdsale
 * @dev Crowdsale with a limit for total contributions.
 */
contract CappedCrowdsale is Crowdsale {

    uint256 public cap;

    /**
    * @dev Constructor, takes maximum amount of wei accepted in the crowdsale.
    * @param _cap Max amount of wei to be contributed
    */
    constructor(uint256 _cap) public {
        require(_cap > 0);
        cap = _cap;
    }

}
