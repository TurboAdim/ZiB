
-- Кастомные мигалки на машинах
local customSirens = {
	[479] = {	-- BMW M5 F90
		licensepType = "police",
		sirenType = 3, allDirections = true, checkLOS = true, useRandom = false, silent = false,
		{pos = {x = -0.070, y = -0.346, z = 0.737}, color = {r = 255, g = 0, b = 0}, alpha = 255, minAlpha = 0},
		{pos = {x = -0.245, y = -0.346, z = 0.737}, color = {r = 255, g = 0, b = 0}, alpha = 255, minAlpha = 0},
		{pos = {x = -0.485, y = -0.346, z = 0.737}, color = {r = 255, g = 0, b = 0}, alpha = 255, minAlpha = 0},
		{pos = {x =  0.485, y = -0.346, z = 0.737}, color = {r = 0, g = 0, b = 255}, alpha = 255, minAlpha = 0},
		{pos = {x =  0.245, y = -0.346, z = 0.737}, color = {r = 0, g = 0, b = 255}, alpha = 255, minAlpha = 0},
		{pos = {x =  0.070, y = -0.346, z = 0.737}, color = {r = 0, g = 0, b = 255}, alpha = 255, minAlpha = 0},
	},
	noSiren = {
		licensepType = "normal",
		sirenType = 1, allDirections = false, checkLOS = false, useRandom = false, silent = true,
		{pos = {x=0, y=0, z=0}, color = {r=0, g=0, b=0}, alpha=0, minAlpha=0},
	},
}
customSirens[416] = customSirens.noSiren	-- Ambulance
customSirens[490] = customSirens.noSiren	-- Range Rover SVAutobiography
customSirens[596] = customSirens.noSiren	-- Audi A8 D4
customSirens[598] = customSirens.noSiren	-- Mercedes-Benz E63 AMG
customSirens[599] = customSirens.noSiren	-- Toyota Land Cruiser 200

local teleportBlockCoords = {x = -2230, y = 1827, radius = 200}

-- В логах для всех машин указывать: ID, licensep, owner, опционально model, modelName

local vehiclesByID = {}		-- Таблица машин по их ID

--[[function onResourceStart()
	if isResourceRunning("mysql") then
		local continue = prepareTables()
		if (continue) then continue = checkAndUpdateTables()
		end
		if (continue) then checkAndUpdatePaintjobs() end
	else
		outputChatBox("[CAR_SYSTEM][ERROR] mysql is not running!", root, 255,0,0)
		setTimer(onResourceStart, 5000, 1)
	end
end
addEvent ("onResourceStart", false)
addEventHandler ("onResourceStart", resourceRoot, onResourceStart)]]


addEvent("dbCallback", false)
addEventHandler("dbCallback", resourceRoot, function(queryResult, callbackFunctionName, callbackArguments)
	_G[callbackFunctionName](queryResult, callbackArguments)
end)

-- ==========     Отправка списка машин     ==========
function updateVehicleInfo(player)
	player = player or client
	if not isElement(player) then return end
	local accName = getAccountName(getPlayerAccount(player))
	if isResourceRunning("mysql") then
		exports.mysql:dbQueryAsync("updateVehicleInfoCallback", {player=player, accName=accName}, "vehicle", "SELECT ID, model, licensep, userOrder FROM ?? WHERE owner = ?;", accName)
	else
		outputDebugString("[CAR_SYSTEM][WARNING] Cannot updateVehicleInfo - mysql is not active", 2)
	end
end
function updateVehicleInfoCallback(result, args)
	if not isElement(args.player) then return end
	triggerClientEvent(args.player, "refreshCarList", resourceRoot, result, colshapes.usedauto, colshapes.nomerchange)
	if isResourceRunning("house") then
		triggerClientEvent(args.player, "catchParkingLotsCount", resourceRoot, getUsedParkLots(args.accName), exports.house:getPlayerParkingLots(args.accName))
	else
		triggerClientEvent(args.player, "catchParkingLotsCount", resourceRoot, getUsedParkLots(args.accName), 0)
	end
end
addEvent("clientStartsResource", true)
addEventHandler("clientStartsResource", resourceRoot, updateVehicleInfo)

function removeAllMyVehicle()
	for i,v in ipairs (getElementsByType("vehicle")) do
		if getElementData (v, "owner") == getAccountName(getPlayerAccount(client)) then
			if not getElementData(v, "job_taxi.isTaxi") and not getElementData(v, "hasIllegalItems") then
				destroyVehicle(v)
			end
		end
	end
	exports.v_message:add("Usunięto pojazdy.",4, client)
end
addEvent("removeAllMyVehicle", true)
addEventHandler("removeAllMyVehicle", resourceRoot, removeAllMyVehicle)

-- Получение количества занятых парковочных мест
function getUsedParkLots(accName)
	if isResourceRunning("mysql") then
		local result = exports.mysql:dbQuery(-1, "vehicle", "SELECT COUNT(ID) AS count FROM ?? WHERE owner = ? AND model NOT IN ("..notSlottingCarsList..");", accName)
		return ((result and result[1] and result[1].count) or 0)
	else
		outputDebugString("[CAR_SYSTEM][WARNING] Cannot getUsedParkLots - mysql is not active", 2)
		return 0
	end
end

-- ==========     Респавн машины     ==========
function respawnMyVehicleFunc(id)
	local vehicle = vehiclesByID[id]
	if isElement(vehicle) then
		if getElementData(vehicle, "hasIllegalItems") then
			exports.v_message:add("Nie możesz odrodzić tego pojazdu, ponieważ zawiera nielegalne przedmioty",1, client)
			return
		end
		if getElementData(vehicle, "job_taxi.isTaxi") then
			exports.v_message:add("Tego pojazdu nie można odrodzić, ponieważ pełni on funkcję taksówki",1, client)
			return
		end
		destroyVehicle(vehicle)
	end
	spawnVehicle(id, client, true, false)
end
addEvent("respawnMyVehicle", true)
addEventHandler("respawnMyVehicle", resourceRoot, respawnMyVehicleFunc)

-- ==========     Спавн машины     ==========
function checkVeh (pl)
local count = 0
local acc = getAccountName (getPlayerAccount (pl))
for i, v in ipairs (getElementsByType ("vehicle")) do
	if getElementData (v, "owner") == acc then
		count = count + 1
	end
end
return count
end

function spawnVehicle(id, player, showMessage, warpInto)
	if isElement(vehiclesByID[id]) then return end
	if isResourceRunning("mysql") then
		if checkVeh (player) + 1 > 3 then exports.v_message:add ("Nie możesz stworzyć więcej niż 3 samochody.",1, player) return end
		local secondTableName = exports.mysql:getTableName("handling")
		local callbackArguments = {player=player, showMessage=showMessage, requestedID=id, warpInto=warpInto}
		-- "vehicle", "SELECT * FROM ?? AS veh, ?? AS han WHERE veh.ID = ? AND han.ID = ?;", secondTableName, id, id
		exports.mysql:dbQueryAsync("spawnVehicleCallback", callbackArguments, "vehicle", "SELECT * FROM ?? AS veh LEFT JOIN ?? AS han ON (veh.ID = han.ID) WHERE veh.ID = ?;", secondTableName, id)
	else
		exports.v_message:add("Nie można utworzyć samochodu – błąd systemu. Proszę zgłosić to administratorowi.",2, player)
		outputDebugString("[CAR_SYSTEM][WARNING] Cannot spawn car - mysql is not active", 2)
	end
end
function spawnVehicleCallback(result, args)
	if not isElement(args.player) then return end
	if (not result) or (#result < 1) then
		exports.v_message:add("Wystąpił problem z pojazdem o ID "..tostring(args.requestedID)..", Proszę zgłosić to administratorowi.",2, args.player)
		outputDebugString("[CAR_SYSTEM][WARNING] Cannot spawn car - problem with id "..tostring(args.requestedID), 2)
		return
	end
	if (getElementInterior(args.player) ~= 0) then return end
	local dimension = getElementDimension(args.player)
	if (dimension > 10) then return end
	
	result = result[1]
	result.ID = tonumber(result.ID) or tonumber(args.requestedID)
	result.model = tonumber(result.model)
	
	if isElement(vehiclesByID[result.ID]) then return end
	
	if (getAccountName(getPlayerAccount(args.player)) ~= result.owner) then
		outputDebugString(string.format("[CAR_SYSTEM] Cannot spawn car - wrong owner. %s found, %s expected. Car: %s, lic %s, model %s",
			tostring(getAccountName(getPlayerAccount(args.player))), tostring(result.owner), tostring(result.ID), tostring(result.licensep), tostring(result.model)
		), 1)
		return
	end
	
	if (result.flag == "police") then
		if not isResourceRunning("police_ccd") or not exports.police_ccd:isActivePoliceman(args.player) then
			exports.v_message:add("Nie możesz uruchomić tego samochodu, dopóki nie rozpoczniesz zmiany z policją.",1, args.player)
			return
		end
	end
	
	local vehicle = createVehicle(result.model, result.x, result.y, result.z, 0, 0, result.rotZ) or exports.newmodels:makeVehicle(result.model, result.x, result.y, result.z, 0, 0, result.rotZ)
	setElementData(vehicle, "ID", result.ID)
	setElementData(vehicle, "owner", result.owner)
	setElementData(vehicle, "fuel", result.fuel)
	setElementData(vehicle, "fuelOctane", result.fuelOctane)
	setElementData(vehicle, "odometer", result.odometer)
	setElementData(vehicle, "licensep", result.licensep)
	
	local color = split(result.colors, ',')
	local r1 = color[1] or 255
	local g1 = color[2] or 255
	local b1 = color[3] or 255
	local r2 = color[4] or 255
	local g2 = color[5] or 255
	local b2 = color[6] or 255
	setVehicleColor(vehicle, r1, g1, b1, r2, g2, b2)
	
	local health = tonumber(result.HP) or 1000
	if health <= 255.5 then health = 255 end
	setElementHealth(vehicle, health)
	
	if (result.model ~= 462) and (result.handling) and (result.handling ~= "") then
		for property, value in pairs(fromJSON(result.handling)) do
			if (property ~= "suspensionUpperLimit") then
				setVehicleHandling(vehicle, property, value)
			end
		end
	end
	
	local paintjob = result.paintjob
	if (paintjob ~= "3") and (paintjob ~= 3) and (paintjob ~= "") then
		setElementData(vehicle, "paintjob", paintjob)
	end
	
	local customTuning = fromJSON(result.customTuning)
	if (customTuning) then
		local toner = customTuning.toner
		local xenon = customTuning.xenon
		local sgu = customTuning.sgu
		local wheels_brakes = customTuning.wheels_brakes
	    local wheels_tire = customTuning.wheels_tire
        
        if (wheels_brakes) then
        	setElementData(vehicle, "wheels_brakes", wheels_brakes)
        end
        if (wheels_tire) then
        	setElementData(vehicle, "wheels_tire", wheels_tire)
        end
	    
		if (toner) then
			setElementData(vehicle, "tint_front", toner[1])
			setElementData(vehicle, "tint_side", toner[2])
			setElementData(vehicle, "tint_rear", toner[3])
			setElementData(vehicle, "tint_pered", toner[4])
			setElementData(vehicle, "tint_zad", toner[5])
		end
		if (xenon) then
			xenon[1] = tonumber(xenon[1]) or 255
			xenon[2] = tonumber(xenon[2]) or 255
			xenon[3] = tonumber(xenon[3]) or 255
			setVehicleHeadLightColor(vehicle, xenon[1], xenon[2], xenon[3])
			setElementData(vehicle, "xenon", xenon[1]..","..xenon[2]..","..xenon[3])
		else
			setVehicleHeadLightColor(vehicle, 255, 255, 255)
			setElementData(vehicle, "xenon", "255,255,255")
		end
		if (sgu) then
			local pos = fromJSON(sgu.pos)
			setElementData(vehicle, "sgu_config", tonumber(sgu.state))
			if pos[1] and pos[2] and pos[3] and pos[4] then
				setElementData(vehicle, "sgu", sgu.pos)
				--exports.sgu:createSGUVehicle (vehicle, pos[2], pos[3], pos[4], pos[5] or 0, pos[6] or 0, pos[7] or 180)
			end
		end
	end
	
	if (hasActiveHeadlights[result.model]) then
		setVehicleOverrideLights(vehicle, 1)
	end	
	
	vehiclesByID[result.ID] = vehicle
	
	local upgrades = split(tostring(result.upgrades), ';')
	for _, upgrade in ipairs(upgrades) do
		local upgrParts = split(upgrade, ',')
		if not tonumber(upgrParts[1]) then
			setElementData(vehicle, upgrParts[1], (tonumber(upgrParts[2]) or upgrParts[2]))
		else
			local detal = oldUpgradesToNew[ tonumber(upgrParts[1]) ]
			if (detal) then
				setElementData(vehicle, detal[1], tonumber(detal[2]))
			end
		end
	end
	
	if isResourceRunning("car_benzin") then
		exports.car_benzin:setOctaneDependentParameters(vehicle)
	end
	
	setElementDimension(vehicle, dimension)
	
	local vehType = getVehicleType(result.model)
	if (vehType == "Automobile") or (vehType == "Boat") then
		setElementData(vehicle, "hasInventory", true)
	end

	triggerClientEvent("forceUpdateVehicleComponents", vehicle)
	
	if (customSirens[result.model]) then
		local sirensData = customSirens[result.model]
		if licensepMatch(result.licensep, sirensData.licensepType) then
			removeVehicleSirens(vehicle)
			addVehicleSirens(vehicle, #sirensData, sirensData.sirenType, sirensData.allDirections, sirensData.checkLOS, sirensData.useRandom, sirensData.silent)
			for siren, data in ipairs(sirensData) do
				setVehicleSirens(vehicle, siren, data.pos.x,data.pos.y,data.pos.z, data.color.r,data.color.g,data.color.b, data.alpha, data.minAlpha)
			end
		end
	end
	
	if (args.showMessage) then
		exports.v_message:add("Twój pojazd jest schowany.",2, args.player)
	end
	
	if (args.warpInto) then
		setTimer(warpPedIntoVehicle, 50, 1, args.player, vehicle, 0)
	end
end

function licensepMatch(licensep, licType)
	if (licType == "normal") then
		return (tostring(licensep):sub(1, 1) ~= "b")
	elseif (licType == "police") then
		return (tostring(licensep):sub(1, 1) == "b")
	else
		outputDebugString("[CAR_SYSTEM] Unknown licType on licensepMatch. licensep: "..inspect(licensep)..", licType: "..inspect(licType))
	end
end

-- ==========     Убрать машину     ==========
function removeMyVehicle(id)
	local vehicle = vehiclesByID[id]
	if isElement(vehicle) then
		if getElementData(vehicle, "job_taxi.isTaxi") then
			exports.v_message:add("Nie możesz usunąć tego pojazdu, ponieważ jest on używany jako taksówka.",1, client)
			return
		elseif getElementData(vehicle, "hasIllegalItems") then
			exports.v_message:add("Nie możesz usunąć tego pojazdu, ponieważ zawiera nielegalne przedmioty.",1, client)
			return
		end
		destroyVehicle(vehicle)
		exports.v_message:add("Schowałeś pojazd.",2, client)
	else
		--outputCarSystemInfo("Ваш транспорт #FF0000не заспавнен", client)
	end
end
addEvent("removeMyVehicle", true)
addEventHandler("removeMyVehicle", resourceRoot, removeMyVehicle)

function _getElementModel(element)
	if getElementType(element) == 'vehicle' then
		return getElementData(element, exports.newmodels:getDataNameFromType("vehicle")) or getElementModel(element)
	else
		return getElementModel(element)
	end
end

-- ==========     Убирание машины     ==========
function destroyVehicle(theVehicle)
	if isElement(theVehicle) then
		saveCarData(theVehicle)
		for _, element in ipairs( getAttachedElements(theVehicle) ) do
			if isElement(element) and (getElementType(element) == "blip") then
				destroyElement(element)
			end
		end
		local id = getElementData(theVehicle, "ID")
		vehiclesByID[id] = nil
		destroyElement(theVehicle)
	end
end

-- ==========     Сохранение данных машины     ==========
function saveCarData(vehicle)
	if not isElement(vehicle) then return end
	if not getElementData(vehicle, "owner") then return end
	
	if isResourceRunning("mysql") then
		local x, y, z = getElementPosition(vehicle)
		local _, _, rz = getElementRotation(vehicle)
		local r1, g1, b1, r2, g2, b2 = getVehicleColor(vehicle, true)
		local color = table.concat({r1, g1, b1, r2, g2, b2}, ",")
		local paintjob = getElementData(vehicle, "paintjob") or ""
		local id = getElementData(vehicle, "ID")
		local fuel = getElementData(vehicle, "fuel")
		local fuelOctane = getElementData(vehicle, "fuelOctane")
		local odometer = getElementData(vehicle, "odometer")
		local HP = getElementHealth(vehicle)

		local tintFront = getElementData(vehicle, "tint_front") or false
		local tintSide = getElementData(vehicle, "tint_side") or false
		local tintRear = getElementData(vehicle, "tint_rear") or false
		local tintPered = getElementData(vehicle, "tint_pered") or false
		local tintZad = getElementData(vehicle, "tint_zad") or false
		local xenonData = getElementData(vehicle, "xenon")
		local xenon = xenonData and split(xenonData, ",") or {255, 255, 255}
		--local customTuning = toJSON({toner = {tintFront, tintSide, tintRear}, xenon = xenon}, true)
		local wheels_brakes = getElementData(vehicle, "wheels_brakes") or -1
		local wheels_tire = getElementData(vehicle, "wheels_tire") or -1

		local posSGU = getElementData(vehicle, "sgu") or toJSON({false, false, false, false, false, false}) -- Положение сгу 
		local buyedSGU = getElementData (vehicle, "sgu_config") or 0
		
		local customTuning = toJSON({toner = {tintFront, tintSide, tintRear, tintFare}, 
									xenon = xenon, 
									smokecolor = smokecolor,
									wheels_tire = wheels_tire,
									wheels_brakes = wheels_brakes,
									sgu = {
										state = tostring(buyedSGU), 
										pos = posSGU
										},
									}, true)
		
		local upgrades = {}
		for _, upgrade in pairs(upgradeVariants) do
			local installed = getElementData(vehicle, upgrade)
			if (installed) and (installed ~= 0) then
				table.insert(upgrades, upgrade..","..tostring(installed))
			end
		end
		upgrades = table.concat(upgrades, ";")
		
		exports.mysql:dbExec("vehicle", [[UPDATE ?? SET x=?, y=?, z=?, rotZ=?, colors = ?, upgrades = ?,
			paintjob = ?, HP = ?, fuel=?, customTuning = ?, fuelOctane = ?, odometer = ? WHERE ID = ?;]],
			x, y, z, rz, color, upgrades, paintjob, HP, fuel, customTuning, fuelOctane, odometer, id)
		
		if (_getElementModel(vehicle) ~= 462) then
			local handling = toJSON(getVehicleHandling(vehicle), true)
			exports.mysql:dbExec("handling", "UPDATE ?? SET handling = ? WHERE ID = ?;", handling, id)
		end
	else
		outputDebugString("[CAR_SYSTEM][WARNING] Cannot save car data - mysql is not active", 2)
	end
end
-- Исправление проебанных записей о хэндлинге
-- INSERT INTO car_system_handling (ID, handling) SELECT ID, "" AS handling FROM car_system_vehicle AS t1 WHERE model != 462 AND NOT EXISTS (SELECT ID FROM car_system_handling WHERE ID = t1.id);

-- Сохранение машины при выходе водителя
function saveVehicleOnExitFromIt(_, seat, _) 
	if isElement(source) then
		if getElementType(source) == "vehicle" then
			if getElementData(source, "ID") and (seat == 0) then
				saveCarData(source)
			end
		end
	end
end
addEventHandler("onVehicleExit", root, saveVehicleOnExitFromIt)

function buyVehicleForPlayer(player, model, r1, g1, b1, r2, g2, b2, shopID, region)
	client = player
	return buyNewVehicle(model, r1, g1, b1, r2, g2, b2, shopID, region)
end

-- ==========     Покупка машины из салона     ==========
function buyNewVehicle(model, r1, g1, b1, r2, g2, b2, shopID, region)
	region = tonumber(region)
	
	local cost, currency = getCarPrice(model)
	if isResourceRunning("bank") then
		if exports.bank:getPlayerBankMoney(client, currency) < cost then
			exports.v_message:add("Nie masz wystarczających środków na koncie bankowym.",1, client)
			return false
		end
	else
		if (getPlayerMoney(client) < cost) or (currency) then
			exports.v_message:add("Nie masz wystarczających środków.",1, client)
			return false
		end
	end
	
	local accName = getAccountName(getPlayerAccount(client))
	if (not notSlottingCar[model]) and isResourceRunning("house") then
		local availableParkingLots = exports.house:getPlayerParkingLots(accName)
		local usedParkingLots = getUsedParkLots(accName)
		if (usedParkingLots > availableParkingLots) then
			exports.v_message:add("Nie możesz kupić więcej samochodów. Nie masz wystarczającej liczby miejsc parkingowych: "..(availableParkingLots+1)..".",1, player)
			exports.v_message:add("W tej chwili masz "..usedParkingLots.." miejsc.",1, player)
			return false
		end
	end

	if not isResourceRunning("mysql") then
		exports.v_message:add("Nie można kupić samochodu - błąd systemu. Proszę zgłosić to administratorowi.",2, client)
		outputDebugString("[CAR_SYSTEM][WARNING] Cannot buy car - mysql is not active", 2)
		return false
	end
	
	if (getThisModelCarsCount(accName, model) > 10) then
		exports.v_message:add("Masz już za dużo identycznych pojazdów.",1, client)
		return false
	end

	local newID = getFreeID() or 1
	if (not newID) then
		outputDebugString("[CAR-SYSTEM] Cannot getFreeID(): result="..tostring(newID), 1)
		return false
	end
	local color = table.concat({r1, g1, b1, r2, g2, b2}, ",")
	local fuel = math.random(90, 99)
	local paintjob = stockPaintjobs[model] or ""
	
	local vehicleType = getVehicleType(model)
	local licensePlate = generateNumberplate("boat", region)
	if (vehicleType == "Bike") or (vehicleType == "Quad") or (vehicleType == "BMX") then
		licensePlate = generateNumberplate("c", region)
	elseif (vehicleType == "Boat") then
		licensePlate = generateNumberplate("boat")
	elseif (vehicleType == "Helicopter") then
		licensePlate = generateNumberplate("helicopter")
	end
	-- Остаются Automobile: Cars, vans and trucks, Plane, Train, Trailer: A trailer for a truck, Monster Truck
	local shop = shopTable[shopID] or {}

	exports.mysql:dbExec("vehicle", [[INSERT INTO ?? (ID, owner, model, x, y, z, rotZ, colors, upgrades, paintjob, HP, fuel, licensep, customTuning, fuelOctane, odometer, userOrder)
		VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);]],
		newID, accName, model, shop.spwnPosX, shop.spwnPosY, shop.spwnPosZ, shop.spwnRotZ, color, "", paintjob, 1000.0, fuel, licensePlate, toJSON({toner = {false, false, false}}, true), "92.0", math.random(0, 12), getNextUserOrderValue(accName)
	)
	if (model ~= 462) then
		exports.mysql:dbExec("handling", "REPLACE INTO ?? (ID, handling) VALUES(?, ?);", newID, "")
	end
	
	local moneyText = ""
	if isResourceRunning("bank") then
		exports.bank:takePlayerBankMoney(client, cost, currency)
		exports.v_message:add("Kupiłeś "..getVehicleModName(model).." za "..explodeNumber(cost)..currencyToSymbol(currency),4, client)
		moneyText = string.format("bank %i%s", exports.bank:getPlayerBankMoney(client, currency), (currency or "RUB"))
	else
		takePlayerMoney(client, cost)
		exports.v_message:add("Kupiłeś "..getVehicleModName(model).." za "..cost.." $.",4, client)
		moneyText = "money "..getPlayerMoney(client)
	end
	
	outputDebugString(string.format("[CAR-SHOP][BUY] %s (acc %s, %s) bought %s (%i, %s, %i) for %i", getPlayerName(client), accName,moneyText, getVehicleModName(model), newID,licensePlate,tostring(model), tostring(cost)))

	spawnVehicle(newID, client, false, true)
	updateVehicleInfo(client)
	
	return true
end
addEvent("onBuyNewVehicle", true)
addEventHandler("onBuyNewVehicle", resourceRoot, buyNewVehicle)

function getNextUserOrderValue(owner)
	local order = exports.mysql:dbQuery(-1, "vehicle", "SELECT MAX(userOrder)+1 AS `order` FROM ?? WHERE owner=?", owner)
	return order and order[1] and order[1].order or 1
end

-- Получение количества машин данной модели
function getThisModelCarsCount(accName, model)
	local count = exports.mysql:dbQuery(-1, "vehicle", "SELECT COUNT(ID) AS count FROM ?? WHERE owner = ? AND model = ?", accName, model)
	return count and count[1] and count[1].count or 0
end

-- Получение свободного ID машины
function getFreeID()
	local result = exports.mysql:dbQuery(-1, "vehicle", "SELECT t1.ID+1 AS result FROM ?? AS t1 LEFT JOIN ?? AS t2 ON t1.ID+1 = t2.ID WHERE t2.ID IS NULL ORDER BY t1.ID LIMIT 1;", exports.mysql:getTableName("vehicle"))
	return (result and result[1] and result[1].result)
end

-- Генерация номера по заданному шаблону
function generateNumberplate(plateType, selectedRegion)
	local licCh = {"a", "b", "e", "k", "m", "h", "o", "p", "c", "t", "y", "x"}
	local licReg = {50,150,750, 77,177,777, 90,190,790, 97,197,797, 99,199,799}
	local newPlate
	if (not plateType) or (plateType == "a") then
		repeat
			local region = selectedRegion or licReg[math.random(#licReg)]
			if (region < 100) then
				newPlate = string.format("a-%s%i%i%i%s%s%02i", licCh[math.random(#licCh)], math.random(0,9), math.random(0,9), math.random(0,9), licCh[math.random(#licCh)], licCh[math.random(#licCh)], region)
			else
				newPlate = string.format("a-%s%i%i%i%s%s%03i", licCh[math.random(#licCh)], math.random(0,9), math.random(0,9), math.random(0,9), licCh[math.random(#licCh)], licCh[math.random(#licCh)], region)
			end
		until (not nomerIs000(newPlate)) and (not checkNomerExistance(newPlate)) and (not nomerIsPHA(newPlate)) -- Истина - выход из цикла
		return newPlate
		
	elseif (plateType == "b") then
		return string.format("b-%s%i%i%i%i%02i", licCh[math.random(#licCh)], math.random(0,9), math.random(0,9), math.random(0,9), math.random(0,9), string.sub(licReg[math.random(#licReg)], -2, -1))
		
	elseif (plateType == "c") then
		repeat
			local region = string.sub( (selectedRegion or licReg[math.random(#licReg)]), -2, -1)
			newPlate = string.format("c-%i%i%i%i%s%s%02i", math.random(0,9), math.random(0,9), math.random(0,9), math.random(0,9), licCh[math.random(#licCh)], licCh[math.random(#licCh)], region)
		until (not nomerIs0000(newPlate)) and (not checkNomerExistance(newPlate)) -- Истина - выход из цикла
		return newPlate
		
	elseif (plateType == "i") then
		return "i-"..licCh[math.random(#licCh)]..licCh[math.random(#licCh)]..math.random(0,9)..math.random(0,9)..math.random(0,9)..string.sub(licReg[math.random(#licReg)], -2, -1)
		
	elseif (plateType == "boat") then
		return "h-ZMIENNY23"
		
	elseif (plateType == "special") then
		return "m-ZMIENNY23"
		
	elseif (plateType == "helicopter") then
		return "h-Helicopter"
		
	end
end
function nomerIs000(plate)
	return (tonumber( string.sub(plate, 4, 6) ) == 0)
end
function nomerIs0000(plate)
	return (tonumber( string.sub(plate, 3, 6) ) == 0)
end
function nomerIsPHA(plate)
	return (string.sub(plate, 3, 3) == "p") and (string.sub(plate, 7, 7) == "h") and (string.sub(plate, 7, 7) == "m") and (string.sub(plate, 8, 8) == "a")
end

-- Проверка на наличие номера
function checkNomerExistance(nomer)
	local data = exports.mysql:dbQuery(-1, "vehicle", "SELECT licensep, owner, model FROM ?? WHERE licensep = ?;", nomer) or {}
	
	if isResourceRunning("car_usedauto") then
		local _, dataFrom = exports.car_usedauto:checkNomerExistance(nomer)
		for _, row in ipairs(dataFrom) do
			row.usedauto = true
			table.insert(data, row)
		end
	end
	if isResourceRunning("car_nomerchange") then
		local _, dataFrom = exports.car_nomerchange:checkNomerExistance(nomer)
		for _, row in ipairs(dataFrom) do
			table.insert(data, row)
		end
	end
	
	return (#data > 0), data
end

-- ==========     Покупка машины с б/у рынка     ==========
function BuyVehicleByUsed(player, data, position)
	local accName = getAccountName(getPlayerAccount(player))

	if isResourceRunning("bank") then
		if (exports.bank:getPlayerBankMoney(player, "RUB") < data.price) then
			exports.v_message:add("Nie masz wystarczających środków na swoim koncie bankowym w PLN.",1, player)
			return false
		end
	else
		if (getPlayerMoney(player) < data.price) then
			exports.v_message:add("Nie masz wystarczających środków.",1, player)
			return false
		end
	end
	
	if not isResourceRunning("mysql") then
		exports.v_message:add("Nie można kupić samochodu - błąd systemu. Proszę zgłosić to administratorowi.",2, client)
		outputDebugString("[CAR_SYSTEM][WARNING] Cannot buy used car - mysql is not active", 2)
		return
	end
	
	if (getThisModelCarsCount(accName, data.model) > 10) then
		exports.v_message:add("Masz już za dużo identycznych pojazdów.",2, player)
		return false
	end
	
	if (not notSlottingCar[data.model]) and isResourceRunning("house") then
		local availableParkingLots = exports.house:getPlayerParkingLots(accName)
		local usedParkingLots = getUsedParkLots(accName)
		if (usedParkingLots > availableParkingLots) then
			exports.v_message:add("Вы не можете купить больше "..(availableParkingLots+1).." машин. У вас недостаточно парковочных мест.",1, player)
			exports.v_message:add("В данный момент у вас "..usedParkingLots.." машин.",1, player)
			return false
		end
	end
	
	local newID = getFreeID()
	if (not newID) then
		outputDebugString("[CAR-SYSTEM] Cannot getFreeID(): result="..tostring(newID), 1)
		return false
	end
	data.fuelOctane = tonumber(data.fuelOctane) or 92.0
	
	exports.mysql:dbExec("vehicle", [[INSERT INTO ?? (ID, owner, model, x, y, z, rotZ, colors, upgrades, paintjob, HP, fuel, licensep, customTuning, fuelOctane, odometer, userOrder)
		VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);]],
		newID, accName, data.model, position.x, position.y, position.z, position.rotZ, data.colors, data.upgrades, data.paintjob, 1000, math.random(10, 25), data.licensep, data.customTuning, data.fuelOctane, data.odometer, getNextUserOrderValue(accName)
	)
	exports.mysql:dbExec("handling", "REPLACE INTO ?? (ID, handling) VALUES(?, ?);", newID, data.handling)
	
	local moneyText = ""
	if isResourceRunning("bank") then
		exports.bank:takePlayerBankMoney(player, data.price, "RUB")
		exports.v_message:add("Вы купили "..getVehicleModName(data.model).." за "..explodeNumber(data.price).." руб.",4, player)
		moneyText = "bank "..exports.bank:getPlayerBankMoney(player, "RUB").."RUB"
	else
		takePlayerMoney(player, data.price)
		exports.v_message:add("Вы купили "..getVehicleModName(data.model).." за "..data.price.." руб.",4, player)
		moneyText = "money "..getPlayerMoney(player)
	end
	
	outputDebugString(string.format("[CAR-SHOP][BUY_USED] %s (acc %s, %s) bought %s (%i, %s, %i) for %i from used carshop",
		getPlayerName(player), accName,moneyText, getVehicleModName(data.model), newID,data.licensep,data.model, data.price))

	spawnVehicle(newID, player, false, true)
	setElementInterior(player, 0)
	setElementDimension(player, 0)

	updateVehicleInfo(player)
	return true	
end

-- ==========     Продажа машины на б/у рынок     ==========
function sellVehicle(id, money)
	if isResourceRunning("mysql") then
		local secondTableName = exports.mysql:getTableName("handling")
		local callbackArguments = {
			player = client,
			id = id,
			money = math.floor(money),
			vehicle = getVehicleByID(id)
		}
		if isElement(callbackArguments.vehicle) then
			saveCarData(vehicle)
		end
		exports.mysql:dbQueryAsync("sellVehicleCallback", callbackArguments, "vehicle", "SELECT * FROM ?? AS veh LEFT JOIN ?? AS han ON (veh.ID = han.ID) WHERE veh.ID = ?;", secondTableName, id)
	else
		outputCarSystemError("Невозможно продать машину - системная ошибка. Proszę zgłosić to administratorowi.", client)
		outputDebugString("[CAR_SYSTEM][WARNING] Cannot sell car - mysql is not active", 2)
	end
end
local vehicleIsSold = {}
function sellVehicleCallback(result, args)
	if not isElement(args.player) then return end
	if (not result) or (#result < 1) then
		exports.v_message:add("Возникла проблема с транспортом id "..tostring(args.id)..", Proszę zgłosić to administratorowi.",2, args.player)
		outputDebugString("[CAR_SYSTEM][WARNING] Cannot sell car - problem with id "..tostring(args.id), 2)
		return
	end
	
	result = result[1]
--if not checkCarInColshape(args.vehicle, result, args.player) then return end
	
	result.model = tonumber(result.model)
	local accName = getAccountName(getPlayerAccount(args.player))
	if (result.owner ~= accName) then
		exports.v_message:add("Возникла проблема с продажей транспорта id "..tostring(args.id)..", Proszę zgłosić to administratorowi.",2, args.player)
		outputDebugString(string.format("[CAR_SYSTEM][ERROR] Cannot sell car - owner does not match: %s (acc %s money %s) car %s (%i, %s, %i, owner %s) price %i",
			getPlayerName(args.player), accName,getPlayerMoney(args.player), getVehicleModName(result.model), tostring(args.id),result.licensep,result.model,result.owner, tostring(args.money)), 1)
		return
	end
	
	if (vehicleIsSold[args.id]) then
		outputDebugString(string.format("[CAR_SYSTEM][ERROR] Cannot sell car - it is already sold: %s (acc %s money %s) car %s (%i, %s, %i, owner %s) price %i",
			getPlayerName(args.player), accName,getPlayerMoney(args.player), getVehicleModName(result.model), tostring(args.id),result.licensep,result.model,result.owner, tostring(args.money)), 1)
		return
	end
	
	if (result.flag) then
		exports.v_message:add("Nie możesz sprzedać tego samochodu.",1, args.player)
		return
	end
	
	local _, _, minPrice, maxPrice = getAllSellingPrices(result.model)
	if (not minPrice) then
		exports.v_message:add("Nie można sprzedać pojazdu. Operacje bankowe niedostępne.",1, args.player)
		return
	end
	if (args.money < minPrice) then
		exports.v_message:add("Nie możesz ustalić niższej ceny niż "..minPrice.." $.",1)
		return
	end
	if (args.money > maxPrice) then
		exports.v_message:add("Nie możesz ustalić wyższej ceny niż "..maxPrice.." $.",1)
		return
	end
	if overPricedCar[result.model] then
		args.money = 0
	end

	if isElement(args.vehicle) then destroyVehicle(args.vehicle) end
	if (not notSoldableCar[result.model]) and (not overPricedCar[result.model]) and (not isBoat[result.model]) and (not isHeli[result.model]) and isResourceRunning("car_usedauto") then
		if (args.money >= 0) then
		-- ORG if (args.money*1.2 >= 100) then
			result.handling = result.handling or ""
			exports.car_usedauto:addCarToUsedShop(result, math.floor(args.money*1.2), args.player)
		else
			outputCarSystemWarning("Uwaga! W komisie samochodowym nie ma samochodów na sprzedaż za mniej niż $100", args.player)
		end
	end	

	exports.mysql:dbExec("vehicle", "DELETE FROM ?? WHERE ID = ?", args.id)
	exports.mysql:dbExec("handling", "DELETE FROM ?? WHERE ID = ?", args.id)

	exports.bank:givePlayerBankMoney(args.player, args.money, "RUB")
	exports.v_message:add("Sprzedałeś swój pojazd za "..explodeNumber(args.money).." $.",4, args.player)
	
	outputDebugString(string.format("[CAR-SHOP][SELL] %s (acc %s bank %s) sold %s (%i, %s, %i) for %i",
		getPlayerName(args.player), accName,exports.bank:getPlayerBankMoney(args.player, "RUB"), getVehicleModName(result.model), (result.ID or args.id),result.licensep,result.model, args.money))

	updateVehicleInfo(args.player)
	
	vehicleIsSold[args.id] = true
	setTimer(removeVehicleFromSold, 60000, 1, args.id)
end
addEvent("SellMyVehicle", true)
addEventHandler("SellMyVehicle", resourceRoot, sellVehicle)

function removeVehicleFromSold(id)
	vehicleIsSold[id] = nil
end

function getVehicleByID(id)
	return vehiclesByID[ tonumber(id) ]
end

--[[function checkCarInColshape(vehicle, carData, player)
	if not isElementWithinColShape(player, colshapes.usedauto) then
		outputCarSystemError("Невозможно продать автомобиль. Вы должны находиться на б/у рынке.", player)
		return false
	end
	if isElement(vehicle) then
		if not isElementWithinColShape(vehicle, colshapes.usedauto) then
			outputCarSystemError("Невозможно продать автомобиль. Его нужно пригнать на б/у рынок.", player)
			return false
		end
	else
		local colX, colY = getElementPosition(colshapes.usedauto)
		if (getDistanceBetweenPoints2D(colX, colY, carData.x, carData.y) > 75) then
			outputCarSystemError("Невозможно продать автомобиль. Его нужно пригнать на б/у рынок.", player)
			return false
		end
	end
	return true
end]]

-- ==========     Установка блипа на машину     ==========
function blipMyVehicle(id)
	local vehicle = vehiclesByID[id]
	if not isElement(vehicle) then
		exports.v_message:add("Twój pojazd jest schowany",1, client)
		return
	end
	if not getElementData(vehicle, "ABlip") then
		setElementData(vehicle, "ABlip", true)
		createBlipAttachedTo(vehicle, 41, 2, 255, 0, 0, 255, 0, 65535, client)
		exports.v_message:add("Twój transport jest zaznaczony na mapie. Użyj F11, aby go znaleźć.",2, client)
	else
		local attached = getAttachedElements(vehicle)
		if (attached) then
			for k,element in ipairs(attached) do
				if getElementType(element) == "blip" then
					destroyElement(element)
				end
			end
		end
		setElementData(vehicle, "ABlip", false)
		exports.v_message:add("Oznaczenie zostało usunięte z Twojego pojazdu.",2, client)
	end
end
addEvent("BlipMyVehicle", true)
addEventHandler("BlipMyVehicle", resourceRoot, blipMyVehicle)

-- ==========     Фриз машины     ==========
function freezeMyVehicle(id, houseData)
	local vehicle = vehiclesByID[id]
	if not isElement(vehicle) then
		exports.v_message:add("Twój pojazd jest schowany",1, client)
		return
	end
	if isElementFrozen ( vehicle ) then
		setElementFrozen ( vehicle, false )
		setVehicleDamageProof(vehicle, false)
		setVehicleEngineState ( vehicle, true )
		exports.v_message:add("Twój pojazd może się poruszać.",4, client)
	else
		-- if getAccountData(getPlayerAccount(client), "car-system.cannotFreezeCar") then
			-- outputCarSystemError("Ты не можешь блокировать свой автомобиль!", client)
			-- return
		-- end
		local carX,carY,carZ = getElementPosition(vehicle)
		local sx, sy, sz = getElementVelocity(vehicle)
		local speed = math.floor(((sx^2 + sy^2 + sz^2)^(0.5))*180)
		if speed > 5 then
			exports.v_message:add("Zatrzymaj samochód przed zablokowaniem.",1, client)
		elseif (getDistanceToNearestHouse(houseData, carX,carY,carZ) > 50) then
			exports.v_message:add("Możesz zablokować samochód tylko w pobliżu swojego domu.",1, client)
		-- elseif (_getElementModel(vehicle) == 462) then
			-- outputCarSystemInfo("Мопед блокировать нельзя.", client)
		else
			setElementFrozen ( vehicle, true )
			setVehicleDamageProof(vehicle, true)
			setVehicleEngineState ( vehicle, false )
			exports.v_message:add("Twój pojazd jest zablokowany.",4, client)
		end
	end
end
addEvent("FreezeMyVehicle", true)
addEventHandler("FreezeMyVehicle", resourceRoot, freezeMyVehicle)

function getDistanceToNearestHouse(houseData, x,y,z)
	local minimalDist = 300
	for _, house in ipairs(houseData) do
		local dist = getDistanceBetweenPoints3D(house.x, house.y, house.z, x,y,z)
		if (not minimalDist) or (dist < minimalDist) then
			minimalDist = dist
		end
	end
	return minimalDist
end

-- ==========     Закрытие дверей машины     ==========
addEvent("LockMyVehicle", true)
addEventHandler("LockMyVehicle", resourceRoot, function(id)
	local vehicle = vehiclesByID[id]
	if not isElement(vehicle) then
		exports.v_message:add("Twój pojazd jest schowany",1, client)
		return
	end
	local x,y,z = getElementPosition(client)
	local carX,carY,carZ = getElementPosition(vehicle)
	if (getDistanceBetweenPoints3D(x,y,z, carX,carY,carZ) > 100) then
		exports.v_message:add("Twój samochód jest za daleko.",1, client)
		return
	end
	local wasLocked = isVehicleLocked(vehicle)
	if not wasLocked then
		setVehicleLocked(vehicle, true)
		setVehicleDoorsUndamageable(vehicle, true)
		setVehicleDoorState(vehicle, 0, 0)
		setVehicleDoorState(vehicle, 1, 0)
		setVehicleDoorState(vehicle, 2, 0)
		setVehicleDoorState(vehicle, 3, 0) 
		exports.v_message:add("Twój pojazd jest zamknięty.",4, client)
	else
		setVehicleLocked(vehicle, false)
		setVehicleDoorsUndamageable(vehicle, false)
		exports.v_message:add("Twój pojazd jest otwarty.",4, client)
	end
	if isResourceRunning("car_movparts") then
		exports.car_movparts:setVehicleMovpartsState(client, vehicle, wasLocked)
	end
end)

-- ==========     Сброс хандлинга     ==========
function resetVehicleHandling(id)
	local vehicle = vehiclesByID[id]
	local destroy, vehModel = false
	if isElement(vehicle) then
		if getElementData(vehicle, "job_taxi.isTaxi") then
			exports.v_message:add("Tego pojazdu nie można odrodzić, ponieważ pełni on funkcję taksówki.",1, client)
			return
		end
		vehModel = _getElementModel(vehicle)
		destroyVehicle(vehicle)
		destroy = true
	end
	if not isResourceRunning("mysql") then
		exports.v_message:add("Nie można zresetować handlingu — błąd systemu. Proszę zgłosić to administratorowi.",2, client)
		outputDebugString("[CAR_SYSTEM][WARNING] Cannot reset handling - mysql is not active", 2)
		return
	end
	exports.mysql:dbExec("handling", "UPDATE ?? SET handling = ? WHERE ID = ?;", "", id)
	if destroy then
		exports.v_message:add("Zresetowałeś handling: "..getVehicleModName(vehModel)..".",4, client)
		spawnVehicle(id, client, false, false)
	else
		exports.v_message:add("Pomyślnie zresetowałeś handling na tym komputerze.",4, client)
	end
end
addEvent("ResetVehicleHandling", true)
addEventHandler("ResetVehicleHandling", resourceRoot, resetVehicleHandling)

-- ==========     Телепорт машины     ==========
function warpMyVehicle(id)
	if isPedInVehicle(client) then
		exports.v_message:add("Nie możemy przyjąć Twojego pojazdu. Proszę wysiąść z drugiego pojazdu.",1, client)
		return
	end		
	if (getElementInterior(client) ~= 0) then
		exports.v_message:add("Nie można wjechać samochodem do budynku.",1, client)
		return
	end
	local vehicle = vehiclesByID[id]
	if isElement(vehicle) then
		if getElementData(vehicle, "hasIllegalItems") then
			exports.v_message:add("Nie możesz teleportować tego pojazdu, ponieważ zawiera nielegalne przedmioty.",1, client)
			return
		end
		for _, player in pairs(getVehicleOccupants(vehicle)) do
			if getElementData(player, "isChased") then
				exports.v_message:add("Nie możesz teleportować tego pojazdu, ponieważ ścigany jest w nim inny gracz.",1, client)
				return
			end
		end
		local x, y, z = getElementPosition(client)
		if (getDistanceBetweenPoints2D(x,y, teleportBlockCoords.x, teleportBlockCoords.y) < teleportBlockCoords.radius) then
			exports.v_message:add("Nie można dostarczyć pojazdu do strzeżonego obszaru.",1, client)
			return
		end
		if getElementData(vehicle, "job_taxi.isTaxi") then
			local carX, carY, carZ = getElementPosition(vehicle)
			if getDistanceBetweenPoints3D(x, y, z, carX, carY, carZ) > 50 then
				exports.v_message:add("Nie możesz teleportować tego pojazdu, ponieważ pełni on funkcję taksówki i znajduje się zbyt daleko.",1, client)
				return
			end
		end
		local _,_,rotz = getElementRotation ( client, "ZYX" )
		setElementFrozen ( vehicle, false )
		setVehicleDamageProof(vehicle, false)
		setElementRotation ( vehicle, 0, 0, rotz+90, "ZYX")
		local dist = 3.5
		rotz = math.rad(rotz+90)
		x = x+3.5*math.cos(rotz)
		y = y+3.5*math.sin(rotz)
		setElementPosition(vehicle, x, y, z+1.0)
		exports.v_message:add("Zespawnowano pojazd.",4, client)
	else
		exports.v_message:add("Twój pojazd jest schowany",1, client)
	end
end
addEvent("WarpMyVehicle", true)
addEventHandler("WarpMyVehicle", resourceRoot, warpMyVehicle)

-- ==========     Убирание машин при выходе игрока, при стопе ресурса     ==========
function onPlayerQuit()
	if isResourceRunning("mysql") then
		exports.mysql:dbQueryAsync("onPlayerQuitCallback", {}, "vehicle", "SELECT ID FROM ?? WHERE owner = ?", getAccountName(getPlayerAccount(source)))
	else
		outputDebugString("[CAR_SYSTEM][WARNING] Cannot get list of cars to destroy - mysql is not active", 2)
	end
end
function onPlayerQuitCallback(result, args)
	for _, row in ipairs(result) do
		destroyVehicle(vehiclesByID[row.ID])
	end
end
addEventHandler("onPlayerQuit", root, onPlayerQuit)

function saveAllVehicles() 
	for i, veh in ipairs(getElementsByType("vehicle")) do
		if getElementData(veh, "ID") then
			saveCarData(veh)
		end
	end
end
addEventHandler("onResourceStop", resourceRoot, saveAllVehicles)

-- ==========     Смена номера через внешний ресурс     ==========
function changeNomer(ID, newNomer, player)
	if isResourceRunning("mysql") then
		exports.mysql:dbExec("vehicle", "UPDATE ?? SET licensep = ? WHERE ID = ?", newNomer, ID)
		if player then
			updateVehicleInfo(player)
		end
	else
		outputDebugString("[CAR_SYSTEM][WARNING] Cannot changeNomer() - mysql is not active", 2)
		return false
	end
end










function removeExplodedVeh()
	if isElement(source) then
		if getElementData(source, "doNotRemoveThisCarOnTimeout") then
			setTimer(respawnVehicle, 5000, 1, source)
		else
			setTimer(checkRemove, 60000, 1, source)
		end
	end
end
addEventHandler("onVehicleExplode", root, removeExplodedVeh)
function checkRemove(veh)
	if isElement(veh) and isVehicleBlown(veh) then
		destroyElement(veh)
	end
end

function onVehicleEnter()
	if getElementHealth(source) <= 255 then 
		setVehicleEngineState(source, false)
	else
		if isVehicleDamageProof(source) then
			setVehicleDamageProof(source, false)
		end
	end
end
addEventHandler("onVehicleEnter", resourceRoot, onVehicleEnter)






function checkCarAbilityToSellToPlayer(vehicle, carData, player)
	if (not vehicle) then vehicle = vehiclesByID[ carData[1].ID ] end
	if not isElementWithinColShape(player, colshapes.nomerchange) then
		exports.v_message:add("Nie można sprzedać samochodu. Musisz być w centrum ponownej rejestracji.",1, player)
		return false
	end
	if isElement(vehicle) then
		if not isElementWithinColShape(vehicle, colshapes.nomerchange) then
			exports.v_message:add("Nie można sprzedać samochodu. Należy go odstawić do punktu ponownej rejestracji.",1, player)
			return false
		end
	else
		local colX, colY = 1378.286133, 727.662109
		if (getDistanceBetweenPoints2D(colX, colY, carData[1].X, carData[1].Y) > 75) then
			exports.v_message:add("Nie można sprzedać samochodu. Należy go odstawić do punktu ponownej rejestracji.",1, player)
			return false
		end
	end
	return true
end


--	==========     Контроль за машинами, чтобы они не взрывались     ==========
local lowHPcars = {}
setTimer(function()
	for vehicle, _ in pairs(lowHPcars) do
		if isElement(vehicle) then
			if (getElementHealth(vehicle) > 256) then
				setVehicleDamageProof(vehicle, false)
				lowHPcars[vehicle] = nil
			else
				local rotX = getElementRotation(vehicle)
				if (rotX < 90) or (rotX > 270) then
					setVehicleDamageProof(vehicle, false)
					lowHPcars[vehicle] = nil
				end
			end
		else
			lowHPcars[vehicle] = nil
		end
	end
	for _, vehicle in ipairs(getElementsByType("vehicle", resourceRoot)) do
		if (getElementHealth(vehicle) < 256) then
			setElementHealth(vehicle, 256)
			setVehicleDamageProof(vehicle, true)
			setVehicleEngineState(vehicle, false)
			lowHPcars[vehicle] = true
			for _, occupant in pairs(getVehicleOccupants(vehicle)) do
				if getElementData(occupant, "isChased") or getElementData(occupant, "isChasing") then
					setElementData(vehicle, "isBroken", true)
				end
			end
		end
	end
end, 1000, 0)


function clrparking()
	local clrCars, pzdCars = 0, 0
	local clrTime = getTickCount()
	for _, colShape in pairs(colshapes) do
		local vehTable = getElementsWithinColShape(colShape, "vehicle")
		for _, veh in ipairs(vehTable) do
			if (not getVehicleOccupant(veh)) and getElementData(veh, "ID") then 
				destroyVehicle(veh)
				clrCars = clrCars + 1
			end
		end
	end
	local pzdTime = getTickCount()
	clrTime = pzdTime - clrTime
	for i, veh in ipairs (getElementsByType("vehicle", resourceRoot)) do
		local model = _getElementModel(veh)
		if ((model == 445) or (model == 462)) and (not getVehicleOccupant(veh)) and (not getElementData(veh, "doNotRemoveThisCarOnTimeout")) then
			destroyVehicle(veh)
			pzdCars = pzdCars + 1
		end
	end
	local garbTime = getTickCount()
	pzdTime = garbTime - pzdTime
	local garbage = collectgarbage("count")
	collectgarbage()
	garbage = math.floor(garbage - collectgarbage("count"))
	garbTime = getTickCount() - garbTime
	outputDebugString("[CARSYSTEM] Clearparking "..clrCars.." cars "..clrTime.." ms, pizdahuy "..pzdCars.." cars "..pzdTime.." ms, collectgarbage "..garbage.."KB "..garbTime.." ms")
end
setTimer(clrparking, 600000, 0)

function setNomer(player,_,nomer)
	if (not nomer) or (nomer=="") then
		exports.v_message:add("CMD: '/setnomer <nomer>'",2, player)
		return
	end
	local vehicle = getPedOccupiedVehicle(player)
	if not vehicle then
		exports.v_message:add("Musisz usiąść w samochodzie, dla którego robisz numer!",1, player)
		return
	end
	local id = getElementData(vehicle, "ID")	
	if not id then
		exports.v_message:add("Musisz usiąść w swoim prywatnym samochodzie!",1, player)
		return
	end
	setElementData(vehicle, "licensep", nomer)
	local owner = getElementData(vehicle, "owner")
	if isResourceRunning("mysql") then
		local data = exports.mysql:dbQuery(-1, "vehicle", "SELECT ID FROM ?? WHERE ID = ?", id)
		if type(data) == "table" and #data ~= 0 then
			exports.mysql:dbExec("vehicle", "UPDATE ?? SET licensep = ? WHERE ID = ?", nomer, id)
			outputDebugString("[CAR-SYSTEM][MANUALNOMERCHANGE] "..getPlayerName(player).." changed nomer to "..nomer.." on "..getVehicleModName(vehicle).." (".._getElementModel(vehicle)..", owner "..owner..")")
		end
		updateVehicleInfo(getAccountPlayer(getAccount(owner)))
	else
		outputDebugString("[CAR_SYSTEM][WARNING] Cannot setnomer - mysql is not active", 2)
	end
end
addCommandHandler("setnomer", setNomer, true, false)

function setRamka(player, _, ramka)
	if (not ramka) or (ramka=="") then
		exports.v_message:add("CMD: '/setramka <ramka>'",2, player)
		return
	end
	local vehicle = getPedOccupiedVehicle(player)
	if not vehicle then
		exports.v_message:add("Musisz usiąść w samochodzie, w którym zamierzasz zamontować ramkę!",1, player)
		return
	end
	local id = getElementData(vehicle, "ID")	
	if not id then
		exports.v_message:add("Musisz usiąść w swoim prywatnym samochodzie!",1, player)
		return
	end
	setElementData(vehicle, "licence_frame", ramka)
	local owner = getElementData(vehicle, "owner")
	outputDebugString("[CAR-SYSTEM][CHANGE_RAMKA] "..getPlayerName(player).." changed ramka to "..ramka.." on "..getVehicleModName(vehicle).." (".._getElementModel(vehicle)..", owner "..tostring(owner)..")")
	triggerClientEvent("forceUpdateVehicleComponents", vehicle)
end
addCommandHandler("setramka", setRamka, true, false)




function getDataOnLogin()
	updateVehicleInfo(source)	
end
addEventHandler("onPlayerLogin", root, getDataOnLogin)


--	==========     Функции для полиции     ==========
-- Добавляет полиц. машину игроку в F3
function addPoliceCar(player, model)
	if not isElement(player) then return end
	local accName = getAccountName(getPlayerAccount(player))
	exports.mysql:dbQueryAsync("addPoliceCarCallback", {player=player, accName=accName, model=model}, "vehicle", "SELECT `ID` FROM ?? WHERE `owner` = ? AND `model` = ? AND `flag` = 'police';", accName, model)
end
function addPoliceCarCallback(result, args)
	if isElement(args.player) and (result) and (#result == 0) then
		local newID = getFreeID()
		local licensep = generateNumberplate("b")
		exports.mysql:dbExec("vehicle", [[INSERT INTO ?? (ID, owner, model, x, y, z, rotZ, colors, upgrades, paintjob, HP, fuel, licensep, customTuning, fuelOctane, odometer, userOrder, flag)
			VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);]],
			newID, args.accName, args.model, 5000.0,5000.0,0.0,0.0, "255,255,255,255,255,255", "interiorparts,1", "f90_police", 1000, 80,
			licensep, toJSON({toner = {false, false, false}}, true), 98.0, math.random(15000), getNextUserOrderValue(args.accName), "police"
		)
		exports.mysql:dbExec("handling", "REPLACE INTO ?? (ID, handling) VALUES(?, ?);", newID, "")
		updateVehicleInfo(args.player)
	end
end

-- Убирает полицейские машины по окончанию смены
function destroyPoliceCar(accName)
	exports.mysql:dbQueryAsync("destroyPoliceCarCallback", {}, "vehicle", "SELECT `ID` FROM ?? WHERE `flag` = 'police' AND `owner` = ?;", accName)
end
function destroyPoliceCarCallback(result, args)
	for _, row in ipairs(result) do
		local vehicle = vehiclesByID[row.ID]
		if isElement(vehicle) then
			destroyVehicle(vehicle)
		end
	end
end

-- Удаляет полицейские машины
function removePoliceCar(player, accName)
	exports.mysql:dbQueryAsync("removePoliceCarCallback", {player=player, accName=accName}, "vehicle", "SELECT `ID`, `model`, `licensep` FROM ?? WHERE `flag` = 'police' AND `owner` = ?;", accName)
end
function removePoliceCarCallback(result, args)
	if (result) and (#result > 0) then
		local tbl = {}
		for _, row in ipairs(result) do
			table.insert(tbl, row.ID)
			local vehicle = vehiclesByID[row.ID]
			if isElement(vehicle) then
				destroyVehicle(vehicle)
			end
		end
		exports.mysql:dbExec("vehicle", "DELETE FROM ?? WHERE `ID` IN ("..table.concat(tbl, ",")..");")
		exports.mysql:dbExec("handling", "DELETE FROM ?? WHERE `ID` IN ("..table.concat(tbl, ",")..");")
		if isElement(args.player) then
			updateVehicleInfo(args.player)
		end
		outputDebugString(string.format("[CARSYSTEM] Removed %i police cars for account %s. Car data: %s",
			#result, args.accName, toJSON(result, true)
		))
	end
end

-- Отдает список игроков, имеющих полицейские машины
function getPoliceCarOwners()
	exports.mysql:dbQueryAsync("getPoliceCarOwnersCallback", {}, "vehicle", "SELECT DISTINCT `owner` FROM ?? WHERE `flag` = 'police';")
end
function getPoliceCarOwnersCallback(result, args)
	local tbl = {}
	for _, row in ipairs(result) do
		table.insert(tbl, row.owner)
	end
	exports.police_ccd:catchPoliceCarOwners(tbl)
end


--	==========     Информационные сообщения     ==========
function outputCarSystemInfo(text, player)
	outputChatBox("#4080bf[Garaż] #f2f2f2"..text:gsub("#цв#", "#f2f2f2"), player, 38, 122, 216, true)
end
function outputCarSystemWarning(text, player)
	outputChatBox("#ffcc00[Garaż] #f2f2f2"..text:gsub("#цв#", "#f2f2f2"), player, 38, 122, 216, true)
end
function outputCarSystemError(text, player)
	outputChatBox("#ff3333[Garaż] #f2f2f2"..text:gsub("#цв#", "#f2f2f2"), player, 38, 122, 216, true)
end

--	==========     Оставлено для совместимости     ==========
function policeRemoveCar(vehicle)
	outputDebugString(string.format("[CAR_SYSTEM] %s using obsolete function policeRemoveCar(vehicle). Use destroyVehicle(vehicle) instead.", tostring(getResourceName(sourceResource))), 2)
	destroyVehicle(vehicle)
end

--	==========     Получение значка валюты из таблицы     ==========
function currencyToSymbol(currency)
	currency = currency or "RUB"
	return currencyTable[currency] or ""
end

-- ==========     Разбивка числа на части     ==========
function explodeNumber(number)
    number = tostring(number)
    local k
    repeat
        number, k = string.gsub(number, "^(-?%d+)(%d%d%d)", '%1 %2')
    until (k==0)    -- true - выход из цикла
    return number
end

--	==========     Получить имя игрока без цветового кода     ==========
function getPlayerNameWoutColor(player)
	return string.gsub(getPlayerName(player), '#%x%x%x%x%x%x', '')
end

--	==========     Проверка, что ресурс запущен     ==========
function isResourceRunning(resName)
	local res = getResourceFromName(resName)
	return (res) and (getResourceState(res) == "running")
end


-- ==========     Связанное с удалением аккаунтов     ==========
function wipeAccount(accName)
	local moneyEquivalent = 0
	local data = exports.mysql:dbQuery(-1, "vehicle", "SELECT * FROM ?? WHERE owner = ?", accName)
	for index, car in ipairs(data) do
		exports.mysql:dbExec("vehicle", "DELETE FROM ?? WHERE ID = ?", car.ID)
		exports.mysql:dbExec("handling", "DELETE FROM ?? WHERE ID = ?", car.ID)
		local cost, currency = getCarPrice(car.model)
		outputDebugString(string.format("[CAR-SYSTEM] Deleted car ID %i, owner %s, licensep %s, model %i, name \"%s\", cost %i %s",
			car.ID, car.owner, car.licensep, car.model, getVehicleModName(car.model), cost, (currency or "RUB")
		))
		data[index].cost = exports.bank:convertCurrency(cost, (currency or "RUB"), "RUB")
		moneyEquivalent = moneyEquivalent + data[index].cost
	end
	outputDebugString(string.format("[CAR-SYSTEM] Cars equivalent of account %s: %i", accName, moneyEquivalent))
	return moneyEquivalent, data
end

function addBase(player,vehicle,r1, g1, b1, r2, g2, b2,region)
local accName = getAccountName(getPlayerAccount(player))
local newID = getFreeID() or 1

local color = table.concat({r1, g1, b1, r2, g2, b2}, ",")
-- local licensePlate = generateNumberplate("a", region)
local licensePlate = generateNumberplate("special")
local paintjob = stockPaintjobs[vehicle] or ""
local fuel = math.random(10, 25)

    exports.mysql:dbExec("vehicle", [[INSERT INTO ?? (ID, owner, model, x, y, z, rotZ, colors, upgrades, paintjob, HP, fuel, licensep, customTuning, fuelOctane, odometer, userOrder)
        VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);]],
        newID, accName, vehicle, 0,0,2,0, color, "", paintjob, 1000.0, fuel, licensePlate, toJSON({toner = {false, false, false}}, true), "92.0", math.random(0, 12), getNextUserOrderValue(accName)
    )exports.mysql:dbExec("handling", "REPLACE INTO ?? (ID, handling) VALUES(?, ?);", newID, "")
    updateVehicleInfo(player)
end


function addPoliceBase(player,vehicle,r1, g1, b1, r2, g2, b2,region)
local accName = getAccountName(getPlayerAccount(player))
local newID = getFreeID() or 1

local color = table.concat({r1, g1, b1, r2, g2, b2}, ",")
local licensePlate = generateNumberplate("b", region)
local paintjob = stockPaintjobs[vehicle] or ""
local fuel = math.random(10, 25)

    exports.mysql:dbExec("vehicle", [[INSERT INTO ?? (ID, owner, model, x, y, z, rotZ, colors, upgrades, paintjob, HP, fuel, licensep, customTuning, fuelOctane, odometer, userOrder)
        VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);]],
        newID, accName, vehicle, 0,0,2,0, color, "", paintjob, 1000.0, fuel, licensePlate, toJSON({toner = {false, false, false}}, true), "92.0", math.random(0, 12), getNextUserOrderValue(accName)
    )exports.mysql:dbExec("handling", "REPLACE INTO ?? (ID, handling) VALUES(?, ?);", newID, "")
    updateVehicleInfo(player)
end
