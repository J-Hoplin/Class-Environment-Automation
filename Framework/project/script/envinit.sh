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
unset -v containerCount
unset -v memoryLimit 

# Parameter type array after parsing
unset -v ports

# Script Document
scriptDoc="
  -i | string:lowercase | image name
  -n | string:lowercase | container base name
  -c | int | container container count
  -m | int | Memory limit, Unit : mb | default : 500
"

# Step printer
step=1
stepPrint(){
  printStep $step "$1"
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
  if [[ -z "${imageName}" || -z "${containerName}" || -z "${containerCount}" || -z "${memoryLimit}" ]];
  then
    argumentException "Some arguments not entered" "${scriptDoc}"
  else
    # Check containerCount variable type as int
    typeChecker $containerCount int "c"
    if [[ $containerCount -lt $LEAST_COUNT ]];
    then
      argumentException "Container count must be create more than ${LEAST_COUNT}" "${scriptDoc}"
    fi

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

stepPrint "Parsing Arguments"
# Parsing arguments, required in order(POSIX method)
while getopts "i:n:c:p:m:" opt;
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
    #Container env count
    c) 
      containerCount=${OPTARG}
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

stepPrint "Initiate containers : Total $containerCount need to be initiate"

dynamicPortsInfo=()
for i in $(seq $containerCount)
do
  echo "Progressing...(${i}/${containerCount})"
  loopName="${containerName}_${i}"
  { 
    # Dynamic port allocate
    docker run -it -d -m ${memoryLimit}m -p 0:22 --privileged --name ${loopName} ${imageName} /sbin/init
    docker exec ${loopName} bash init/init.sh
    docker exec ${loopName} rm -rf init
    dynamicPortsInfo+="$(docker port ${loopName})"
  } &> /dev/null
done

node $(dirname $(pwd))/utils port "${containerName}" "${dynamicPortsInfo[@]}"

stepPrint "Script End"
