----------------------------------------------------
-- GUI POLICJANTA
-- zib_praca_ciezarowka
----------------------------------------------------

local policeWindow = nil
local driverLabel = nil

local checkCargoButton = nil
local checkTachoButton = nil
local closeButton = nil

local driverUpdateTimer = nil


----------------------------------------------------
-- CZCIONKI
----------------------------------------------------

local fontMain = guiCreateFont(
    "files/Borscha-Regular.ttf",
    16
)

local fontButton = guiCreateFont(
    "files/Borscha-Regular.ttf",
    12
)


----------------------------------------------------
-- TWORZENIE GUI
----------------------------------------------------

local function createPoliceGUI()

    if isElement(policeWindow) then
        return
    end


    ------------------------------------------------
    -- GŁÓWNE OKNO
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
    -- TYTUŁ KIEROWCY
    ------------------------------------------------

    local driverTitle = guiCreateLabel(
        0.6,
        0.10,
        0.84,
        0.08,
        "Kontrolowany Kierowca:",
        true,
        policeWindow
    )

    --[[guiLabelSetHorizontalAlign(
        driverTitle,
        "center"
    )

    guiLabelSetVerticalAlign(
        driverTitle,
        "center"
    )--]]

    ------------------------------------------------
    -- NICK KIEROWCY
    ------------------------------------------------

    driverLabel = guiCreateLabel(
        0.6,
        0.15,
        0.84,
        0.10,
        "Brak",
        true,
        policeWindow
    )

    --[[guiLabelSetHorizontalAlign(
        driverLabel,
        "center"
    )

    guiLabelSetVerticalAlign(
        driverLabel,
        "center"
    )--]]

    ------------------------------------------------
    -- SPRAWDŹ ŁADUNEK
    ------------------------------------------------

    checkCargoButton = guiCreateButton(
        0.10,
        0.36,
        0.17,
        0.06,
        "CARGO",
        true,
        policeWindow
    )

    ------------------------------------------------
    -- SPRAWDŹ TACHOGRAF
    ------------------------------------------------

    checkTachoButton = guiCreateButton(
        0.10,
        0.44,
        0.17,
        0.06,
        "TACHOGRAF",
        true,
        policeWindow
    )

    ------------------------------------------------
    -- ZAMKNIJ
    ------------------------------------------------

    closeButton = guiCreateButton(
        0.73,
        0.84,
        0.17,
        0.06,
        "Zamknij",
        true,
        policeWindow
    )


    ------------------------------------------------
    -- CZCIONKA GUI
    ------------------------------------------------

    guiSetFont(driverTitle, fontMain)
    guiSetFont(driverLabel, fontMain)
    guiSetFont(checkCargoButton, fontButton)
    guiSetFont(checkTachoButton, fontButton)
    guiSetFont(closeButton, fontButton)
	
end

----------------------------------------------------
-- SPRAWDZANIE KIEROWCY
----------------------------------------------------

local function updateControlledDriver()

    if not isElement(policeWindow) then
        return
    end

    if not guiGetVisible(policeWindow) then
        return
    end

    ------------------------------------------------
    -- SPRAWDZENIE POJAZDU POLICJANTA
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
    -- SPRAWDZENIE KIEROWCY
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
    -- CZY KIEROWCA JEST GRACZEM
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

    local playerName = getPlayerName(driver)

-- Usunięcie kodu koloru #RRGGBB
playerName = string.gsub(playerName,
    "^#[%x][%x][%x][%x][%x][%x]",
    "")

guiSetText(driverLabel, playerName)

guiLabelSetColor(
    driverLabel,
    255,
    255,
    255
)

end

----------------------------------------------------
-- SPRAWDZENIE TEAMU POLICJA
----------------------------------------------------

local function isPolice()

    local policeTeam =
        getTeamFromName(
            "Policja"
        )

    if not policeTeam then
        return false
    end

    if getPlayerTeam(localPlayer)
        ~= policeTeam then

        return false
    end

    return true

end

----------------------------------------------------
-- OTWARCIE GUI
----------------------------------------------------

local function openPoliceGUI()

    ------------------------------------------------
    -- SPRAWDZENIE TEAMU
    ------------------------------------------------

    if not isPolice() then

        outputChatBox(
            "Nie jesteś policjantem.",
            255,
            0,
            0
        )

        return

    end

    ------------------------------------------------
    -- UTWORZENIE GUI
    ------------------------------------------------

    createPoliceGUI()

    ------------------------------------------------
    -- OTWARCIE
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
    -- TIMER AKTUALIZACJI KIEROWCY
    ------------------------------------------------

    if isTimer(driverUpdateTimer) then
        killTimer(driverUpdateTimer)
    end

    driverUpdateTimer =
        setTimer(
            updateControlledDriver,
            250,
            0
        )

end

----------------------------------------------------
-- ZAMKNIĘCIE GUI
----------------------------------------------------

local function closePoliceGUI()

    if not isElement(policeWindow) then
        return
    end

    ------------------------------------------------
    -- UKRYCIE GUI
    ------------------------------------------------

    guiSetVisible(
        policeWindow,
        false
    )

    showCursor(false)

    ------------------------------------------------
    -- ZATRZYMANIE TIMERA
    ------------------------------------------------

    if isTimer(driverUpdateTimer) then
        killTimer(driverUpdateTimer)
    end

    driverUpdateTimer = nil

end

----------------------------------------------------
-- KOMENDA /PGUI
----------------------------------------------------

addCommandHandler(
    "pgui",
    function()

        ------------------------------------------------
        -- JEŚLI GUI JEST OTWARTE - ZAMKNIJ
        ------------------------------------------------

        if isElement(policeWindow)
            and guiGetVisible(policeWindow) then

            closePoliceGUI()

            return

        end

        ------------------------------------------------
        -- JEŚLI GUI JEST ZAMKNIĘTE - OTWÓRZ
        ------------------------------------------------

        openPoliceGUI()

    end
)

----------------------------------------------------
-- PRZYCISK SPRAWDŹ ŁADUNEK
----------------------------------------------------

addEventHandler(
    "onClientGUIClick",
    root,
    function()

        if source ~= checkCargoButton then
            return
        end

        ------------------------------------------------
        -- SPRAWDZENIE TEAMU
        ------------------------------------------------

        if not isPolice() then

            closePoliceGUI()

            outputChatBox(
                "Nie jesteś już policjantem.",
                255,
                0,
                0
            )

            return

        end

        ------------------------------------------------
        -- WYSŁANIE DO SERVERA
        ------------------------------------------------

        triggerServerEvent(
            "police:checkCargo",
            localPlayer
        )

    end
)

----------------------------------------------------
-- PRZYCISK SPRAWDŹ TACHOGRAF
----------------------------------------------------

addEventHandler(
    "onClientGUIClick",
    root,
    function()

        if source ~= checkTachoButton then
            return
        end

        ------------------------------------------------
        -- SPRAWDZENIE TEAMU
        ------------------------------------------------

        if not isPolice() then

            closePoliceGUI()

            outputChatBox(
                "Nie jesteś już policjantem.",
                255,
                0,
                0
            )

            return

        end

        ------------------------------------------------
        -- WYSŁANIE DO SERVERA
        ------------------------------------------------

        triggerServerEvent(
            "police:checkTacho",
            localPlayer
        )

    end
)

----------------------------------------------------
-- PRZYCISK ZAMKNIJ
----------------------------------------------------

addEventHandler(
    "onClientGUIClick",
    root,
    function()

        if source ~= closeButton then
            return
        end

        closePoliceGUI()

    end
)

----------------------------------------------------
-- ESC - ZAMKNIĘCIE GUI
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
