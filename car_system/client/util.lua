-- Util

PScreen = Vector2(guiGetScreenSize());
px, py = ( PScreen.x / 1920 ), ( PScreen.y / 1080 )

TableAlpha = {}
ButtonColorHover = tocolor(54, 54, 54, 255)

function isCursor (x, y, w, h)
    if isCursorShowing() then
        local mx, my = getCursorPosition()
        local cursorx, cursory = mx * PScreen.x, my * PScreen.y
        if cursorx > x and cursorx < x + w and cursory > y and cursory < y + h then
            return true
        end
    end
    return false
end

function isConvertNumber(number)
    local formatted = number   
    while true do       
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1 %2")     
        if (k == 0) then       
            break   
        end
    end   
    return formatted 
end

function dxCreateButton (x, y, w, h, image_state, image_hover, color, r, g, b, r1, g1, b1, index)
    if TableAlpha[index] == nil then
        TableAlpha[index] = {}
        TableAlpha[index] = 0
    end
    
    if isCursor(x, y, w, h) then
        if TableAlpha[index] <= 240 then
            TableAlpha[index] = TableAlpha[index] + 15
        end
        ButtonColorHover = tocolor(r1, g1, b1, (color/255) * TableAlpha[index])
    else
        if TableAlpha[index] ~= 0 then
            TableAlpha[index] = TableAlpha[index] - 15
        end
        ButtonColorHover = tocolor(r1, g1, b1, (color/255) * TableAlpha[index])
    end

    dxDrawImage(x, y, w, h, image_state, 0, 0, 0, tocolor(r, g, b, color))
    dxDrawImage(x, y, w, h, image_hover, 0, 0, 0, ButtonColorHover)
end

function isEventHandlerAdded( sEventName, pElementAttachedTo, func )
    if type( sEventName ) == 'string' and isElement( pElementAttachedTo ) and type( func ) == 'function' then
        local aAttachedFunctions = getEventHandlers( sEventName, pElementAttachedTo )
        if type( aAttachedFunctions ) == 'table' and #aAttachedFunctions > 0 then
            for i, v in ipairs( aAttachedFunctions ) do
                if v == func then
                    return true
                end
            end
        end
    end
    return false
end

_dxGetTextWidth = dxGetTextWidth
local DGTWData = {};

function dxGetTextWidth(text, scale, font, colorCode)
    if DGTWData[text] and
        DGTWData[text].scale == scale and
        DGTWData[text].font == font and
        DGTWData[text].colorCode == colorCode then

        return DGTWData[text].value
    end

    DGTWData[text] = {
        scale = scale;
        text = text;
        font = font;
        colorCode = colorCode;
        value = _dxGetTextWidth(text, scale, font, colorCode)
    }
    return DGTWData[text].value;
end

function math.round(value)
	return math.ceil(value)
end

function dxCreateText (text, x, y, w, h, ... )
    dxDrawText (text, x, y, x + w, y + h, ... )
end

function dxDrawRoundedRectangle(x, y, width, height, radius, color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y+radius, width-(radius*2), height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawCircle(x+radius, y+radius, radius, 180, 270, color, color, 16, 1, postGUI)
    dxDrawCircle(x+radius, (y+height)-radius, radius, 90, 180, color, color, 16, 1, postGUI)
    dxDrawCircle((x+width)-radius, (y+height)-radius, radius, 0, 90, color, color, 16, 1, postGUI)
    dxDrawCircle((x+width)-radius, y+radius, radius, 270, 360, color, color, 16, 1, postGUI)
    dxDrawRectangle(x, y+radius, radius, height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y+height-radius, width-(radius*2), radius, color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+width-radius, y+radius, radius, height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y, width-(radius*2), radius, color, postGUI, subPixelPositioning)
end