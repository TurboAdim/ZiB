----------------------------------------------------
-- GUI POLICJANTA
----------------------------------------------------

local screenW, screenH = guiGetScreenSize()

----------------------------------------------------
-- ZMIENNE
----------------------------------------------------

local policeWindow = nil
local driverLabel = nil

local checkCargoButton = nil
local checkTachoButton = nil
local closeButton = nil

local updateTimer = nil

----------------------------------------------------
-- TWORZENIE GUI
----------------------------------------------------

local function createPoliceGUI()

    if isElement(policeWindow) then
        return
    end

    ------------------------------------------------
    -- OKNO
    ------------------------------------------------

    policeWindow = guiCreateWindow(
        0.35,
        0.25,
        0.30,
        0.50,
        "Panel Policjanta",
        true
    )

    guiWindowSetSizable(
        policeWindow,
        false
    )

    guiSetVisible(
        policeWindow,
        false
    )

    ------------------------------------------------
    -- KONTROLOWANY KIEROWCA
    ------------------------------------------------

    local driverTitle = guiCreateLabel(
        0.08,
        0.10,
        0.84,
        0.08,
        "Kontrolowany Kierowca:",
        true,
        policeWindow
    )

    guiLabelSetHorizontalAlign(
        driverTitle,
        "center"
    )

    guiLabelSetVerticalAlign(
        driverTitle,
        "center"
    )

    ------------------------------------------------
    -- NICK KIEROWCY
    ------------------------------------------------

    driverLabel = guiCreateLabel(
        0.08,
        0.18,
        0.84,
        0.10,
        "Brak",
        true,
        policeWindow
    )

    guiLabelSetHorizontalAlign(
        driverLabel,
        "center"
    )

    guiLabelSetVerticalAlign(
        driverLabel,
        "center"
    )

    ------------------------------------------------
    -- PRZYCISK SPRAWDZENIA ŁADUNKU
    ------------------------------------------------

    checkCargoButton = guiCreateButton(
        0.10,
        0.35,
        0.80,
        0.12,
        "Sprawdź ładunek",
        true,
        policeWindow
    )

    ------------------------------------------------
    -- PRZYCISK SPRAWDZENIA TACHOGRAFU
    ------------------------------------------------

    checkTachoButton = guiCreateButton(
        0.10,
        0.50,
        0.80,
        0.12,
        "Sprawdź tachograf",
        true,
        policeWindow
    )

    ------------------------------------------------
    -- ZAMKNIJ
    ------------------------------------------------

    closeButton = guiCreateButton(
        0.10,
        0.75,
        0.80,
        0.12,
        "Zamknij",
        true,
        policeWindow
    )

end

----------------------------------------------------
-- AKTUALIZACJA KIEROWCY
----------------------------------------------------

local function updateControlledDriver()

    if not isElement(policeWindow) then
        return
    end

    if not guiGetVisible(policeWindow) then
        return
    end

    ------------------------------------------------
    -- POJAZD POLICJANTA
    ------------------------------------------------

    local vehicle =
        getPedOccupiedVehicle(
            localPlayer
        )

    if not vehicle then

        guiSetText(
            driverLabel,
            "Brak"
        )

        return

    end

    ------------------------------------------------
    -- KIEROWCA
    ------------------------------------------------

    local driver =
        getVehicleOccupant(
            vehicle,
            0
        )

    if not driver then

        guiSetText(
            driverLabel,
            "Brak"
        )

        return

    end

    ------------------------------------------------
    -- SPRAWDZENIE CZY TO GRACZ
    ------------------------------------------------

    if not isElement(driver)
        or getElementType(driver) ~= "player" then

        guiSetText(
            driverLabel,
            "Brak"
        )

        return

    end

    ------------------------------------------------
    -- WYŚWIETLENIE NICKU
    ------------------------------------------------

    guiSetText(
        driverLabel,
        getPlayerName(driver)
    )

end

----------------------------------------------------
-- OTWIERANIE GUI
----------------------------------------------------

local function openPoliceGUI()

    createPoliceGUI()

    ------------------------------------------------
    -- SPRAWDZENIE TEAMU
    ------------------------------------------------

    local policeTeam =
        getTeamFromName(
            "Policja"
        )

    if not policeTeam then

        outputChatBox(
            "Błąd: brak teamu Policja.",
            255,
            0,
            0
        )

        return

    end

    if getPlayerTeam(localPlayer)
        ~= policeTeam then

        outputChatBox(
            "Nie jesteś policjantem.",
            255,
            0,
            0
        )

        return

    end

    ------------------------------------------------
    -- OTWIERANIE
    ------------------------------------------------

    guiSetVisible(
        policeWindow,
        true
    )

    showCursor(true)

    ------------------------------------------------
    -- PIERWSZA AKTUALIZACJA
    ------------------------------------------------

    updateControlledDriver()

    ------------------------------------------------
    -- TIMER AKTUALIZACJI
    ------------------------------------------------

    if isTimer(updateTimer) then
        killTimer(updateTimer)
    end

    updateTimer =
        setTimer(
            updateControlledDriver,
            250,
            0
        )

end

----------------------------------------------------
-- ZAMYKANIE GUI
----------------------------------------------------

local function closePoliceGUI()

    if not isElement(policeWindow) then
        return
    end

    guiSetVisible(
        policeWindow,
        false
    )

    showCursor(false)

    ------------------------------------------------
    -- ZATRZYMANIE TIMERA
    ------------------------------------------------

    if isTimer(updateTimer) then
        killTimer(updateTimer)
    end

    updateTimer = nil

end

----------------------------------------------------
-- KOMENDA /PGUI
----------------------------------------------------

addCommandHandler(
    "pgui",
    function()

        createPoliceGUI()

        if guiGetVisible(policeWindow) then

            closePoliceGUI()

        else

            openPoliceGUI()

        end

    end
)

----------------------------------------------------
-- SPRAWDZANIE ŁADUNKU
----------------------------------------------------

addEventHandler(
    "onClientGUIClick",
    checkCargoButton,
    function()

        if source ~= checkCargoButton then
            return
        end

        triggerServerEvent(
            "police:checkCargo",
            localPlayer
        )

    end,
    false
)

----------------------------------------------------
-- SPRAWDZANIE TACHOGRAFU
----------------------------------------------------

addEventHandler(
    "onClientGUIClick",
    checkTachoButton,
    function()

        if source ~= checkTachoButton then
            return
        end

        triggerServerEvent(
            "police:checkTacho",
            localPlayer
        )

    end,
    false
)

----------------------------------------------------
-- ZAMKNIJ
----------------------------------------------------

addEventHandler(
    "onClientGUIClick",
    closeButton,
    function()

        if source ~= closeButton then
            return
        end

        closePoliceGUI()

    end,
    false
)

----------------------------------------------------
-- ESC - ZAMYKANIE GUI
----------------------------------------------------

addEventHandler(
    "onClientKey",
    root,
    function(button, press)

        if not press then
            return
        end

        if button ~= "escape" then
            return
        end

        if not isElement(policeWindow) then
            return
        end

        if not guiGetVisible(policeWindow) then
            return
        end

        closePoliceGUI()

    end
)