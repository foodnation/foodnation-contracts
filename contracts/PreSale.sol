pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/payment/RefundEscrow.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "./crowdsale/Crowdsale.sol";
import "./crowdsale/validation/MilestoneCrowdsale.sol";
import "./price/USDPrice.sol";

interface MintableERC20 {
    function mint(address _to, uint256 _amount) public returns (bool);
}

/**
 * @title PreSale
 * @dev Crowdsale accepting contributions only within a time frame, 
 * having milestones defined, the price is defined in USD
 * having a mechanism to refund sales if soft cap not capReached();
 * And an escrow to support the refund.
 */
contract PreSale is Ownable, Crowdsale, MilestoneCrowdsale {
    using SafeMath for uint256;

    /// Max amount of tokens to be contributed
    uint256 public cap;

    /// Minimum amount of wei per contribution
    uint256 public minimumContribution;

    /// minimum amount of funds to be raised in weis
    uint256 public goal;
    
    bool public isFinalized = false;

    /// refund escrow used to hold funds while crowdsale is running
    RefundEscrow private escrow;

    USDPrice private usdPrice; 

    event Finalized();

    constructor(
        uint256 _rate,
        address _wallet,
        ERC20 _token,
        uint256 _openingTime,
        uint256 _closingTime,
        uint256 _goal,
        uint256 _cap,
        uint256 _minimumContribution,
        USDPrice _usdPrice
    )
        Crowdsale(_rate, _wallet, _token)
        MilestoneCrowdsale(_openingTime, _closingTime)
        public
    {  
        require(_cap > 0);
        require(_minimumContribution > 0);
        require(_goal > 0);
        
        cap = _cap;
        minimumContribution = _minimumContribution;

        escrow = new RefundEscrow(wallet);
        goal = _goal;
        usdPrice = _usdPrice;
    }


    /**
    * @dev Checks whether the cap has been reached.
    * @return Whether the cap was reached
    */
    function capReached() public view returns (bool) {
        return tokensSold >= cap;
    }

    /**
    * @dev Investors can claim refunds here if crowdsale is unsuccessful
    */
    function claimRefund() public {
        require(isFinalized);
        require(!goalReached());

        escrow.withdraw(msg.sender);
    }

    /**
    * @dev Checks whether funding goal was reached.
    * @return Whether funding goal was reached
    */
    function goalReached() public view returns (bool) {
        return tokensSold >= goal;
    }

    /**
    * @dev Must be called after crowdsale ends, to do some extra finalization
    * work. Calls the contract's finalization function.
    */
    function finalize() public onlyOwner {
        require(!isFinalized);
        require(goalReached() || hasClosed());

        finalization();
        emit Finalized();

        isFinalized = true;
    }

    /**
    * @dev Override to extend the way in which ether is converted to tokens.
    * @param _weiAmount Value in wei to be converted into tokens
    * @return Number of tokens that can be purchased with the specified _weiAmount
    */
    function _getTokenAmount(uint256 _weiAmount)
        internal view returns (uint256)
    {
        return usdPrice.getPrice(_weiAmount).div(getCurrentRate());
    }

    /**
    * @dev Extend parent behavior sending heartbeat to token.
    * @param _beneficiary Address receiving the tokens
    * @param _weiAmount Value in wei involved in the purchase
    * @param _tokenAmount Value in token involved in the purchase
    */
    function _updatePurchasingState(
        address _beneficiary,
        uint256 _weiAmount,
        uint256 _tokenAmount
    )
        internal
    {
        super._updatePurchasingState(_beneficiary, _weiAmount, _tokenAmount);
    }
    
    /**
    * @dev Overrides delivery by minting tokens upon purchase. - MINTED Crowdsale
    * @param _beneficiary Token purchaser
    * @param _tokenAmount Number of tokens to be minted
    */
    function _deliverTokens(
        address _beneficiary,
        uint256 _tokenAmount
    )
        internal
    {
        // Potentially dangerous assumption about the type of the token.
        require(MintableERC20(address(token)).mint(_beneficiary, _tokenAmount));
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
        require(_weiAmount >= minimumContribution);
        require(tokensSold.add(_tokenAmount) <= cap);
    }

    /**
    * @dev escrow finalization task, called when owner calls finalize()
    */
    function finalization() internal {
        if (goalReached()) {
            escrow.close();
            escrow.beneficiaryWithdraw();
        } else {
            escrow.enableRefunds();
        }
    }

    /**
    * @dev Overrides Crowdsale fund forwarding, sending funds to escrow.
    */
    function _forwardFunds() internal {
        escrow.deposit.value(msg.value)(msg.sender);
    }

}