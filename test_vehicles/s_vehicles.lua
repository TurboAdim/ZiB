-- Method with exports
--   These vehicles will be destroyed if newmodels_red stops
--   because they are children of that resource.

-- Vehicle model, x,y,z, rx,ry,rz, interior,dimension
local VEHICLE_SPAWNS = {
    { 490,   -941.95, 1043.03, 24.25, 355.90, 356.51, 199.00, 0, 0 },
    { 80003, -947.94, 1060.05, 25.96, 356.28, 356.34, 204.01, 0, 0 },
    { 80006, -926,    1010.67, 22,    356.28, 356.34, 204.01, 0, 0 },
}

local function createVehicles()
    for _, data in ipairs(VEHICLE_SPAWNS) do
        local model, x, y, z, rx, ry, rz, interior, dimension = unpack(data)
        local vehicle = exports["newmodels_red"]:createVehicle(model, x, y, z, rx, ry, rz)
        if vehicle then
            setElementInterior(vehicle, interior)
            setElementDimension(vehicle, dimension)
            -- print("test_vehicles #" ..
            --     i .. " - Created vehicle with ID " .. model .. " at " .. x .. ", " .. y .. ", " .. z)
        end
    end
end
addEventHandler("onResourceStart", resourceRoot, createVehicles, false)

addEvent("newmodels-test_vehicles:requestVehicleSpawn", true)

addEventHandler(
    "newmodels-test_vehicles:requestVehicleSpawn",
    resourceRoot,
    function(vehicleID, x, y, z, rot)

        local player = client

        if not isElement(player) then
            return
        end

        -- USUŃ POPRZEDNI POJAZD
        if isElement(playerVehicles[player]) then
            destroyElement(playerVehicles[player])
            playerVehicles[player] = nil
        end

        -- STWÓRZ NOWY
        --[[local vehicle = exports.newmodels_red:createVehicle(vehicleID,x,y,z,0,0,rot)

        if not vehicle then
            triggerClientEvent(player,"newmodels-test_vehicles:vehicleSpawnResponse",player,false,"Failed to spawn vehicle!")
            return
        end--]]

        --warpPedIntoVehicle(player, vehicle)

        -- ZAPISANIE VEHICLE
        playerVehicles[player] = vehicle

        triggerClientEvent(player,"newmodels-test_vehicles:vehicleSpawnResponse",player,true,"Vehicle spawned successfully!")
    end
)


addEvent("newmodels-test_vehicles:destroyVehicle", true)
addEventHandler("newmodels-test_vehicles:destroyVehicle",
    resourceRoot,
    function()

        local player = client
        local vehicle = getPedOccupiedVehicle(player)

        if not vehicle then
            return
        end

        -- TYLKO KIEROWCA
        if getVehicleOccupant(vehicle, 0) ~= player then
            return
        end

        destroyElement(vehicle)

        if playerVehicles[player] == vehicle then
            playerVehicles[player] = nil
        end
    end
)