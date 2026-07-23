local batteryFont = dxCreateFont(
    "files/Borscha-Regular.ttf",
    14
)



----------------------------------------------------
-- DX BATTERY MINIGAME
----------------------------------------------------

local sx, sy = guiGetScreenSize()

local active = false
local vehicle = nil

local dragging = false
local dragCable = nil

local batteryBG = dxCreateTexture("files/battery_bg.png")

local cables = {
    {name="PLUS (+)", color={255,0,0}, key="red"},
    {name="MINUS (-)", color={0,0,0}, key="black"},
    {name="NALADUJ XIAOMI", color={0,255,0}, key="green"}
}

local points = {
    {x=0.45, y=0.55, key="red"},
    {x=0.55, y=0.55, key="black"},
    {x=0.65, y=0.35, key="green"}
}

local progress = 1
local lines = {}

----------------------------------------------------
-- START MINIGAME
----------------------------------------------------
addEvent("pd:startBatteryMinigame", true)
addEventHandler("pd:startBatteryMinigame", root,
function(veh)
    if active then return end

    active = true
    vehicle = veh

    progress = 1   -- 🔥 TUTAJ
    lines = {}

    showCursor(true)
    outputChatBox("Podłącz przewody do akumulatora", 255,255,0)
end)

----------------------------------------------------
-- DX RENDER
----------------------------------------------------
addEventHandler("onClientRender", root,
function()
    if not active then return end

    local sx, sy = guiGetScreenSize()

    -- BACKGROUND IMAGE
    dxDrawImage(
        sx * 0.3,
        sy * 0.2,
        sx * 0.4,
        sy * 0.6,
        batteryBG
    )

    -- PANEL (opcjonalny overlay)
    --[[dxDrawRectangle(
        0.3*sx,
        0.2*sy,
        0.4*sx,
        0.6*sy,
        tocolor(0,0,0,120)
    )--]]
	

    dxDrawText(
        "MINIGRA ŁADOWANIA AKUMULATORA",
        0.3*sx, 0.15*sy,
        0.7*sx, 0.2*sy,
        tocolor(255,255,255),
        1.2, batteryFont,
        "center"
    )

    ----------------------------------------------------
    -- CABLES
    ----------------------------------------------------
    for i=1, progress do
        local c = cables[i]
        if c then
            local x = 0.35*sx
            local y = (0.3 + (i*0.1))*sy

            dxDrawRectangle(x, y, 120, 30, tocolor(c.color[1],c.color[2],c.color[3],200))
            dxDrawText(c.name, x, y, x+120, y+30, tocolor(255,255,255), 1, batteryFont, "center", "center")
        end
    end

    ----------------------------------------------------
    -- TARGET POINTS
    ----------------------------------------------------
    for i=1, progress do
        local p = points[i]
        if p then
            local x = p.x * sx
            local y = p.y * sy

            --dxDrawCircle(x, y, 10, 0, 360, tocolor(255,255,255,180))
			-- dxDrawRectangle(x-5, y-5, 10, 10, color)
			dxDrawRectangle(
    x - 10,
    y - 10,
    20,
    20,
    tocolor(255,255,0,255)
)
        end
    end

    ----------------------------------------------------
    -- LINES
    ----------------------------------------------------
    for _,l in ipairs(lines) do
        dxDrawLine(l.x1,l.y1,l.x2,l.y2, tocolor(l.r,l.g,l.b,255), 3)
    end

    ----------------------------------------------------
    -- DRAG LINE
    ----------------------------------------------------
    if dragging and dragCable then
        local cx, cy = getCursorPosition()
        if not cx then return end

        local mx, my = cx*sx, cy*sy

        dxDrawLine(
            dragCable.x,
            dragCable.y,
            mx,
            my,
            tocolor(dragCable.color[1],dragCable.color[2],dragCable.color[3],255),
            2
        )
    end
end)

----------------------------------------------------
-- CLICK START DRAG
----------------------------------------------------
addEventHandler("onClientClick", root,
function(btn, state)
    if not active then return end

    if btn == "left" and state == "down" then

        local cx, cy = getCursorPosition()
        if not cx then return end

        local mx, my = cx*sx, cy*sy

        local i = cables[progress]

        local x = 0.35*sx
        local y = (0.3 + (progress*0.1))*sy

        if mx >= x and mx <= x+120 and my >= y and my <= y+30 then

            dragging = true
            dragCable = {
                x = x+60,
                y = y+15,
                color = i.color,
                key = i.key
            }
        end
    end

    if btn == "left" and state == "up" and dragging then

        local cx, cy = getCursorPosition()
        if not cx then return end

        local mx, my = cx*sx, cy*sy

        local target = points[progress]

        if not target then return end

        local tx = target.x * sx
        local ty = target.y * sy

        local dist = getDistanceBetweenPoints2D(mx,my,tx,ty)

        if dragCable.key == target.key and dist < 40 then

            table.insert(lines, {
                x1 = dragCable.x,
                y1 = dragCable.y,
                x2 = tx,
                y2 = ty,
                r = dragCable.color[1],
                g = dragCable.color[2],
                b = dragCable.color[3]
            })

            progress = progress + 1

            outputChatBox("Poprawnie podłączono kabel", 0,255,0)

            if progress > #cables then
                finishMinigame(true)
            end

        else
            outputChatBox("Błędne podłączenie", 255,0,0)
            finishMinigame(false)
        end

        dragging = false
        dragCable = nil
    end
end)

----------------------------------------------------
-- FINISH
----------------------------------------------------
function finishMinigame(success)
    active = false
    showCursor(false)

    if success then
        triggerServerEvent(
            "pd:finishBatteryRepair",
            localPlayer,
            vehicle
        )
    end

    vehicle = nil
    dragging = false
    dragCable = nil
    lines = {}
end

----------------------------------------------------
-- ESC CANCEL
----------------------------------------------------
addEventHandler("onClientKey", root,
function(key, press)
    if not active then return end

    if key == "escape" and press then
        finishMinigame(false)
        cancelEvent()
    end
end)