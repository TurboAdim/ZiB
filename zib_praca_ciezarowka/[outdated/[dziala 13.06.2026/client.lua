local screenW, screenH = guiGetScreenSize()
local truckSound = nil

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

addEvent("trucker:setWorking",true)
addEventHandler("trucker:setWorking",root,
    function(state)

        isWorking = state

        refreshButton()

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