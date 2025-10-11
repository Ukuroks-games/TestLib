--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

--	Библиотеки

local stdlib = require(script.Parent.Parent.stdlib)

local algorithm = stdlib.algorithm

--[[
	Имя папки с тестами
]]
local TestFolderName = "Tests"

local test = require(script.Parent.test)

--[[
	Тестироующая библиотека
]]
local tester = {
	Tests = {},
}

export type TestLib = typeof(tester)

--[[
	# Папка в которой лежат данные тестов
]]
local testsFolder = stdlib.utility.CreateOrFindInstance(
	TestFolderName,
	"Folder",
	ReplicatedStorage
) :: Folder

local function GetTestsList(TestsNames: { string }?): { test.Test }
	local TestTable = {}

	local function insert(v: Instance)
		if v.ClassName == "Folder" then
			table.insert(TestTable, test.fromFolder(v :: Folder))
		end
	end

	for _, v in pairs(testsFolder:GetChildren()) do
		if TestsNames then
			if table.find(TestsNames, v.Name) then
				insert(v)
			end
		else
			insert(v)
		end
	end

	return TestTable
end

function tester.GetTests(self: TestLib?, list: { string }?): { test.Test }
	if self then
		if list then
			return stdlib.algorithm.get_keys_values(self.Tests, list)
		else
			return self.Tests
		end
	else
		return GetTestsList(list)
	end
end

--[[
	print summary
]]
function tester.Summary(self: TestLib?, list: { string }?): string
	local TestTable = (self or tester):GetTests(list)
	local str = ""

	for _, v in pairs(TestTable) do
		str ..= "\n" .. tostring(v)
	end

	str ..= "\nPassed: " .. algorithm.count_if(TestTable, function(value)
		if value.Done.Value then
			return value.Result.Value
		end

		return false
	end) .. "/" .. #TestTable

	return str
end

--[[
	Run summary after all tests done.

	Waiting tests.
]]
function tester.PostSummary(self: TestLib?, list: {string}?): string
	local tests = (self or tester):GetTests(list)

	for _, v in pairs(tests) do
		if not v.Done.Value then -- if test not completed yet
			v.Done.Changed:Wait()
		end
	end

	return tester.Summary(self, list)
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

			Test.Done.Value = true
		end
	end)

	local TestFolder = Instance.new("Folder")
	TestFolder.Parent = testsFolder
	TestFolder.Name = Test.Name

	Test.Running.Parent = TestFolder
	Test.Done.Parent = TestFolder
	Test.Time.Parent = TestFolder
	Test.Result.Parent = TestFolder

	table.insert(self.Tests, Test)

	return Test
end

return tester
