var FelipeTimelockToken = artifacts.require("FelipeTimelockToken");

var VitorTimelockToken = artifacts.require("VitorTimelockToken");

var FoodNationToken = artifacts.require("FoodNationToken");

var felipe_wallet = '0xb3c833bfD919E709061EDfa3360eCE2e1B196a51';

var vitor_wallet = '0x34c7f7382935e556fcb06b4f574594923ccf2b30';

const duration = {
    seconds: function (val) { return val; },
    minutes: function (val) { return val * this.seconds(60); },
    hours: function (val) { return val * this.minutes(60); },
    days: function (val) { return val * this.hours(24); },
    weeks: function (val) { return val * this.days(7); },
    years: function (val) { return val * this.days(365); },
};

function deployVesting(deployer, vestingToken, name, destination_wallet, years) {
    // Vesting time for Team
    const timeNow = Math.floor(Date.now() / 1000);
    const timelock = timeNow + duration.years(years);
    return deployer.deploy(vestingToken, name, FoodNationToken.address, destination_wallet, timelock);
}

module.exports = function (deployer) {

    var promises = [];

    // Felipe Timelock Tokens
    console.log("Creating Felipe Timelock wallet...");
    promises.push(deployVesting(deployer, FelipeTimelockToken, "Felipe Carvalho", felipe_wallet, 1));

    // Vitor Timelock Tokens
    console.log("Creating Vitor Timelock wallet...");
    promises.push(deployVesting(deployer, VitorTimelockToken, "Vitor Lançoni", vitor_wallet, 1));

    Promise.all(promises)
        .then(async () => {
            var deployedFelipeVestingToken = FelipeTimelockToken;
            console.log("Felipe Timelock wallet address: " + deployedFelipeVestingToken.address);

            var deployedVitorVestingToken = VitorVestingToken;
            console.log("Vitor Timelock wallet address: " + VitorTimelockToken.address);
        });
}
