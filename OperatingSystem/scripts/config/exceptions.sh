#!/bin/bash

# Argument help command
helpCommand(){
  printConsole "Required options for dockerinit.sh"
  echo "${1}"
}

# Type Exception
typeException() {
    clear
    helpCommand "${2}"
    echo "Type Exception : $1"
    exit 1
}

# Argument Exception
argumentException() {
    clear
    helpCommand "${2}"
    echo "Arguments Exception : $1"
    exit 1
}