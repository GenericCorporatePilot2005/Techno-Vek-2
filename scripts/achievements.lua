local this={}

local path = mod_loader.mods[modApi.currentMod].resourcePath
local modid = "Nico_Techno_Veks 2" -- also Squad id

function Nico_Techno_Veks2squad_Chievo(id)
    	-- exit if not our squad
	if Board:GetSize() == Point(6,6) then return end -- TipImage
	if GAME.additionalSquadData.squad ~= modid then return end
	if IsTestMechScenario() then return end
	-- exit if current one is unlocked
	modApi.achievements:trigger(modid,id)
	
end
local imgs = {
	"Leaper",
	"Centipede",
	"Psion",
}

local achname = "Nico_Techno_"
for _, img in ipairs(imgs) do
	modApi:appendAsset("img/achievements/".. achname..img ..".png", path .."img/achievements/".. img ..".png")
end

modApi.achievements:add{
	id = "Nico_Techno_Leaper",
	name = "Killer King",
	tip = "Deal at least 10 damage with a single slice of the Titanite Talons",
	image = "img/achievements/Nico_Techno_Leaper.png",
	squad = "Nico_Techno_Veks 2",
}

modApi.achievements:add{
	id = "Nico_Techno_Centipede",
	name = "Disposal Unit",
	tip = "Destroy at least 3 mountains with a single shot of the Splattering Gunk",
	image = "img/achievements/Nico_Techno_Centipede.png",
	squad = "Nico_Techno_Veks 2",
}

--Lemon's Real Mission Checker
local function isRealMission()
	local mission = GetCurrentMission()

	return true
		and mission ~= nil
		and mission ~= Mission_Test
		and Board
		and Board:IsMissionBoard()
end

--This function has a global variable created in it for the pre-fire mountain count
local function getMountainPreCount(mission, pawn, weaponId, p1, p2)
	local count = 0
	
	if (weaponId == "Acidic_Vomit") or (weaponId == "Acidic_Vomit_A") or (weaponId == "Acidic_Vomit_B") or (weaponId == "Acidic_Vomit_AB") then
		global_gunk = true
	else
		global_gunk = false
	end
	
	for _, p in ipairs(Board) do
		if Board:IsTerrain(p,TERRAIN_MOUNTAIN) then
			count = count + 1
		end
	end
	
	global_mountains_precount = count
	
	return count
end

--This function is the same as the above one but without the global variable so that when the post-fire count occurs, it does not update global_mountains_precount
local function getMountainPostCount(mission, pawn, weaponId, p1, p2)
	local count = 0
	
	if (weaponId == "Acidic_Vomit") or (weaponId == "Acidic_Vomit_A") or (weaponId == "Acidic_Vomit_B") or (weaponId == "Acidic_Vomit_AB") then
		global_gunk = true
	else
		global_gunk = false
	end
	
	for _, p in ipairs(Board) do
		if Board:IsTerrain(p,TERRAIN_MOUNTAIN) then
			count = count + 1
		end
	end
	
	return count
end

local function mountainChecker(mission)
	local gunk = global_gunk
	local precount = global_mountains_precount
	local postcount = getMountainPostCount()
	local ret = SkillEffect()
	if isRealMission() and gunk and precount - postcount > 2 then
		ret:AddScript("Nico_Techno_Veks2squad_Chievo('Nico_Techno_Centipede')")
		Board:AddEffect(ret)
	end
end

local function EVENT_onModsLoaded() --This function will run when the mod is loaded
	--modapiext is requested in the init.lua
	global_gunk = false
	global_mountains_precount = 0
	modapiext:addSkillStartHook(getMountainPreCount)
	--This line tells us that we want to run the above function every time a skill has just begun executing (including skill previews)
	modApi:addSaveGameHook(mountainChecker)
	--This line tells us that we want to run the above function every time the game is saved (so after all weapon effects and death effects have processed, e.g. Boom Bots, Unstable Boulders)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)

modApi.achievements:add{
	id = "Nico_Techno_Psion",
	name = "Diplomatic immunity",
	tip = "Don't kill any Psions over the course of 3 Corporate Islands (Psion Abomination excluded)",
	image = "img/achievements/Nico_Techno_Psion.png",
	squad = "Nico_Techno_Veks 2",
}

local function HOOK_nextTurn(mission)
	if isMissionBoard() then

		--Diplomatic immunity
		if not achievements.Nico_Techno_Psion:isComplete() then
			if Board:GetTurn() == 1 and Game:GetTeamTurn() == TEAM_PLAYER then
				ret:AddScript("Nico_Techno_Veks2squad_Chievo('Nico_Techno_Psion')")
			end
		end

	end
end


local hook = function(mission)
    if PsionWasKilled() then
        modApi.achievements:reset("Nico_Techno_Veks 2", Nico_Techno_Psion)
    else
        modApi.achievements:addProgress("Nico_Techno_Veks 2", Nico_Techno_Psion, 1)
    end
end
modApi:addMissionEndHook(hook)

function PsionWasKilled()
local pawns = extract_table(Board:GetPawns(TEAM_VEK))
	local psionKilled = false
		for i, v in ipairs(pawns) do
			local pawn = Board:GetPawn(v)
			if pawn:GetLeader() ~= LEADER_NONE and pawn:IsDead() then
				psionKilled = true
			end
		end
	return psionKilled
end
local hook = function(corporation, island)
	if modApi.achievements:getProgress("Nico_Techno_Veks 2", Nico_Techno_Psion) < 5 then
		modApi.achievements:reset("Nico_Techno_Veks 2", Nico_Techno_Psion)
	end
end
modApi:addPostIslandSelectionHook(hook)

return this