pragma solidity ^0.4.22;

import "openzeppelin-solidity/contracts/crowdsale/validation/TimedCrowdsale.sol";
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
        uint256 tokenCap;

        // How many tokens per wei you will get after this milestone has been passed
        uint256 rate;

        // State variable that finalize Milestone
        bool isFinalized;

    }

    /// Store milestones in a fixed array, so that it can be seen in a blockchain explorer
    /// Milestone 0 is always (0, 0)
    /// (TODO: change this when we confirm dynamic arrays are explorable)
    Milestone[10] public milestones;

    // How many active milestones have been created
    uint256 public milestoneCount = 0;

    // Index of the current milestone
    uint256 public currentMilestoneIdx = 0;

    /// @dev Contruction, creating a list of milestones
    /// @param _openingTime Crowdsale opening time
    /// @param _closingTime Crowdsale closing time
    /// @param _time uint[] milestones start time 
    /// @param _tokenCap uint[] milestones tokenCap 
    /// @param _rate uint[] milestones rate 
    constructor(        
        uint256 _openingTime,
        uint256 _closingTime, 
        uint256[] _time, 
        uint256[] _tokenCap, 
        uint256[] _rate) public {
        // Need to have tuples, length check
        require(_time.length > 0, "Parameters length must be non-zero");
        require(_time.length == _tokenCap.length && _tokenCap.length == _rate.length, "Parameters must have the same length");
        require(_time[0] == _openingTime, "First Milestone should start at same time as global Crowdsale");
        require(_time[_time.length-1] < _closingTime, "Last Milestone should start before global Crowdsale ends");

        for (uint iterator = 0; iterator < _time.length; iterator++) {
            if (_time[iterator] != 0) {
                assert(_time[iterator] > milestones[milestoneCount-1].startTime);
                milestones[milestoneCount] = Milestone({
                    index: milestoneCount,
                    startTime: _time[iterator],
                    tokensSold: 0,
                    tokenCap: _tokenCap[iterator],
                    rate: _rate[iterator],
                    isFinalized: false
                });
                milestoneCount++;
            }
        }
    }

    /// @dev Iterate through milestones. You reach end of milestones when rate = 0
    /// @return tuple (time, rate)
    function getMilestoneTimeAndRate(uint256 n) public view returns (uint, uint) {
        return (milestones[n].startTime, milestones[n].rate);
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

    /// @dev Get the current milestone or bail out if we are not in the milestone periods.
    /// @return {[type]} [description]
    function getNextMilestoneIndex() internal view onlyWhileOpen returns  (uint256) {
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

        // For the next code, you may ask why not assert if last milestone surpass tokenCap...
        // Because if its last and it is capped we would like to finish not sell any more tokens 
        // Check if the current milestone has reached it's cap
        if (milestones[index].tokensSold > milestones[index].tokenCap) {
            index = index + 1;
        }

        return index;
    }

      /**
    * @dev Extend parent behavior requiring purchase to respect the funding cap from the currentMilestone.
    * @param _beneficiary Token purchaser
    * @param _weiAmount Amount of wei contributed
    */
    function _preValidatePurchase(
        address _beneficiary,
        uint256 _weiAmount
    )
        internal
    {
        super._preValidatePurchase(_beneficiary, _weiAmount);
        uint256 tokens = _getTokenAmount(_weiAmount);
        require(milestones[currentMilestoneIdx].tokensSold.add(tokens) <= milestones[currentMilestoneIdx].tokenCap, "The current purchase exceeds the Hard Cap of current Milestone. Please, try again with a smaller value...");
    }

    /**
    * @dev Extend parent behavior updating contract variables
    * @param _beneficiary Address performing the token purchase
    * @param _weiAmount Value in wei involved in the purchase
    */
    function _postValidatePurchase(
        address _beneficiary,
        uint256 _weiAmount
    )
        internal
    {
        super._postValidatePurchase(_beneficiary, _weiAmount);
        uint256 tokens = _getTokenAmount(_weiAmount);
        milestones[currentMilestoneIdx].tokensSold = milestones[currentMilestoneIdx].tokensSold.add(tokens);
        currentMilestoneIdx = getNextMilestoneIndex();
    }

    /// @dev Get the current rate.
    /// @return The current rate or 0 if we are outside milestone period
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
        return _weiAmount.mul(rate);
    }

}
