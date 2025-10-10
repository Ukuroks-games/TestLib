local test = {}

local testClass = {}
testClass.__index = testClass

export type TestData = {
	--[[
		Имя теста
	]]
	Name: string,

	--[[
		Зависимости теста
	]]
	Depends: { Test },

	--[[
		Функция теста
	]]
	Func: ()->boolean,
		
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
	Time: NumberValue,

	ErrorMsg: string
}
--[[
	# Тест
]]
export type Test = typeof(
	setmetatable(
		{} :: TestData, 
		testClass
	)
)

function configure(self: TestData): Test

	setmetatable(self, testClass)	-- add methods

	return self
end

--[[
	# Создать тест
]]
function test.new( name: string, func: () -> boolean, depends: { Test }?): Test

	local self = configure(
		{
			Name = name,
			Depends = depends or {},
			Func = func,
			Result = Instance.new("BoolValue"),
			Done = Instance.new("BoolValue"),
			Running = Instance.new("BoolValue"),
			Time = Instance.new("NumberValue"),
			ErrorMsg = nil
		}
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
			print("Test " .. self.Name .. " started")
		end
	end)

	self.Done.Changed:Connect(function() 
		print(self)
	end)

	return self

end

--[[
	# Создать тест из папки

	## Warning:

	создаёт обрезаный тест (без функции и зависимостей)
]]
function test.fromFolder(folder: Folder): Test
	return configure(
		{
			Func = nil,
			Depends = {},
			Name = folder.Name,
			Result = folder:FindFirstChild("Result"),
			Done = folder:FindFirstChild("Running"),
			Time = folder:FindFirstChild("Time"),
			Running = folder:FindFirstChild("Running"),
			ErrorMsg = nil
		}
	)
end

--[[
	# Запустить тест
]]
function testClass.Run(self: Test): boolean

	local function End()
		self.Running.Value = false
		self.Done.Value = true	-- Все! тест кончился
	end

	if self.Running.Value then	-- тест уже запущен
		self.Done.Changed:Wait()	-- ждемс конца
		return self.Result.Value
	end

	if self.Done.Value then	-- тест уже БЫЛ запущен
		return self.Result.Value
	end


	self.Running.Value = true

	for _, v in pairs(self.Depends) do	-- Запуск завивимостей
		if not testClass.Run(v) then
			self.ErrorMsg = "Depends fail"
			End()
			return false
		end
	end


	-- Результат запуска теста
	local result: boolean

	-- Время запуска функции
	local TimeStart: number

	-- время конца функции
	local TimeEnd: number


	TimeStart = os.clock()

	result = self.Func()	-- Запуск функции

	TimeEnd = os.clock()

	self.Time.Value = TimeEnd - TimeStart	-- расчёт времени функции

	self.Result.Value = result

	End()

	return result
end

function testClass.__tostring(self: Test): string
	
	local str = "Test ".. self.Name .. " "
	
	if self.Running.Value then
		str ..= "still running"

	elseif self.Done.Value then

		if self.Result.Value then
			str..= "passed"
		else
			str..= "failed"

			if self.ErrorMsg then
				str ..= "\nError:" .. self.ErrorMsg
			end
		end

		str ..= "\n	Time: " .. tostring(self.Time.Value) .. " sec"

	else
		str ..= "were not run yet"
	end

	return str
end

return setmetatable(test, testClass)
