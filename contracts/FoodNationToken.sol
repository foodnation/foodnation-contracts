pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol";
import "openzeppelin-solidity/contracts/token/ERC20/CappedToken.sol";
import "openzeppelin-solidity/contracts/token/ERC20/DetailedERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/PausableToken.sol";
import "openzeppelin-solidity/contracts/ownership/Superuser.sol";

import "./token/UpgradeableToken.sol";
import "./token/ReservableToken.sol";

contract FoodNationToken is StandardToken, MintableToken, CappedToken, DetailedERC20, PausableToken, UpgradeableToken, ReservableToken, Superuser {

    constructor(
        string _name, 
        string _symbol, 
        uint8 _decimals, 
        uint256 _cap, 
        address[] _addrs, 
        uint256[] _amounts
    )
        DetailedERC20(_name, _symbol, _decimals)
        CappedToken(_cap)
        ReservableToken(_addrs, _amounts)
        public
    {

    }
}