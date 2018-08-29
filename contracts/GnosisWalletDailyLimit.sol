pragma solidity ^0.4.22;

import "./wallet/MultiSigWalletWithDailyLimit.sol";

contract GnosisWalletDailyLimit is MultiSigWalletWithDailyLimit {
    
    string public name;

    /** 
    * @dev Contract constructor sets initial owners, required number of confirmations and daily withdraw limit.
    * @param _owners List of initial owners.
    * @param _required Number of required confirmations.
    * @param _dailyLimit Amount in wei, which can be withdrawn without confirmations on a daily basis.
    */
    constructor(string _name, address[] _owners, uint _required, uint _dailyLimit)
        public
        MultiSigWalletWithDailyLimit(_owners, _required, _dailyLimit)
    {
        name = _name;
    }
}
