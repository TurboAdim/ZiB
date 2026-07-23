function safeDestroy(element)

    if isElement(element) then
        destroyElement(element)
    end

end

function getRandomTable(tbl)

    return tbl[math.random(#tbl)]

end

function createCustomVehicle(model,x,y,z)

    if tonumber(model) > 611 then

        return exports["newmodels_red"]:createVehicle(
            tonumber(model),
            x,y,z
        )

    end

    return createVehicle(
        tonumber(model),
        x,y,z
    )

end