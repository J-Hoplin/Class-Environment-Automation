#!/bin/bash

clear

# '{} &> /dev/null' : output of command will be trashed

# If some command exit with non-zero option, exit script
set -e

# Get exceptions and console printConvention functions
source ./print.sh
source ./exceptions.sh

# Unset required field arguments

unset -v imageName
unset -v containerName
unset -v containerCount

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


# Type checking function
# For funciton return state code
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
    string)
      # String type doesn't support unicode emoji or text
      if [[ $1 =~ ^([A-Za-z])+([0-9])*$ ]];
      then
        returnState=0
      else
        returnState=1
      fi
      ;;
    lowerstring) 
      # Lower string base : should be at least 1 string and 0 or more int
      if [[ $1 =~ ^([a-z])+([0-9])*$ ]]; 
      then
        returnState=0
      else
        returnState=1
      fi
      ;;
    upperstring)
      # Upper string base : should be at least 1 string and 0 or more int
      if [[ $1 =~ ^([A-Z])+([0-9])*$ ]];
      then
        returnState=0
      else
        returnState=1
      fi
      ;;
    any | *)
      returnState=0
  esac
}

# Check required arguments entered
checkRequiredArguments(){
  if [[ -z "${imageName}" || -z "${containerName}" || -z "${containerCount}" ]]
  then
    argumentException "Some arguments not entered" "${scriptDoc}"
  else
    # Check containerCount variable type as int
    typeChecker $containerCount int
    if [[ $returnState == 1 ]]
    then
      argumentException "option -c must be type 'int'" "${scriptDoc}"
    fi

    # Check imageName type as string:lowercase
    typeChecker $containerName lowerstring
    if [[ $returnState == 1 ]]
    then
      argumentException "option -n must be type 'lowercase string'" "${scriptDoc}"
    fi

    # Check containerName type as string:lowercase
    typeChecker $imageName lowerstring
    if [[ $returnState == 1 ]]
    then
      argumentException "option -i must be type 'lowercase string'" "${scriptDoc}"
    fi
  fi
}


stepPrint "Parsing Arguments"
# Parsing arguments, required in order(POSIX method)
while getopts "i:n:c:" opt;
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
  {
    docker build -t ${imageName} $(dirname $(pwd))/Docker
  } &> /dev/null
fi

stepPrint "Initiate containers : Total $containerCount need to be initiate"

for i in $(seq $containerCount)
do
  loopName="${containerName}_${i}"
  { 
    docker run -it -d --privileged --name ${loopName} ${imageName} /sbin/init
    docker exec ${loopName} bash init/init.sh
    docker exec ${loopName} rm -rf init
  } &> /dev/null
  echo "Progressing...(${i}/${containerCount})"
done

stepPrint "Script End"