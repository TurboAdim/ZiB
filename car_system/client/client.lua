local bannedSirenCars = {
	[416] = true,	-- Ambulance
	[490] = true,	-- Range Rover SVAutobiography
	[596] = true,	-- Audi A8 D4
	[598] = true,	-- Mercedes-Benz E63 AMG
	[599] = true,	-- Toyota Land Cruiser 200
}

usedautoColshape = createColRectangle(1692.502441, -1142.171875, 9, 25) -- Б/у салон

local suppressF3Colshapes = {
	createColSphere(-2730, 1827, -1, 200),			-- Тюрьма
	createColCuboid(-3135, -1677, 50, 73, 14, 6),	-- Шахта, проход
	createColCuboid(-3232, -1753, 47, 108, 77, 7),	-- Шахта, основная часть
}
local teleportBlockCoords = {x = -2730, y = 1827, radius = 200}

addEventHandler("onClientResourceStart", resourceRoot, function()
	triggerServerEvent("clientStartsResource", resourceRoot)
end)

Vehicle = {}

Vehicle.Manager = {};
local self = Vehicle.Manager
local carData

-- // Startup
function Vehicle.Manager:Startup()

	-- // Logic and int variables
	self.isVisible 			= false;
	self.iGlobalAlpha		= 0;
	self.vehData 			= {};
	self.scroll 			= 0;
	self.scrollMax			= 0;
	self.isSelected			= 0;
	self.isMenu				= "Main"
	self.isText   	 		= "Miejsca parkingowe: 0 na 0"

	-- // EditBox
	self.activeSellText		= false;
	self.tickBackSpace		= getTickCount()
	self.edits 				= {
							   sellText = "Wprowadź kwotę";
							}

	self.isParks			= {
								filled = 0,
								all = 0,
							}

	-- // Render target and optimization
	self.ListCars 			= dxCreateRenderTarget(364 * px, 265 * px, true);

	-- // Fonts
	self.uFontRegular1		= DxFont("assets/fonts/regular.ttf", 26 * px, false, "antialiased");
	self.uFontRegular2		= DxFont("assets/fonts/regular.ttf", 23 * px, true, "antialiased");
	self.uFontRegular3		= DxFont("assets/fonts/regular.ttf", 25 * px, true, "antialiased");
end
Vehicle.Manager:Startup()

function Vehicle.Manager.Render()
	
	if self.isVisible then
		if self.iGlobalAlpha <= 245 then
			self.iGlobalAlpha = self.iGlobalAlpha + 10
		end
	elseif self.isVisible == false then
		if self.iGlobalAlpha >= 5 then
			self.iGlobalAlpha = self.iGlobalAlpha - 10
		end
	end

	--dxDrawRectangle(0, 0, PScreen.x, PScreen.y, tocolor(0, 0, 0, 190 * self.iGlobalAlpha/255))

	if self.isMenu == "Main" then
		dxDrawImage((PScreen.x/2) - (730*px/2), (PScreen.y/2) - (475*py/2), 730*px, 475*py, "assets/images/main.png", 0, 0, 0, tocolor(255, 255, 255, 255))
		--dxDrawImage(635*px, 330*py, 22*px, 48*py, "assets/images/line.png", 0, 0, 0, tocolor(118, 45, 255, self.iGlobalAlpha))
		--dxCreateText("Управление транспортом", 667*px, 344*py, 0, 0, tocolor(255, 255, 255, self.iGlobalAlpha), 0.5, self.uFontRegular1, "left", "top")

		dxDrawImage(644*px, 386*py, 380*px, 345*py, "assets/images/main2.png", 0, 0, 0, tocolor(15, 15, 15, self.iGlobalAlpha))
		dxCreateText("Pojazd", 670*px, 406*py, 0, 0, tocolor(255, 255, 255, 100 * self.iGlobalAlpha/255), 0.5, self.uFontRegular2, "left", "top")
		dxCreateText("Rejestracja", 999*px, 406*py, 0, 0, tocolor(255, 255, 255, 100 * self.iGlobalAlpha/255), 0.5, self.uFontRegular2, "right", "top")

		dxCreateText(self.isText, (PScreen.x/2) - (730*px/2), 743*py, 730*px, 0, tocolor(79, 79, 79, self.iGlobalAlpha), 0.5, self.uFontRegular2, "center", "top", false, false, false, true, false)

		dxCreateButton(1049*px, 403*py, 245*px, 45*py, "assets/images/button_null_respawn.png", "assets/images/button_respawn.png", self.iGlobalAlpha, 255, 255, 255, 255, 255, 255, 0)
		--dxCreateText("Респавн", 1049*px, 403*py, 245*px, 45*py, tocolor(255, 255, 255, self.iGlobalAlpha), 0.5, self.uFontRegular2, "center", "center")

		dxCreateButton(1049*px, 454*py, 245*px, 45*px, "assets/images/button_null.png", "assets/images/button.png", self.iGlobalAlpha, 255, 255, 255, 255, 255, 255, 1)
		--dxCreateText("Телепорт", 1049*px, 454*py, 245*px, 45*py, tocolor(255, 255, 255, self.iGlobalAlpha), 0.5, self.uFontRegular2, "center", "center")

		dxCreateButton(1049*px, 505*py, 245*px, 45*px, "assets/images/button_null_remove.png", "assets/images/button_remove.png", self.iGlobalAlpha, 255, 255, 255, 255, 255, 255, 2)
		--dxCreateText("Убрать", 1049*px, 505*py, 245*px, 45*py, tocolor(255, 255, 255, self.iGlobalAlpha), 0.5, self.uFontRegular2, "center", "center")

		dxCreateButton(1049*px, 556*py, 245*px, 45*px, "assets/images/button_null_lock.png", "assets/images/button_lock.png", self.iGlobalAlpha, 255, 255, 255, 255, 255, 255, 3)
		--dxCreateText("Открыть/Закрыть", 1049*px, 556*py, 245*px, 45*py, tocolor(255, 255, 255, self.iGlobalAlpha), 0.5, self.uFontRegular2, "center", "center")

		dxCreateButton(1049*px, 607*py, 245*px, 45*px, "assets/images/button_null_sell.png", "assets/images/button_sell.png", self.iGlobalAlpha, 255, 255, 255, 255, 255, 255, 4)
		--dxCreateText("Продать", 1049*py, 607*py, 245*px, 45*py, tocolor(255, 255, 255, self.iGlobalAlpha), 0.5, self.uFontRegular2, "center", "center")

		dxCreateButton(1049*px, 658*py, 245*px, 45*px, "assets/images/button_null_map.png", "assets/images/button_map.png", self.iGlobalAlpha, 255, 255, 255, 255, 255, 255, 5)
		--dxCreateText("Метка", 1049*px, 658*py, 245*px, 45*py, tocolor(255, 255, 255, self.iGlobalAlpha), 0.5, self.uFontRegular2, "center", "center")

		dxSetBlendMode("add")
			dxDrawImage(652*px, 434*py, 364*px, 265*py, self.ListCars, 0, 0, 0, tocolor(255, 255, 255, self.iGlobalAlpha))
		dxSetBlendMode("blend")

		if self.scrollMax > 0 then
			dxDrawRoundedRectangle(1029*px, 448*py, 5*px, 230*py, 4*px, tocolor(15, 15, 15, self.iGlobalAlpha))

			local size = 230*px * ((230*px)/(self.scrollMax + 230*px))
			dxDrawRoundedRectangle (1029*px, 448*py + self.scroll/self.scrollMax*(230*px-size), 5*px, size, 2.5*px, tocolor(239, 93, 93, 255))
		end

	elseif self.isMenu == "Sale" then
		dxDrawImage((PScreen.x/2) - (422*px/2), (PScreen.y/2) - (331*py/2), 422*px, 331*py, "assets/images/sale/main.png", 0, 0, 0, tocolor(25, 25, 25, self.iGlobalAlpha))
		dxDrawImage(1113*px, 404*py, 29*px, 29*py, "assets/images/sale/close.png", 0, 0, 0, tocolor(255, 255, 255, self.iGlobalAlpha))
		dxDrawImage(789*px, 395*py, 22*px, 48*py, "assets/images/line.png", 0, 0, 0, tocolor(239, 93, 93, 255))
		dxCreateText("Sprzedaż pojazdu", 822*px, 410*py, 0, 0, tocolor(255, 255, 255, self.iGlobalAlpha), 0.5, self.uFontRegular1, "left", "top")

		dxCreateText("Wpisz kwotę za ile\nchcesz sprzedać ten\npojazd (#762dff20#FFFFFF-#762dff70#FFFFFF% ceny salonowej)", (PScreen.x/2) - (730*px/2), 463*py, 730*px, 0, tocolor(255, 255, 255, self.iGlobalAlpha), 0.5, self.uFontRegular3, "center", "top", false, false, false, true, false)

		dxDrawImage((PScreen.x/2) - (245*px/2), 545*py, 245*px, 45*px, "assets/images/button.png", 0, 0, 0, tocolor(35, 35, 35, self.iGlobalAlpha))
		if self.activeSellText then
			local w = dxGetTextWidth (isConvertNumber(self.edits.sellText), 0.5, self.uFontRegular3)
			if math.floor(getTickCount()/500) % 2 == 0 then
				dxDrawRectangle ((PScreen.x/2) + (6*px/2) + w/2, 553*py, 2*px, 29*px, tocolor (255, 255, 255, self.iGlobalAlpha))
			end

			if getKeyState ("backspace") then
				if getTickCount() - self.tickBackSpace > 50 then
					self.edits.sellText = utf8.sub (self.edits.sellText, 1, utf8.len(self.edits.sellText) - 1)
					self.tickBackSpace = getTickCount()
				end
			end
		end

		if self.edits.sellText == "Wprowadź kwotę" then
			dxCreateText("Wprowadź kwotę", (PScreen.x/2) - (245*px/2), 545*py, 245*px, 45*px,  tocolor(255, 255, 255, 100 * self.iGlobalAlpha/255), 0.5, self.uFontRegular3, "center", "center");
		else
			dxCreateText(isConvertNumber(self.edits.sellText), (PScreen.x/2) - (245*px/2), 545*py, 245*px, 45*px,  tocolor(255, 255, 255, 255), 0.5, self.uFontRegular3, "center", "center");
		end


		dxCreateButton((PScreen.x/2) - (245*px/2), 613*py, 245*px, 45*px, "assets/images/button.png", "assets/images/button.png", self.iGlobalAlpha, 118, 45, 255, 131, 65, 255, 6)
		dxCreateText("Sprzedaj", (PScreen.x/2) - (245*px/2), 613*py, 245*px, 45*px, tocolor(255, 255, 255, self.iGlobalAlpha), 0.5, self.uFontRegular2, "center", "center")
	end

end

function Vehicle.Manager.VehicleList()

	collectgarbage()

	dxSetRenderTarget(self.ListCars, true)
		dxSetBlendMode("modulate_add")
			local y = 0

			for i, v in ipairs (carData) do
				if i == self.isSelected then
					dxDrawImage(0, y - self.scroll, 364*px, 40*py, "assets/images/rectangle.png", 0, 0, 0, tocolor(239, 93, 93, 255))
					dxCreateText (getVehicleModName(v.model):sub (1, 24), 20*px, y - self.scroll, 364*px, 40*py, tocolor(255, 255, 255, self.iGlobalAlpha), 0.5, self.uFontRegular2, "left", "center")
					dxCreateText (convertPlateIDtoLicensep(v.licensep), 0, y - self.scroll, 348*px, 40*px, tocolor(255, 255, 255, self.iGlobalAlpha), 0.5, self.uFontRegular2, "right", "center")
				else
					dxCreateText (getVehicleModName(v.model):sub (1, 24), 20*px, y - self.scroll, 364*px, 40*px, tocolor(255, 255, 255, self.iGlobalAlpha), 0.5, self.uFontRegular2, "left", "center")
					dxCreateText (convertPlateIDtoLicensep(v.licensep), 0, y - self.scroll, 348*px, 40*px, tocolor(255, 255, 255, self.iGlobalAlpha), 0.5, self.uFontRegular2, "right", "center")
				end

				self.vehData[i] = {ID = tonumber(v.ID), model = v.model}
				y = y + 45*py
			end

			if y > 265*py then
				self.scrollMax = y - 265*py
			end
		dxSetBlendMode("blend")
	dxSetRenderTarget()

end

function ClickManager(button, state)

	if state == "down" then else return end
    if button == "left" and state == "down" then
    	if self.isMenu == "Main" then
	    	local y = 0
			for i, v in ipairs (carData) do
				if isCursor(652*px, 434*py, 364*px, 265*py) then
					if isCursor(652*px, 434*py + y - self.scroll, 364*px, 40*py) then
						self.isSelected = i
					end
				end
				y = y + 45*px
			end

			if not isCursor((PScreen.x/2) - (730*px/2), (PScreen.y/2) - (475*py/2), 730*px, 475*py) then
				self.isSelected = nil
			end

			if isCursor(1049*px, 403*py, 245*px, 45*py) then
				if self.isSelected then
					if antiDOScheck() then
						local carID = self.vehData[self.isSelected].ID
						triggerServerEvent("respawnMyVehicle", resourceRoot, carID)

						local x, y, _ = getElementPosition(localPlayer)
						if (getDistanceBetweenPoints2D(x,y, teleportBlockCoords.x, teleportBlockCoords.y) < teleportBlockCoords.radius) then
							exports.v_message:add("Nie można dostarczyć pojazdu do strzeżonego obszaru.",1)
							return
						end

						setTimer(function ()
							local carID = self.vehData[self.isSelected].ID
							triggerServerEvent("WarpMyVehicle", resourceRoot, carID)
						end, 500, 1)
					end
				end
			elseif isCursor(1049*px, 454*py, 245*px, 45*px) then
				if self.isSelected then
					if antiDOScheck() then
						local carID = self.vehData[self.isSelected].ID
						triggerServerEvent("WarpMyVehicle", resourceRoot, carID, true)
					end
				end
			elseif isCursor(1049*px, 658*py, 245*px, 45*px) then
				if self.isSelected then
					if antiDOScheck() then
						local carID = self.vehData[self.isSelected].ID
						triggerServerEvent("BlipMyVehicle", resourceRoot, carID, true)
					end
				end
			elseif isCursor(1049*px, 505*py, 245*px, 45*px) then
				if self.isSelected then
					if antiDOScheck() then
						local carID = self.vehData[self.isSelected].ID
						triggerServerEvent("removeMyVehicle", resourceRoot, carID)
					end
				end
			elseif isCursor(1049*px, 556*py, 245*px, 45*px) then
				if self.isSelected then
					if antiDOScheck() then
						local carID = self.vehData[self.isSelected].ID
						triggerServerEvent("LockMyVehicle", resourceRoot, carID)
					end
				end
			elseif isCursor(1049*px, 607*py, 245*px, 45*px) then
				if self.isSelected then
					if antiDOScheck() then
						local carID = self.vehData[self.isSelected].ID
						local carModel = self.vehData[self.isSelected].model
						
						sellingBaseID = carID
						sellingVehModel = carModel

						local _, defaultPrice = getAllSellingPrices(sellingVehModel)
						if (defaultPrice) then
							self.isMenu = "Sale"
						end
					end
				end
			end

		elseif self.isMenu == "Sale" then

			if isCursor((PScreen.x/2) - (245*px/2), 545*py, 245*px, 45*px) then
	    		self.activeSellText = true
				guiSetInputMode ("no_binds")
				if self.edits.sellText == "Wprowadź kwotę" then
					self.edits.sellText = ""
				end
			else
				self.activeSellText = false
				guiSetInputMode ("allow_binds")
				if self.edits.sellText:gsub (" ", "") == "" then
					self.edits.sellText = "Wprowadź kwotę"
				end
			end

			if isCursor((PScreen.x/2) - (245*px/2), 613*py, 245*px, 45*px) then
				local _, _, costLow, costHigh = getAllSellingPrices(sellingVehModel)
				if (costLow) then
					local gotPrice = tonumber(self.edits.sellText)
					if (gotPrice < costLow) then
						exports.v_message:add ("Nie możesz ustawić niższej ceny niż "..costLow, 1)
						return
					end

					if (gotPrice > costHigh) then
						exports.v_message:add ("Nie możesz ustawić wyższej ceny niż "..costHigh, 1)
						return
					end

					triggerServerEvent("SellMyVehicle", resourceRoot, sellingBaseID, gotPrice)
					ShowInterface(false)
				else
					exports.v_message:add ("Nie udało się sprzedać samochodu. Operacje bankowe nie są dostępne.", 1)
				end
			elseif isCursor(1113*px, 404*py, 29*px, 29*py) then
				ShowInterface(false)
			end

		end

    end

end

addEventHandler ("onClientKey", root, function(key)
	if not self.isVisible then return end
	if key == "mouse_wheel_up" then
		if isCursor(652*px, 434*py, 364*px, 265*py) then
			if self.scroll - 25 >= 0 then
				self.scroll = self.scroll - 25
			else
				self.scroll = 0
			end
			Vehicle.Manager.VehicleList()
		end
	elseif key == "mouse_wheel_down" then
		if isCursor(652*px, 434*py, 364*px, 265*py) then
			if self.scroll + 25 <= self.scrollMax then
				self.scroll = self.scroll + 25
			else
				self.scroll = self.scrollMax
			end
			Vehicle.Manager.VehicleList()
		end
	end
end)

-- // Character symbol
addEventHandler ("onClientCharacter", root, function(char)
	if self.activeSellText and tonumber(char) then
		guiSetInputMode ("no_binds")

		if utf8.len(self.edits.sellText) < 9 then
			if utf8.find(tonumber(char), "%W") or utf8.find(tonumber(char), "%w") then
				self.edits.sellText = self.edits.sellText..tonumber(char)
			end
		end
	end
end)

-- // Delete symbol
addEventHandler ("onClientKey", root, function(key, state)
	if not state then return end
	if key == "backspace" then
		self.tickBackSpace = getTickCount() + 200
		if self.activeSellText then
			self.edits.sellText = utf8.sub (self.edits.sellText, 1, utf8.len(self.edits.sellText) - 1)
		end
	end
end)

-- // ShowManager
function ShowManager()
	Vehicle.Manager:Render();
	Vehicle.Manager:VehicleList();
end

-- // Hide engine
function ShowInterface(state)
	if (getElementInterior(localPlayer) == 0) and (getElementDimension(localPlayer) <= 10) and not isPlayerInSupressF3Colshape() and not getElementData(localPlayer, "isChased") then
	    if state then
	        if not isEventHandlerAdded("onClientRender", root, ShowManager) then
				addEventHandler("onClientRender", root, ShowManager)
			end

			if not isEventHandlerAdded("onClientClick", root, ClickManager) then
				addEventHandler("onClientClick", root, ClickManager)
			end

			self.isMenu = "Main"
			self.edits.sellText = "Wprowadź kwotę"
	    else
	        if isEventHandlerAdded("onClientRender", root, ShowManager) then
				if self.iGlobalAlpha <= 0 then
					removeEventHandler("onClientRender", root, ShowManager)
				end
			end

			if isEventHandlerAdded("onClientClick", root, ClickManager) then
				removeEventHandler("onClientClick", root, ClickManager)
			end

			self.isMenu = nil
			self.activeSellText = false
	    end

	    self.isVisible = state;
	    showCursor(state);
	else
		HideShowInterface()
		showCursor(false)
	end
end

function HideShowInterface()
	ShowInterface(false)
end

-- // Key press
bindKey("F3", "down", function()
	if not self.isVisible then
		ShowInterface(true);
		return
	end
	ShowInterface(false);
end)

function refreshGrid(data)
	carData = data or carData

	table.sort(carData, function(a, b)
			local nameA = utf8.lower(getVehicleModName(a.model))
			local nameB = utf8.lower(getVehicleModName(b.model))
			return nameA < nameB
		end)

	for i, dataRow in ipairs(carData) do			
		self.vehData[i] = {ID = tonumber(dataRow.ID), model = dataRow.model}
	end
	
	refreshInterchangeGrid(carData)
end
addEvent("refreshCarList", true )
addEventHandler("refreshCarList", resourceRoot, refreshGrid)

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
		ShowInterface(false)
	end
end
for _, colshape in ipairs(suppressF3Colshapes) do
	addEventHandler("onClientColShapeHit", colshape, onSuppressF3ColshapeEnter)
end

setTimer(function()
	if self.isVisible then
		if (getElementInterior(localPlayer) ~= 0) or (getElementDimension(localPlayer) > 10) or getElementData(localPlayer, "isChased") then
			ShowInterface(false)
		end
	end
end, 100, 0)

function catchParkingLotsCount(filled, all)
	self.isParks.filled = filled
	self.isParks.all = all
	self.isText = "#4f4f4fZajęte miejsca parkingowe: #EF5D5D"..filled.." #4f4f4f/ #E75642"..(getElementData(localPlayer, "customSlots") or 0) + (all+1).."#4f4f4f."
end
addEvent("catchParkingLotsCount", true)
addEventHandler("catchParkingLotsCount", resourceRoot, catchParkingLotsCount)

function outputCarSystemInfo(text, player)
	outputChatBox("#762DFF[Dealer] #FFFFFF"..text:gsub("#цв#", "#FFFFFF"), player, 255, 255, 255, true)
end

function outputCarSystemError(text, player)
	outputChatBox("#762DFF[Dealer] #FFFFFF"..text:gsub("#цв#", "#FFFFFF"), player, 255, 255, 255, true)
end

local antiDOSdelay, triggerEventPause = 250
function antiDOScheck()
	if isTimer(triggerEventPause) then
		return false
	else
		triggerEventPause = setTimer(function() end, antiDOSdelay, 1)
		return true
	end
end

function isResourceRunning(resName)
	local res = getResourceFromName(resName)
	return (res) and (getResourceState(res) == "running")
end

local sirenTimer
addEventHandler("onClientVehicleEnter", root, function(player, seat)
	if (player == localPlayer) then
		if (bannedSirenCars[ getElementModel(source) ]) then
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

function clearMemory()		
	local oldGarbage = math.floor(collectgarbage("count"))
	collectgarbage()
	outputDebugString(string.lower(getResourceName (getThisResource())).." collected "..oldGarbage-math.floor(collectgarbage("count")).." of "..oldGarbage.."KB")
end
setTimer(clearMemory, 1800000, 0)
addCommandHandler ("lag", clearMemory)