#!/usr/bin/env bash

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"

rm -rf flats
mkdir flats

truffle-flattener contracts/FoodNationToken.sol > flats/FoodNationToken_flat.sol

truffle-flattener contracts/GnosisWallet.sol > flats/GnosisWallet_flat.sol

truffle-flattener contracts/GnosisWalletDailyLimit.sol > flats/GnosisWalletDailyLimit_flat.sol

truffle-flattener contracts/PreSale.sol > flats/PreSale_flat.sol

truffle-flattener contracts/VestingToken.sol > flats/VestingToken_flat.sol