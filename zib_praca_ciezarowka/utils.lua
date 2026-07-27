function safeDestroy(element)

    if isElement(element) then
        destroyElement(element)
    end

end

function getRandomTable(tbl)

    return tbl[math.random(#tbl)]

end

function calculatePayment(x1,y1,z1,x2,y2,z2,illegal)

    local dist = getDistanceBetweenPoints3D(
        x1,y1,z1,
        x2,y2,z2
    )

    local multiplier = illegal and 3 or 1

    return math.floor(dist * multiplier), math.floor(dist)

end