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

tester.test = test

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
tester.testsFolder = CreateTestsFolder()

--[[
	# Список тестов 
]]
tester.Tests = {}

--[[
	# Вывести результаты тестов

	## Params:

	`Tests` - Список тестов
]]
function tester.PrintTestsResults(Tests: {test.test})

	-- кол-во успешных тестов
	local passed = algorithm.count_if(
		Tests, 
		function(value: Folder): boolean 
			local a = value:FindFirstChild("Result")
			return a.Value
		end
	)

	if passed == #Tests then	-- Все тесты пройдены
		print("All test passed\n")
	else
		print("Failed tests:")

		for _, v in pairs(Tests) do	-- Вывод неудачных тестов
			if v:FindFirstChild("Result").Value == false then
				print("+", v.Name)
			end
		end
	end

	print("Passed:", tostring(passed), "/", #Tests)
end

--[[
	# Вывести суммарную информацию о тестах

	если self == nil, то выводится информация о всех тестах
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
			
		if running then	-- Если оно вообще было найденно
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
	# Добавить тест

	## Params:

	`testFunction` - тестирующая функция

	`TestName` - Имя теста

	`depends` - зависимости теста, необязательно указывать
]]
function tester.AddTest(self, testFunction: ()->boolean, TestName: string, depends: {test.test}?): test.test
	
	local Test = test.new(self.testsFolder, TestName, testFunction, depends)

	table.insert(self.Tests, Test)

	return Test
end

return tester
