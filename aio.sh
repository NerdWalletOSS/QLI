#!/bin/bash

# Install required packages
sudo apt-get install libssl-dev -y
sudo apt-get install m4 -y

# Pre-requisite - luarocks needs to be installed
sudo luarocks install http
sudo luarocks install linenoise
