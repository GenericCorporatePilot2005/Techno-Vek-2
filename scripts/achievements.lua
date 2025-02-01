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
	"Shield",
}

local achname = "Nico_Techno_"
for _, img in ipairs(imgs) do
	modApi:appendAsset("img/achievements/".. achname..img ..".png", path .."img/achievements/".. img ..".png")
end

modApi.achievements:add{
	id = "Nico_Techno_Leaper",
	name = "Killer King",
	tip = "Deal at least 8 damage with a single slice of the Titanite Talons",
	image = "img/achievements/Nico_Techno_Leaper.png",
	squad = "Nico_Techno_Veks 2",
	objective=1,
}

modApi.achievements:add{
	id = "Nico_Techno_Centipede",
	name = "Disposal Unit",
	tip = "Destroy at least 4 mountains with a single shot of the Splattering Gunk",
	image = "img/achievements/Nico_Techno_Centipede.png",
	squad = "Nico_Techno_Veks 2",
	objective=1,
}

achNico_Techno_Psion = modApi.achievements:add{
	id = "Nico_Techno_Psion",
	name = "Diplomatic Immunity",
	tip = "Don't kill any Psions over the course of 3 Corporate Islands. (Psion Abomination excluded).",
	image = "img/achievements/Nico_Techno_Psion.png",
	squad = "Nico_Techno_Veks 2",
	objective = 3,
}

modApi.achievements:add{
	id = "Nico_Techno_Shield",
	global = "Secret Rewards",
	secret=true,
	name = "The Call of The Psion",
	tip = "New Mech Unlocked on Random and Custom Squads.\nRequires a restart to take effect.",
	image = "img/achievements/Nico_Techno_Shield.png",
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

--Centipede's achievement

--This function has a global variable created in it for the pre-fire mountain count
local function getMountainPreCount(mission, pawn, weaponId, p1, p2)
	local count = 0
	
	if (weaponId == "Acidic_Vomit") or (weaponId == "Acidic_Vomit_A") or (weaponId == "Acidic_Vomit_B") or (weaponId == "Acidic_Vomit_AB") then
		global_gunk = true
	else
		global_gunk = false
	end
	
	if isRealMission() then
		for _, p in ipairs(Board) do
			if Board:IsTerrain(p,TERRAIN_MOUNTAIN) then
				count = count + 1
			end
		end
	end
	
	global_mountains_precount = count
	
	return count
end

--This function is the same as the above one but without the global variable so that when the post-fire count occurs, it does not update global_mountains_precount
local function getMountainPostCount()
	local count = 0
	
	if isRealMission() then
		for _, p in ipairs(Board) do
			if Board:IsTerrain(p,TERRAIN_MOUNTAIN) then
				count = count + 1
			end
		end
	end
	
	return count
end

local function mountainChecker(mission)
	local gunk = global_gunk
	local precount = global_mountains_precount
	local postcount = getMountainPostCount()
	local ret = SkillEffect()
	if isRealMission() and gunk and precount - postcount > 3 and GAME.additionalSquadData.squad == modid and not modApi.achievements:isComplete(modid,"Nico_Techno_Centipede") then
		ret:AddScript("Nico_Techno_Veks2squad_Chievo('Nico_Techno_Centipede')")
		if modApi.achievements:isComplete(modid, "Nico_Techno_Leaper") and modApi.achievements:isComplete(modid, "Nico_Techno_Psion") then ret:AddScript("Nico_Techno_Veks2squad_Chievo('Nico_Techno_Shield')") end
		Board:AddEffect(ret)
		global_gunk = false
	end
end

--Psion's achievement

local function Nico_MissionStart(mission)
	mission.Nico_PsionDeath = false--create mission flag
	if achNico_Techno_Psion:isComplete() then
		achNico_Techno_Psion.tooltip = "Don't kill any Psions over the course of 3 Corporate Islands. (Psion Abomination excluded).\nCompleted."
	elseif achNico_Techno_Psion:getProgress() < 3 then
		Nico_GetProgress(mission)
	end	
end
local function Nico_MissionEnd(mission)
	local progress = modApi.achievements:getProgress("Nico_Techno_Veks 2","Nico_Techno_Psion")
	if not modApi.achievements:isComplete(modid,"Nico_Techno_Psion") then
		if mission.Nico_PsionDeath then
			modApi.achievements:addProgress(modid,"Nico_Techno_Psion",-progress-1)--invalidate if psion was killed
			Nico_GetProgress(mission)
		end
	end
end
local function Nico_GetProgress(mission)
	local texto = math.max(achNico_Techno_Psion:getProgress(),0)
	achNico_Techno_Psion.tooltip = "Don't kill any Psions over the course of 3 Corporate Islands. (Psion Abomination excluded).\n\nCurrent Progress: " .. texto .. "/3"
end
local function Nico_PsionKilled(mission, pawn)
	if (_G[pawn:GetType()].Image == "DNT_jelly" or pawn:GetLeader() ~= 0) and pawn:GetType() ~= "Jelly_Boss" then
		mission.Nico_PsionDeath = true--track death of psion
		Nico_GetProgress(mission)
	end
end
local function Nico_onIslandLeft(island)
	if modApi.achievements:getProgress(modid,"Nico_Techno_Psion")>-1 then
		modApi.achievements:addProgress(modid,"Nico_Techno_Psion",1)--increment if still valid
		Nico_GetProgress(mission)
	end
	if modApi.achievements:isComplete(modid, "Nico_Techno_Leaper") and modApi.achievements:isComplete(modid, "Nico_Techno_Centipede") and modApi.achievements:isComplete(modid,"Nico_Techno_Psion") then modApi.achievements:trigger(modid,"Nico_Techno_Shield") end
end
local function Nico_GameStart()
	if not modApi.achievements:isComplete(modid,"Nico_Techno_Psion") then
		modApi.achievements:reset(modid, "Nico_Techno_Psion")--manually reset the achievement
		if GAME.additionalSquadData.squad ~= modid then
			modApi.achievements:addProgress(modid,"Nico_Techno_Psion",-1)--invalidate if not the right squad
		end
		Nico_GetProgress(mission)
	end
end

local function EVENT_onModsLoaded() --This function will run when the mod is loaded
	--modapiext is requested in the init.lua
	global_gunk = false
	global_mountains_precount = 0
	modapiext:addSkillStartHook(getMountainPreCount)
	--This line tells us that we want to run the above function every time a skill has just begun executing (including skill previews)
	modApi:addSaveGameHook(mountainChecker)
	--This line tells us that we want to run the above function every time the game is saved (so after all weapon effects and death effects and hooks have processed, e.g. Boom Bots, Unstable Boulders)
	modApi:addMissionStartHook(Nico_MissionStart)
	--This line tells us that we want to run the above function every time a mission is entered
	modApi:addMissionEndHook(Nico_MissionEnd)
	--This line tells us that we want to run the above function every time a mission is over
	modapiext:addPawnKilledHook(Nico_PsionKilled)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)
modApi.events.onIslandLeft:subscribe(Nico_onIslandLeft)
modApi.events.onPostStartGame:subscribe(Nico_GameStart)
modApi.events.onHangarLeaving:subscribe(Nico_GetProgress)

return this
