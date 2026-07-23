local sx, sy = guiGetScreenSize()

local active = false
local vehicle = nil

local bg = nil
local font = nil

local dragging = false
local dragCable = nil

local progress = 1
local lines = {}

addEventHandler("onClientResourceStart", resourceRoot, function()

    bg = dxCreateTexture("files/immobiliser.png", "dxt5")
    font = dxCreateFont("files/Borscha-Regular.ttf", 14)

    --outputChatBox("[IMMOBILISER] bg="..tostring(bg))
    --outputChatBox("[IMMOBILISER] font="..tostring(font))
end)




local cables = {
    {name="IGNITION", color={255,0,0}, key="red"},
    {name="IMMOBILISER", color={0,0,0}, key="black"},
    {name="ECU BYPASS", color={0,255,0}, key="green"}
}

local points = {
    {x=0.45, y=0.55, key="red"},
    {x=0.55, y=0.55, key="black"},
    {x=0.65, y=0.35, key="green"}
}

----------------------------------------------------
-- START
----------------------------------------------------

addEvent("criminal:startLockpickMinigame", true)
addEventHandler("criminal:startLockpickMinigame", root, function(veh)

    if active then return end

    active = true
    vehicle = veh

    progress = 1
    lines = {}

    showCursor(true)
end)

----------------------------------------------------
-- RENDER
----------------------------------------------------

addEventHandler("onClientRender", root, function()
    if not active then return end
    if not bg then return end

    dxDrawImage(
        sx * 0.3,
        sy * 0.2,
        sx * 0.4,
        sy * 0.6,
        bg,
        0,0,0,
        tocolor(255,255,255,255)
    )

    dxDrawRectangle(
        sx*0.3,
        sy*0.2,
        sx*0.4,
        sy*0.6,
        tocolor(0,0,0,120)
    )

    dxDrawText(
        "IMMOBILISER BYPASS",
        sx*0.3,
        sy*0.15,
        sx*0.7,
        sy*0.2,
        tocolor(255,255,255),
        1.2,
        font or "default",
        "center"
    )

    -- cables
    for i=1, progress do
        local c = cables[i]
        if c then
            local x = sx*0.35
            local y = sy*(0.3 + (i*0.1))

            dxDrawRectangle(x, y, 120, 30, tocolor(c.color[1],c.color[2],c.color[3],200))
            dxDrawText(c.name, x, y, x+120, y+30, tocolor(255,255,255), 1, font or "default", "center", "center")
        end
    end

    -- points
    for i=1, progress do
        local p = points[i]
        if p then
            dxDrawRectangle(
                p.x*sx-5,
                p.y*sy-5,
                10,10,
                tocolor(255,255,255,180)
            )
        end
    end

    -- lines
    for _,l in ipairs(lines) do
        dxDrawLine(l.x1,l.y1,l.x2,l.y2, tocolor(l.r,l.g,l.b,255), 3)
    end

    -- drag line
    if dragging and dragCable then
        local cx, cy = getCursorPosition()
        if not cx then return end

        dxDrawLine(
            dragCable.x,
            dragCable.y,
            cx*sx,
            cy*sy,
            tocolor(dragCable.color[1],dragCable.color[2],dragCable.color[3]),
            3
        )
    end
end)

----------------------------------------------------
-- CLICK
----------------------------------------------------

addEventHandler("onClientClick", root,
function(btn, state)

    if not active then return end

    if btn == "left" and state == "down" then

        local cx, cy = getCursorPosition()
        if not cx then return end

        local mx, my = cx*sx, cy*sy

        local cable = cables[progress]

        local x = sx*0.35
        local y = sy*(0.3 + (progress*0.1))

        if mx >= x and mx <= x+120 and my >= y and my <= y+30 then

            dragging = true

            dragCable = {
                x = x+60,
                y = y+15,
                color = cable.color,
                key = cable.key
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

            if progress > #cables then
                active = false
                showCursor(false)

                triggerServerEvent("criminal:minigameSuccess", localPlayer, vehicle)

                vehicle = nil
                lines = {}
                dragging = false
                dragCable = nil
                return
            end

        else
            active = false
            showCursor(false)

            triggerServerEvent("criminal:minigameFailed", localPlayer, vehicle)

            vehicle = nil
            lines = {}
        end

        dragging = false
        dragCable = nil
    end
end)



addEventHandler("onClientKey", root,
function(key, press)
    if not active then return end

    if key == "escape" and press then
        active = false
        showCursor(false)

        triggerServerEvent("criminal:minigameFailed", localPlayer, vehicle)

        vehicle = nil
        lines = {}
        dragging = false
        dragCable = nil
    end
end)