local test = require(script.test)
local testlib = require(script.testlib)

return setmetatable(testlib, { __index = test })
