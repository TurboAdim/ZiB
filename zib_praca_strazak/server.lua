Firefighters = {}
FireLights = {}
SavedSkins = {}
PlacedObjects = {}
Spills = {}
DutyVehicles = {}

local SpillState = {}
local SPILL_RESPAWN_TIME = 10000 -- 10 sekund TEST


-------------------------------------------------
-- TEAM
-------------------------------------------------
local fireTeam = nil

addEventHandler("onResourceStart", resourceRoot, function()
    fireTeam = getTeamFromName("Straż Pożarna") or createTeam("Straż Pożarna",255,50,50)
end)

local fireRespawnPos = {1731.0258789062,2110.6159667969,10.828125}


-------------------------------------------------
-- MARKER
-------------------------------------------------
local marker = createMarker(
    Config.Marker[1],
    Config.Marker[2],
    Config.Marker[3],
    "cylinder",
    2,
    255,50,50,150
)

setElementData(marker,"firefighter:marker",true)

local blip = createBlipAttachedTo(marker,20)
--setBlipVisibleDistance(blip,250)



-------------------------------------------------
-- CREATE SPILLS
-------------------------------------------------
function updateSpillBlipsForPlayer(player)

    local isFire = getElementData(player, "firefighter:duty")
    local teamOk = (getPlayerTeam(player) == fireTeam)

    for spill, data in pairs(Spills) do
        if isElement(spill) and data and isElement(data.blip) then

            if isFire and teamOk then
                setElementVisibleTo(data.blip, player, true)
            else
                setElementVisibleTo(data.blip, player, false)
            end

        end
    end
end

addEventHandler("onResourceStart", resourceRoot, function()
    for i, _ in ipairs(Config.Spills) do
        SpillState[i] = {
            active = false,
            timer = nil
        }
    end

    setTimer(spawnAllSpills, 1000, 1)
end)

function spawnSpill(index)
    local data = Config.Spills[index]
    if not data then return end

    local state = SpillState[index]
    if not state or state.active then return end

    local spill = createElement("spill")
    setElementPosition(spill, data.x, data.y, data.z)
    setElementRotation(spill, data.rx or 0, data.ry or 0, data.rz or 0)

    setElementData(spill, "spill", true)
    setElementData(spill, "spill:index", index)
    setElementData(spill, "spill:name", data.name or "Nieznana lokalizacja")

    local blip = createBlipAttachedTo(spill, 20)
    setBlipVisibleDistance(blip, 200)
    setElementVisibleTo(blip, root, false)

    Spills[spill] = {
        blip = blip,
        index = index
    }

    state.active = true
    state.timer = nil

    for _, player in ipairs(getPlayersInTeam(fireTeam)) do
        setElementVisibleTo(blip, player, true)
    end
end

function spawnAllSpills()
    for i in ipairs(Config.Spills) do
        spawnSpill(i)
    end
end


addEvent("firefighter:cleanSpill", true)
addEventHandler("firefighter:cleanSpill", root, function(spill)
    if not isElement(spill) then return end

    local data = Spills[spill]
    if not data then return end

    local index = data.index

    -- usuń blip
    if isElement(data.blip) then
        destroyElement(data.blip)
    end

    destroyElement(spill)
    Spills[spill] = nil

    -- ustaw respawn po 10 sekundach
    if SpillState[index] then
        SpillState[index].active = false

        if isTimer(SpillState[index].timer) then
            killTimer(SpillState[index].timer)
        end

        SpillState[index].timer = setTimer(function()
            spawnSpill(index)
        end, SPILL_RESPAWN_TIME, 1)
    end

    outputChatBox("Usunięto rozlany płyn.", client, 0,255,0)
end)




-------------------------------------------------
-- CUSTOM VEHICLE
-------------------------------------------------
function createFireVehicle(model,x,y,z,rot)

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

    if not veh then
        return false
    end

    setElementRotation(veh,0,0,rot)

    -- ZAPIS CUSTOM MODELU
    setElementData(
        veh,
        "firefighter:model",
        tonumber(model)
    )

    return veh
end

-------------------------------------------------
-- CUSTOM SKIN
-------------------------------------------------
function applyFireSkin(player,skin)

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

-------------------------------------------------
-- START DUTY
-------------------------------------------------
addEvent("firefighter:startDuty",true)
addEventHandler("firefighter:startDuty",root,function(vehicleID,skinID)

    local player = client

    local vehicleData = Config.Vehicles[vehicleID]
    local skinData = Config.Skins[skinID]

    if not vehicleData or not skinData then
        return
    end

    local spawn = Config.Spawns[
        math.random(#Config.Spawns)
    ]

    local veh = createFireVehicle(
    vehicleData.model,
    spawn[1],
    spawn[2],
    spawn[3],
    spawn[4]
)

if not veh then
    outputChatBox("Błąd tworzenia pojazdu",player,255,0,0)
    return
end

-- FIX DAMAGE PROOF (MTA SAFE)
setVehicleDamageProof(veh, true)
setVehicleEngineState(veh, true)
setVehicleLocked(veh, false)
setVehicleDoorsUndamageable(veh, true)

warpPedIntoVehicle(player, veh)

    SavedSkins[player] = getElementModel(player)

    applyFireSkin(
        player,
        skinData.skin
    )

    Firefighters[player] = {
        vehicle = veh
    }
	DutyVehicles[veh] = player

    setPlayerTeam(player,fireTeam)
	
	updateSpillBlipsForPlayer(player)
	
    setElementData(player,"firefighter:duty",true)
    setElementData(veh,"firefighter:vehicle",true)

    triggerClientEvent(
        player,
        "firefighter:setDuty",
        root,
        true
    )

    outputChatBox(
        "✔ Rozpocząłeś służbę Strażaka",
        player,
        255,50,50
    )

end)

local vehicleCallCooldown = {}

addCommandHandler("pojazd.przywolaj",
function(player)

    if getPlayerTeam(player) ~= fireTeam then
        return
    end

    if vehicleCallCooldown[player] and getTickCount() - vehicleCallCooldown[player] < 30000 then
        outputChatBox("Poczekaj chwilę przed kolejnym przywołaniem.", player, 255, 0, 0)
        return
    end

    if not Firefighters[player] then
        outputChatBox("Nie jesteś na służbie.", player, 255, 0, 0)
        return
    end

    local veh = Firefighters[player].vehicle

    if not isElement(veh) then
        outputChatBox("Nie masz przypisanego pojazdu.", player, 255, 0, 0)
        return
    end

    vehicleCallCooldown[player] = getTickCount()

    local x,y,z = getElementPosition(player)
    local _,_,rot = getElementRotation(player)

    setElementPosition(veh,x+2,y+2,z)
    setElementRotation(veh,0,0,rot)
    setVehicleEngineState(veh,true)
    setVehicleLocked(veh,false)

    outputChatBox("Przywołano pojazd służbowy.", player, 0, 255, 0)
end)


-------------------------------------------------
-- STOP DUTY
-------------------------------------------------
function stopFireDuty(player)

    if not Firefighters[player] then
        return
    end

    local data = Firefighters[player]
	
	
	
	-------------------------------------------------
-- REMOVE OBJECTS
-------------------------------------------------

if PlacedObjects[player] then

    for _,obj in ipairs(PlacedObjects[player]) do

        if isElement(obj) then
            destroyElement(obj)
        end

    end

    PlacedObjects[player] = nil
end

    -------------------------------------------------
    -- LIGHTS REMOVE
    -------------------------------------------------
    if FireLights[player] then

        for _,m in ipairs(FireLights[player]) do

            if isElement(m) then
                destroyElement(m)
            end
        end

        FireLights[player] = nil
    end


    -- VEHICLE
if isElement(data.vehicle) then

    if setVehicleDamageProof then
        setVehicleDamageProof(data.vehicle, false)
    end

    if setVehicleEngineDamageProof then
        setVehicleEngineDamageProof(data.vehicle, false)
    end

    if setVehicleFuelTankExplodable then
        setVehicleFuelTankExplodable(data.vehicle, true)
    end

    DutyVehicles[data.vehicle] = nil

    destroyElement(data.vehicle)
end

    -------------------------------------------------
    -- RESTORE SKIN
    -------------------------------------------------
    if SavedSkins[player] then
        setElementModel(player,SavedSkins[player])
    end

    -------------------------------------------------
    -- TEAM
    -------------------------------------------------
    local drift = getTeamFromName("ZMIENNY23 - Gracze")

    if drift then
        setPlayerTeam(player,drift)
    end
	
	updateSpillBlipsForPlayer(player)
	
    setElementData(player,"firefighter:duty",false)

    Firefighters[player] = nil
    SavedSkins[player] = nil

    triggerClientEvent(
        player,
        "firefighter:setDuty",
        root,
        false
    )

    outputChatBox(
        "❌ Zakończyłeś służbę",
        player,
        255,50,50
    )
end

addEvent("firefighter:stopDuty",true)
addEventHandler("firefighter:stopDuty",root,function()
    stopFireDuty(client)
end)

-------------------------------------------------
-- LIGHTS
-------------------------------------------------
addEvent("firefighter:toggleLights",true)
addEventHandler("firefighter:toggleLights",root,function()

    local player = client

    if not Firefighters[player] then
        return
    end

    local veh = Firefighters[player].vehicle

    if not isElement(veh) then
        return
    end

    -------------------------------------------------
    -- OFF
    -------------------------------------------------
    if FireLights[player] then

        for _,m in ipairs(FireLights[player]) do

            if isElement(m) then
                destroyElement(m)
            end
        end

        FireLights[player] = nil

        setElementData(
            veh,
            "firefighter:lights",
            false
        )

        return
    end

    -------------------------------------------------
    -- MODEL
    -------------------------------------------------
    local model = getElementData(
        veh,
        "firefighter:model"
    ) or getElementModel(veh)

    local cfg = Config.Beacons[model]

    if not cfg then
        outputDebugString(
            "[STRAZ] Brak Config.Beacons dla modelu: "..tostring(model)
        )
        return
    end

    -------------------------------------------------
    -- ON
    -------------------------------------------------
    FireLights[player] = {}

    local ci = 1

    for _,off in ipairs(cfg.offsets) do

        local col = cfg.colors[ci]

        local m = createMarker(
            0,0,0,
            "corona",
            0.30,
            col[1],
            col[2],
            col[3],
            255
        )

        attachElements(
            m,
            veh,
            off[1],
            off[2],
            off[3]
        )

        setElementData(
            m,
            "ff_color",
            col
        )

        table.insert(
            FireLights[player],
            m
        )

        ci = ci + 1

        if ci > #cfg.colors then
            ci = 1
        end
    end

    setElementData(
        veh,
        "firefighter:lights",
        true
    )

end)

-------------------------------------------------
-- SAFD
-------------------------------------------------
addCommandHandler("safd",function(player)

    local players = getPlayersInTeam(fireTeam)

    if #players <= 0 then

        outputChatBox(
            "Zgłoszenie nie wysłane. Brak Strażaków na serwerze",
            player,
            255,0,0
        )

        return
    end

    outputChatBox(
        "Zgłoszenie wysłane. Straż Pożarna jest w drodze",
        player,
        0,255,0
    )

    local x,y,z = getElementPosition(player)

    local blip = createBlip(
        x,y,z,
        20
    )

    for _,player in ipairs(players) do

        setElementVisibleTo(
            blip,
            player,
            true
        )

        triggerClientEvent(
            player,
            "firefighter:playBip",
            root
        )
    end

    setTimer(function()

        if isElement(blip) then
            destroyElement(blip)
        end

    end,30000,1)

end)




-------------------------------------------------
-- PACHOŁKI / BARIERKI
-------------------------------------------------

addCommandHandler("pacholek",function(player)

    if getPlayerTeam(player) ~= fireTeam then
        return
    end

    local x,y,z = getElementPosition(player)

    local obj = createObject(
        1238,
        x,
        y,
        z - 0.7
    )

    PlacedObjects[player] =
        PlacedObjects[player] or {}

    table.insert(
        PlacedObjects[player],
        obj
    )

    outputChatBox(
        "Postawiono pachołek.",
        player,
        255,100,0
    )

end)

-------------------------------------------------
-- BARIERKA
-------------------------------------------------

addCommandHandler("barierka",function(player)

    if getPlayerTeam(player) ~= fireTeam then
        return
    end

    local x,y,z = getElementPosition(player)

    local obj = createObject(
        1237,
        x,
        y,
        z - 1
    )

    PlacedObjects[player] =
        PlacedObjects[player] or {}

    table.insert(
        PlacedObjects[player],
        obj
    )

    outputChatBox(
        "Postawiono barierkę.",
        player,
        255,100,0
    )

end)

-------------------------------------------------
-- USUWANIE OBIEKTÓW
-------------------------------------------------

addCommandHandler("usunobiekty",function(player)

    if not PlacedObjects[player] then
        return
    end

    for _,obj in ipairs(PlacedObjects[player]) do

        if isElement(obj) then
            destroyElement(obj)
        end

    end

    PlacedObjects[player] = {}

    outputChatBox(
        "Usunięto wszystkie obiekty.",
        player,
        255,100,0
    )

end)


-------------------------------------------------
-- VEHICLE SLIDE
-------------------------------------------------

setTimer(function()

    for spill, data in pairs(Spills) do

        if isElement(spill) then

            local sx,sy,sz = getElementPosition(spill)

            for _,veh in ipairs(getElementsByType("vehicle")) do

                local vx,vy,vz = getElementPosition(veh)

                local dist = getDistanceBetweenPoints3D(
                    sx,sy,sz,
                    vx,vy,vz
                )

                if dist < 4 then

                    local velX,velY,velZ = getElementVelocity(veh)

                    local strength = 2.2

                    local slipX = math.random(-40,40)/100 * strength
                    local slipY = math.random(-40,40)/100 * strength

                    setElementVelocity(
                        veh,
                        velX + slipX,
                        velY + slipY,
                        velZ
                    )

                end
            end
        end
    end

end,500,0)



-------------------------------------------------
-- CLEAN SPILL
-------------------------------------------------

addCommandHandler("wyczysc",function(player)

    if not getElementData(player,"firefighter:duty") then
        outputChatBox("Nie jesteś na służbie.",player,255,0,0)
        return
    end

    local px,py,pz = getElementPosition(player)

    for spill, data in pairs(Spills) do
        if isElement(spill) then

            local sx,sy,sz = getElementPosition(spill)

            if getDistanceBetweenPoints3D(px,py,pz,sx,sy,sz) < 3 then

                triggerClientEvent(player,"firefighter:startCleanAnim",player,spill)
                return
            end
        end
    end

    outputChatBox("Nie ma obok rozlanego płynu.",player,255,0,0)
end)

-------------------------------------------------
-- MINIGAME SUCCESS
-------------------------------------------------

addEvent("firefighter:cleanSpill",true)
addEventHandler("firefighter:cleanSpill",root,function(spill)

    if isElement(spill) then

        -- 🔥 USUŃ BLIPY PRZYPISANE DO PLAMY
        local attached = getAttachedElements(spill)
        if attached then
            for _,el in ipairs(attached) do
                if getElementType(el) == "blip" then
                    destroyElement(el)
                end
            end
        end

        destroyElement(spill)
        Spills[spill] = nil

        outputChatBox("Usunięto rozlany płyn.", client, 0,255,0)
    end
end)

addEventHandler("onPlayerLogin", root, function()
    setTimer(function(player)
        updateSpillBlipsForPlayer(player)
    end, 1000, 1, source)
end)



addEventHandler("onPlayerTeamChange", root, function()
    for spill, data in pairs(Spills) do
        for _, blip in ipairs(getAttachedElements(spill) or {}) do
            if getElementType(blip) == "blip" then

                setElementVisibleTo(blip, source, false)

                if getPlayerTeam(source) == fireTeam then
                    setElementVisibleTo(blip, source, true)
                end

            end
        end
    end
end)



-------------------------------------------------
-- QUIT CLEANUP
-------------------------------------------------
addEventHandler("onPlayerQuit", root, function()
    stopFireDuty(source)

    for veh, owner in pairs(DutyVehicles) do
        if owner == source then
            if isElement(veh) then
                destroyElement(veh)
            end
            DutyVehicles[veh] = nil
        end
    end

    PlacedObjects[source] = nil
end)


addEventHandler("onPlayerWasted", root,
    function()
        local player = source

        if getPlayerTeam(player) ~= fireTeam then
            return
        end

        setTimer(function(player)
            if not isElement(player) then return end

            spawnPlayer(
                player,
                fireRespawnPos[1],
                fireRespawnPos[2],
                fireRespawnPos[3],
                0,
                getElementModel(player),
                0,
                0
            )

            fadeCamera(player, true)
            setCameraTarget(player, player)

            -- zachowanie duty
            setElementData(player, "firefighter:duty", true)

        end, 3000, 1, player)
    end
)


addEventHandler("onResourceStart", resourceRoot, function()
    setTimer(createSpills, 1000, 1)
end)