var contract = require('truffle-contract');

var FoodNationTokenJson = require("build/contracts/FoodNationToken.json");
var GnosisWalletJson = require("build/contracts/GnosisWallet.json");
var PreSaleJson = require("build/contracts/PreSale.json");
var FVestingTokenJson = require("build/contracts/VestingToken.json");

var nikola_wallet_address = '0x9c78aaec0be3d9ffd55bb0b6b7c61f69c2128a95';
var neo_wallet_address = '0x91c2d785a28181b15decf26d9be812b0f7259a32';

var team_wallet_address = '0x82c89b1b5bfff5b461fa8f1eced4307fd1d528da';
var advisors_wallet_address = '0xd0aa38c0ccc3f3753f7fdb113d9e2cc8d4ae0e41';
var community_wallet_address = '0xb7478fd4c6b4075aa54f1b092d92fd49e6285413';
var marketing_wallet_address = '0x22943d8d007a19dda43aaaebd774194c664cd999';
var reserve_wallet_address = '0xc2ff99f89ad25682c780ac78234935e186bc84d8';
var pre_sale_wallet_address = '0xf69bfa7cf94e39164e731ab58a38a0079108adae';
var sale_wallet_address = '0xb3ccccdd662a6504914752321861108fcd810111';

const duration = {
    seconds: function (val) { return val; },
    minutes: function (val) { return val * this.seconds(60); },
    hours: function (val) { return val * this.minutes(60); },
    days: function (val) { return val * this.hours(24); },
    weeks: function (val) { return val * this.days(7); },
    years: function (val) { return val * this.days(365); },
};

const units = {
    million: function (val) { return val * 1e6; },
    billion: function (val) { return val * 1e9; }
};

const tokencap = units.billion(1);

function Reserved(address, amount) {
    this.address = address;
    this.amount = amount;
}

module.exports = async function (deployer, network, accounts) {
    // Deploy FoodNation Token
    var FoodNationTokenContract = contract(FoodNationTokenJson);
    await deployer.deploy(FoodNationToken, "FoodNation Token", "FOOD", 18, tokencap);
    const deployedToken = await FoodNationToken.deployed();
    console.log(deployedToken.address);

    // Deploy Vesting Factory
    await deployer.deploy(VestingFactory);
    const deployedVestingFactory = await VestingFactory.deployed();

    // Vesting time for Founders
    const timeNow = Math.floor(Date.now() / 1000);
    const founder_start_vesting = timeNow + duration.minutes(10);

    // Nikola Vesting Tokens
    var NikolaVesting = deployedVestingFactory.newVesting("Nikola Wyatt", nikola_wallet_address, founder_start_vesting, duration.years(1), duration.years(1));
    await deployer.deploy(NikolaVesting);
    const deployedNikolaVesting = await NikolaVesting.deployed();

    // Neo Vesting Tokens
    var NeoVesting = deployedVestingFactory.newVesting("Neo Dula", neo_wallet_address, founder_start_vesting, duration.years(1), duration.years(1));
    await deployer.deploy(NeoVesting);
    const deployedNeoVesting = await NeoVesting.deployed();

    var reservedTokens = [];
    reservedTokens.push(new Reserved(reserve_wallet_address, tokencap * 0.05));
    reservedTokens.push(new Reserved(team_wallet_address, tokencap * 0.03));
    reservedTokens.push(new Reserved(advisors_wallet_address, tokencap * 0.03));
    reservedTokens.push(new Reserved(community_wallet_address, tokencap * 0.20));
    reservedTokens.push(new Reserved(marketing_wallet_address, tokencap * 0.25));
    reservedTokens.push(new Reserved(marketing_wallet_address, tokencap * 0.25));
    reservedTokens.push(new Reserved(marketing_wallet_address, tokencap * 0.25));
    reservedTokens.push(new Reserved(deployedNikolaVesting.address, tokencap * 0.045));
    reservedTokens.push(new Reserved(deployedNeoVesting.address, tokencap * 0.045));
    reservedTokens.push(new Reserved(pre_sale_wallet_address.address, tokencap * 0.05));
    reservedTokens.push(new Reserved(sale_wallet_address.address, tokencap * 0.30));

    var addrs = [];
    var amounts = [];
    var reservedTokensLength = reservedTokens.length;
    for (var i = 0; i < reservedTokensLength; i++) {
        addrs.push(reservedTokens[i].address);
        amounts.push(reservedTokens[i].amount);
    }

    deployedToken.setReservedTokensListMultiple(addrs, amounts);
    deployedToken.distributeReservedTokens();



    const presale1_rate = 100;// Change to USD;
    const presale_openingTime = Math.floor(new Date(2018, 8, 21, 0, 0, 0, 0) / 1000);
    const presale_closingTime = Math.floor(new Date(2018, 11, 20, 23, 59, 59, 59) / 1000);
    const presale1_cap = web3.toWei(10000000);// Change to tokens

    await deployer.deploy(
        PreSale1,
        presale1_rate,
        wallet,
        deployedToken.address,
        presale_openingTime,
        presale_closingTime,
        presale1_cap
    );
};
