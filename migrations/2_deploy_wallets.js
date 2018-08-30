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

const duration = {
    seconds: function (val) { return val; },
    minutes: function (val) { return val * this.seconds(60); },
    hours: function (val) { return val * this.minutes(60); },
    days: function (val) { return val * this.hours(24); },
    weeks: function (val) { return val * this.days(7); },
    years: function (val) { return val * this.days(365); },
};

function deployGnosisWallet(deployer, wallet, owners) {
    return deployer.deploy(wallet, owners, 2);
}

function deployGnosisDailyLimitWallet(deployer, wallet, owners, limit) {
    return deployer.deploy(wallet, owners, 2, limit);
}

function deployVesting(deployer, vestingToken, name, destination_wallet) {
    // Vesting time for Founders
    const timeNow = Math.floor(Date.now() / 1000);
    const founder_start_vesting = timeNow + duration.minutes(10);
    return deployer.deploy(vestingToken, name, destination_wallet, founder_start_vesting, duration.years(1), duration.years(1), false);
}

module.exports = function (deployer) {

    var owners = [];
    owners.push(nikola_hot_wallet);
    owners.push(neo_hot_wallet);

    var promises = [];

    console.log("Creating Team wallet...");

    console.log("Creating Advisors wallet...");
    promises.push(deployGnosisWallet(deployer, TeamGnosisWallet, owners, 2));

    console.log("Creating Advisors wallet...");
    promises.push(deployGnosisWallet(deployer, AdvisorsGnosisWallet, owners, 2));

    console.log("Creating Community wallet...");
    promises.push(deployGnosisDailyLimitWallet(deployer, CommunityGnosisDailyLimitWallet, owners, web3.toWei(150)));

    console.log("Creating Marketing wallet...");
    promises.push(deployGnosisDailyLimitWallet(deployer, MarketingGnosisDailyLimitWallet, owners, web3.toWei(150)));

    console.log("Creating Reserve wallet...");
    promises.push(deployGnosisDailyLimitWallet(deployer, ReserveGnosisDailyLimitWallet, owners, web3.toWei(150)));

    // Nikola Vesting Tokens
    console.log("Creating Nikola Vesting wallet...");
    promises.push(deployVesting(deployer, NikolaVestingToken, "Nikola Wyatt", nikola_cold_wallet));

    // Neo Vesting Tokens
    console.log("Creating Neo Vesting wallet...");
    promises.push(deployVesting(deployer, NeoVestingToken, "Neo Dula", neo_cold_wallet));

    // Wallet to where funds will be directioned
    console.log("Creating Sales wallet...");
    promises.push(deployGnosisDailyLimitWallet(deployer, SalesGnosisDailyLimitWallet, owners, web3.toWei(150)));

    Promise.all(promises)
        .then(async () => {
            var deployedTeamWallet = TeamGnosisWallet;
            console.log("Team wallet address: " + deployedTeamWallet.address);

            var deployedAdvisorsWallet = AdvisorsGnosisWallet;
            console.log("Advisors wallet address: " + deployedAdvisorsWallet.address);

            var deployedCommunityWallet = CommunityGnosisDailyLimitWallet;
            console.log("Community wallet address: " + deployedCommunityWallet.address);

            var deployedMarketingWallet = MarketingGnosisDailyLimitWallet;
            console.log("Marketing wallet address: " + deployedMarketingWallet.address);

            var deployedReserveWallet = ReserveGnosisDailyLimitWallet;
            console.log("Reserve wallet address: " + deployedReserveWallet.address);

            var deployedNikolaVestingToken = NikolaVestingToken;
            console.log("Nikola Vesting wallet address: " + deployedNikolaVestingToken.address);

            var deployedNeoVestingToken = NeoVestingToken;
            console.log("Neo Vesting wallet address: " + deployedNeoVestingToken.address);

            deployedSalesWallet = SalesGnosisDailyLimitWallet;
            console.log("Sales wallet address: " + deployedSalesWallet.address);

        });
}
