pragma solidity 0.4.24;

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/BasicToken.sol

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  uint256 internal totalSupply_;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_value <= balances[msg.sender]);
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  modifier hasMintPermission() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(
    address _to,
    uint256 _amount
  )
    public
    hasMintPermission
    canMint
    returns (bool)
  {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() public onlyOwner canMint returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/CappedToken.sol

/**
 * @title Capped token
 * @dev Mintable token with a token cap.
 */
contract CappedToken is MintableToken {

  uint256 public cap;

  constructor(uint256 _cap) public {
    require(_cap > 0);
    cap = _cap;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(
    address _to,
    uint256 _amount
  )
    public
    returns (bool)
  {
    require(totalSupply_.add(_amount) <= cap);

    return super.mint(_to, _amount);
  }

}

// File: openzeppelin-solidity/contracts/token/ERC20/DetailedERC20.sol

/**
 * @title DetailedERC20 token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract DetailedERC20 is ERC20 {
  string public name;
  string public symbol;
  uint8 public decimals;

  constructor(string _name, string _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
  }
}

// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyOwner whenNotPaused {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused {
    paused = false;
    emit Unpause();
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/PausableToken.sol

/**
 * @title Pausable token
 * @dev StandardToken modified with pausable transfers.
 **/
contract PausableToken is StandardToken, Pausable {

  function transfer(
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transfer(_to, _value);
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(
    address _spender,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.approve(_spender, _value);
  }

  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}

// File: openzeppelin-solidity/contracts/ownership/Heritable.sol

/**
 * @title Heritable
 * @dev The Heritable contract provides ownership transfer capabilities, in the
 * case that the current owner stops "heartbeating". Only the heir can pronounce the
 * owner's death.
 */
contract Heritable is Ownable {
  address private heir_;

  // Time window the owner has to notify they are alive.
  uint256 private heartbeatTimeout_;

  // Timestamp of the owner's death, as pronounced by the heir.
  uint256 private timeOfDeath_;

  event HeirChanged(address indexed owner, address indexed newHeir);
  event OwnerHeartbeated(address indexed owner);
  event OwnerProclaimedDead(
    address indexed owner,
    address indexed heir,
    uint256 timeOfDeath
  );
  event HeirOwnershipClaimed(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev Throw an exception if called by any account other than the heir's.
   */
  modifier onlyHeir() {
    require(msg.sender == heir_);
    _;
  }


  /**
   * @notice Create a new Heritable Contract with heir address 0x0.
   * @param _heartbeatTimeout time available for the owner to notify they are alive,
   * before the heir can take ownership.
   */
  constructor(uint256 _heartbeatTimeout) public {
    setHeartbeatTimeout(_heartbeatTimeout);
  }

  function setHeir(address _newHeir) public onlyOwner {
    require(_newHeir != owner);
    heartbeat();
    emit HeirChanged(owner, _newHeir);
    heir_ = _newHeir;
  }

  /**
   * @dev Use these getter functions to access the internal variables in
   * an inherited contract.
   */
  function heir() public view returns(address) {
    return heir_;
  }

  function heartbeatTimeout() public view returns(uint256) {
    return heartbeatTimeout_;
  }

  function timeOfDeath() public view returns(uint256) {
    return timeOfDeath_;
  }

  /**
   * @dev set heir = 0x0
   */
  function removeHeir() public onlyOwner {
    heartbeat();
    heir_ = address(0);
  }

  /**
   * @dev Heir can pronounce the owners death. To claim the ownership, they will
   * have to wait for `heartbeatTimeout` seconds.
   */
  function proclaimDeath() public onlyHeir {
    require(ownerLives());
    emit OwnerProclaimedDead(owner, heir_, timeOfDeath_);
    // solium-disable-next-line security/no-block-members
    timeOfDeath_ = block.timestamp;
  }

  /**
   * @dev Owner can send a heartbeat if they were mistakenly pronounced dead.
   */
  function heartbeat() public onlyOwner {
    emit OwnerHeartbeated(owner);
    timeOfDeath_ = 0;
  }

  /**
   * @dev Allows heir to transfer ownership only if heartbeat has timed out.
   */
  function claimHeirOwnership() public onlyHeir {
    require(!ownerLives());
    // solium-disable-next-line security/no-block-members
    require(block.timestamp >= timeOfDeath_ + heartbeatTimeout_);
    emit OwnershipTransferred(owner, heir_);
    emit HeirOwnershipClaimed(owner, heir_);
    owner = heir_;
    timeOfDeath_ = 0;
  }

  function setHeartbeatTimeout(uint256 _newHeartbeatTimeout)
    internal onlyOwner
  {
    require(ownerLives());
    heartbeatTimeout_ = _newHeartbeatTimeout;
  }

  function ownerLives() internal view returns (bool) {
    return timeOfDeath_ == 0;
  }
}

// File: contracts/upgrade/Recoverable.sol

/**
 * This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net
 *
 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt
 */

pragma solidity ^0.4.24;



contract Recoverable is Ownable {

    /// @dev Empty constructor (for now)
    constructor() public{
    }

    /// @dev This will be invoked by the owner, when owner wants to rescue tokens
    /// @param token Token which will we rescue to the owner from the contract
    function recoverTokens(ERC20Basic token) public onlyOwner  {
        token.transfer(owner, tokensToBeReturned(token));
    }

    /// @dev Interface function, can be overwritten by the superclass
    /// @param token Token which balance we will check and return
    /// @return The amount of tokens (in smallest denominator) the contract owns
    function tokensToBeReturned(ERC20Basic token) public view returns (uint) {
        return token.balanceOf(this);
    }
}

// File: contracts/upgrade/UpgradeAgent.sol

/**
 * Upgrade agent interface inspired by Lunyr.
 *
 * Upgrade agent transfers tokens to a new contract.
 * Upgrade agent itself can be the token contract, or just a middle man contract doing the heavy lifting.
 */
contract UpgradeAgent {

    uint public originalSupply;

    /** Interface marker */
    function isUpgradeAgent() public pure returns (bool) {
        return true;
    }

    function upgradeFrom(address _from, uint256 _value) public;

}

// File: contracts/token/UpgradeableToken.sol

/**
 * This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net
 *
 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt
 */

pragma solidity ^0.4.24;





/**
 * A token upgrade mechanism where users can opt-in amount of tokens to the next smart contract revision.
 *
 * First envisioned by Golem and Lunyr projects.
 */
contract UpgradeableToken is StandardToken, Recoverable {

    /** Contract / person who can set the upgrade path. This can be the same as team multisig wallet, as what it is with its default value. */
    address public upgradeMaster;

    /** The next contract where the tokens will be migrated. */
    UpgradeAgent public upgradeAgent;

    /** How many tokens we have upgraded by now. */
    uint256 public totalUpgraded;

    /**
    * Upgrade states.
    *
    * - NotAllowed: The child contract has not reached a condition where the upgrade can bgun
    * - WaitingForAgent: Token allows upgrade, but we don't have a new agent yet
    * - ReadyToUpgrade: The agent is set, but not a single token has been upgraded yet
    * - Upgrading: Upgrade agent is set and the balance holders can upgrade their tokens
    *
    */
    enum UpgradeState {Unknown, NotAllowed, WaitingForAgent, ReadyToUpgrade, Upgrading}

    /**
    * Somebody has upgraded some of his tokens.
    */
    event Upgrade(address indexed _from, address indexed _to, uint256 _value);

    /**
    * New upgrade agent available.
    */
    event UpgradeAgentSet(address agent);

    /**
    * Do not allow construction without upgrade master set.
    */
    constructor() public {
        upgradeMaster = msg.sender;
    }

    /**
    * @dev Throws if called by any account other than the upgradeMaster.
    */
    modifier onlyUpgradeMaster() {
        require(msg.sender == upgradeMaster, "Sender not authorized.");
        _;
    }

    /**
    * Allow the token holder to upgrade some of their tokens to a new contract.
    */
    function upgrade(uint256 value) public {
        // Validate input value.
        require(value != 0, "Value parameter must be non-zero.");

        UpgradeState state = getUpgradeState();
        require(state == UpgradeState.ReadyToUpgrade || state == UpgradeState.Upgrading, "Function called in a bad state");

        balances[msg.sender] = balances[msg.sender].sub(value);

        // Take tokens out from circulation
        totalSupply_ = totalSupply_.sub(value);
        totalUpgraded = totalUpgraded.add(value);

        // Upgrade agent reissues the tokens
        upgradeAgent.upgradeFrom(msg.sender, value);
        emit Upgrade(msg.sender, upgradeAgent, value);
    }

    /**
    * Set an upgrade agent that handles
    */
    function setUpgradeAgent(address agent) external onlyUpgradeMaster {
        // The token is not yet in a state that we could think upgrading
        require(canUpgrade(), "Upgrade not enabled.");

        // Upgrade has already begun for an agent
        require(getUpgradeState() != UpgradeState.Upgrading, "Updgrade has alredy begun.");

        upgradeAgent = UpgradeAgent(agent);

        // Bad interface
        require(upgradeAgent.isUpgradeAgent(), "Not an upgrade Agent or bad interface");
        // Make sure that token supplies match in source and target
        assert(upgradeAgent.originalSupply() == totalSupply_);

        emit UpgradeAgentSet(upgradeAgent);
    }

    /**
    * Get the state of the token upgrade.
    */
    function getUpgradeState() public view returns(UpgradeState) {
        if(!canUpgrade()) return UpgradeState.NotAllowed;
        else if(address(upgradeAgent) == 0x00) return UpgradeState.WaitingForAgent;
        else if(totalUpgraded == 0) return UpgradeState.ReadyToUpgrade;
        else return UpgradeState.Upgrading;
    }

    /**
    * Change the upgrade master.
    *
    * This allows us to set a new owner for the upgrade mechanism.
    */
    function setUpgradeMaster(address master) public onlyUpgradeMaster {
        require(master != 0x0, "New master cant be 0x0");
        upgradeMaster = master;
    }

    /**
    * Child contract can enable to provide the condition when the upgrade can begun.
    */
    function canUpgrade() public pure returns(bool) {
        return true;
    }

}

// File: contracts/token/ReservableToken.sol

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

    //state variables for reserved token distribution
    bool reservedTokensAreDistributed = false;
    uint256 public distributedReservedTokensDestinationsLen = 0;

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

    /// distributes reserved tokens
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

// File: contracts/FoodNationToken.sol

contract FoodNationToken is StandardToken, MintableToken, CappedToken, DetailedERC20, PausableToken, UpgradeableToken, ReservableToken, Heritable {

    constructor(
        string _name, 
        string _symbol, 
        uint8 _decimals, 
        uint256 _cap, 
        address[] _addrs, 
        uint256[] _amounts, 
        uint256 _heartbeatTimeout
    )
        DetailedERC20(_name, _symbol, _decimals)
        CappedToken(_cap)
        ReservableToken(_addrs, _amounts)
        Heritable(_heartbeatTimeout)
        public
    {

    }
}
