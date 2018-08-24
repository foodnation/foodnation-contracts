#!/usr/bin/env bash

rm -rf flats/*
./node_modules/.bin/truffle-flattener contracts/FoodNationToken.sol > flats/FoodNationToken_flat.sol

./node_modules/.bin/truffle-flattener contracts/VestingFactory.sol > flats/VestingFactory_flat.sol

./node_modules/.bin/truffle-flattener contracts/Vesting.sol > flats/Vesting_flat.sol

./node_modules/.bin/truffle-flattener contracts/PreSale.sol > flats/PreSale_flat.sol