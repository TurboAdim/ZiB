
local bannedSirenCars = {
	[416] = true,	-- Ambulance
	[490] = true,	-- Range Rover SVAutobiography
	[596] = true,	-- Audi A8 D4
	[598] = true,	-- Mercedes-Benz E63 AMG
	[599] = true,	-- Toyota Land Cruiser 200
}

local settingsFile = "settings.json"
usedautoColshape = createColRectangle(1692.502441, -1142.171875, 10, 25) -- Б/у салон

local currencyTable = {
	-- PLN = "₽",
	PLN = " руб.",
	USD = "$",
	EUR = "€",
}

local suppressF3Colshapes = {
	createColSphere(-2230, 1827, -1, 200),			-- Тюрьма
	createColCuboid(-3135, -1677, 50, 73, 14, 6),	-- Шахта, проход
	createColCuboid(-3232, -1753, 47, 108, 77, 7),	-- Шахта, основная часть
}
local teleportBlockCoords = {x = -2230, y = 1827, radius = 200}

GUI = {
	window = {}, 
	label = {}, 
	gridlist = {}, 
	edit = {},
	button = {},
    staticimage = {},
	radiobutton = {},
	checkbox = {},
}
local screenW, screenH = guiGetScreenSize()
local minimalSize = {x = 310, y = 440}
local vehListData = { [-1]={} }

function createPlayerWindows()
	-- ===================     Главное окно     ===================
	GUI.window.main = guiCreateWindow((screenW-minimalSize.x)/2, (screenH-minimalSize.y)/ 2, minimalSize.x, minimalSize.y, "Управление транспортом", false)

	GUI.button.sell = guiCreateButton(10, 30, 90, 45, "Продать", false, GUI.window.main)
	GUI.button.blip = guiCreateButton(110, 30, 90, 45, "Метка", false, GUI.window.main)
	GUI.button.lock = guiCreateButton(210, 30, 90, 45, "Откр/Закр", false, GUI.window.main)
	GUI.gridlist.vehList = guiCreateGridList(10, 85, 290, 245, false, GUI.window.main)
	guiGridListSetSortingEnabled(GUI.gridlist.vehList, false)
	guiGridListAddColumn(GUI.gridlist.vehList, "Транспорт", 0.62)
	guiGridListAddColumn(GUI.gridlist.vehList, "Номер", 0.32)
	GUI.checkbox.sortByName = guiCreateCheckBox(80, 335, 150, 15, "Сортировать по имени", false, false, GUI.window.main)
	GUI.button.respawn = guiCreateButton(10, 360, 90, 20, "Респавн", false, GUI.window.main)
	GUI.button.remove = guiCreateButton(10, 385, 90, 20, "Убрать", false, GUI.window.main)
	GUI.button.warp = guiCreateButton(110, 360, 90, 45, "Телепорт", false, GUI.window.main)
	GUI.button.freeze = guiCreateButton(210, 360, 90, 45, "Заблоки-\nровать", false, GUI.window.main)
	GUI.button.resetHandling = guiCreateButton(210, 360, 90, 45, "Сбросить хэндлинг", false, GUI.window.main)
	GUI.label.parkingLots = guiCreateLabel(10, 415, 270, 15, "Парковочных мест занято: * из *.", false, GUI.window.main)
	guiLabelSetHorizontalAlign(GUI.label.parkingLots, "center", false)

	-- ===================     Продажа на б/у рынок     ===================
	GUI.window.sell = guiCreateWindow((screenW-310)/2, (screenH-150)/2, 310, 150, "Внимание!", false)
	guiSetProperty(GUI.window.sell, "AlwaysOnTop", "true")
	guiWindowSetSizable(GUI.window.sell, false)
	
	GUI.label.sellText = guiCreateLabel(21, 23, 266, 36, "За сколько вы желаете выставить автомобиль на продажу? (20-70% от цены)", false, GUI.window.sell)
	guiLabelSetHorizontalAlign(GUI.label.sellText, "center", true)
	guiLabelSetColor(GUI.label.sellText, 38, 122, 216)
	GUI.edit.carPrice = guiCreateEdit(17, 58, 273, 30, "", false, GUI.window.sell)
	GUI.button.sellOK = guiCreateButton(17, 103, 149, 36, "Выставить на продажу", false, GUI.window.sell)
	GUI.button.sellCancel = guiCreateButton(181, 103, 109, 36, "Отмена", false, GUI.window.sell)

	-- ===================     Автосалон     ===================
	GUI.window.shop = guiCreateWindow(screenW-350, screenH-450, 343, 436, "Автосалон", false)
	guiWindowSetSizable(GUI.window.shop, false)
	guiSetAlpha(GUI.window.shop, 0.8)
	
	GUI.gridlist.shop = guiCreateGridList(9, 20, 324, 329, false, GUI.window.shop)
	guiGridListSetSortingEnabled(GUI.gridlist.shop, false)
	guiGridListAddColumn(GUI.gridlist.shop, "Автомобиль", 0.65)
	guiGridListAddColumn(GUI.gridlist.shop, "Цена", 0.3)
	GUI.button.buy = guiCreateButton(14, 355, 86, 56, "Купить", false, GUI.window.shop)
	guiSetProperty(GUI.button.buy, "NormalTextColour", "FF069AF8")
	GUI.button.chooseColor = guiCreateButton(128, 355, 86, 56, "Выбрать цвет", false, GUI.window.shop)
	guiSetProperty(GUI.button.chooseColor, "NormalTextColour", "FF069AF8")
	GUI.button.closeShop = guiCreateButton(237, 355, 86, 56, "Закрыть", false, GUI.window.shop)
	guiSetProperty(GUI.button.closeShop, "NormalTextColour", "FF069AF8")
		
	-- ===================     Вне GUI Editor     ===================
	guiSetVisible(GUI.window.shop, false)
	guiSetVisible(GUI.window.main, false)
	guiSetVisible(GUI.window.sell, false)
	addWindowToCursorControl(GUI.window.shop)
	addWindowToCursorControl(GUI.window.main)
	addWindowToCursorControl(GUI.window.sell)
	triggerServerEvent("clientStartsResource", resourceRoot)
	
	loadSettings()
	saveSettings()
end
addEventHandler("onClientResourceStart", resourceRoot, createPlayerWindows)

-- ===================     Масштабирование элементов при изменении размера окна     ===================
function recalculateMainGUIElements()
	local window = getExtendedGUISize(GUI.window.main)
	if (window.x < minimalSize.x) and (window.y < minimalSize.y) then
		guiSetSize(GUI.window.main, minimalSize.x, minimalSize.y, false)
		window = getExtendedGUISize(GUI.window.main)
	elseif (window.x < minimalSize.x) then
		guiSetSize(GUI.window.main, minimalSize.x, window.y, false)
		window = getExtendedGUISize(GUI.window.main)
	elseif (window.y < minimalSize.y) then
		guiSetSize(GUI.window.main, window.x, minimalSize.y, false)
		window = getExtendedGUISize(GUI.window.main)
	end
	
	guiSetSize(GUI.gridlist.vehList,	window.x-20, window.y-195, false)
	
	guiSetPosition(GUI.button.sell, window.center.x-145, 30, false)
	guiSetPosition(GUI.button.blip, window.center.x- 45, 30, false)
	guiSetPosition(GUI.button.lock, window.center.x+ 55, 30, false)
	
	guiSetPosition(GUI.button.respawn,	window.center.x-145, window.y-80, false)
	guiSetPosition(GUI.button.remove,	window.center.x-145, window.y-55, false)
	guiSetPosition(GUI.button.warp,		window.center.x- 45, window.y-80, false)
	guiSetPosition(GUI.button.freeze,	window.center.x+ 55, window.y-80, false)
	guiSetPosition(GUI.button.resetHandling, window.center.x+ 55, window.y-80, false)
	guiSetPosition(GUI.label.parkingLots,	 window.center.x-145, window.y-25, false)
	
	guiSetPosition(GUI.checkbox.sortByName, window.center.x-75, window.y-105, false)
	
	saveSettings()
end

addEventHandler("onClientGUISize", resourceRoot, function()
	if (source == GUI.window.main) then
		recalculateMainGUIElements()
	end
end)

function _getElementModel(element)
	if getElementType(element) == 'vehicle' then
		return getElementData(element, exports.newmodels:getDataNameFromType("vehicle")) or getElementModel(element)
	else
		return getElementModel(element)
	end
end

function getExtendedGUISize(element)
	local size = {}
	size.x, size.y = guiGetSize(element, false)
	size.center = {x = size.x/2, y = size.y/2}
	return size
end

-- ===================     Сохранение и загрузка размеров главного окна     ===================
function loadSettings()
	local data
	if fileExists(settingsFile) then 
		local file = fileOpen(settingsFile, true)
		if (file) then
			data = fromJSON(fileRead(file, fileGetSize(file)))
			fileClose(file)
		end
	end
	if (type(data) ~= "table") then data = {} end

	if (type(data.size) == "table") and tonumber(data.size.x) and tonumber(data.size.y) then
		guiSetSize(GUI.window.main, data.size.x, data.size.y, false)
		guiSetPosition(GUI.window.main, (screenW-data.size.x)/2, (screenH-data.size.y)/2, false)
		recalculateMainGUIElements()
	end
	
	guiCheckBoxSetSelected(GUI.checkbox.sortByName, data.sortByName or false)
end

local saveTimer
local needsSave = false

function saveSettings()
	if isTimer(saveTimer) then
		needsSave = true
	else
		needsSave = true
		writeSettingsFile()
		saveTimer = setTimer(writeSettingsFile, 1000, 1)
	end
end

function writeSettingsFile()
	if (needsSave) then
		local data = {size={}}
		data.size.x, data.size.y = guiGetSize(GUI.window.main, false)
		data.sortByName = guiCheckBoxGetSelected(GUI.checkbox.sortByName)
		
		local file = fileCreate(settingsFile)
		if (file) then
			fileWrite(file, toJSON(data, true))
			fileClose(file)
		end
		needsSave = false
	end
end

-- ===================     Обработка кнопок основного окна     ===================
local oldID, sellingBaseID, sellingVehModel
function onGUIClick()
	local selectedID = guiGridListGetSelectedItem(GUI.gridlist.vehList)
	local carID = vehListData[selectedID].ID
	
	if (source == GUI.gridlist.vehList) then
		if (selectedID == -1) and oldID then
			guiGridListSetSelectedItem(GUI.gridlist.vehList, oldID, 1)
			return
		else
			oldID = guiGridListGetSelectedItem(GUI.gridlist.vehList)
		end
		
	elseif (source == GUI.button.respawn) then
		if (not carID) then outputCarSystemError("Не выбрана машина!") return end
		if antiDOScheck() then
			triggerServerEvent("respawnMyVehicle", resourceRoot, carID)
		end
		
	elseif (source == GUI.button.remove) then
		if (not carID) then outputCarSystemError("Не выбрана машина!") return end
		if antiDOScheck() then
			triggerServerEvent("removeMyVehicle", resourceRoot, carID)
		end
		
	elseif (source == GUI.button.blip) then 
		if (not carID) then outputCarSystemError("Не выбрана машина!") return end
		if antiDOScheck() then
			triggerServerEvent("BlipMyVehicle", resourceRoot, carID)
		end
		
	elseif (source == GUI.button.lock) then 
		if (not carID) then outputCarSystemError("Не выбрана машина!") return end
		if antiDOScheck() then
			triggerServerEvent("LockMyVehicle", resourceRoot, carID)
		end
		
	elseif (source == GUI.button.sell) then
		if (not carID) then outputCarSystemError("Не выбрана машина!") return end
		if isElementWithinColShape(localPlayer, usedautoColshape) then
			sellingBaseID = carID
			sellingVehModel = vehListData[selectedID].model
			local _, defaultPrice = getAllSellingPrices(sellingVehModel)
			if (defaultPrice) then
				guiSetText(GUI.edit.carPrice, defaultPrice)
				guiSetVisible(GUI.window.sell, true)
			else
				outputCarSystemError("Невозможно продать автомобиль. Банковские операции недоступны.")
			end
		else
			outputCarSystemError("Невозможно продать автомобиль. Вы и ваш автомобиль должны находиться на спец. площадке рядом со входом на б/у рынок.")
		end	
		
	elseif (source == GUI.button.sellOK) then
		if not isElementWithinColShape(localPlayer, usedautoColshape) then
			outputCarSystemError("Невозможно продать автомобиль. Вы и ваш автомобиль должны находиться на спец. площадке рядом со входом на б/у рынок")
			return
		end
		local _, _, costLow, costHigh = getAllSellingPrices(sellingVehModel)
		if (costLow) then
			local gotPrice = tonumber(guiGetText(GUI.edit.carPrice))
			if (gotPrice < costLow) then
				outputCarSystemError("Нельзя поставить цену меньше "..costLow.." руб.")
				return
			end
			if (gotPrice > costHigh) then
				outputCarSystemError("Нельзя поставить цену больше "..costHigh.." руб.")
				return
			end
			triggerServerEvent("SellMyVehicle", resourceRoot, sellingBaseID, gotPrice)
			guiSetVisible(GUI.window.main, false)
			guiSetVisible(GUI.window.sell, false)
			hideCursor()
		else
			outputCarSystemError("Невозможно продать автомобиль. Банковские операции недоступны.")
		end
		
		
	elseif (source == GUI.button.sellCancel) then
		guiSetVisible (GUI.window.sell, false)
		
	elseif source == GUI.button.freeze then
		if (not carID) then outputCarSystemError("Не выбрана машина!") return end
		if antiDOScheck() then
			triggerServerEvent("FreezeMyVehicle", resourceRoot, carID, (isResourceRunning("house") and exports.house:getMyHouses()) )
		end
		
	elseif source == GUI.button.resetHandling then
		if (not carID) then outputCarSystemError("Не выбрана машина!") return end
		if antiDOScheck() then
			triggerServerEvent("ResetVehicleHandling", resourceRoot, carID)
		end
		
	elseif source == GUI.button.warp then
		if (not carID) then outputCarSystemError("Не выбрана машина!") return end
		local x,y,_ = getElementPosition(localPlayer)
		if (getDistanceBetweenPoints2D(x,y, teleportBlockCoords.x, teleportBlockCoords.y) < teleportBlockCoords.radius) then
			outputCarSystemError("Невозможно доставить автомобиль на охраняемую территорию.")
			return
		end
		if antiDOScheck() then
			triggerServerEvent("WarpMyVehicle", resourceRoot, carID)
		end
		
	elseif (source == GUI.checkbox.sortByName) then
		refreshGrid()
		saveSettings()
		
	end
end
addEventHandler("onClientGUIClick", resourceRoot, onGUIClick)

function openMainWindow()
	if (getElementInterior(localPlayer) == 0) and (getElementDimension(localPlayer) <= 10) and not isPlayerInSupressF3Colshape() and not getElementData(localPlayer, "isChased") then
		local state = not guiGetVisible(GUI.window.main)
		guiSetVisible(GUI.window.main, state)
		guiSetVisible(GUI.window.sell, false)
		if (state) then
			if isResourceRunning("hedit") and exports.hedit:isPlayerInsideRepairStation(localPlayer) then
				guiSetVisible(GUI.button.freeze, false)
				guiSetVisible(GUI.button.resetHandling, true)
			else
				guiSetVisible(GUI.button.freeze, true)
				guiSetVisible(GUI.button.resetHandling, false)
			end	
			showCursor(true)
		else
			hideCursor()
		end		
	else
		hideCarWindows()
	end
end
--addCommandHandler("carpanel", openMainWindow, false)
addCommandHandler("cp", openMainWindow, false)
bindKey("F3", "down", "cp")

function hideCarWindows()
	guiSetVisible(GUI.window.main, false)
	guiSetVisible(GUI.window.sell, false)
	hideCursor()
end

local carData
function refreshGrid(data)
	carData = data or carData
	if guiCheckBoxGetSelected(GUI.checkbox.sortByName) then
		table.sort(carData, function(a, b)
			local nameA = utf8.lower(getVehicleModName(a.model))
			local nameB = utf8.lower(getVehicleModName(b.model))
			return nameA < nameB
		end)
	else
		table.sort(carData, function(a, b) return a.userOrder < b.userOrder end)
	end
	
	local rw, cl = guiGridListGetSelectedItem(GUI.gridlist.vehList)
	guiGridListClear(GUI.gridlist.vehList)
	for _, dataRow in ipairs(carData) do			
		local row = guiGridListAddRow(GUI.gridlist.vehList)
		guiGridListSetItemText(GUI.gridlist.vehList, row, 1, getVehicleModName(dataRow.model), false, true)
		guiGridListSetItemText(GUI.gridlist.vehList, row, 2, convertPlateIDtoLicensep(dataRow.licensep), false, true)
		vehListData[row] = {ID = tonumber(dataRow.ID), model = dataRow.model}
	end
	guiGridListSetSelectedItem(GUI.gridlist.vehList, rw, cl)
	refreshInterchangeGrid(carData)
end
addEvent("refreshCarList", true )
addEventHandler("refreshCarList", resourceRoot, refreshGrid)


--	==========     Слежение за попаданием игрока в зоны запрещения F3     ==========
function isPlayerInSupressF3Colshape()
	for _, colshape in ipairs(suppressF3Colshapes) do
		if isElementWithinColShape(localPlayer, colshape) then
			return true
		end
	end
	return false
end

function onSuppressF3ColshapeEnter(element, matchingDimension)
	if (element == localPlayer) and (matchingDimension) then
		hideCarWindows()
		ic_closeAllWindows(false)
	end
end
for _, colshape in ipairs(suppressF3Colshapes) do
	addEventHandler("onClientColShapeHit", colshape, onSuppressF3ColshapeEnter)
end

setTimer(function()
	if guiGetVisible(GUI.window.main) then
		if (getElementInterior(localPlayer) ~= 0) or (getElementDimension(localPlayer) > 10) or getElementData(localPlayer, "isChased") then
			hideCarWindows()
		end
	end
end, 100, 0)


--	==========     Получение значка валюты из таблицы     ==========
function currencyToSymbol(currency)
	currency = currency or "PLN"
	return currencyTable[currency] or ""
end

--	==========     Разделение числа на части     ==========
function explodeNumber(number)
	number = tostring(number)
	local k
	repeat
		number, k = string.gsub(number, "^(-?%d+)(%d%d%d)", '%1 %2')
	until (k==0)	-- true - выход из цикла
	return number
end

--	==========     Обновление строки с занятыми местами     ==========
function catchParkingLotsCount(filled, all)
	guiSetText(GUI.label.parkingLots, "Парковочных мест занято: "..filled.." из "..(all+1)..".")
	guiSetText(GUIEditor.label[14], "Ваш гараж: "..filled.." авто")
end
addEvent("catchParkingLotsCount", true)
addEventHandler("catchParkingLotsCount", resourceRoot, catchParkingLotsCount)

--	==========     Вывод сообщений в формате автосалона     ==========
function outputCarSystemInfo(text)
	outputChatBox("[Автосалон] #58FAF4"..text:gsub("#цв#", "#58FAF4"), 38, 122, 216, true)
end
function outputCarSystemError(text)
	outputChatBox("[Автосалон] #FF3232"..text:gsub("#цв#", "#FF3232"), 38, 122, 216, true)
end

--	==========     Слоумод на кнопку/действие     ==========
local antiDOSdelay, triggerEventPause = 250
function antiDOScheck()
	if isTimer(triggerEventPause) then
		return false
	else
		triggerEventPause = setTimer(function() end, antiDOSdelay, 1)
		return true
	end
end

--	==========     Проверка, что ресурс запущен     ==========
function isResourceRunning(resName)
	local res = getResourceFromName(resName)
	return (res) and (getResourceState(res) == "running")
end

--	==========     Контроль включения мигалок     ==========
local sirenTimer
addEventHandler("onClientVehicleEnter", root, function(player, seat)
	if (player == localPlayer) then
		if (bannedSirenCars[ _getElementModel(source) ]) then
			if isTimer(sirenTimer) then killTimer(sirenTimer) end
			local licensep = tostring(getElementData(source, "licensep"))
			if (licensep:sub(1,1) ~= "b") then
				sirenTimer = setTimer(controlSirens, 100, 0)
			end
		end
	end
end)

function controlSirens()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if (vehicle) then
		if getVehicleSirensOn(vehicle) then
			setVehicleSirensOn(vehicle, false)
		end
	else
		if isTimer(sirenTimer) then killTimer(sirenTimer) end
	end
end


--	==========     Проверяет, не открыто ли какое-нибудь из окон     ==========
local controlledWindows = {}
function addWindowToCursorControl(window)
	table.insert(controlledWindows, window)
end

function hideCursor()
	for _, window in ipairs(controlledWindows) do
		if guiGetVisible(window) then
			return
		end
	end
	showCursor(false)
end
