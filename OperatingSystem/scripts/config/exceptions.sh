#!/bin/bash

# Argument help command
helpCommand(){
  printConsole "Required options for dockerinit.sh"
  echo "-i | string:lowercase | image name"
  echo "-n | string:lowercase | container base name"
  echo "-c | int | container container count"
}

# Type Exception
typeException() {
    helpCommand
    echo "Type Exception : $1"
    exit 1
}

# Argument Exception
argumentException() {
    helpCommand
    echo "Arguments Exception : $1"
    exit 1
}