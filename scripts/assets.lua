local path = GetParentPath(...)
-- this line just gets the file path for your mod, so you can find all your files easily.
local path = mod_loader.mods[modApi.currentMod].resourcePath
	modApi:appendAsset("img/portraits/pilots/Pilot_Nico_Techno_Centipede.png", path .."img/portraits/Pilot_CentipedeMech.png")
	modApi:appendAsset("img/portraits/pilots/Pilot_Nico_Techno_Leaper.png", path .."img/portraits/Pilot_LeaperMech.png")
	modApi:appendAsset("img/portraits/pilots/Pilot_Nico_Techno_Psion.png", path .."img/portraits/Pilot_PsionMech.png")
	modApi:appendAsset("img/portraits/pilots/Pilot_Nico_Techno_Shield.png", path .."img/portraits/Pilot_ShieldMech.png")
-- locate our mech assets.
local CentmechPath = path .."img/units/player/"
-- make a list of our files.
local files = {
	"Nico_Techno_Centipede.png",
	"Nico_Techno_Centipede_a.png",
	"Nico_Techno_Centipede_w.png",
	"Nico_Techno_Centipede_w_broken.png",
	"Nico_Techno_Centipede_broken.png",
	"Nico_Techno_Centipede_ns.png",
	"Nico_Techno_Centipede_h.png",
}
for _, file in ipairs(files) do
	modApi:appendAsset("img/units/player/".. file, CentmechPath .. file)
end
local a=ANIMS
	a.Nico_Techno_Centipede =a.MechUnit:new{Image="units/player/Nico_Techno_Centipede.png", PosX = -19, PosY = 4}
	a.Nico_Techno_Centipedea = a.MechUnit:new{Image="units/player/Nico_Techno_Centipede_a.png",  PosX = -20, PosY = 4, NumFrames = 4 }
	a.Nico_Techno_Centipedew = a.MechUnit:new{Image="units/player/Nico_Techno_Centipede_w.png", -22, PosY = 10}
	a.Nico_Techno_Centipede_broken = a.MechUnit:new{Image="units/player/Nico_Techno_Centipede_broken.png", PosX = -22, PosY = 4 }
	a.Nico_Techno_Centipedew_broken = a.MechUnit:new{Image="units/player/Nico_Techno_Centipede_w_broken.png", PosX = -20, PosY = 10 }
	a.Nico_Techno_Centipede_ns = a.MechIcon:new{Image="units/player/Nico_Techno_Centipede_ns.png" }

-- locate our mech assets.
local LeapmechPath = path .."img/units/player/"
-- make a list of our files.
local files = {
	"Nico_Techno_Leaper.png",
	"Nico_Techno_Leaper_a.png",
	"Nico_Techno_Leaper_w.png",
	"Nico_Techno_Leaper_w_broken.png",
	"Nico_Techno_Leaper_broken.png",
	"Nico_Techno_Leaper_ns.png",
	"Nico_Techno_Leaper_h.png",
}
for _, file in ipairs(files) do
	modApi:appendAsset("img/units/player/".. file, LeapmechPath .. file)
end
local a=ANIMS
	a.Nico_Techno_Leaper =	a.MechUnit:new{Image = "units/player/Nico_Techno_Leaper.png", PosX = -21, PosY = -3}
	a.Nico_Techno_Leapera =	a.MechUnit:new{Image = "units/player/Nico_Techno_Leaper_a.png", PosX = -21, PosY = -3, NumFrames = 4 }
	a.Nico_Techno_Leaperw =	a.MechUnit:new{Image = "units/player/Nico_Techno_Leaper_w.png", PosX = -19, PosY = 6 }
	a.Nico_Techno_Leaper_broken = a.MechUnit:new{Image="units/player/Nico_Techno_Leaper_broken.png", PosX = -21, PosY = -3 }
	a.Nico_Techno_Leaperw_broken = a.MechUnit:new{Image="units/player/Nico_Techno_Leaper_w_broken.png", PosX = -19, PosY = 6 }
	a.Nico_Techno_Leaper_ns = a.MechIcon:new{Image="units/player/Nico_Techno_Leaper_ns.png" }

local PsionmechPath=path .."img/units/player/"
local files = {
	"Nico_Techno_Psion.png",
	"Nico_Techno_Psion_a.png",
	"Nico_Techno_Psion_w.png",
	"Nico_Techno_Psion_w_broken.png",
	"Nico_Techno_Psion_broken.png",
	"Nico_Techno_Psion_ns.png",
	"Nico_Techno_Psion_h.png",
}
for _, file in ipairs(files) do
	modApi:appendAsset("img/units/player/".. file, PsionmechPath .. file)
end
local a = ANIMS
	a.Nico_Techno_Psion = a.MechUnit:new{Image="units/player/Nico_Techno_Psion.png", PosX = -27, PosY = -14}
	a.Nico_Techno_Psiona = a.MechUnit:new{Image="units/player/Nico_Techno_Psion_a.png", PosX = -15, PosY = -10, NumFrames = 4 }
	a.Nico_Techno_Psionw = a.MechUnit:new{Image="unitsplayer/Nico_Techno_Psion_w.png", PosX = -24, PosY = 6 }
	a.Nico_Techno_Psion_broken = a.MechUnit:new{Image="units/player/Nico_Techno_Psion_broken.png", PosX = -22, PosY = -10 }
	a.Nico_Techno_Psionw_broken = a.MechUnit:new{Image="units/player/Nico_Techno_Psion_w_broken.png", PosX = -22, PosY = 6}
	a.Nico_Techno_Psion_ns = a.MechIcon:new{Image="units/player/Nico_Techno_Psion_ns.png" }

	local ShieldmechPath=path .."img/units/player/"
	local files = {
		"Nico_Techno_Shield.png",
		"Nico_Techno_Shield_a.png",
		"Nico_Techno_Shield_w.png",
		"Nico_Techno_Shield_w_broken.png",
		"Nico_Techno_Shield_broken.png",
		"Nico_Techno_Shield_ns.png",
		"Nico_Techno_Shield_h.png",
	}
	local a = ANIMS
		a.Nico_Techno_Shield = a.MechUnit:new{Image="units/player/Nico_Techno_Shield.png", PosX = -27, PosY = -14}
		a.Nico_Techno_Shielda = a.MechUnit:new{Image="units/player/Nico_Techno_Shield_a.png", PosX = -15, PosY = -10, NumFrames = 8 }
		a.Nico_Techno_Shieldw = a.MechUnit:new{Image="unitsplayer/Nico_Techno_Shield_w.png", PosX = -24, PosY = 6 }
		a.Nico_Techno_Shield_broken = a.MechUnit:new{Image="units/player/Nico_Techno_Shield_broken.png", PosX = -22, PosY = -10 }
		a.Nico_Techno_Shieldw_broken = a.MechUnit:new{Image="units/player/Nico_Techno_Shield_w_broken.png", PosX = -22, PosY = 6}
		a.Nico_Techno_Shield_ns = a.MechIcon:new{Image="units/player/Nico_Techno_Shield_ns.png"}

for _, file in ipairs(files) do
	modApi:appendAsset("img/units/player/".. file, ShieldmechPath .. file)
end