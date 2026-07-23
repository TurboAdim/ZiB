PDWorkers = {}
PDLights = {}
PlacedObjects = {}
TowVehicles = {}
ServerCalls = {}
RandomEvents = {}
UsedTreeLocations = {}
PDPrivateBlips = {}

----------------------------------------------------
-- NUMERY ZGŁOSZEŃ
----------------------------------------------------

PDCallCounter = 0

function generatePDCallID()

    PDCallCounter = PDCallCounter + 1

    return string.format(
        "PD-%s-%04d",
        getRealTime().year + 1900,
        PDCallCounter
    )

end

function registerPDCall(vehicle, player, reportType)

    if not isElement(vehicle) then
        return false
    end

    local callID = generatePDCallID()

    setElementData(vehicle, "pd:callID", callID)
    setElementData(vehicle, "pd:reportedBy", isElement(player) and getPlayerName(player) or "SYSTEM")
    setElementData(vehicle, "pd:reportTime", getRealTime().timestamp)
    setElementData(vehicle, "pd:reportType", reportType or "Nieznany")
    setElementData(vehicle, "pd:isTowed", false)
    setElementData(vehicle, "pd:isSecured", false)

    return callID
end

----------------------------------------------------
-- TEAM
----------------------------------------------------

local pdTeam = getTeamFromName("Pomoc Drogowa")

if not pdTeam then

    pdTeam = createTeam(
        "Pomoc Drogowa",
        255,140,0
    )

end

local pdRespawnPos = {1668.5778808594,2198.0649414062,10.8203125}



function getPDPlayers()
    return getPlayersInTeam(pdTeam)
end

function outputPDChat(text, r, g, b)
    for _, player in ipairs(getPDPlayers()) do
        outputChatBox(text, player, r or 255, g or 255, b or 255)
    end
end

----------------------------------------------------
-- BLIP TYLKO DLA PD
----------------------------------------------------
--[[function createPDOnlyBlip(element, icon)

    local blips = {}

    for _,player in ipairs(getPlayersInTeam(pdTeam)) do

        local blip = createBlipAttachedTo(
            element,
            icon or 27,
            2,
            255,140,0,
            255,
            0,
            99999,
            player
        )

        table.insert(blips, blip)

    end

    return blips
end--]]


function createPDVehicle(model,x,y,z,rx,ry,rz)

    local veh

    if tonumber(model) > 611 then

        veh = exports["newmodels_red"]:createVehicle(
            tonumber(model),
            x,y,z
        )

        -- ZAPIS PRAWDZIWEGO MODELU
        setElementData(veh, "pd:customModel", tonumber(model))

    else

        veh = createVehicle(
            tonumber(model),
            x,y,z
        )

        setElementData(veh, "pd:customModel", tonumber(model))

    end

    if not veh then
        return false
    end

    -------------------------------------------------
    -- ROTACJA
    -------------------------------------------------

    setElementRotation(
        veh,
        rx or 0,
        ry or 0,
        rz or 0
    )

    -------------------------------------------------
    -- KOLOR POJAZDU
    -------------------------------------------------

    setVehicleColor(
        veh,
        255,140,0, -- kolor 1
        0,0,0      -- kolor 2
    )

    return veh
end

--[[function createPDOnlyBlip(element, icon)

    local workers = getPlayersInTeam(pdTeam)

    if #workers <= 0 then
        return false
    end

    local visibleTo = {}

    for _,player in ipairs(workers) do
        table.insert(visibleTo, player)
    end

    local blip = createBlipAttachedTo(
        element,
        icon or 27,
        2,
        255,140,0,
        255,
        0,
        99999,
        visibleTo
    )

    return blip
end--]]
--[[function createPDOnlyBlip(element)
    local players = getPDPlayers()

    local blip = createBlipAttachedTo(
        element,
        27,
        2,
        255,140,0,
        255,
        0,
        99999,
        players
    )

    return blip
end--]]
function createPDOnlyBlip(element)
    local blip = createBlipAttachedTo(element, 27)

    for _, player in ipairs(getPDPlayers()) do
        setElementVisibleTo(blip, player, true)
    end

    setElementVisibleTo(blip, root, false)

    return blip
end




----------------------------------------------------
-- MARKER
----------------------------------------------------

local marker = createMarker(
    Config.Marker[1],
    Config.Marker[2],
    Config.Marker[3],
    "cylinder",
    2,
    255,140,0,150
)

setElementData(marker,"pd:marker",true)

createBlipAttachedTo(marker,27)

----------------------------------------------------
-- VEHICLE
----------------------------------------------------

--[[function createPDVehicle(model,x,y,z,rx,ry,rz)

    local veh

    if tonumber(model) > 611 then

        veh = exports["newmodels_red"]:createVehicle(
            tonumber(model),
            x,y,z
        )

        -- ZAPIS PRAWDZIWEGO MODELU
        setElementData(veh, "pd:customModel", tonumber(model))

    else

        veh = createVehicle(
            tonumber(model),
            x,y,z
        )

        setElementData(veh, "pd:customModel", tonumber(model))

    end

    setElementRotation(
        veh,
        rx or 0,
        ry or 0,
        rz or 0
    )

    return veh
end--]]

----------------------------------------------------
-- SKIN
----------------------------------------------------

function setPDSkin(player,skin)

    if tonumber(skin) > 311 then

        exports["newmodels_red"]:setElementModel(
            player,
            tonumber(skin)
        )

    else

        setElementModel(
            player,
            tonumber(skin)
        )

    end
end

----------------------------------------------------
-- GUI
----------------------------------------------------

addEvent("pd:openGUI",true)
addEventHandler("pd:openGUI",root,
function()

    triggerClientEvent(
        client,
        "pd:loadGUI",
        resourceRoot,
        Config.Vehicles,
        Config.Skins
    )

end)

----------------------------------------------------
-- START JOB
----------------------------------------------------

addEvent("pd:startJob",true)
addEventHandler("pd:startJob",root,
function(vehicleID,skinID)

    local player = client

    local vehData = Config.Vehicles[vehicleID]
    local skinData = Config.Skins[skinID]

    if not vehData or not skinData then
        return
    end

    local spawn = Config.Spawns[math.random(#Config.Spawns)]

    local oldSkin = getElementModel(player)


    local veh = createPDVehicle(
    vehData.model,
    spawn[1],
    spawn[2],
    spawn[3],
    spawn[4] or 0,
    spawn[5] or 0,
    spawn[6] or 0
)

    setVehicleDamageProof(veh,true)
    setVehicleEngineState(veh,true)

    warpPedIntoVehicle(player,veh)

    setPDSkin(player,skinData.skin)

    PDWorkers[player] = {

        vehicle = veh,
        oldSkin = oldSkin,
        oldTeam = getPlayerTeam(player)

    }

    setPlayerTeam(player,pdTeam)

    setElementData(player,"pd:duty",true)

    triggerClientEvent(
        player,
        "pd:setWorking",
        resourceRoot,
        true
    )

    outputChatBox(
        "Pracownik Pomocy Drogowej rozpoczął pracę.",
        root,
        255,255,0
    )
	refreshPDBlips()

end)


addCommandHandler("pojazd.przywolaj",
    function(player)

        if getPlayerTeam(player) ~= pdTeam then
            return
        end

        if not PDWorkers[player] or not isElement(PDWorkers[player].vehicle) then
            outputChatBox("Nie masz przypisanego pojazdu.", player, 255, 0, 0)
            return
        end

        local veh = PDWorkers[player].vehicle

        local x, y, z = getElementPosition(player)
        local _, _, rot = getElementRotation(player)

        setElementPosition(veh, x + 2, y + 2, z)
        setElementRotation(veh, 0, 0, rot)

        setVehicleEngineState(veh, true)
        setVehicleLocked(veh, false)

        outputChatBox("Przywołano pojazd służbowy.", player, 0, 255, 0)
		
		if vehicleCallCooldown[player] and getTickCount() - vehicleCallCooldown[player] < 30000 then
           outputChatBox("Poczekaj chwilę przed kolejnym przywołaniem.", player, 255, 0, 0)
           return
        end
        vehicleCallCooldown[player] = getTickCount()
    end
)


----------------------------------------------------
-- STOP JOB
----------------------------------------------------

function stopPDJob(player)
    if not PDWorkers[player] then return end

    local data = PDWorkers[player]

    -- lights OFF
    if PDLights[player] then
        for _, marker in ipairs(PDLights[player]) do
            if isElement(marker) then destroyElement(marker) end
        end
        PDLights[player] = nil
    end

    -- vehicle cleanup
    if data.vehicle and isElement(data.vehicle) then
        destroyElement(data.vehicle)
    end

    if data.oldSkin then

    if tonumber(data.oldSkin) > 311 then

        exports["newmodels_red"]:setElementModel(
            player,
            tonumber(data.oldSkin)
        )

    else

        setElementModel(
            player,
            tonumber(data.oldSkin)
        )

    end

end

    setElementData(player, "pd:duty", false)

    --setPlayerTeam(player, getTeamFromName("ZMIENNY23 - Gracze"))
	if data.oldTeam then
       setPlayerTeam(player,data.oldTeam)
    end
	
    triggerClientEvent(player, "pd:setWorking", resourceRoot, false)

    PDWorkers[player] = nil
	refreshPDBlips()
end





----------------------------------------------------
-- PACHOLKI / BARIERKI
----------------------------------------------------

addCommandHandler("pacholek",
function(player)

    if getPlayerTeam(player) ~= pdTeam then
        return
    end

    local x,y,z = getElementPosition(player)

    local obj = createObject(
        1238,
        x,y,z-0.7
    )

    PlacedObjects[player] =
        PlacedObjects[player] or {}

    table.insert(
        PlacedObjects[player],
        obj
    )

end)

addCommandHandler("barierka",
function(player)

    if getPlayerTeam(player) ~= pdTeam then
        return
    end

    local x,y,z = getElementPosition(player)

    local obj = createObject(
        1237,
        x,y,z-1
    )

    PlacedObjects[player] =
        PlacedObjects[player] or {}

    table.insert(
        PlacedObjects[player],
        obj
    )

end)

----------------------------------------------------
-- USUWANIE
----------------------------------------------------

addCommandHandler("usunobiekty",
function(player)

    if not PlacedObjects[player] then
        return
    end

    for _,obj in ipairs(PlacedObjects[player]) do

        if isElement(obj) then
            destroyElement(obj)
        end

    end

    PlacedObjects[player] = {}

end)

----------------------------------------------------
-- UTRUDNIENIA
----------------------------------------------------

addCommandHandler("utrudnienia",
function(player,...)

    if getPlayerTeam(player) ~= pdTeam then
        return
    end

    local text = table.concat({...}," ")

    outputChatBox(
        "[POMOC DROGOWA] Odnotowano utrudnienia w ruchu drogowym: "..text,
        root,
        255,255,0
    )

end)

local allowedTeams = {
    ["Pomoc Drogowa"] = true,
    ["Policja"] = true,
    ["Straż Pożarna"] = true
}

local function canSecure(player)
    local team = getPlayerTeam(player)

    if not team then
        return false
    end

    return allowedTeams[getTeamName(team)] == true
end

addCommandHandler("zabezpiecz",
function(player)

    if not canSecure(player) then
        return
    end

    local px,py,pz = getElementPosition(player)

    local nearestVehicle = nil
    local nearestDist = 5

    for _,veh in ipairs(getElementsByType("vehicle")) do

        local vx,vy,vz = getElementPosition(veh)

        local dist =
            getDistanceBetweenPoints3D(
                px,py,pz,
                vx,vy,vz
            )

        if dist < nearestDist then
            nearestDist = dist
            nearestVehicle = veh
        end
    end

    if not nearestVehicle then
        return
    end

    setElementData(nearestVehicle,"securedVehicle",true)

    setVehicleLocked(nearestVehicle,true)
    setElementFrozen(nearestVehicle,true)

    outputChatBox(
        "Pojazd został zabezpieczony.",
        player,
        0,255,0
    )

end)

addCommandHandler("odbezpiecz",
function(player)

    if not canSecure(player) then
        return
    end

    local px,py,pz = getElementPosition(player)

    for _,veh in ipairs(getElementsByType("vehicle")) do

        local vx,vy,vz = getElementPosition(veh)

        local dist =
            getDistanceBetweenPoints3D(
                px,py,pz,
                vx,vy,vz
            )

        if dist <= 5 and getElementData(veh,"securedVehicle") then

            removeElementData(
                veh,
                "securedVehicle"
            )

            setVehicleLocked(veh,false)
            setElementFrozen(veh,false)

            outputChatBox(
                "Pojazd został odbezpieczony.",
                player,
                255,255,0
            )

            break
        end
    end

end)


function getVehicleCustomValue(vehicle)

    if not isElement(vehicle) then
        return 0
    end

    local model =
        getElementData(
            vehicle,
            "pd:customModel"
        )

    if not model then
        model = getElementModel(vehicle)
    end

    return Config.VehicleValues[model] or 1000
end


addCommandHandler("wycena",
function(player)

    local px,py,pz =
        getElementPosition(player)

    local nearestVehicle = nil
    local nearestDist = 5

    for _,veh in ipairs(
        getElementsByType("vehicle")
    ) do

        local vx,vy,vz =
            getElementPosition(veh)

        local dist =
            getDistanceBetweenPoints3D(
                px,py,pz,
                vx,vy,vz
            )

        if dist < nearestDist then

            nearestDist = dist
            nearestVehicle = veh

        end
    end

    if not nearestVehicle then
        return
    end

    local value =
        getVehicleCustomValue(
            nearestVehicle
        )

    outputChatBox(
        "Szacowana wartość pojazdu: $"..value,
        player,
        255,255,0
    )

end)

----------------------------------------------------
-- AWARIE AKUMULATORA
----------------------------------------------------

BrokenBatteryVehicles = {}
UsedBatteryLocations = {}

function createBatteryEvent()

    local players = getElementsByType("player")

    if #players <= 0 then
        return
    end

    ----------------------------------------------------
    -- WOLNE LOKALIZACJE
    ----------------------------------------------------

    local freeLocations = {}

    for index,data in ipairs(Config.BatteryEvents) do

        if not UsedBatteryLocations[index] then

            table.insert(freeLocations,{
                index = index,
                data = data
            })

        end

    end

    if #freeLocations <= 0 then
        return
    end

    ----------------------------------------------------
    -- LOSOWANIE
    ----------------------------------------------------

    local selected =
        freeLocations[
            math.random(#freeLocations)
        ]

    local eventData = selected.data
    local locationIndex = selected.index

    ----------------------------------------------------
    -- CREATE VEHICLE
    ----------------------------------------------------

local veh = createPDVehicle(
    eventData.model,
    eventData.x,
    eventData.y,
    eventData.z,
    eventData.rx,
    eventData.ry,
    eventData.rz
)


    setVehicleDamageProof(veh,true)
    setElementFrozen(veh,true)
    setVehicleLocked(veh,true)
    setVehicleEngineState(veh,false)

    setElementData(
        veh,
        "pd:brokenBattery",
        true
    )

    local blip = createPDOnlyBlip(veh)
	--local blip = createPDOnlyBlip(veh,27)
	--createPDOnlyBlip(veh)
	
    BrokenBatteryVehicles[veh] = {
        blip = blip,
        locationIndex = locationIndex
    }

    UsedBatteryLocations[locationIndex] = true

    --outputChatBox("[SERWER] Zgłoszono rozładowany pojazd: "..eventData.name,root,255,140,0)
	--outputPDChat("[POMOC DROGOWA] Zgłoszono rozładowany pojazd: "..eventData.name,255,140,0
    local callID = generatePDCallID()

    BrokenBatteryVehicles[veh].callID = callID

    outputPDChat("[POMOC DROGOWA]["..callID.."] Rozładowany pojazd: "..eventData.name,255,140,0)
end

setTimer(
    createBatteryEvent,
    350000,
    0
)

----------------------------------------------------
-- BLOKADA WEJŚCIA
----------------------------------------------------

addEventHandler("onVehicleStartEnter", root,
function(player)

    if getElementData(source,"pd:brokenBattery") then
        cancelEvent()
    end

end)

----------------------------------------------------
-- ODPALANIE AKUMULATORA
----------------------------------------------------

addCommandHandler("odpal",
function(player)

    if getPlayerTeam(player) ~= pdTeam then
        return
    end

    local towVeh = getPedOccupiedVehicle(player)

    if towVeh then
        outputChatBox(
            "Wyjdź z pojazdu.",
            player,
            255,0,0
        )
        return
    end

    local px,py,pz =
        getElementPosition(player)

    for veh,data in pairs(BrokenBatteryVehicles) do

        if isElement(veh) then

            local vx,vy,vz =
                getElementPosition(veh)

            local dist =
                getDistanceBetweenPoints3D(
                    px,py,pz,
                    vx,vy,vz
                )

            if dist <= 4 then

                local nearestVeh = nil
                local nearestDist = 999

                for _,vehicle in ipairs(
                    getElementsByType("vehicle")
                ) do

                    if vehicle ~= veh then

                        local x,y,z =
                            getElementPosition(vehicle)

                        local d =
                            getDistanceBetweenPoints3D(
                                x,y,z,
                                vx,vy,vz
                            )

                        if d < nearestDist then
                            nearestDist = d
                            nearestVeh = vehicle
                        end

                    end

                end

                if not nearestVeh then
                    return
                end

                if nearestDist > 40 then

                    outputChatBox(
                        "Brak pojazdu PD obok auta.",
                        player,
                        255,0,0
                    )
					
					outputChatBox("Musisz ustawić pojazd Pomocy Drogowej przy rozładowanym aucie (przód do przodu).",player,255,0,0)
                    return
                end

                ----------------------------------------------------
                -- SPRAWDZANIE TEAMU
                ----------------------------------------------------

                local valid = false

                for _,dataPD in pairs(PDWorkers) do

                    if dataPD.vehicle == nearestVeh then
                        valid = true
                        break
                    end

                end

                if not valid then

                    outputChatBox(
                        "To nie jest pojazd Pomocy Drogowej.",
                        player,
                        255,0,0
                    )

                    return
                end

                ----------------------------------------------------
                -- MINIGRA
                ----------------------------------------------------

                activeBatteryVehicle = veh
				
				setElementData(veh, "pd:batteryInProgress", player)
                triggerClientEvent(player,"pd:startBatteryMinigame",resourceRoot,veh)

                outputChatBox("Podłączono pojazdy poprawnie. Możesz rozpocząć naprawę akumulatora!",player,0,255,0)

                return

            end
        end
    end

end)


----------------------------------------------------
-- LOSOWE DRZEWA
----------------------------------------------------

function createRandomTreeEvent()

    local players = getElementsByType("player")

    if #players <= 0 then
        return
    end

    ----------------------------------------------------
    -- SZUKANIE WOLNEJ LOKALIZACJI
    ----------------------------------------------------

    local freeLocations = {}

    for index,data in ipairs(Config.RandomTrees) do

        if not UsedTreeLocations[index] then
            table.insert(freeLocations, {
                index = index,
                data = data
            })
        end

    end

    ----------------------------------------------------
    -- BRAK WOLNYCH
    ----------------------------------------------------

    if #freeLocations <= 0 then
        return
    end

    ----------------------------------------------------
    -- LOSOWANIE
    ----------------------------------------------------

    local selected =
        freeLocations[
            math.random(#freeLocations)
        ]

    local random = selected.data
    local locationIndex = selected.index

    ----------------------------------------------------
    -- CREATE TREE
    ----------------------------------------------------

    local tree = createObject(
    Config.TreeModel,
    random.x,
    random.y,
    random.z,
    random.rx or 90,
    random.ry or 0,
    random.rz or 0
    )
	
	
	local blip = createPDOnlyBlip(tree)
    --local blip = createPDOnlyBlip(tree,27)
	--createPDOnlyBlip(tree)
	
    RandomEvents[tree] = {
        blip = blip,
        place = data.place,
        locationIndex = locationIndex
    }

    UsedTreeLocations[locationIndex] = true

    --outputChatBox("[SERWER] Odnotowano powalone drzewo: "..data.place,root,255,140,0)
	outputPDChat(
    "[POMOC DROGOWA] Odnotowano powalone drzewo: "..data.place,
    255,140,0
)
end

setTimer(
    createRandomTreeEvent,
    215000,
    0
)

----------------------------------------------------
-- NAPRAWA
----------------------------------------------------

addCommandHandler("napraw",
function(player)

    if getPlayerTeam(player) ~= pdTeam then
        return
    end

    local weapon = getPedWeapon(player)

    if weapon ~= 9 then
        outputChatBox(
            "Musisz trzymać piłę łańcuchową.",
            player,
            255,0,0
        )
        return
    end

    local px,py,pz =
        getElementPosition(player)

    for obj,data in pairs(RandomEvents) do

        if isElement(obj) then

            local x,y,z =
                getElementPosition(obj)

            local dist =
                getDistanceBetweenPoints3D(
                    px,py,pz,
                    x,y,z
                )

            if dist <= 5 then

                setPedAnimation(
                    player,
                    "CHAINSAW",
                    "CSAW_G",
                    5000,
                    true,
                    false,
                    false
                )

                toggleAllControls(
                    player,
                    false
                )

                setTimer(function()

                    if isElement(obj) then
                        destroyElement(obj)
                    end

                    if isElement(data.blip) then
                        destroyElement(data.blip)
                    end

                    toggleAllControls(
                        player,
                        true
                    )

                    setPedAnimation(player,false)

                    outputChatBox(
                        "Zadanie ukończone.",
                        player,
                        0,255,0
                    )

                    --outputChatBox("[SERWER] Zagrożenie usunięte: Powalone Drzewo",root,255,255,0)
					local callID = generatePDCallID()

                    RandomEvents[obj].callID = callID
					--RandomEvents[tree].callID = callID
                    
                    outputPDChat("[POMOC DROGOWA]["..callID.."] Powalone drzewo: "..data.place,255,140,0
)

                    if data.locationIndex then
                       UsedTreeLocations[data.locationIndex] = nil
                    end

                    RandomEvents[obj] = nil

                end,5000,1)

                break
            end
        end
    end
end)

----------------------------------------------------
-- WEZWANIE
----------------------------------------------------

addCommandHandler("wezwij.pd",
function(player)
    
	local callID = generatePDCallID()
	
    local workers =
        getPlayersInTeam(pdTeam)

    if #workers <= 0 then

        outputChatBox(
            "Brak pracowników Pomocy Drogowej na serwerze.",
            player,
            255,0,0
        )

        return
    end

    local x,y,z =
        getElementPosition(player)

    local blip =
        createBlipAttachedTo(
            player,
            27
        )

    setTimer(function()

        if isElement(blip) then
            destroyElement(blip)
        end

    end,60000,1)

    for _,p in ipairs(workers) do

    outputChatBox(
        "[ZGŁOSZENIE "..callID.."] Gracz "..getPlayerName(player).." wzywa Pomoc Drogową.",
        p,
        255,255,0
    )

end

    outputChatBox(
    "Zgłoszenie "..callID.." zostało wysłane.",
    player,
    0,255,0
)

end)

----------------------------------------------------
-- PANEL
----------------------------------------------------

addEvent("pd:getWeapons",true)
addEventHandler("pd:getWeapons",root,
function()

    local player = client

    if getPlayerTeam(player) ~= pdTeam then
        return
    end

    giveWeapon(player,9,9999)
    giveWeapon(player,6,9999)

    outputChatBox(
        "Otrzymałeś wyposażenie.",
        player,
        0,255,0
    )

end)



--[[addEvent("pd:toggleLights", true)
addEventHandler("pd:toggleLights", root,
function()
    local player = client
    if not PDWorkers[player] then return end

    local veh = PDWorkers[player].vehicle
    if not isElement(veh) then return end

    if getVehicleOccupant(veh, 0) ~= player then
        outputChatBox("Musisz siedzieć za kierownicą.", player, 255,0,0)
        return
    end

    if PDLights[player] then
        for _,m in ipairs(PDLights[player]) do
            if isElement(m) then destroyElement(m) end
        end
        PDLights[player] = nil
        setElementData(veh, "pd:lights", false)
        return
    end

    PDLights[player] = {}

    local vehModel = getElementData(veh, "pd:customModel") or getElementModel(veh)

    local cfg = Config.Strobes[vehModel]
    if not cfg then return end

    local colorIndex = 1

    for _,off in ipairs(cfg.offsets) do
        local col = cfg.colors[colorIndex] or {255,255,0}

        local marker = createMarker(0,0,0,"corona",0.25,col[1],col[2],col[3],220)
        attachElements(marker, veh, off[1], off[2], off[3])

        setElementData(marker, "pd:lightColor", col)
        table.insert(PDLights[player], marker)

        colorIndex = colorIndex + 1
        if colorIndex > #cfg.colors then colorIndex = 1 end
    end

    setElementData(veh, "pd:lights", true)
end)--]]

addEvent("pd:toggleLights", true)
addEventHandler("pd:toggleLights", root,
function()
    local player = client

    if not PDWorkers[player] then
        return
    end

    local veh = PDWorkers[player].vehicle

    if not isElement(veh) then
        return
    end

    -- tylko kierowca może przełączać
    if getVehicleOccupant(veh, 0) ~= player then
        return
    end

    if PDLights[player] then

        for _,m in ipairs(PDLights[player]) do
            if isElement(m) then
                destroyElement(m)
            end
        end

        PDLights[player] = nil
        setElementData(veh, "pd:lights", false)

        return
    end

    local vehModel =
        getElementData(veh, "pd:customModel")
        or getElementModel(veh)

    local cfg = Config.Strobes[vehModel]

    if not cfg then
        return
    end

    PDLights[player] = {}

    local colorIndex = 1

    for _,off in ipairs(cfg.offsets) do

        local col =
            cfg.colors[colorIndex]
            or {255,255,0}

        local marker = createMarker(
            0,0,0,
            "corona",
            0.25,
            col[1],
            col[2],
            col[3],
            220
        )

        attachElements(
            marker,
            veh,
            off[1],
            off[2],
            off[3]
        )

        setElementData(
            marker,
            "pd:lightColor",
            col
        )

        table.insert(
            PDLights[player],
            marker
        )

        colorIndex = colorIndex + 1

        if colorIndex > #cfg.colors then
            colorIndex = 1
        end
    end

    setElementData(veh, "pd:lights", true)

end)




addEvent("pd:stopJob", true)
addEventHandler("pd:stopJob", root,
function()
    local player = client
    if not isElement(player) then return end
    stopPDJob(player)
end)


addEventHandler("onPlayerQuit", root,
function()

    if PDWorkers[source] then
        stopPDJob(source)
    end

end)



----------------------------------------------------
-- NAPRAWA AKUMULATORA
----------------------------------------------------

local activeBatteryVehicle = nil

addEvent("pd:finishBatteryRepair", true)
addEventHandler("pd:finishBatteryRepair", root,
function(vehicle)

    local player = client

    -- 🔒 ANTI EXPLOIT CHECK
    if not isElement(player) then return end
    if not isElement(vehicle) then return end
    if not getElementData(vehicle, "pd:brokenBattery") then return end

    -- 🔥 SECURITY: sprawdź czy gracz faktycznie jest w pobliżu auta
    local px, py, pz = getElementPosition(player)
    local vx, vy, vz = getElementPosition(vehicle)

    if getDistanceBetweenPoints3D(px, py, pz, vx, vy, vz) > 6 then
        return
    end

    setVehicleEngineState(vehicle, true)
    setElementFrozen(vehicle, false)

    removeElementData(vehicle, "pd:brokenBattery")

    givePlayerMoney(player, 500)

    outputChatBox(
        "Akumulator został naładowany",
        player,
        0,255,0
    )

    if BrokenBatteryVehicles[vehicle] then
       local data = BrokenBatteryVehicles[vehicle]

       if isElement(data.blip) then
           destroyElement(data.blip)
       end

       if data.locationIndex then
           UsedBatteryLocations[data.locationIndex] = nil
       end

       BrokenBatteryVehicles[vehicle] = nil
    end

--givePlayerMoney(player, 500)

destroyElement(vehicle)

end)







addEventHandler("onPlayerTeamChange", root,
function()
    setTimer(refreshPDBlips,1000,1)
end)


addEventHandler("onResourceStop", resourceRoot,
function()

    for veh, data in pairs(BrokenBatteryVehicles) do
        if isElement(veh) then destroyElement(veh) end
        if data.blip and isElement(data.blip) then destroyElement(data.blip) end
    end

    BrokenBatteryVehicles = {}

end)

addEventHandler("onResourceStart", resourceRoot,
function()

    for _, veh in ipairs(getElementsByType("vehicle")) do
        if getElementData(veh, "pd:brokenBattery") then
            destroyElement(veh)
        end
    end

    BrokenBatteryVehicles = {}
    UsedBatteryLocations = {}

end)


----------------------------------------------------
-- REFRESH BLIPÓW
----------------------------------------------------

function refreshPDBlips()

    local workers = getPlayersInTeam(pdTeam)

    ----------------------------------------------------
    -- AKUMULATORY
    ----------------------------------------------------

    for veh,data in pairs(BrokenBatteryVehicles) do

        if isElement(data.blip) then
            destroyElement(data.blip)
        end

        data.blip = createPDOnlyBlip(veh)

    end

    ----------------------------------------------------
    -- DRZEWA
    ----------------------------------------------------

    for obj,data in pairs(RandomEvents) do

        if isElement(data.blip) then
            destroyElement(data.blip)
        end

        data.blip = createPDOnlyBlip(obj)

    end

end

----------------------------------------------------
-- LAWETA
----------------------------------------------------

local towMarker = createMarker(
    Config.Towyard.x,
    Config.Towyard.y,
    Config.Towyard.z - 1,
    "cylinder",
    4,
    255,
    140,
    0,
    150
)

createBlip(
    Config.Towyard.x,
    Config.Towyard.y,
    Config.Towyard.z,
    51
)

function getNearestVehicle(player)

    local px, py, pz = getElementPosition(player)

    local nearest = nil
    local distance = 999

    for _, veh in ipairs(getElementsByType("vehicle")) do

        local vx, vy, vz = getElementPosition(veh)

        local dist = getDistanceBetweenPoints3D(
            px, py, pz,
            vx, vy, vz
        )

        if dist < distance then
            distance = dist
            nearest = veh
        end
    end

    return nearest, distance
end

addCommandHandler("laduj.pojazd", function(player)

    if getPlayerTeam(player) ~= pdTeam then
        return
    end

    local towTruck = getPedOccupiedVehicle(player)
    if not towTruck then
        return
    end

    --local model = getElementData(towTruck, "pd:customModel") or getElementModel(towTruck)
	--local model = tonumber(getElementData(towTruck, "pd:customModel") or getElementModel(towTruck))
	--local model = tonumber(getElementData(towTruck, "pd:customModel"))
	local model = getElementModel(towTruck)
	
    if not Config.TowTruckModels[model] then
        outputChatBox("To nie jest laweta (model: "..tostring(model)..")", player, 255, 0, 0)
        return
    end

    if TowVehicles[towTruck] then
        outputChatBox("Na lawecie jest już pojazd.", player, 255, 0, 0)
        return
    end

    local nearest, dist = getNearestVehicle(player)

    if not nearest then
        return
    end

    if nearest == towTruck then
        return
    end

    if dist > 8 then
        outputChatBox("Brak pojazdu do załadowania.", player, 255, 0, 0)
        return
    end

    setElementFrozen(nearest, true)

    local occupant = getVehicleOccupant(nearest, 0)
    if occupant then
        removePedFromVehicle(occupant)
    end

    attachElements(
        nearest,
        towTruck,
        Config.TowAttachOffset.x,
        Config.TowAttachOffset.y,
        Config.TowAttachOffset.z
    )

    TowVehicles[towTruck] = {
        vehicle = nearest,
        loadedAt = { getElementPosition(nearest) }
    }

    outputChatBox("Pojazd załadowany.", player, 0, 255, 0)

end)

addCommandHandler("rozladuj.pojazd", function(player)

    if getPlayerTeam(player) ~= pdTeam then
        return
    end

    local towTruck = getPedOccupiedVehicle(player)
    if not towTruck then
        return
    end

    local data = TowVehicles[towTruck]
    if not data then
        return
    end

    local veh = data.vehicle
    if not isElement(veh) then
        return
    end

    detachElements(veh)

    local x, y, z = getElementPosition(towTruck)
    local _, _, rz = getElementRotation(towTruck)

    local offset = 7

    local nx = x - math.sin(math.rad(rz)) * offset
    local ny = y + math.cos(math.rad(rz)) * offset

    setElementPosition(veh, nx, ny, z)
    setElementFrozen(veh, false)

    TowVehicles[towTruck] = nil

    outputChatBox("Pojazd rozładowany.", player, 0, 255, 0)

end)

addEventHandler("onMarkerHit", towMarker,

function(vehicle)

    if getElementType(vehicle) ~= "vehicle" then
        return
    end

    if getElementModel(vehicle) ~= 525 then
        return
    end

    local driver = getVehicleOccupant(vehicle)

    if not driver then
        return
    end

    if getPlayerTeam(driver) ~= pdTeam then
        return
    end

    local towed = getVehicleTowedByVehicle(vehicle)

    if not isElement(towed) then
        outputChatBox(
            "Nie holujesz żadnego pojazdu.",
            driver,
            255,0,0
        )
        return
    end

    local model =
        getElementData(towed,"pd:customModel")
        or
        getElementModel(towed)

    local reward =
        Config.VehicleValues[model]
        or
        5000

    destroyElement(towed)

    givePlayerMoney(driver,reward)

    outputChatBox(
        "Pojazd przekazano na Tow Yard. Otrzymujesz $"..reward,
        driver,
        0,255,0
    )

end)

----------------------------------------------------
-- OCENA SZKODY
----------------------------------------------------

function getVehicleDamageRating(vehicle)

    local hp = getElementHealth(vehicle)

    if hp >= 950 then

        return "Idealny", 1.0

    elseif hp >= 800 then

        return "Lekko uszkodzony", 1.1

    elseif hp >= 600 then

        return "Uszkodzony", 1.25

    elseif hp >= 400 then

        return "Poważnie uszkodzony", 1.5

    else

        return "Wrak", 2.0

    end

end

----------------------------------------------------
-- DIAGNOZA
----------------------------------------------------

addCommandHandler("diagnoza",
function(player)

    local px,py,pz =
        getElementPosition(player)

    local nearestVehicle = nil
    local nearestDist = 5

    for _,veh in ipairs(
        getElementsByType("vehicle")
    ) do

        local vx,vy,vz =
            getElementPosition(veh)

        local dist =
            getDistanceBetweenPoints3D(
                px,py,pz,
                vx,vy,vz
            )

        if dist < nearestDist then

            nearestDist = dist
            nearestVehicle = veh

        end

    end

    if not nearestVehicle then

        outputChatBox(
            "Brak pojazdu w pobliżu.",
            player,
            255,0,0
        )

        return
    end

    local state,multiplier =
        getVehicleDamageRating(
            nearestVehicle
        )

    local hp =
        math.floor(
            getElementHealth(
                nearestVehicle
            )
        )

    outputChatBox(
        "Stan pojazdu: "..state,
        player,
        255,255,0
    )

    outputChatBox(
        "HP pojazdu: "..hp.."/1000",
        player,
        255,255,0
    )

end)



addEventHandler("onPlayerWasted", root,
    function()
        local player = source

        if getPlayerTeam(player) ~= pdTeam then
            return
        end

        setTimer(function(p)
            if not isElement(p) then return end

            spawnPlayer(
                p,
                pdRespawnPos[1],
                pdRespawnPos[2],
                pdRespawnPos[3],
                0,
                getElementModel(p),
                0,
                0
            )

            fadeCamera(p, true)
            setCameraTarget(p, p)

            -- zachowanie duty
            setElementData(p, "pd:duty", true)

        end, 3000, 1, player)
    end
)



----------------------------------------------------
-- BLOKADA KLAWISZY PODCZAS SŁUŻBY
----------------------------------------------------

local blockedKeys = {
    ["F1"] = true,
    ["F4"] = true,
    ["b"] = true
}

addEventHandler("onClientKey", root,
    function(button, press)
        if not press then return end

        -- tylko podczas służby
        if not getElementData(localPlayer, "pd:duty") then
            return
        end

        if blockedKeys[button] then
            cancelEvent()

            outputChatBox(
                "Ta funkcja jest niedostępna podczas służby.",
                255, 0, 0
            )
        end
    end
)