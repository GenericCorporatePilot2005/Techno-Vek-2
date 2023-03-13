local path = GetParentPath(...)
require(path.."palette")
local mod = modApi:getCurrentMod()
local imageOffset = modApi:getPaletteImageOffset(mod.id)

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
	a.Nico_Techno_Centipede =a.MechUnit:new{Image="units/player/Nico_Techno_Centipede.png", PosX = -22, PosY = 4}
	a.Nico_Techno_Centipedea = a.MechUnit:new{Image="units/player/Nico_Techno_Centipede_a.png",  PosX = -20, PosY = 4, NumFrames = 4 }
	a.Nico_Techno_Centipedew = a.MechUnit:new{Image="units/player/Nico_Techno_Centipede_w.png", -22, PosY = 10}
	a.Nico_Techno_Centipede_broken = a.MechUnit:new{Image="units/player/Nico_Techno_Centipede_broken.png", PosX = -22, PosY = 4 }
	a.Nico_Techno_Centipedew_broken = a.MechUnit:new{Image="units/player/Nico_Techno_Centipede_w_broken.png", PosX = -20, PosY = 10 }
	a.Nico_Techno_Centipede_ns = a.MechIcon:new{Image="units/player/Nico_Techno_Centipede_ns.png"}

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
	a.Nico_Techno_Leaper_ns = a.MechIcon:new{Image="units/player/Nico_Techno_Leaper_ns.png"}

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
	a.Nico_Techno_Psion = a.MechUnit:new{Image="units/player/Nico_Techno_Psion.png", PosX = -12, PosY = -10}
	a.Nico_Techno_Psiona = a.MechUnit:new{Image="units/player/Nico_Techno_Psion_a.png", PosX = -15, PosY = -10, NumFrames = 4 }
	a.Nico_Techno_Psionw = a.MechUnit:new{Image="unitsplayer/Nico_Techno_Psion_w.png", PosX = -24, PosY = 6 }
	a.Nico_Techno_Psion_broken = a.MechUnit:new{Image="units/player/Nico_Techno_Psion_broken.png", PosX = -22, PosY = -10 }
	a.Nico_Techno_Psionw_broken = a.MechUnit:new{Image="units/player/Nico_Techno_Psion_w_broken.png", PosX = -22, PosY = 6}
	a.Nico_Techno_Psion_ns = a.MechIcon:new{Image="units/player/Nico_Techno_Psion_ns.png"}

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
		a.Nico_Techno_Shield = a.MechUnit:new{Image="units/player/Nico_Techno_Shield.png", PosX = -12, PosY = -10}
		a.Nico_Techno_Shielda = a.MechUnit:new{Image="units/player/Nico_Techno_Shield_a.png", PosX = -15, PosY = -10, NumFrames = 4 }
		a.Nico_Techno_Shieldw = a.MechUnit:new{Image="unitsplayer/Nico_Techno_Shield_w.png", PosX = -24, PosY = 6 }
		a.Nico_Techno_Shield_broken = a.MechUnit:new{Image="units/player/Nico_Techno_Shield_broken.png", PosX = -22, PosY = -10 }
		a.Nico_Techno_Shieldw_broken = a.MechUnit:new{Image="units/player/Nico_Techno_Shield_w_broken.png", PosX = -22, PosY = 6}
		a.Nico_Techno_Shield_ns = a.MechIcon:new{Image="units/player/Nico_Techno_Shield_ns.png"}

for _, file in ipairs(files) do
	modApi:appendAsset("img/units/player/".. file, ShieldmechPath .. file)
end
CreatePilot{
	Id = "Pilot_Nico_Techno_Centipede",
	Personality = "Vek",
	Sex = SEX_VEK,
	Skill = "Survive_Death",
	Rarity = 0,
	Blacklist = {"Invulnerable", "Popular","Grid"},
}
CreatePilot{
	Id = "Pilot_Nico_Techno_Leaper",
	Personality = "Vek",
	Sex = SEX_VEK,
	Skill = "Survive_Death",
	Rarity = 0,
	Blacklist = {"Invulnerable", "Popular","Grid"},
}
CreatePilot{
	Id = "Pilot_Nico_Techno_Psion",
	Personality = "Vek",
	Sex = SEX_VEK,
	Skill = "Survive_Death",
	Rarity = 0,
	Blacklist = {"Invulnerable", "Popular","Grid"},
}
CreatePilot{
	Id = "Pilot_Nico_Techno_Shield",
	Personality = "Vek",
	Sex = SEX_VEK,
	Skill = "Survive_Death",
	Rarity = 0,
	Blacklist = {"Invulnerable", "Popular","Grid"},
}

-- we can make a mech based on another mech much like we did with weapons.
Nico_Techno_Leaper = Pawn:new{
	Name = "Techno-Leaper",

	Class = "TechnoVek",

	Health = 1,
	MoveSpeed = 4,
	Massive = true,
	Corpse = true,
	Jumper=true,

	Image = "Nico_Techno_Leaper",

	-- ImageOffset specifies which color scheme we will be using.
	-- (only apporpirate if you draw your mechs with Archive olive green colors)
	ImageOffset = 8,

	-- Any weapons this mech should start with goes in this table.
	SkillList = {"Leaper_Talons"},

	-- movement sounds.
	SoundLocation = "/enemy/leaper_2/",

	-- who will be controlling this unit.
	DefaultTeam = TEAM_PLAYER,

	-- impact sounds.
	ImpactMaterial = IMPACT_INSECT,

}
AddPawn("Nico_Techno_Leaper")

local original_MoveGetTargetArea = Move.GetTargetArea

local original_MoveGetSkillEffect = Move.GetSkillEffect
function Move:GetSkillEffect(p1, p2)
	local ret

	if Pawn:GetMechName() == "Techno-Leaper" then
		ret = Nico_LeaperMove:GetSkillEffect(p1, p2)
	else
		ret = original_MoveGetSkillEffect(self, p1, p2)
	end

    return ret
end

Nico_LeaperMove = Move:new{}

function Nico_LeaperMove:GetSkillEffect(p1, p2)

	local ret = SkillEffect()
	local move = PointList()
	move:push_back(p1)
	move:push_back(p2)

	ret:AddSound("/enemy/leaper_1/move")

	ret:AddLeap(move,FULL_DELAY)
	ret:AddBounce(p2, 1)

	ret:AddSound("/enemy/leaper_1/land")

	return ret
end
Nico_Techno_Centipede = Pawn:new{
	Name = "Techno-Centipede",

	-- FlameMech is also Prime, so this is redundant, but if you had no base, you would need a class.
	Class = "TechnoVek",

	-- various stats.
	Health = 3,
	MoveSpeed = 4,
	Massive = true,
	Corpse = true,

	-- reference the animations we set up earlier.
	Image = "Nico_Techno_Centipede",

	-- ImageOffset specifies which color scheme we will be using.
	-- (only apporpirate if you draw your mechs with Archive olive green colors)
	ImageOffset = 8,

	-- Any weapons this mech should start with goes in this table.
	SkillList = {"Acidic_Vomit"},

	-- movement sounds.
	SoundLocation = "/enemy/centipede_2/",

	-- who will be controlling this unit.
	DefaultTeam = TEAM_PLAYER,

	-- impact sounds.
	ImpactMaterial = IMPACT_INSECT,

AddPawn("Nico_Techno_Centipede")
}
Nico_Techno_Psion = Pawn:new{
	Name = "Techno-Psion",

	-- FlameMech is also Prime, so this is redundant, but if you had no base, you would need a class.
	Class = "TechnoVek",

	-- various stats.
	Health = 2,
	MoveSpeed = 3,
	LargeShield = true,
	Massive = true,
	Corpse = true,
    Flying=true,

	-- reference the animations we set up earlier.
	Image = "Nico_Techno_Psion",

	-- ImageOffset specifies which color scheme we will be using.
	-- (only apporpirate if you draw your mechs with Archive olive green colors)
	ImageOffset = 8,

	-- Any weapons this mech should start with goes in this table.
	SkillList = {"Tentacle_attack" ,"Passive_Psions" },

	-- movement sounds.
	SoundLocation = "/enemy/jelly/",

	-- who will be controlling this unit.
	DefaultTeam = TEAM_PLAYER,

	-- impact sounds.
	ImpactMaterial = IMPACT_INSECT,

}
AddPawn("Nico_Techno_Psion")


--Remove Grapples (Webs) from Leaper Mech:
local function HOOK_PawnGrappled(mission, pawn, isGrappled) --Here's the function that will run
	if isGrappled and pawn:GetType() == "Nico_Techno_Leaper" then --If we're grappled and it's our leaper
		--If removing the web right away it looks really weird (try it if you want). So we'll wait about half a second with this
		modApi:scheduleHook(550,function()
			local space = pawn:GetSpace() --Store the space so we can move it back later
			Board:AddAlert(space,"WEB PREVENTED") --This will play an alert when it happens
			--It's entirely optional, remove it if you don't like it
			pawn:SetSpace(Point(-1,-1)) --Move the pawn to Point(-1,-1)
			modApi:runLater(function() --This runs a function one frame later so things get updated
				pawn:SetSpace(space) --Move the pawn back, after that one frame. The web will be gone
			end)
		end)
	end
end

local function EVENT_onModsLoaded() --This function will run when the mod is loaded
	--modapiext is requested in the init.lua
	modapiext:addPawnIsGrappledHook(HOOK_PawnGrappled)
	--This line tells us that we want to run the above function every time a pawn is grappled
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)
--This tells the mod loader to run the above when loaded

modApi:appendAsset("img/combat/icons/icon_Nico_grapple.png", path.."img/combat/icons/icon_Nico_grapple.png")--image of the trait
local mod = modApi:getCurrentMod()--the mod itself
local trait = require(mod.scriptPath .."libs/trait")--where does it get the code for the rest of this to work
trait:add{
	pawnType="Nico_Techno_Leaper",--who will get the trait
	icon = "img/combat/icons/icon_Nico_grapple.png",--the icon itself
	icon_offset = Point(0,9),--it's location
	desc_title = "Web Immunity",--title
	desc_text = "This unit is unaffected by Webbing.",--description
}

Nico_Techno_Shield = Pawn:new{
	Name = "Shield Psion",

	-- FlameMech is also Prime, so this is redundant, but if you had no base, you would need a class.
	Class = "TechnoVek",

	-- various stats.
	Health = 2,
	MoveSpeed = 4,
	LargeShield = true,
	Massive = true,
	Corpse = true,
	Flying=true,

	-- reference the animations we set up earlier.
	Image = "Nico_Techno_Shield",

	-- ImageOffset specifies which color scheme we will be using.
	-- (only apporpirate if you draw your mechs with Archive olive green colors)

	ImageOffset = imageOffset,

	-- Any weapons this mech should start with goes in this table.
	SkillList = {"Shield_attack" ,"Passive_Psions" },

	-- movement sounds.
	SoundLocation = "/enemy/jelly/",

	-- who will be controlling this unit.
	DefaultTeam = TEAM_PLAYER,

	-- impact sounds.
	ImpactMaterial = IMPACT_INSECT,
	}
AddPawn("Nico_Techno_Shield")

--pendiente, hacer posible lo de arriba, ya lograste hacer andar el mod, el resto es refinar los detalles, vos podes!