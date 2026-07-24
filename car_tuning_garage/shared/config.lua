Config = {}

Config.tuningGarageModel = 1909

-- Расположение объекта гаража
Config.tuningGaragePosition = Vector3(0, 0, 100)

-- Команда для входа в тюнинг из любого места
Config.debugEnableTuningCommand = false
Config.debugTuningCommand = "tuning"
Config.debugMessagesEnabled = false

-- Положение автомобиля в тюнинге
Config.tuningVehiclePosition = Config.tuningGaragePosition + Vector3(-4.45, -0.35, -1)
Config.tuningVehicleRotation = Vector3(0, 0, 0)
Config.tuningInterior = 1

-- Автомобили, для которых запрещён тюнинг
Config.disabledVehicleModels = {
    [499] = true,
    [437] = true,
    [431] = true,
    [515] = true,
    [403] = true,
    [414] = true,
}
-- -2053.1420898438,169.81932067871,29.559148788452


-- -1937.5010986328,236.23593139648,33.745574951172
-- Входы в тюнинг
Config.tuningMarkers = {
    -- TransFender
    { position = Vector3(2386.658, 1054.361, 9.453),     angle = 0 },
    -- Wheel Arch Angles
    { position = Vector3(-2723.706, 217.268, 4.613),     angle = 90 },
    -- Loco Low Co.
    { position = Vector3(1990.689, 2056.804, 10.384),    angle = 0 },
    -- TransFender
    { position = Vector3(2499.615, -1779.813, 12.8),     angle = 90 },
    -- TransFender Los Santos
    { position = Vector3(2644.898, -2043.392, 12.6),     angle = 180 },
    -- DOHERTY 1
    { position = Vector3(-2053.3420898438,170.11932067871,30.109148788452),    angle = 80 }, -- -2052.1364746094,163.71585083008,28.3625831604
	{ position = Vector3(-2052.1364746094,163.71585083008,28.9625831604),    angle = 1 },
    -- TransFender Los Santos
    { position = Vector3(1041.960 , -1013.734 , 32.097), angle = 0 },
}

Config.tuningMarkerRadius = 3.5
Config.tuningMarkerBlip = 27
Config.tuningMarkerColor = {255, 255, 255, 100}

-- Ограничения настрек колёс
Config.wheelPropertiesLimits = {
    offset = {-0.06, 0.22},
    razval = {0, 30},
    radius = {0.7, 1.3},
    width  = {0.8, 1.6},
}

Config.wheelPropertiesPrices = {
    wheels_offset_f = 10000,
    wheels_offset_r = 10000,

    wheels_razval_f = 10000,
    wheels_razval_r = 10000,

    wheels_radius = 10000,

    wheels_width_f = 10000,
    wheels_width_r = 10000,
}

Config.wheelProperties = {
    "wheels_offset_f",
    "wheels_offset_r",
    "wheels_razval_f",
    "wheels_razval_r",
    "wheels_radius",
    "wheels_width_f",
    "wheels_width_r",
}
