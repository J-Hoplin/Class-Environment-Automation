#!/bin/bash

clear

# R&D : xargs
set -e

unset -v containerName


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
for i in $(docker ps --filter="name=class502" -q)
do
  ctName=$i
  echo "Removing container id : ${ctName}"
  {
    docker stop $i
    docker rm $i
  } &> /dev/null
done

stepPrint "Script End"