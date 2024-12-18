local tester = require(game:GetService("ReplicatedStorage").tester)

tester(function() return true end, "True Test1")
tester(function() return true end, "True Test2")
tester(function() return false end, "False Test1")
tester(function() return false end, "False Test2")

-- Результаты только для тестов этого скрипта
tester:Summary()

-- Вообще для всех тестов
tester.Summary() 
