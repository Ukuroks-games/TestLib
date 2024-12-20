# TestsLib

Small library for creating unit tests.

see tests/test.server.lua

## Usage

add test:
```
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local testlib = require(ReplicatedStorage.DevPackages.testlib)

testlib:AddTest(
	function (): boolean
		-- do you test
		return testResult --(true is OK)
	end,
	"TestName"
):Run()

```

add test depends:
```
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local testlib = require(ReplicatedStorage.DevPackages.testlib)

local dependTest = testlib:AddTest(
	function (): boolean
		-- do you test
		return testResult --(true is OK)
	end,
	"Depend test"
) -- you can not run this test because it's depend of another test

testlib:AddTest(
	function (): boolean
		-- do you test
		return testResult --(true is OK)
	end,
	"test with dependencies",
	{
		dependTest
	}
):Run()
```
