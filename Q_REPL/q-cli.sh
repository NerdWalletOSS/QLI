#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
W_DIR=`pwd`
cd $SCRIPT_DIR/../../
export LUA_PATH="$LUA_PATH;`pwd`/?.lua;`pwd`/?/init.lua;;"
cd $W_DIR
luajit $SCRIPT_DIR/q_tool.lua $1 $2

