local font = guiCreateFont(
    "files/Borscha-Regular.ttf",
    13
)

local isWorking = false

----------------------------------------------------
-- GUI
----------------------------------------------------

local window = guiCreateWindow(
    0.35,
    0.25,
    0.30,
    0.45,
    "Pomoc Drogowa",
    true
)

guiSetVisible(window,false)


local bg = guiCreateStaticImage(
    0, 0,
    1, 1,
    "files/bg.png",
    true,
    window
)

local vehGrid = guiCreateGridList(
    0.03,
    0.10,
    0.42,
    0.65,
    true,
    window
)

local vehCol =
    guiGridListAddColumn(
        vehGrid,
        "POJAZDY",
        0.80
    )

local skinGrid = guiCreateGridList(
    0.52,
    0.10,
    0.42,
    0.65,
    true,
    window
)

local skinCol =
    guiGridListAddColumn(
        skinGrid,
        "SKINY",
        0.80
    )

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

----------------------------------------------------
-- MARKER
----------------------------------------------------

addEventHandler("onClientMarkerHit",root,
function(player)

    if player ~= localPlayer then
        return
    end

    if not getElementData(source,"pd:marker") then
        return
    end

    guiSetVisible(window,true)
    showCursor(true)

    triggerServerEvent(
        "pd:openGUI",
        localPlayer
    )

end)

----------------------------------------------------
-- LOAD
----------------------------------------------------

addEvent("pd:loadGUI",true)
addEventHandler("pd:loadGUI",root,
function(vehicles,skins)

    guiGridListClear(vehGrid)
    guiGridListClear(skinGrid)

    for _,v in ipairs(vehicles) do

        local row =
            guiGridListAddRow(vehGrid)

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

        local row =
            guiGridListAddRow(skinGrid)

        guiGridListSetItemText(
            skinGrid,
            row,
            skinCol,
            v.name,
            false,
            false
        )

    end

end)

----------------------------------------------------
-- START / STOP
----------------------------------------------------

addEventHandler("onClientGUIClick",startBtn,
function()

    if not isWorking then

        local veh =
            guiGridListGetSelectedItem(
                vehGrid
            )

        local skin =
            guiGridListGetSelectedItem(
                skinGrid
            )

        if veh == -1 or skin == -1 then
            return
        end

        triggerServerEvent(
            "pd:startJob",
            localPlayer,
            veh + 1,
            skin + 1
        )

    else

        triggerServerEvent(
            "pd:stopJob",
            localPlayer
        )

    end

    guiSetVisible(window,false)
    showCursor(false)

end,false)

----------------------------------------------------
-- CLOSE
----------------------------------------------------

addEventHandler("onClientGUIClick",closeBtn,
function()

    guiSetVisible(window,false)
    showCursor(false)

end,false)

----------------------------------------------------
-- WORKING
----------------------------------------------------

addEvent("pd:setWorking",true)
addEventHandler("pd:setWorking",root,
function(state)

    isWorking = state

    if isWorking then
        guiSetText(startBtn,"Zakończ")
    else
        guiSetText(startBtn,"Rozpocznij")
    end

end)

----------------------------------------------------
-- PANEL PD
----------------------------------------------------

local panel = guiCreateWindow(
    0.40,
    0.30,
    0.20,
    0.20,
    "Panel PD",
    true
)

local panelBG = guiCreateStaticImage(
    0,0,
    1,1,
    "files/bg.png",
    true,
    panel
)

guiSetVisible(panel,false)



local weaponsBtn = guiCreateButton(
    0.10,
    0.30,
    0.80,
    0.20,
    "Pobierz wyposażenie",
    true,
    panel
)

local closePanel = guiCreateButton(
    0.10,
    0.60,
    0.80,
    0.20,
    "Zamknij",
    true,
    panel
)

guiSetFont(startBtn, font)
guiSetFont(closeBtn, font)

guiSetFont(weaponsBtn, font)
guiSetFont(closePanel, font)


addCommandHandler("panelpd",
function()

    guiSetVisible(panel,true)
    showCursor(true)

end)

addEventHandler("onClientGUIClick",weaponsBtn,
function()

    triggerServerEvent(
        "pd:getWeapons",
        localPlayer
    )

end,false)

addEventHandler("onClientGUIClick",closePanel,
function()

    guiSetVisible(panel,false)
    showCursor(false)

end,false)




----------------------------------------------------
-- OBJECT PLACER
----------------------------------------------------

local placingObject = false
local placingModel = nil
local ghostObject = nil
local objectRotation = 0

----------------------------------------------------
-- START PLACE
----------------------------------------------------

function startObjectPlacement(model)

    if placingObject then
        return
    end

    placingObject = true
    placingModel = model
    objectRotation = 0

    local x,y,z = getElementPosition(localPlayer)

    ghostObject = createObject(
        model,
        x,y,z
    )

    setElementAlpha(ghostObject,150)
    setElementCollisionsEnabled(
        ghostObject,
        false
    )

    showCursor(true)

end

----------------------------------------------------
-- RENDER
----------------------------------------------------

addEventHandler("onClientRender", root,
function()

    if not placingObject then
        return
    end

    local cx,cy = getCursorPosition()

    if not cx then
        return
    end

    local sx,sy = guiGetScreenSize()

    local wx,wy,wz =
        getWorldFromScreenPosition(
            cx * sx,
            cy * sy,
            10
        )

    local camX,camY,camZ =
        getCameraMatrix()

    local hit,x,y,z =
        processLineOfSight(
            camX,camY,camZ,
            wx,wy,wz
        )

    if hit then

        setElementPosition(
            ghostObject,
            x,y,z
        )

        setElementRotation(
            ghostObject,
            0,0,
            objectRotation
        )

    end

end)

----------------------------------------------------
-- SCROLL ROTATION
----------------------------------------------------

addEventHandler("onClientKey", root,
function(button, press)

    if not placingObject then
        return
    end

    if not press then
        return
    end

    if button == "mouse_wheel_up" then

        objectRotation =
            objectRotation + 5

    elseif button == "mouse_wheel_down" then

        objectRotation =
            objectRotation - 5

    end

end)

----------------------------------------------------
-- CLICK
----------------------------------------------------

addEventHandler("onClientClick", root,
function(button, state)

    if not placingObject then
        return
    end

    if state ~= "down" then
        return
    end

    ----------------------------------------------------
    -- PLACE
    ----------------------------------------------------

    if button == "left" then

        local x,y,z =
            getElementPosition(
                ghostObject
            )

        triggerServerEvent(
            "pd:createPlacedObject",
            localPlayer,
            placingModel,
            x,y,z,
            0,0,
            objectRotation
        )

        destroyElement(ghostObject)

        ghostObject = nil
        placingObject = false

        showCursor(false)

    ----------------------------------------------------
    -- CANCEL
    ----------------------------------------------------

    elseif button == "right" then

        if isElement(ghostObject) then
            destroyElement(ghostObject)
        end

        ghostObject = nil
        placingObject = false

        showCursor(false)

    end

end)












----------------------------------------------------
-- KLAWISZ Z
----------------------------------------------------

addEventHandler("onClientKey", root,
function(button, press)

    if not press then
        return
    end

    if button == "z" then

        if getElementData(localPlayer,"pd:duty") then

            triggerServerEvent(
                "pd:toggleLights",
                localPlayer
            )

        end

    end

end)




----------------------------------------------------
-- MIGANIE STROBO
----------------------------------------------------

local phase = 0

setTimer(function()

    phase = 1 - phase

    for _,veh in ipairs(
        getElementsByType("vehicle", root, true)
    ) do

        if getElementData(veh,"pd:lights") then

            local attached =
                getAttachedElements(veh)

            if attached then

                local index = 0

                for _,marker in ipairs(attached) do

                    if getElementType(marker) == "marker" then

                        index = index + 1

                        local col =
                            getElementData(
                                marker,
                                "pd:lightColor"
                            )

                        if not col then
                            col = {255,255,0}
                        end

                        local isLeft =
                            (index % 2 == 1)

                        local shouldBeOn =
                            (phase == 1 and isLeft)
                            or
                            (phase == 0 and not isLeft)

                        if shouldBeOn then

                            setMarkerColor(
                                marker,
                                col[1],
                                col[2],
                                col[3],
                                220
                            )

                        else

                            setMarkerColor(
                                marker,
                                0,0,0,0
                            )

                        end

                    end
                end
            end
        end
    end

end,250,0)