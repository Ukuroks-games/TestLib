# TestsLib

Small library for creating unit tests.

## Why?

I dont understand how use testez.

## Usage Examples

just add this lib in you dev-depends in `wally.toml`:  
```toml
[dev-dependincies]
testlib = "egor00f/testlib@0.1.5"
```

add test:
```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local testlib = require(ReplicatedStorage.DevPackages.testlib)

local t = tester:AddTest(
	tester.test.new(
		"True Test1",
		function(): boolean
			-- Test you function here
			return result --(true is ok)
		end
	)
)

```

add test that depending from other test:
```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local testlib = require(ReplicatedStorage.DevPackages.testlib)

local test = tester:AddTest(
	tester.test.new(
		"True Test1",
		function(): boolean
			-- Test you function here
			return result --(true is ok)
		end
	)
)

local t = tester:AddTest(
	tester.test.new(
		"True Test1",
		function(): boolean
			-- Test you function here
			return result --(true is ok)
		end,
		{
			test
		}
	)
)
```

print summary info:
```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local testlib = require(ReplicatedStorage.DevPackages.testlib)

wait()

testlib.PostSummary() -- wait of end of all tests and show results
```
