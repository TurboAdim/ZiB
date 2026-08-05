Criminals = {}
StealVehicles = {}
PlayerMission = {}
MissionVehicles = {}

local criminalTeam = getTeamFromName("Praca - Kryminalista")
if not criminalTeam then
    criminalTeam = createTeam("Praca - Kryminalista", 120,220,255)
end

local drift = getTeamFromName("ZMIENNY23 - Gracze")
local policeTeam = getTeamFromName("Policja")

----------------------------------------------------
-- EVENTS
----------------------------------------------------

addEvent("criminal:startJob", true)
addEvent("criminal:stopJob", true)

addEvent("criminal:minigameSuccess", true)
addEvent("criminal:minigameFailed", true)


----------------------------------------------------
-- RESPAWN CONTROL
----------------------------------------------------

local respawnTimer = false

----------------------------------------------------
-- START MARKER
----------------------------------------------------

local startMarker = createMarker(
    Config.StartMarker[1],
    Config.StartMarker[2],
    Config.StartMarker[3],
    "cylinder",
    1.3,
    120,220,255,150
)

createBlipAttachedTo(startMarker, 55)
setElementData(startMarker, "criminal:start", true)

----------------------------------------------------
-- HIDE MARKER
----------------------------------------------------

local hideMarker = createMarker(
    Config.HideVehicle[1],
    Config.HideVehicle[2],
    Config.HideVehicle[3],
    "cylinder",
    5,
    120,220,255,150
)

local hideBlip = createBlipAttachedTo(hideMarker, 55)
setElementVisibleTo(hideBlip, root, false)

----------------------------------------------------
-- MISSION MARKER
----------------------------------------------------

local missionMarker = createMarker(
    1998.32, 2300.75, 10.32,
    "cylinder",
    1.5,
    170, 0, 255, 120
)



--[[function isPoliceOnline()

    local team = getTeamFromName("Policja")
    if not team then return false end

    local players = getPlayersInTeam(team)

    for _,p in ipairs(players) do
        if isElement(p) then
            return true
        end
    end

    return false
end--]]





----------------------------------------------------
-- VEHICLE CREATION SAFE WRAPPER
----------------------------------------------------

function spawnStealVehicle(v)

    local veh = createCustomVehicle(v.model, v.x, v.y, v.z)

    if not veh then
        outputDebugString("[Kryminalista] Failed spawn vehicle: "..tostring(v.model), 1)
        return nil
    end

    setElementRotation(veh, v.rx, v.ry, v.rz)
    setElementData(veh, "criminal:stealVehicle", true)
	setElementData(veh, "criminal:displayName", v.name)
    setElementFrozen(veh, true)

    table.insert(StealVehicles, {
    vehicle = veh
    })

    return veh
end

----------------------------------------------------
-- CREATE STEAL VEHICLES
----------------------------------------------------

function createStealVehicles()

    for _,v in ipairs(Config.StealVehicles) do

        local found = false

        for _,veh in ipairs(getElementsByType("vehicle")) do

            local x,y,z = getElementPosition(veh)

            if getDistanceBetweenPoints3D(x,y,z,v.x,v.y,v.z) < 3 then
                found = true
                break
            end
        end

        if not found then
            spawnStealVehicle(v)
        end
    end
end

----------------------------------------------------
-- INITIAL SPAWN
----------------------------------------------------

createStealVehicles()





function getRandomMissionVehicle(player)

    local freeVehicles = {}

    for _, veh in ipairs(getElementsByType("vehicle")) do

        if getElementData(veh, "criminal:stealVehicle") then

            if not MissionVehicles[veh] then
                table.insert(freeVehicles, veh)
            end

        end
    end

    if #freeVehicles == 0 then
        return nil
    end

    local veh = freeVehicles[math.random(#freeVehicles)]

    MissionVehicles[veh] = player

    return veh
end

function createMissionForPlayer(player)

    local data = Criminals[player]
    if not data then return end

    -- gracz ma już aktywne zlecenie
    if data.missionVehicle then
        outputChatBox(
            "[Kryminalista] Masz już aktywne zlecenie.",
            player,
            255, 200, 0
        )
        return
    end

    local target = getRandomMissionVehicle(player)

    if not target then
        outputChatBox(
            "[Kryminalista] Brak wolnych pojazdów do kradzieży.",
            player,
            255, 0, 0
        )
        return
    end

    --data.missionVehicle = target

    local x, y, z = getElementPosition(target)

    local zone = getZoneName(x, y, z)
    local city = getZoneName(x, y, z, true)

    local vehicleName = getElementData(target, "criminal:displayName")
        or getVehicleNameFromModel(getElementModel(target))

    data.missionZone = zone
    data.missionVehicleName = vehicleName

    local areaSize = math.random(150, 250)

    local offsetX = math.random(-60, 0)
    local offsetY = math.random(-60, 0)

    local areaX = x + offsetX
    local areaY = y + offsetY

    outputChatBox("#C060FF==============================", player, 255,255,255, true)
    outputChatBox("#C060FF        ZLECENIE", player, 255,255,255, true)
    outputChatBox("#FFFFFFKlient poszukuje: #FFD700"..vehicleName, player, 255,255,255, true)
    outputChatBox("#FFFFFFOstatnio widziany:", player, 255,255,255, true)
    outputChatBox("#00BFFF"..zone.." ("..city..")", player, 255,255,255, true)
    outputChatBox("#C060FF==============================", player, 255,255,255, true)

    triggerClientEvent(
        player,
        "criminal:createMissionArea",
        player,
        areaX,
        areaY,
        areaSize,
        areaSize
    )
end

addEventHandler("onMarkerHit", missionMarker,

function(hit)

    if getElementType(hit) ~= "player" then return end

    if getPlayerTeam(hit) ~= criminalTeam then return end
	
	if isPedInVehicle(hit) then
    outputChatBox(
        "[Kryminalista] Opuść pojazd, aby odebrać zlecenie.",
        hit,
        255,50,50
    )
    return
end

    createMissionForPlayer(hit)

end)

----------------------------------------------------
-- CRIMINAL BLIP UPDATE
----------------------------------------------------

function updateCriminalBlips(player)
    

    setElementVisibleTo(hideBlip, player, true)
end

----------------------------------------------------
-- START JOB
----------------------------------------------------

function criminalStartJob(model, skin)

    local player = client

    if Criminals[player] then return end

    --[[if not isPoliceOnline() then
        outputChatBox("[Kryminalista] Brak policji na służbie!", player, 255,50,50)
        return
    end--]]

    if not drift then
        drift = getTeamFromName("ZMIENNY23 - Gracze")
    end

    local spawn = Config.Spawn

    local veh = createCustomVehicle(model, spawn[1], spawn[2], spawn[3])
    if not veh then return end

    setElementRotation(veh, spawn[4], spawn[5], spawn[6])

    local oldSkin = getElementModel(player)

    setElementModel(player, skin)
    warpPedIntoVehicle(player, veh)

    setPlayerTeam(player, criminalTeam)

    Criminals[player] = {
    vehicle = veh,
    stolenVehicle = nil,
    missionVehicle = nil,
    policeBlip = nil,
    missionArea = nil,
    earned = 0,
    oldSkin = oldSkin
}

    updateCriminalBlips(player)
	--[[local target = getRandomMissionVehicle(player)

if not target then
    outputChatBox("[Kryminalista] Brak wolnych pojazdów do kradzieży.", player, 255,0,0)
    stopCriminalJob(player)
    return
end

Criminals[player].missionVehicle = target
local x, y, z = getElementPosition(target)
local areaSize = math.random(150, 250)

local offsetX = math.random(-60, 0)
local offsetY = math.random(-60, 0)

local areaX = x + offsetX
local areaY = y + offsetY

local zone = getZoneName(x, y, z)
local city = getZoneName(x, y, z, true)

local model = getElementModel(target)
local vehicleName = getVehicleNameFromModel(model)

Criminals[player].missionZone = zone
Criminals[player].missionVehicleName = vehicleName

outputChatBox("#C060FF==============================", player, 255,255,255, true)
outputChatBox("#C060FF        ZLECENIE", player, 255,255,255, true)
outputChatBox("#FFFFFFKlient poszukuje: #FFD700"..vehicleName, player, 255,255,255, true)
outputChatBox("#FFFFFFOstatnio widziany:", player, 255,255,255, true)
outputChatBox("#00BFFF"..zone.." ("..city..")", player, 255,255,255, true)
outputChatBox("#C060FF==============================", player, 255,255,255, true)

triggerClientEvent(player,"criminal:createMissionArea",player,areaX,areaY,areaSize,areaSize)
end--]]

addEventHandler("criminal:startJob", root, criminalStartJob)

----------------------------------------------------
-- VEHICLE ENTER CHECK
----------------------------------------------------

addEventHandler("onVehicleStartEnter", root,
function(player)

    if not getElementData(source, "criminal:stealVehicle") then return end

    if getPlayerTeam(player) ~= criminalTeam then
        cancelEvent()
        outputChatBox("[Kryminalista] Ten pojazd jest celem kradzieży.", player, 255,0,0)
    end
end)

----------------------------------------------------
-- VEHICLE ENTER LOGIC
----------------------------------------------------

addEventHandler("onVehicleEnter", root,
function(player, seat)

    if seat ~= 0 then return end
    if not getElementData(source, "criminal:stealVehicle") then return end

    local data = Criminals[player]
    if not data then return end
	
	if source ~= data.missionVehicle then
    outputChatBox(
        "[Kryminalista] To nie jest pojazd wskazany przez klienta.",
        player,
        255, 50, 50
    )
    removePedFromVehicle(player)
    return
end

    setElementFrozen(source, true)

    data.stolenVehicle = source
    data.waitingForMinigame = true

    triggerClientEvent(player,"criminal:startLockpickMinigame",player,source)

    -- remove blip 12
    for k,v in ipairs(StealVehicles) do
        if v.vehicle == source then
            --safeDestroy(v.blip)
            table.remove(StealVehicles, k)
            break
        end
    end

    -- police alert
    if policeTeam then
        for _,p in ipairs(getPlayersInTeam(policeTeam)) do
            local blip = createBlipAttachedTo(source, 55)
            triggerClientEvent(p, "criminal:playPoliceSound", resourceRoot)
            data.policeBlip = blip
        end
    end

    --outputChatBox("[Kryminalista] Dostarcz pojazd do kryjówki.", player, 0,255,0)
end)



addEventHandler("criminal:minigameSuccess", root,
function(vehicle)

    local player = client

    local data = Criminals[player]
    if not data then return end

    if vehicle ~= data.stolenVehicle then
        return
    end

    data.waitingForMinigame = nil

    if isElement(vehicle) then
        setElementFrozen(vehicle, false)
    end

    outputChatBox(
        "[Kryminalista] Udało Ci się uruchomić pojazd.",
        player,
        0,255,0
    )

    outputChatBox(
        "[Kryminalista] Dostarcz pojazd do kryjówki.",
        player,
        0,255,0
    )
end)


addEventHandler("criminal:minigameFailed", root,
function(vehicle)

    local player = client

    local data = Criminals[player]
    if not data then return end

    if vehicle ~= data.stolenVehicle then
        return
    end

    data.stolenVehicle = nil
    data.waitingForMinigame = nil

    if isPedInVehicle(player) then
        removePedFromVehicle(player)
    end

    outputChatBox(
        "[Kryminalista] Nie udało się uruchomić pojazdu.",
        player,
        255,0,0
    )
end)



----------------------------------------------------
-- HIDE DELIVERY
----------------------------------------------------

addEventHandler("onMarkerHit", hideMarker,
function(hit)

    if getElementType(hit) ~= "vehicle" then return end

    local player = getVehicleOccupant(hit)
    if not player then return end

    local data = Criminals[player]
    if not data then return end

    if hit ~= data.stolenVehicle then return end

    outputChatBox("[Kryminalista] Chowamy samochód pod kocem", player, 255,255,0)

    setElementFrozen(hit, true)

    setTimer(function()

        if not isElement(hit) then return end

        setElementFrozen(hit, false)

        setElementPosition(
            data.vehicle,
            2004.9022216797,
            2280.5900878906,
            10.671875
        )
		
		local model = getElementModel(data.stolenVehicle)
local reward = calculateReward(model)

data.earned = (data.earned or 0) + reward

outputChatBox(
    "[Kryminalista] +$"..reward.." za dostawę pojazdu",
    player,
    0,255,0
)

        setElementRotation(data.vehicle, 0,0,90)

        safeDestroy(data.policeBlip)
		MissionVehicles[hit] = nil
        data.missionVehicle = nil

        destroyElement(hit)
        data.stolenVehicle = nil
		
		
		triggerClientEvent(player,"criminal:clearMissionArea",player)

        ----------------------------------------------------
        -- RESPAWN DELAY SYSTEM
        ----------------------------------------------------

        setTimer(function()
    createStealVehicles()
end, 120000, 1)

    end, 5000, 1)
end)

----------------------------------------------------
-- STOP JOB
----------------------------------------------------

function stopCriminalJob(player)
    
	if data.missionVehicle then
       MissionVehicles[data.missionVehicle] = nil
    end
	
    local data = Criminals[player]
    if not data then return end

    -- usuń auta / blipy
    if isElement(data.vehicle) then
        destroyElement(data.vehicle)
    end

    if isElement(data.policeBlip) then
        destroyElement(data.policeBlip)
    end

    -- 🔥 PRZYWRÓCENIE SKINA
    if data.oldSkin then
        setElementModel(player, data.oldSkin)
    end

    Criminals[player] = nil

    -- team powrót
    if drift then
        setPlayerTeam(player, drift)
    end

    outputChatBox("[Kryminalista] Zakończyłeś pracę.", player, 255,100,100)
end

addEventHandler("criminal:stopJob", root, function()
    stopCriminalJob(client)
end)



function calculateReward(vehicleModel)
    -- widełki nagród zależne od auta
    if vehicleModel == 60122 then
        return math.random(1200, 2000)
    elseif vehicleModel == 60160 then
        return math.random(1800, 2800)
    else
        return math.random(1000, 1500)
    end
end





----------------------------------------------------
-- QUIT / EXPLODE
----------------------------------------------------

addEventHandler("onPlayerQuit", root, function()

    local data = Criminals[source]
    if not data then return end

    if data.oldSkin then
        setElementModel(source, data.oldSkin)
    end

    if isElement(data.vehicle) then
        destroyElement(data.vehicle)
    end

    if isElement(data.policeBlip) then
        destroyElement(data.policeBlip)
    end

    Criminals[source] = nil
end)

addEventHandler("onVehicleExplode", root, function()

    for player, data in pairs(Criminals) do

        if source == data.vehicle or source == data.stolenVehicle then
            stopCriminalJob(player)
        end
    end
end)


addEvent("criminal:collectMoney", true)
addEventHandler("criminal:collectMoney", root,
function()
    local player = client
    local data = Criminals[player]
    if not data then return end

    if not data.earned or data.earned <= 0 then
        outputChatBox("[Kryminalista] Brak pieniędzy do odbioru.", player, 255,0,0)
        return
    end

    givePlayerMoney(player, data.earned)

    outputChatBox("[Kryminalista] Odebrano $"..data.earned, player, 0,255,0)

    data.earned = 0
end)


addEvent("criminal:requestOpenPanel", true)
addEventHandler("criminal:requestOpenPanel", root, function()
    triggerClientEvent(client, "criminal:openPanel", client)
end)

----------------------------------------------------
-- RESOURCE STOP CLEANUP
----------------------------------------------------

addEventHandler("onResourceStop", resourceRoot, function()

    -- usuwanie aut do kradzieży
    for _,data in ipairs(StealVehicles) do

        if isElement(data.vehicle) then
            destroyElement(data.vehicle)
        end

    end

    -- usuwanie pojazdów graczy
    for player,data in pairs(Criminals) do

        if isElement(data.vehicle) then
            destroyElement(data.vehicle)
        end

        if isElement(data.stolenVehicle) then
            destroyElement(data.stolenVehicle)
        end

        if isElement(data.policeBlip) then
            destroyElement(data.policeBlip)
        end

        -- przywrócenie teamu
        if isElement(player) and drift then
            setPlayerTeam(player, drift)
        end

        -- przywrócenie skina
        if isElement(player) and data.oldSkin then
            setElementModel(player, data.oldSkin)
        end
    end

    -- cleanup tabel
    Criminals = {}
    StealVehicles = {}

end)
