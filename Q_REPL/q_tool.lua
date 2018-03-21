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
  assert(q_src_root and q_data_dir, "Required environment variables are not set\nPlease run \"source $Q_SRC_ROOT/setup.sh -f\"")
  assert(q_src_root and plpath.isdir(q_src_root))
  assert(q_data_dir and plpath.isdir(q_data_dir))
  Q = require 'Q'
  -- Load the saved session if present
  local meta_file = os.getenv('Q_METADATA_FILE')
  if meta_file and plpath.exists(meta_file) then
    Q.restore(meta_file)
  end
  repl (function (line)
    if plstring.strip(line) == "os.exit()" then
      -- Call Q.shutdown()
      -- TODO: capture <ctrl>c and <ctrl>d signals
      Q.shutdown()
    end
    local success, results = eval(line)
    if success then
      return res_str(results)
    else
      if type(results) == "table" then
        return tostring(results[1])
      else
        return tostring(results)
      end
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
