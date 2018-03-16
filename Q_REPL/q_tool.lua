--[[
A CLI for Q that can either run standalone or act as remote http-client to a Q-server

Usage: luajit Q/Q_REPL/q_tool.lua [<host> <port>]
]]

print '----- Welcome to Q! ------'

local repl	= require 'QLI/Q_REPL/start_repl'
local eval	= require 'QLI/Q_REPL/q_eval_line'
local res_str	= require 'QLI/Q_REPL/q_res_str'
local plpath	= require 'pl.path'
local plstring	= require 'pl.stringx'

if (#arg == 0) then
    local q_src_root = os.getenv("Q_SRC_ROOT")
    local q_data_dir = os.getenv("Q_DATA_DIR")
    local q_metadata_dir = os.getenv("Q_METADATA_DIR")
    assert(q_src_root and q_data_dir, "Required environment variables are not set\nPlease run \"source $Q_SRC_ROOT/setup.sh -f\"")
    assert(q_src_root and plpath.isdir(q_src_root))
    assert(q_data_dir and plpath.isdir(q_data_dir))
    Q = require 'Q'
    local q_consts = require 'Q/UTILS/lua/q_consts'
    local meta_file_path = nil
    if q_metadata_dir then
      assert(plpath.isdir(q_data_dir))
      meta_file_path = q_metadata_dir .. "/" .. q_consts.meta_file_name
      -- Load the saved session if present
      if plpath.exists(meta_file_path) then
        Q.restore(meta_file_path)
      end
    end
    repl (function (line)
        if plstring.strip(line) == "os.exit()" then
          -- Save the state to file meta_file_path
          if meta_file_path then
            Q.save(meta_file_path)
          end
          os.exit()
        end
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
