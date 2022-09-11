#!/bin/bash

clear

# R&D : xargs
set -e

unset -v containerName


# Get exceptions and console printConvention
source ./print.sh
source ./exceptions.sh

# Parsing arguments, 
unset -v returnState
typeChecker(){
  case $2 in
    int)
      if [[ $1 =~ ^[0-9]+$ ]];
      then
        returnState=0
      else
        returnState=1
      fi
      ;;
    lowerstring)
      if [[ $1 =~ ^([a-z])+([0-9])*$ ]]; 
      then
        returnState=0
      else
        returnState=1
      fi
      ;;
    esac
}

checkRequiredArguments(){
  if [[ -z "${containerName}" ]]
  then
    argumentException "Some arguments not entered"
  else
    typeChecker $containerName lowerstring
    if [[ $returnState == 1 ]]
    then
      argumentException "option -n must be type 'lowercase string'"
    fi
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
      argumentException "Not supported type of argument"
      ;;
  esac
done

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