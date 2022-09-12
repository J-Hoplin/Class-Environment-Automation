#!/bin/bash

set -e

source ./console.sh
source ./exceptions.sh

baseDoc="
  -i | string:lowercase | image name
  -n | string:lowercase | container base name
  -c | int | container container count
"
unset -v scriptDoc

# Type checking function
# For funciton return state code
unset -v returnState
typeChecker(){
  if [[ -z "${4}" ]]
  then
    scriptDoc=$baseDoc
  else
    scriptDoc="${4}"
  fi
  case $2 in
    int)
      if [[ $1 =~ ^[0-9]+$ ]]; 
      then
        returnState=0
      else
        typeException "option -$3 must be type 'int'" "${scriptDoc}"
      fi 
      ;;
    string)
      # String type doesn't support unicode emoji or text
      if [[ $1 =~ ^([A-Za-z])+([0-9_-])*$ ]];
      then
        returnState=0
      else
        typeException "option -$3 must be type 'string'" "${scriptDoc}"
      fi
      ;;
    lowerstring) 
      # Lower string base : should be at least 1 string and 0 or more int
      if [[ $1 =~ ^([a-z])+([0-9_-])*$ ]]; 
      then
        returnState=0
      else
        typeException "option -$3 must be type 'lower string'" "${scriptDoc}"
      fi
      ;;
    upperstring)
      # Upper string base : should be at least 1 string and 0 or more int
      if [[ $1 =~ ^([A-Z])+([0-9_-])*$ ]];
      then
        returnState=0
      else
        typeException "option -$3 must be type 'upper string'" "${scriptDoc}"
      fi
      ;;
    any | *)
      returnState=0
  esac
}