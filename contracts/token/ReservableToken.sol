pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol";
import "openzeppelin-solidity/contracts/token/ERC20/DetailedERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";


/**
* @title ReservableToken
* @dev An amount of token is reserved and allocated to reservedTokensList.
*/
contract ReservableToken is MintableToken {

    using SafeMath for uint256;
  
    struct ReservedTokensData {
        uint256 amount;
        bool isReserved;
        bool isDistributed;
    }

    mapping (address => ReservedTokensData) public reservedTokensList;

    address[] public reservedTokensDestinations;

    uint256 public reservedTokensDestinationsLen = 0;

    uint256 public distributedReservedTokensDestinationsLen = 0;

    bool reservedTokensDestinationsAreSet = false;

    bool reservedTokensAreDistributed = false;


    /**
    * @dev Constructor, takes token reserved addresses and amounts.
    * @param addrs Token reserverd adress list
    * @param amounts Token reserverd amounts list
    */
    constructor(
        address[] addrs, 
        uint256[] amounts
    ) 
        public 
    {
        setReservedTokensListMultiple(addrs, amounts);
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

    /**
    * @dev distribute previous reserved tokens
    * @return Boolean if everything is alright
    */
    function distributeReservedTokens() public canMint onlyOwner returns (bool){
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
        return true;
    }

    /**
    * @dev Set reserved addresses and its amounts in batch
    * @param address Addresses list to reserve tokens
    * @param amounts Amount reserved list to address
    */
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

    /**
    * @dev Set reserved address and its amount
    * @param addr Address to reserve tokens
    * @param amount Amount reserved to address
    */
    function setReservedTokensList(address addr, uint256 amount) internal canMint onlyOwner {
        assert(addr != address(0));
        if (!isAddressReserved(addr)) {
            reservedTokensDestinations.push(addr);
            reservedTokensDestinationsLen++;
        }

        reservedTokensList[addr] = ReservedTokensData({
            amount: amount,
            isReserved: true,
            isDistributed: false
        });
    }

    function finalizeReservedAddress(address addr) internal onlyOwner {
        ReservedTokensData storage reservedTokensData = reservedTokensList[addr];
        reservedTokensData.isDistributed = true;
    }
}
