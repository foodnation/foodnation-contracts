var FoodNationToken = artifacts.require("FoodNationToken");
var TeamGnosisWallet = artifacts.require("TeamGnosisWallet");
var AdvisorsGnosisWallet = artifacts.require("AdvisorsGnosisWallet");

var CommunityGnosisDailyLimitWallet = artifacts.require("CommunityGnosisDailyLimitWallet");
var MarketingGnosisDailyLimitWallet = artifacts.require("MarketingGnosisDailyLimitWallet");
var ReserveGnosisDailyLimitWallet = artifacts.require("ReserveGnosisDailyLimitWallet");

var NikolaVestingToken = artifacts.require("NikolaVestingToken");
var NeoVestingToken = artifacts.require("NeoVestingToken");

const decimals = 18;

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

const tokencap = units.billion(1) * Math.pow(10, decimals);

function Reserved(address, amount) {
    this.address = address;
    this.amount = amount;
}

function deployToken(deployer, token, name, tick, addrs, amounts) {
    return deployer.deploy(token, name, tick, decimals, tokencap, addrs, amounts);
}

module.exports = function (deployer) {

    var reservedTokens = [];
    reservedTokens.push(new Reserved(ReserveGnosisDailyLimitWallet.address, tokencap * 0.05));
    reservedTokens.push(new Reserved(TeamGnosisWallet.address, tokencap * 0.03));
    reservedTokens.push(new Reserved(AdvisorsGnosisWallet.address, tokencap * 0.03));
    reservedTokens.push(new Reserved(CommunityGnosisDailyLimitWallet.address, tokencap * 0.20));
    reservedTokens.push(new Reserved(MarketingGnosisDailyLimitWallet.address, tokencap * 0.25));
    reservedTokens.push(new Reserved(NikolaVestingToken.address, tokencap * 0.045));
    reservedTokens.push(new Reserved(NeoVestingToken.address, tokencap * 0.045));

    var addrs = [];
    var amounts = [];
    var reservedTokensLength = reservedTokens.length;
    for (var i = 0; i < reservedTokensLength; i++) {
        console.log("Wallet address: " + reservedTokens[i].address + " will receive: " + reservedTokens[i].amount);
        addrs.push(reservedTokens[i].address);
        amounts.push(reservedTokens[i].amount);
    }

    console.log("Reserved List size: " + reservedTokens.length);

    console.log("Creating Token...");

    deployToken(deployer, FoodNationToken, "FoodNation Token", "FOOD", addrs, amounts)
        .then(async (deployedToken) => {
            console.log("Token Created...:" + deployedToken.address);
            var distributed = await deployedToken.distributeReservedTokens();
            console.log("Reserved Tokens Distributed...: " + distributed);
        });
}
