#!/bin/bash

# Generate Project directory
frameworkDirectory="$(dirname $(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd ))/Framework"

scriptDoc="
    @param1 | string | Directory you want to create project
"

# cp -r : copy all including inner directories

if [[ -z "${1}" ]];
then
    echo "${scriptDoc}"
else
    cp -r "${frameworkDirectory}" $1
fi