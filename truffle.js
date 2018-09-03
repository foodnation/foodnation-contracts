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
            gas: 7500000,
            gasPrice: 5000000000
        },
        mainnet: {
            provider: infuraProvider('mainnet'),
            network_id: '1',
            gas: 4712388,
            gasPrice: 20000000000
        },
        ropsten: {
            provider: infuraProvider('ropsten'),
            network_id: '3',
            gas: 4712388,
            gasPrice: 20000000000
        },
        kovan: {
            provider: infuraProvider('kovan'),
            network_id: '42',
            gas: 4712388

        },
        rinkeby: {
            provider: infuraProvider('rinkeby'),
            network_id: '4',
            gas: 4712388
        }
    },
    solc: {
        optimizer: {
            enabled: true,
            runs: 200
        }
    },
    mocha: {
        reporter: 'eth-gas-reporter',
        reporterOptions: {
            currency: 'USD',
            gasPrice: 21
        },
        useColors: true
    }
};
