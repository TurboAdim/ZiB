PDWorkers = {}
PDLights = {}
PlacedObjects = {}
ServerCalls = {}
RandomEvents = {}
UsedTreeLocations = {}

----------------------------------------------------
-- TEAM
----------------------------------------------------

local pdTeam = getTeamFromName("Pomoc Drogowa")

if not pdTeam then

    pdTeam = createTeam(
        "Pomoc Drogowa",
        255,255,0
    )

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
    255,255,0,150
)

setElementData(marker,"pd:marker",true)

createBlipAttachedTo(marker,27)

----------------------------------------------------
-- VEHICLE
----------------------------------------------------

function createPDVehicle(model,x,y,z,rot)

    local veh

    if tonumber(model) > 611 then

        veh = exports["newmodels_red"]:createVehicle(
            tonumber(model),
            x,y,z
        )

    else

        veh = createVehicle(
            tonumber(model),
            x,y,z
        )

    end

    setElementRotation(veh,0,0,rot)

    return veh
end

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

    local spawn =
        Config.Spawns[
            math.random(#Config.Spawns)
        ]

    local oldSkin = getElementModel(player)

    local veh = createPDVehicle(
        vehData.model,
        spawn[1],
        spawn[2],
        spawn[3],
        spawn[4]
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

end)

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
        setElementModel(player, data.oldSkin)
    end

    setElementData(player, "pd:duty", false)

    setPlayerTeam(player, getTeamFromName("ZMIENNY23 - Gracze"))

    triggerClientEvent(player, "pd:setWorking", resourceRoot, false)

    PDWorkers[player] = nil
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
        1228,
        x,y,z-1
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
        90,0,0
    )

    local blip =
        createBlipAttachedTo(
            tree,
            27
        )

    RandomEvents[tree] = {
        blip = blip,
        place = random.name,
        locationIndex = locationIndex
    }

    UsedTreeLocations[locationIndex] = true

    outputChatBox(
        "[SERWER] Odnotowano powalone drzewo: "..random.name,
        root,
        255,200,0
    )

end

setTimer(
    createRandomTreeEvent,
    200000,
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

                    outputChatBox(
                        "[SERWER] Zagrożenie usunięte: Powalone Drzewo",
                        root,
                        255,255,0
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
            "Gracz "..getPlayerName(player).." wzywa Pomoc Drogową.",
            p,
            255,255,0
        )

    end

    outputChatBox(
        "Zgłoszenie wysłane, ktoś za chwile zajmie Twoją sprawą.",
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



addEvent("pd:toggleLights", true)
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

    local cfg = Config.Strobes[getElementModel(veh)]
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