local test = {}

local testClass = {}
testClass.__index = testClass

--[[
	# Тест
]]
export type test = typeof(setmetatable(
	{} :: {
		--[[
			Имя теста
		]]
		Name: string,

		--[[
			Зависимости теста
		]]
		Depends: {test},

		--[[
			Функция теста
		]]
		TestFunc: ()->boolean,

		--[[
			папка теста
		]]
		testFolder: Folder,
		
		--[[
			Результат теста.
			Имеет значение только после того как тест был выполнен
		]]
		TestResult: BoolValue,

		--[[
			Завершился ли тест
		]]
		TestDone: BoolValue,

		--[[
			Время выполнения теста
		]]
		TestTime: NumberValue
	}, 
	testClass
))

--[[
	# Создать тест
]]
function test.new(Parent: Folder, name: string, func: ()->boolean, depends: {test}?): test

	local testFolder = Instance.new("Folder", Parent)
	testFolder.Name = name

	local self = setmetatable(
		{
			Name = name,
			Depends = depends or {},
			TestFunc = func,
			TestResult = Instance.new("BoolValue", testFolder),
			TestDone = Instance.new("BoolValue", testFolder),
			TestTime = Instance.new("NumberValue", testFolder),
			testFolder = testFolder
		},	testClass
	)

	self.TestResult.Name = "TestResult"
	self.TestDone.Name = "TestDone"
	self.TestTime.Name = "TestTime"

	self.TestResult.Value = false
	self.TestDone.Value = false

	self.TestDone.Changed:Connect(function(newValue: boolean) 
		if newValue then
			print("Test "..tostring(self.Name).." started")
		end
	end)

	self.TestResult.Changed:Connect(function() 
		print(tostring(self))
	end)

	return self
end

--[[
	# Создать тест из папки
]]
function test.fromFolder(folder: Folder): test
	
	local self = setmetatable(
		{
			Name = folder.Name,
			TestResult = folder:FindFirstChild("TestResult"),
			TestDone = folder:FindFirstChild("TestRunning"),
			TestTime = folder:FindFirstChild("TestTime"),
			testFolder = folder
		}, 
		test
	)

	return self
end

--[[
	# Запустить тест
]]
function testClass.RunTest(self: test): boolean

	local result: boolean

	for _, v in pairs(self.Depends) do
		result = testClass.RunTest(v)
		if not result then
			break
		end
	end

	local TimeStart: number
	local TimeEnd: number

	self.TestRunning.Value = true

	TimeStart = os.time()

	result = self.TestFunc()

	TimeEnd = os.time()

	self.TestResult.Value = result
	self.TestTime.Value = os.difftime(TimeEnd, TimeStart)
	self.TestRunning.Value = false

	return result
end

function testClass.__tostring(self: test)
	
	local str: string
	
	if not self.TestDone.Value then
		str = "Test "..self.Name.." "

		if self.TestResult.Value then
			str..= "passed"
		else
			str..= "failed"
		end

		str ..= "\nTime: "..tostring(self.TestTime.Value)
	end

	return str
end

return setmetatable(test, testClass)
