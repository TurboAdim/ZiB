local screenW,screenH = guiGetScreenSize()

local font = guiCreateFont(
    "files/Borscha-Regular.ttf",
    13
)

local isPolice = false
local isWorking = false

----------------------------------------------------
-- MAIN GUI
----------------------------------------------------

local window = guiCreateWindow(
    0.35,
    0.25,
    0.30,
    0.45,
    "Praca Policjanta",
    true
)

guiWindowSetSizable(window,false)
guiSetVisible(window,false)

guiCreateStaticImage(
    0,0,1,1,
    "files/bg.png",
    true,
    window
)

----------------------------------------------------
-- VEHICLES
----------------------------------------------------

local vehGrid = guiCreateGridList(
    0.03,
    0.10,
    0.42,
    0.65,
    true,
    window
)

local vehCol = guiGridListAddColumn(
    vehGrid,
    "POJAZDY",
    0.80
)

----------------------------------------------------
-- SKINS
----------------------------------------------------

local skinGrid = guiCreateGridList(
    0.52,
    0.10,
    0.42,
    0.65,
    true,
    window
)

local skinCol = guiGridListAddColumn(
    skinGrid,
    "SKINY",
    0.80
)

----------------------------------------------------
-- BUTTONS
----------------------------------------------------

local startBtn = guiCreateButton(
    0.03,
    0.80,
    0.42,
    0.12,
    "Rozpocznij",
    true,
    window
)

local closeBtn = guiCreateButton(
    0.52,
    0.80,
    0.42,
    0.12,
    "Zamknij",
    true,
    window
)

guiSetFont(startBtn,font)
guiSetFont(closeBtn,font)


local function refreshButton()

    if isWorking then
        guiSetText(startBtn,"Zakończ")
    else
        guiSetText(startBtn,"Rozpocznij")
    end

end

----------------------------------------------------
-- LOAD
----------------------------------------------------

addEvent("police:loadGUI",true)
addEventHandler("police:loadGUI",root,
    function(vehicles,skins)

        guiGridListClear(vehGrid)
        guiGridListClear(skinGrid)

        for _,v in ipairs(vehicles) do

            local row = guiGridListAddRow(vehGrid)

            --[[guiGridListSetItemText(
                vehGrid,
                row,
                vehCol,
                v.name.." ("..v.model..")",
                false,
                false
            )

        end

        for _,v in ipairs(skins) do

            local row = guiGridListAddRow(skinGrid)

            guiGridListSetItemText(
                skinGrid,
                row,
                skinCol,
                v.name.." ("..v.skin..")",
                false,
                false
            )--]]
			guiGridListSetItemText(
                vehGrid,
                row,
                vehCol,
                v.name,
                false,
                false
            )

        end

        for _,v in ipairs(skins) do

            local row = guiGridListAddRow(skinGrid)

            guiGridListSetItemText(
                skinGrid,
                row,
                skinCol,
                v.name,
                false,
                false
            )
			

        end

    end
)

----------------------------------------------------
-- MARKER
----------------------------------------------------

addEventHandler("onClientMarkerHit",root,
    function(player)

        if player ~= localPlayer then
            return
        end

        if not getElementData(source,"police:marker") then
            return
        end

        triggerServerEvent(
            "police:checkACL",
            localPlayer
        )

    end
)

----------------------------------------------------
-- OPEN
----------------------------------------------------

addEvent("police:openGUI",true)
addEventHandler("police:openGUI",root,
    function()

        guiSetVisible(window,true)
        showCursor(true)

    end
)

----------------------------------------------------
-- DENY
----------------------------------------------------

addEvent("police:noACL",true)
addEventHandler("police:noACL",root,
    function()

        outputChatBox(
            "Nie pracujesz tutaj.",
            255,0,0
        )

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

            local vehRow =
                guiGridListGetSelectedItem(vehGrid)

            local skinRow =
                guiGridListGetSelectedItem(skinGrid)

            if vehRow == -1 or skinRow == -1 then

                outputChatBox(
                    "Wybierz pojazd i skin.",
                    255,0,0
                )

                return
            end

            triggerServerEvent(
                "police:startJob",
                localPlayer,
                vehRow + 1,
                skinRow + 1
            )

        ----------------------------------------------------
        -- STOP
        ----------------------------------------------------

        else

            triggerServerEvent(
                "police:stopJob",
                localPlayer
            )

        end

        guiSetVisible(window,false)
        showCursor(false)

    end,
false)

----------------------------------------------------
-- CLOSE
----------------------------------------------------

addEventHandler("onClientGUIClick",closeBtn,
    function()

        guiSetVisible(window,false)
        showCursor(false)

    end,
false)

----------------------------------------------------
-- PANEL
----------------------------------------------------

local panel = guiCreateWindow(
    0.35,
    0.20,
    0.30,
    0.50,
    "Panel Policji",
    true
)


guiWindowSetSizable(panel,false)
guiSetAlpha(panel,0.95)

local panelBg = guiCreateStaticImage(
    0,0,1,1,
    "files/bg.png",
    true,
    panel
)

guiSetVisible(panel,false)
guiWindowSetSizable(panel,false)

local playerGrid = guiCreateGridList(
    0.05,
    0.08,
    0.45,
    0.50,
    true,
    panel
)

local playerCol = guiGridListAddColumn(
    playerGrid,
    "GRACZE",
    0.85
)

local ticketBtn = guiCreateButton(
    0.05,
    0.62,
    0.12,
    0.05,
    "Mandat",
    true,
    panel
)

local jailBtn = guiCreateButton(
    0.20,
    0.62,
    0.12,
    0.05,
    "JAIL",
    true,
    panel
)

local trackBtn = guiCreateButton(
    0.35,
    0.62,
    0.12,
    0.05,
    "Namierz",
    true,
    panel
)

local weaponBtn = guiCreateButton(
    0.05,
    0.68,
    0.12,
    0.05,
    "Bronie",
    true,
    panel
)

local closePanel = guiCreateButton(
    0.30,
    0.88,
    0.40,
    0.08,
    "Zamknij",
    true,
    panel
)



local function setFontToButtons(font)
    guiSetFont(ticketBtn, font)
    guiSetFont(jailBtn, font)
    guiSetFont(trackBtn, font)
    guiSetFont(weaponBtn, font)
    guiSetFont(closePanel, font)
end


setFontToButtons(font)

----------------------------------------------------
-- PANEL CMD
----------------------------------------------------

addCommandHandler("panel",
    function()

        triggerServerEvent(
            "police:openPanel",
            localPlayer
        )

    end
)

addEvent("police:showPanel",true)
addEventHandler("police:showPanel",root,
    function(players)

        guiGridListClear(playerGrid)

        for _,v in ipairs(players) do

            local row = guiGridListAddRow(playerGrid)

            guiGridListSetItemText(
                playerGrid,
                row,
                playerCol,
                v,
                false,
                false
            )

        end

        guiSetVisible(panel,true)
        showCursor(true)

    end
)

----------------------------------------------------
-- CLOSE PANEL
----------------------------------------------------

addEventHandler("onClientGUIClick",closePanel,
    function()

        guiSetVisible(panel,false)
        showCursor(false)

    end,
false)







----------------------------------------------------
-- MANDAT GUI
----------------------------------------------------

local ticketWindow = guiCreateWindow(
    0.40,
    0.35,
    0.20,
    0.20,
    "Mandat",
    true
)

guiSetVisible(ticketWindow,false)
guiWindowSetSizable(ticketWindow,false)

local ticketEdit = guiCreateEdit(
    0.10,
    0.30,
    0.80,
    0.20,
    "",
    true,
    ticketWindow
)

local giveTicketBtn = guiCreateButton(
    0.10,
    0.60,
    0.35,
    0.20,
    "Wystaw",
    true,
    ticketWindow
)

local closeTicketBtn = guiCreateButton(
    0.55,
    0.60,
    0.35,
    0.20,
    "Zamknij",
    true,
    ticketWindow
)


addEventHandler("onClientGUIClick",ticketBtn,
    function()

        guiSetVisible(ticketWindow,true)
		guiBringToFront(ticketWindow)

    end,
false)


addEventHandler("onClientGUIClick",closeTicketBtn,
    function()

        guiSetVisible(ticketWindow,false)

    end,
false)



addEventHandler("onClientGUIClick",giveTicketBtn,
    function()

        local row =
            guiGridListGetSelectedItem(playerGrid)

        if row == -1 then
            return
        end

        local playerName =
            guiGridListGetItemText(
                playerGrid,
                row,
                playerCol
            )

        local amount =
            tonumber(guiGetText(ticketEdit))

        if not amount then
            return
        end

        triggerServerEvent(
            "police:giveTicket",
            localPlayer,
            playerName,
            amount
        )

    end,
false)






----------------------------------------------------
-- JAIL GUI
----------------------------------------------------

local jailWindow = guiCreateWindow(
    0.40,
    0.30,
    0.22,
    0.28,
    "Więzienie",
    true
)

guiSetVisible(jailWindow,false)

local cellBox = guiCreateComboBox(
    0.10,
    0.20,
    0.80,
    0.30,
    "Cela",
    true,
    jailWindow
)

guiComboBoxAddItem(cellBox,"Cela 1")
guiComboBoxAddItem(cellBox,"Cela 2")
guiComboBoxAddItem(cellBox,"Cela 3")
guiComboBoxAddItem(cellBox,"Cela 4")

local timeBox = guiCreateComboBox(
    0.10,
    0.45,
    0.80,
    0.30,
    "Czas",
    true,
    jailWindow
)

guiComboBoxAddItem(timeBox,"1")
guiComboBoxAddItem(timeBox,"2")
guiComboBoxAddItem(timeBox,"5")
guiComboBoxAddItem(timeBox,"10")

local jailBtn2 = guiCreateButton(
    0.10,
    0.75,
    0.35,
    0.15,
    "Uwięź",
    true,
    jailWindow
)

local closeJailBtn = guiCreateButton(
    0.55,
    0.75,
    0.35,
    0.15,
    "Zamknij",
    true,
    jailWindow
)



addEventHandler("onClientGUIClick",jailBtn,
    function()

        guiSetVisible(jailWindow,true)
		guiBringToFront(jailWindow)

    end,
false)

addEventHandler("onClientGUIClick",closeJailBtn,
    function()

        guiSetVisible(jailWindow,false)

    end,
false)


addEventHandler("onClientGUIClick",jailBtn2,
    function()

        local row =
            guiGridListGetSelectedItem(playerGrid)

        if row == -1 then
            return
        end

        local playerName =
            guiGridListGetItemText(
                playerGrid,
                row,
                playerCol
            )

        local cell =
            guiComboBoxGetSelected(cellBox) + 1

        local time =
            tonumber(
                guiComboBoxGetItemText(
                    timeBox,
                    guiComboBoxGetSelected(timeBox)
                )
            )

        triggerServerEvent(
            "police:jailPlayer",
            localPlayer,
            playerName,
            cell,
            time
        )

    end,
false)



addEventHandler("onClientGUIClick",trackBtn,
    function()

        local row =
            guiGridListGetSelectedItem(playerGrid)

        if row == -1 then
            return
        end

        local playerName =
            guiGridListGetItemText(
                playerGrid,
                row,
                playerCol
            )

        triggerServerEvent(
            "police:trackPlayer",
            localPlayer,
            playerName
        )

    end,
false)





addEventHandler("onClientGUIClick",weaponBtn,
    function()

        triggerServerEvent(
            "police:getWeapons",
            localPlayer
        )

    end,
false)



















----------------------------------------------------
-- TRACK SOUND
----------------------------------------------------

addEvent("police:playBip",true)
addEventHandler("police:playBip",root,
    function()

        playSound("files/bip.mp3")

    end
)


addEvent("police:setWorking",true)
addEventHandler("police:setWorking",root,
    function(state)

        isWorking = state

        refreshButton()

    end
)

addEventHandler("onClientKey", root,
    function(button, press)
        if not press then return end
        if button ~= "x" then return end

        -- ❌ BLOKADA: pisanie / GUI / chat
        if isChatBoxInputActive() or isConsoleActive() or guiGetInputEnabled() then
            return
        end

        -- ❌ tylko policja na służbie
        if not getElementData(localPlayer, "police:duty") then
            return
        end

        -- ❌ tylko jeśli w pojeździe policji
        local veh = getPedOccupiedVehicle(localPlayer)
        if not veh then return end
        if not getElementData(veh, "police:customModel") then return end

        triggerServerEvent(
            "police:send3DBip",
            localPlayer
        )
    end
)

addEventHandler("onClientKey", root,
    function(button, press)
        if not press then return end
        if button ~= "z" then return end

        -- ❌ BLOKADA: pisanie / GUI / chat
        if isChatBoxInputActive() or isConsoleActive() or guiGetInputEnabled() then
            return
        end

        -- ❌ tylko policja na służbie
        if not getElementData(localPlayer, "police:duty") then
            return
        end

        local veh = getPedOccupiedVehicle(localPlayer)
        if not veh then return end
        if not getElementData(veh, "police:customModel") then return end

        triggerServerEvent(
            "police:toggleLights",
            localPlayer
        )
    end
)


----------------------------------------------------
-- STROBOSKOPY
----------------------------------------------------

local phase = 0

setTimer(function()

    phase = 1 - phase

    for _, veh in ipairs(getElementsByType("vehicle", root, true)) do

        if getElementData(veh, "police:lights") then

            local attached = getAttachedElements(veh)

            if attached then

                local index = 0

                for _, marker in ipairs(attached) do

                    if getElementType(marker) == "marker" then

                        index = index + 1

                        local col = getElementData(marker, "police:lightColor")
                        if not col then col = {255,255,255} end

                        -- 🔥 KLUCZ: LEWY / PRAWY
                        local isLeft = (index % 2 == 1)
                        local shouldBeOn = (phase == 1 and isLeft) or (phase == 0 and not isLeft)

                        if shouldBeOn then
                            setMarkerColor(marker, col[1], col[2], col[3], 220)
                        else
                            setMarkerColor(marker, 0, 0, 0, 0)
                        end

                    end
                end
            end
        end
    end

end, 250, 0)

addEvent("police:play3DBip", true)
addEventHandler("police:play3DBip", root,
    function(x,y,z)

        local sound = playSound3D("files/bip2.mp3", x, y, z)

        setSoundMaxDistance(sound, 150)
        setSoundVolume(sound, 1.0)

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