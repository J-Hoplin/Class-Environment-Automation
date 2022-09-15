#!/bin/bash

# Installation Script

# Directories
initDirectory=$(pwd)/init/

echo "alias initProject=\"bash ${initDirectory}generateProject.sh\"" >> ~/.bashrc

# Install framework javascript dependencies
cd "$(pwd)/Framework" &> /dev/null && npm install