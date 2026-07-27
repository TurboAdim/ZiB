Police = {}
TrackedPlayers = {}
JailedPlayers = {}
PoliceLights = {}
PoliceSkins = {}


----------------------------------------------------
-- TEAM
----------------------------------------------------

local policeTeam =
    getTeamFromName("Policja")

if not policeTeam then

    policeTeam = createTeam(
        "Policja",
        51,153,255
    )

end


----------------------------------------------------
-- POJAZDY DO KOLOROWANIA
----------------------------------------------------

local vehiclesToColorBIALE = {
    -- NEWMODELS
    [60196] = true,
    [60075] = true,
    [60214] = true,
}

local vehiclesToColorCZARNE = {
    -- NEWMODELS
    [60211] = true,
    [60212] = true,
    [60061] = true,
}

local restrictedTeams = {
    ["forkliftTeam"] = true,
    ["Praca - Kryminalista"] = true,
    ["truckerTeam"] = true,
    ["pdTeam"] = true,
    ["fireTeam"] = true,
    ["tornadoTeam"] = true
}

local bypassTeamChange = {}
local policeRespawnPos = {2298.4467773438, 2424.6328125, 10.8203125}
local vehicleCallCooldown = {}

addEventHandler("onPlayerTeamChange", root,
    function(oldTeam, newTeam)

        local player = source

        if bypassTeamChange[player] then
            return
        end

        if oldTeam == policeTeam and newTeam then
            local teamName = getTeamName(newTeam)

            if restrictedTeams[teamName] then
                cancelEvent()
                outputChatBox(
                    "Nie możesz zmienić pracy podczas służby policji!",
                    player,
                    255,0,0
                )
            end
        end
    end
)

----------------------------------------------------
-- MARKER
----------------------------------------------------

local marker = createMarker(
    Config.Marker[1],
    Config.Marker[2],
    Config.Marker[3],
    "cylinder",
    2,
    51,153,255,150
)

setElementData(marker,"police:marker",true)

createBlipAttachedTo(marker, 30)

----------------------------------------------------
-- ACL
----------------------------------------------------

function hasPoliceACL(player)

    local account = getPlayerAccount(player)

    if not account or isGuestAccount(account) then
        return false
    end

    local accName = getAccountName(account)

    local acl = aclGetGroup("Everyone")

    if not acl then
        return false
    end

    return isObjectInACLGroup(
        "user."..accName,
        acl
    )

end

----------------------------------------------------
-- CHECK
----------------------------------------------------

addEvent("police:checkACL",true)
addEventHandler("police:checkACL",root,
    function()

        if not hasPoliceACL(client) then

            triggerClientEvent(
                client,
                "police:noACL",
                resourceRoot
            )

            return
        end

        triggerClientEvent(
            client,
            "police:loadGUI",
            resourceRoot,
            Config.Vehicles,
            Config.Skins
        )

        triggerClientEvent(
            client,
            "police:openGUI",
            resourceRoot
        )

    end
)

----------------------------------------------------
-- CREATE VEHICLE
----------------------------------------------------

function createPoliceVehicle(model,x,y,z,rot)

    local veh

    model = tonumber(model)

    if not model then
        return false
    end

    if model > 611 then

        veh = exports["newmodels_red"]:createVehicle(
            model,
            x,
            y,
            z
        )

    else

        veh = createVehicle(
            model,
            x,
            y,
            z
        )

    end

    if not isElement(veh) then

        outputDebugString(
            "[zib_praca_policja] Nie udało się stworzyć pojazdu. Model: "..tostring(model),
            1
        )

        return false

    end

    setElementRotation(
        veh,
        0,
        0,
        tonumber(rot) or 0
    )

    return veh

end

----------------------------------------------------
-- SKIN
----------------------------------------------------

function setPoliceSkin(player,skin)

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
-- START JOB
----------------------------------------------------

addEvent("police:startJob",true)
addEventHandler("police:startJob",root,
    function(vehicleID,skinID)

        local player = client

        if not hasPoliceACL(player) then
            return
        end

        local vehData =
            Config.Vehicles[vehicleID]

        local skinData =
            Config.Skins[skinID]

        if not vehData or not skinData then
            return
        end

        local spawn =
            Config.Spawns[
                math.random(#Config.Spawns)
            ]

        local veh = createPoliceVehicle(
    vehData.model,
    spawn[1],
    spawn[2],
    spawn[3],
    spawn[4]
)
if not isElement(veh) then

    outputChatBox(
        "Nie udało się utworzyć pojazdu służbowego.",
        player,
        255,
        0,
        0
    )

    return

end

        setVehicleDamageProof(veh, true)
        setVehicleEngineState(veh, true)
        setVehicleLocked(veh, false)

----------------------------------------------------
-- KOLOR POJAZDU
----------------------------------------------------

local vehicleModel = tonumber(vehData.model)

if vehiclesToColorBIALE[vehicleModel] then

    setVehicleColor(
        veh,
        255, 255, 255,       -- pierwszy kolor: CZARNY
        0, 0, 0  -- drugi kolor: BIAŁY
    )
	elseif vehiclesToColorCZARNE[vehicleModel] then
	setVehicleColor(
        veh,
        0, 0, 0,       -- pierwszy kolor: CZARNY
        255, 255, 255  -- drugi kolor: BIAŁY
    )
	

end
        --setVehicleDoorsUndamageable(veh, true)


setElementData(
    veh,
    "police:customModel",
    vehData.model
)

        warpPedIntoVehicle(player,veh)
		
		PoliceSkins[player] = getElementModel(player)
		
        setPoliceSkin(
            player,
            skinData.skin
        )

        local oldTeam =
            getPlayerTeam(player)

        Police[player] = {

            vehicle = veh,
            oldTeam = oldTeam

        }

        setPlayerTeam(player,policeTeam)

        triggerClientEvent(
        player,
        "police:setWorking",
        resourceRoot,
        true
)

        setPlayerNametagShowing(player,false)

        setElementData(player,"police:duty",true)

        outputChatBox(
            "Policjant rozpoczął służbę.",
            root,
            0,100,255
        )

    end
)

--[[addCommandHandler("pojazd.przywolaj",
    function(player)

        if getPlayerTeam(player) ~= policeTeam then
            return
        end

        if not Police[player] or not isElement(Police[player].vehicle) then
            outputChatBox("Nie masz przypisanego pojazdu.", player, 255, 0, 0)
            return
        end
		
		if vehicleCallCooldown[player] and getTickCount() - vehicleCallCooldown[player] < 30000 then
           outputChatBox("Poczekaj chwilę przed kolejnym przywołaniem.", player, 255, 0, 0)
           return
        end
        vehicleCallCooldown[player] = getTickCount()
    

        local veh = Police[player].vehicle

        local x, y, z = getElementPosition(player)
        local _, _, rot = getElementRotation(player)

        setElementPosition(veh, x + 2, y + 2, z)
        setElementRotation(veh, 0, 0, rot)

        setVehicleEngineState(veh, true)
        setVehicleLocked(veh, false)

        outputChatBox("Przywołano pojazd służbowy.", player, 0, 255, 0)
		
		
    end
)--]]


----------------------------------------------------
-- PRZYWOLANIE POJAZDU POLICJI
----------------------------------------------------

local function recallPoliceVehicle(player)

    ------------------------------------------------
    -- SPRAWDZENIE GRACZA
    ------------------------------------------------

    if not isElement(player) then
        return
    end

    if getElementType(player) ~= "player" then
        return
    end

    ------------------------------------------------
    -- SPRAWDZENIE TEAMU
    ------------------------------------------------

    local policeTeam =
        getTeamFromName("Policja")

    if not policeTeam then

        outputChatBox(
            "Błąd: nie znaleziono teamu Policja.",
            player,
            255,
            0,
            0
        )

        return
    end

    if getPlayerTeam(player) ~= policeTeam then

        outputChatBox(
            "Nie jesteś policjantem.",
            player,
            255,
            0,
            0
        )

        return
    end

    ------------------------------------------------
    -- SPRAWDZENIE PRZYPISANEGO POJAZDU
    ------------------------------------------------

    if not Police[player]
        or not isElement(Police[player].vehicle) then

        outputChatBox(
            "Nie masz przypisanego pojazdu.",
            player,
            255,
            0,
            0
        )

        return
    end

    ------------------------------------------------
    -- COOLDOWN
    ------------------------------------------------

    if vehicleCallCooldown[player]
        and getTickCount() - vehicleCallCooldown[player] < 30000 then

        outputChatBox(
            "Poczekaj chwilę przed kolejnym przywołaniem.",
            player,
            255,
            0,
            0
        )

        return
    end

    vehicleCallCooldown[player] =
        getTickCount()

    ------------------------------------------------
    -- POJAZD
    ------------------------------------------------

    local veh =
        Police[player].vehicle

    ------------------------------------------------
    -- POZYCJA GRACZA
    ------------------------------------------------

    local x, y, z =
        getElementPosition(player)

    local _, _, rot =
        getElementRotation(player)

    ------------------------------------------------
    -- PRZYWOLANIE POJAZDU
    ------------------------------------------------

    setElementPosition(
        veh,
        x + 2,
        y + 2,
        z
    )

    setElementRotation(
        veh,
        0,
        0,
        rot
    )

    ------------------------------------------------
    -- USTAWIENIA POJAZDU
    ------------------------------------------------

    setVehicleEngineState(
        veh,
        true
    )

    setVehicleLocked(
        veh,
        false
    )

    ------------------------------------------------
    -- INFORMACJA
    ------------------------------------------------

    outputChatBox(
        "Przywołano pojazd służbowy.",
        player,
        0,
        255,
        0
    )

end


----------------------------------------------------
-- KOMENDA /PRZYWOLAJ.POJAZD
----------------------------------------------------

addCommandHandler(
    "przywolaj.pojazd",
    function(player)

        recallPoliceVehicle(
            player
        )

    end
)


----------------------------------------------------
-- EVENT DLA BUTTONA GUI
----------------------------------------------------

addEvent(
    "police:recallVehicle",
    true
)

addEventHandler(
    "police:recallVehicle",
    root,
    function()

        local player =
            client

        recallPoliceVehicle(
            player
        )

    end
)


----------------------------------------------------
-- EVENT DLA BUTTONA GUI
----------------------------------------------------

addEvent(
    "police:recallVehicle",
    true
)

addEventHandler(
    "police:recallVehicle",
    root,
    function()

        local player = client

        recallPoliceVehicle(player)

    end
)

----------------------------------------------------
-- STOP
----------------------------------------------------

function stopPoliceJob(player)
    bypassTeamChange[player] = true
    if not isElement(player) then return end

    local data = Police[player]
    if type(data) ~= "table" then return end

    -- 🔴 WYŁĄCZ KOGUTY
    if PoliceLights[player] then
        for _, marker in ipairs(PoliceLights[player]) do
            if isElement(marker) then
                destroyElement(marker)
            end
        end
        PoliceLights[player] = nil
    end

    -- 🔴 USUŃ POJAZD
    if isElement(data.vehicle) then
        destroyElement(data.vehicle)
    end

    local drift = getTeamFromName("ZMIENNY23 - Gracze")

    if data.oldTeam and isElement(data.oldTeam) then
        setPlayerTeam(player, data.oldTeam)
    elseif drift then
        setPlayerTeam(player, drift)
    else
        setPlayerTeam(player, nil)
    end

    -- 🔴 RESET PLAYER STATE
    setElementData(player, "police:duty", false)
    setPlayerNametagShowing(player, true)
	
	-- 🔄 PRZYWRÓĆ SKIN
    if PoliceSkins[player] then
       setElementModel(player, PoliceSkins[player])
       PoliceSkins[player] = nil
    end

    triggerClientEvent(player, "police:setWorking", resourceRoot, false)

    Police[player] = nil
	bypassTeamChange[player] = nil
end
----------------------------------------------------
-- PANEL
----------------------------------------------------

addEvent("police:openPanel",true)
addEventHandler("police:openPanel",root,
    function()

        local player = client

        if getPlayerTeam(player) ~= policeTeam then
            return
        end

        local players = {}

        for _,p in ipairs(getElementsByType("player")) do
            table.insert(players,getPlayerName(p))
        end

        triggerClientEvent(
            player,
            "police:showPanel",
            resourceRoot,
            players
        )

    end
)



addEvent("police:giveTicket",true)
addEventHandler("police:giveTicket",root,
    function(targetName,amount)

        local player = client

        if getPlayerTeam(player) ~= policeTeam then
            return
        end

        local target

        for _,p in ipairs(getElementsByType("player")) do

            if getPlayerName(p) == targetName then
                target = p
                break
            end

        end

        if not target then
            return
        end

        takePlayerMoney(target,amount)

        outputChatBox(
            "Otrzymałeś mandat $"..amount,
            target,
            255,0,0
        )

        outputChatBox(
            "Wystawiono mandat.",
            player,
            0,255,0
        )

    end
)





addEvent("police:jailPlayer",true)
addEventHandler("police:jailPlayer",root,
    function(targetName,cell,time)

        local player = client

        if getPlayerTeam(player) ~= policeTeam then
            return
        end

        local target

        for _,p in ipairs(getElementsByType("player")) do

            if getPlayerName(p) == targetName then
                target = p
                break
            end

        end

        if not target then
            return
        end

        local pos = Config.Cells[cell]

        -- zapisz poprzednią pozycję
    JailedPlayers[target] = {
    x = getElementPosition(target),
    y = select(2, getElementPosition(target)),
    z = select(3, getElementPosition(target)),
    int = getElementInterior(target),
    dim = getElementDimension(target)
}

     -- teleport do celi
     local pos = Config.Cells[cell]

     setElementPosition(target, pos[1], pos[2], pos[3])
     setElementInterior(target, 0)
     setElementDimension(target, 0)

     toggleAllControls(target,false)

        outputChatBox(
            "Zostałeś uwięziony na "..time.." minut.",
            target,
            255,0,0
        )

        setTimer(function()

            if not isElement(target) then
                return
            end

            --if not isElement(target) then return end

        toggleAllControls(target,true)

local data = JailedPlayers[target]
if data then

        setElementPosition(target, data.x, data.y, data.z)
        setElementInterior(target, data.int)
        setElementDimension(target, data.dim)

        JailedPlayers[target] = nil
    end

        outputChatBox("Wyszedłeś z więzienia.", target, 0,255,0)


        end,time*60000,1)

    end
)



addEvent("police:trackPlayer",true)
addEventHandler("police:trackPlayer",root,
    function(targetName)

        local player = client

        if getPlayerTeam(player) ~= policeTeam then
            return
        end

        local target

        for _,p in ipairs(getElementsByType("player")) do

            if getPlayerName(p) == targetName then
                target = p
                break
            end

        end

        if not target then
            return
        end

        ----------------------------------------------------
        -- REMOVE OLD
        ----------------------------------------------------

        if TrackedPlayers[target] then

            if isElement(TrackedPlayers[target]) then
                destroyElement(TrackedPlayers[target])
            end

            TrackedPlayers[target] = nil

        end

        ----------------------------------------------------
        -- CREATE BLIP
        ----------------------------------------------------

        local x,y,z = getElementPosition(target)

        local blip = createBlip(x,y,z, 0, 2, 255,0,0,255)

        TrackedPlayers[target] = blip
		
		
		

        ----------------------------------------------------
        -- VISIBILITY
        ----------------------------------------------------

        for _,cop in ipairs(getPlayersInTeam(policeTeam)) do

            setElementVisibleTo(
                blip,
                cop,
                true
            )

        end

        ----------------------------------------------------
        -- INFO
        ----------------------------------------------------

        outputChatBox(
            "Poszukiwany został namierzony.",
            player,
            255,0,0
        )

        triggerClientEvent(
            player,
            "police:playBip",
            resourceRoot
        )

    end
)

addEventHandler("onPlayerQuit",root,
    function()

        if TrackedPlayers[source] then

            if isElement(TrackedPlayers[source]) then
                destroyElement(TrackedPlayers[source])
            end

            TrackedPlayers[source] = nil

        end

    end
)

addEventHandler("onPlayerWasted",root,
    function()

        if TrackedPlayers[source] then

            if isElement(TrackedPlayers[source]) then
                destroyElement(TrackedPlayers[source])
            end

            TrackedPlayers[source] = nil

        end

    end
)




addEvent("police:getWeapons",true)
addEventHandler("police:getWeapons",root,
    function()

        local player = client

        if getPlayerTeam(player) ~= policeTeam then
            return
        end

        giveWeapon(player,3,1)
        giveWeapon(player,24,200)
        giveWeapon(player,31,500)

        outputChatBox(
            "Otrzymałeś wyposażenie.",
            player,
            0,255,0
        )

    end
)


----------------------------------------------------
-- SAPD
----------------------------------------------------

addCommandHandler("sapd",
    function(player)

        outputChatBox(
            getPlayerName(player)..
            " wzywa SAPD!",
            root,
            255,0,0
        )

        local x,y,z =
            getElementPosition(player)

        local blip =
            createBlip(
                x,y,z,
                0,
                2,
                255,0,0,255
            )

        for _,p in ipairs(getPlayersInTeam(policeTeam)) do

            setElementVisibleTo(
                blip,
                p,
                true
            )

            triggerClientEvent(
                p,
                "police:playBip",
                resourceRoot
            )

        end

        setTimer(function()

            if isElement(blip) then
                destroyElement(blip)
            end

        end,30000,1)

    end
)

----------------------------------------------------
-- WEAPONS
----------------------------------------------------

addCommandHandler("wyposazenie",
    function(player)

        if getPlayerTeam(player) ~= policeTeam then
            return
        end

        giveWeapon(player,3,1)
        giveWeapon(player,24,200)
        giveWeapon(player,31,500)

    end
)












addEvent("police:send3DBip", true)
addEventHandler("police:send3DBip", root,
    function()

        local player = client

        if not isElement(player) then return end

        if getPlayerTeam(player) ~= policeTeam then
            return
        end

        local x,y,z = getElementPosition(player)

        for _,p in ipairs(getElementsByType("player")) do

            local px,py,pz = getElementPosition(p)

            if getDistanceBetweenPoints3D(x,y,z,px,py,pz) <= 150 then

                triggerClientEvent(
                    p,
                    "police:play3DBip",
                    resourceRoot,
                    x,y,z
                )

            end

        end

    end
)




----------------------------------------------------
-- EXPORT
----------------------------------------------------

function isPlayerPolice(player)

    return getPlayerTeam(player) == policeTeam

end


addEvent("police:toggleLights", true)
addEventHandler("police:toggleLights", root,
function()
    local player = client

    if not Police[player] then return end

    local veh = Police[player].vehicle
    if not isElement(veh) then return end

    if getVehicleOccupant(veh, 0) ~= player then
        outputChatBox("Musisz siedzieć za kierownicą.", player, 255, 0, 0)
        return
    end

    -- 🔴 JEŚLI JUŻ ŚWIECĄ → WYŁĄCZ
    if PoliceLights[player] then
        for _, marker in ipairs(PoliceLights[player]) do
            if isElement(marker) then
                destroyElement(marker)
            end
        end

        PoliceLights[player] = nil
        setElementData(veh, "police:lights", false) -- ważne
        return -- 🔥 KLUCZOWE: kończymy tutaj
    end

    -- 🟢 WŁĄCZ
    PoliceLights[player] = {}

    local model = getElementData(veh, "police:customModel") or getElementModel(veh)
    local offsets = Config.Strobes[model]

    if not offsets then
        outputChatBox("Brak konfiguracji strobo dla tego pojazdu.", player, 255, 0, 0)
        return
    end

   local cfg = Config.Strobes[model]

if not cfg then
    outputChatBox("Brak konfiguracji strobo dla tego pojazdu.", player, 255, 0, 0)
    return
end

local offsets = cfg.offsets
local colors = cfg.colors

local colorIndex = 1

for _, off in ipairs(offsets) do

    local col = colors[colorIndex] or {255, 255, 255}

    local marker = createMarker(
    0, 0, 0,
    "corona",
    0.25,
    col[1], col[2], col[3], 220
)

attachElements(marker, veh, off[1], off[2], off[3])

setElementData(marker, "police:lightColor", col) -- 🔥 TO DODAJ

table.insert(PoliceLights[player], marker)

    colorIndex = colorIndex + 1

    if colorIndex > #colors then
        colorIndex = 1
    end
end

    setElementData(veh, "police:lights", true)
end)


addEventHandler("onPlayerQuit",root,
    function()

        JailedPlayers[source] = nil

    end
)



----------------------------------------------------
-- TRACK UPDATE TIMER
----------------------------------------------------

setTimer(function()

    for target,blip in pairs(TrackedPlayers) do

        if isElement(target) and isElement(blip) then

            local x,y,z = getElementPosition(target)

            setElementPosition(
                blip,
                x,y,z
            )

        else

            if isElement(blip) then
                destroyElement(blip)
            end

            TrackedPlayers[target] = nil

        end

    end

end,1000,0)


----------------------------------------------------
-- STOP
----------------------------------------------------


addCommandHandler("koniecsluzby",
    function(player)

        stopPoliceJob(player)

    end
)

addEvent("police:stopJob",true)
addEventHandler("police:stopJob",root,
function()
    local player = client

    stopPoliceJob(player)
end)




addEventHandler("onPlayerQuit",root,
    function()

        stopPoliceJob(source)

    end
)


addEventHandler("onPlayerWasted", root,
    function()
        local player = source

        if getPlayerTeam(player) ~= policeTeam then
            return
        end

        setTimer(function(p)
            if not isElement(p) then return end

            spawnPlayer(
                p,
                policeRespawnPos[1],
                policeRespawnPos[2],
                policeRespawnPos[3],
                0,
                getElementModel(p),
                0,
                0
            )

            fadeCamera(p, true)
            setCameraTarget(p, p)

            -- zachowanie duty
            setElementData(p, "police:duty", true)

        end, 3000, 1, player)
    end
)