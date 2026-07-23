local working = false

-------------------------------------------------
-- FONT
-------------------------------------------------
local font = guiCreateFont("files/Borscha-Regular.ttf", 13)

-------------------------------------------------
-- GUI
-------------------------------------------------
local w = guiCreateWindow(0.35,0.25,0.30,0.45,"Straż Pożarna",true)
guiWindowSetSizable(w,false)
guiSetVisible(w,false)

guiCreateStaticImage(0,0,1,1,"files/bg.png",true,w)

local vehGrid = guiCreateGridList(0.05,0.10,0.40,0.60,true,w)
local vehCol = guiGridListAddColumn(vehGrid,"POJAZDY",0.9)

local skinGrid = guiCreateGridList(0.55,0.10,0.40,0.60,true,w)
local skinCol = guiGridListAddColumn(skinGrid,"SKINY",0.9)

local btnMain = guiCreateButton(0.15,0.75,0.70,0.10,"Rozpocznij",true,w)
local btnClose = guiCreateButton(0.15,0.87,0.70,0.08,"Zamknij",true,w)

guiSetFont(btnMain,font)
guiSetFont(btnClose,font)

-------------------------------------------------
-- OPEN PANEL
-------------------------------------------------
addEventHandler("onClientMarkerHit",root,function(plr)

    if plr ~= localPlayer then return end
    if not getElementData(source,"firefighter:marker") then return end

    guiSetVisible(w,true)
    showCursor(true)

    guiGridListClear(vehGrid)
    guiGridListClear(skinGrid)

    for i,v in ipairs(Config.Vehicles) do
        local r = guiGridListAddRow(vehGrid)
        guiGridListSetItemText(vehGrid,r,vehCol,v.name,false,false)
    end

    for i,v in ipairs(Config.Skins) do
        local r = guiGridListAddRow(skinGrid)
        guiGridListSetItemText(skinGrid,r,skinCol,v.name,false,false)
    end
end)

-------------------------------------------------
-- CLOSE
-------------------------------------------------
addEventHandler("onClientGUIClick",btnClose,function()

    guiSetVisible(w,false)
    showCursor(false)

end,false)

-------------------------------------------------
-- START / STOP
-------------------------------------------------
addEventHandler("onClientGUIClick",btnMain,function()

    if not working then

        local v = guiGridListGetSelectedItem(vehGrid)
        local s = guiGridListGetSelectedItem(skinGrid)

        if v == -1 or s == -1 then
            outputChatBox("Wybierz pojazd i skin",255,0,0)
            return
        end

        triggerServerEvent(
            "firefighter:startDuty",
            localPlayer,
            v+1,
            s+1
        )

    else

        triggerServerEvent(
            "firefighter:stopDuty",
            localPlayer
        )

    end

    guiSetVisible(w,false)
    showCursor(false)

end,false)


addEvent("firefighter:startCleanAnim",true)
addEventHandler("firefighter:startCleanAnim",root,function(spill)

    if spillGame then return end
    if getPedOccupiedVehicle(localPlayer) then return end

    setPedAnimation(localPlayer, "ped", "idle_tired", -1, true, false, false, false)

    setTimer(function()
        setPedAnimation(localPlayer, false)
        triggerServerEvent("firefighter:cleanSpill", localPlayer, spill)
    end, 2000, 1)

end)
setTimer(function()
    setPedAnimation(localPlayer, "BIKE", "BIKEv_Back", -1, true, false, false, false)
end, 50, 1)


-------------------------------------------------
-- DUTY STATE
-------------------------------------------------
addEvent("firefighter:setDuty",true)
addEventHandler("firefighter:setDuty",root,function(state)

    working = state

    if state then
        guiSetText(btnMain,"Zakończ")
    else
        guiSetText(btnMain,"Rozpocznij")
    end
end)

-------------------------------------------------
-- STROBOSKOPY
-------------------------------------------------
addEventHandler("onClientKey",root,function(key,press)

    if not press then return end
    if key ~= "z" then return end

    if not getElementData(localPlayer,"firefighter:duty") then
        return
    end

    triggerServerEvent(
        "firefighter:toggleLights",
        localPlayer
    )

end)

-------------------------------------------------
-- SYRENA
-------------------------------------------------
addEventHandler("onClientKey",root,function(key,press)

    if not press then return end
    if key ~= "x" then return end

    if not getElementData(localPlayer,"firefighter:duty") then
        return
    end

    local s = playSound("files/bip2.mp3")

    if s then
        setSoundVolume(s,1)
    end

end)

-------------------------------------------------
-- SAFD BIP
-------------------------------------------------
addEvent("firefighter:playBip",true)
addEventHandler("firefighter:playBip",root,function()

    local s = playSound("files/bip.mp3")

    if s then
        setSoundVolume(s,1)
    end

end)

-------------------------------------------------
-- FLASH SYSTEM
-------------------------------------------------
local phase = 0

setTimer(function()

    phase = 1 - phase

    for _,veh in ipairs(getElementsByType("vehicle")) do

        if getElementData(veh,"firefighter:lights") then

            local attached = getAttachedElements(veh)

            if attached then

                local index = 0

                for _,m in ipairs(attached) do

                    if isElement(m) and getElementType(m) == "marker" then

                        index = index + 1

                        local col = getElementData(m,"ff_color")

                        if col then

                            local active =
                                (phase == 0 and index % 2 == 0)
                                or
                                (phase == 1 and index % 2 == 1)

                            if active then

                                setMarkerColor(
                                    m,
                                    col[1],
                                    col[2],
                                    col[3],
                                    220
                                )

                            else

                                setMarkerColor(m,0,0,0,0)

                            end
                        end
                    end
                end
            end
        end
    end

end,250,0)




-------------------------------------------------
-- SPILL MINIGAME
-------------------------------------------------

local sx,sy = guiGetScreenSize()

local spillGame = false
local spillObject = nil

local spillProgress = 1

local spillDragging = false
local spillCable = nil

local spillLines = {}

local spillFont =
    dxCreateFont(
        "files/Borscha-Regular.ttf",
        14
    )

local spillBG =
    dxCreateTexture(
        "files/spill_bg.png"
    )

local spillCables = {

    {
        name = "A1",
        color = {255,0,0},
        key = "red"
    },

    {
        name = "A2",
        color = {255,255,0},
        key = "yellow"
    },

    {
        name = "A3",
        color = {0,120,255},
        key = "blue"
    }
}

local spillPoints = {

    {
        x = 0.68,
        y = 0.35,
        key = "red"
    },

    {
        x = 0.68,
        y = 0.50,
        key = "yellow"
    },

    {
        x = 0.68,
        y = 0.65,
        key = "blue"
    }
}

-------------------------------------------------
-- START
-------------------------------------------------

addEvent(
    "firefighter:startSpillMinigame",
    true
)

addEventHandler(
    "firefighter:startSpillMinigame",
    root,
    function(spill)

        if spillGame then
            return
        end

        spillGame = true
        spillObject = spill

        spillProgress = 1
        spillLines = {}

        showCursor(true)

        outputChatBox(
            "Połącz elementy.",
            255,255,0
        )
    end
)

-------------------------------------------------
-- RENDER
-------------------------------------------------

addEventHandler(
    "onClientRender",
    root,
    function()

        if not spillGame then
            return
        end

        dxDrawImage(
            sx*0.3,
            sy*0.2,
            sx*0.4,
            sy*0.6,
            spillBG
        )

        dxDrawText(
            "USUWANIE ROZLANEGO PŁYNU",
            0.3*sx,
            0.15*sy,
            0.7*sx,
            0.2*sy,
            tocolor(255,255,255),
            1.2,
            spillFont,
            "center"
        )

        -------------------------------------------------
        -- CABLES
        -------------------------------------------------

        for i=1,spillProgress do

            local c = spillCables[i]

            if c then

                local x = 0.35*sx
                local y =
                    (0.3 + (i*0.1))*sy

                dxDrawRectangle(
                    x,
                    y,
                    120,
                    30,
                    tocolor(
                        c.color[1],
                        c.color[2],
                        c.color[3],
                        220
                    )
                )

                dxDrawText(
                    c.name,
                    x,
                    y,
                    x+120,
                    y+30,
                    tocolor(255,255,255),
                    1,
                    spillFont,
                    "center",
                    "center"
                )
            end
        end

        -------------------------------------------------
        -- TARGETS
        -------------------------------------------------

        for i=1,spillProgress do

            local p =
                spillPoints[i]

            if p then

                local x =
                    p.x * sx

                local y =
                    p.y * sy

                dxDrawCircle(
                    x,
                    y,
                    15,
                    0,
                    360,
                    tocolor(
                        255,
                        255,
                        255,
                        200
                    )
                )
            end
        end

        -------------------------------------------------
        -- SAVED LINES
        -------------------------------------------------

        for _,l in ipairs(
            spillLines
        ) do

            dxDrawLine(
                l.x1,
                l.y1,
                l.x2,
                l.y2,
                tocolor(
                    l.r,
                    l.g,
                    l.b,
                    255
                ),
                3
            )
        end

        -------------------------------------------------
        -- DRAGGING
        -------------------------------------------------

        if spillDragging
        and spillCable then

            local cx,cy =
                getCursorPosition()

            if not cx then
                return
            end

            local mx,my =
                cx*sx,
                cy*sy

            dxDrawLine(
                spillCable.x,
                spillCable.y,
                mx,
                my,
                tocolor(
                    spillCable.color[1],
                    spillCable.color[2],
                    spillCable.color[3],
                    255
                ),
                2
            )
        end
    end
)

-------------------------------------------------
-- CLICK
-------------------------------------------------

addEventHandler(
    "onClientClick",
    root,
    function(btn,state)

        if not spillGame then
            return
        end

        if btn == "left"
        and state == "down" then

            local cx,cy =
                getCursorPosition()

            if not cx then
                return
            end

            local mx,my =
                cx*sx,
                cy*sy

            local i =
                spillCables[
                    spillProgress
                ]

            local x = 0.35*sx

            local y =
                (0.3 +
                (spillProgress*0.1))*sy

            if mx >= x
            and mx <= x+120
            and my >= y
            and my <= y+30 then

                spillDragging = true

                spillCable = {

                    x = x+60,
                    y = y+15,

                    color = i.color,
                    key = i.key
                }
            end
        end

        -------------------------------------------------
        -- RELEASE
        -------------------------------------------------

        if btn == "left"
        and state == "up"
        and spillDragging then

            local cx,cy =
                getCursorPosition()

            if not cx then
                return
            end

            local mx,my =
                cx*sx,
                cy*sy

            local target =
                spillPoints[
                    spillProgress
                ]

            local tx =
                target.x * sx

            local ty =
                target.y * sy

            local dist =
                getDistanceBetweenPoints2D(
                    mx,my,
                    tx,ty
                )

            if spillCable.key
            == target.key
            and dist < 40 then

                table.insert(
                    spillLines,
                    {

                        x1 =
                            spillCable.x,

                        y1 =
                            spillCable.y,

                        x2 = tx,
                        y2 = ty,

                        r =
                            spillCable.color[1],

                        g =
                            spillCable.color[2],

                        b =
                            spillCable.color[3]
                    }
                )

                spillProgress =
                    spillProgress + 1

                if spillProgress
                > #spillCables then

                    triggerServerEvent(
                        "firefighter:cleanSpill",
                        localPlayer,
                        spillObject
                    )

                    spillGame = false

                    showCursor(false)
                end

            else

                outputChatBox(
                    "Błędne połączenie.",
                    255,0,0
                )

                spillGame = false

                showCursor(false)
            end

            spillDragging = false
            spillCable = nil
        end
    end
)

local spillTexture = dxCreateTexture("files/spill_bg_road.png")

addEventHandler("onClientRender", root, function()

    local px, py, pz = getElementPosition(localPlayer)

    for _, spill in ipairs(getElementsByType("spill")) do

        local x, y, z = getElementPosition(spill)

        local dist = getDistanceBetweenPoints3D(px, py, pz, x, y, z)

        if dist <= 25 then

            local sx, sy = getScreenFromWorldPosition(x, y, z + 0.05)

            if sx and sy then

                dxDrawImage(
                    sx - 80,
                    sy - 80,
                    160,
                    160,
                    spillTexture,
                    0,
                    0,
                    0,
                    tocolor(255,255,255,220)
                )

            end
        end
    end
end)



addEventHandler("onClientKey", root,
    function(button, press)

        if button == "F1" and press then

            if working then
                cancelEvent()
                outputChatBox("Freeroam zablokowany podczas pracy.", 255,0,0)
            end

        end

    end
)

addEventHandler("onClientKey", root,
    function(button, press)

        if button == "F2" and press then

            if working then
                cancelEvent()
                outputChatBox("Mapa zablokowana podczas pracy. Nie bądź leń i dojedź", 255,0,0)
            end

        end

    end
)

addEventHandler("onClientKey", root,
    function(button, press)

        if button == "F4" and press then

            if working then
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
        if not working then
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


addEvent("firefighter:cleanSpill",true)
addEventHandler("firefighter:cleanSpill",root,function(spill)

    if not isElement(spill) then return end

    setPedAnimation(localPlayer, false)
    spillGame = false
    spillDragging = false
    spillCable = nil
    spillLines = {}

    showCursor(false)

    triggerServerEvent("firefighter:cleanSpill", localPlayer, spill)
end)