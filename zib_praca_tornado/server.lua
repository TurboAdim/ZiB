TornadoPlayers = {}
TornadoVehicles = {}
TornadoSkins = {}
RadarBlips = {}
SampleCooldown = {}


local tornadoFrozen = false
local tornadoFreezeUntil = 0
local tornadoDestroyedBySample = false
local tornadoDestroyer = nil


if type(TornadoPlayers) ~= "table" then return end

local tornadoTeam =
    getTeamFromName(Config.TeamName)

if not tornadoTeam then

    tornadoTeam = createTeam(
        Config.TeamName,
        120,220,255
    )

end

local tornado = nil
local tornadoForce = nil
local tornadoSize = 26
local tornadoOwner = nil

local tornadoRoute = nil
local tornadoRouteIndex = 1

local tornadoMoveSpeed = 1.2

local tornadoActive = false
local tornadoMoving = false
local nextTornadoTimer = nil






function destroyCurrentTornado()
    if not tornadoDestroyedBySample then
           tornadoDestroyer = nil
    end
    if isElement(tornado) then
        destroyElement(tornado)
    end

    if isElement(tornadoForce) then
        destroyElement(tornadoForce)
    end

    tornado = nil
    tornadoForce = nil

    tornadoRoute = nil
    tornadoRouteIndex = 1

    tornadoActive = false
    tornadoMoving = false

    tornadoFrozen = false
    tornadoFreezeUntil = 0

    tornadoSize = 26

    setWeather(6)
    setWeatherBlended(6)

    triggerClientEvent(
        root,
        "tornado:updateRadar",
        resourceRoot,
        99999,99999,0,0
    )

    scheduleNextTornado()
end

-------------------------------------------------
-- MARKER
-------------------------------------------------

local marker = createMarker(
    Config.Marker[1],
    Config.Marker[2],
    Config.Marker[3]-1,
    "cylinder",
    2,
    120,220,255,150
)
local markerBlip = createBlip(
    Config.Marker[1],
    Config.Marker[2],
    Config.Marker[3],
    3
)

setElementData(marker,"tornado:jobmarker",true)

-------------------------------------------------
-- GUI
-------------------------------------------------
-------------------------------------------------
-- CREATE VEHICLE
-------------------------------------------------

function createTornadoVehicle(model,x,y,z,rx,ry,rz)

    model = tonumber(model)

    local veh

    -------------------------------------------------
    -- CUSTOM MODEL
    -------------------------------------------------

    if model > 611 then

        veh = exports["newmodels_red"]:createVehicle(
            model,
            x,y,z
        )

        if not veh then
            outputDebugString("[TORNADO] Failed create custom vehicle "..model,1)
            return false
        end

        setElementData(
            veh,
            "newmodels:model",
            model
        )

    -------------------------------------------------
    -- NORMAL MODEL
    -------------------------------------------------

    else

        veh = createVehicle(
            model,
            x,y,z,
            rx,ry,rz
        )

    end

    if not veh then
        return false
    end

    setElementRotation(
        veh,
        rx,ry,rz
    )

    setVehicleDamageProof(veh,false)

    return veh
end

-------------------------------------------------
-- SET SKIN
-------------------------------------------------

function setTornadoSkin(p,skin)

    skin = tonumber(skin)

    if skin > 311 then

        exports["newmodels_red"]:setElementModel(
            p,
            skin
        )

        setElementData(
            p,
            "newmodels:model",
            skin
        )

    else

        setElementModel(p,skin)

        removeElementData(
            p,
            "newmodels:model"
        )

    end
end

addEvent("tornado:requestGUI", true)
addEventHandler("tornado:requestGUI", root, function()

    if client and isElement(client) then
        triggerClientEvent(
            client,
            "tornado:openGUI",
            resourceRoot,
            Config.Vehicles,
            Config.Skins
        )
    end
end)

-------------------------------------------------
-- START JOB
-------------------------------------------------

addEvent("tornado:startJob",true)
addEventHandler("tornado:startJob",root,
function(vehicleID,skinID)
    if not client or not isElement(client) then return end
	
    local p = client

    local vehData = Config.Vehicles[vehicleID]
    local skinData = Config.Skins[skinID]

    if not vehData or not skinData then
        return
    end

    local spawn =
        Config.Spawns[
            math.random(#Config.Spawns)
        ]

    local veh = createTornadoVehicle(
    vehData.model,
    spawn[1],
    spawn[2],
    spawn[3],
    spawn[4],
    spawn[5],
    spawn[6]
)

if not veh then
    return
end

    warpPedIntoVehicle(p,veh)

    TornadoSkins[p] = getElementModel(p)

setTornadoSkin(
    p,
    skinData.skin
)

    setPlayerTeam(p,tornadoTeam)

    setElementData(p,"tornado:duty",true)

    setElementData(veh,"tornado:class",vehData.class)

    TornadoPlayers[p] = {
        vehicle = veh
    }

    TornadoVehicles[veh] = p

    triggerClientEvent(
        p,
        "tornado:setWorking",
        resourceRoot,
        true
    )

end)

-------------------------------------------------
-- STOP JOB
-------------------------------------------------

function stopTornadoJob(p)

    if not isElement(p) then
        return
    end

    if not TornadoPlayers[p] then
        return
    end

    local data = TornadoPlayers[p]

    -------------------------------------------------
    -- VEHICLE
    -------------------------------------------------

    if isElement(data.vehicle) then
        destroyElement(data.vehicle)
    end

    TornadoVehicles[data.vehicle] = nil

    -------------------------------------------------
    -- TEAM
    -------------------------------------------------

    local drift = getTeamFromName("ZMIENNY23 - Gracze")
    if drift then
         setPlayerTeam(p, drift)
    else
         setPlayerTeam(p, nil)
    end

    -------------------------------------------------
    -- DUTY
    -------------------------------------------------

    setElementData(p,"tornado:duty",false)

    -------------------------------------------------
    -- SKIN RESTORE
    -------------------------------------------------

    if TornadoSkins[p] then

        local oldSkin =
            tonumber(TornadoSkins[p])

        if oldSkin > 311 then

            exports["newmodels_red"]:setElementModel(
                p,
                oldSkin
            )

            setElementData(
                p,
                "newmodels:model",
                oldSkin
            )

        else

            setElementModel(
                p,
                oldSkin
            )

            removeElementData(
                p,
                "newmodels:model"
            )

        end

        TornadoSkins[p] = nil
    end

    -------------------------------------------------
    -- BLIP
    -------------------------------------------------

    if isElement(RadarBlips[p]) then
        destroyElement(RadarBlips[p])
    end

    RadarBlips[p] = nil

    TornadoPlayers[p] = nil

    triggerClientEvent(
        p,
        "tornado:setWorking",
        resourceRoot,
        false
    )
	triggerClientEvent(p, "tornado:clearRadar", resourceRoot)
end

addEvent("tornado:stopJob",true)
addEventHandler("tornado:stopJob",root,
function()

    stopTornadoJob(client)

end)

-------------------------------------------------
-- QUIT
-------------------------------------------------

addEventHandler("onPlayerQuit",root,
function()

    stopTornadoJob(source)

end)

-------------------------------------------------
-- TORNADO
-------------------------------------------------

function createTornado()

    if tornadoActive then
        return
    end

    if not Config.TornadoRoutes
    or #Config.TornadoRoutes == 0 then

        outputDebugString("[TORNADO] Brak tras!",1)
        return
    end

    local route =
        Config.TornadoRoutes[
            math.random(#Config.TornadoRoutes)
        ]

    if not route[1] or not route[2] then
        outputDebugString("[TORNADO] Trasa musi mieć punkt A i B!",1)
        return
    end

    tornadoRoute = route

    local startPos = route[1]

    local x = startPos[1]
    local y = startPos[2]

    tornadoSize = 26

tornado = createMarker(
    x,
    y,
    15,
    "checkpoint",
    tornadoSize,
    120,120,120,180
)

-------------------------------------------------
-- NIEWIDZIALNA STREFA SIŁY
-------------------------------------------------

tornadoForce = createMarker(
    x,
    y,
    15,
    "cylinder",
    tornadoSize + 25, -- TUTAJ zmieniasz średnicę
    0,0,0,0
)

    if not tornado then
        return
    end

    tornadoActive = true
    tornadoMoving = false
	

    tornadoFrozen = true
    tornadoFreezeUntil = getTickCount() + 10000

    setWeather(8)
    setWeatherBlended(16)

    outputChatBox(
        "[TORNADO] Wykryto tornado!",
        root,
        255,0,0,
        true
    )

    for _,p in ipairs(getPlayersInTeam(tornadoTeam)) do

        triggerClientEvent(
            p,
            "tornado:alarm",
            resourceRoot
        )
		
		tornadoDestroyedBySample = false
        tornadoDestroyer = nil
		
    end
end

-------------------------------------------------
-- TIMER
-------------------------------------------------

function scheduleNextTornado()

    if isTimer(nextTornadoTimer) then
        killTimer(nextTornadoTimer)
    end

    local randomTime = math.random(
        Config.TornadoMinTime,
        Config.TornadoMaxTime
    )

    outputDebugString(
        "[TORNADO] Następne tornado za "..math.floor(randomTime / 1000).." sekund."
    )

    nextTornadoTimer = setTimer(function()

        if not tornadoActive then
            createTornado()
        end
		if not tornadoMoving then
    return
end

    end, randomTime, 1)

end

scheduleNextTornado()

-------------------------------------------------
-- GROW
-------------------------------------------------

setTimer(function()

    if isElement(tornado) then

        tornadoSize = tornadoSize + 0.5

        setMarkerSize(
            tornado,
            tornadoSize
        )
		if isElement(tornadoForce) then
        setMarkerSize(
        tornadoForce,
        tornadoSize + 25
    )
end

    end

end,10000,0)




-------------------------------------------------
-- MOVE TORNADO
-------------------------------------------------

setTimer(function()

    if not tornadoActive then
        return
    end

    if not isElement(tornado) then
        return
    end

    if not tornadoRoute then
        return
    end

    local target = tornadoRoute[2]

    if not target then
        return
    end

    -------------------------------------------------
    -- FREEZE START
    -------------------------------------------------

    if tornadoFrozen then

    if getTickCount() >= tornadoFreezeUntil then

        tornadoFrozen = false
        tornadoMoving = true

    else
        return
    end
end

    -------------------------------------------------
    -- MOVE
    -------------------------------------------------

    local x,y,z = getElementPosition(tornado)

    local tx = target[1]
    local ty = target[2]

    local dx = tx - x
    local dy = ty - y

    local dist = math.sqrt(dx*dx + dy*dy)

    if dist <= 5 then

        tornadoMoving = false
        tornadoFrozen = true
        tornadoFreezeUntil = getTickCount() + 10000

        if isTimer(tornadoEndTimer) then
    killTimer(tornadoEndTimer)
end

tornadoEndTimer = setTimer(function()

    if tornadoActive then
        destroyCurrentTornado()
    end

end,10000,1)

        return
    end

    local moveX = (dx / dist) * tornadoMoveSpeed
    local moveY = (dy / dist) * tornadoMoveSpeed

    local newX = x + moveX
    local newY = y + moveY

setElementPosition(
    tornado,
    newX,
    newY,
    z
)

if isElement(tornadoForce) then
    setElementPosition(
        tornadoForce,
        newX,
        newY,
        z
    )
end

end,100,0)






-------------------------------------------------
-- DAMAGE
-------------------------------------------------

addEventHandler("onMarkerHit",root,
function(hitElement)

    if source ~= tornado then
        return
    end

    if getElementType(hitElement) == "vehicle" then

        local vx,vy,vz =
            getElementVelocity(hitElement)

        setElementVelocity(
    hitElement,
    vx * 3,
    vy * 3,
    1.5
)

setElementAngularVelocity(
    hitElement,
    2,
    2,
    2
)

        blowVehicle(hitElement)

    elseif getElementType(hitElement) == "player" then

        killPed(hitElement)

    elseif getElementType(hitElement) == "object" then

        if getElementModel(hitElement) == 2918 and getElementData(hitElement,"tornado:canDestroy") then

            local owner =
                getElementData(hitElement,"tornado:owner")

            if isElement(owner) then

                tornadoDestroyedBySample = true
tornadoDestroyer = owner

givePlayerMoney(owner, 10000)

for p, data in pairs(TornadoPlayers) do
    if isElement(p) and isElement(data.vehicle) then
        if getElementData(data.vehicle,"tornado:class") == "RADAR" then
            givePlayerMoney(p, 4000)
        end
    end
end

                outputChatBox(
                    "Zniszczyłeś tornado! +"..
                    Config.DestroyReward.."$",
                    owner,
                    0,255,0
                )

            end

            destroyElement(hitElement)

            destroyCurrentTornado()

        end

    end

end)


-------------------------------------------------
-- TORNADO FORCE
-------------------------------------------------

addEventHandler("onMarkerHit",root,
function(hitElement)

    if source ~= tornadoForce then
        return
    end

    if not tornadoActive then
        return
    end

    if getElementType(hitElement) ~= "vehicle" then
        return
    end

    local vx,vy,vz =
        getElementVelocity(hitElement)

    -------------------------------------------------
    -- LEKKIE PODRZUCENIE
    -------------------------------------------------

    setElementVelocity(
        hitElement,
        vx * 1.05,
        vy * 1.05,
        math.random(20,35) / 100
    )

    -------------------------------------------------
    -- LOSOWY OBRÓT
    -------------------------------------------------

    setElementAngularVelocity(
        hitElement,
        math.random(-10,10)/10,
        math.random(-10,10)/10,
        math.random(-10,10)/10
    )

end)


-------------------------------------------------
-- PROBKA
-------------------------------------------------

addCommandHandler("probka",
function(p)

    local veh = getPedOccupiedVehicle(p)
    if not veh then return end

    if getElementData(veh,"tornado:class") ~= "CHASE" then
        outputChatBox("Tylko pojazdy CHASE.", p, 255,0,0)
        return
    end

    local now = getTickCount()

    if SampleCooldown[p] and now - SampleCooldown[p] < 60000 then
        outputChatBox("Musisz odczekać 60 sekund.", p, 255,0,0)
        return
    end

    SampleCooldown[p] = now

    if getPlayerTeam(p) ~= tornadoTeam then
        return
    end

    local veh = getPedOccupiedVehicle(p)

    if not veh then return end

    if getElementData(veh,"tornado:class") ~= "CHASE" then

        outputChatBox(
            "Tylko pojazdy gończe mogą używać próbek.",
            p,
            255,0,0
        )

        return
    end

    local x,y,z = getElementPosition(veh)

    local obj = createObject(
        2918,
        x,y-2,z-0.5
    )

    setElementData(
        obj,
        "tornado:owner",
        p
    )
	setElementData(obj, "tornado:canDestroy", true)
tornadoDestroyedBySample = false
tornadoDestroyer = p

    local rx,ry,rz =
        getElementRotation(veh)

    local vx = math.cos(math.rad(rz))*0.8
    local vy = math.sin(math.rad(rz))*0.8

    setElementVelocity(
        obj,
        vx,
        vy,
        0.1
    )

    setTimer(function()

        if isElement(obj) then
            destroyElement(obj)
        end

    end,15000,1)

end)

-------------------------------------------------
-- RADAR
-------------------------------------------------

setTimer(function()

    if not tornadoActive or not isElement(tornado) then return end

    if not TornadoPlayers then
        return
    end

    if not isElement(tornado) or not tornadoActive then
        return
    end

    local tx, ty, tz = getElementPosition(tornado)

    for p, data in pairs(TornadoPlayers) do

        if isElement(p) and data and isElement(data.vehicle) then

            local veh = data.vehicle

            if getElementData(veh, "tornado:class") == "RADAR" and TornadoVehicles[veh] then

                local x, y, z = getElementPosition(veh)

                local dist = getDistanceBetweenPoints3D(
                    x, y, z,
                    tx, ty, tz
                )

                local accuracy

if dist <= 250 and dist >= 200 then
    -- NAJLEPSZA PRECYZJA
    accuracy = 20

elseif dist < 200 then
    -- ZA BLISKO = CHAOS
    accuracy = math.random(250, 500)

else
    -- ZA DALEKO = TEŻ CHAOS
    accuracy = math.random(120, 450)
end

                for _, teamPlayer in ipairs(getPlayersInTeam(tornadoTeam)) do

                    if isElement(teamPlayer) then
                        triggerClientEvent(
                            teamPlayer,
                            "tornado:updateRadar",
                            resourceRoot,
                            tx, ty, tz,
                            accuracy
                        )
                    end
                end
            end
        end
    end

end, 3000, 0)












addEventHandler("onMarkerHit", root, function(hitElement)

    if getElementType(hitElement) ~= "player" then return end
    if source ~= marker then return end

    triggerClientEvent(
        hitElement,
        "tornado:startSound",
        resourceRoot
    )

end)































-------------------------------------------------
-- RESOURCE STOP
-------------------------------------------------

addEventHandler("onResourceStop",resourceRoot,
function()

    -------------------------------------------------
    -- pS
    -------------------------------------------------
    if isElement(markerBlip) then
        destroyElement(markerBlip)
    end


    for p,data in pairs(TornadoPlayers) do
        stopTornadoJob(p)
    end

    -------------------------------------------------
    -- TORNADO
    -------------------------------------------------

    if isElement(tornado) then
        destroyElement(tornado)
    end
	if isElement(tornadoForce) then
    destroyElement(tornadoForce)
    end

    -------------------------------------------------
    -- WEATHER
    -------------------------------------------------

    setWeatherBlended(0)

    outputDebugString(
        "[TORNADO] Cleanup zakończony."
    )

end)


-------------------------------------------------
-- REMOVE RADAR BLIPS
-------------------------------------------------

setTimer(function()

    local hasRadar = false

    for veh,_ in pairs(TornadoVehicles) do

        if isElement(veh)
        and getElementData(veh,"tornado:class") == "RADAR" then

            hasRadar = true
            break
        end
    end

    if not hasRadar then

        triggerClientEvent(
    root,
    "tornado:updateRadar",
    resourceRoot,
    99999,99999,0,0
)

    end

end,5000,0)



addEvent("tornado:clientReady", true)
addEventHandler("tornado:clientReady", root, function()
    -- client gotowy (możesz przechowywać flagę jeśli chcesz)
end)