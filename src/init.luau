--!nocheck

local test = require(script.test)
local testlib = require(script.testlib)

testlib.test = test

return testlib :: typeof(testlib) & {test: typeof(test)}
