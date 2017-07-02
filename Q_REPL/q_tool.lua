--[[
A CLI for Q that can either run standalone or act as remote http-client to a Q-server

Usage: luajit Q/Q_REPL/q_tool.lua [<host> <port>]
]]

print '----- Welcome to Q! ------'

local repl = require 'start_repl'
local eval = require 'q_eval_line'
local res_str = require 'q_res_str'

if (#arg == 0) then
    Q = require 'Q'
    repl (function (line)
        local success, results = eval(line)
        if success then
            return res_str(results)
        else
            return tostring(results[1])
        end
    end)
elseif (#arg == 2) then 
    -- act as http client
    local host = arg[1]
    local port = arg[2]
    local uri = "http://" .. host .. ":" .. port
    print ("Commands will be delegated to Q-server at " .. uri)
    print ("--------------------------")
    local request = require "http.request"
    local req_timeout = 10
    repl (function (line)
        local req = request.new_from_uri(uri)
        req.headers:upsert(":method", "POST")
	    req:set_body(line)
        local headers, stream = req:go(req_timeout)
        if headers == nil then
            io.stderr:write(tostring(stream), "\n")
            os.exit(1)
        end
        local body, err = stream:get_body_as_string()
        if not body and err then
            io.stderr:write(tostring(err), "\n")
            os.exit(1)
        end
        return body   
    end)
else
    print "Usage: luajit Q/Q_REPL/q_tool.lua [<host> <port>]"
end
