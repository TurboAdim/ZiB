local screenW, screenH = guiGetScreenSize()
local truckSound = nil
----------------------------------------------------
-- TACHOGRAF HUD
----------------------------------------------------

local remainingRoutes = 0
local maxRoutes = 10


local window = guiCreateWindow(
    0.38,
    0.28,
    0.35,
    0.42,
    "Praca - Kierowca Ciężarówki",
    true
)

guiWindowSetSizable(window,false)
guiSetVisible(window,false)
guiSetAlpha(window,0.90)

local bg = guiCreateStaticImage(
    0,0,1,1,
    "files/bg.png",
    true,
    window
)

local font = guiCreateFont(
    "files/Borscha-Regular.ttf",
    15
)

----------------------------------------------------
-- GRIDLIST
----------------------------------------------------

local grid = guiCreateGridList(
    0.04,
    0.10,
    0.42,
    0.60,
    true,
    window
)

local col = guiGridListAddColumn(
    grid,
    "CIĘŻARÓWKI",
    0.85
)

----------------------------------------------------
-- INFO
----------------------------------------------------

local info = guiCreateLabel(
    0.50,
    0.10,
    0.45,
    0.45,
    "Kierowca Ciężarówki\n\n- Załadunek towaru\n- Transport\n- Dostawa\n- Legalne i nielegalne kursy\n\nPolicja może sprawdzić Twój ładunek.",
    true,
    window
)

guiSetFont(info,font)

----------------------------------------------------
-- BUTTONY
----------------------------------------------------

local isWorking = false

local startBtn = guiCreateButton(
    0.04,
    0.75,
    0.28,
    0.12,
    "Rozpocznij",
    true,
    window
)

local collectBtn = guiCreateButton(
    0.35,
    0.75,
    0.28,
    0.12,
    "Odbierz",
    true,
    window
)

local closeBtn = guiCreateButton(
    0.66,
    0.75,
    0.28,
    0.12,
    "Zamknij",
    true,
    window
)

local function refreshButton()

    if isWorking then
        guiSetText(startBtn,"Zakończ")
    else
        guiSetText(startBtn,"Rozpocznij")
    end

end

guiSetFont(startBtn,font)
guiSetFont(collectBtn,font)
guiSetFont(closeBtn,font)

----------------------------------------------------
-- ŁADOWANIE TRUCKÓW
----------------------------------------------------

for _,v in ipairs(Config.Trucks) do

    local row = guiGridListAddRow(grid)

    guiGridListSetItemText(
        grid,
        row,
        col,
        v.name.." ("..v.model..")",
        false,
        false
    )

end

----------------------------------------------------
-- OTWIERANIE GUI
----------------------------------------------------

addEventHandler("onClientMarkerHit",root,
    function(player)

        if player ~= localPlayer then
            return
        end

        if not getElementData(source,"trucker:start") then
            return
        end

        guiSetVisible(window,true)
        showCursor(true)
----------------------------------------------------
-- SOUND
----------------------------------------------------

        if isElement(truckSound) then
        stopSound(truckSound)
        end

        truckSound = playSound("files/truck.mp3")

        setSoundVolume(truckSound,0.8)

    end
)

----------------------------------------------------
-- START
----------------------------------------------------

addEventHandler("onClientGUIClick",startBtn,
    function()

        ----------------------------------------------------
        -- START
        ----------------------------------------------------

        if not isWorking then

            local row =
                guiGridListGetSelectedItem(grid)

            if row == -1 then

                outputChatBox(
                    "Wybierz ciężarówkę.",
                    255,0,0
                )

                return
            end

            local truck = Config.Trucks[row+1]

            triggerServerEvent(
                "trucker:startJob",
                localPlayer,
                truck.model
            )

            isWorking = true

            refreshButton()

        ----------------------------------------------------
        -- STOP
        ----------------------------------------------------

        else

            triggerServerEvent(
                "trucker:stopJob",
                localPlayer
            )

            isWorking = false

            refreshButton()

        end

        guiSetVisible(window,false)
        showCursor(false)

    end,
false)

----------------------------------------------------
-- ODBIERANIE KASY
----------------------------------------------------

addEventHandler("onClientGUIClick",collectBtn,
    function()

        triggerServerEvent(
            "trucker:collectMoney",
            localPlayer
        )

    end,
false)

----------------------------------------------------
-- ZAMKNIJ
----------------------------------------------------

addEventHandler("onClientGUIClick",closeBtn,
    function()

        guiSetVisible(window,false)
        showCursor(false)

        if isElement(truckSound) then
            stopSound(truckSound)
        end

    end,
false)

----------------------------------------------------
-- GUI ŁADUNKU
----------------------------------------------------

local cargoWindow = guiCreateWindow(
    0.40,
    0.30,
    0.30,
    0.35,
    "Wybór Ładunku",
    true
)

guiSetVisible(cargoWindow,false)

local cargoGrid = guiCreateGridList(
    0.05,
    0.10,
    0.90,
    0.65,
    true,
    cargoWindow
)

local cargoCol = guiGridListAddColumn(
    cargoGrid,
    "ŁADUNKI",
    0.85
)

local roadBtn = guiCreateButton(
    0.05,
    0.80,
    0.42,
    0.12,
    "W Drogę",
    true,
    cargoWindow
)

local closeCargo = guiCreateButton(
    0.53,
    0.80,
    0.42,
    0.12,
    "Zamknij",
    true,
    cargoWindow
)

local selectedCargo = nil

----------------------------------------------------
-- OPEN CARGO
----------------------------------------------------

addEvent("trucker:openCargoGUI",true)
addEventHandler("trucker:openCargoGUI",root,
    function(cargo)

        guiGridListClear(cargoGrid)

        selectedCargo = nil

        for k,v in ipairs(cargo) do

            local row = guiGridListAddRow(cargoGrid)

            local text = v.name.." - "..v.distance.."m"

            if v.illegal then
                text = text.." (NIELEGALNE)"
            end

            guiGridListSetItemText(
            cargoGrid,
            row,
            cargoCol,
            text,
            false,
            false
)

            guiGridListSetItemData(
            cargoGrid,
            row,
            cargoCol,
            v.id
)

            if v.illegal then

                guiGridListSetItemColor(
                    cargoGrid,
                    row,
                    cargoCol,
                    255,0,0
                )

            end

        end

        guiSetVisible(cargoWindow,true)
        showCursor(true)

    end
)

----------------------------------------------------
-- SELECT
----------------------------------------------------

addEventHandler("onClientGUIClick",cargoGrid,
    function()

        local row = guiGridListGetSelectedItem(cargoGrid)

        if row == -1 then
            return
        end

        selectedCargo = guiGridListGetItemData(
        cargoGrid,
        row,
        cargoCol
        )

    end,
false)

----------------------------------------------------
-- ROAD BTN
----------------------------------------------------

addEventHandler("onClientGUIClick",roadBtn,
    function()

        if not selectedCargo then
            return
        end

        triggerServerEvent(
            "trucker:selectCargo",
            localPlayer,
            selectedCargo
        )

        guiSetVisible(cargoWindow,false)
        showCursor(false)

    end,
false)

----------------------------------------------------
-- CLOSE CARGO
----------------------------------------------------

addEventHandler("onClientGUIClick",closeCargo,
    function()

        guiSetVisible(cargoWindow,false)
        showCursor(false)

    end,
false)

--[[addEvent("trucker:setWorking",true)
addEventHandler("trucker:setWorking",root,
    function(state)

        isWorking = state

        refreshButton()

    end
)--]]
addEvent("trucker:setWorking",true)

addEventHandler(
    "trucker:setWorking",
    root,
    function(state)

        isWorking = state

        refreshButton()

        ----------------------------------------------------
        -- RESET HUD PO ZAKOŃCZENIU PRACY
        ----------------------------------------------------

        if not state then
            remainingRoutes = 0
            maxRoutes = 10
        end

    end
)


----------------------------------------------------
-- GUI ŁADOWANIA TACHOGRAFU
----------------------------------------------------

local tachographWindow = guiCreateWindow(
    0.35,
    0.30,
    0.30,
    0.30,
    "TruckStop - Ładowanie tachografu",
    true
)

guiWindowSetSizable(
    tachographWindow,
    false
)

guiSetVisible(
    tachographWindow,
    false
)

----------------------------------------------------
-- INFORMACJA
----------------------------------------------------

local tachographInfo = guiCreateLabel(
    0.08,
    0.12,
    0.84,
    0.15,
    "Wybierz liczbę przewozów do naładowania:",
    true,
    tachographWindow
)

guiLabelSetHorizontalAlign(
    tachographInfo,
    "center"
)

----------------------------------------------------
-- SUWAK
----------------------------------------------------

local tachographSlider = guiCreateScrollBar(
    0.10,
    0.35,
    0.80,
    0.12,
    true,
    tachographWindow
)

----------------------------------------------------
-- ILOŚĆ
----------------------------------------------------

local tachographAmount = guiCreateLabel(
    0.08,
    0.52,
    0.84,
    0.12,
    "Wybrano: 1",
    true,
    tachographWindow
)

guiLabelSetHorizontalAlign(
    tachographAmount,
    "center"
)

----------------------------------------------------
-- PRZYCISK ŁADUJ
----------------------------------------------------

local tachographLoadButton = guiCreateButton(
    0.08,
    0.72,
    0.40,
    0.18,
    "Ładuj",
    true,
    tachographWindow
)

----------------------------------------------------
-- PRZYCISK ZAMKNIJ
----------------------------------------------------

local tachographCloseButton = guiCreateButton(
    0.52,
    0.72,
    0.40,
    0.18,
    "Zamknij",
    true,
    tachographWindow
)


----------------------------------------------------
-- AKTUALIZACJA SUWAKA
----------------------------------------------------

addEventHandler(
    "onClientGUIScroll",
    tachographSlider,
    function()

        local maximum =
            tonumber(
                getElementData(
                    localPlayer,
                    "trucker:tachoMaxCharge"
                )
            ) or 1

        local scrollPosition =
            guiScrollBarGetScrollPosition(
                tachographSlider
            )

        local selected =
            math.floor(
                1 +
                (
                    maximum - 1
                ) *
                (
                    scrollPosition / 100
                )
            )

        guiSetText(
            tachographAmount,
            "Wybrano: "..selected
        )

    end,
false
)


----------------------------------------------------
-- OTWARCIE GUI TACHOGRAFU
----------------------------------------------------

addEvent(
    "trucker:openTachographGUI",
    true
)

addEventHandler(
    "trucker:openTachographGUI",
    root,
    function(maximum)

        maximum = tonumber(maximum) or 1

        if maximum < 1 then
            maximum = 1
        end

        ----------------------------------------------------
        -- ZAPIS MAKSYMALNEJ LICZBY JEDNOSTEK
        ----------------------------------------------------

        setElementData(
            localPlayer,
            "trucker:tachoMaxCharge",
            maximum,
            false
        )

        ----------------------------------------------------
        -- RESET SUWAKA
        ----------------------------------------------------

        guiScrollBarSetScrollPosition(
            tachographSlider,
            0
        )

        guiSetText(
            tachographAmount,
            "Wybrano: 1"
        )

        ----------------------------------------------------
        -- OTWARCIE GUI
        ----------------------------------------------------

        guiSetVisible(
            tachographWindow,
            true
        )

        showCursor(true)

    end
)


----------------------------------------------------
-- ŁADOWANIE TACHOGRAFU
----------------------------------------------------

addEventHandler(
    "onClientGUIClick",
    tachographLoadButton,
    function()

        local maximum =
            tonumber(
                getElementData(
                    localPlayer,
                    "trucker:tachoMaxCharge"
                )
            ) or 1

        local scrollPosition =
            guiScrollBarGetScrollPosition(
                tachographSlider
            )

        local selected =
            math.floor(
                1 +
                (
                    maximum - 1
                ) *
                (
                    scrollPosition / 100
                )
            )

        ----------------------------------------------------
        -- WYSŁANIE DO SERVERA
        ----------------------------------------------------

        triggerServerEvent(
            "trucker:startTachographRefill",
            localPlayer,
            selected
        )

        ----------------------------------------------------
        -- ZAMKNIĘCIE GUI
        ----------------------------------------------------

        guiSetVisible(
            tachographWindow,
            false
        )

        showCursor(false)

    end,
false
)


----------------------------------------------------
-- ZAMKNIĘCIE GUI TACHOGRAFU
----------------------------------------------------

addEventHandler(
    "onClientGUIClick",
    tachographCloseButton,
    function()

        triggerServerEvent(
            "trucker:closeTachograph",
            localPlayer
        )

        guiSetVisible(
            tachographWindow,
            false
        )

        showCursor(false)

    end,
false
)


----------------------------------------------------
-- ZAMKNIĘCIE GUI PO ZAKOŃCZENIU ŁADOWANIA
----------------------------------------------------

addEvent(
    "trucker:closeTachographGUI",
    true
)

addEventHandler(
    "trucker:closeTachographGUI",
    root,
    function()

        guiSetVisible(
            tachographWindow,
            false
        )

        showCursor(false)

    end
)

----------------------------------------------------
-- TACHOGRAF - ODBIERANIE DANYCH
----------------------------------------------------

addEvent(
    "trucker:updateRoutes",
    true
)

addEventHandler(
    "trucker:updateRoutes",
    root,
    function(current, maximum)

        remainingRoutes = tonumber(current) or 0
        maxRoutes = tonumber(maximum) or 10

    end
)

----------------------------------------------------
-- TACHOGRAF - HUD
----------------------------------------------------

addEventHandler(
    "onClientRender",
    root,
    function()

        if not isWorking then
            return
        end

        local text =
            "Tachograf: "
            ..remainingRoutes
            .."/"
            ..maxRoutes

        dxDrawText(
            text,
            20,
            screenH - 100,
            350,
            screenH - 60,
            tocolor(255,255,255,255),
            1.2,
            "default-bold",
            "left",
            "center",
            false,
            false,
            false,
            true
        )

    end
)

addEventHandler("onClientKey", root,
    function(button, press)

        if button == "F1" and press then

            if isWorking then
                cancelEvent()
                outputChatBox("Freeroam zablokowany podczas pracy.", 255,0,0)
            end

        end

    end
)

addEventHandler("onClientKey", root,
    function(button, press)

        if button == "F2" and press then

            if isWorking then
                cancelEvent()
                outputChatBox("Mapa zablokowana podczas pracy. Nie bądź leń i dojedź", 255,0,0)
            end

        end

    end
)

addEventHandler("onClientKey", root,
    function(button, press)

        if button == "F4" and press then

            if isWorking then
                cancelEvent()
                outputChatBox("CarPass zablokowany podczas pracy.", 255,0,0)
            end

        end

    end
)



addEventHandler("onClientKey", root,
    function(button, press)
        if not press then return end
        if button ~= "b" then return end

        -- ❌ blokada gdy gracz pisze / ma GUI
        if isChatBoxInputActive() or isConsoleActive() or guiGetInputEnabled() then
            return
        end

        -- ❌ tylko gdy pracuje
        if not isWorking then
            return
        end

        -- ❌ (opcjonalnie) tylko gdy jest w pojeździe
        local veh = getPedOccupiedVehicle(localPlayer)
        if not veh then return end

        cancelEvent()

        outputChatBox(
            "Blokujemy Handling na turbo przyśpieszenie, śmieszku.",
            255, 0, 0
        )
    end
)