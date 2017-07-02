local function gatherResults(...)
  local n = select('#', ...)
  return { n = n, ... }
end

return function (results) 
    results = gatherResults(results)
    local res = {}
--    print(results.n)
    for i = 1, results.n do
        -- res[i] = require('luv_utils').dump(results[i], nil, should_colorize)
        res[i] = tostring(results[i])
    end
    return table.concat(res)
end