-- seeded from code on Luvit blog

-- server.lua
dofile 'luvit-loader.lua' -- Enable require to find lit packages

-- This returns a table that is the app instance.
-- All it's functions return the same table for chaining calls.

-- TODO this is copy-paste but worth it for now...
local function script_path()
   local str = debug.getinfo(2, "S").source:sub(2)
   return str:match("(.*/)")
end

local tmp
local webpath = script_path() .. "/web"

require('weblit-app')

  -- Bind to localhost on port 3000 and listen for connections.
  .bind({
    host = "0.0.0.0",
    port = 8343
  })

  -- Include a few useful middlewares.  Weblit uses a layered approach.
  .use(require('weblit-logger'))
  .use(require('weblit-auto-headers'))
  .use(require('weblit-etag-cache'))
  .use(require('weblit-static')(webpath))
  -- This is a custom route handler
  .route({
    method = "POST", -- Filter on HTTP verb
    path = "/Q", -- Filter on url patterns and capture some parameters.
  }, function (req, res)
    --p(req) -- Log the entire request table for debugging fun
    --print ('REQ' .. req.body)
    --res.body = "Hello " .. req.params.name .. "\n"
    tmp, res.body = evaluateLine(req.body)
    res.code = 200
  end)

  -- Actually start the server
  .start()

--require('luv').run()