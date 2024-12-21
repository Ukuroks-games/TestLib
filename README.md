# TestsLib

Small library for creating unit tests.

## Why?

I dont understand how use testez.

## Usage

just add this lib in you dev-depends:  
```
[dev-dependincies]
testlib = "egor00f/testlib@0.1.4"
```

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
