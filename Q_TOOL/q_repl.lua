-- TAKEN from luv repo, examples/
-- edited

local uv = require('luv')
--local utils = require('lib/utils')
local utils = require('luv_utils')

if uv.guess_handle(0) ~= "tty" or
   uv.guess_handle(1) ~= "tty" then
  error "stdio must be a tty"
end
local stdin = uv.new_tty(0, true)
--uv.tty_set_mode(stdin, 1)
local stdout = utils.stdout

local debug = require('debug')
local c = utils.color

local function displayPrompt(prompt)
  uv.write(stdout, prompt .. ' ')
end

local function onread(err, line)
  if err then error(err) end
  if line then
    local prompt = evaluateLine(line, true)
    displayPrompt(prompt)
  else
    uv.close(stdin)
  end
end

coroutine.wrap(function()
  displayPrompt (prompt)
  uv.read_start(stdin, onread)
end)()

-- uv.run()

