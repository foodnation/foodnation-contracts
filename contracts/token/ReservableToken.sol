pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol";
import "openzeppelin-solidity/contracts/token/ERC20/DetailedERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract ReservableToken is MintableToken {

    using SafeMath for uint256;
    
    //Reserved Tokens Data Structure
    struct ReservedTokensData {
        uint256 amount;
        bool isReserved;
        bool isDistributed;
    }

    //state variables for reserved token setting 
    mapping (address => ReservedTokensData) public reservedTokensList;
    address[] public reservedTokensDestinations;
    uint256 public reservedTokensDestinationsLen = 0;
    bool reservedTokensDestinationsAreSet = false;

    uint256 decimalPlaces;

    //state variables for reserved token distribution
    bool reservedTokensAreDistributed = false;
    uint256 public distributedReservedTokensDestinationsLen = 0;

    constructor(
        address[] addrs, 
        uint256[] amounts,
        uint256 _decimals
    ) 
        public 
    {
        decimalPlaces = _decimals;
        setReservedTokensListMultiple(addrs, amounts);
        distributeReservedTokens();
    }

    function isAddressReserved(address addr) public view returns (bool isReserved) {
        return reservedTokensList[addr].isReserved;
    }

    function areTokensDistributedForAddress(address addr) public view returns (bool isDistributed) {
        return reservedTokensList[addr].isDistributed;
    }

    function getReservedTokens(address addr) public view returns (uint256 amount) {
        return reservedTokensList[addr].amount;
    }

    function setReservedTokensListMultiple(address[] addrs, uint256[] amounts) internal canMint onlyOwner {
        require(!reservedTokensDestinationsAreSet, "Reserved Tokens already set");
        require(addrs.length == amounts.length, "Parameters must have the same length");
        for (uint iterator = 0; iterator < addrs.length; iterator++) {
            if (addrs[iterator] != address(0)) {
                setReservedTokensList(addrs[iterator], amounts[iterator]);
            }
        }
        reservedTokensDestinationsAreSet = true;
    }

    function setReservedTokensList(address addr, uint256 amount) internal canMint onlyOwner {
        assert(addr != address(0));
        if (!isAddressReserved(addr)) {
            reservedTokensDestinations.push(addr);
            reservedTokensDestinationsLen++;
        }

        reservedTokensList[addr] = ReservedTokensData({
            amount: amount * (10 ** decimalPlaces),
            isReserved: true,
            isDistributed: false
        });
    }

    /// distributes reserved tokens
    function distributeReservedTokens() internal canMint onlyOwner {
        assert(!reservedTokensAreDistributed);
        assert(distributedReservedTokensDestinationsLen < reservedTokensDestinationsLen);


        uint startLooping = distributedReservedTokensDestinationsLen;
        uint256 batch = reservedTokensDestinationsLen.sub(distributedReservedTokensDestinationsLen);
        uint endLooping = startLooping + batch;

        // move reserved tokens
        for (uint j = startLooping; j < endLooping; j++) {
            address reservedAddr = reservedTokensDestinations[j];
            if (!areTokensDistributedForAddress(reservedAddr)) {
                uint256 allocatedTokens = getReservedTokens(reservedAddr);

                if (allocatedTokens > 0) {
                    mint(reservedAddr, allocatedTokens);
                }

                finalizeReservedAddress(reservedAddr);
                distributedReservedTokensDestinationsLen++;
            }
        }

        if (distributedReservedTokensDestinationsLen == reservedTokensDestinationsLen) {
            reservedTokensAreDistributed = true;
        }
    }

    function finalizeReservedAddress(address addr) internal onlyOwner {
        ReservedTokensData storage reservedTokensData = reservedTokensList[addr];
        reservedTokensData.isDistributed = true;
    }
}
