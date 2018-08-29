pragma solidity ^0.4.22;

import "./wallet/MultiSigWallet.sol";

contract GnosisWallet is MultiSigWallet {
    
    string public name;

    /** 
    * @dev Contract constructor sets initial owners, required number of confirmations and daily withdraw limit.
    * @param _owners List of initial owners.
    * @param _required Number of required confirmations.
    */
    constructor(string _name, address[] _owners, uint _required)
        public
        MultiSigWallet(_owners, _required)
    {
        name = _name;
    }
}
