pragma solidity ^0.4.24;

import "./wallet/MultiSigWallet.sol";

contract GnosisWallet is MultiSigWallet {
    
    /** 
    * @dev Contract constructor sets initial owners, required number of confirmations and daily withdraw limit.
    * @param _owners List of initial owners.
    * @param _required Number of required confirmations.
    */
    constructor(address[] _owners, uint _required)
        public
        MultiSigWallet(_owners, _required)
    { }
}
