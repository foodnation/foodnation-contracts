var FoodNationToken = artifacts.require("FoodNationToken");
var NikolaVestingToken = artifacts.require("NikolaVestingToken");
var NeoVestingToken = artifacts.require("NeoVestingToken");

var TeamGnosisWallet = artifacts.require("TeamGnosisWallet");
var AdvisorsGnosisWallet = artifacts.require("AdvisorsGnosisWallet");

var CommunityGnosisDailyLimitWallet = artifacts.require("CommunityGnosisDailyLimitWallet");
var MarketingGnosisDailyLimitWallet = artifacts.require("MarketingGnosisDailyLimitWallet");
var ReserveGnosisDailyLimitWallet = artifacts.require("ReserveGnosisDailyLimitWallet");

const { expectThrow } = require('./helpers/expectThrow');
const { EVMRevert } = require('./helpers/EVMRevert');

const units = {
    million: function (val) { return val * 1e6; },
    billion: function (val) { return val * 1e9; }
};

const decimal = 18;

contract('FoodNationToken Test', function () {
    it("should put 9% FoodNation Token in the founders Vesting", function () {
        FoodNationToken.deployed().then(function (instance) {
            var balance = instance.balanceOf.call(NikolaVestingToken.address) + instance.balanceOf.call(NeoVestingToken.address);
            return balance;
        }).then(function (balance) {
            assert.equal(balance, units.billion(1) * Math.pow(10, decimal) * 0.09, "9% wasn't in the founders account");
        });
    });

    it("should put 3% FoodNation Token in the Team Gnosis Wallet", function () {
        FoodNationToken.deployed().then(function (instance) {
            var balance = instance.balanceOf.call(TeamGnosisWallet.address);
            return balance;
        }).then(function (balance) {
            assert.equal(balance, units.billion(1) * Math.pow(10, decimal) * 0.03, "3% wasn't in the team account");
        });
    });

    it("should put 3% FoodNation Token in the Advisors Gnosis Wallet", function () {
        FoodNationToken.deployed().then(function (instance) {
            var balance = instance.balanceOf.call(AdvisorsGnosisWallet.address);
            return balance;
        }).then(function (balance) {
            assert.equal(balance, units.billion(1) * Math.pow(10, decimal) * 0.03, "3% wasn't in the advisors account");
        });
    });

    it("should put 20% FoodNation Token in the Community Gnosis Wallet", function () {
        FoodNationToken.deployed().then(function (instance) {
            var balance = instance.balanceOf.call(CommunityGnosisDailyLimitWallet.address);
            return balance;
        }).then(function (balance) {
            assert.equal(balance, units.billion(1) * Math.pow(10, decimal) * 0.2, "2% wasn't in the community account");
        });
    });

    it("should put 25% FoodNation Token in the Marketing Gnosis Wallet", function () {
        FoodNationToken.deployed().then(function (instance) {
            var balance = instance.balanceOf.call(MarketingGnosisDailyLimitWallet.address);
            return balance;
        }).then(function (balance) {
            assert.equal(balance, units.billion(1) * Math.pow(10, decimal) * 0.25, "25% wasn't in the Marketing account");
        });
    });

    it("should put 5% FoodNation Token in the Reserve Gnosis Wallet", function () {
        FoodNationToken.deployed().then(function (instance) {
            var balance = instance.balanceOf.call(ReserveGnosisDailyLimitWallet.address);
            return balance;
        }).then(function (balance) {
            assert.equal(balance, units.billion(1) * Math.pow(10, decimal) * 0.05, "5% wasn't in the reserve account");
        });
    });

    it("should throw exception if already distributed reserved tokens", function () {
        FoodNationToken.deployed().then(async function (instance) {
            await expectThrow(instance.distributeReservedTokens(), EVMRevert);
        });
    });


});