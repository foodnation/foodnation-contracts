var PreSale = artifacts.require("PreSale");
var USDPrice = artifacts.require("USDPrice");

const { assertRevert } = require('./helpers/assertRevert');
const { ethGetBalance } = require('./helpers/web3');
const { ether } = require('./helpers/ether');
const { increaseTimeTo, duration } = require('./helpers/increaseTime');

const openingTime = Math.floor(new Date(2018, 8, 21, 0, 0, 0, 0) / 1000);
const closingTime = Math.floor(new Date(2018, 11, 21, 0, 0, 0, 0) / 1000);

const beforeOpeningTime = openingTime - duration.minutes(10);
const afterClosingTime = closingTime + duration.minutes(10);

const firstMilestone = Math.floor(new Date(2018, 8, 21, 0, 0, 0, 0) / 1000);
const secondMilestone = Math.floor(new Date(2018, 9, 21, 0, 0, 0, 0) / 1000);
const thirdMilestone = Math.floor(new Date(2018, 10, 21, 0, 0, 0, 0) / 1000);

const decimal = 18;

const BigNumber = web3.BigNumber;

const should = require('chai')
    .use(require('chai-bignumber')(BigNumber))
    .should();

contract('PreSale Test', function ([_, owner, wallet, investor, thirdparty]) {

    const value = ether(1);
    const goal = ether(90);
    const crowdsale = PreSale.at(PreSale.address);
    const usdPrice = USDPrice.at(USDPrice.address);

    it('should reject payments before start', async () => {
        await increaseTimeTo(beforeOpeningTime);
        await assertRevert(crowdsale.send(value));
        await assertRevert(crowdsale.buyTokens(investor, { value: value }));
    });

    it('should deny refunds before start', async function () {
        await assertRevert(crowdsale.claimRefund({ from: investor }));
    });

    it('should accept payments after start', async () => {
        await increaseTimeTo(openingTime + duration.minutes(1));
        await crowdsale.buyTokens(investor, { value: value });
    });

    it('should update the ETH USD value', async () => {
        await usdPrice.updatePrice(30000);
        var ETHUSD = await usdPrice.ETHUSD();
        assert.equal(ETHUSD, 30000, "The price wasn't updated correctly");
    });

    it('cannot be finalized before ending', async function () {
        var crowdsale = PreSale.at(PreSale.address);
        await assertRevert(crowdsale.finalize());
    });

    it('should deny refunds before end', async function () {
        await assertRevert(crowdsale.claimRefund({ from: investor }));
    });

    it('should convert to the right amount of food in first milestone', async () => {
        await increaseTimeTo(firstMilestone + duration.minutes(10));
        await usdPrice.updatePrice(30000);
        const { logs } = await crowdsale.buyTokens(investor, { value: value });
        const event = logs.find(e => e.event === 'TokenPurchase');
        should.exist(event);
        event.args.amount.should.be.bignumber.equal(30000 * Math.pow(10, decimal));
    });

    it('should convert to the right amount of food in second milestone', async () => {
        await increaseTimeTo(secondMilestone + duration.minutes(10));
        await usdPrice.updatePrice(30000);
        const { logs } = await crowdsale.buyTokens(investor, { value: value });
        const event = logs.find(e => e.event === 'TokenPurchase');
        should.exist(event);
        event.args.amount.should.be.bignumber.equal(15000 * Math.pow(10, decimal));
    });

    it('should convert to the right amount of food in third milestone', async () => {
        await increaseTimeTo(thirdMilestone + duration.minutes(10));
        await usdPrice.updatePrice(30000);
        const { logs } = await crowdsale.buyTokens(investor, { value: value });
        const event = logs.find(e => e.event === 'TokenPurchase');
        should.exist(event);
        event.args.amount.should.be.bignumber.equal(7500 * Math.pow(10, decimal));
    });

    it('should reach goal', async () => {
        await usdPrice.updatePrice(200000);
        await crowdsale.buyTokens(investor, { value: goal });
        var reached = await crowdsale.goalReached();
        assert.equal(reached, true, "The goal wasn't reached");
    });

    it('should be ended only after end', async () => {
        (await crowdsale.hasClosed()).should.equal(false);
        await increaseTimeTo(afterClosingTime);
        (await crowdsale.hasClosed()).should.equal(true);
    });

    it('should reject payments after end', async () => {
        await assertRevert(crowdsale.send(value));
        await assertRevert(crowdsale.buyTokens(investor, { value: value }));
    });

    it('cannot be finalized by third party after ending', async function () {
        await assertRevert(crowdsale.finalize({ from: thirdparty }));
    });

    it('can be finalized by owner after ending', async function () {
        await crowdsale.finalize();
    });

    it('cannot be finalized twice', async function () {
        await assertRevert(crowdsale.finalize());
    });

    it('should deny refunds after end if goal was reached', async function () {
        await assertRevert(crowdsale.claimRefund({ from: investor }));
    });

});
