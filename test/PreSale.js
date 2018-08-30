var PreSale = artifacts.require("PreSale");
var FoodNationToken = artifacts.require("FoodNationToken");

const { advanceBlock } = require('./helpers/advanceToBlock');
const { expectThrow } = require('./helpers/expectThrow');
const { EVMRevert } = require('./helpers/EVMRevert');
const { ether } = require('./helpers/ether');
const { increaseTimeTo, duration } = require('./helpers/increaseTime');

const openingTime = Math.floor(new Date(2018, 8, 21, 0, 0, 0, 0) / 1000);
const closingTime = Math.floor(new Date(2018, 11, 20, 23, 59, 59, 59) / 1000);

const beforeOpeningTime = openingTime - duration.weeks(1);
const afterClosingTime = closingTime + duration.weeks(1);

const firstMilestone = Math.floor(new Date(2018, 8, 21, 0, 0, 0, 0) / 1000);
const secondMilestone = Math.floor(new Date(2018, 9, 21, 0, 0, 0, 0) / 1000);
const thirdMilestone = Math.floor(new Date(2018, 10, 21, 0, 0, 0, 0) / 1000);

contract('PreSale Test', function ([_, investor, purchaser]) {

    const value = ether(1);

    before(async function () {
        // Advance to the next block to correctly read time in the solidity "now" function interpreted by ganache
        await advanceBlock();
    });

    after(async function () {
        // Advance to the next block to correctly read time in the solidity "now" function interpreted by ganache
        await advanceBlock();
    });

    it('should reject payments before start', function () {
        PreSale.deployed().then(async function (crowdsale) {
            await increaseTimeTo(beforeOpeningTime);
            await expectThrow(crowdsale.send(value), EVMRevert);
            await expectThrow(crowdsale.buyTokens(investor, { from: purchaser, value: value }), EVMRevert);
        });
    });

    it('should accept payments after start', function () {
        PreSale.deployed().then(async function (crowdsale) {
            await increaseTimeTo(openingTime + duration.minutes(1));
            await crowdsale.send(ether(42));
            await crowdsale.buyTokens(investor, { value: ether(42), from: purchaser });
        });
    });

    it('should update the ETH USD value', function () {
        PreSale.deployed().then(async function (crowdsale) {
            await updatePrice(30000);
            assert.equal(crowdsale.ETHUSD, 30000, "The price wasn't updated correctly");
        });
    });

    it('should convert to the right amount of food in first milestone', function () {
        PreSale.deployed().then(async function (crowdsale) {
            await increaseTimeTo(firstMilestone + duration.minutes(1));
            await updatePrice(30000);
            await crowdsale.send(value);
            await crowdsale.buyTokens(investor, { value: value, from: purchaser });
            var token = await FoodNationToken.deployed()
            var balance = await token.balanceOf.call(purchaser);
            console.log(balance);
            assert.equal(balance, 30000 * Math.pow(10, decimal), "First milestone convertion is not right");
        });
    });

    it('should convert to the right amount of food in second milestone', function () {
        PreSale.deployed().then(async function (crowdsale) {
            await increaseTimeTo(secondMilestone + duration.minutes(1));
            await updatePrice(30000);
            await crowdsale.send(value);
            await crowdsale.buyTokens(investor, { value: value, from: purchaser });
            var token = await FoodNationToken.deployed()
            var balance = await token.balanceOf.call(purchaser);
            console.log(balance);
            assert.equal(balance, 15000 * Math.pow(10, decimal), "First milestone convertion is not right");
        });
    });

    it('should convert to the right amount of food in second milestone', function () {
        PreSale.deployed().then(async function (crowdsale) {
            await increaseTimeTo(thirdMilestone + duration.minutes(1));
            await updatePrice(30000);
            await crowdsale.send(value);
            await crowdsale.buyTokens(investor, { value: value, from: purchaser });
            var token = await FoodNationToken.deployed()
            var balance = await token.balanceOf.call(purchaser);
            console.log(balance);
            assert.equal(balance, 7500 * Math.pow(10, decimal), "First milestone convertion is not right");
        });
    });

    it('should be ended only after end', async () => {
        PreSale.deployed().then(async function (crowdsale) {
            (await crowdsale.hasClosed()).should.equal(false);
            await increaseTimeTo(afterClosingTime);
            (await crowdsale.hasClosed()).should.equal(true);
        });
    });

    it('should reject payments after end', function () {
        PreSale.deployed().then(async function (crowdsale) {
            await increaseTimeTo(afterClosingTime + 1);
            await expectThrow(crowdsale.send(value), EVMRevert);
            await expectThrow(crowdsale.buyTokens(investor, { value: value, from: purchaser }), EVMRevert);
        });
    });
});
