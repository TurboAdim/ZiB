----------------------------------------------------
-- SCREEN + BACKGROUND PNG
----------------------------------------------------

local screenW, screenH = guiGetScreenSize()
local bg = dxCreateTexture("bg.png")


local jobSound = nil

----------------------------------------------------
-- GUI
----------------------------------------------------

local window = guiCreateWindow(
    0.4,
    0.35,
    0.32,
    0.35,
    "Operator Wózka Jezdniowego - MAGAZYN",
    true
)

guiWindowSetSizable(window, false)
guiSetVisible(window, false)

local bg = guiCreateStaticImage(
    0,0,1,1,
    "bg.png",
    true,
    window
)


local function getWindowPos()
    local x, y = guiGetPosition(window, false)
    local w, h = guiGetSize(window, false)

    x = x * screenW
    y = y * screenH
    w = w * screenW
    h = h * screenH

    return x, y, w, h
end


-- pół-przezroczyste okno (żeby PNG było widoczne)
guiSetAlpha(window, 0.85)

----------------------------------------------------
-- GRIDLIST
----------------------------------------------------

local gridlist = guiCreateGridList(
    0.05,
    0.12,
    0.45,
    0.55,
    true,
    window
)

local column = guiGridListAddColumn(gridlist, "WYBIERZ WÓZEK", 0.9)

----------------------------------------------------
-- FONT
----------------------------------------------------

local font = guiCreateFont("Borscha-Regular.ttf", 16)

----------------------------------------------------
-- INFO TEXT
----------------------------------------------------

local infoLabel = guiCreateLabel(
    0.52,
    0.12,
    0.45,
    0.55,
    "Operator Wózka Jezdniowego:\n\n- Pobieraj palety\n- Dostarczaj do punktów\n- Unikaj kolizji\n- Nie gub ładunku\\n\n\n- ATTENZIONE!\n- Pierdolnie jak towar z regauuuuu",
    true,
    window
)

guiSetFont(infoLabel, font)

----------------------------------------------------
-- POJAZDY
----------------------------------------------------

local vehicles = {
    {name = "Wózek Widłowy", model = 530}
    --{name = "Guido Custom Turbo", model = 60200}
}

for _,v in ipairs(vehicles) do
    local row = guiGridListAddRow(gridlist)

    guiGridListSetItemText(
        gridlist,
        row,
        column,
        v.name .. " (" .. v.model .. ")",
        false,
        false
    )
end


local closeBtn = guiCreateButton(0.85,0.88,0.13,0.08,"Zamknij",true,window)

addEventHandler("onClientGUIClick",closeBtn,function()
    guiSetVisible(window,false)
    showCursor(false)
	
	if isElement(jobSound) then
    stopSound(jobSound)
    end
end,false)

----------------------------------------------------
-- JEDEN PRZYCISK
----------------------------------------------------

local actionBtn = guiCreateButton(
    0.05,
    0.75,
    0.45,
    0.15,
    "Rozpocznij",
    true,
    window
)

guiSetFont(actionBtn, font)

----------------------------------------------------
-- STAN PRACY
----------------------------------------------------

local isWorking = false

local function updateButton()
    if isWorking then
        guiSetText(actionBtn, "Zakoncz")
    else
        guiSetText(actionBtn, "Rozpocznij")
    end
end

----------------------------------------------------
-- RENDER TŁA PNG
----------------------------------------------------

addEventHandler("onClientMarkerHit", root,
    function(hitPlayer)

        if hitPlayer ~= localPlayer then return end
        if not getElementData(source, "forklift:job") then return end

        guiSetVisible(window, true)
        showCursor(true)

        if isElement(jobSound) then
            stopSound(jobSound)
        end

        jobSound = playSound("towar.mp3")
		setSoundVolume(jobSound, 0.9)

    end
)

----------------------------------------------------
-- ACTION BUTTON
----------------------------------------------------

addEventHandler("onClientGUIClick", actionBtn,
    function()

        if not isWorking then

            local row = guiGridListGetSelectedItem(gridlist)
            if row == -1 then
                outputChatBox("Wybierz pojazd.", 255,0,0)
                return
            end

            local vehicle = vehicles[row+1]
            if not vehicle then return end

            triggerServerEvent(
                "forklift:startJob",
                localPlayer,
                vehicle.model
            )

            isWorking = true
            updateButton()

        else

            triggerServerEvent(
                "forklift:stopJob",
                localPlayer
            )

            isWorking = false
            updateButton()

        end

        guiSetVisible(window, false)
        showCursor(false)

    end,
false)

----------------------------------------------------
-- RESET ZE SERVERA
----------------------------------------------------

addEvent("forklift:resetUI", true)
addEventHandler("forklift:resetUI", root,
    function()
        isWorking = false
        updateButton()
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