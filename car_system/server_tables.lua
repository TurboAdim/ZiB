
-- Машины с выдвижными фарами
hasActiveHeadlights = {
	[410] = true,	-- Toyota AE86
	[562] = true,	-- Nissan Silvia S13
	[439] = true,	-- Dodge Charger R/T 426 HEMI
	[576] = true,	-- Mazda RX-7
}

-- Таблица замены старых записей об апгрейдах новыми
oldUpgradesToNew = {
	-- Колеса
	[1025] = {"wheels", 1}, [1073] = {"wheels", 2}, [1074] = {"wheels", 3}, [1075] = {"wheels", 4}, [1076] = {"wheels", 5},
	[1077] = {"wheels", 6}, [1078] = {"wheels", 7}, [1079] = {"wheels", 8}, [1080] = {"wheels", 9}, [1081] = {"wheels", 10},
	[1082] = {"wheels", 11}, [1083] = {"wheels", 12}, [1084] = {"wheels", 13}, [1085] = {"wheels", 14}, [1096] = {"wheels", 15},
	[1097] = {"wheels", 16}, [1098] = {"wheels", 17},
	-- Спойлеры
	[1000] = {"spoiler", 1}, [1001] = {"spoiler", 2}, [1002] = {"spoiler", 3}, [1003] = {"spoiler", 4}, [1014] = {"spoiler", 5},
	[1015] = {"spoiler", 6}, [1016] = {"spoiler", 7}, [1023] = {"spoiler", 8}, [1049] = {"spoiler", 9}, [1050] = {"spoiler", 10},
	[1058] = {"spoiler", 11}, [1060] = {"spoiler", 12}, [1138] = {"spoiler", 13}, [1139] = {"spoiler", 14}, [1146] = {"spoiler", 15},
	[1147] = {"spoiler", 16}, [1158] = {"spoiler", 17}, [1162] = {"spoiler", 18}, [1163] = {"spoiler", 19}, [1164] = {"spoiler", 20},
}

-- Винилы, устанавливаемые на машины сразу при покупке
stockPaintjobs = {
	[439] = "charger_stock",
	[415] = "lambo_superleggera",
}

-- Список апгрейдов, хранимых в элементдате машины и сохраняемых в базу
upgradeVariants = {"bumper_f","bumper_r","skirts","fenders_f","fenders_r","misc","head_lights","tail_lights","scoop","bonnet","spoiler","trunk",
	"trunk_badge","splitter","diffuser","interior","interiorparts","door_pside_f","door_dside_f","kit","licence_frame",
	"wheels","wheels_r","wheels_f","wheels_razval_f","wheels_razval_r","wheels_offset_f","wheels_offset_r","wheels_radius","wheels_width","wheels_color","wheels_width_f","wheels_width_r", "blik_color", "coverType", "wheels_tire", "wheels_brakes",
	"exhaust", "bonnet_attach"
}

-- Названия валют для отображения
currencyTable = {
	-- PLN = "₽",	-- Есть проблемы с отображением символа на разных системах
	PLN = " руб.",
	USD = "$",
	EUR = "€",
}

-- Территории для автоочистки
colshapes = {
	createColRectangle(-543.761536, 2545.731689, 40, 95), -- Такси
	usedauto = createColRectangle(1692.502441, -1142.171875, 10, 25), -- Б/у салон
	createColCuboid(-2056.71, 151.32, 27.8, 16.5, 31, 5.5 ), -- СТО СФ
	createColCuboid(2920.62, -1104.26, 11.34, 16.5, 31, 5.5 ), -- СТО ЛС пляж
	createColCuboid(2880.15, 2219.5, 10.94, 16.5, 31, 5.5 ), -- СТО ЛВ
	createColCuboid ( 997.5 , -1370.3 , 12.3, 20, 14.5, 5.5 ), -- СТО ЛС город
	createColRectangle(-2096.34375 , -102.916992, 79, 23), -- Автошкола
	createColPolygon(-2006.866211 , 130.698242, -- Спавн
					-2001.251953, 218.192383,
					-1998.124023, 188.451172,
					-1997.329102, 38.445312,
					-2016.833984, 38.438477,
					-2016.651367, 220.443359),
	createColRectangle(1357.5, 663.4, 40, 134.5) -- Старое ЕКХ
}

-- Машины, которые не занимают слоты в гараже
notSlottingCar = {
	[448] = true, -- Pizzaboy
	[457] = true, -- Ока
	[462] = true, -- Мопед
	[403] = true, -- Камаз
	[414] = true, -- Фусо
	[431] = true, -- Икарус
	[437] = true, -- Лиаз
	[515] = true, -- Ивеко
	[525] = true, -- Эвакуатор
	[582] = true, -- Спринтер

	[497] = true, -- Полиц вертолет
	[520] = true  -- Гидра
}
-- Машины, которые должны продаваться за 0 руб
overPricedCar = {
}
-- То, что не должно попадать на б/у рынок
notSoldableCar = {
	[448] = true, -- Pizzaboy
	[462] = true, -- Мопед
	
	[506] = true, -- Bugatti Chiron
	[536] = true, -- Koenigsegg Agera
	[545] = true, -- Bugatti Divo
	[565] = true, -- Regera
	[587] = true, -- McLaren P1
	[503] = true, -- Police E63

	[403] = true, -- Камаз 53215
	[431] = true, -- Volvo Keolis
	[437] = true, -- Mercedes-Benz O345
	[515] = true, -- Scania R620
}


-- Различные таблицы, которые надо разобрать
isHeli = {	-- Костыль, иначе не дает менять номера на машинах из списка notSoldableCar
	[417] = true, -- Ми-26
	[425] = true, -- Heli
	[447] = true, -- Heli
	[469] = true, -- Robinson R22
	[487] = true, -- MBB Bo 105
	[488] = true, -- Heli
	[497] = true, -- Police Helicopter
	[548] = true, -- Heli
	[563] = true, -- Eurocopter EC130
	[520] = true  -- Гидра
}
isBoat = {
	[430] = true, -- 
	[446] = true, -- Wellcraft 38 Scarab KV
	[452] = true, -- 
	[453] = true, -- Reefer
	[454] = true, -- Princess 50
	[472] = true, -- Tropic
	[473] = true, -- Надувная лодка
	[484] = true, -- 
	[493] = true, -- Lampadati Toro
	[595] = true -- Blade
}
isMotorcycle = {
	[448] = true, -- Мото
	[461] = true, -- Мото
	[462] = true, -- Мото
	[463] = true, -- Мото
	[468] = true, -- Мото
	[471] = true, -- Мото
	[521] = true, -- Мото
	[522] = true, -- Мото
	[523] = true, -- Мото
	[581] = true, -- Мото
	[586] = true  -- Мото
}


-- local notSlottingCarsList = "448, 457, 462, 403, 414, 431, 437, 515, 525, 582, 597, 497, 520"
notSlottingCarsList = "a"
local function createNotSlottingCarsList()
	local tempTable = {}
	for index, _ in pairs(notSlottingCar) do
		table.insert(tempTable, index)
	end
	notSlottingCarsList = table.concat(tempTable, ",")
end
createNotSlottingCarsList()