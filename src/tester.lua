--[[
	Сервисы
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[[
	Тестироующая библиотека
]]
local tester = {}

--[[
	папка в которой лежат данные тестов
]]
tester.testsFolder = ReplicatedStorage:FindFirstChild("Tests")

--[[
	
]]
function tester.EndOfTesting(Tests: {Folder})

	local function GetPassedTestsNum()
		local num = 0
		
		for _, v in pairs(Tests) do
			if v:FindFirstChild("TestResult").Value then
				num += 1
			end
		end
		
		return num
	end

	local passed = GetPassedTestsNum()

	if passed == #Tests then
		print("Tests is OK\n")
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
		for i, v in pairs(self) do
			if typeof(i) == "string" and typeof(v) == "Folder" then
				table.insert(Tests, v)
			end
		end
	else
		Tests = tester.testsFolder:GetChildren()
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

	tester.EndOfTesting(Tests)
end


function tester.__call(testFunction: ()->boolean, TestName: string)

	if not tester.testsFolder then
		tester.testsFolder = Instance.new("Folder", ReplicatedStorage)
		tester.testsFolder.Name = "Tests"
	end

	--[[
		Папка этого текста
	]]
	local testFolder = Instance.new("Folder", tester.testsFolder)
	testFolder.Name = TestName

	tester["TestName"] = testFolder

	--[[
		Результат теста.
		Имеет значение только после того как тест был выполнен
	]]
	local TestResult = Instance.new("BoolValue", testFolder)
	TestResult.Name = "TestResult"

	--[[
		Завершился ли тест
	]]
	local TestRunning = Instance.new("BoolValue", testFolder)
	TestRunning.Name = "TestRunning"

	local TimeStart: number
	local TimeEnd: number

	TestRunning.Changed:Connect(function(newValue: boolean) 
		if newValue then
			print("Test "..tostring(TestName).." started")
		end
	end)

	TestResult.Changed:Connect(function(newValue: boolean) 
		local str = "Test "..TestName.." "

		if newValue then
			str..= "passed"
		else
			str..= "failed"
		end

		str ..= "\nTime: "..tostring(os.difftime(TimeEnd, TimeStart))

		if newValue then
			print(str)
		else
			warn(str)
		end
	end)

	task.spawn(function()

		TestRunning.Value = true
		TimeStart = os.time()
		TestResult.Value = testFunction()
		TimeEnd = os.time()
		TestRunning.Value = false
	end)
end

return tester
