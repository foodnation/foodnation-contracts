#!/usr/bin/env bash

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
dst="./build/contracts/$2.json"
cd "$parent_path"
if [ -f "$dst" ]
then
    echo "$dst found"
else
    cat ./build/contracts/$1.json | jq --arg inp1 $2 '.contractName = ($inp1 + "") | .networks = {}' > $dst
fi