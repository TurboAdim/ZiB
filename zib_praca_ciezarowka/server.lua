Truckers = {}

----------------------------------------------------
-- TEAM
----------------------------------------------------

local truckerTeam =
    getTeamFromName("Praca - Kierowca Ciężarówki")

if not truckerTeam then

    truckerTeam = createTeam(
        "Praca - Kierowca Ciężarówki",
        120,220,255
    )

end

local policeTeam =
    getTeamFromName("Policja")

----------------------------------------------------
-- MARKER
----------------------------------------------------

local marker = createMarker(
    Config.StartMarker[1],
    Config.StartMarker[2],
    Config.StartMarker[3],
    "cylinder",
    2.5,
    180,0,255,150
)

setElementData(marker,"trucker:start",true)

----------------------------------------------------
-- TRUCKSTOP
----------------------------------------------------

for _, pos in ipairs(Config.TruckStops) do

    local truckStop = createMarker(
        pos[1],
        pos[2],
        pos[3],
        "cylinder",
        4,
        255,
        170,
        0,
        150
    )

    local blip =
        createBlipAttachedTo(
            truckStop,
            51
        )

    setElementData(
        truckStop,
        "trucker:truckstop",
        true
    )

    addEventHandler(
        "onMarkerHit",
        truckStop,
        function(
            hitElement,
            matchingDimension
        )

            if not matchingDimension then
                return
            end

            if getElementType(hitElement) ~= "vehicle" then
                return
            end

            ----------------------------------------------------
            -- KIEROWCA
            ----------------------------------------------------

            local player =
                getVehicleOccupant(
                    hitElement,
                    0
                )

            if not player then
                return
            end

            ----------------------------------------------------
            -- SESJA
            ----------------------------------------------------

            local data =
                Truckers[player]

            if not data then
                return
            end

            ----------------------------------------------------
            -- SPRAWDZENIE WŁASNEGO POJAZDU
            ----------------------------------------------------

            if data.vehicle ~= hitElement then
                return
            end

            ----------------------------------------------------
            -- TACHOGRAF PEŁNY
            ----------------------------------------------------

            if data.remainingRoutes >= Config.MaxRoutes then

                outputChatBox(
                    "Twój tachograf jest już pełny: "
                    ..data.remainingRoutes
                    .."/"
                    ..Config.MaxRoutes,
                    player,
                    255,
                    255,
                    0
                )

                return

            end

            ----------------------------------------------------
            -- NIE MOŻNA OTWORZYĆ DRUGIEGO GUI
            ----------------------------------------------------

            if data.tachographGUI then
                return
            end

            ----------------------------------------------------
            -- ZAPIS TRUCKSTOPU
            ----------------------------------------------------

            data.currentTruckStop = source

            data.tachographGUI = true

            ----------------------------------------------------
            -- FREEZE POJAZDU
            ----------------------------------------------------

            setElementFrozen(
                data.vehicle,
                true
            )

            ----------------------------------------------------
            -- ILE MOŻNA MAKSYMALNIE DOŁADOWAĆ
            ----------------------------------------------------

            local available =
                Config.MaxRoutes
                - data.remainingRoutes

            ----------------------------------------------------
            -- OTWARCIE GUI
            ----------------------------------------------------

            triggerClientEvent(
                player,
                "trucker:openTachographGUI",
                resourceRoot,
                available
            )

        end
    )

end

----------------------------------------------------
-- START ŁADOWANIA TACHOGRAFU
----------------------------------------------------

addEvent(
    "trucker:startTachographRefill",
    true
)

addEventHandler(
    "trucker:startTachographRefill",
    root,
    function(amount)

        local player = client

        local data =
            Truckers[player]

        if not data then
            return
        end

        ----------------------------------------------------
        -- WALIDACJA
        ----------------------------------------------------

        amount =
            tonumber(amount)

        if not amount then
            return
        end

        amount =
            math.floor(amount)

        if amount < 1 then
            return
        end

        ----------------------------------------------------
        -- MAKSYMALNA ILOŚĆ
        ----------------------------------------------------

        local available =
            Config.MaxRoutes
            - data.remainingRoutes

        if amount > available then

            outputChatBox(
                "Nie możesz naładować tylu jednostek.",
                player,
                255,
                0,
                0
            )

            return

        end

        ----------------------------------------------------
        -- SPRAWDZENIE TRUCKSTOPU
        ----------------------------------------------------

        if not data.currentTruckStop then
            return
        end

        ----------------------------------------------------
        -- NIE MOŻNA ŁADOWAĆ DRUGI RAZ
        ----------------------------------------------------

        if data.refillingRoutes then
            return
        end

        ----------------------------------------------------
        -- ROZPOCZĘCIE
        ----------------------------------------------------

        data.refillingRoutes = true

        data.refillAmount = amount

        ----------------------------------------------------
        -- CZAS
        ----------------------------------------------------

        local refillTime =
            amount *
            Config.RouteRefillTime

        outputChatBox(
            "Rozpoczęto ładowanie tachografu.",
            player,
            0,
            255,
            0
        )

        outputChatBox(
            "Ładowanie: "
            ..amount
            .." przewozów.",
            player,
            255,
            255,
            0
        )

        outputChatBox(
            "Czas ładowania: "
            ..math.floor(
                refillTime / 1000
            )
            .." sekund.",
            player,
            255,
            255,
            0
        )

        ----------------------------------------------------
        -- TIMER
        ----------------------------------------------------

        data.refillTimer =
            setTimer(
                function()

                    ------------------------------------------------
                    -- SESJA NIE ISTNIEJE
                    ------------------------------------------------

                    if not Truckers[player] then
                        return
                    end

                    local truckerData =
                        Truckers[player]

                    ------------------------------------------------
                    -- SPRAWDZENIE TRUCKSTOPU
                    ------------------------------------------------

                    if not truckerData.currentTruckStop then

                        truckerData.refillingRoutes =
                            false

                        truckerData.refillTimer =
                            nil

                        truckerData.refillAmount =
                            nil

                        return

                    end

                    ------------------------------------------------
                    -- DOŁADOWANIE
                    ------------------------------------------------

                    truckerData.remainingRoutes =
                        truckerData.remainingRoutes
                        + amount

                    ------------------------------------------------
                    -- BEZPIECZEŃSTWO
                    ------------------------------------------------

                    if truckerData.remainingRoutes
                        > Config.MaxRoutes then

                        truckerData.remainingRoutes =
                            Config.MaxRoutes

                    end

                    ------------------------------------------------
                    -- RESET
                    ------------------------------------------------

                    truckerData.refillingRoutes =
                        false

                    truckerData.refillTimer =
                        nil

                    truckerData.refillAmount =
                        nil

                    ------------------------------------------------
                    -- HUD
                    ------------------------------------------------

                    updateRoutes(player)

                    ------------------------------------------------
                    -- ODBLOKOWANIE POJAZDU
                    ------------------------------------------------

                    if isElement(
                        truckerData.vehicle
                    ) then

                        setElementFrozen(
                            truckerData.vehicle,
                            false
                        )

                    end

                    ------------------------------------------------
                    -- KOMUNIKAT
                    ------------------------------------------------

                    outputChatBox(
                        "Tachograf został naładowany o "
                        ..amount
                        .." przewozów.",
                        player,
                        0,
                        255,
                        0
                    )

                    outputChatBox(
                        "Aktualnie: "
                        ..truckerData.remainingRoutes
                        .."/"
                        ..Config.MaxRoutes,
                        player,
                        255,
                        255,
                        0
                    )

                    ------------------------------------------------
                    -- ZAMKNIĘCIE GUI
                    ------------------------------------------------

                    triggerClientEvent(
                        player,
                        "trucker:closeTachographGUI",
                        resourceRoot
                    )

                end,
                refillTime,
                1
            )

    end
)

----------------------------------------------------
-- ZAMKNIĘCIE GUI TACHOGRAFU
----------------------------------------------------

addEvent(
    "trucker:closeTachograph",
    true
)

addEventHandler(
    "trucker:closeTachograph",
    root,
    function()

        local player = client

        local data =
            Truckers[player]

        if not data then
            return
        end

        ----------------------------------------------------
        -- ANULOWANIE GUI
        ----------------------------------------------------

        data.tachographGUI =
            false

        data.currentTruckStop =
            nil

        ----------------------------------------------------
        -- ODBLOKOWANIE POJAZDU
        ----------------------------------------------------

        if isElement(
            data.vehicle
        ) then

            setElementFrozen(
                data.vehicle,
                false
            )

        end

    end
)

----------------------------------------------------
-- BLIP STARTU PRACY
----------------------------------------------------

createBlipAttachedTo(
    marker,
    51
)

----------------------------------------------------
-- SESSION
----------------------------------------------------
function createSession(player)
    Truckers[player] = {
        vehicle = nil,
        trailer = nil,
        pickupMarker = nil,
        pickupBlip = nil,
        deliveryMarker = nil,
        deliveryBlip = nil,
        cargo = nil,
        earned = 0,
        oldTeam = getPlayerTeam(player),

        ----------------------------------------------------
-- TACHOGRAF
----------------------------------------------------

-- Liczba dostępnych przewozów
remainingRoutes = Config.MaxRoutes,

-- Czy aktualnie trwa ładowanie
refillingRoutes = false,

-- Timer ładowania
refillTimer = nil,

-- Liczba przewozów ładowanych aktualnie
refillAmount = nil,

-- Czy GUI tachografu jest otwarte
tachographGUI = false,

-- Aktualny TruckStop
currentTruckStop = nil
    }
end

----------------------------------------------------
-- TACHOGRAF - AKTUALIZACJA HUD
----------------------------------------------------

function updateRoutes(player)

    local data = Truckers[player]

    if not data then
        return
    end

    triggerClientEvent(
        player,
        "trucker:updateRoutes",
        resourceRoot,
        data.remainingRoutes,
        Config.MaxRoutes
    )

end

--[[function createSession(player)

        Truckers[player] = {

        vehicle = nil,
        trailer = nil,

        pickupMarker = nil,
        pickupBlip = nil,

        deliveryMarker = nil,
        deliveryBlip = nil,

        cargo = nil,

        earned = 0,

        oldTeam = getPlayerTeam(player)

    }

end--]]

----------------------------------------------------
-- DESTROY
----------------------------------------------------

function destroySession(player)

    local data = Truckers[player]
    if not data then return end

    safeDestroy(data.vehicle)
    safeDestroy(data.trailer)

    safeDestroy(data.pickupMarker)
    safeDestroy(data.pickupBlip)

    safeDestroy(data.deliveryMarker)
    safeDestroy(data.deliveryBlip)

    Truckers[player] = nil

end

----------------------------------------------------
-- CREATE VEHICLE
----------------------------------------------------

function createTruck(model, x, y, z, rot)

    local veh

    if tonumber(model) > 611 then
        veh = exports["newmodels_red"]:createVehicle(
            tonumber(model),
            x, y, z
        )
    else
        veh = createVehicle(
            tonumber(model),
            x, y, z
        )
    end

    if veh then
        setElementRotation(veh, 0, 0, rot or 0)
    end

    return veh
end

----------------------------------------------------
-- START JOB
----------------------------------------------------

function startJob(model)

    local player = client

    if Truckers[player] then
        return
    end

    createSession(player)

    local data = Truckers[player]

    ----------------------------------------------------
    -- ODCZYT KONFIGU
    ----------------------------------------------------

    local selectedTruck

    for _,truck in ipairs(Config.Trucks) do

        if truck.model == model then
            selectedTruck = truck
            break
        end

    end

    if not selectedTruck then
        return
    end

    local spawn =
        getRandomTable(Config.VehicleSpawns)

    ----------------------------------------------------
    -- CIĄGNIK
    ----------------------------------------------------

    local veh = createTruck(
        selectedTruck.model,
        spawn[1],
        spawn[2],
        spawn[3],
        spawn[4]
    )

    data.vehicle = veh

    ----------------------------------------------------
    -- NACZEPA
    ----------------------------------------------------

    if selectedTruck.trailer then

        local trailer = createTruck(
            selectedTruck.trailer,
            spawn[1] - 8,
            spawn[2],
            spawn[3]
        )

        data.trailer = trailer

        attachTrailerToVehicle(
            veh,
            trailer
        )

    end

    warpPedIntoVehicle(player,veh)

    setPlayerTeam(player,truckerTeam)
	triggerClientEvent(
    player,
    "trucker:setWorking",
    resourceRoot,
    true
)
----------------------------------------------------
-- TACHOGRAF
----------------------------------------------------

updateRoutes(player)

    outputChatBox(
        "Rozpocząłeś pracę kierowcy ciężarówki.",
        player,
        0,255,0
    )

    createPickup(player)

end
addEvent("trucker:startJob",true)
addEventHandler("trucker:startJob",root,startJob)

----------------------------------------------------
-- PICKUP
----------------------------------------------------

function createPickup(player)

    local data = Truckers[player]
    if not data then return end

    safeDestroy(data.pickupMarker)
    safeDestroy(data.pickupBlip)

    local pos =
        getRandomTable(Config.Pickups)

    local marker = createMarker(
        pos[1],
        pos[2],
        pos[3],
        "cylinder",
        4,
        255,255,0,150
    )

    local blip =
        createBlipAttachedTo(marker,41)

    setElementVisibleTo(marker,root,false)
    setElementVisibleTo(blip,root,false)

    setElementVisibleTo(marker,player,true)
    setElementVisibleTo(blip,player,true)

    data.pickupMarker = marker
    data.pickupBlip = blip

    addEventHandler("onMarkerHit",marker,
        function(hit)

            if hit ~= data.vehicle then
                return
            end

            outputChatBox(
                "Załadunek...",
                player,
                255,255,0
            )

            setElementFrozen(data.vehicle,true)

            setTimer(function()

                if not Truckers[player] then
                    return
                end

                setElementFrozen(data.vehicle,false)

                local cargoList = {}

                for k,v in ipairs(Config.Cargo) do

                    local delivery

                    if v.illegal then
                        delivery =
                            getRandomTable(
                                Config.IllegalDeliveries
                            )
                    else
                        delivery =
                            getRandomTable(
                                Config.LegalDeliveries
                            )
                    end

                    local dist =
                        getDistanceBetweenPoints3D(
                            pos[1],pos[2],pos[3],
                            delivery[1],delivery[2],delivery[3]
                        )

                    table.insert(cargoList,{
                        id = k,
                        name = v.name,
                        illegal = v.illegal,
                        distance = math.floor(dist)
                    })

                end

                table.sort(cargoList,
                    function(a,b)
                        return a.distance < b.distance
                    end
                )

                triggerClientEvent(
                    player,
                    "trucker:openCargoGUI",
                    resourceRoot,
                    cargoList
                )

            end,10000,1)

        end
    )

end

----------------------------------------------------
-- SELECT CARGO
----------------------------------------------------
function selectCargo(cargoID)

    local player = client
    local data = Truckers[player]

    if not data then
        return
    end

    local cargo = Config.Cargo[cargoID]

    if not cargo then
        return
    end

    ----------------------------------------------------
-- SPRAWDZENIE TACHOGRAFU
----------------------------------------------------

if data.remainingRoutes <= 0 then

    outputChatBox(
        "Nie masz już dostępnych przewozów.",
        player,
        255,
        0,
        0
    )

    outputChatBox(
        "Udaj się do TruckStopu, aby odnowić tachograf.",
        player,
        255,
        255,
        0
    )

    return

end

    ----------------------------------------------------
    -- WYBÓR ŁADUNKU
    ----------------------------------------------------

    data.cargo = cargo

    createDelivery(player)

end

addEvent("trucker:selectCargo",true)
addEventHandler(
    "trucker:selectCargo",
    root,
    selectCargo
)
--[[function selectCargo(cargoID)

    local player = client

    local data = Truckers[player]
    if not data then return end

    local cargo = Config.Cargo[cargoID]
    if not cargo then return end

    data.cargo = cargo

    createDelivery(player)

end--]]
--addEvent("trucker:selectCargo",true)
--addEventHandler("trucker:selectCargo",root,selectCargo)

----------------------------------------------------
-- DELIVERY
----------------------------------------------------

function createDelivery(player)

    local data = Truckers[player]
    if not data then return end

    safeDestroy(data.deliveryMarker)
    safeDestroy(data.deliveryBlip)

    local delivery

    if data.cargo.illegal then
        delivery =
            getRandomTable(
                Config.IllegalDeliveries
            )
    else
        delivery =
            getRandomTable(
                Config.LegalDeliveries
            )
    end

    local marker = createMarker(
        delivery[1],
        delivery[2],
        delivery[3],
        "cylinder",
        5,
        0,255,0,150
    )

    local blip =
        createBlipAttachedTo(marker,19)

    setElementVisibleTo(marker,root,false)
    setElementVisibleTo(blip,root,false)

    setElementVisibleTo(marker,player,true)
    setElementVisibleTo(blip,player,true)

    data.deliveryMarker = marker
    data.deliveryBlip = blip

    addEventHandler("onMarkerHit",marker,
        function(hit)

            if hit ~= data.vehicle then
                return
            end

            outputChatBox(
                "Rozładowywanie...",
                player,
                255,255,0
            )

            setElementFrozen(data.vehicle,true)

            setTimer(function()

                if not Truckers[player] then
                    return
                end

                setElementFrozen(data.vehicle,false)

                local x,y,z =
                    getElementPosition(
                        data.pickupMarker
                    )

                --[[local money,dist =
                    calculatePayment(
                        x,y,z,
                        delivery[1],
                        delivery[2],
                        delivery[3],
                        data.cargo.illegal
                    )

                data.earned =
                    data.earned + money--]]
				local money,dist = calculatePayment(
    x,y,z,
    delivery[1],
    delivery[2],
    delivery[3],
    data.cargo.illegal
)

data.earned = data.earned + money

----------------------------------------------------
-- TACHOGRAF
----------------------------------------------------

-- Każdy zakończony przewóz zmniejsza
-- liczbę dostępnych przewozów o 1.
--
-- Dotyczy to zarówno ładunków legalnych,
-- jak i nielegalnych.

if data.remainingRoutes > 0 then

    data.remainingRoutes =
        data.remainingRoutes - 1

    updateRoutes(player)

    outputChatBox(
        "Tachograf: pozostało "
        ..data.remainingRoutes
        .."/"
        ..Config.MaxRoutes
        .." dostępnych przewozów.",
        player,
        255,
        255,
        0
    )

end

                outputChatBox(
                    "Dostarczyłeś ładunek: "..data.cargo.name,
                    player,
                    0,255,0
                )

                outputChatBox(
                    "Dystans: "..dist.."m | Zarobek: $"..money,
                    player,
                    255,255,0
                )

                safeDestroy(marker)
                safeDestroy(blip)

                createPickup(player)

            end,10000,1)

        end
    )

end

----------------------------------------------------
-- ODBIÓR KASY
----------------------------------------------------

function collectMoney()

    local player = client

    local data = Truckers[player]

    if not data then

        outputChatBox(
            "Nie pracujesz jako kierowca.",
            player,
            255,0,0
        )

        return
    end

    if data.earned <= 0 then

        outputChatBox(
            "Leniu, do roboty, wtedy kasa się znajdzie.",
            player,
            255,50,50
        )

        return
    end

    givePlayerMoney(player,data.earned)

    outputChatBox(
        "Odebrano $"..data.earned,
        player,
        0,255,0
    )

    data.earned = 0

end
addEvent("trucker:collectMoney",true)
addEventHandler("trucker:collectMoney",root,collectMoney)

----------------------------------------------------
-- STOP JOB
----------------------------------------------------

function stopJob(player)

    local data = Truckers[player]
    if not data then return end

    ----------------------------------------------------
    -- TEAM
    ----------------------------------------------------

    local drift =
        getTeamFromName("ZMIENNY23 - Gracze")

    if drift then
        setPlayerTeam(player,drift)
    else
        setPlayerTeam(player,nil)
    end

    ----------------------------------------------------
    -- CLEANUP
    ----------------------------------------------------

    safeDestroy(data.vehicle)
    safeDestroy(data.trailer)

    safeDestroy(data.pickupMarker)
    safeDestroy(data.pickupBlip)

    safeDestroy(data.deliveryMarker)
    safeDestroy(data.deliveryBlip)

    ----------------------------------------------------
    -- RESET
    ----------------------------------------------------
	----------------------------------------------------
-- ANULOWANIE ŁADOWANIA TACHOGRAFU
----------------------------------------------------

if data.refillTimer
    and isTimer(data.refillTimer) then

    killTimer(
        data.refillTimer
    )

end

data.refillTimer =
    nil

data.refillingRoutes =
    false

data.refillAmount =
    nil

data.tachographGUI =
    false

data.currentTruckStop =
    nil
	
	triggerClientEvent(
    player,
    "trucker:closeTachographGUI",
    resourceRoot
)





----------------------------------------------------
-- OPUSZCZENIE TRUCKSTOPU
----------------------------------------------------

addEventHandler(
    "onMarkerLeave",
    root,
    function(
        leftElement,
        matchingDimension
    )

        if not matchingDimension then
            return
        end

        if getElementType(leftElement) ~= "vehicle" then
            return
        end

        if not getElementData(
            source,
            "trucker:truckstop"
        ) then
            return
        end

        local player =
            getVehicleOccupant(
                leftElement,
                0
            )

        if not player then
            return
        end

        local data =
            Truckers[player]

        if not data then
            return
        end

        ----------------------------------------------------
        -- TYLKO AKTUALNY TRUCKSTOP
        ----------------------------------------------------

        if data.currentTruckStop ~= source then
            return
        end

        ----------------------------------------------------
        -- JEŻELI ŁADOWANIE TRWA
        ----------------------------------------------------

        if data.refillingRoutes then

            if data.refillTimer
                and isTimer(data.refillTimer) then

                killTimer(
                    data.refillTimer
                )

            end

            data.refillTimer =
                nil

            data.refillingRoutes =
                false

            data.refillAmount =
                nil

            outputChatBox(
                "Opuściłeś TruckStop. Ładowanie tachografu zostało anulowane.",
                player,
                255,
                0,
                0
            )

        end

        ----------------------------------------------------
        -- RESET TRUCKSTOPU
        ----------------------------------------------------

        data.currentTruckStop =
            nil

        data.tachographGUI =
            false

        ----------------------------------------------------
        -- ODBLOKOWANIE POJAZDU
        ----------------------------------------------------

        if isElement(
            data.vehicle
        ) then

            setElementFrozen(
                data.vehicle,
                false
            )

        end

        ----------------------------------------------------
        -- ZAMKNIĘCIE GUI
        ----------------------------------------------------

        triggerClientEvent(
            player,
            "trucker:closeTachographGUI",
            resourceRoot
        )

    end
)



    Truckers[player] = nil

    triggerClientEvent(
        player,
        "trucker:setWorking",
        resourceRoot,
        false
    )

    outputChatBox(
        "Zakończyłeś pracę kierowcy ciężarówki.",
        player,
        255,100,100
    )

end

----------------------------------------------------
-- POLICJA
----------------------------------------------------

----------------------------------------------------
-- SPRAWDZANIE ŁADUNKU - FUNKCJA
----------------------------------------------------

function checkCargo(player)

    local policeTeam =
        getTeamFromName(
            "Policja"
        )

    if not policeTeam then

        outputChatBox(
            "Błąd: brak teamu Policja.",
            player,
            255,
            0,
            0
        )

        return

    end

    if getPlayerTeam(player)
        ~= policeTeam then

        outputChatBox(
            "Nie jesteś policjantem.",
            player,
            255,
            0,
            0
        )

        return

    end

    local veh =
        getPedOccupiedVehicle(
            player
        )

    if not veh then

        outputChatBox(
            "Musisz być w pojeździe.",
            player,
            255,
            0,
            0
        )

        return

    end

    local driver =
        getVehicleOccupant(
            veh,
            0
        )

    if not driver then

        outputChatBox(
            "Brak kierowcy.",
            player,
            255,
            0,
            0
        )

        return

    end

    local data =
        Truckers[driver]

    if not data then

        outputChatBox(
            "Ten gracz nie pracuje jako kierowca.",
            player,
            255,
            0,
            0
        )

        return

    end

    ------------------------------------------------
    -- START CHECK
    ------------------------------------------------

    outputChatBox(
        "Sprawdzanie ładunku...",
        player,
        255,
        255,
        0
    )

    outputChatBox(
        "Policjant przeszukuje ładunek...",
        driver,
        255,
        255,
        0
    )

    setTimer(
        function()

            if not Truckers[driver] then
                return
            end

            ------------------------------------------------
            -- RESULT INFO
            ------------------------------------------------

            outputChatBox(
                "Policjant przeszukał pojazd.",
                driver,
                255,
                255,
                255
            )

            outputChatBox(
                "Przeszukanie zakończone.",
                player,
                255,
                255,
                255
            )

            ------------------------------------------------
            -- BRAK ŁADUNKU
            ------------------------------------------------

            if not data.cargo then

                outputChatBox(
                    "Pojazd nie posiada aktualnie ładunku.",
                    player,
                    255,
                    255,
                    0
                )

                return

            end

            ------------------------------------------------
            -- DETECTION
            ------------------------------------------------

            if data.cargo.illegal then

                outputChatBox(
                    "Wykryto NIELEGALNY ładunek: "
                    ..data.cargo.name,
                    player,
                    255,
                    0,
                    0
                )

            else

                outputChatBox(
                    "Ładunek legalny: "
                    ..data.cargo.name,
                    player,
                    0,
                    255,
                    0
                )

            end

        end,
        math.random(3000,5000),
        1
    )

end

----------------------------------------------------
-- KOMENDA
----------------------------------------------------

addCommandHandler(
    "sprawdz.ladunek",
    function(player)

        checkCargo(player)

    end
)

----------------------------------------------------
-- EVENT Z GUI
----------------------------------------------------

addEvent(
    "police:checkCargo",
    true
)

addEventHandler(
    "police:checkCargo",
    root,
    function()

        checkCargo(client)

    end
)


----------------------------------------------------
-- SPRAWDZENIE TACHOGRAFU
----------------------------------------------------

function checkTacho(player)

    local policeTeam =
        getTeamFromName(
            "Policja"
        )

    if not policeTeam then

        outputChatBox(
            "Błąd: brak teamu Policja.",
            player,
            255,
            0,
            0
        )

        return

    end

    if getPlayerTeam(player)
        ~= policeTeam then

        outputChatBox(
            "Nie jesteś policjantem.",
            player,
            255,
            0,
            0
        )

        return

    end

    local veh =
        getPedOccupiedVehicle(
            player
        )

    if not veh then

        outputChatBox(
            "Musisz być w pojeździe.",
            player,
            255,
            0,
            0
        )

        return

    end

    local driver =
        getVehicleOccupant(
            veh,
            0
        )

    if not driver then

        outputChatBox(
            "Brak kierowcy.",
            player,
            255,
            0,
            0
        )

        return

    end

    local data =
        Truckers[driver]

    if not data then

        outputChatBox(
            "Ten gracz nie pracuje jako kierowca.",
            player,
            255,
            0,
            0
        )

        return

    end

    ------------------------------------------------
    -- START CHECK
    ------------------------------------------------

    outputChatBox(
        "Sprawdzanie tachografu...",
        player,
        255,
        255,
        0
    )

    outputChatBox(
        "Policjant sprawdza Twój tachograf...",
        driver,
        255,
        255,
        0
    )

    setTimer(
        function()

            if not Truckers[driver] then
                return
            end

            local remainingRoutes =
                data.remainingRoutes or 0

            local maxRoutes =
                Config.MaxRoutes or 10

            ------------------------------------------------
            -- RESULT INFO
            ------------------------------------------------

            outputChatBox(
                "Policjant sprawdził tachograf.",
                driver,
                255,
                255,
                255
            )

            outputChatBox(
                "Sprawdzenie tachografu zakończone.",
                player,
                255,
                255,
                255
            )

            ------------------------------------------------
            -- TACHOGRAF
            ------------------------------------------------

            outputChatBox(
                "===== TACHOGRAF =====",
                player,
                255,
                255,
                0
            )

            outputChatBox(
                "Kierowca: "
                ..getPlayerName(driver),
                player,
                255,
                255,
                255
            )

            outputChatBox(
                "Tachograf: "
                ..remainingRoutes
                .."/"
                ..maxRoutes,
                player,
                0,
                255,
                0
            )

            outputChatBox(
                "=====================",
                player,
                255,
                255,
                0
            )

        end,
        math.random(3000,5000),
        1
    )

end

----------------------------------------------------
-- KOMENDA
----------------------------------------------------

addCommandHandler(
    "sprawdz.tacho",
    function(player)

        checkTacho(player)

    end
)

----------------------------------------------------
-- EVENT Z GUI
----------------------------------------------------

addEvent(
    "police:checkTacho",
    true
)

addEventHandler(
    "police:checkTacho",
    root,
    function()

        checkTacho(client)

    end
)
--[[addCommandHandler("sprawdz.ladunek",
    function(player)

        local policeTeam = getTeamFromName("Policja")

        if not policeTeam then
            outputChatBox("Błąd: brak teamu Policja.", player, 255,0,0)
            return
        end

        if getPlayerTeam(player) ~= policeTeam then
            outputChatBox("Nie jesteś policjantem.", player, 255,0,0)
            return
        end

        local veh = getPedOccupiedVehicle(player)

        if not veh then
            outputChatBox("Musisz być w pojeździe.", player, 255,0,0)
            return
        end

        local driver = getVehicleOccupant(veh, 0)

        if not driver then
            outputChatBox("Brak kierowcy.", player, 255,0,0)
            return
        end

        local data = Truckers[driver]

        if not data then
            outputChatBox("Ten gracz nie pracuje jako kierowca.", player, 255,0,0)
            return
        end

        ----------------------------------------------------
        -- START CHECK
        ----------------------------------------------------

        outputChatBox("Sprawdzanie ładunku...", player, 255,255,0)

        outputChatBox(
            "Policjant przeszukuje ładunek...",
            driver,
            255,255,0
        )

        setTimer(function()

            if not Truckers[driver] then return end

            ----------------------------------------------------
            -- RESULT INFO (OBIE STRONY)
            ----------------------------------------------------

            outputChatBox(
                "Policjant przeszukał pojazd.",
                driver,
                255,255,255
            )

            outputChatBox(
                "Przeszukanie zakończone.",
                player,
                255,255,255
            )

            ----------------------------------------------------
            -- DETECTION (tylko policjant widzi wynik)
            ----------------------------------------------------

            if not data.cargo then return end

            if data.cargo.illegal then
                outputChatBox(
                    "Wykryto NIELEGALNY ładunek: "..data.cargo.name,
                    player,
                    255,0,0
                )
            else
                outputChatBox(
                    "Ładunek legalny: "..data.cargo.name,
                    player,
                    0,255,0
                )
            end

        end, math.random(3000,5000), 1)

    end
)--]]

----------------------------------------------------
-- EXIT
----------------------------------------------------

addEventHandler("onPlayerQuit",root,
    function()

        if Truckers[source] then
            stopJob(source)
        end

    end
)

----------------------------------------------------
-- EXPLODE
----------------------------------------------------

addEventHandler("onVehicleExplode",root,
    function()

        for player,data in pairs(Truckers) do

            if source == data.vehicle or source == data.trailer then

                outputChatBox(
                    "Twoja ciężarówka została zniszczona.",
                    player,
                    255,0,0
                )

                stopJob(player)

            end

        end

    end
)


addEvent("trucker:stopJob",true)
addEventHandler("trucker:stopJob",root,
    function()

        stopJob(client)

    end
)


--[[
----------------------------------------------------
-- ANTI DETACH
----------------------------------------------------

setTimer(function()

    for player,data in pairs(Truckers) do

        if data.vehicle
        and data.trailer
        and isElement(data.vehicle)
        and isElement(data.trailer) then

            local attached =
                getVehicleTowedByVehicle(
                    data.vehicle
                )

            if attached ~= data.trailer then

                attachTrailerToVehicle(
                    data.vehicle,
                    data.trailer
                )

            end

        end

    end

end,1000,0)--]]

