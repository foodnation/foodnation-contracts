pragma solidity ^0.4.22;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./VestingToken.sol";

contract VestingFactory is Ownable {

    VestingToken[] vestings;

    constructor() public {}

    function newVesting(string _name, address _beneficiary, uint256 _start, uint256 _cliff, uint256 _duration) public onlyOwner returns (VestingToken)  {
        VestingToken vesting = new VestingToken(_name, _beneficiary, _start, _cliff, _duration, false);
        vestings.push(vesting);
        return vesting;
    }
}