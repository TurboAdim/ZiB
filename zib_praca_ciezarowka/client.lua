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

local tachographFont = dxCreateFont(
    "files/Borscha-Regular.ttf",
    14
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

local upgradeBtn = guiCreateButton(
    0.35,
    0.75,
    0.28,
    0.12,
    "ULEPSZENIA",
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
guiSetFont(upgradeBtn,font)
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
    selectedCargo,
    baseWeight,
    finalWeight,
    distance,
    delivery
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

--[[addEventHandler("onClientKey", root,
    function(button, press)

        if button == "F2" and press then

            if isWorking then
                cancelEvent()
                outputChatBox("Mapa zablokowana podczas pracy. Nie bądź leń i dojedź", 255,0,0)
            end

        end

    end
)--]]

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



----------------------------------------------------
-- TRUCKSTOP - TACHOGRAF
----------------------------------------------------

local tachographVisible = false
local tachographLoading = false

local tachographCurrent = 0
local tachographMaximum = 10

local tachographBackground = nil


----------------------------------------------------
-- ŁADOWANIE OBRAZU
----------------------------------------------------

tachographBackground =
    dxCreateTexture(
        "files/bg.png"
    )


----------------------------------------------------
-- OTWARCIE TACHOGRAFU
----------------------------------------------------

addEvent(
    "trucker:openTachograph",
    true
)

addEventHandler(
    "trucker:openTachograph",
    root,
    function(
        current,
        maximum
    )

        tachographCurrent =
            tonumber(current) or 0

        tachographMaximum =
            tonumber(maximum) or 10

        tachographVisible = true
        tachographLoading = false

        showCursor(false)

    end
)


----------------------------------------------------
-- AKTUALIZACJA TACHOGRAFU
----------------------------------------------------

addEvent(
    "trucker:updateTachograph",
    true
)

addEventHandler(
    "trucker:updateTachograph",
    root,
    function(
        current,
        maximum
    )

        tachographCurrent =
            tonumber(current) or 0

        tachographMaximum =
            tonumber(maximum) or 10

    end
)


----------------------------------------------------
-- ZAKOŃCZENIE ŁADOWANIA
----------------------------------------------------

addEvent(
    "trucker:tachographFinished",
    true
)

addEventHandler(
    "trucker:tachographFinished",
    root,
    function(
        current,
        maximum
    )

        tachographCurrent =
            tonumber(current) or tachographCurrent

        tachographMaximum =
            tonumber(maximum) or tachographMaximum

        tachographLoading = false

    end
)


----------------------------------------------------
-- ZAMKNIĘCIE TACHOGRAFU
----------------------------------------------------

addEvent(
    "trucker:closeTachograph",
    true
)

addEventHandler(
    "trucker:closeTachograph",
    root,
    function()

        tachographVisible = false
        tachographLoading = false

        showCursor(false)

    end
)


----------------------------------------------------
-- RYSOWANIE TACHOGRAFU
----------------------------------------------------

addEventHandler(
    "onClientRender",
    root,
    function()

        if not tachographVisible then
            return
        end

        local bgX = (screenW - 600) / 2
        local bgY = (screenH - 500) / 2

        ----------------------------------------------------
        -- TŁO
        ----------------------------------------------------

        if isElement(tachographBackground) then

            dxDrawImage(
                bgX,
                bgY,
                600,
                500,
                tachographBackground,
                0,
                0,
                0,
                tocolor(
                    255,
                    255,
                    255,
                    230
                ),
                false
            )

        end

        ----------------------------------------------------
        -- GŁÓWNY NAPIS
        ----------------------------------------------------

        local mainText

        if tachographLoading then

            mainText =
                "Ładowanie tachografu..."

        else

            mainText =
                "Wciśnij SPACJĘ, aby naładować tachograf"

        end

        dxDrawText(
    mainText,
    bgX,
    bgY + 170,
    bgX + 600,
    bgY + 250,
    tocolor(
        255,
        255,
        255,
        255
    ),
    1,
    tachographFont,
    "center",
    "center",
    false,
    false,
    false,
    true
)

        ----------------------------------------------------
        -- LICZNIK
        ----------------------------------------------------

        dxDrawText(
    tachographCurrent
    .."/"
    ..tachographMaximum,
    bgX,
    bgY + 250,
    bgX + 600,
    bgY + 330,
    tocolor(
        255,
        255,
        255,
        255
    ),
    1,
    tachographFont,
    "center",
    "center",
    false,
    false,
    false,
    true
)

        ----------------------------------------------------
        -- INFORMACJA O ESC
        ----------------------------------------------------

        dxDrawText(
    "ESC - zamknij",
    bgX,
    bgY + 380,
    bgX + 600,
    bgY + 430,
    tocolor(
        255,
        255,
        255,
        220
    ),
    1,
    tachographFont,
    "center",
    "center",
    false,
    false,
    false,
    true
)

    end
)


----------------------------------------------------
-- SPACJA - START ŁADOWANIA
----------------------------------------------------

addEventHandler(
    "onClientKey",
    root,
    function(
        button,
        press
    )

        if not press then
            return
        end

        ----------------------------------------------------
        -- SPRAWDZAMY CZY TACHOGRAF JEST OTWARTY
        ----------------------------------------------------

        if not tachographVisible then
            return
        end

        ----------------------------------------------------
        -- SPACJA
        ----------------------------------------------------

        if button == "space" then

            cancelEvent()

            ----------------------------------------------------
            -- NIE URUCHAMIAMY DRUGIEGO ŁADOWANIA
            ----------------------------------------------------

            if tachographLoading then
                return
            end

            ----------------------------------------------------
            -- TACHOGRAF PEŁNY
            ----------------------------------------------------

            if tachographCurrent
                >= tachographMaximum then

                outputChatBox(
                    "Tachograf jest już pełny.",
                    255,
                    255,
                    0
                )

                return

            end

            ----------------------------------------------------
            -- ZMIENIAMY STAN
            ----------------------------------------------------

            tachographLoading = true

            ----------------------------------------------------
            -- START TIMERA NA SERWERZE
            ----------------------------------------------------

            triggerServerEvent(
                "trucker:startTachographRefill",
                localPlayer
            )

            return

        end

        ----------------------------------------------------
        -- ESC - ZAMKNIĘCIE
        ----------------------------------------------------

        if button == "escape" then

            cancelEvent()

            tachographVisible = false
            tachographLoading = false

            triggerServerEvent(
                "trucker:closeTachograph",
                localPlayer
            )

        end

    end
)