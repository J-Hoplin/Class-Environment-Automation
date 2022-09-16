#!/bin/bash

clear

# R&D : xargs

unset -v containerName

# Framework Base Directory
frameworkDirectory="$(cd "$(dirname "$(cd "$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)")" &> /dev/null && pwd)")" &> /dev/null && pwd)"
# Container volume mount Directory
volumeBaseDirectory="$(cd "$(dirname "${frameworkDirectory}")" &> /dev/null && pwd)"

# Get exceptions and console printConvention
source ./console.sh
source ./exceptions.sh
source ./typeChecker.sh

# Script Document
scriptDoc="
  -n | string:lowercase | container base name
"

checkRequiredArguments(){
  if [[ -z "${containerName}" ]]
  then
    argumentException "Some arguments not entered" "${scriptDoc}"
  else
    typeChecker $containerName lowerstring "n" "${scriptDoc}"
  fi
}

# Step printer
step=1
stepPrint(){
  printStep $step "$1"
  step=$(expr $step + 1)
}
#################
#Execution Point#
#################
stepPrint "Parsing arguments"
while getopts "n:" opt;
do
  case $opt in
    n)
      containerName=${OPTARG}
      ;;
    *)
      argumentException "Not supported type of argument" "${scriptDoc}"
      ;;
  esac
done

# Check required Arguments including lowercase, typechecking
stepPrint "Checking arguments conditions(type, constraints)"
checkRequiredArguments

stepPrint "Searching matched containers, stop, remove"
for i in $(docker ps -aq --filter="name=${containerName}")
do
  ctName=$i
  echo "Removing container id : ${ctName}"
  {
    docker stop "${ctName}"
    docker rm "${ctName}"
  } &> /dev/null
done

cd ${volumeBaseDirectory}
rm -rf $(ls | grep "${containerName}")

stepPrint "Script End"