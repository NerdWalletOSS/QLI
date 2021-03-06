local L = require 'linenoise'

return function (evaluator)
  -- L.clearscreen()
  local prompt, history = 'q> ', '_qhist'
  L.historyload(history) -- load existing history
  L.setcompletion(function(c,s)
    if s == 'h' then
      L.addcompletion(c,'help')
      L.addcompletion(c,'halt')
    end
  end)
  local line = L.linenoise(prompt)
  while line do
    if #line > 0 then
      local res = evaluator(line)
      if res and res ~= "nil" then
        print(res)
      end
      L.historyadd(line)
      L.historysave(history) -- save every new line
    end
    line = L.linenoise(prompt)
  end
end
