#!/usr/bin/env bash
 
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

cd "$parent_path"

truffle compile

/bin/bash ./new_instance.sh GnosisWallet TeamGnosisWallet
/bin/bash ./new_instance.sh GnosisWallet AdvisorsGnosisWallet

/bin/bash ./new_instance.sh GnosisWalletDailyLimit CommunityGnosisDailyLimitWallet
/bin/bash ./new_instance.sh GnosisWalletDailyLimit MarketingGnosisDailyLimitWallet
/bin/bash ./new_instance.sh GnosisWalletDailyLimit ReserveGnosisDailyLimitWallet
/bin/bash ./new_instance.sh GnosisWalletDailyLimit SalesGnosisDailyLimitWallet

/bin/bash ./new_instance.sh VestingToken NikolaVestingToken
/bin/bash ./new_instance.sh VestingToken NeoVestingToken

truffle migrate --reset




