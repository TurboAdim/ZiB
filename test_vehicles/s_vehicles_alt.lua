-- Alternative method with loadstring
--   These vehicles will not be destroyed if newmodels_red stops
--   because the elements are children of this resource on creation.

-- Loads newmodels functions, which allow usage of custom model IDs "as if they were normal IDs"
local playerVehicles = {}
loadstring(exports.newmodels_red:import())()

-- Vehicle model, x,y,z, rx,ry,rz, interior,dimension
local VEHICLE_SPAWNS = {
    { 525,   -938.74, 1034.21, 23.59, 3.42,   2.85,   20.27,  0, 0 },
    { 80001, -944.88, 1051.90, 24.84, 355.97, 356.23, 198.86, 0, 0 },
    { 80002, -924.62, 1015.67, 22,    355.97, 0,      0,      0, 0 },
}

local function createVehicles()
    for _, data in ipairs(VEHICLE_SPAWNS) do
        local model, x, y, z, rx, ry, rz, interior, dimension = unpack(data)
        local vehicle = createVehicle(model, x, y, z, rx, ry, rz)
        if vehicle then
            setElementInterior(vehicle, interior)
            setElementDimension(vehicle, dimension)
            -- print("test_vehicles [alt] #" ..
            --     i .. " - Created vehicle with ID " .. model .. " at " .. x .. ", " .. y .. ", " .. z)
        end
    end
end
addEventHandler("onResourceStart", resourceRoot, createVehicles, false)

addEvent("newmodels-test_vehicles:requestVehicleSpawn", true)
addEventHandler("newmodels-test_vehicles:requestVehicleSpawn",
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
            triggerClientEvent(
                player,
                "newmodels-test_vehicles:vehicleSpawnResponse",
                player,
                false,
                "Failed to spawn vehicle!"
            )
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

