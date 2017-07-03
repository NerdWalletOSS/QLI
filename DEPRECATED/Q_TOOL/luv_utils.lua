-- TAKEN from luv repo, lib/

local uv = require('luv')
local utils = {}
local usecolors

if uv.guess_handle(1) == "tty" then
  utils.stdout = uv.new_tty(1, false)
  usecolors = true
else
  utils.stdout = uv.new_pipe(false)
  uv.pipe_open(utils.stdout, 1)
  usecolors = false
end

local colors = {
  black   = "0;30",
  red     = "0;31",
  green   = "0;32",
  yellow  = "0;33",
  blue    = "0;34",
  magenta = "0;35",
  cyan    = "0;36",
  white   = "0;37",
  B        = "1;",
  Bblack   = "1;30",
  Bred     = "1;31",
  Bgreen   = "1;32",
  Byellow  = "1;33",
  Bblue    = "1;34",
  Bmagenta = "1;35",
  Bcyan    = "1;36",
  Bwhite   = "1;37"
}

function utils.color(color_name)
  if usecolors then
    return "\27[" .. (colors[color_name] or "0") .. "m"
  else
    return ""
  end
end

function utils.colorize(color_name, string, reset_name, should_colorize)
  if should_colorize then
    return utils.color(color_name) .. tostring(string) .. utils.color(reset_name)
  else
    return tostring(string)
  end
end

local backslash, null, newline, carriage, tab, quote, quote2, obracket, cbracket

function utils.loadColors(n)
  if n ~= nil then usecolors = n end
  backslash = utils.colorize("Bgreen", "\\\\", "green", true)
  null      = utils.colorize("Bgreen", "\\0", "green", true)
  newline   = utils.colorize("Bgreen", "\\n", "green", true)
  carriage  = utils.colorize("Bgreen", "\\r", "green", true)
  tab       = utils.colorize("Bgreen", "\\t", "green", true)
  quote     = utils.colorize("Bgreen", '"', "green", true)
  quote2    = utils.colorize("Bgreen", '"', true)
  obracket  = utils.colorize("B", '[', true)
  cbracket  = utils.colorize("B", ']', true)
end

utils.loadColors()

function utils.dump(o, depth, should_colorize)
  local t = type(o)
  if t == 'string' then
    return quote .. o:gsub("\\", backslash):gsub("%z", null):gsub("\n", newline):gsub("\r", carriage):gsub("\t", tab) .. quote2
  end
  if t == 'nil' then
    return utils.colorize("Bblack", "nil", nil, should_colorize)
  end
  if t == 'boolean' then
    return utils.colorize("yellow", tostring(o), nil, should_colorize)
  end
  if t == 'number' then
    return utils.colorize("blue", tostring(o), nil, should_colorize)
  end
  if t == 'userdata' then
    return utils.colorize("magenta", tostring(o), nil, should_colorize)
  end
  if t == 'thread' then
    return utils.colorize("Bred", tostring(o), nil, should_colorize)
  end
  if t == 'function' then
    return utils.colorize("cyan", tostring(o), nil, should_colorize)
  end
  if t == 'cdata' then
    return utils.colorize("Bmagenta", tostring(o), nil, should_colorize)
  end
  if t == 'table' then
    if type(depth) == 'nil' then
      depth = 0
    end
    if depth > 1 then
      return utils.colorize("yellow", tostring(o), nil, should_colorize)
    end
    local indent = ("  "):rep(depth)

    -- Check to see if this is an array
    local is_array = true
    local i = 1
    for k,v in pairs(o) do
      if not (k == i) then
        is_array = false
      end
      i = i + 1
    end

    local first = true
    local lines = {}
    i = 1
    local estimated = 0
    for k,v in (is_array and ipairs or pairs)(o) do
      local s
      if is_array then
        s = ""
      else
        if type(k) == "string" and k:find("^[%a_][%a%d_]*$") then
          s = k .. ' = '
        else
          s = '[' .. utils.dump(k, 100, should_colorize) .. '] = '
        end
      end
      s = s .. utils.dump(v, depth + 1, should_colorize)
      lines[i] = s
      estimated = estimated + #s
      i = i + 1
    end
    if estimated > 200 then
      return "{\n  " .. indent .. table.concat(lines, ",\n  " .. indent) .. "\n" .. indent .. "}"
    else
      return "{ " .. table.concat(lines, ", ") .. " }"
    end
  end
  -- This doesn't happen right?
  return tostring(o)
end



-- Print replacement that goes through libuv.  This is useful on windows
-- to use libuv's code to translate ansi escape codes to windows API calls.
function print(...)
  local n = select('#', ...)
  local arguments = {...}
  for i = 1, n do
    arguments[i] = tostring(arguments[i])
  end
  uv.write(utils.stdout, table.concat(arguments, "\t") .. "\n")
end

-- A nice global data dumper
function utils.prettyPrint(...)
  local n = select('#', ...)
  local arguments = { ... }

  for i = 1, n do
    arguments[i] = utils.dump(arguments[i])
  end

  print(table.concat(arguments, "\t"))
end

return utils

