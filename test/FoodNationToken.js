var FoodNationToken = artifacts.require("FoodNationToken");
var NikolaVestingToken = artifacts.require("NikolaVestingToken");
var NeoVestingToken = artifacts.require("NeoVestingToken");

var TeamGnosisWallet = artifacts.require("TeamGnosisWallet");
var AdvisorsGnosisWallet = artifacts.require("AdvisorsGnosisWallet");


var CommunityGnosisDailyLimitWallet = artifacts.require("CommunityGnosisDailyLimitWallet");
var MarketingGnosisDailyLimitWallet = artifacts.require("MarketingGnosisDailyLimitWallet");
var ReserveGnosisDailyLimitWallet = artifacts.require("ReserveGnosisDailyLimitWallet");

const { assertRevert } = require('./helpers/assertRevert');

const units = {
    million: function (val) { return val * 1e6; },
    billion: function (val) { return val * 1e9; }
};

const decimal = 18;

contract('FoodNationToken Test', function () {
    it("should put 9% FoodNation Token in the founders Vesting", async function () {
        var token = FoodNationToken.at(FoodNationToken.address);
        var balanceNikola = await token.balanceOf(NikolaVestingToken.address);
        assert.equal(balanceNikola, units.billion(1) * Math.pow(10, decimal) * 0.045, "4.5% wasn't in the Nikola account");
        var balanceNeo = await token.balanceOf(NeoVestingToken.address);
        assert.equal(balanceNeo, units.billion(1) * Math.pow(10, decimal) * 0.045, "4.5% wasn't in the Neo account");
    });
    it("should put 3% FoodNation Token in the Team Gnosis Wallet", async function () {
        var token = FoodNationToken.at(FoodNationToken.address);
        var balance = await token.balanceOf(TeamGnosisWallet.address);
        assert.equal(balance, units.billion(1) * Math.pow(10, decimal) * 0.03, "3% wasn't in the team account");
    });

    it("should put 3% FoodNation Token in the Advisors Gnosis Wallet", async function () {
        var token = FoodNationToken.at(FoodNationToken.address);
        var balance = await token.balanceOf(AdvisorsGnosisWallet.address);
        assert.equal(balance, units.billion(1) * Math.pow(10, decimal) * 0.03, "3% wasn't in the advisors account");
    });

    it("should put 20% FoodNation Token in the Community Gnosis Wallet", async function () {
        var token = FoodNationToken.at(FoodNationToken.address);
        var balance = await token.balanceOf(CommunityGnosisDailyLimitWallet.address);
        assert.equal(balance, units.billion(1) * Math.pow(10, decimal) * 0.2, "2% wasn't in the community account");
    });

    it("should put 25% FoodNation Token in the Marketing Gnosis Wallet", async function () {
        var token = FoodNationToken.at(FoodNationToken.address);
        var balance = await token.balanceOf(MarketingGnosisDailyLimitWallet.address);
        assert.equal(balance, units.billion(1) * Math.pow(10, decimal) * 0.25, "25% wasn't in the Marketing account");
    });

    it("should put 5% FoodNation Token in the Reserve Gnosis Wallet", async function () {
        var token = FoodNationToken.at(FoodNationToken.address);
        var balance = await token.balanceOf(ReserveGnosisDailyLimitWallet.address);
        assert.equal(balance, units.billion(1) * Math.pow(10, decimal) * 0.05, "5% wasn't in the reserve account");
    });

    it("should throw exception if already distributed reserved tokens", async function () {
        var token = FoodNationToken.at(FoodNationToken.address);
        await assertRevert(token.distributeReservedTokens());
    });
});

