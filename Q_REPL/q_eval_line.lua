local function evaluateLine(line)
  local chunk  = '' .. line
  local f, err = loadstring('return ' .. chunk, 'REPL') -- first we prefix return

  if not f then
    f, err = loadstring(chunk, 'REPL') -- try again without return
  end

  if f then
    local success, results = xpcall(f, debug.traceback)
    return success, results
  end
  return nil
end

return evaluateLine