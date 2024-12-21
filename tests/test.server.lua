local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tester = require(ReplicatedStorage.testlib)


local t = tester:AddTest(
	function() 
		return true 
	end, 
	"True Test1")
tester:AddTest(
	function() 
		return true 
	end, 
	"True Test2"
)
tester:AddTest(
	function() 
		return false 
	end,
	"False Test1")
tester:AddTest(
	function() 
		return false 
	end,
	"False Test2")
tester:AddTest(
	function(): boolean 
		return true
	end,
	"Depend Test",
	{
		t
	}
)

-- Результаты только для тестов этого скрипта
tester:Summary()

-- Вообще для всех тестов
tester.Summary() 
