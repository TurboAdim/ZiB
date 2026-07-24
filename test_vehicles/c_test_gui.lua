

local screenW, screenH = guiGetScreenSize()

local windowW, windowH = 800, 600
local windowX, windowY = (screenW - windowW) / 2, (screenH - windowH) / 2
local window = guiCreateWindow(windowX, windowY, windowW, windowH, "ZMIENNY23 - CAR PASS", false)

local selectedVehicleLabel1 = guiCreateLabel(650, 40, 760, 30, "Kategoria", false, window)
--guiLabelSetHorizontalAlign(label, "center")

-- Informacja o wybranym pojeździe
local selectedVehicleLabel2 = guiCreateLabel(50, 100, 500, 60, "Wybrany Pojazd:\nBrak", false, window)

-- Czcionka
local font = guiCreateFont("Borscha-Regular.ttf", 16)
if font then
    guiSetFont(selectedVehicleLabel1, font)
	guiSetFont(selectedVehicleLabel2, font)
	--[[guiSetFont(alfaButton, font)
	guiSetFont(betaButton, font)
	guiSetFont(destroyButton, font)--]]
end

-- Przyciski kategorii po prawej stronie
local realCars = guiCreateButton(620, 80, 150, 30, "Real Cars", false, window)
local driftCars = guiCreateButton(620, 130, 150, 30, "Drift/JDM Cars", false, window)
local motoCars = guiCreateButton(620, 180, 150, 30, "Motocykle", false, window)
local emergencyCars = guiCreateButton(620, 230, 150, 30, "Emergency Cars", false, window)
local miscfunnyCars = guiCreateButton(620, 280, 150, 30, "Misc & Funny Cars", false, window)
local lorefriendlyCars = guiCreateButton(620, 330, 150, 30, "Lore Friendly Cars", false, window)
local industrialCars = guiCreateButton(620, 380, 150, 30, "Industrial Cars", false, window)



local destroyButton = guiCreateButton(620,520,150,50, "Delete / Usuń", false, window)

-- Gridlista pojazdów
local vehicleList = guiCreateGridList(50, 160, 500, 300, false, window)
guiGridListAddColumn(vehicleList, "NAZWA POJAZDU", 0.9)

local spawnButton = guiCreateButton(50, 480, 500, 50, "SPAWN", false, window)

guiSetVisible(window, false)

-- Kategorie pojazdów
local vehicleCategories = {
    real = {
		{name = "►►► Alfa Romeo ◄◄◄", id = 602},
		{name = "(Real Cars) Alfa Romeo Giulia GTA '75", id = 60026},
		{name = "", id = 602},
		{name = "►►► Aston Martin ◄◄◄", id = 602},
		{name = "(Real Cars) Aston Martin V8", id = 60024},
		{name = "(Real Cars) Aston Martin DB5", id = 60121},
		{name = "(Real Cars) Aston Martin DB9 LQ", id = 60028},
		{name = "(Real Cars) Aston Martin DBS Superleggera LQ", id = 60249},
		{name = "(Real Cars) Aston Martin Vantage AMR '19 LQ", id = 60251},
		{name = "", id = 602},
		{name = "►►► Audi ◄◄◄", id = 602},
		{name = "(Real Cars) Audi R8 '08", id = 60031},
		{name = "(Real Cars) Audi S5 '14", id = 60124},
		{name = "(Real Cars) Audi RS4 Sedan '09", id = 60033},
		--{name = "(Real Cars) Audi RS4 Touring '14", id = 60149},
		{name = "(Real Cars) Audi TT '10", id = 60125},
		{name = "", id = 602},
		{name = "►►► Bentley ◄◄◄", id = 602},
		{name = "(Real Cars) Bentley Bentayga LQ", id = 60017},
		{name = "", id = 602},
		{name = "►►► Bugatti ◄◄◄", id = 602},
		{name = "(Real Cars) Bugatti Divo", id = 60274},
		{name = "(Real Cars) Bugatti EB110 LQ", id = 60022},
		{name = "(Real Cars) Bugatti Veyron 16.4", id = 60045},
		{name = "", id = 602},
		{name = "►►► BMW ◄◄◄", id = 602},
		{name = "(Real Cars) BMW E24 6-Series", id = 60034},
		{name = "(Real Cars) BMW E30 325i Sedan", id = 60053},
		{name = "(Real Cars) BMW E30 325i Avant", id = 60054},
		{name = "(Real Cars) BMW E30 M3", id = 60055},
		{name = "(Real Cars) BMW E36 318i Avant", id = 60049},
		{name = "(Real Cars) BMW E36 320i Sedan", id = 60047},
		{name = "(Real Cars) BMW E36 325i Coupe", id = 60051},
		{name = "(Real Cars) BMW E36 325i Cabrio", id = 60052},
		{name = "(Real Cars) BMW E39 5-Series", id = 60021},
		{name = "(Real Cars) BMW E46 320i Coupe", id = 60057},
		{name = "(Real Cars) BMW E46 320d Sedan", id = 60058},
		{name = "(Real Cars) BMW E46 FAKE-3 OffRoad", id = 60158},
		{name = "(Real Cars) BMW E52 Z8", id = 60085},
		{name = "(Real Cars) BMW E60 M5", id = 60171},
		{name = "(Real Cars) BMW E63 645Ci", id = 60056},
		{name = "(Real Cars) BMW F90 5-Series", id = 60015},
		{name = "", id = 602},
		{name = "►►► Cadillac ◄◄◄", id = 602},
		{name = "(Real Cars) Cadillac DTS '06", id = 60215},
		{name = "(Real Cars) Cadillac Fleetwood Brougham '84", id = 60141},
		{name = "", id = 602},
		{name = "►►► Chevrolet ◄◄◄", id = 602},
		{name = "(Real Cars) Chevrolet Camaro MK5 '10", id = 60162},
		{name = "(Real Cars) Chevrolet Camaro MK5 Convertible '10", id = 60163},
		{name = "(Real Cars) Chevrolet Camaro ZL1 MK5", id = 60128},
		--{name = "(Real Cars) Chevrolet Caprice '85", id = 60168},
		{name = "(Real Cars) Chevrolet Caprice Wagon '84", id = 60164},
		{name = "(Real Cars) Chevrolet Caprice Wagon '94", id = 60165},
		--{name = "(Real Cars) Chevrolet Silverado C10", id = 60159},
		{name = "(Real Cars) Chevrolet Cheyenne C/K '73", id = 60023},
		--{name = "(Real Cars) Chevrolet Corvette C4", id = 60089},
		{name = "(Real Cars) Chevrolet Corvette C5", id = 60188},
		{name = "(Real Cars) Chevrolet Corvette C6 ZR1", id = 60252},
		{name = "(Real Cars) Chevrolet Impala '87", id = 60228},
		{name = "(Real Cars) Chevrolet Impala '15", id = 60018},
		{name = "(Real Cars) Chevrolet Monte Carlo '71", id = 60184},
		{name = "(Real Cars) Chevrolet Monte Carlo '89", id = 60185},
		{name = "(Real Cars) Chevrolet Nomad", id = 60183},
		{name = "(Real Cars) Chevrolet Silverado C20", id = 60161},
		{name = "(Real Cars) Chevrolet Silverado 1500 '80", id = 60169},
		{name = "(Real Cars) Chevrolet Silverado 2500 '21 LQ", id = 60097},
		{name = "(Real Cars) Chevrolet Suburban GMT900 LQ", id = 60275},
		{name = "(Real Cars) Chevrolet Tahoe '99", id = 60016},
		{name = "", id = 602},
		{name = "►►► Dodge ◄◄◄", id = 602},
		{name = "(Real Cars) Dodge Challenger R/T '70", id = 60255},
		{name = "(Real Cars) Dodge Challenger SRT8 '08 LQ", id = 60027},
		{name = "(Real Cars) Dodge Charger SE '18 LQ", id = 60150},
		{name = "(Real Cars) Dodge Charger Daytona '70", id = 60177},
		{name = "(Real Cars) Dodge Coronet SuperBee", id = 60122},
		{name = "(Real Cars) Dodge Journey SXT '14 LQ", id = 60099},
		{name = "(Real Cars) Dodge RAM SANDKING LQ", id = 60151},
		{name = "(Real Cars) Dodge Viper '08", id = 60041},
		{name = "(Real Cars) Dodge Stealth R/T '96", id = 60088},
		{name = "(Real Cars) RAM 1500 LARAMIE '15", id = 60238},
		{name = "", id = 602},
		{name = "►►► DMC ◄◄◄", id = 602},
		{name = "(Real Cars) DeLorean DMC-12", id = 60265},
		{name = "", id = 602},
		{name = "►►► Ferrari ◄◄◄", id = 602},
		{name = "(Real Cars) Ferrari 288 GTO", id = 60032},
		{name = "(Real Cars) Ferrari 458 Italia", id = 60109},
		{name = "(Real Cars) Ferrari F12 Berlinetta", id = 60260},
		{name = "(Real Cars) Ferrari F430", id = 60235},
		{name = "(Real Cars) Ferrari Daytona", id = 60038},
		{name = "(Real Cars) Ferrari FXX K LQ", id = 60152},
		{name = "", id = 602},
		{name = "►►► Ford ◄◄◄", id = 602},
		{name = "(Real Cars) Ford Bronco XLT '96", id = 60117},
		{name = "(Real Cars) Ford Crown Victoria", id = 60035},
		{name = "(Real Cars) Ford Crown Victoria TAXI", id = 60036},
		{name = "(Real Cars) Ford Explorer '11", id = 60254},
		{name = "(Real Cars) Ford Explorer '17", id = 60271},
		{name = "(Real Cars) Ford F-150 CREWCAB '15 LQ", id = 60233},
		{name = "(Real Cars) Ford F-150 Raptor '19 LQ", id = 60153},
		{name = "(Real Cars) Ford GT '05", id = 60037},
		{name = "(Real Cars) Ford Mustang GT '99", id = 60006},
		{name = "(Real Cars) Ford Mustang '65", id = 60142},
		{name = "(Real Cars) Ford Mustang Dark Horse '24", id = 60008},
		{name = "(Real Cars) Ford Mustang Mach1 '69", id = 60040},
		{name = "(Real Cars) Ford Mustang F-250 '24", id = 60010},
		{name = "(Real Cars) Shelby Mustang GT500 '09", id = 60239},
		{name = "(Real Cars) Ford Sierra RS500", id = 60253},
		{name = "(Real Cars) Ford Ranger Raptor", id = 60263},
		{name = "", id = 602},
		{name = "►►► Honda ◄◄◄", id = 602},
		{name = "(Real Cars) Honda Civic III 3D", id = 60029},
		{name = "(Real Cars) Honda Civic Si '08", id = 60144},
		{name = "(Real Cars) Honda Civic Si '99", id = 60262},
		{name = "", id = 602},
		{name = "►►► Hummer ◄◄◄", id = 602},
		{name = "(Real Cars) Hummer H2", id = 60236},
		{name = "", id = 602},
		{name = "►►► Infiniti ◄◄◄", id = 602},
		{name = "(Real Cars) Infiniti G35", id = 60143},
		{name = "", id = 602},
		{name = "►►► Jeep ◄◄◄", id = 602},
		{name = "(Real Cars) Jeep Grand Cherokee '98", id = 60269},
		{name = "(Real Cars) Jeep Wrangler TJ '97 A", id = 60070},
		{name = "(Real Cars) Jeep Wrangler TJ '97 A JurassicP.", id = 60081},
		{name = "(Real Cars) Jeep Wrangler TJ '97 B", id = 60071},
		{name = "(Real Cars) Jeep Wrangler TJ '97 C", id = 60080},
		{name = "", id = 602},
		{name = "►►► Lamborghini ◄◄◄", id = 602},
		{name = "(Real Cars) Lamborghini Aventador SVJ", id = 60257},
		{name = "(Real Cars) Lamborghini Asterion LP910-4", id = 60258},
		{name = "(Real Cars) Lamborghini Centenario", id = 60273},
		{name = "(Real Cars) Lamborghini Gallardo LP640-4", id = 60127},
		{name = "(Real Cars) Lamborghini Murcielago LQ", id = 60101},
		{name = "", id = 602},
		--{name = "►►► Lancia ◄◄◄", id = 602},
		--{name = "(Real Cars) Lancia 037", id = 60043},
		{name = "", id = 602},
		{name = "►►► Land Rover ◄◄◄", id = 602},
		{name = "(Real Cars) Land Rover Discovery 2", id = 60115},
		{name = "(Real Cars) Land Rover Discovery 3", id = 60114},
		{name = "(Real Cars) Land Rover Range Rover", id = 60116},
		{name = "", id = 602},
		{name = "►►► Lincoln ◄◄◄", id = 602},
		{name = "(Real Cars) Lincoln Continental '20 Sedan", id = 60277},
		{name = "", id = 602},
		{name = "►►► McLaren ◄◄◄", id = 602},
		{name = "(Real Cars) McLaren 600LT LQ", id = 60154},
		{name = "(Real Cars) McLaren Senna LQ", id = 60155},
		{name = "", id = 602},
		{name = "►►► Mercedes-Benz ◄◄◄", id = 602},
		{name = "(Real Cars) Mercedes-Benz 300SEL", id = 60039},
		{name = "(Real Cars) Mercedes-Benz 300SL Gulwing", id = 60267},
		{name = "(Real Cars) Mercedes-Benz 560SEL", id = 60046},
		{name = "(Real Cars) Mercedes-Benz CLK GTR", id = 60119},
		{name = "(Real Cars) Mercedes-Benz E55 AMG W211", id = 60113},
		{name = "(Real Cars) Mercedes-Benz E63 AMG W212", id = 60264},
		{name = "(Real Cars) Mercedes-Benz S500 W140", id = 60256},
		{name = "(Real Cars) Mercedes-Benz SL R129", id = 60110},
		{name = "(Real Cars) Mercedes-Benz SL 65 AMG", id = 60234},
		{name = "(Real Cars) Mercedes-Benz SLK 350", id = 60111},
		{name = "(Real Cars) Mercedes-Benz SLS AMG '10", id = 60108},
		{name = "(Real Cars) Mercedes-Benz SLS AMG Black Series '14", id = 60246},
		{name = "(Real Cars) Mercedes-McLaren SLR", id = 60134},
		{name = "", id = 602},
		{name = "►►► MINI ◄◄◄", id = 602},
		{name = "(Real Cars) MINI Cooper S '15 LQ", id = 60098},
		{name = "(Real Cars) MINI Cooper S '65", id = 60261},
		{name = "", id = 602},
		{name = "►►► Mitsubishi ◄◄◄", id = 602},
		{name = "(Real Cars) Mitsubishi Lancer EVO VI", id = 60268},
		{name = "", id = 602},
		{name = "►►► Morgan ◄◄◄", id = 602},
		{name = "(Real Cars) Morgan Aero SS LQ", id = 60250},
		{name = "", id = 602},
		{name = "►►► Nissan ◄◄◄", id = 602},
		{name = "(Real Cars) Nissan Skyline GT-R32", id = 60135},
		{name = "(Real Cars) Nissan GT-R35 Concept", id = 60112},
		{name = "(Real Cars) Nissan GT-R35 '14", id = 60266},
		{name = "(Real Cars) Nissan GT-R35 NISMO '17", id = 60237},
		{name = "(Real Cars) Nissan Skyline GT-R34 Z-Tune", id = 60247},
		{name = "(Real Cars) Nissan Patrol '05", id = 60138},
		{name = "", id = 602},
		{name = "►►► Pagani ◄◄◄", id = 602},
		{name = "(Real Cars) Pagani Huayra", id = 60248},
		{name = "(Real Cars) Pagani Zonda", id = 60118},
		{name = "", id = 602},
		{name = "►►► Pontiac ◄◄◄", id = 602},
		{name = "(Real Cars) Pontiac GTO '69", id = 60025},
		{name = "", id = 602},
		{name = "►►► Porsche ◄◄◄", id = 602},
		{name = "(Real Cars) Porsche 718 Cayman S", id = 60276},
		{name = "(Real Cars) Porsche 911 Carrera (964) LQ", id = 60156},
		{name = "(Real Cars) Porsche 911 (991) LQ", id = 60157},
		{name = "(Real Cars) Porsche 911 GT2 (996)", id = 60048},
		{name = "(Real Cars) Porsche 911 Turbo (996) LQ", id = 60072},
		{name = "(Real Cars) Porsche 918", id = 60105},
		{name = "", id = 602},
		{name = "►►► Renault ◄◄◄", id = 602},
		{name = "(Real Cars) Renault Megane 2 R.S.", id = 60123},
		{name = "", id = 602},
		{name = "►►► Rolls-Royce ◄◄◄", id = 602},
		{name = "(Real Cars) Rolls-Royce Wraith '14", id = 60259},
		{name = "", id = 602},
		{name = "►►► Seat ◄◄◄", id = 602},
		{name = "(Real Cars) Seat Leon Cupra R", id = 60104},
		{name = "", id = 602},
		{name = "►►► Subaru ◄◄◄", id = 602},
		{name = "(Real Cars) Subaru BRZ", id = 60050},
		{name = "(Real Cars) Subaru Impreza STi '08", id = 60270},
		{name = "", id = 602},
		{name = "►►► Toyota ◄◄◄", id = 602},
		{name = "(Real Cars) Toyota Camry V30", id = 60019},
		{name = "(Real Cars) Toyota Camry XLE LQ", id = 60145},
		{name = "(Real Cars) Toyota Highlander '15 LQ", id = 60096},
		{name = "(Real Cars) Toyota Supra MK5 LQ", id = 60146},
		{name = "", id = 602},
		{name = "►►► Volvo ◄◄◄", id = 602},
		{name = "(Real Cars) Volvo 850 LQ", id = 60147},
		{name = "(Real Cars) Volvo S40 LQ", id = 60100},
		{name = "(Real Cars) Volvo XC70 LQ", id = 60059},
		{name = "", id = 602},
		{name = "►►► Volkswagen ◄◄◄", id = 602},
		{name = "(Real Cars) VW Corrado", id = 60103},
		{name = "(Real Cars) VW Golf MK4", id = 60133},
		{name = "(Real Cars) VW Golf MK5 GTI", id = 60030},
		{name = "(Real Cars) VW Passat B5", id = 60102},
		{name = "(Real Cars) VW Scirocco '88", id = 60042},
    },

    drift = {
        {name = "►►► BMW ◄◄◄", id = 602},
		--{name = "(Drift/JDM Cars) BMW E34 5-Series Drift", id = 60172},
		{name = "(Drift/JDM Cars) BMW E34 5-Series Drift", id = 60173},
		{name = "", id = 602},
		{name = "►►► Chevrolet ◄◄◄", id = 602},
		{name = "(Drift/JDM Cars) Chevrolet C10", id = 60160},
		{name = "(Drift/JDM Cars) Chevrolet Camaro MK5 Drift", id = 60167},
		{name = "", id = 602},
		{name = "►►► Dodge ◄◄◄", id = 602},
		{name = "(Drift/JDM Cars) Dodge Charger SharkWide '69", id = 60178},
		{name = "(Drift/JDM Cars) Dodge Viper MOPAR", id = 60182},
		{name = "", id = 602},
		{name = "►►► Ford ◄◄◄", id = 602},
		{name = "(Drift/JDM Cars) Ford Mustang GT Falken Tire '05", id = 60007},
		{name = "", id = 602},
		{name = "►►► Lexus ◄◄◄", id = 602},
		{name = "(Drift/JDM Cars) Lexus IS300 Drift Monster", id = 60174},
		{name = "", id = 602},
		{name = "►►► Mazda ◄◄◄", id = 602},
		{name = "(Drift/JDM Cars) Mazda RX-7 DriftKing", id = 60175},
		{name = "(Drift/JDM Cars) Mazda RX-7 FD3S", id = 60181},
		{name = "(Drift/JDM Cars) Mazda RX-7 FD3S", id = 60189},
		{name = "", id = 602},
		{name = "►►► Nissan ◄◄◄", id = 602},
		{name = "(Drift/JDM Cars) Nissan 180SX Potenza", id = 60044},
		{name = "(Drift/JDM Cars) Nissan 240SX", id = 60179},
		{name = "(Drift/JDM Cars) Nissan 300ZX", id = 60139},
		{name = "(Drift/JDM Cars) Nissan 300ZX Drift", id = 60176},
		{name = "(Drift/JDM Cars) Nissan Silvia S14", id = 60140},
		{name = "(Drift/JDM Cars) Nissan Silvia S14 Jardine JE", id = 60137},
		{name = "(Drift/JDM Cars) Nissan Silvia S15 C-West", id = 60107},
		{name = "(Drift/JDM Cars) Nissan Silvia S15 R CTS", id = 60136},
		{name = "(Drift/JDM Cars) Nissan Skyline GT-R35 Drift", id = 60148},
		{name = "(Drift/JDM Cars) Nissan Stagea 25RS Four S", id = 60131},
		{name = "(Drift/JDM Cars) Nissan Stagea GT-R34", id = 60130},
		{name = "(Drift/JDM Cars) Nissan Stagea GT-R35", id = 60132},
		{name = "", id = 602},
		{name = "►►► Pontiac ◄◄◄", id = 602},
		{name = "(Drift/JDM Cars) Pontiac Solstice GXP", id = 60180},
		{name = "", id = 602},
		{name = "►►► Subaru ◄◄◄", id = 602},
		{name = "(Drift/JDM Cars) Subaru Impreza WRX STi '05 LQ", id = 60020},
		{name = "(Drift/JDM Cars) Subaru Impreza 22b", id = 60120},
		{name = "", id = 602},
		{name = "►►► Toyota ◄◄◄", id = 602},
		{name = "(Drift/JDM Cars) Toyota Trueno AE86", id = 60129},
    },
	moto = {
		{name = "(Motocykle) Sanchez", id = 80005},
    },
	
	emergency = {
		{name = "►►► Police Department ◄◄◄", id = 602},
		{name = "/psapd - cmd", id = 602},
		{name = "", id = 602},
		{name = "►►► San Andreas Road Assistance ◄◄◄", id = 602},
		{name = "/psara - cmd", id = 602},
		{name = "", id = 602},
		{name = "►►► Fire Department ◄◄◄", id = 602},
		{name = "/psafd - cmd", id = 602},
		{name = "", id = 602},
		
		--[[{name = "►►► Lore & Other Police Cars ◄◄◄", id = 602},
		{name = "(Emergency) Police 1 LSPD", id = 596},
		{name = "(Emergency) Police 2 SFPD", id = 597},
		{name = "(Emergency) Police 3 LVPD", id = 598},
		{name = "(Emergency) Police 4 Rancher", id = 599},
		{name = "(Emergency) FBI Rancher", id = 490},
		{name = "(Emergency) Panto Police", id = 60061},
		{name = "(Emergency) Chevrolet Monte Carlo '71 Unmarked", id = 60186},
		{name = "(Emergency) Chevrolet Monte Carlo '71 Marked", id = 60187},
		{name = "(Emergency) Dodge Charger Police Interceptor '18", id = 60013},
		{name = "(Emergency) Dodge Charger '14", id = 60214},
		{name = "(Emergency) Dodge Charger Slicktop '08", id = 60215},
		{name = "(Emergency) Dodge Magnum '09 SFPD", id = 60209},
		--{name = "(Emergency) Dodge Viper Sheriff Police '10", id = 60240},
		{name = "(Emergency) Ford Crown Victoria Police Interceptor", id = 60011},
		{name = "(Emergency) Ford Crown Victoria Police Interceptor ver2", id = 60213},
		{name = "(Emergency) Ford Crown Victoria Police Interceptor ver4", id = 60224},
		{name = "(Emergency) Ford F-150 Police Interceptor", id = 60012},
		{name = "(Emergency) Ford Fusion Police Interceptor '18", id = 60014},
		{name = "(Emergency) Ford Shelby Mustang GT500 Police '09", id = 60227},
		{name = "(Emergency) Honda Integra Police '96", id = 60229},
		{name = "(Emergency) Lamborghini Huracan EVO '19 Police", id = 60211},
		{name = "(Emergency) Lamborghini Aventador Police", id = 60212},
		{name = "(Emergency) Pontiac FireBird Trans AM Police '79", id = 60219},
		{name = "(Emergency) Pontiac FireBird Trans AM Police '87", id = 60218},
		{name = "", id = 602},
		{name = "►►► JDM Police Cars ◄◄◄", id = 602},
		{name = "(Emergency) Infernus JDM Police '91", id = 60075},
		{name = "(Emergency) Nissan Skyline GT-R34 Police", id = 60196},
		{name = "(Emergency) Nissan Skyline GT-R35 Police", id = 60195},
		{name = "", id = 602},
		{name = "►►► NFS Most Wanted Cars ◄◄◄", id = 602},
		{name = "(Emergency) Chevrolet Corvette C6 Marked (NFSMW)", id = 60203},
		{name = "(Emergency) Chevrolet Corvette C6 Unmarked (NFSMW)", id = 60204},
		{name = "(Emergency) Pontiac GTO Marked Police (NFSMW)", id = 60201},
		{name = "(Emergency) Pontiac GTO Unmarked Police (NFSMW)", id = 60202},
		{name = "", id = 602},
		{name = "►►► SFPD Cars ◄◄◄", id = 602},
		{name = "(Emergency) Ford CVPI SFPD ver3", id = 60205},
		{name = "(Emergency) Ford Explorer SFPD", id = 60206},
		{name = "(Emergency) Dodge Charger '18 SFPD", id = 60207},
		{name = "(Emergency) Ford F-150 BombSquad SFPD", id = 60208},
		{name = "", id = 602},
		{name = "►►► Lore & Other Fire Cars ◄◄◄", id = 602},
		{name = "(Emergency) Chevrolet Caprice '87 Chicago Fire Dept.", id = 60221},
		{name = "(Emergency) Chevrolet Caprice '94 SA Fire Dept.", id = 60223},
		{name = "(Emergency) Chevrolet Suburban '02 SF Fire Dept. Wagon", id = 60222},
		{name = "(Emergency) Ford CVFI ARSON", id = 60217},
		{name = "(Emergency) Ford F4000 Fire", id = 60216},
		--{name = "(Emergency) Opel Astra G - Straż", id = 60220},--]]
    },
	
	miscfun = {
		{name = "(Misc&Funny) BUS", id = 431},
		{name = "(Misc&Funny) BUS Prison", id = 60090},
		{name = "(Misc&Funny) BUS School", id = 60091},
		{name = "(Misc&Funny) Bikini Bottom Boat", id = 60230},
		{name = "(Misc&Funny) Chevrolet Caprice Wagon Majestic Nomad", id = 60166},
		{name = "(Misc&Funny) Coach", id = 437},
		{name = "(Misc&Funny) Cabbie TURBO", id = 60106},
		{name = "(Misc&Funny) Guido", id = 60200},
		{name = "(Misc&Funny) Mower Dragster", id = 60190},
		{name = "(Misc&Funny) Mower Stroker", id = 60191},
		{name = "(Misc&Funny) Pigeon", id = 60079},
		{name = "(Misc&Funny) Ubermacht Goofy3 Touring", id = 60003},
    },
	
	lorefriendly = {
		{name = "(Lore Friendly) Alpha", id = 602},
		{name = "(Lore Friendly) Angra", id = 60064},
		{name = "(Lore Friendly) Argento", id = 60073},
		{name = "(Lore Friendly) Banshee No Roof", id = 60068},
		{name = "(Lore Friendly) Banshee", id = 60069},
		{name = "(Lore Friendly) Basilik S7", id = 60076},
		{name = "(Lore Friendly) Benson Exceller A", id = 60086},
		{name = "(Lore Friendly) Benson Exceller B", id = 60087},
		{name = "(Lore Friendly) Blista Compact '01", id = 60094},
		{name = "(Lore Friendly) Buffalo AC", id = 60004},
		{name = "(Lore Friendly) Buffalo B", id = 60077},
		{name = "(Lore Friendly) Bullet GT", id = 60092},
		{name = "(Lore Friendly) Bullet GT4 Long Tail '66", id = 60093},
		{name = "(Lore Friendly) Corsivo", id = 60062},
		{name = "(Lore Friendly) Comet A", id = 60272},
		{name = "(Lore Friendly) Cruiser Pickup A", id = 60082},
		{name = "(Lore Friendly) Cruiser Pickup B", id = 60083},
		{name = "(Lore Friendly) Cruiser Pickup C", id = 60084},
		{name = "(Lore Friendly) Elegant", id = 80006},
		{name = "(Lore Friendly) Idaho", id = 60005},
		{name = "(Lore Friendly) Infernus '91", id = 60074},
		{name = "(Lore Friendly) Itali HRG", id = 60063},
		--{name = "(Lore Friendly) Jackal '06", id = 60095},
		{name = "(Lore Friendly) Karin RR GTO", id = 60066},
		{name = "(Lore Friendly) Karin Shibuya", id = 60067},
		{name = "(Lore Friendly) Lampadati LC24", id = 60078},
		{name = "(Lore Friendly) Landstalker 1", id = 80002},
		{name = "(Lore Friendly) Landstalker 2", id = 80003},
		{name = "(Lore Friendly) Landstalker 3", id = 80004},
		{name = "(Lore Friendly) Panto", id = 60060},
		{name = "(Lore Friendly) Ubermacht G3 Coupe", id = 60000},
		{name = "(Lore Friendly) Ubermacht G3 Sedan", id = 60001},
		{name = "(Lore Friendly) Ubermacht G3 Touring", id = 60002},
		{name = "(Lore Friendly) Ubermacht Rebla", id = 60009},
		{name = "(Lore Friendly) Schafter", id = 80001},
		{name = "(Lore Friendly) Stinger Ferocious GT", id = 60065},
    },
	
	industrial = {
	    --{name = "(Industrial) Chevrolet Silverado DOT", id = 60232},
		{name = "(Industrial) Chevrolet Silverado C10 TowTruck", id = 525},
		{name = "(Industrial) Chevrolet Silverado 1500 Utility '80", id = 60170},
		{name = "(Industrial) Chevrolet Express TV", id = 60245},
		{name = "(Industrial) Dodge RAM 2500 '96 Twisters", id = 60241},
		{name = "(Industrial) Ford E150 '06 CNN", id = 60244},
		{name = "(Industrial) Ford F150 Utility '90", id = 60225},
		{name = "(Industrial) Ford F150 Utility CREWCAB '11", id = 60226},
		{name = "(Industrial) Ford F150 Utility CREWCAB '16", id = 60231},
		{name = "(Industrial) DFT 4x2", id = 60192},
		--{name = "(Industrial) GMC Sierra TowTruck", id = 60198},
		--{name = "(Industrial) Linerunner FX", id = 60246},
		{name = "(Industrial) NewsVan 7Channel", id = 60243},
		{name = "(Industrial) Stanier San News", id = 60242},
		--{name = "(Industrial) TowTruck 4x4", id = 60197},
		--{name = "(Industrial) TowTruck 6x6", id = 60200},
		{name = "(Industrial) Yankorcer", id = 60193},
		--{name = "(Industrial) Yosemite TowTruck", id = 60199},
    }
}

-- Aktualizacja gridlisty
local function loadVehicleCategory(category)
    guiGridListClear(vehicleList)

    for _, vehicle in ipairs(vehicleCategories[category]) do
        local row = guiGridListAddRow(vehicleList)

        guiGridListSetItemText(vehicleList, row, 1, vehicle.name, false, false)
        guiGridListSetItemData(vehicleList, row, 1, vehicle.id)
    end
end









-- Obsługa przycisków kategorii
addEventHandler("onClientGUIClick", realCars, function()
    loadVehicleCategory("real")
end, false)

addEventHandler("onClientGUIClick", driftCars, function()
    loadVehicleCategory("drift")
end, false)

addEventHandler("onClientGUIClick", motoCars, function()
    loadVehicleCategory("moto")
end, false)

addEventHandler("onClientGUIClick", emergencyCars, function()
    loadVehicleCategory("emergency")
end, false)

addEventHandler("onClientGUIClick", miscfunnyCars, function()
    loadVehicleCategory("miscfun")
end, false)

addEventHandler("onClientGUIClick", lorefriendlyCars, function()
    loadVehicleCategory("lorefriendly")
end, false)

addEventHandler("onClientGUIClick", industrialCars, function()
    loadVehicleCategory("industrial")
end, false)









addEventHandler("onClientGUIClick", destroyButton, function()
        triggerServerEvent(
            "newmodels-test_vehicles:destroyVehicle",
            resourceRoot
        )
    end, false)


















-- Aktualizacja napisu po wybraniu pojazdu
addEventHandler("onClientGUIClick", vehicleList, function()
    local selectedRow = guiGridListGetSelectedItem(vehicleList)

    if selectedRow ~= -1 then
        local vehicleName = guiGridListGetItemText(vehicleList, selectedRow, 1)

        guiSetText(selectedVehicleLabel2, "Wybrany Pojazd:\n" .. vehicleName)
    end
end, false)



local function spawnVehicleByID(vehicleID)
    if not vehicleID then
        outputChatBox("Error: Wpisz właściwe ID.", 255, 0, 0)
        return
    end

    local x, y, z = getElementPosition(localPlayer)
    local _, _
    rot = getElementRotation(localPlayer)
    local offsetDistance = 5
    local spawnX = x + offsetDistance * math.sin(math.rad(-rot))
    local spawnY = y + offsetDistance * math.cos(math.rad(-rot))
    triggerServerEvent("newmodels-test_vehicles:requestVehicleSpawn", resourceRoot, vehicleID, spawnX, spawnY, z, rot)
end

local function requestVehicleSpawn()
    local selectedRow = guiGridListGetSelectedItem(vehicleList)

    if selectedRow == -1 then
        outputChatBox("Error: Wybierz pojazd.", 255, 0, 0)
        return
    end

    local vehicleID = guiGridListGetItemData(vehicleList, selectedRow, 1)

    spawnVehicleByID(vehicleID)

    guiSetVisible(window, false)
    showCursor(false)
end

addEventHandler("onClientGUIClick", spawnButton, requestVehicleSpawn, false)



local function toggleSpawnerGUI()
    local visible = guiGetVisible(window)

    guiSetVisible(window, not visible)
    showCursor(not visible)

    if not visible then
        guiBringToFront(vehicleList)
    end
end

bindKey("F4", "down", toggleSpawnerGUI)
addCommandHandler("vspawner", toggleSpawnerGUI, false)

addCommandHandler("spawnveh", function(_, id)
    spawnVehicleByID(tonumber(id))
end, false)
