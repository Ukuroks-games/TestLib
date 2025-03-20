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
	Summary: (self: TestLib?) -> nil,

	--[[
		# Добавить тест

		## Params:

		`testFunction` - тестирующая функция

		`TestName` - Имя теста

		`depends` - зависимости теста, необязательно указывать
	]]
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


--[[
	Тестироующая библиотека
]]
local tester = {
	Summary = function (self: TestLib?)

		local TestTable: {test.Test}

		if self then
			TestTable = self.Tests
		else
			TestTable = {}
			for _, v in pairs(testsFolder:GetChildren()) do
				table.insert(TestTable, test.fromFolder(v))
			end
		end

		for _, v in pairs(TestTable) do
			print(v)
		end

		print(
			"Passed:",
			algorithm.count_if(
				TestTable, 
				function(value) 
					if value.Done.Value then
						return value.Result.Value
					end

					return false
				end
			), 
			'/', 
			#TestTable
		)

	end,

	AddTest = function(self: TestLib, Test: test.Test): test.Test

		local TestFolder = Instance.new("Folder", testsFolder)
		TestFolder.Name = Test.Name

		for _, v in pairs(Test) do
			if	typeof(v) == "NumberValue" or
				typeof(v) == "BoolValue" 
			then
				v.Parent = TestFolder
			end
		end

		table.insert(self.Tests, Test)

		task.spawn(function()
			local s, e = pcall(function() 
				Test:Run()
			end)

			if not s then
				Test.Result.Value = false
				Test.Done.Value = true
				Test.ErrorMsg = e
			end

			

		end)

		return Test
	end,

	Tests = {},

	test = test
}

return tester
