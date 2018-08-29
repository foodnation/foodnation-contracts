var FoodNationToken = artifacts.require("FoodNationToken");
var PreSale = artifacts.require("PreSale");

var TeamGnosisWallet = artifacts.require("TeamGnosisWallet");
var AdvisorsGnosisWallet = artifacts.require("AdvisorsGnosisWallet");

var CommunityGnosisDailyLimitWallet = artifacts.require("CommunityGnosisDailyLimitWallet");
var MarketingGnosisDailyLimitWallet = artifacts.require("MarketingGnosisDailyLimitWallet");
var ReserveGnosisDailyLimitWallet = artifacts.require("ReserveGnosisDailyLimitWallet");
var SalesGnosisDailyLimitWallet = artifacts.require("SalesGnosisDailyLimitWallet");

var NikolaVestingToken = artifacts.require("NikolaVestingToken");
var NeoVestingToken = artifacts.require("NeoVestingToken");

var nikola_hot_wallet = '0x9c78aaec0be3d9ffd55bb0b6b7c61f69c2128a95';

var neo_hot_wallet = '0x91c2d785a28181b15decf26d9be812b0f7259a32';

var nikola_cold_wallet = '0xC3c52ee3C5CE608377401522174FcD35CD1e54df';
var neo_cold_wallet = '0x22E5FDD2Cad32296986BC97f01e2406e08206676';

var nikola_dev_wallet = '0xD89Fd61c4916e607823cD48d4f90F2A191F8e11c';

const decimals = 18;

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

async function deployGnosisWallet(deployer, wallet, name, owners) {
    return await deployer.deploy(wallet, name, owners, 2)
        .then(() => wallet.deployed());
}

async function deployGnosisDailyLimitWallet(deployer, wallet, name, owners, limit) {
    return await deployer.deploy(wallet, name, owners, 2, limit)
        .then(() => wallet.deployed());
}

async function deployVesting(deployer, vestingToken, name, destination_wallet) {
    // Vesting time for Founders
    const timeNow = Math.floor(Date.now() / 1000);
    const founder_start_vesting = timeNow + duration.minutes(10);
    return await deployer.deploy(vestingToken, name, destination_wallet, founder_start_vesting, duration.years(1), duration.years(1), false)
        .then(() => vestingToken.deployed());
}

async function deployToken(deployer, token, name, tick, tokencap, addrs, amounts, heartbeat) {
    return await deployer.deploy(FoodNationToken, name, tick, decimals, tokencap, addrs, amounts, heartbeat)
        .then(() => token.deployed());
}

module.exports = function (deployer) {

    var owners = [];
    owners.push(nikola_hot_wallet);
    owners.push(neo_hot_wallet);

    console.log("Crating Team wallet...");
    var deployedTeamWallet = deployGnosisWallet(deployer, TeamGnosisWallet, "team", owners, 2);
    console.log("Team wallet address: " + deployedTeamWallet.address);

    console.log("Crating Advisors wallet...");
    var deployedAdvisorsWallet = deployGnosisWallet(deployer, AdvisorsGnosisWallet, "advisors", owners, 2);
    console.log("Advisors wallet address: " + deployedAdvisorsWallet.address);


    console.log("Crating Community wallet...");
    var deployedCommunityWallet = deployGnosisDailyLimitWallet(deployer, CommunityGnosisDailyLimitWallet, "community", owners, web3.toWei(150));
    console.log("Community wallet address: " + deployedCommunityWallet.address);

    console.log("Crating Marketing wallet...");
    var deployedMarketingWallet = deployGnosisDailyLimitWallet(deployer, MarketingGnosisDailyLimitWallet, "marketing", owners, web3.toWei(150));
    console.log("Marketing wallet address: " + deployedMarketingWallet.address);

    console.log("Crating Reserve wallet...");
    var deployedReserveWallet = deployGnosisDailyLimitWallet(deployer, ReserveGnosisDailyLimitWallet, "reserve", owners, web3.toWei(150));
    console.log("Reserve wallet address: " + deployedReserveWallet.address);

    // Nikola Vesting Tokens
    console.log("Crating Nikola Vesting wallet...");
    var deployedNikolaVestingToken = deployVesting(deployer, NikolaVestingToken, "Nikola Wyatt", nikola_cold_wallet);
    console.log("Nikola Vesting wallet address: " + deployedNikolaVestingToken.address);

    // Neo Vesting Tokens
    console.log("Crating Neo Vesting wallet...");
    var deployedNeoVestingToken = deployVesting(deployer, NeoVestingToken, "Neo Dula", neo_cold_wallet);
    console.log("Neo Vesting wallet address: " + deployedNeoVestingToken.address);

    var reservedTokens = [];
    reservedTokens.push(new Reserved(deployedReserveWallet.address, tokencap * 0.05));
    reservedTokens.push(new Reserved(deployedTeamWallet.address, tokencap * 0.03));
    reservedTokens.push(new Reserved(deployedAdvisorsWallet.address, tokencap * 0.03));
    reservedTokens.push(new Reserved(deployedCommunityWallet.address, tokencap * 0.20));
    reservedTokens.push(new Reserved(deployedMarketingWallet.address, tokencap * 0.25));
    reservedTokens.push(new Reserved(deployedNikolaVestingToken.address, tokencap * 0.045));
    reservedTokens.push(new Reserved(deployedNeoVestingToken.address, tokencap * 0.045));

    var addrs = [];
    var amounts = [];
    var reservedTokensLength = reservedTokens.length;
    for (var i = 0; i < reservedTokensLength; i++) {
        addrs.push(reservedTokens[i].address);
        amounts.push(reservedTokens[i].amount);
    }

    // Deploy FoodNation Token
    console.log("Crating Token...");
    var deployedToken = deployToken(FoodNationToken, "FoodNation Token", "FOOD", addrs, amounts, duration.days(2));
    console.log("Token address: " + deployedToken.address);

    // Pre Sale constructor variables
    const constantRate = 10; // 0,10 USD;

    // Wallet to where funds will be directioned
    console.log("Crating Sales wallet...");
    deployedSalesWallet = deployGnosisDailyLimitWallet(deployer, SalesGnosisDailyLimitWallet, "sales", owners, web3.toWei(150));
    console.log("Sales wallet address: " + deployedSalesWallet.address);

    const presale_openingTime = Math.floor(new Date(2018, 8, 21, 0, 0, 0, 0) / 1000);
    const presale_closingTime = Math.floor(new Date(2018, 11, 20, 23, 59, 59, 59) / 1000);

    var milestoneStartTime = [];
    milestoneStartTime.push(Math.floor(new Date(2018, 8, 21, 0, 0, 0, 0) / 1000));
    milestoneStartTime.push(Math.floor(new Date(2018, 9, 21, 0, 0, 0, 0) / 1000));
    milestoneStartTime.push(Math.floor(new Date(2018, 10, 21, 0, 0, 0, 0) / 1000));

    var milestoneCap = [];
    milestoneCap.push(units.million(10) * (Math.pow(10, decimals)));
    milestoneCap.push(units.million(15) * (Math.pow(10, decimals)));
    milestoneCap.push(units.million(25) * (Math.pow(10, decimals)));

    var milestoneRate = [];
    milestoneRate.push(1);
    milestoneRate.push(2);
    milestoneRate.push(4);

    var goal = units.million(1) * Math.pow(10, decimals);

    var cap = units.million(50) * Math.pow(10, decimals);

    const minimumContribution = web3.toWei(0.2);

    console.log("Crating Pre Sale...");
    deployer.deploy(
        PreSale,
        constantRate,
        deployedSalesWallet.address,
        deployedToken.address,
        presale_openingTime,
        presale_closingTime,
        milestoneStartTime,
        milestoneCap,
        milestoneRate,
        goal,
        cap,
        minimumContribution
    ).then(async () => {
        const deployedCrowdsale = await PreSale.deployed();
        console.log("Pre Sale address: " + deployedSalesWallet.address);

        deployedToken.setHeir(nikola_dev_wallet)

        deployedToken.transferOwnership(deployedCrowdsale.address)
    });
}
