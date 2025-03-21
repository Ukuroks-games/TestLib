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

export type TestLib = {
	Summary: (self: TestLib?) -> string,

	PostSummary: (self: TestLib?) -> string,

	AddTest: (self: TestLib, Test: test.Test) -> test.Test,

	Tests: { test.Test },

	test: typeof(test)
}

--[[
	Создать или найти папку с тестами
]]
local function CreateTestsFolder(): Folder
	local testsFolder = ReplicatedStorage:FindFirstChild(TestFolderName) or Instance.new("Folder", ReplicatedStorage)
	testsFolder.Name = TestFolderName

	return testsFolder
end

--[[
	# Папка в которой лежат данные тестов
]]
local testsFolder = CreateTestsFolder()

local function GetGlobalsTestsList(): { test.Test }
	local TestTable = {}
	for _, v in pairs(testsFolder:GetChildren()) do
		table.insert(TestTable, test.fromFolder(v))
	end

	return TestTable
end

local function GetTests(self: TestLib?): { test.Test }
	if self then
		return self.Tests
	else
		return GetGlobalsTestsList()
	end
end

--[[
	Тестироующая библиотека
]]
local tester = {
	Tests = {},

	test = test
}

--[[

]]
function tester.Summary(self: TestLib?): string
	
	local TestTable = GetTests(self)
	local str = ""

	for _, v in pairs(TestTable) do
		str ..= "\n" .. tostring(v)
	end

	str ..= "\nPassed: " ..
		algorithm.count_if(
			TestTable, 
			function(value) 
				if value.Done.Value then
					return value.Result.Value
				end

				return false
			end
		) .. '/' .. #TestTable

	return str
end

--[[

]]
function tester.PostSummary(self: TestLib?): string
		
	local tests = GetTests(self)

	for _, v in pairs(tests) do
		if not v.Done.Value then	-- if test not complited yet
			v.Done.Changed:Wait()
		end
	end

	return tester.Summary(self)
end

--[[
	# Добавить тест

	## Params:

	`testFunction` - тестирующая функция

	`TestName` - Имя теста

	`depends` - зависимости теста, необязательно указывать
]]
function tester.AddTest(self: TestLib, Test: test.Test): test.Test

	task.spawn(function()
		local s, e = pcall(function() 
			Test:Run()
		end)

		if not s then
			Test.Result.Value = false
			
			Test.ErrorMsg = e
		end

		Test.Done.Value = true
	end)

	local TestFolder = Instance.new("Folder", testsFolder)
	TestFolder.Name = Test.Name

	Test.Running.Parent = TestFolder
	Test.Done.Parent = TestFolder
	Test.Time.Parent = TestFolder
	Test.Result.Parent = TestFolder

	table.insert(self.Tests, Test)

	return Test
end

return tester
