


--[[

-- function transCarOfferAcception(carData, seller, sellerMoney)
	-- if not isElement(seller) then return end
	-- if (not guiGetVisible(GUI.window.getCar)) then
		-- outputCarSystemInfo(getPlayerName(seller).." #32FF32предложил вам купить его "..getVehicleModName(carData.Model).."!")
		-- transCarData = carData
		-- transCarData.seller = seller
		-- transCarData.sellerMoney = sellerMoney
		-- transCarData.buyerMoney = (sellerMoney*1.05)
		-- guiSetText(GUI.label.getPlayer, string.gsub(getPlayerName(seller), '#%x%x%x%x%x%x', '').." предлагает вам купить его автомобиль.")
		-- guiSetText(GUI.label.getCar, "Марка, модель:\n"..getVehicleModName(carData.Model))
		-- local color = split(carData.Colors, ',')
		-- color = string.format("%.2X%.2X%.2X%.2X", 255,color[1],color[2],color[3])
		-- guiSetProperty(GUI.staticimage.getColor, "ImageColours", "tl:"..color.." tr:"..color.." bl:"..color.." br:"..color)
		-- guiSetText(GUI.label.getLicensep, "Номер: "..convertPlateIDtoLicensep(carData.licensep))
		-- guiSetText(GUI.label.getYouPay, "Вы заплатите: "..(sellerMoney*1.05).." руб.")
		-- guiSetText(GUI.label.getSellerGet, "Продавец получит: "..sellerMoney.." руб.")
		-- guiSetVisible(GUI.window.getCar, true)
		-- guiBringToFront(GUI.window.getCar)
		-- showCursor(true)
	-- else
		-- outputCarSystemError(getPlayerName(seller).." #FF3232попытался предложить вам "..getVehicleModName(carData.Model).." за "..sellerMoney.." руб, но у вас уже открыто окно покупки.")
		-- triggerServerEvent("carOfferAlreadyExists", resourceRoot, carData, seller)
	-- end
-- end
-- addEvent("transCarOffer", true)
-- addEventHandler("transCarOffer", resourceRoot, transCarOfferAcception)

-- function refreshTransCarList()
	-- guiGridListClear(GUI.gridlist.transPlayers)
	-- local x, y, z = getElementPosition(localPlayer)
	-- for _, player in ipairs(getElementsByType("player", root, true)) do
		-- local pX, pY, pZ = getElementPosition(player)
		-- -- if (getDistanceBetweenPoints3D(x, y, z, pX, pY, pZ) < 30) then
		-- if (getDistanceBetweenPoints3D(x, y, z, pX, pY, pZ) < 30) and (player ~= localPlayer) then
			-- local row = guiGridListAddRow(GUI.gridlist.transPlayers)
			-- guiGridListSetItemText(GUI.gridlist.transPlayers, row, 1, string.gsub(getPlayerName(player), '#%x%x%x%x%x%x', ''), false, false)
			-- guiGridListSetItemData(GUI.gridlist.transPlayers, row, 1, player)
		-- end
	-- end
-- end

-- function onEditBoxChanged()
	-- if (source == GUI.edit.transYouGet) then
		-- local money = tonumber(guiGetText(GUI.edit.transYouGet))
		-- if money then
			-- guiSetText(GUI.edit.transBuyerSum, math.floor(money*1.05))
		-- else
			-- guiSetText(GUI.edit.transBuyerSum, "")
		-- end
	-- end
-- end
-- addEventHandler("onClientGUIChanged", resourceRoot, onEditBoxChanged)
		
	-- elseif (source == GUI.button.sellToPlayer) then
		-- if (not carID) then outputCarSystemError("Не выбрана машина!") return end
		-- if not isElementWithinColShape(localPlayer, nomerchangeColshape) then
			-- outputCarSystemError("Невозможно продать автомобиль. Вы и ваш автомобиль должны находиться в центре перерегистрации.")
			-- return
		-- end
		-- local model = guiGridListGetItemData(GUI.gridlist.vehList, selectedID, 2)
		-- transCarBaseID = carID
		-- guiSetText(GUI.edit.transYouGet, math.floor(getCarPrice(model)*0.55) )
		-- refreshTransCarList()
		-- guiSetText(GUI.label.chosenCar, "Выбранный автомобиль:\n"..guiGridListGetItemText(GUI.gridlist.vehList, selectedID, 1).."\n"..guiGridListGetItemText(GUI.gridlist.vehList, selectedID, 2))
		-- guiSetVisible(GUI.window.transCar, true)
		-- guiBringToFront(GUI.window.transCar)
		
	-- elseif (source == GUI.button.transCancel) then
		-- guiSetVisible(GUI.window.transCar, false)
		
	-- elseif (source == GUI.button.transRefresh) then
		-- refreshTransCarList()
		
	-- elseif (source == GUI.button.transOK) then
		-- if not isElementWithinColShape(localPlayer, nomerchangeColshape) then
			-- outputCarSystemError("Невозможно продать автомобиль. Вы и ваш автомобиль должны находиться в центре перерегистрации.")
			-- return
		-- end
		-- local sellerMoney = tonumber(guiGetText(GUI.edit.transYouGet))
		-- local player = guiGridListGetItemData(GUI.gridlist.transPlayers, guiGridListGetSelectedItem(GUI.gridlist.transPlayers))
		-- if (not sellerMoney) then
			-- outputBadMessage("Пожалуста, введите корректную сумму!")
			-- return
		-- end
		-- if (sellerMoney < 0) then
			-- outputBadMessage("Нельзя указывать отрицательную стоимость!")
			-- return
		-- end
		-- if (not player) then
			-- outputBadMessage("Выберите игрока, которому хотите передать бизнес!")
			-- return
		-- end
		-- hideCarWindows()
		-- triggerServerEvent("transCar", resourceRoot, transCarBaseID, player, math.floor(sellerMoney))
		
	-- elseif (source == GUI.button.getOK) then
		-- guiSetVisible(GUI.window.getCar, false)
		-- showCursor(false)
		-- triggerServerEvent("acceptCarOffer", resourceRoot, transCarData)
		-- transCarData = nil
	
	-- elseif (source == GUI.button.getDecline) then
		-- outputCarSystemInfo("Вы отказались покупать "..getVehicleModName(transCarData.Model)..".")
		-- guiSetVisible(GUI.window.getCar, false)
		-- showCursor(false)
		-- triggerServerEvent("declineCarOffer", resourceRoot, transCarData)
		-- transCarData = nil
		
local transCarData, transCarBaseID

	--GUI.label[1] = guiCreateLabel(10, 20, 90, 15, "Продать", false, GUI.window.main)
	--guiLabelSetHorizontalAlign(GUI.label[1], "center", false)
	--guiSetFont(GUI.label[1], "default-bold-small")
	--GUI.button.sellToPlayer = guiCreateButton(10, 35, 90, 20, "Игроку", false, GUI.window.main)
	-- ===================     Продажа игроку     ===================
	-- GUI.window.transCar = guiCreateWindow((screenW-430)/2, (screenH-300)/2, 430, 300, "Передача автомобиля", false)
	-- guiWindowSetSizable(GUI.window.transCar, false)
	-- guiSetAlpha(GUI.window.transCar, 1.00)

	-- GUI.label[1] = guiCreateLabel(10, 25, 200, 105, "Выберите игрока из списка.\nЕсли игрока нет в списке, обновите список.\nИгрок, которому вы хотите продать автомобиль, должен находиться на небольшом расстоянии от вас.", false, GUI.window.transCar)
	-- guiLabelSetHorizontalAlign(GUI.label[1], "center", true)
	-- GUI.gridlist.transPlayers = guiCreateGridList(10, 140, 200, 115, false, GUI.window.transCar)
	-- guiGridListAddColumn(GUI.gridlist.transPlayers, "Игроки", 0.9)
	-- GUI.button.transRefresh = guiCreateButton(10, 265, 130, 25, "Обновить список", false, GUI.window.transCar)
	
	-- GUI.label[2] = guiCreateLabel(220, 25, 200, 45, "Wprowadz kwote, за которую вы хотите продать ваш автомобиль.\nНалог на сделку составляет 5%.", false, GUI.window.transCar)
	-- guiLabelSetHorizontalAlign(GUI.label[2], "center", true)
	-- GUI.label[3] = guiCreateLabel(220, 80, 200, 15, "Вы получите:", false, GUI.window.transCar)
	-- GUI.edit.transYouGet = guiCreateEdit(220, 100, 200, 25, "", false, GUI.window.transCar)
	-- guiEditSetMaxLength(GUI.edit.transYouGet, 10)
	-- GUI.label[4] = guiCreateLabel(220, 135, 200, 15, "Покупатель заплатит:", false, GUI.window.transCar)
	-- GUI.edit.transBuyerSum = guiCreateEdit(220, 155, 200, 25, "", false, GUI.window.transCar)
	-- guiSetProperty(GUI.edit.transBuyerSum, "NormalTextColour", "FF7F7F7F")
	-- guiEditSetReadOnly(GUI.edit.transBuyerSum, true)
	-- GUI.label.chosenCar = guiCreateLabel(220, 190, 200, 45, "Выбранный автомобиль:", false, GUI.window.transCar)
    -- guiLabelSetHorizontalAlign(GUI.label.chosenCar, "center", false)
	-- GUI.button.transOK = guiCreateButton(220, 260, 80, 30, "ОК", false, GUI.window.transCar)
	-- GUI.button.transCancel = guiCreateButton(340, 260, 80, 30, "Отмена", false, GUI.window.transCar)
	
	-- ===================     Покупка у игрока     ===================
	-- GUI.window.getCar = guiCreateWindow((screenW-270)/2, (screenH-255)/2, 270, 255, "Покупка автомобиля", false)
	-- guiWindowSetSizable(GUI.window.getCar, false)

	-- GUI.label.getPlayer = guiCreateLabel(10, 25, 250, 30, "ИГРОК ПИДР предлагает вам купить его автомобиль.", false, GUI.window.getCar)
	-- guiLabelSetHorizontalAlign(GUI.label.getPlayer, "center", true)
	-- GUI.label.getCar = guiCreateLabel(10, 65, 210, 30, "Марка, модель:\nToyota Sprinter Trueno AE86", false, GUI.window.getCar)
	-- GUI.label[6] = guiCreateLabel(220, 65, 40, 15, "Цвет:", false, GUI.window.getCar)
	-- guiLabelSetHorizontalAlign(GUI.label[6], "center", false)
	-- GUI.staticimage.getColor = guiCreateStaticImage(220, 80, 40, 15, ":car_system/color.png", false, GUI.window.getCar)
	-- GUI.label.getLicensep = guiCreateLabel(10, 105, 250, 15, "Номер: |м888мм|88|", false, GUI.window.getCar)  
	-- GUI.label.getYouPay = guiCreateLabel(10, 130, 250, 15, "Вы заплатите: ", false, GUI.window.getCar)
	-- GUI.label.getSellerGet = guiCreateLabel(10, 155, 250, 15, "Продавец получит: ", false, GUI.window.getCar)
	-- GUI.label[5] = guiCreateLabel(10, 185, 250, 15, "Вы подтверждаете покупку?", false, GUI.window.getCar)
	-- guiLabelSetHorizontalAlign(GUI.label[5], "center", false)
	-- guiSetFont(GUI.label[5], "default-bold-small")
	-- GUI.button.getOK = guiCreateButton(10, 210, 120, 35, "Подтверждаю", false, GUI.window.getCar)
	-- guiSetProperty(GUI.button.getOK, "NormalTextColour", "FF1EFF1E")
	-- guiSetFont(GUI.button.getOK, "default-bold-small")
	-- GUI.button.getDecline = guiCreateButton(140, 210, 119, 35, "Отказываюсь", false, GUI.window.getCar)
	-- guiSetProperty(GUI.button.getDecline, "NormalTextColour", "FFFF1E1E")
	-- guiSetFont(GUI.button.getDecline, "default-bold-small")
	
	-- guiSetVisible(GUI.window.getCar, false)
	-- guiSetVisible(GUI.window.transCar, false)
	
	-- {
		-- cars = {
			-- {597, "Ford Crown Victoria Police", 99999999},
			-- {525, "Эвакуатор", 99999999},
			-- {497, "Police Helicopter", 99999999}
		-- },
		-- mrkPosX = 3308.304688, mrkPosY = -7345.272461, mrkPosZ = 22.46073,
		-- vehPosX = 3321.358398, vehPosY = -7357.416016, vehPosZ = 23.370419,
		-- camX = 3325.529297, camY = -7347.50293, camZ = 25.817095,
		-- lookAtX = 3321.358398, lookAtY = -7357.416016, lookAtZ = 23.370419,
		-- spwnPosX = 3452.795898, spwnPosY = -7368.02832, spwnPosZ = 33.424221, spwnRotZ = 0,
		-- licensep = "h-ADMIN"
	-- }


function SpecVehicle(id)
	if spc then 
		removeEventHandler("onClientPreRender", root, Sp)
		setCameraTarget(localPlayer)
		if isTimer(freezTimer) then killTimer(freezTimer) end
		freezTimer = setTimer(function() setElementFrozen(localPlayer, false) end, 2500, 1)
		spc = false
	return end
	for i, vehicle in ipairs(getElementsByType("vehicle")) do
		if getElementData(vehicle, "Owner") == localPlayer and getElementData(vehicle, "ID") == id then
			cVeh = vehicle
			spc = true
			addEventHandler("onClientPreRender", root, Sp)
			guiSetVisible(GUI.window.main, false)
			showCursor(false)
			break
		  end
	end
end
function Sp()
	if isElement(cVeh) then
		local x, y, z = getElementPosition(cVeh)
		setElementFrozen(localPlayer, true)
		setCameraMatrix(x, y-1, z+15, x, y, z)
	else
		removeEventHandler("onClientPreRender", root, Sp)
		setCameraTarget(localPlayer)
		if isTimer(freezTimer) then killTimer(freezTimer) end
		freezTimer = setTimer(function() setElementFrozen(localPlayer, false) end, 2500, 1)
		spc = false
      end
end

addCommandHandler("xx", function()
	local x, y, z, lx, ly, lz = getCameraMatrix()
	setCameraMatrix(x, y, z, lx, ly, lz)
	outputChatBox(x..", "..y..", "..z..", "..lx..", "..ly..", "..z)
end)



-- Какой баг исправляется этой штукой???
-- Эта штука создает зону вокруг будочки возле полицейского участка в ЛС. Если в ней находиться, то:
-- 1. у тебя не будут происходить взрывы в любом месте
-- 2. ты не сможешь спавнить и телепортировать авто
BlockCreateInPolice = createColCuboid (  1573.84900, -1637.5, 12, 10, 6, 6  )
setElementData(root, "BlockExportCol", BlockCreateInPolice)
setTimer(
	function ()
		local theCol = getElementData(root, "BlockExportCol")	
		function isInColExport()
			if isElement(theCol) and isElementWithinColShape(localPlayer, theCol) then
				return true
			else
				return false
			end
		end
		function ClientExplosionCFunction()
			if isInColExport()  then
				cancelEvent()
			end
		end
		addEventHandler("onClientExplosion", root, ClientExplosionCFunction)
	end, 
1000, 1 )

]]