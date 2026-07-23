local font = guiCreateFont("files/Borscha-Regular.ttf",13)

local isWorking = false


addEventHandler("onClientResourceStart", resourceRoot, function()
    triggerServerEvent("tornado:clientReady", localPlayer)
end)
-------------------------------------------------
-- GUI
-------------------------------------------------

local window = guiCreateWindow(
    0.35,0.25,0.30,0.45,
    "Praca Łowcy Tornad",
    true
)

guiSetVisible(window,false)
guiWindowSetSizable(window,false)

guiCreateStaticImage(
    0,0,1,1,
    "files/bg.png",
    true,
    window
)

-------------------------------------------------
-- GRIDLISTY
-------------------------------------------------

local vehGrid = guiCreateGridList(
    0.03,0.10,0.42,0.65,
    true,window
)

local vehCol = guiGridListAddColumn(
    vehGrid,
    "POJAZDY",
    0.8
)

local skinGrid = guiCreateGridList(
    0.52,0.10,0.42,0.65,
    true,window
)

local skinCol = guiGridListAddColumn(
    skinGrid,
    "SKINY",
    0.8
)

-------------------------------------------------
-- BUTTONY
-------------------------------------------------

local startBtn = guiCreateButton(
    0.03,0.80,0.42,0.12,
    "Rozpocznij",
    true,window
)

local closeBtn = guiCreateButton(
    0.52,0.80,0.42,0.12,
    "Zamknij",
    true,window
)

guiSetFont(startBtn,font)
guiSetFont(closeBtn,font)

-------------------------------------------------
-- OPEN GUI
-------------------------------------------------

addEvent("tornado:openGUI",true)
addEventHandler("tornado:openGUI",root,
function(vehicles,skins)

    guiGridListClear(vehGrid)
    guiGridListClear(skinGrid)

    for _,v in ipairs(vehicles) do

        local row = guiGridListAddRow(vehGrid)

        guiGridListSetItemText(
            vehGrid,
            row,
            vehCol,
            v.name.." ["..v.class.."]",
            false,false
        )
    end

    for _,v in ipairs(skins) do

        local row = guiGridListAddRow(skinGrid)

        guiGridListSetItemText(
            skinGrid,
            row,
            skinCol,
            v.name,
            false,false
        )
    end

    guiSetVisible(window,true)
    showCursor(true)

end)









-------------------------------------------------
-- MARKER HIT
-------------------------------------------------

local markerTick = 0

addEventHandler("onClientMarkerHit", root, function(hitPlayer)

    if hitPlayer ~= localPlayer then return end

    if not getElementData(source, "tornado:jobmarker") then
        return
    end

    if getTickCount() - markerTick < 3000 then return end
    markerTick = getTickCount()

    triggerServerEvent(
        "tornado:requestGUI",
        localPlayer
    )
end)

-------------------------------------------------
-- START JOB
-------------------------------------------------

addEventHandler("onClientGUIClick",startBtn,
function()

    if not isWorking then

        local veh = guiGridListGetSelectedItem(vehGrid)
        local skin = guiGridListGetSelectedItem(skinGrid)

        if veh == -1 or skin == -1 then
            outputChatBox("Wybierz pojazd i skin.",255,0,0)
            return
        end

        triggerServerEvent(
            "tornado:startJob",
            localPlayer,
            veh+1,
            skin+1
        )

    else

        triggerServerEvent(
            "tornado:stopJob",
            localPlayer
        )

    end

    guiSetVisible(window,false)
    showCursor(false)

end,false)

-------------------------------------------------
-- CLOSE
-------------------------------------------------

addEventHandler("onClientGUIClick",closeBtn,
function()

    guiSetVisible(window,false)
    showCursor(false)

end,false)

-------------------------------------------------
-- WORK STATE
-------------------------------------------------

addEvent("tornado:setWorking",true)
addEventHandler("tornado:setWorking",root,
function(state)

    isWorking = state

    if state then
        guiSetText(startBtn,"Zakończ")
    else
        guiSetText(startBtn,"Rozpocznij")
    end

end)

-------------------------------------------------
-- RADAR TORNADA
-------------------------------------------------

local tornadoBlip = nil

addEvent("tornado:updateRadar", true)
addEventHandler("tornado:updateRadar", root, function(x, y, z, accuracy)

    if not x or not y then return end

    if x == 99999 then
        if isElement(tornadoBlip) then
            destroyElement(tornadoBlip)
        end
        tornadoBlip = nil
        return
    end

    local randomX = x + math.random(-accuracy, accuracy)
    local randomY = y + math.random(-accuracy, accuracy)

    if not isElement(tornadoBlip) then
        tornadoBlip = createBlip(randomX, randomY, z, 3)
    else
        setElementPosition(tornadoBlip, randomX, randomY, z)
    end
end)

--[[
-------------------------------------------------
-- STREFA
-------------------------------------------------

local area = createRadarArea(
    math.min(Config.Zone.x1,Config.Zone.x2),
    math.min(Config.Zone.y1,Config.Zone.y2),

    math.abs(Config.Zone.x2-Config.Zone.x1),
    math.abs(Config.Zone.y2-Config.Zone.y1),

    255,0,0,120
)

setRadarAreaFlashing(area,true)--]]





local lastSoundTick = 0

addEvent("tornado:startSound", true)
addEventHandler("tornado:startSound", root, function()

    if getTickCount() - lastSoundTick < 10000 then
        return
    end

    lastSoundTick = getTickCount()

    local sound = playSound("files/muzyka.mp3")

    if sound then
        setSoundVolume(sound, 1)
    end
end)





addEventHandler("onClientResourceStop",resourceRoot,
function()

    if isElement(tornadoBlip) then
        destroyElement(tornadoBlip)
    end

end)

-------------------------------------------------
-- ALARM TORNADA
-------------------------------------------------

addEvent("tornado:alarm",true)
addEventHandler("tornado:alarm",root,
function()

    playSound("files/bip.mp3")

end)


addEvent("tornado:clearRadar",true)
addEventHandler("tornado:clearRadar",root,function()
    if isElement(tornadoBlip) then
        destroyElement(tornadoBlip)
    end
end)