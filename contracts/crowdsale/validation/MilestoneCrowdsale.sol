pragma solidity ^0.4.24;

import "./TimedCrowdsale.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

/**
 * @title MilestoneCrowdsale
 * @dev Crowdsale with multiple milestones separated by time and cap
 * @author Nikola Wyatt <nikola.wyatt@foodnation.io>
 */
contract MilestoneCrowdsale is TimedCrowdsale {
    using SafeMath for uint256;

    uint256 public constant MAX_MILESTONE = 10;

    /**
    * Define pricing schedule using milestones.
    */
    struct Milestone {

        // Milestone index in array
        uint256 index;

        // UNIX timestamp when this milestone starts
        uint256 startTime;

        // Amount of tokens sold in milestone
        uint256 tokensSold;

        // Maximum amount of Tokens accepted in the current Milestone.
        uint256 cap;

        // How many tokens per wei you will get after this milestone has been passed
        uint256 rate;

    }

    /**
    * Store milestones in a fixed array, so that it can be seen in a blockchain explorer
    * Milestone 0 is always (0, 0)
    * (TODO: change this when we confirm dynamic arrays are explorable)
    */
    Milestone[10] public milestones;

    // How many active milestones have been created
    uint256 public milestoneCount = 0;


    bool public milestoningFinished = false;

    constructor(        
        uint256 _openingTime,
        uint256 _closingTime
        ) 
        TimedCrowdsale(_openingTime, _closingTime)
        public 
        {
        }

    /**
    * @dev Contruction, setting a list of milestones
    * @param _milestoneStartTime uint[] milestones start time 
    * @param _milestoneCap uint[] milestones cap 
    * @param _milestoneRate uint[] milestones price 
    */
    function setMilestonesList(uint256[] _milestoneStartTime, uint256[] _milestoneCap, uint256[] _milestoneRate) public {
        // Need to have tuples, length check
        require(!milestoningFinished);
        require(_milestoneStartTime.length > 0);
        require(_milestoneStartTime.length == _milestoneCap.length && _milestoneCap.length == _milestoneRate.length);
        require(_milestoneStartTime[0] == openingTime);
        require(_milestoneStartTime[_milestoneStartTime.length-1] < closingTime);

        for (uint iterator = 0; iterator < _milestoneStartTime.length; iterator++) {
            if (iterator > 0) {
                assert(_milestoneStartTime[iterator] > milestones[iterator-1].startTime);
            }
            milestones[iterator] = Milestone({
                index: iterator,
                startTime: _milestoneStartTime[iterator],
                tokensSold: 0,
                cap: _milestoneCap[iterator],
                rate: _milestoneRate[iterator]
            });
            milestoneCount++;
        }
        milestoningFinished = true;
    }

    /**
    * @dev Iterate through milestones. You reach end of milestones when rate = 0
    * @return tuple (time, rate)
    */
    function getMilestoneTimeAndRate(uint256 n) public view returns (uint256, uint256) {
        return (milestones[n].startTime, milestones[n].rate);
    }

    /**
    * @dev Checks whether the cap of a milestone has been reached.
    * @return Whether the cap was reached
    */
    function capReached(uint256 n) public view returns (bool) {
        return milestones[n].tokensSold >= milestones[n].cap;
    }

    /**
    * @dev Checks amount of tokens sold in milestone.
    * @return Amount of tokens sold in milestone
    */
    function getTokensSold(uint256 n) public view returns (uint256) {
        return milestones[n].tokensSold;
    }

    function getFirstMilestone() private view returns (Milestone) {
        return milestones[0];
    }

    function getLastMilestone() private view returns (Milestone) {
        return milestones[milestoneCount-1];
    }

    function getFirstMilestoneStartsAt() public view returns (uint256) {
        return getFirstMilestone().startTime;
    }

    function getLastMilestoneStartsAt() public view returns (uint256) {
        return getLastMilestone().startTime;
    }

    /**
    * @dev Get the current milestone or bail out if we are not in the milestone periods.
    * @return {[type]} [description]
    */
    function getCurrentMilestoneIndex() internal view onlyWhileOpen returns  (uint256) {
        uint256 index;

        // Found the current milestone by evaluating time. 
        // If (now < next start) the current milestone is the previous
        // Stops loop if finds current
        for(uint i = 0; i < milestoneCount; i++) {
            index = i;
            // solium-disable-next-line security/no-block-members
            if(block.timestamp < milestones[i].startTime) {
                index = i - 1;
                break;
            }
        }

        // For the next code, you may ask why not assert if last milestone surpass cap...
        // Because if its last and it is capped we would like to finish not sell any more tokens 
        // Check if the current milestone has reached it's cap
        if (milestones[index].tokensSold > milestones[index].cap) {
            index = index + 1;
        }

        return index;
    }

    /**
    * @dev Extend parent behavior requiring purchase to respect the funding cap from the currentMilestone.
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
        require(milestones[getCurrentMilestoneIndex()].tokensSold.add(_tokenAmount) <= milestones[getCurrentMilestoneIndex()].cap);
    }

    /**
    * @dev Extend parent behavior to update current milestone state and index
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
        milestones[getCurrentMilestoneIndex()].tokensSold = milestones[getCurrentMilestoneIndex()].tokensSold.add(_tokenAmount);
    }

    /**
    * @dev Get the current price.
    * @return The current price or 0 if we are outside milestone period
    */
    function getCurrentRate() internal view returns (uint result) {
        return milestones[getCurrentMilestoneIndex()].rate;
    }

    /**
    * @dev Override to extend the way in which ether is converted to tokens.
    * @param _weiAmount Value in wei to be converted into tokens
    * @return Number of tokens that can be purchased with the specified _weiAmount
    */
    function _getTokenAmount(uint256 _weiAmount)
        internal view returns (uint256)
    {
        return _weiAmount.mul(getCurrentRate());
    }

}
