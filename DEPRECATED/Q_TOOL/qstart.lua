-- ensure Q library is installed
-- TODO better err msg needed?
assert(require('Q'))
print 'Welcome Q-ser !!'
local buffer = ''

local function gatherResults(success, ...)
  local n = select('#', ...)
  return success, { n = n, ... }
end

local function printResults(results, should_colorize)
  for i = 1, results.n do
    results[i] = require('luv_utils').dump(results[i], nil, should_colorize)
  end
  --print(table.concat(results, '\t'))
  return table.concat(results, '\t')
end

prompt = "q>"

function evaluateLine(line, should_print)
  if line == "<3\n" then
    print("I " .. c("Bred") .. "♥" .. c() .. " you too!")
    return '>'
  end
  local chunk  = buffer .. line
  local f, err = loadstring('return ' .. chunk, 'REPL') -- first we prefix return

  if not f then
    f, err = loadstring(chunk, 'REPL') -- try again without return
  end

  local outs
  if f then
    buffer = ''
    local success, results = gatherResults(xpcall(f, debug.traceback))
    if success then
      -- successful call
      if results.n > 0 then
        outs = printResults(results, should_print)
      end
    else
      -- error
      -- print(results[1])
      outs = results[1]
    end
  else
    if err:match "'<eof>'$" then
      -- Lua expects some more input; stow it away for next time
      buffer = chunk .. '\n'
      return '>>'
    else
      -- print(err)
      outs = err
      buffer = ''
    end
  end
  if outs and should_print then print (outs) end
  return prompt, outs
end

require 'q_httpserver'
require 'q_repl'
--require 'q_repl_ln'

require('luv').run()
-- We also need to explicitly start the libuv event loop.
