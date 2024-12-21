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
		Func: ()->boolean,

		--[[
			папка теста
		]]
		Folder: Folder,
		
		--[[
			Результат теста.
			Имеет значение только после того как тест был выполнен
		]]
		Result: BoolValue,

		--[[
			Завершился ли тест
		]]
		Done: BoolValue,

		--[[
			Запущен ли сейчас тест
		]]
		Running: BoolValue,

		--[[
			Время выполнения теста
		]]
		Time: NumberValue
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
			Func = func,
			Result = Instance.new("BoolValue", testFolder),
			Done = Instance.new("BoolValue", testFolder),
			Running = Instance.new("BoolValue", testFolder),
			Time = Instance.new("NumberValue", testFolder),
			testFolder = testFolder
		},	testClass
	)

	self.Result.Name = "Result"
	self.Done.Name = "Done"
	self.Time.Name = "Time"
	self.Running.Name = "Running"

	self.Result.Value = false
	self.Running.Value = false
	self.Done.Value = false

	self.Running.Changed:Connect(function(newValue: boolean) 
		if newValue then
			print("Test "..tostring(self.Name).." started")
		end
	end)

	self.Result.Changed:Connect(function() 
		print(tostring(self))
	end)

	return self
end

--[[
	# Создать тест из папки

	## Warning:

	создаёт обрезаный тест (без функции и зависимостей)
]]
function test.fromFolder(folder: Folder): test

	local self = setmetatable(
		{
			Name = folder.Name,
			Result = folder:FindFirstChild("Result"),
			Done = folder:FindFirstChild("Running"),
			Time = folder:FindFirstChild("Time"),
			Running = folder:FindFirstChild("Running"),
			testFolder = folder
		}, 
		test
	)

	return self
end

--[[
	# Запустить тест
]]
function testClass.Run(self: test): boolean
	
	if self.Running.Value then	-- тест уже запущен
		self.Result.Changed:Wait()	-- ждемс конца
		return self.Result.Value
	end

	if self.Done.Value then	-- тест уже БЫЛ запущен
		return self.Result.Value
	end

	
	self.Running.Value = true

	for _, v in pairs(self.Depends) do	-- Запуск завивимостей
		if not testClass.Run(v) then
			return false
		end
	end


	-- Результат запуска теста
	local result: boolean

	-- Время запуска функции
	local TimeStart: number

	-- время конца функции
	local TimeEnd: number


	TimeStart = os.time()

	result = self.Func()	-- Запуск функции

	TimeEnd = os.time()

	self.Time.Value = os.difftime(TimeEnd, TimeStart)	-- расчёт времени функции
	self.Result.Value = result
	self.Running.Value = false
	self.Done.Value = true	-- Все! тест кончился

	return result

end

function testClass.__tostring(self: test)
	
	local str: string
	
	if not self.Done.Value then
		str = "Test "..self.Name.." "

		if self.Result.Value then
			str..= "passed"
		else
			str..= "failed"
		end

		str ..= "\nTime: "..tostring(self.Time.Value)
	end

	return str
end

return setmetatable(test, testClass)
