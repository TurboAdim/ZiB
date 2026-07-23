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
    {name="MINUS (-)", color={120,120,120}, key="black"},
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

    if active then
        return
    end

    active = true
    vehicle = veh

    progress = 1
    lines = {}

    dragging = false
    dragCable = nil

    showCursor(true)

    outputChatBox(
        "Podłącz przewody do akumulatora",
        255,255,0
    )

end)

----------------------------------------------------
-- DX RENDER
----------------------------------------------------

addEventHandler("onClientRender", root,
function()

    if not active then
        return
    end

    ----------------------------------------------------
    -- BACKGROUND
    ----------------------------------------------------

    dxDrawImage(
        sx * 0.30,
        sy * 0.20,
        sx * 0.40,
        sy * 0.60,
        batteryBG
    )

    ----------------------------------------------------
    -- TITLE
    ----------------------------------------------------

    dxDrawText(
        "MINIGRA ŁADOWANIA AKUMULATORA",
        sx * 0.30,
        sy * 0.15,
        sx * 0.70,
        sy * 0.20,
        tocolor(255,255,255,255),
        1.2,
        batteryFont,
        "center",
        "center"
    )

    ----------------------------------------------------
    -- CABLES
    ----------------------------------------------------

    for i = 1, progress do

        local c = cables[i]

        if c then

            local x = sx * 0.35
            local y = sy * (0.30 + (i * 0.10))

            dxDrawRectangle(
                x - 2,
                y - 2,
                124,
                34,
                tocolor(255,255,255,200)
            )

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
                x + 120,
                y + 30,
                tocolor(255,255,255,255),
                1,
                batteryFont,
                "center",
                "center"
            )

        end

    end

    ----------------------------------------------------
    -- TARGET POINTS
    ----------------------------------------------------

    for i = 1, progress do

        local p = points[i]

        if p then

            local x = p.x * sx
            local y = p.y * sy

            dxDrawRectangle(
                x - 12,
                y - 12,
                24,
                24,
                tocolor(0,0,0,200)
            )

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
    -- SAVED LINES
    ----------------------------------------------------

    for _, line in ipairs(lines) do

        dxDrawLine(
            line.x1,
            line.y1,
            line.x2,
            line.y2,
            tocolor(
                line.r,
                line.g,
                line.b,
                255
            ),
            3
        )

    end

    ----------------------------------------------------
    -- CURRENT DRAG LINE
    ----------------------------------------------------

    if dragging and dragCable then

        local cx, cy = getCursorPosition()

        if cx then

            local mx = cx * sx
            local my = cy * sy

            dxDrawLine(
                dragCable.x,
                dragCable.y,
                mx,
                my,
                tocolor(
                    dragCable.color[1],
                    dragCable.color[2],
                    dragCable.color[3],
                    255
                ),
                3
            )

        end

    end

end)

----------------------------------------------------
-- CLICK
----------------------------------------------------

addEventHandler("onClientClick", root,
function(button, state)

    if not active then
        return
    end

    ----------------------------------------------------
    -- START DRAG
    ----------------------------------------------------

    if button == "left" and state == "down" then

        local cx, cy = getCursorPosition()

        if not cx then
            return
        end

        local mx = cx * sx
        local my = cy * sy

        local cable = cables[progress]

        if not cable then
            return
        end

        local x = sx * 0.35
        local y = sy * (0.30 + (progress * 0.10))

        if mx >= x and mx <= x + 120 and
           my >= y and my <= y + 30 then

            dragging = true

            dragCable = {
                x = x + 60,
                y = y + 15,
                color = cable.color,
                key = cable.key
            }

        end

    end

    ----------------------------------------------------
    -- RELEASE DRAG
    ----------------------------------------------------

    if button == "left" and
       state == "up" and
       dragging and
       dragCable then

        local cx, cy = getCursorPosition()

        if not cx then
            return
        end

        local mx = cx * sx
        local my = cy * sy

        local target = points[progress]

        if not target then
            return
        end

        local tx = target.x * sx
        local ty = target.y * sy

        local dist = getDistanceBetweenPoints2D(
            mx,
            my,
            tx,
            ty
        )

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

            outputChatBox(
                "Poprawnie podłączono kabel",
                0,255,0
            )

            if progress > #cables then
                finishMinigame(true)
            end

        else

            outputChatBox(
                "Błędne podłączenie",
                255,0,0
            )

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
    progress = 1

end

----------------------------------------------------
-- ESC CANCEL
----------------------------------------------------

addEventHandler("onClientKey", root,
function(key, press)

    if not active then
        return
    end

    if key == "escape" and press then

        finishMinigame(false)
        cancelEvent()

    end

end)