local screenW, screenH = guiGetScreenSize()
local isWorking = false
local panelOpen = false

----------------------------------------------------
-- GUI
----------------------------------------------------

local criminalWindow = guiCreateWindow(
    0.37, 0.25, 0.36, 0.46,
    "Praca - Kryminalista",
    true
)

guiWindowSetSizable(criminalWindow,false)
guiSetVisible(criminalWindow,false)
guiSetAlpha(criminalWindow,0.90)

local bg = guiCreateStaticImage(
    0,0,1,1,
    "files/bg.png",
    true,
    criminalWindow
)

local criminalFont = guiCreateFont("files/Borscha-Regular.ttf", 15)

----------------------------------------------------
-- GRIDS
----------------------------------------------------

local vehicleGrid = guiCreateGridList(0.03,0.10,0.42,0.55,true,criminalWindow)
local vehicleCol = guiGridListAddColumn(vehicleGrid,"POJAZDY",0.85)

local skinGrid = guiCreateGridList(0.48,0.10,0.20,0.55,true,criminalWindow)
local skinCol = guiGridListAddColumn(skinGrid,"SKIN",0.75)

----------------------------------------------------
-- INFO
----------------------------------------------------

local info = guiCreateLabel(
    0.70,0.10,0.27,0.55,
    "Kryminalista\n\n- Kradzież pojazdów\n- Ucieczka policji\n- Ukrywanie aut\n\nPolicja otrzyma sygnał GPS po kradzieży.",
    true, criminalWindow
)

guiSetFont(info,criminalFont)

----------------------------------------------------
-- BUTTONS
----------------------------------------------------

local startBtn = guiCreateButton(0.04,0.75,0.28,0.12,"Rozpocznij",true,criminalWindow)
local collectBtn = guiCreateButton(0.35,0.75,0.28,0.12,"Odbierz",true,criminalWindow)
local closeBtn = guiCreateButton(0.66,0.75,0.28,0.12,"Zamknij",true,criminalWindow)

guiSetFont(startBtn,criminalFont)
guiSetFont(collectBtn,criminalFont)
guiSetFont(closeBtn,criminalFont)

----------------------------------------------------
-- LOAD DATA
----------------------------------------------------

for _,v in ipairs(Config.CriminalVehicles) do
    local row = guiGridListAddRow(vehicleGrid)
    guiGridListSetItemText(vehicleGrid,row,vehicleCol,v.name,false,false)
end

for _,skin in ipairs(Config.Skins) do
    local row = guiGridListAddRow(skinGrid)
    guiGridListSetItemText(skinGrid,row,skinCol,tostring(skin),false,false)
end

----------------------------------------------------
-- OPEN PANEL
----------------------------------------------------

addEvent("criminal:openPanel", true)
addEventHandler("criminal:openPanel", root, function()

    guiSetVisible(criminalWindow, true)
    showCursor(true)

    panelOpen = true
    guiBringToFront(criminalWindow)
end)

----------------------------------------------------
-- MARKER HIT
----------------------------------------------------

addEventHandler("onClientMarkerHit", root, function(hitElement, matchingDimension)

    if hitElement ~= localPlayer then return end
    if not matchingDimension then return end
    if not getElementData(source,"criminal:start") then return end

    triggerServerEvent("criminal:requestOpenPanel", localPlayer)
end)

----------------------------------------------------
-- START / STOP (TOGGLE FIX)
----------------------------------------------------

addEventHandler("onClientGUIClick", startBtn, function(btn, state)

    if btn ~= "left" or state ~= "up" then return end

    if not isWorking then

        local vehRow = guiGridListGetSelectedItem(vehicleGrid)
        local skinRow = guiGridListGetSelectedItem(skinGrid)

        if vehRow == -1 or skinRow == -1 then
            outputChatBox("[Kryminalista] Wybierz pojazd i skin.",255,0,0)
            return
        end

        local vehicle = Config.CriminalVehicles[vehRow+1]
        local skin = tonumber(guiGridListGetItemText(skinGrid,skinRow,skinCol))

        triggerServerEvent("criminal:startJob", localPlayer, vehicle.model, skin)

        isWorking = true
        guiSetText(startBtn, "Zakończ")

    else
        triggerServerEvent("criminal:stopJob", localPlayer)

        isWorking = false
        guiSetText(startBtn, "Rozpocznij")
    end

    guiSetVisible(criminalWindow,false)
    showCursor(false)
    panelOpen = false

end,false)

----------------------------------------------------
-- COLLECT MONEY (NAPRAWIONE)
----------------------------------------------------

addEventHandler("onClientGUIClick", collectBtn, function(btn, state)

    if btn ~= "left" or state ~= "up" then return end

    triggerServerEvent("criminal:collectMoney", localPlayer)

end,false)

----------------------------------------------------
-- CLOSE BUTTON (FIX)
----------------------------------------------------

addEventHandler("onClientGUIClick", closeBtn, function(btn, state)

    if btn ~= "left" or state ~= "up" then return end

    guiSetVisible(criminalWindow,false)
    showCursor(false)
    panelOpen = false

end,false)

----------------------------------------------------
-- POLICE SOUND
----------------------------------------------------

addEvent("criminal:playPoliceSound",true)
addEventHandler("criminal:playPoliceSound",root,function()

    local sound = playSound("files/bip.mp3")
    setSoundVolume(sound,1)

end)





addEventHandler("onClientKey", root, function(key, press)
    if not press then return end
    if not isWorking then return end

    if key == "F1" or key == "F2" or key == "F3" or key == "F4" or key == "F5" or key == "F6" or key == "F7" or key == "F8" or key == "F9" or key == "b" then
        cancelEvent()
    end
end)


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