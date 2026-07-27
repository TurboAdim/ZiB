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
-- TRUCKSTOP - TACHOGRAF
----------------------------------------------------

local truckStops = {}

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

    local blip = createBlipAttachedTo(
        truckStop,
        51
    )

    setElementData(
        truckStop,
        "trucker:truckstop",
        true
    )

    table.insert(
        truckStops,
        {
            marker = truckStop,
            blip = blip
        }
    )

end


----------------------------------------------------
-- WJAZD DO TRUCKSTOPU
----------------------------------------------------

addEventHandler(
    "onMarkerHit",
    root,
    function(hitElement, matchingDimension)

        if not matchingDimension then
            return
        end

        ----------------------------------------------------
        -- SPRAWDZAMY CZY TO TRUCKSTOP
        ----------------------------------------------------

        if not getElementData(
            source,
            "trucker:truckstop"
        ) then
            return
        end

        ----------------------------------------------------
        -- MARKER MUSI DOTKNĄĆ POJAZD
        ----------------------------------------------------

        if getElementType(hitElement) ~= "vehicle" then
            return
        end

        ----------------------------------------------------
        -- POBIERAMY KIEROWCĘ
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
        -- SPRAWDZAMY SESJĘ
        ----------------------------------------------------

        local data =
            Truckers[player]

        if not data then
            return
        end

        ----------------------------------------------------
        -- MUSI BYĆ TO POJAZD GRACZA
        ----------------------------------------------------

        if data.vehicle ~= hitElement then
            return
        end

        ----------------------------------------------------
        -- ZAPISUJEMY AKTUALNY TRUCKSTOP
        ----------------------------------------------------

        data.currentTruckStop = source

        ----------------------------------------------------
        -- SPRAWDZAMY CZY TACHOGRAF JEST PEŁNY
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
        -- FREEZE POJAZDU
        ----------------------------------------------------

        setElementFrozen(
            hitElement,
            true
        )

        ----------------------------------------------------
        -- OTWIERAMY EKRAN TACHOGRAFU
        ----------------------------------------------------

        triggerClientEvent(
            player,
            "trucker:openTachograph",
            resourceRoot,
            data.remainingRoutes,
            Config.MaxRoutes
        )

    end
)


----------------------------------------------------
-- ROZPOCZĘCIE ŁADOWANIA TACHOGRAFU
----------------------------------------------------

addEvent(
    "trucker:startTachographRefill",
    true
)

addEventHandler(
    "trucker:startTachographRefill",
    root,
    function()

        local player = client

        local data =
            Truckers[player]

        if not data then
            return
        end

        ----------------------------------------------------
        -- SPRAWDZAMY CZY GRACZ JEST W TRUCKSTOPIE
        ----------------------------------------------------

        if not data.currentTruckStop then
            return
        end

        ----------------------------------------------------
        -- TACHOGRAF PEŁNY
        ----------------------------------------------------

        if data.remainingRoutes >= Config.MaxRoutes then

            triggerClientEvent(
                player,
                "trucker:tachographFinished",
                resourceRoot,
                data.remainingRoutes,
                Config.MaxRoutes
            )

            return

        end

        ----------------------------------------------------
        -- NIE URUCHAMIAMY DRUGIEGO ŁADOWANIA
        ----------------------------------------------------

        if data.refillingRoutes then
            return
        end

        ----------------------------------------------------
        -- ROZPOCZYNAMY ŁADOWANIE
        ----------------------------------------------------

        data.refillingRoutes = true

        outputChatBox(
            "Rozpoczęto ładowanie tachografu.",
            player,
            0,
            255,
            0
        )

        outputChatBox(
            "Jeden przewóz zostanie dodany co "
            ..(Config.RouteRefillTime / 1000)
            .." sekundy.",
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

                    ----------------------------------------------------
                    -- SPRAWDZAMY CZY GRACZ NADAL PRACUJE
                    ----------------------------------------------------

                    if not Truckers[player] then
                        return
                    end

                    local truckerData =
                        Truckers[player]

                    ----------------------------------------------------
                    -- SPRAWDZAMY CZY NADAL JEST W TYM TRUCKSTOPIE
                    ----------------------------------------------------

                    if not truckerData.currentTruckStop then

                        truckerData.refillingRoutes = false
                        truckerData.refillTimer = nil

                        return

                    end

                    ----------------------------------------------------
                    -- SPRAWDZAMY MAXIMUM
                    ----------------------------------------------------

                    if truckerData.remainingRoutes
                        >= Config.MaxRoutes then

                        truckerData.refillingRoutes = false
                        truckerData.refillTimer = nil

                        triggerClientEvent(
                            player,
                            "trucker:tachographFinished",
                            resourceRoot,
                            truckerData.remainingRoutes,
                            Config.MaxRoutes
                        )

                        return

                    end

                    ----------------------------------------------------
                    -- DODAJEMY 1 PRZEWÓZ
                    ----------------------------------------------------

                    truckerData.remainingRoutes =
                        truckerData.remainingRoutes + 1

                    updateRoutes(player)

                    ----------------------------------------------------
                    -- AKTUALIZACJA GUI
                    ----------------------------------------------------

                    triggerClientEvent(
                        player,
                        "trucker:updateTachograph",
                        resourceRoot,
                        truckerData.remainingRoutes,
                        Config.MaxRoutes
                    )

                    ----------------------------------------------------
                    -- KOMUNIKAT
                    ----------------------------------------------------

                    outputChatBox(
                        "Naładowano 1 przewóz. Aktualnie: "
                        ..truckerData.remainingRoutes
                        .."/"
                        ..Config.MaxRoutes,
                        player,
                        0,
                        255,
                        0
                    )

                    ----------------------------------------------------
                    -- SPRAWDZAMY CZY PEŁNY
                    ----------------------------------------------------

                    if truckerData.remainingRoutes
                        >= Config.MaxRoutes then

                        truckerData.refillingRoutes = false
                        truckerData.refillTimer = nil

                        outputChatBox(
                            "Tachograf został w pełni naładowany: "
                            ..truckerData.remainingRoutes
                            .."/"
                            ..Config.MaxRoutes,
                            player,
                            0,
                            255,
                            0
                        )

                        triggerClientEvent(
                            player,
                            "trucker:tachographFinished",
                            resourceRoot,
                            truckerData.remainingRoutes,
                            Config.MaxRoutes
                        )

                    end

                end,
                Config.RouteRefillTime,
                0
            )

    end
)


----------------------------------------------------
-- ZAMKNIĘCIE OKNA TACHOGRAFU
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
        -- ZATRZYMUJEMY TIMER
        ----------------------------------------------------

        if data.refillTimer
            and isTimer(data.refillTimer) then

            killTimer(
                data.refillTimer
            )

        end

        data.refillTimer = nil
        data.refillingRoutes = false

        ----------------------------------------------------
        -- ODBLOKOWUJEMY POJAZD
        ----------------------------------------------------

        if isElement(data.vehicle) then

            setElementFrozen(
                data.vehicle,
                false
            )

        end

        ----------------------------------------------------
        -- RESET TRUCKSTOPU
        ----------------------------------------------------

        data.currentTruckStop = nil

        ----------------------------------------------------
        -- ZAMYKAMY GUI
        ----------------------------------------------------

        triggerClientEvent(
            player,
            "trucker:closeTachograph",
            resourceRoot
        )

    end
)


----------------------------------------------------
-- WYJAZD Z TRUCKSTOPU
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

        ----------------------------------------------------
        -- SPRAWDZAMY CZY TO TRUCKSTOP
        ----------------------------------------------------

        if not getElementData(
            source,
            "trucker:truckstop"
        ) then
            return
        end

        ----------------------------------------------------
        -- MUSI TO BYĆ POJAZD
        ----------------------------------------------------

        if getElementType(leftElement) ~= "vehicle" then
            return
        end

        ----------------------------------------------------
        -- POBIERAMY KIEROWCĘ
        ----------------------------------------------------

        local player =
            getVehicleOccupant(
                leftElement,
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
        -- SPRAWDZAMY CZY TO AKTUALNY TRUCKSTOP
        ----------------------------------------------------

        if data.currentTruckStop ~= source then
            return
        end

        ----------------------------------------------------
        -- ZATRZYMUJEMY ŁADOWANIE
        ----------------------------------------------------

        if data.refillTimer
            and isTimer(data.refillTimer) then

            killTimer(
                data.refillTimer
            )

        end

        data.refillTimer = nil
        data.refillingRoutes = false
        data.currentTruckStop = nil

        ----------------------------------------------------
        -- ODBLOKOWUJEMY POJAZD
        ----------------------------------------------------

        setElementFrozen(
            leftElement,
            false
        )

        ----------------------------------------------------
        -- ZAMYKAMY GUI
        ----------------------------------------------------

        triggerClientEvent(
            player,
            "trucker:closeTachograph",
            resourceRoot
        )

        outputChatBox(
            "Opuściłeś TruckStop. "
            .."Ładowanie tachografu przerwane.",
            player,
            255,
            100,
            0
        )

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

        -- TACHOGRAF
-- Liczba wszystkich dostępnych przewozów
-- Legalnych oraz nielegalnych
remainingRoutes = Config.MaxRoutes,

-- Czy aktualnie trwa ładowanie tachografu
refillingRoutes = false,

-- Timer ładowania tachografu
refillTimer = nil,

        -- Marker TruckStop, przy którym aktualnie się znajdujemy
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

if data.refillTimer and isTimer(data.refillTimer) then
    killTimer(data.refillTimer)
end

data.refillTimer = nil
data.refillingRoutes = false
data.currentTruckStop = nil

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

function checkPoliceCargo(player)

    ------------------------------------------------
    -- SPRAWDZENIE TEAMU POLICJA
    ------------------------------------------------

    local policeTeam =
        getTeamFromName("Policja")

    if not policeTeam then

        outputChatBox(
            "Błąd: brak teamu Policja.",
            player,
            255,0,0
        )

        return

    end

    if getPlayerTeam(player) ~= policeTeam then

        outputChatBox(
            "Nie jesteś policjantem.",
            player,
            255,0,0
        )

        return

    end

    ------------------------------------------------
    -- SPRAWDZENIE POJAZDU POLICJANTA
    ------------------------------------------------

    local veh =
        getPedOccupiedVehicle(player)

    if not veh then

        outputChatBox(
            "Musisz być w pojeździe.",
            player,
            255,0,0
        )

        return

    end

    ------------------------------------------------
    -- SPRAWDZENIE KIEROWCY
    ------------------------------------------------

    local driver =
        getVehicleOccupant(
            veh,
            0
        )

    if not driver then

        outputChatBox(
            "Brak kierowcy.",
            player,
            255,0,0
        )

        return

    end

    ------------------------------------------------
    -- SPRAWDZENIE CZY KIEROWCA PRACUJE
    ------------------------------------------------

    local data =
        Truckers[driver]

    if not data then

        outputChatBox(
            "Ten gracz nie pracuje jako kierowca.",
            player,
            255,0,0
        )

        return

    end

    ------------------------------------------------
    -- ROZPOCZĘCIE KONTROLI
    ------------------------------------------------

    outputChatBox(
        "Sprawdzanie ładunku...",
        player,
        255,255,0
    )

    outputChatBox(
        "Policjant przeszukuje ładunek...",
        driver,
        255,255,0
    )

    ------------------------------------------------
    -- OPÓŹNIENIE KONTROLI
    ------------------------------------------------

    setTimer(
        function()

            ------------------------------------------------
            -- SPRAWDZENIE CZY KIEROWCA NADAL PRACUJE
            ------------------------------------------------

            if not Truckers[driver] then
                return
            end

            ------------------------------------------------
            -- INFORMACJA O ZAKOŃCZENIU
            ------------------------------------------------

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

            ------------------------------------------------
            -- BRAK ŁADUNKU
            ------------------------------------------------

            if not data.cargo then

                outputChatBox(
                    "Nie wykryto żadnego ładunku.",
                    player,
                    255,255,0
                )

                return

            end

            ------------------------------------------------
            -- WYNIK KONTROLI
            ------------------------------------------------

            if data.cargo.illegal then

                outputChatBox(
                    "Wykryto NIELEGALNY ładunek: "
                    ..data.cargo.name,
                    player,
                    255,0,0
                )

            else

                outputChatBox(
                    "Ładunek legalny: "
                    ..data.cargo.name,
                    player,
                    0,255,0
                )

            end

        end,
        math.random(3000,5000),
        1
    )

end


----------------------------------------------------
-- KOMENDA: /SPRAWDZ.LADUNEK
----------------------------------------------------

addCommandHandler(
    "sprawdz.ladunek",
    function(player)

        checkPoliceCargo(player)

    end
)


----------------------------------------------------
-- GUI: SPRAWDŹ ŁADUNEK
----------------------------------------------------

addEvent(
    "police:checkCargo",
    true
)

addEventHandler(
    "police:checkCargo",
    root,
    function()

        checkPoliceCargo(client)

    end
)


----------------------------------------------------
-- POLICJA - SPRAWDZENIE TACHOGRAFU
----------------------------------------------------

function checkPoliceTacho(player)

    ------------------------------------------------
    -- SPRAWDZENIE TEAMU POLICJA
    ------------------------------------------------

    local policeTeam =
        getTeamFromName("Policja")

    if not policeTeam then

        outputChatBox(
            "Błąd: brak teamu Policja.",
            player,
            255,0,0
        )

        return

    end

    if getPlayerTeam(player) ~= policeTeam then

        outputChatBox(
            "Nie jesteś policjantem.",
            player,
            255,0,0
        )

        return

    end

    ------------------------------------------------
    -- SPRAWDZENIE POJAZDU POLICJANTA
    ------------------------------------------------

    local veh =
        getPedOccupiedVehicle(player)

    if not veh then

        outputChatBox(
            "Musisz być w pojeździe.",
            player,
            255,0,0
        )

        return

    end

    ------------------------------------------------
    -- SPRAWDZENIE KIEROWCY
    ------------------------------------------------

    local driver =
        getVehicleOccupant(
            veh,
            0
        )

    if not driver then

        outputChatBox(
            "Brak kierowcy.",
            player,
            255,0,0
        )

        return

    end

    ------------------------------------------------
    -- SPRAWDZENIE CZY KIEROWCA PRACUJE
    ------------------------------------------------

    local data =
        Truckers[driver]

    if not data then

        outputChatBox(
            "Ten gracz nie pracuje jako kierowca.",
            player,
            255,0,0
        )

        return

    end

    ------------------------------------------------
    -- ROZPOCZĘCIE KONTROLI
    ------------------------------------------------

    outputChatBox(
        "Sprawdzanie tachografu...",
        player,
        255,255,0
    )

    outputChatBox(
        "Policjant sprawdza Twój tachograf...",
        driver,
        255,255,0
    )

    ------------------------------------------------
    -- OPÓŹNIENIE KONTROLI
    ------------------------------------------------

    setTimer(
        function()

            ------------------------------------------------
            -- SPRAWDZENIE CZY KIEROWCA NADAL PRACUJE
            ------------------------------------------------

            if not Truckers[driver] then
                return
            end

            ------------------------------------------------
            -- AKTUALNE DANE TACHOGRAFU
            ------------------------------------------------

            local remainingRoutes =
                data.remainingRoutes or 0

            local maxRoutes =
                Config.MaxRoutes or 10

            ------------------------------------------------
            -- INFORMACJA O ZAKOŃCZENIU
            ------------------------------------------------

            outputChatBox(
                "Policjant sprawdził tachograf.",
                driver,
                255,255,255
            )

            outputChatBox(
                "Sprawdzenie tachografu zakończone.",
                player,
                255,255,255
            )

            ------------------------------------------------
            -- WYNIK TACHOGRAFU
            ------------------------------------------------

            outputChatBox(
                "===== TACHOGRAF =====",
                player,
                255,255,0
            )

            outputChatBox(
                "Kierowca: "
                ..getPlayerName(driver),
                player,
                255,255,255
            )

            outputChatBox(
                "Tachograf: "
                ..remainingRoutes
                .."/"
                ..maxRoutes,
                player,
                0,255,0
            )

            outputChatBox(
                "=====================",
                player,
                255,255,0
            )

        end,
        math.random(3000,5000),
        1
    )

end


----------------------------------------------------
-- KOMENDA: /SPRAWDZ.TACHO
----------------------------------------------------

addCommandHandler(
    "sprawdz.tacho",
    function(player)

        checkPoliceTacho(player)

    end
)


----------------------------------------------------
-- GUI: SPRAWDŹ TACHOGRAF
----------------------------------------------------

addEvent(
    "police:checkTacho",
    true
)

addEventHandler(
    "police:checkTacho",
    root,
    function()

        checkPoliceTacho(client)

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

