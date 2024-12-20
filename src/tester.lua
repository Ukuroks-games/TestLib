--	Сервисы



local ReplicatedStorage = game:GetService("ReplicatedStorage")


--	Библиотеки


--[[ 
	Папка с пакетами 
]]
local Packages = ReplicatedStorage.Packages


local stdlib = require(Packages.stdlib)

local algorithm = stdlib.algorithm



local test = require(script.Parent.test)



--[[
	Тестироующая библиотека
]]
local tester = {}

--[[
	папка в которой лежат данные тестов
]]
tester.testsFolder = ReplicatedStorage:FindFirstChild("Tests")

tester.Tests = {}

--[[
	# Вывести результаты тестов

	## Params:

	`Tests` - Список тестов
]]
function tester.PrintTestsResults(Tests: {test.test})

	local function GetPassedTestsNum()
		local num =	algorithm.count_if(
			Tests, 
			function(value: Folder): boolean 
				local a = value:FindFirstChild("TestResult")
				return a.Value
			end
		)
		
		return num
	end

	local passed = GetPassedTestsNum()

	if passed == #Tests then
		print("All test passed\n")
	else
		print("Tests failed:")

		for _, v in pairs(Tests) do
			if v:FindFirstChild("TestResult").Value == false then
				print(v.Name)
			end
		end
	end

	print("Passed:"..tostring(passed).."/"..tostring(#Tests))
end

--[[
	вывести суммарную информацию о тестах
]]
function tester.Summary(self)

	local Tests = {}

	if self then
		Tests = self.Tests
	else
		local all:{Instance} = self.testsFolder:GetChildren()

		for _, v in pairs(all) do
			table.insert(Tests, test.fromFolder(v))
		end
	end

	-- Если хоть один тест ещё запущен, ливаем
	for _, v in pairs(tester.testsFolder:GetChildren()) do
		local running = v:FindFirstChild("TestRunning")
			
		if running then
			if running.Value then
				warn("Not all tests done!")
				return
			else
				table.insert(Tests, v)
			end
		end
	end

	tester.PrintTestsResults(Tests)
end

--[[
	Добавить тест
]]
function tester.AddTest(testFunction: ()->boolean, TestName: string, depends: {test.test}?): test.test
	

	if not tester.testsFolder then
		tester.testsFolder = Instance.new("Folder", ReplicatedStorage)
		tester.testsFolder.Name = "Tests"
	end

	local Test = test.new(tester.testsFolder, TestName, testFunction, depends)

	table.insert(tester.Tests, Test)

	return Test
end

return tester
