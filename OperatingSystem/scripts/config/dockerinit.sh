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

# Parameter type array after parsing
unset -v ports

# Script Document
scriptDoc="
  -i | string:lowercase | image name
  -n | string:lowercase | container base name
  -c | int | container container count
"

# Step printer
step=1
stepPrint(){
  printStep $step "$1"
  step=$(expr $step + 1)
}

# Check required arguments entered
checkRequiredArguments(){
  if [[ -z "${imageName}" || -z "${containerName}" || -z "${containerCount}" ]]
  then
    argumentException "Some arguments not entered" "${scriptDoc}"
  else
    # Check containerCount variable type as int
    typeChecker $containerCount int "c"

    # Check imageName type as string:lowercase
    typeChecker $containerName lowerstring "n"

    # Check containerName type as string:lowercase
    typeChecker $imageName lowerstring "i"

    # Check port type as int
    for i in  "${ports[@]}"
    do
      typeChecker $i int "p"
    done
  fi
}


stepPrint "Parsing Arguments"
# Parsing arguments, required in order(POSIX method)
while getopts "i:n:c:p:" opt;
do
  case $opt in
    i)
      imageName=${OPTARG}
      ;;
    n) 
      containerName=${OPTARG}
      ;;
    c) 
      containerCount=${OPTARG}
      ;;
    p)
      ports=()
      for i in "${OPTARG}"
      do
        ports+=($i)
      done
      ;;
    *)
      argumentException "Not supported type of argument" "${scriptDoc}"
      ;;
  esac
done

# Check required Arguments including lowercase, typechecking
stepPrint "Checking arguments conditions(type, constraints)"
checkRequiredArguments

stepPrint "Build Container"

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

for i in $(seq $containerCount)
do
  loopName="${containerName}_${i}"
  { 
    docker run -it -d --privileged -p ${ports[$i - 1]}:22 --name ${loopName} ${imageName} /sbin/init
    docker exec ${loopName} bash init/init.sh
    docker exec ${loopName} rm -rf init
  } &> /dev/null
  echo "Progressing...(${i}/${containerCount})"
done

stepPrint "Script End"