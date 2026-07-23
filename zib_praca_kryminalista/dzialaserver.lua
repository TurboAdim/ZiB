Criminals = {}
StealVehicles = {}

----------------------------------------------------
-- EVENTS
----------------------------------------------------

addEvent("criminal:startJob", true)
addEvent("criminal:stopJob", true)

----------------------------------------------------
-- TEAM
----------------------------------------------------

local criminalTeam =
    getTeamFromName("Praca - Kryminalista")

if not criminalTeam then

    criminalTeam = createTeam(
        "Praca - Kryminalista",
        120,220,255
    )

end

----------------------------------------------------
-- START MARKER
----------------------------------------------------

local startMarker = createMarker(
    Config.StartMarker[1],
    Config.StartMarker[2],
    Config.StartMarker[3],
    "cylinder",
    1.2,
    120,220,255,150
)

createBlipAttachedTo(startMarker,55)

setElementData(startMarker,"criminal:start",true)

----------------------------------------------------
-- CREATE STEAL VEHICLES
----------------------------------------------------

function createStealVehicles()

    for _,v in ipairs(Config.StealVehicles) do

        local found = false

        for _,veh in pairs(getElementsByType("vehicle")) do

            local x,y,z = getElementPosition(veh)

            if getDistanceBetweenPoints3D(
                x,y,z,
                v.x,v.y,v.z
            ) < 3 then

                found = true
                break

            end

        end

        if not found then

            local veh = createCustomVehicle(
    v.model,
    v.x,
    v.y,
    v.z
)

if not veh then

    outputDebugString(
        "[Kryminalista] Nie udało się stworzyć pojazdu ID: "..tostring(v.model),
        1
    )

    return
end

setElementRotation(
    veh,
    v.rx,
    v.ry,
    v.rz
)

            setElementData(
                veh,
                "criminal:stealVehicle",
                true
            )
			setElementFrozen(veh,true)

            local blip = createBlipAttachedTo(
                veh,
                12
            )

            setElementVisibleTo(blip,root,false)

            table.insert(StealVehicles,{
                vehicle = veh,
                blip = blip
            })

        end

    end

end
setTimer(function()

    createStealVehicles()

end,120000,1)

----------------------------------------------------
-- START JOB
----------------------------------------------------

function criminalStartJob(model,skin)

    local player = client

    local police =
        getTeamFromName("Policja")

    if not police then
        return
    end

    local members =
        getPlayersInTeam(police)

    --[[if #members <= 0 then

        outputChatBox(
            "[Kryminalista] Nie może być za łatwo. Wróć, gdy chociaż jeden policjant będzie na służbie",
            player,
            255,50,50
        )

        return
    end--]]

    if Criminals[player] then
        return
    end

    local spawn = Config.Spawn

    local veh = createCustomVehicle(
        model,
        spawn[1],
        spawn[2],
        spawn[3]
    )

    setElementRotation(
        veh,
        spawn[4],
        spawn[5],
        spawn[6]
    )

    setElementModel(player,skin)

    warpPedIntoVehicle(player,veh)

    setPlayerTeam(player,criminalTeam)

    Criminals[player] = {
        vehicle = veh,
        stolenVehicle = nil,
        policeBlip = nil
    }

    outputChatBox(
        "[Kryminalista] Nowy złodziej na serwerze",
        root,
        255,50,50
    )
	
	setElementVisibleTo(
    hideBlip,
    player,
    true
    )
	
	
    for _,data in ipairs(StealVehicles) do

        if isElement(data.blip) then
            setElementVisibleTo(
                data.blip,
                player,
                true
            )
        end

    end

end
addEventHandler("criminal:startJob",root,criminalStartJob)

----------------------------------------------------
-- ENTER VEHICLE
----------------------------------------------------

addEventHandler("onVehicleStartEnter",root,
    function(player)

        if not getElementData(source,"criminal:stealVehicle") then
            return
        end

        if getPlayerTeam(player) ~= criminalTeam then

            cancelEvent()

            outputChatBox(
                "[Kryminalista] Ten pojazd jest celem kradzieży.",
                player,
                255,0,0
            )

            return
        end

    end
)

----------------------------------------------------
-- STOLEN
----------------------------------------------------

addEventHandler("onVehicleEnter",root,
    function(player,seat)

        if seat ~= 0 then
            return
        end
		setElementFrozen(source,false)
		

        if not getElementData(source,"criminal:stealVehicle") then
            return
        end

        local data = Criminals[player]

        if not data then
            return
        end

        data.stolenVehicle = source
		
		for _,v in ipairs(StealVehicles) do

    if v.vehicle == source then

        safeDestroy(v.blip)

        break
    end

end

        local police =
            getTeamFromName("Policja")

        if police then

            for _,p in ipairs(getPlayersInTeam(police)) do

                local blip =
                    createBlipAttachedTo(
                        source,
                        55
                    )

                triggerClientEvent(
                    p,
                    "criminal:playPoliceSound",
                    resourceRoot
                )

                data.policeBlip = blip

            end

        end

        outputChatBox(
            "[Kryminalista] Dostarcz pojazd do kryjówki.",
            player,
            0,255,0
        )

    end
)

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

local hideBlip = createBlipAttachedTo(
    hideMarker,
    55
)

setElementVisibleTo(hideBlip,root,false)

----------------------------------------------------
-- DELIVERY
----------------------------------------------------

addEventHandler("onMarkerHit",hideMarker,
    function(hit)

        if getElementType(hit) ~= "vehicle" then
            return
        end

        local player = getVehicleOccupant(hit)

        if not player then
            return
        end

        local data = Criminals[player]

        if not data then
            return
        end

        if hit ~= data.stolenVehicle then
            return
        end

        outputChatBox(
            "[Kryminalista] Chowamy samochód pod kocem",
            player,
            255,255,0
        )

        setElementFrozen(hit,true)

        setTimer(function()

            if not isElement(hit) then
                return
            end

            setElementFrozen(hit,false)

            local x,y,z =
                getElementPosition(player)

            setElementPosition(
    data.vehicle,
    2004.9022216797,
    2280.5900878906,
    10.671875
)

setElementRotation(
    data.vehicle,
    0,
    0,
    90
)

            safeDestroy(data.policeBlip)
			for k,v in ipairs(StealVehicles) do

    if v.vehicle == hit then

        table.remove(StealVehicles,k)

        break
    end

end

            destroyElement(hit)

            data.stolenVehicle = nil

            createStealVehicles()

        end,5000,1)

    end
)

----------------------------------------------------
-- STOP JOB
----------------------------------------------------

function stopCriminalJob(player)

    local data = Criminals[player]

    if not data then
        return
    end

    safeDestroy(data.vehicle)
    safeDestroy(data.policeBlip)

    Criminals[player] = nil

    setPlayerTeam(player,nil)

    outputChatBox(
        "[Kryminalista] Zakończyłeś pracę.",
        player,
        255,100,100
    )

end

addEventHandler("criminal:stopJob",root,
    function()

        stopCriminalJob(client)

    end
)

----------------------------------------------------
-- QUIT
----------------------------------------------------

addEventHandler("onPlayerQuit",root,
    function()

        stopCriminalJob(source)

    end
)

----------------------------------------------------
-- EXPLODE
----------------------------------------------------

addEventHandler("onVehicleExplode",root,
    function()

        for player,data in pairs(Criminals) do

            if source == data.vehicle
            or source == data.stolenVehicle then

                outputChatBox(
                    "[Kryminalista] Misja nieudana.",
                    player,
                    255,0,0
                )

                stopCriminalJob(player)

            end

        end

    end
)





