-- Стандартные спойлеры
local defaultSpoilers = {
    { name="SA spoiler 1",  price=5000 },
    { name="SA spoiler 2",  price=5000 },
    { name="SA spoiler 3",  price=5000 },
    { name="SA spoiler 4",  price=5000 },
    { name="SA spoiler 5",  price=5000 },
    { name="SA spoiler 6",  price=5000 },
    { name="SA spoiler 7",  price=5000 },
    { name="SA spoiler 8",  price=5000 },
    { name="SA spoiler 9",  price=5000 },
    { name="SA spoiler 10", price=5000 },
    { name="SA spoiler 11", price=5000 },
    { name="SA spoiler 12", price=5000 },
    { name="SA spoiler 13", price=5000 },
    { name="SA spoiler 14", price=5000 },
    { name="SA spoiler 15", price=5000 },
    { name="SA spoiler 16", price=5000 },
    { name="SA spoiler 17", price=5000 },
    { name="SA spoiler 18", price=5000 },
    { name="SA spoiler 19", price=5000 },
    { name="SA spoiler 20", price=5000 },
}

-- Стандартные колёса
local defaultWheels = {
    { name="Felga 1",            price=11600 },
    { name="Felga 2",      price=24000 },
    { name="Felga 3",            price=6000  },
    { name="Felga 4",        price=13000 },
    { name="Felga 5",        price=18000 },
    { name="Felga 6",        price=22000 },
    { name="Felga 7",              price=6000  },
    { name="Felga 8",             price=17200 },
    { name="Felga 9",             price=16400 },
    { name="Felga 10",               price=8000  },
    { name="Felga 11",       price=10000 },
    { name="Felga 12",     price=15400 },
    { name="Felga 13",             price=33000 },
    { name="Felga 14",     price=21300 },
    { name="Felga 15",    price=62000 },
    { name="Felga 16",                 price=10400 },
    { name="Felga 17",                price=13200 },
    { name="Felga 18",        price=14500 },
    { name="Felga 19",             price=6000  },
    { name="Felga 20",                 price=14000 },
    { name="Felga 21", price=15400 },
    { name="Felga 22",       price=47000 },
    { name="Felga 23",      price=6000  },
    { name="Felga 24",          price=45000 },
    { name="Felga 25",     price=6000  },
    { name="Felga 26",          price=9000  },
    { name="Felga 27",           price=15000 },
    { name="Felga 28",       price=3000  },
    { name="Felga 29",       price=3000  },
    { name="Felga 30",            price=8000  },
    { name="Felga 31",         price=15000 },
    { name="Felga 32",            price=8000  },
    { name="Felga 33",          price=8000  },
    { name="Felga 34",        price=6000  },
    { name="Felga 35",             price=21000 },
    { name="Felga 36",      price=2000  },
    { name="Felga 37",      price=2000  },
    { name="Felga 38",            price=9000  },
    { name="Felga 39",              price=40000 },
    { name="Felga 40",           price=22000 },
    { name="Felga 41",     price= 8000 },
    { name="Felga 42",price= 6000 },
    { name="Felga 43",	 price= 8000 },
    { name="Felga 44",		 price= 3500 },
    { name="Felga 45",		 price= 3500 },
    { name="Felga 46",		 price= 6700 },
    { name="Felga 47",			 price= 9000 },
    { name="Felga 48",		 price=15800 },
    { name="Felga 49",			 price=12000 },
    { name="Felga 50",			 price=23000 },
    { name="Felga 51",		 price=26000 },
    { name="Felga 52",		 		 price=12000 },
    { name="Felga 53",	 price=42000 },
    { name="Felga 54",	 price=47000 },
    { name="Felga 55",		 price=47000 },
}

-- Сменные рамки номеров
local licesneFrames = {
    { name="fifteen52",              price=10000 },
    { name="M Performance",          price=10000 },
    { name="tourerV",             price=10000 },
    { name="Slow 'n Low",              price=10000 },
    { name="RedBull 1", price=10000 },
    { name="RedBull 2",              price=10000 },
    { name="AMG",                    price=10000 },
    { name="Made in Japan",        price=10000 },
    { name="GOLD",                price=10000 },
    { name="M-Powe",               price=10000 },
    { name="MightyCarMods",                    price=10000 },
    { name="RDS",                    price=10000 },
    { name="I <3 My Subaru",        price=10000 },
    { name="Stance Nation",          price=10000 },
    { name="Vossen",                 price=10000 },
    { name="YOKOHAMA",          price=10000 },
    { name="Loud Sound",             price=10000 },
    { name="Ralli ART",              price=10000 },
    { name="Illskil",                price=10000 },
    { name="[HOONIGAN]",             price=10000 },
    { name="Domo Kun",               price=10000 },
    { name="Keep Drifting Fun",      price=10000 },
    { name="Nismo",                  price=10000 },
    { name="GReddy Brembo",                 price=10000 },
    { name="Toyo Tires",             price=10000 },
    { name="#stilovdaily",           price=10000 },
    { name="SPEED HUNTERS",                  price=10000 },
    --[[{ name="Made in Japan 1",       price=10000 },
    { name="Brazzers",               price=10000 },
    { name="Yokohama",               price=10000 },
    { name="Удачный бодрый сток",    price=10000 },
    { name="Dikobrazzers",           price=10000 },
    { name="Одержимые",              price=10000 },
    { name="Fail Crew",              price=10000 },
    { name="Domo Kun #2",            price=10000 },
    { name="Янiщий",                 price=10000 },
    { name="Doge",                   price=10000 },
    { name="VOLK Racing Wheel",      price=10000 },
    { name="Boost Charging",		 price=10000 },
    { name="Внеземные цивилизации",	 price=10000 },
    { name="HKS",					 price=10000 },
    { name="Учился ездить в GTA",	 price=10000 },
    { name="Haters Gonna Hate",		 price=10000 },
    { name="Жру Сплю ЖДМ",			 price=10000 },
    { name="Hello Kitty",			 price=10000 },
    { name="I love my Subaru",		 price=10000 },
    { name="Low & Slow",			 price=10000 },
    { name="Low'n'Slow",			 price=10000 },
    { name="Made In Japan 2",		 price=10000 },
    { name="Made In Japan 3",		 price=10000 },
    { name="Made In Japan 4",		 price=10000 },
    { name="MILF Hunters",			 price=10000 },
    { name="Monster Energy",		 price=10000 },
    { name="Red Bull 1",			 price=10000 },
    { name="Red Bull 2",			 price=10000 },
    { name="SpeedHunters",			 price=10000 },
    { name="StolbHunters",			 price=10000 },
    { name="Быстро, дорого, не продаю", price=10000 },
    { name="Не буди Даниэля",		 price=10000 },--]]
}

local kitComponents = {}

for model, components in pairs(ComponentsTable) do
    if components.kit then
        kitComponents[model] = {}
        for name, list in pairs(components) do
            for id, component in pairs(list) do
                for kitId in pairs(components.kit) do
                    if component.kit and component.kit[kitId] then
                        if not kitComponents[model][kitId] then
                            kitComponents[model][kitId] = {}
                        end
                        kitComponents[model][kitId][name] = id
                    end
                end
            end
        end
    end
end

local function getStockComponent()
    return { name = "Stock", price = 0 }
end

function getComponentsTable(model)
    if type(model) ~= "number" then
        return
    end
    local components = table.copy(ComponentsTable[model])
    if not components then
        components = {}
    end

    -- Спойлеры
    if not components.spoiler then
        components.spoiler = {}
    end
    -- Сначала идут стандартные спойлеры
    local spoilersTable = table.copy(defaultSpoilers)
    -- Далее идут спойлеры автомобиля
    if components.spoiler then
        for i = 1, table.maxn(components.spoiler) do
            table.insert(spoilersTable, components.spoiler[i])
        end
        -- Добавить стоковый спойлер
        spoilersTable[0] = components.spoiler[0]
    end
    if not spoilersTable[0] then
        spoilersTable[0] = getStockComponent()
    end
    components.spoiler = spoilersTable

    -- Колёса
    components.wheels = table.copy(defaultWheels)
    components.wheels[0] = getStockComponent()

    if isResourceRunning("car_components") then
        -- Сменные рамки номеров
        components.licence_frame = table.copy(licesneFrames)
        components.licence_frame[0] = getStockComponent()

        -- Ксенон
        components.xenon = exports["car_components"]:getXenonColors()
        components.xenon[0] = getStockComponent()
    end
    return components
end

function getComponentInfo(model, component, id)
    if not model or not component or not id then
        return
    end
    local components = getComponentsTable(model)
    if not components or not components[component] or not components[component][id] then
        return
    end

    return components[component][id]
end

-- Получает номер компонента в ките
function getKitComponentId(model, kit, name)
    if kitComponents[model] and kitComponents[model][kit] and kitComponents[model][kit][name] then
        local id = kitComponents[model][kit][name]
        -- Для спойлеров в таблице не учитываются стандартные спойлеры, поэтому id нужно смещать
        if name == "spoiler" then
            id = id + #defaultSpoilers
        end
        return id
    end
end
