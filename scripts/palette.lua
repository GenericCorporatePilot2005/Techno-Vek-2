
local mod = modApi:getCurrentMod()

local palette = {
    image="units/player/Nico_Techno_Shield_ns.png",
    id = mod.id,
    name = "Shield Psion's Sky Blue & Pink",
        colorMap = {
        	PlateHighlight = {197,255,255},--lights
			PlateLight     = {243,94,222},--main highlight
			PlateMid       = {133,55,152},--main light
			PlateDark      = {56,34,78},--main mid
			PlateOutline   = {9,13,23},--main dark
			PlateShadow    = {22,66,82},--metal dark
			BodyColor      = {0,175,199},--metal mid
	        BodyHighlight  = {109,255,243},--metal light
		},
}

modApi:addPalette(palette)
