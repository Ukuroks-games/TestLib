local ReplicatedStorage = game:GetService("ReplicatedStorage")


--	Библиотеки


--[[ 
	Папка с пакетами 
]]
local Packages = ReplicatedStorage.Packages


local stdlib = require(Packages.stdlib)

local algorithm = stdlib.algorithm


--[[
	Имя папки с тестами
]]
local TestFolderName = "Tests"



local test = require(script.Parent.test)


--[[
	Тестироующая библиотека
]]
local tester = {}


local function createTestsFolder(): Folder
	local testsFolder = Instance.new("Folder", ReplicatedStorage)
	testsFolder.Name = TestFolderName

	return testsFolder
end

--[[
	папка в которой лежат данные тестов
]]
tester.testsFolder = ReplicatedStorage:FindFirstChild(TestFolderName) or createTestsFolder

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
				local a = value:FindFirstChild("Result")
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
			if v:FindFirstChild("Result").Value == false then
				print(v.Name)
			end
		end
	end

	print("Passed:", tostring(passed), "/", #Tests)
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
		local running = v:FindFirstChild("Running")
			
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
function tester.AddTest(self, testFunction: ()->boolean, TestName: string, depends: {test.test}?): test.test
	
	local Test = test.new(self.testsFolder, TestName, testFunction, depends)

	table.insert(self.Tests, Test)

	return Test
end

return tester
