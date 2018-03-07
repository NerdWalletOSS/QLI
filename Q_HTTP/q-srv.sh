#!/bin/bash
export LUA_PATH="$LUA_PATH;`pwd`/?.lua;`pwd`/?/init.lua;;"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
luajit $SCRIPT_DIR/q_server.lua $1
