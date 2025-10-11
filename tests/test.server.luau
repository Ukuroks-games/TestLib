local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tester = require(ReplicatedStorage.shared.testlib)


local t = tester:AddTest(
	tester.test.new(
		"True Test1",
		function() 
			return true 
		end
	)
)

tester:AddTest(
	tester.test.new(
		"True Test2",
		function() 
			return true 
		end
	)
)

tester:AddTest(
	tester.test.new(
		"False Test1",
		function() 
			return false 
		end
	)
)

tester:AddTest(
	tester.test.new(
		"False Test2",
		function() 
			return false 
		end
	)
)

tester:AddTest(
	tester.test.new(
		"Depend Test",
		function(): boolean 
			return true
		end,
		{
			t
		}
	)
)

print("Tests summary:", tester:PostSummary())
