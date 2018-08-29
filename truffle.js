/*
 * NB: since truffle-hdwallet-provider 0.0.5 you must wrap HDWallet providers in a 
 * function when declaring them. Failure to do so will cause commands to hang. ex:
 * ```
 * mainnet: {
 *     provider: function() { 
 *       return new HDWalletProvider(mnemonic, 'https://mainnet.infura.io/<infura-key>') 
 *     },
 *     network_id: '1',
 *     gas: 4500000,
 *     gasPrice: 10000000000,
 *   },
 */

require('dotenv').config();
var HDWalletProvider = require("truffle-hdwallet-provider");

const providerWithMnemonic = (mnemonic, rpcEndpoint) =>
    new HDWalletProvider(mnemonic, rpcEndpoint);

const infuraProvider = network => providerWithMnemonic(
    process.env.MNEMONIC || '',
    `https://${network}.infura.io/v3/${process.env.INFURA_API_KEY}`
);

module.exports = {
    // See <http://truffleframework.com/docs/advanced/configuration>
    // to customize your Truffle configuration!
    networks: {
        development: {
            host: 'localhost',
            port: 8545,
            network_id: '*',
            gasPrice: 100000000000
        },
        mainet: {
            provider: infuraProvider,
            port: 443,
            network_id: 1
        },
        ropsten: {
            provider: infuraProvider('ropsten'),
            port: 443,
            network_id: 3,
            gasPrice: 100000000000
        },
        kovan: {
            provider: infuraProvider('kovan'),
            port: 443,
            network_id: 42,
            gasPrice: 100000000000
        },
        rinkeby: {
            provider: infuraProvider('rinkeby'),
            port: 443,
            network_id: "4",
            gasPrice: 100000000000
        }
    },
    solc: {
        optimizer: {
            enabled: true,
            runs: 200
        }
    }
};
