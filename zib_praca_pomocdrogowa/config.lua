Config = {}

----------------------------------------------------
-- MARKER
----------------------------------------------------

Config.Marker = {
    1658.64,2198.52,9.9
}

----------------------------------------------------
-- SPAWNY
----------------------------------------------------

Config.Spawns = {

    {1644.09,2190.46,11.03,0,0,90},
    {1627.55,2190.55,11.03,0,0,180}

}

----------------------------------------------------
-- POJAZDY
----------------------------------------------------

Config.Vehicles = {

    --[[{
        name = "Chevrolet Silverado DOT",
        model = 60232
    },--]]
	
	{
        name = "Chevrolet Silverado C10 Tow Truck",
        model = 525
    },
	
	{
        name = "Chevrolet Silverado 1500 Utility",
        model = 60170
    },
	
	{
        name = "Ford F150 '90 Utility",
        model = 60225
    },
	
	{
        name = "Ford F150 '11 DOT",
        model = 60226
    },
	
	{
        name = "Ford F150 '16 DOT",
        model = 60231
    },
	

}

----------------------------------------------------
-- SKINY
----------------------------------------------------

Config.Skins = {

    {
        name = "Skin 1",
        skin = 65
    },

    {
        name = "Skin 2",
        skin = 20004
    },
	
	{
        name = "Skin 3",
        skin = 20005
    },
	
	{
        name = "Skin 4",
        skin = 20006
    }

}

----------------------------------------------------
-- KOGUTY
----------------------------------------------------

Config.Strobes = {

    [525] = {

        colors = {
            {255,0,0},
			{255,255,0},
        },

        offsets = {

            {-0.5,-0.4,1.4},
            { 0.0,-0.4,1.4},
			{ 0.5,-0.4,1.4}

        }

    },

	
	-- Ford F150 DOT 2011
	[60226] = {

        colors = {
            --{255,0,0},
			{255,128,0},
        },

        offsets = {
		
            { 0.1, -1.2, 1.45 },
			{-0.1, -1.2, 1.45 },

        }

    },
	
	-- Ford F150 DOT 2016
	[60231] = {

        colors = {
            --{255,0,0},
			{255,128,0},
        },

        offsets = {
		
            {-0.1, -1, 1.55 },
			{ 0.1, -1, 1.55 },
			
			{ 0.35, 3.1, 0.3 },
			{-0.35, 3.1, 0.3 },
			
			{ 0.2, -2.95, 0.5 },
			{-0.2, -2.95, 0.5 },

        }

    },
	
	--[[ Chevrolet Silverado DOT
	[60232] = {

        colors = {
            --{255,0,0},
			{255,128,0},
        },

        offsets = {
		
            {-0.5, 0.4, 1.1 },
			{ 0.5, 0.4, 1.1 },
			
			{-0.3, 0.4, 1.1 },
			{ 0.3, 0.4, 1.1 },
			
			{ 0.5, -2.7, 1.3 },
			{-0.5, -2.7, 1.3 },
			
			{ 0.3, -2.7, 1.3 },
			{-0.3, -2.7, 1.3 },

        }

    },--]]

}

----------------------------------------------------
-- LOSOWE DRZEWA
----------------------------------------------------

Config.RandomTrees = {
    
	-- 2055.8767089844,1331.7080078125,10.831587791443
    {
        name = "[LV] Lotnisko LV",
        x = 2055.8,
        y = 1331.7,
        z = 10.8,

        rx = 90,
        ry = 0,
        rz = 25
    },
	
	
	-- 2110.6953125,1867.6236572266,10.673828125
    {
        name = "[LV] The Strip",
        x = 2110.5,
        y = 1867.52,
        z = 10.6,
        
        rx = 90,
        ry = 0,
        rz = 120
     },
	 
	 
	 -- 1783.2158203125,1183.2551269531,6.7419948577881
	 {
        name = "[LV] Las Venturas Airport FWay",
        x = 1783.2,
        y = 1183.2,
        z = 6.74,
        
        rx = 90,
        ry = 0,
        rz = 120
     },
	 
	 -- 1001.8786621094,1788.2479248047,10.8203125
	 {
        name = "[LV] Whitewood Estates",
        x = 1783.2,
        y = 1183.2,
        z = 6.74,
        
        rx = 90,
        ry = 0,
        rz = 120
     },
	 
	 -- 1784.1932373047,2609.9191894531,10.8203125
     {
        name = "[LV] Prickle Pine",
        x = 1784.2,
        y = 2609.9,
        z = 10.8,
        
        rx = 90,
        ry = 0,
        rz = 120
     },
	 
	 -- 2350.2724609375,2228.658203125,10.879667282104
	 {
        name = "[LV] Roca Escalante",
        x = 2350.3,
        y = 2228.6,
        z = 10.8,
        
        rx = 90,
        ry = 0,
        rz = 70
     },
	 
	 
	 
	 
	 
	 
	 
	 
	 
}

----------------------------------------------------
-- MODEL DRZEWA
----------------------------------------------------

Config.TreeModel = 615







Config.BatteryEvents = {
    
	
	--[[ Perennial
    {
        name = "The Stip",
		model = 404,
        x = 2119.81,
        y = 1899.11,
        z = 10.73,
        rot = 0
    },
	
	
	-- 2155.3361816406,1920.4808349609,10.671875
	-- Kosiarka Drag
    {
		name = "The Stip 2",
		model = 60190,
        x = 2155.3,
        y = 1920.4,
        z = 10.8,
        rot = 0
    },--]]
	
	-- 1605.8488769531,2141.466796875,11.332046508789
	-- Mercedes W211
    {
		name = "Bandits Stadion",
		model = 60113,
        x = 1605.8,
        y = 2141.4,
        z = 10.9,
        
		
		rx = -5,
		ry = 0,
		rz = 270
    },
	
	
	-- 2104.5869140625,2072.3493652344,10.252442359924
    {
		name = "[LV] The Strip, Redsands East",
		model = 60130,
        x = 2104.58,
        y = 2072.34,
        z = 10.55,
        
		
		rx = 0,
		ry = 0,
		rz = 90
    },
	
	-- 2124.7585449219,2357.3420410156,10.104513168335
	{
		name = "[LV] The Strip, Emerald Isle",
		model = 60112,
        x = 2124.75,
        y = 2357.34,
        z = 10.2,
        
		
		rx = 0,
		ry = 0,
		rz = 90
    },
	
	-- 2034.5905761719,1916.4020996094,11.610379219055
	{
		name = "[LV] The Strip, The Visage",
		model = 60148,
        x = 2034.59,
        y = 1916.4,
        z = 11.7,
        
		
		rx = 0,
		ry = 0,
		rz = 0
    },
	
	-- 2039.2751464844,1409.5134277344,10.103992462158
	{
		name = "[LV] The Strip, Pirates in Mens Pants",
		model = 60188,
        x = 2039.27,
        y = 1409.6,
        z = 10.1,
        
		
		rx = 0,
		ry = 0,
		rz = 0
    },
	
	-- 2040.1796875,1010.0619506836,10.103157043457
	{
		name = "[LV] The Strip, 4Dragons",
		model = 60143,
        x = 2040.2,
        y = 1010.0,
        z = 10.2,
        
		
		rx = 0,
		ry = 0,
		rz = 0
    },
	
	-- 1913.576171875,698.57281494141,10.261373519897
	{
		name = "[LV] Last Dime Motel",
		model = 60140,
        x = 1913.5,
        y = 698.5,
        z = 10.4,
        
		
		rx = 0,
		ry = 0,
		rz = 0
    },
	
	-- 1435.6522216797,792.56378173828,10.253615379333
	{
		name = "[LV] Backfield Chapel",
		model = 60120,
        x = 1435.65,
        y = 792.5,
        z = -170,
        
		
		rx = 0,
		ry = 0,
		rz = 0
    },
	
	-- 1695.0906982422,1305.9453125,10.251635551453
	{
		name = "[LV] Las Venturas Airport Parking",
		model = 60118,
        x = 1695.1,
        y = 1305.94,
        z = 10.35,
        
		
		rx = 0,
		ry = 0,
		rz = 180
    },
	
}

----------------------------------------------------
-- LAWETA
----------------------------------------------------

Config.TowTruckModels = {
    [525] = true -- Chevrolet Silverado C10 Tow Truck
}

Config.Towyard = {
    x = 1638.1281738281,
    y = 2193.1022949219,
    z = 10.9203125
}

Config.TowAttachOffset = {
    x = 0,
    y = -0.5,
    z = 1.1
}

Config.TowRewardMultiplier = 2.5



Config.VehicleValues = {

    [525] = 5000,

    [60000] = math.random(1000,2000),
    [60001] = math.random(1000,2000),
    [60002] = math.random(1000,2000),
    [60003] = math.random(1000,2000),
    [60004] = math.random(1000,2000),
    [60005] = math.random(1000,2000),
    [60006] = math.random(1000,2000),
    [60007] = math.random(1000,2000),
    [60008] = math.random(1000,2000),
    [60009] = math.random(1000,2000),
    
	[60010] = math.random(1000,2000),
    [60011] = math.random(1000,2000),
    [60012] = math.random(1000,2000),
	[60013] = math.random(1000,2000),
    [60014] = math.random(1000,2000),
    [60015] = math.random(1000,2000),
	[60016] = math.random(1000,2000),
    [60017] = math.random(1000,2000),
    [60018] = math.random(1000,2000),
	[60019] = math.random(1000,2000),
	
	[60020] = math.random(1000,2000),
    [60021] = math.random(1000,2000),
    [60022] = math.random(1000,2000),
    [60023] = math.random(1000,2000),
    [60024] = math.random(1000,2000),
    [60025] = math.random(1000,2000),
    [60026] = math.random(1000,2000),
    [60027] = math.random(1000,2000),
    [60028] = math.random(1000,2000),
    [60029] = math.random(1000,2000),
    
	[60030] = math.random(1000,2000),
    [60031] = math.random(1000,2000),
    [60032] = math.random(1000,2000),
	[60033] = math.random(1000,2000),
    [60034] = math.random(1000,2000),
    [60035] = math.random(1000,2000),
	[60036] = math.random(1000,2000),
    [60037] = math.random(1000,2000),
    [60038] = math.random(1000,2000),
	[60039] = math.random(1000,2000),
	
	[60040] = math.random(1000,2000),
    [60041] = math.random(1000,2000),
    [60042] = math.random(1000,2000),
    [60043] = math.random(1000,2000),
    [60044] = math.random(1000,2000),
    [60045] = math.random(1000,2000),
    [60046] = math.random(1000,2000),
    [60047] = math.random(1000,2000),
    [60048] = math.random(1000,2000),
    [60049] = math.random(1000,2000),
    
	[60050] = math.random(1000,2000),
    [60051] = math.random(1000,2000),
    [60052] = math.random(1000,2000),
	[60053] = math.random(1000,2000),
    [60054] = math.random(1000,2000),
    [60055] = math.random(1000,2000),
	[60056] = math.random(1000,2000),
    [60057] = math.random(1000,2000),
    [60058] = math.random(1000,2000),
	[60059] = math.random(1000,2000),
	
	[60060] = math.random(1000,2000),
    [60061] = math.random(1000,2000),
    [60062] = math.random(1000,2000),
    [60063] = math.random(1000,2000),
    [60064] = math.random(1000,2000),
    [60065] = math.random(1000,2000),
    [60066] = math.random(1000,2000),
    [60067] = math.random(1000,2000),
    [60068] = math.random(1000,2000),
    [60069] = math.random(1000,2000),
    
	[60070] = math.random(1000,2000),
    [60071] = math.random(1000,2000),
    [60072] = math.random(1000,2000),
	[60073] = math.random(1000,2000),
    [60074] = math.random(1000,2000),
    [60075] = math.random(1000,2000),
	[60076] = math.random(1000,2000),
    [60077] = math.random(1000,2000),
    [60078] = math.random(1000,2000),
	[60079] = math.random(1000,2000),
	
	[60080] = math.random(1000,2000),
    [60081] = math.random(1000,2000),
    [60082] = math.random(1000,2000),
	[60083] = math.random(1000,2000),
    [60084] = math.random(1000,2000),
    [60085] = math.random(1000,2000),
	[60086] = math.random(1000,2000),
    [60087] = math.random(1000,2000),
    [60088] = math.random(1000,2000),
	[60089] = math.random(1000,2000),
	
	[60090] = math.random(1000,2000),
    [60091] = math.random(1000,2000),
    [60092] = math.random(1000,2000),
    [60093] = math.random(1000,2000),
    [60094] = math.random(1000,2000),
    [60095] = math.random(1000,2000),
    [60096] = math.random(1000,2000),
    [60097] = math.random(1000,2000),
    [60098] = math.random(1000,2000),
    [60099] = math.random(1000,2000),
    
	[60100] = math.random(1000,2000),
    [60101] = math.random(1000,2000),
    [60102] = math.random(1000,2000),
	[60103] = math.random(1000,2000),
    [60104] = math.random(1000,2000),
    [60105] = math.random(1000,2000),
	[60106] = math.random(1000,2000),
    [60107] = math.random(1000,2000),
    [60108] = math.random(1000,2000),
	[60109] = math.random(1000,2000),
	
	[60110] = math.random(1000,2000),
    [60111] = math.random(1000,2000),
    [60112] = math.random(1000,2000),
	[60113] = math.random(1000,2000),
    [60114] = math.random(1000,2000),
    [60115] = math.random(1000,2000),
	[60116] = math.random(1000,2000),
    [60117] = math.random(1000,2000),
    [60118] = math.random(1000,2000),
	[60119] = math.random(1000,2000),
	
	[60120] = math.random(1000,2000),
    [60121] = math.random(1000,2000),
    [60122] = math.random(1000,2000),
	[60123] = math.random(1000,2000),
    [60124] = math.random(1000,2000),
    [60125] = math.random(1000,2000),
	[60126] = math.random(1000,2000),
    [60127] = math.random(1000,2000),
    [60128] = math.random(1000,2000),
	[60129] = math.random(1000,2000),
	
	[60130] = math.random(1000,2000),
    [60131] = math.random(1000,2000),
    [60132] = math.random(1000,2000),
	[60133] = math.random(1000,2000),
    [60134] = math.random(1000,2000),
    [60135] = math.random(1000,2000),
	[60136] = math.random(1000,2000),
    [60137] = math.random(1000,2000),
    [60138] = math.random(1000,2000),
	[60139] = math.random(1000,2000),
	
	[60140] = math.random(1000,2000),
    [60141] = math.random(1000,2000),
    [60142] = math.random(1000,2000),
	[60143] = math.random(1000,2000),
    [60144] = math.random(1000,2000),
    [60145] = math.random(1000,2000),
	[60146] = math.random(1000,2000),
    [60147] = math.random(1000,2000),
    [60148] = math.random(1000,2000),
	[60149] = math.random(1000,2000),

	[60150] = math.random(1000,2000),
    [60151] = math.random(1000,2000),
    [60152] = math.random(1000,2000),
	[60153] = math.random(1000,2000),
    [60154] = math.random(1000,2000),
    [60155] = math.random(1000,2000),
	[60156] = math.random(1000,2000),
    [60157] = math.random(1000,2000),
    [60158] = math.random(1000,2000),
	[60159] = math.random(1000,2000),
	
	[60160] = math.random(1000,2000),
    [60161] = math.random(1000,2000),
    [60162] = math.random(1000,2000),
	[60163] = math.random(1000,2000),
    [60164] = math.random(1000,2000),
    [60165] = math.random(1000,2000),
	[60166] = math.random(1000,2000),
    [60167] = math.random(1000,2000),
    [60168] = math.random(1000,2000),
	[60169] = math.random(1000,2000),
	
	[60170] = math.random(1000,2000),
    [60171] = math.random(1000,2000),
    [60172] = math.random(1000,2000),
	[60173] = math.random(1000,2000),
    [60174] = math.random(1000,2000),
    [60175] = math.random(1000,2000),
	[60176] = math.random(1000,2000),
    [60177] = math.random(1000,2000),
    [60178] = math.random(1000,2000),
	[60179] = math.random(1000,2000),
	
	[60180] = math.random(1000,2000),
    [60181] = math.random(1000,2000),
    [60182] = math.random(1000,2000),
	[60183] = math.random(1000,2000),
    [60184] = math.random(1000,2000),
    [60185] = math.random(1000,2000),
	[60186] = math.random(1000,2000),
    [60187] = math.random(1000,2000),
    [60188] = math.random(1000,2000),
	[60189] = math.random(1000,2000),
	
	[60190] = math.random(1000,2000),
    [60191] = math.random(1000,2000),
    [60192] = math.random(1000,2000),
	[60193] = math.random(1000,2000),
    [60194] = math.random(1000,2000),
    [60195] = math.random(1000,2000),
	[60196] = math.random(1000,2000),
    [60197] = math.random(1000,2000),
    [60198] = math.random(1000,2000),
	[60199] = math.random(1000,2000),
	
	[60200] = math.random(1000,2000),
    [60201] = math.random(1000,2000),
    [60202] = math.random(1000,2000),
	[60203] = math.random(1000,2000),
    [60204] = math.random(1000,2000),
    [60205] = math.random(1000,2000),
	[60206] = math.random(1000,2000),
    [60207] = math.random(1000,2000),
    [60208] = math.random(1000,2000),
	[60209] = math.random(1000,2000),
	
	[60210] = math.random(1000,2000),
    [60211] = math.random(1000,2000),
    [60212] = math.random(1000,2000),
	[60213] = math.random(1000,2000),
    [60214] = math.random(1000,2000),
    [60215] = math.random(1000,2000),
	[60216] = math.random(1000,2000),
    [60217] = math.random(1000,2000),
    [60218] = math.random(1000,2000),
	[60219] = math.random(1000,2000),
	
	[60220] = math.random(1000,2000),
    [60221] = math.random(1000,2000),
    [60222] = math.random(1000,2000),
	[60223] = math.random(1000,2000),
    [60224] = math.random(1000,2000),
    [60225] = math.random(1000,2000),
	[60226] = math.random(1000,2000),
    [60227] = math.random(1000,2000),
    [60228] = math.random(1000,2000),
	[60229] = math.random(1000,2000),
	
	[60230] = math.random(1000,2000),
    [60231] = math.random(1000,2000),
    [60232] = math.random(1000,2000),
	[60233] = math.random(1000,2000),
    [60234] = math.random(1000,2000),
    [60235] = math.random(1000,2000),
	[60236] = math.random(1000,2000),
    [60237] = math.random(1000,2000),
    [60238] = math.random(1000,2000),
	[60239] = math.random(1000,2000),
	
	[60240] = math.random(1000,2000),
    [60241] = math.random(1000,2000),
    [60242] = math.random(1000,2000),
	[60243] = math.random(1000,2000),
    [60244] = math.random(1000,2000),
    [60245] = math.random(1000,2000),
	[60246] = math.random(1000,2000),
    [60247] = math.random(1000,2000),
    [60248] = math.random(1000,2000),
	[60249] = math.random(1000,2000),
	
	[60250] = math.random(1000,2000),
    [60251] = math.random(1000,2000),
    [60252] = math.random(1000,2000),
	[60253] = math.random(1000,2000),
    [60254] = math.random(1000,2000),
    [60255] = math.random(1000,2000),
	[60256] = math.random(1000,2000),
    [60257] = math.random(1000,2000),
    [60258] = math.random(1000,2000),
	[60259] = math.random(1000,2000),
	
	[60260] = math.random(1000,2000),
    [60261] = math.random(1000,2000),
    [60262] = math.random(1000,2000),
	[60263] = math.random(1000,2000),
    [60264] = math.random(1000,2000),
    [60265] = math.random(1000,2000),
	[60266] = math.random(1000,2000),
    [60267] = math.random(1000,2000),
    [60268] = math.random(1000,2000),
	[60269] = math.random(1000,2000),
	
	[60270] = math.random(1000,2000),
    [60271] = math.random(1000,2000),
    [60272] = math.random(1000,2000),
	[60273] = math.random(1000,2000),
    [60274] = math.random(1000,2000),
    [60275] = math.random(1000,2000),
	[60276] = math.random(1000,2000),
    [60277] = math.random(1000,2000),
    [60278] = math.random(1000,2000),
	[60279] = math.random(1000,2000),
	
	[60280] = math.random(1000,2000),
    [60281] = math.random(1000,2000),
    [60282] = math.random(1000,2000),
	[60283] = math.random(1000,2000),
    [60284] = math.random(1000,2000),
    [60285] = math.random(1000,2000),
	[60286] = math.random(1000,2000),
    [60287] = math.random(1000,2000),
    [60288] = math.random(1000,2000),
	[60289] = math.random(1000,2000),
	
	[60290] = math.random(1000,2000),
    [60291] = math.random(1000,2000),
    [60292] = math.random(1000,2000),
	[60293] = math.random(1000,2000),
    [60294] = math.random(1000,2000),
    [60295] = math.random(1000,2000),
	[60296] = math.random(1000,2000),
    [60297] = math.random(1000,2000),
    [60298] = math.random(1000,2000),
	[60299] = math.random(1000,2000)
	
}

