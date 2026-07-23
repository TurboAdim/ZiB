Config = {}

----------------------------------------------------
-- MARKER
----------------------------------------------------

Config.Marker = {
    2290.3,2428.3,9.9
}

----------------------------------------------------
-- SPAWNY
----------------------------------------------------

Config.Spawns = {

    {2301.6518554688,2416.4250488281,10.247027397156,90}, -- A
    {2279.5104980469,2416.5788574219,10.277377128601,90}, -- B
    {2253.5756835938,2416.5258789062,10.247899055481,90} -- C

}

----------------------------------------------------
-- POJAZDY
----------------------------------------------------

Config.Vehicles = {

    {
        name = "Police LS",
        model = 596
    },

    {
        name = "Police SF",
        model = 597
    },
	
	{
        name = "Police LV",
        model = 598
    },
	
	{
        name = "Police Rancher",
        model = 599
    },

    {
        name = "Chevrolet Monte Carlo '71 Unmarked",
        model = 60186
    },

    {
        name = "Chevrolet Monte Carlo '71 Marked",
        model = 60187
    },
	
	{
        name = "Ford Crown Victoria Police Interceptor",
        model = 60011
    },

    {
        name = "Ford F-150 Police Interceptor",
        model = 60012
    },
	
	{
        name = "Dodge Charger Police Interceptor '18",
        model = 60013
    },

    {
        name = "Ford Fusion Police Interceptor '18",
        model = 60014
    },
	
	{
        name = "Panto Police",
        model = 60061
    },
	
	{
        name = "Infernus JDM Police '91",
        model = 60075
    },
	
	{
        name = "FBI Rancher",
        model = 490
    },
	
	{
        name = "Nissan Skyline GT-R35",
        model = 60195
    },
	
	{
        name = "Nissan Skyline GT-R34",
        model = 60196
    },
	
	{
        name = "Pontiac GTO Marked Police NFSMW",
        model = 60201
    },
	
	{
        name = "Pontiac GTO Unmarked Police NFSMW",
        model = 60202
    },
	
	{
        name = "Chevrolec Corvette C6 Marked Police NFSMW",
        model = 60203
    },
	
	{
        name = "Chevrolec Corvette C6 Unmarked Police NFSMW",
        model = 60204
    },
	
	{
        name = "Ford CVPI SFPD",
        model = 60205
    },
	
	{
        name = "Ford Explorer SFPD",
        model = 60206
    },
	
	{
        name = "Dodge Charger SFPD '18",
        model = 60207
    },
	
	{
        name = "Ford F-150 BombSquad SFPD",
        model = 60208
    },
	
	{
        name = "Dodge Magnum SFPD",
        model = 60209
    },
	
	{
        name = "Dodge Charger SFPD '14",
        model = 60210
    },
	
	{
        name = "Lamborghini Huracan EVO '19 Police",
        model = 60211
    },
	
	{
        name = "Lamborghini Aventador Police",
        model = 60212
    },
	
	{
        name = "Ford CVPI ver3",
        model = 60213
    },
	
	{
        name = "Dodge Charger '08 Slicktop",
        model = 60214
    },
	
	{
        name = "Pontiac Firebird TransAM '87 Police",
        model = 60218
    },
	
	{
        name = "Pontiac Firebird TransAM '79 Police",
        model = 60219
    },
	
	{
        name = "Ford CVPI LSP ver4",
        model = 60224
    },
	
	{
        name = "Ford Mustang Shelby GT500 '09",
        model = 60227
    },
	
	{
        name = "Honda Integra '96",
        model = 60229
    },
	
	--[[{
        name = "Dodge Viper '09 NFSHP",
        model = 60240
    },--]]

}

----------------------------------------------------
-- SKINY
----------------------------------------------------

Config.Skins = {

    {
        name = "Police Officer 1",
        skin = 280
    },

    {
        name = "Police Officer 2",
        skin = 281
    },
	
	{
        name = "Police Officer 3",
        skin = 282
    },
	
	{
        name = "Police Officer 4",
        skin = 283
    },
	
	{
        name = "Police Officer 5",
        skin = 288
    },
	
	{
        name = "FBI Officer 1",
        skin = 286
    },
	
	{
        name = "Officer Tenpenny",
        skin = 265
    },
	
	{
        name = "Officer Pulaski",
        skin = 266
    },
	
	{
        name = "Officer Hern",
        skin = 267
    },

    {
        name = "Custom Skin 1",
        skin = 20001
    },
	
	{
        name = "Custom Skin 2",
        skin = 20002
    },

    {
        name = "Custom Skin 3",
        skin = 20003
    }

}

----------------------------------------------------
-- CELE
----------------------------------------------------

Config.Cells = {

    [1] = {5,5,5},
    [2] = {10,10,10},
    [3] = {15,15,15},
    [4] = {20,20,20}

}



----------------------------------------------------
-- STROBO
----------------------------------------------------

Config.Strobes = {

    ----------------------------------------------------
    -- 596
    ----------------------------------------------------

    [596] = {

    colors = {
        {255, 0, 0},   -- czerwony
        {0, 0, 255}    -- niebieski
    },

    offsets = {
        {-0.35, -0.35, 0.9},
		{0.35, -0.35, 0.9},
		
        {-0.55, -0.35, 0.9},
		{ 0.55, -0.35, 0.9},
    }
},

    ----------------------------------------------------
    -- 597
    ----------------------------------------------------

    [597] = {

        colors = {
        {255, 0, 0},   -- czerwony
        {0, 0, 255}    -- niebieski
    },

    offsets = {
        {-0.35, -0.35, 0.9},
		{0.35, -0.35, 0.9},
		
        {-0.55, -0.35, 0.9},
		{ 0.55, -0.35, 0.9},
    }
},

    ----------------------------------------------------
    -- CUSTOM 60210
    ----------------------------------------------------

    [598] = {

        colors = {
        {255, 0, 0},   -- czerwony
        {0, 0, 255}    -- niebieski
    },

    offsets = {
        {-0.35, -0.35, 0.95},
		{0.35, -0.35, 0.95},
		
        {-0.55, -0.35, 0.95},
		{ 0.55, -0.35, 0.95},
    }
},


	
	[599] = {

        colors = {
        {255, 0, 0},   -- czerwony
        {0, 0, 255}    -- niebieski
    },

    offsets = {
        {-0.35, 0.09, 1.15},
		{ 0.35, 0.09, 1.15},
		
        {-0.55, 0.09, 1.15},
		{ 0.55, 0.09, 1.15},
    }
},
	
	[60011] = {

        {-1.4, 0.3, 1.40},
        {-0.9, 0.3, 1.40},
        {-0.4, 0.3, 1.40},

        { 0.4, 0.3, 1.40},
        { 0.9, 0.3, 1.40},
        { 1.4, 0.3, 1.40},

    },
	
	[60012] = {

        {-1.4, 0.3, 1.40},
        {-0.9, 0.3, 1.40},
        {-0.4, 0.3, 1.40},

        { 0.4, 0.3, 1.40},
        { 0.9, 0.3, 1.40},
        { 1.4, 0.3, 1.40},

    },
	
	
	[60013] = {

        {-1.4, 0.3, 1.40},
        {-0.9, 0.3, 1.40},
        {-0.4, 0.3, 1.40},

        { 0.4, 0.3, 1.40},
        { 0.9, 0.3, 1.40},
        { 1.4, 0.3, 1.40},

    },
	
	[60014] = {

        {-1.4, 0.3, 1.40},
        {-0.9, 0.3, 1.40},
        {-0.4, 0.3, 1.40},

        { 0.4, 0.3, 1.40},
        { 0.9, 0.3, 1.40},
        { 1.4, 0.3, 1.40},

    },
	
	
	-- PANTO POLICE
	[60061] = {

        colors = {
        {255, 0, 0},   -- czerwony
        {0, 0, 255}    -- niebieski
    },

    offsets = {
        {-0.4, -0.25, 0.9},

        { 0.4, -0.25, 0.9},
    }
},
	
	--[[[60075] = {

        --{-1.4, 0.3, 1.40},
        --{-0.9, 0.3, 1.40},
        {-0.36, 0, 0.8},

        { 0.36, 0, 0.8},
        --{ 0.9, 0.3, 1.40},
        --{ 1.4, 0.3, 1.40},

    },--]]
	
	-- INFERNUS JDM Police
	[60075] = { 

    colors = {
        {255, 0, 0},   -- czerwony
        --{0, 0, 255}    -- niebieski
    },

    offsets = {
        {-0.35, -0.05, 0.77},

        { 0.35, -0.05, 0.77},
    }
},




-- Nissan Skyline GT-R35 Police
	[60195] = { 

    colors = {
        {255, 0, 0},   -- czerwony
        --{0, 0, 255}    -- niebieski
    },

    offsets = {
        {-0.35, -0.3, 1},

        { 0.35, -0.3, 1},
    }
},

-- Nissan Skyline GT-R34 Police
	[60196] = { 

    colors = {
        {255, 0, 0},   -- czerwony
        --{0, 0, 255}    -- niebieski
    },

    offsets = {
        {-0.35, -0.35, 1},

        { 0.35, -0.35, 1},
		
		{ 0.3, 2.5, 0.04},

        {-0.3, 2.5, 0.04},
    }
},







	
	-- Chevrolet Monte Carlo Unmarked
	[60186] = {

        colors = {
        {255, 0, 0},   -- czerwony
        {0, 0, 255}    -- niebieski
    },

    offsets = {
        {-0.63, -0.35, 0.8},
		{ 0.29, -0.12, 0.8},
		
        {0.63, -0.35, 0.8},
		{-0.29, -0.12, 0.8},
		
		{0.0, 0.07, 0.8},
    }
},
	
	
	
	-- Chevrolet Monte Carlo Marked
	[60187] = {

        colors = {
        {255, 0, 0},   -- czerwony
        {0, 0, 255}    -- niebieski
    },

    offsets = {
        {-0.45, -0.25, 0.9},

        { 0.45, -0.25, 0.9},
    }
},
	
	[490] = {

        {-1.4, 0.3, 1.40},
        {-0.9, 0.3, 1.40},
        {-0.4, 0.3, 1.40},

        { 0.4, 0.3, 1.40},
        { 0.9, 0.3, 1.40},
        { 1.4, 0.3, 1.40},



},


-- Pontiac GTO Marked Police NFSMW
	[60201] = {

    colors = {
        {255, 0, 0},   -- czerwony
        {0, 0, 255}    -- niebieski
    },

    offsets = {
        {-0.58, -0.43, 1},
		{ 0.15, -0.3, 1},
		
		{-0.15, -0.3, 1},
		{ 0.58, -0.43, 1},
		
		--{0.0, 0.07, 1},
    }
},

-- Pontiac GTO Unmarked Police NFSMW
	[60202] = {

    colors = {
        {255, 0, 0},   -- czerwony
        {0, 0, 255}    -- niebieski
    },

    offsets = {
        { 0.15, 0.2, 0.8},
		{ 0.42, 0.2, 0.8},
		
		{-0.42, 0.2, 0.8},
		{-0.15, 0.2, 0.8},
    }
},



-- Chevrolet Corvette C6 Marked Police NFSMW
	[60203] = {

    colors = {
        {255, 0, 0},   -- czerwony
        {0, 0, 255}    -- niebieski
    },

    offsets = {
        {-0.58, -0.43, 0.6},
		{ 0.15, -0.3, 0.6},
		
		{-0.15, -0.3, 0.6},
		{ 0.58, -0.43, 0.6},
		
		
		
		{ 0.58, -2.3, 0.5},
		{-0.15, -2.3, 0.5},
		
		{ 0.15, -2.3, 0.5},
		{-0.58, -2.3, 0.5},
		
		{-0.55, -2.2, -0.15},
		{ 0.55, -2.2, -0.15},
		
    }
},

-- Chevrolet Corvette C6 Unmarked Police NFSMW
	[60204] = {

    colors = {
        {255, 0, 0},   -- czerwony
        {0, 0, 255}    -- niebieski
    },

    offsets = {
		{ 0.5, 0.15, 0.45},
		{-0.4, 0.15, 0.45},
		
		{-0.5, 0.15, 0.45},
		{ 0.4, 0.15, 0.45},
		
		
		
		{-0.58, -2.3, 0.5},
		{ 0.15, -2.3, 0.5},
		
		{-0.15, -2.3, 0.5},
		{ 0.58, -2.3, 0.5},
		
		{ 0.55, -2.2, -0.15},
		{-0.55, -2.2, -0.15},
		
    }
},



-- Ford CVPI SFPD
	[60205] = {

        colors = {
        {255, 0, 0},   -- czerwony
        {0, 0, 255}    -- niebieski
    },

    offsets = {
        {-0.5, -0.3, 1},

        { 0.5, -0.3, 1},
    }
},

-- Ford Explorer SFPD
	[60206] = {

        colors = {
        {255, 0, 0},   -- czerwony
        {0, 0, 255}    -- niebieski
    },

    offsets = {
        {-0.6, -0.35, 1.2},

        { 0.6, -0.35, 1.2},
    }
},


-- Dodge Charger SFPD '18
	[60207] = {

        colors = {
        {255, 0, 0},   -- czerwony
        {0, 0, 255}    -- niebieski
    },

    offsets = {
        {-0.55, -0.25, 1},

        { 0.55, -0.25, 1},
    }
},

-- Ford Explorer SFPD
	[60208] = {

        colors = {
        {255, 0, 0},   -- czerwony
        {0, 0, 255}    -- niebieski
    },

    offsets = {
        {-0.6, -0.1, 1.2},

        { 0.6, -0.1, 1.2},
    }
},




-- Dodge Magnum SFPD
	[60209] = {

        colors = {
        {255, 0, 0},   -- czerwony
        {0, 0, 255}    -- niebieski
    },

    offsets = {
        {-0.45, -0.3, 0.85},

        { 0.5, -0.3, 0.85},
    }
},


-- Dodge Charger '14
	[60210] = {

        colors = {
        {255, 0, 0},   -- czerwony
        {0, 0, 255}    -- niebieski
    },

    offsets = {
        {-0.4, -0.25, 1.1},
		
        { 0.4, -0.25, 1.1},
    }
},


-- Lamborghini Huracan EVO Police
	[60211] = {

        colors = {
        {255, 0, 0},   -- czerwony
        {0, 0, 255}    -- niebieski
    },

    offsets = {
        {-0.4, 0.15, 0.75},
		
        { 0.4, 0.15, 0.75},
    }
},


-- Lamborghini Aventador Police
	[60212] = {

        colors = {
        {255, 0, 0},   -- czerwony
        {0, 0, 255}    -- niebieski
    },

    offsets = {
        {-0.4, -0.3, 0.7},
		
        { 0.4, -0.3, 0.7},
    }
},


-- Ford CVPI SFPD
	[60213] = {

        colors = {
        {255, 0, 0},   -- czerwony
        {0, 0, 255}    -- niebieski
    },

    offsets = {
        {-0.45, -0.3, 1},

        { 0.45, -0.3, 1},
    }
},



-- Dodge Charger '08 Slicktop
	[60214] = {

        colors = {
        {255, 0, 0},   -- czerwony
        {0, 0, 255}    -- niebieski
    },

    offsets = {
        {-0.4, -1.7, 0.46},
        {-0.33, -1.7, 0.46},
		
		{ 0.1, 0.45, 0.65},
        {-0.1, 0.45, 0.65},
    }
},
	
-- Pontiac Firebird TransAM '87
	[60218] = {

        colors = {
        {255, 0, 0},   -- czerwony
        {0, 0, 255}    -- niebieski
    },

    offsets = {
        {-0.45, -0.3, 0.7},
        { 0.45, -0.3, 0.7},
    }
},

-- Pontiac Firebird TransAM '79
	[60219] = {

        colors = {
        {255, 0, 0},   -- czerwony
        {0, 0, 255}    -- niebieski
    },

    offsets = {
        {-0.45, -0.55, 0.8},
        { 0.45, -0.55, 0.8},
    }
},


-- Ford CVPI LSP ver4
	[60224] = {

        colors = {
        {255, 0, 0},   -- czerwony
        {0, 0, 255}    -- niebieski
    },

    offsets = {
        {-0.63, -0.35, 0.8},
		{ 0.29, -0.12, 0.8},
		
        {0.63, -0.35, 0.8},
		{-0.29, -0.12, 0.8},
		
		{0.0, 0.07, 0.8},
    }
},


-- Ford Mustang Shelby GT500
	[60227] = {

        colors = {
        {255, 0, 0},   -- czerwony
        {0, 0, 255}    -- niebieski
    },

    offsets = {
        { 0.3, -0.35, 0.95},
        {-0.3, -0.35, 0.95},
		
		{-0.15, 2.4, 0.05},
        { 0.15, 2.4, 0.05},
    }
},


-- Honda Integra '96
	[60229] = {

        colors = {
        {255, 0, 0},   -- czerwony
        {0, 0, 255}    -- niebieski
    },

    offsets = {
        {-0.3, -0.3, 0.9},
        { 0.3, -0.3, 0.9},
    }
},

--[[ Dodge Viper '09 NFSHP
	[60240] = {

        colors = {
        {255, 0, 0},   -- czerwony
        {0, 0, 255}    -- niebieski
    },

    offsets = {
        {-0.4, -0.45, 0.95},
        { 0.4, -0.45, 0.95},
		
		{-0.55, 2.4, -0.1},
        { 0.55, 2.4, -0.1},
		
		{ 0.6, -2.4, -0.15},
        {-0.6, -2.4, -0.15},
    }
},--]]



}