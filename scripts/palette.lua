
local mod = modApi:getCurrentMod()

local palette = {
        image="units/player/Nico_Techno_Psion2_ns.png",
        id = mod.id,
        name = "Leader palette",
        colorMap = {
        	PlateHighlight = {255,249,242},--lights
			PlateLight     = {243,94,222},--main highlight
			PlateMid       = {133,55,152},--main light
			PlateDark      = {56,34,78},--main mid
			PlateOutline   = {9,13,23},--main dark
			PlateShadow    = {160,95,54},--metal dark
			BodyColor      = {221,170,73},--metal mid
	        BodyHighlight  = {255,246,220},--metal light
		},
}

modApi:addPalette(palette)
