#!/bin/bash
export LUA_PATH="$LUA_PATH;$PWD/../Q_REPL/?.lua;;"
luajit q_server.lua $1