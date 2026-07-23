local playersJob = {}

----------------------------------------------------
-- TEAM
----------------------------------------------------

local forkliftTeam =
    getTeamFromName("Praca - Wózkowy")

if not forkliftTeam then

    forkliftTeam = createTeam(
        "Praca - Wózkowy",
        120,220,255
    )
end

setTeamFriendlyFire(forkliftTeam, false)



local vehicleMods = {
    {255,0,0,1073},
    {255,255,0,1074},
    {0,0,255,1081},
    {0,255,0,1085}
}


----------------------------------------------------
-- LOKALIZACJE
----------------------------------------------------

local startPos = {
    2837.1,
    855.3,
    9.815
}

local vehicleSpawn = {
    2865.9174804688,
    866.596467285156,
    10.8
}

local pickupPos = {
    2865.3955078125,
    849.59692382812,
    9.815
}

local deliveryPoints = {
    {2861.0463867188,877.98822021484,9.815},
    {2857.2224121094,886.81048583984,9.815},
    {2838.3449707031,886.59991455078,9.815},
    {2832.4787597656,895.39752197266,9.815},
	{2837.8513183594,913.91082763672,9.815},
	
	
	{2859.81541796875,913.929748535161,9.815},
    {2855.9716796875,923.83898925781,9.815},
    {2855.0002441406,942.73931884766,9.815},
    {2832.8845214844,950.81494140625,9.815},
	{2853.6645507812,951.14593505859,9.815},
	
	
	{2860.017578125,951.14593505859,9.815},
    {2856.1843261719,970.52520751953,9.815},
    {2832.9975585938,970.06384277344,9.815},
    {2822.9392089844,991.88824462891,9.815},
	{2839.1799316406,991.51049804688,9.815},
	
	{2852.6303710938,984.91040039062,9.815},
	{2872.3205566406,991.31713867188,9.815},
	{2867.3774414062,991.54205322266,9.815},
}

----------------------------------------------------
-- START MARKER
----------------------------------------------------

local startMarker = createMarker(
    startPos[1],
    startPos[2],
    startPos[3],
    "cylinder",
    2.5,
    180,0,255,150
)

setElementData(startMarker, "forklift:job", true)

createBlipAttachedTo(startMarker, 51)

----------------------------------------------------
-- DOZWOLONE POJAZDY
----------------------------------------------------

local allowedVehicles = {
    [530] = true
    --[60200] = true
}

----------------------------------------------------
-- TWORZENIE POJAZDU
----------------------------------------------------

function createForkliftVehicle(model, x, y, z)

    if not model then return false end

    local veh
    local c = vehicleMods[math.random(#vehicleMods)]

    if tonumber(model) > 611 then
        veh = exports["newmodels_red"]:createVehicle(tonumber(model), x, y, z)
    else
        veh = createVehicle(tonumber(model), x, y, z)
    end

    if veh then
        setVehicleColor(veh, c[1], c[2], c[3])
        addVehicleUpgrade(veh, c[4])
    end

    return veh
end

----------------------------------------------------
-- START PRACY
----------------------------------------------------

function startForkliftJob(vehicleID)

    local player = client

    if not vehicleID then

        outputChatBox(
            "Nie wybrano pojazdu.",
            player,
            255,0,0
        )

        return
    end

    if not allowedVehicles[vehicleID] then

        outputChatBox(
            "Nieprawidłowy pojazd.",
            player,
            255,0,0
        )

        return
    end

    if playersJob[player] then

        outputChatBox(
            "Masz już rozpoczętą pracę.",
            player,
            255,0,0
        )

        return
    end

    local veh = createForkliftVehicle(
        vehicleID,
        vehicleSpawn[1],
        vehicleSpawn[2],
        vehicleSpawn[3]
    )

    if not veh then

        outputChatBox(
            "Nie udało się utworzyć pojazdu.",
            player,
            255,0,0
        )

        return
    end

    warpPedIntoVehicle(player, veh)

    setElementDimension(player, 0)
    setElementDimension(veh, 0)

    -- TRYB DUCHA
    setElementAlpha(player, 180)
    setElementCollisionsEnabled(player, false)

    local data = {
        vehicle = veh,
        carrying = false,
        crate = nil,
        pickupMarker = nil,
        pickupBlip = nil,
        deliveryMarker = nil,
        deliveryBlip = nil,
        leaveTimer = nil,
        oldTeam = getPlayerTeam(player)
    }

    playersJob[player] = data

    setPlayerTeam(player, forkliftTeam)

    createPickupMarker(player)

    outputChatBox(
        "Rozpoczęto pracę operatora wózka.",
        player,
        0,255,0
    )
end
addEvent("forklift:startJob", true)
addEventHandler("forklift:startJob", root, startForkliftJob)

----------------------------------------------------
-- STOP PRACY
----------------------------------------------------

function stopForkliftJob(player)

    if not isElement(player) then
        return
    end

    local data = playersJob[player]
    if not data then return end

    if isElement(data.vehicle) then
        destroyElement(data.vehicle)
    end

    if isElement(data.crate) then
        destroyElement(data.crate)
    end

    if isElement(data.pickupMarker) then
        destroyElement(data.pickupMarker)
    end

    if isElement(data.pickupBlip) then
        destroyElement(data.pickupBlip)
    end

    if isElement(data.deliveryMarker) then
        destroyElement(data.deliveryMarker)
    end

    if isElement(data.deliveryBlip) then
        destroyElement(data.deliveryBlip)
    end

    if isTimer(data.leaveTimer) then
        killTimer(data.leaveTimer)
    end

    setElementAlpha(player, 255)
    setElementCollisionsEnabled(player, true)

    if data.oldTeam and isElement(data.oldTeam) then
        setPlayerTeam(player, data.oldTeam) 
    else

        local drftTeam =
            getTeamFromName("drft")

        if drftTeam then
            setPlayerTeam(player, drftTeam)
        else
            setPlayerTeam(player, nil)
        end
    end

    playersJob[player] = nil

    outputChatBox(
        "Zakończono pracę.",
        player,
        255,100,100
    )
end
addEvent("forklift:stopJob", true)
addEventHandler("forklift:stopJob", root,
    function()
        stopForkliftJob(client)
    end
)

----------------------------------------------------
-- POBRANIE ŁADUNKU
----------------------------------------------------

function createPickupMarker(player)

    local data = playersJob[player]
    if not data then return end

    local marker = createMarker(
        pickupPos[1],
        pickupPos[2],
        pickupPos[3],
        "cylinder",
        3,
        255,255,0,150
    )

    local blip = createBlipAttachedTo(marker, 41)

    -- TYLKO DLA TEGO GRACZA
    setElementVisibleTo(marker, root, false)
    setElementVisibleTo(blip, root, false)

    setElementVisibleTo(marker, player, true)
    setElementVisibleTo(blip, player, true)

    data.pickupMarker = marker
    data.pickupBlip = blip

    addEventHandler("onMarkerHit", marker,
        function(hitElement)

            if hitElement ~= data.vehicle then
                return
            end

            if data.carrying then
                return
            end

            ----------------------------------------------------
            -- FREEZE 3 SEKUNDY
            ----------------------------------------------------

            setElementFrozen(data.vehicle, true)
            setElementFrozen(player, true)

            outputChatBox(
                "Ładowanie towaru...",
                player,
                255,255,0
            )

            setTimer(function()

                if not playersJob[player] then return end
                if not isElement(data.vehicle) then return end

                setElementFrozen(data.vehicle, false)
                setElementFrozen(player, false)

                data.carrying = true

                local crate = createObject(
                    2973,
                    pickupPos[1],
                    pickupPos[2],
                    pickupPos[3]
                )

                attachElements(
                    crate,
                    data.vehicle,
                    0,
                    1,
                    0
                )

                data.crate = crate

                if isElement(marker) then
                    destroyElement(marker)
                end

                if isElement(blip) then
                    destroyElement(blip)
                end

                createDeliveryMarker(player)

                outputChatBox(
                    "Załadowano skrzynię.",
                    player,
                    0,255,0
                )

            end, 3000, 1)
        end
    )
end



----------------------------------------------------
-- DOSTAWA
----------------------------------------------------

function createDeliveryMarker(player)

    local data = playersJob[player]
    if not data then return end

    local rand = math.random(1,#deliveryPoints)
    local pos = deliveryPoints[rand]

    local marker = createMarker(
        pos[1],
        pos[2],
        pos[3],
        "cylinder",
        3,
        0,255,0,150
    )

    local blip = createBlipAttachedTo(marker, 19)

    -- TYLKO DLA TEGO GRACZA
    setElementVisibleTo(marker, root, false)
    setElementVisibleTo(blip, root, false)

    setElementVisibleTo(marker, player, true)
    setElementVisibleTo(blip, player, true)

    data.deliveryMarker = marker
    data.deliveryBlip = blip

    addEventHandler("onMarkerHit", marker,
        function(hitElement)

            if hitElement ~= data.vehicle then
                return
            end

            if not data.carrying then
                return
            end

            ----------------------------------------------------
            -- FREEZE 3 SEKUNDY
            ----------------------------------------------------

            setElementFrozen(data.vehicle, true)
            setElementFrozen(player, true)

            outputChatBox(
                "Rozładowywanie towaru...",
                player,
                255,255,0
            )

            setTimer(function()

                if not playersJob[player] then return end
                if not isElement(data.vehicle) then return end

                setElementFrozen(data.vehicle, false)
                setElementFrozen(player, false)

                data.carrying = false

                if isElement(data.crate) then
                    destroyElement(data.crate)
                end

                if isElement(marker) then
                    destroyElement(marker)
                end

                if isElement(blip) then
                    destroyElement(blip)
                end

                local money = math.random(200,500)

                givePlayerMoney(player, money)

                outputChatBox(
                    "Otrzymujesz $"..money,
                    player,
                    0,255,0
                )

                createPickupMarker(player)

            end, 3000, 1)
        end
    )
end

----------------------------------------------------
-- WYJŚCIE Z POJAZDU
----------------------------------------------------

addEventHandler("onVehicleExit", root,
    function(player)

        local data = playersJob[player]
        if not data then return end
        if source ~= data.vehicle then return end

        outputChatBox(
            "Masz 20 sekund na powrót do pojazdu!",
            player,
            255,50,50
        )

        data.leaveTimer = setTimer(function()

            local job = playersJob[player]
            if not job then return end

            stopForkliftJob(player)

            givePlayerMoney(player, -1000)

            outputChatBox(
                "Nie wróciłeś do pojazdu (-1000$)",
                player,
                255,0,0
            )

        end, 20000, 1)
    end
)



----------------------------------------------------
-- POWRÓT
----------------------------------------------------

addEventHandler("onVehicleEnter", root,
    function(player)

        local data = playersJob[player]
        if not data then return end

        if source ~= data.vehicle then
            return
        end

        if isTimer(data.leaveTimer) then
            killTimer(data.leaveTimer)
        end
    end
)

----------------------------------------------------
-- QUIT
----------------------------------------------------

addEventHandler("onPlayerQuit", root,
    function()

        if playersJob[source] then

            local data = playersJob[source]

            if isElement(data.vehicle) then
                destroyElement(data.vehicle)
            end
        end

        playersJob[source] = nil
    end
)


addEventHandler("onResourceStart", root, function(res)

    local name = getResourceName(res)

    if name == "freeroam" or name == "hedit" then

        for player,_ in pairs(playersJob) do
            stopForkliftJob(player)
            givePlayerMoney(player, -1000)
        end

        outputDebugString("[FORKLIFT] Zablokowano cheat resource: "..name)
    end
end)

----------------------------------------------------
-- CLEANUP
----------------------------------------------------

addEventHandler("onPlayerQuit", root,
    function()

        if playersJob[source] then
            stopForkliftJob(source)
        end

    end
)