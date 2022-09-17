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
unset -v containerName
unset -v memoryLimit 

# Parameter type array after parsing
unset -v ports

# Framework Base Directory
frameworkDirectory="$(cd "$(dirname "$(cd "$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)")" &> /dev/null && pwd)")" &> /dev/null && pwd)"
# Container volume mount Directory
volumeBaseDirectory="$(cd "$(dirname "${frameworkDirectory}")" &> /dev/null && pwd)"

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

# Check required arguments entered
checkRequiredArguments(){
  if [[ -z "${imageName}" || -z "${containerName}" || -z "${memoryLimit}" ]];
  then
    argumentException "Some arguments not entered" "${scriptDoc}"
  else

    # Check imageName type as string:lowercase
    typeChecker $containerName lowerstring "n"

    # Check containerName type as string:lowercase
    typeChecker $imageName lowerstring "i"

    # Check memoryLimit type as string
    # Upper than 10
    typeChecker $memoryLimit int "m"
    if [[ $memoryLimit -lt $LEAST_MEMORY ]];
    then
      argumentException "Memory should be at least ${LEAST_MEMORY}mb" "${scriptDoc}"
    fi
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
  -n | string:lowercase | container base name
  -m | int | Memory limit, Unit : mb | default : $BASIC_MEMORY
"

stepPrint "Parsing Arguments"
# Parsing arguments, required in order(POSIX method)
while getopts "i:n:m:" opt;
do
  case $opt in
    #Image name
    i)
      imageName=${OPTARG}
      ;;
    #Container name
    n) 
      containerName=${OPTARG}
      ;;
    #Memory Limitation
    m)
      if [[ -z ${OPTARG} ]];
      then  
        memoryLimit="${BASIC_MEMORY}"
      else
        memoryLimit=${OPTARG}
      fi
      ;;
    *)
      argumentException "Not supported type of argument" "${scriptDoc}"
      ;;
  esac
done

# Check required Arguments including lowercase, typechecking
stepPrint "Checking arguments conditions(type, constraints)"
checkRequiredArguments

dynamicPortsInfo=()
stepPrint "Initiate containers : Owner container"
volumeName="${volumeBaseDirectory}/${containerName}"
mkdir "${volumeName}"
{
    docker run -it -d -m ${memoryLimit}m -p 0:22 -v ${volumeName}:/home/works --privileged --name ${containerName} ${imageName} /sbin/init
    docker exec ${containerName} bash init/init.sh
    docker exec ${containerName} rm -rf init
    dynamicPortsInfo+="$(docker port ${containerName})"
} &> /dev/null

node $(dirname $(pwd))/utils port-owner "${dynamicPortsInfo[@]}"

exit 0