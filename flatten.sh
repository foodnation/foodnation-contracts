#!/usr/bin/env bash

rm -rf flats/*
./node_modules/.bin/truffle-flattener contracts/FoodNationToken.sol > flats/FoodNationToken_flat.sol

./node_modules/.bin/truffle-flattener contracts/GnosisWallet.sol > flats/GnosisWallet_flat.sol

./node_modules/.bin/truffle-flattener contracts/GnosisWalletDailyLimit.sol > flats/GnosisWalletDailyLimit_flat.sol

./node_modules/.bin/truffle-flattener contracts/PreSale.sol > flats/PreSale_flat.sol

./node_modules/.bin/truffle-flattener contracts/VestingToken.sol > flats/VestingToken_flat.sol