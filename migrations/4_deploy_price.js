var USDPrice = artifacts.require("USDPrice");

module.exports = function (deployer) {

    deployer.deploy(USDPrice)
        .then(async (usdPriceDeployed) => {
            console.log("USD Price deployed...");

            await usdPriceDeployed.updatePrice(30000);
            console.log("USD price set");
        });
}