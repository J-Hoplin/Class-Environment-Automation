#!/bin/bash

clear

# '{} &> /dev/null' : output of command will be trashed

# If some command exit with non-zero option, exit script
set -e

# Get exceptions and console printConvention functions
source ./console.sh
source ./exceptions.sh
source ./typeChecker.sh

# Unset required field arguments

unset -v imageName

# Step printer
step=1
stepPrint(){
  printStep $step "$1" "$(basename $0)"
  step=$(expr $step + 1)
}

# Parse .ENV
envParser(){
  local varLocation=$1

  # Shell can't read last line of file
  # To read last line of file need to 

  while read line; 
  do
    if [[ -z $(echo ${line} | grep "#" ) ]]; then
        eval "${line}"
    fi
  done < ${varLocation}
}

checkRequiredArguments(){
    if [[ -z "${imageName}" ]];
    then
        argumentException "Some arguments not entered" "${scriptDoc}"
    else
        # Check containerName type as string:lowercase
        typeChecker $imageName lowerstring "i"
    fi
}


#################
#Execution Point#
#################

# Get env variables
envParser "$(dirname $(pwd))/config/.env"

# Script Document
scriptDoc="
  -i | string:lowercase | image name
"

stepPrint "Parsing Arguments"
# Parsing arguments, required in order(POSIX method)
while getopts "i:" opt;
do
case $opt in
    #Image name
    i)
      imageName=${OPTARG}
      ;;
    *)
      argumentException "Not supported type of argument" "${scriptDoc}"
      ;;
  esac
done

# Check required Arguments including lowercase, typechecking
stepPrint "Checking arguments conditions(type, constraints)"
checkRequiredArguments

stepPrint "Build container image"

# Check if image with same name exist
imageExist=0
for i in $(docker images | grep os | awk '{print $1}')
do
  if [[ "${i}" == "${imageName}" ]];
  then
    imageExist=1
    break
  fi
done

# Build Image if not exist
if [[ ${imageExist} -eq 0 ]]
then
  stepPrint "Image not detected. Build Image"
  docker build -t ${imageName} $(dirname $(pwd))/Docker
fi

exit 0