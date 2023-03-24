-- this line just gets the file path for your mod, so you can find all your files easily.
local path = mod_loader.mods[modApi.currentMod].resourcePath

-- add assets from our mod so the game can find them.

local scriptPath = mod_loader.mods[modApi.currentMod].resourcePath

modApi:appendAsset("img/combat/icons/icon_Nico_lava.png", path.."img/combat/icons/icon_Nico_lava.png")
Location["combat/icons/icon_Nico_lava.png"] = Point(-12,12)
modApi:appendAsset("img/combat/icons/icon_Nico_acid_water.png", path.."img/combat/icons/icon_Nico_acid_water.png")
Location["combat/icons/icon_Nico_acid_water.png"] = Point(-12,12)

modApi:appendAsset("img/combat/icons/icon_Nico_shield_glow.png", path.."img/combat/icons/icon_Nico_shield_glow.png")
Location["combat/icons/icon_Nico_shield_glow.png"] = Point(-12,12)
modApi:appendAsset("img/combat/icons/icon_Nico_power_glow.png", path.."img/combat/icons/icon_Nico_power_glow.png")
Location["combat/icons/icon_Nico_power_glow.png"] = Point(-12,12)

modApi:appendAsset("img/combat/icons/icon_Nico_smoke_glow.png", path.."img/combat/icons/icon_Nico_smoke_glow.png")
Location["combat/icons/icon_Nico_smoke_glow.png"] = Point(-20,12)
-- create a weapon based on Punchmech's Prime Punch.
-- using the new function creates a copy of an existing table,
-- and will use the variables and  function from it, unless we specify new values.
	-- adding upgrades for your weapon can be a fun part.
	-- their names would be Weapon_Template_A, Weapon_Template_B and Weapon_Template_AB (combined)
	-- since we haven't made them yet, we set upgrades to 0 to avoid crashing the game.
-- If we want our weapon to not have a base, we usually base it on Skill - the base for all weapons.
Leaper_Talons = LeaperAtk1:new{
	Name = "Titanite Talons",
	Class="TechnoVek",
	Description = "Slice an adjacent tile, greatly damaging and flipping it, then move away one tile.",
    Icon = "weapons/enemy_leaper2.png", -- notice how the game starts looking in /img/
	Damage = 3,
	--Push=1,
	Fire = false,
	TwoClick = true,
	SoundBase = "/enemy/leaper_2",
	PowerCost=0,
	Upgrades=2,
	UpgradeCost = { 2 , 2 },
	UpgradeList = { "Ignite",  "+1 Damage"  },
	TipImage = {
		Unit = Point(2,3),
		Enemy1 = Point(2,2),
		Building1 = Point(2,0),
		Queued1 = Point(2,1),
		Target = Point(2,2),
		Second_Click = Point(3,3),
		CustomEnemy = "Firefly2",
		CustomPawn = "Nico_Techno_Leaper",
	}
}
function Leaper_Talons:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local direction = GetDirection(p2 - p1)

	local damage = SpaceDamage(p2,self.Damage,DIR_FLIP)
	damage.sSound="/weapons/sword"
	damage.sAnimation="SwipeClaw2"
	damage.bKO_Effect = false
	Global_Nico_Move_Speed = 1
	if self.Fire then
		damage.sImageMark ="combat/icons/icon_fire_glow.png"
		damage.iFire = 1
		if Board:IsDeadly(damage,Pawn) then
			damage.bKO_Effect = true
			local dam_dealt = self.Damage
			local dpawn = Board:GetPawn(p2)
			local health = dpawn:GetHealth()
			if Board:GetPawn(p1):IsBoosted() then dam_dealt = dam_dealt + 1 end
			if dpawn:IsArmor() and not dpawn:IsAcid() then dam_dealt = dam_dealt - 1 end
			if dpawn:IsAcid() then dam_dealt = dam_dealt*2 end
			Global_Nico_Move_Speed = dam_dealt - health + 1
		end
		damage.bKO_Effect = false
	end
	ret:AddBounce(p2,3)
	ret:AddMelee(p2 - DIR_VECTORS[direction], damage)

	--This section of code is custom flip for Firefly Leader and Junebug Leader
	--Note that it has not been conditioned to check that the Leaders still exist
	local Mirror = false
	if Board:IsPawnSpace(p2) and (Board:GetPawn(p2):GetType() == "FireflyBoss" or Board:GetPawn(p2):GetType() == "DNT_JunebugBoss") and Board:GetPawn(p2):IsQueued()then
		Mirror = true
	end
	
	if Mirror then
		local threat = Board:GetPawn(p2):GetQueuedTarget()
		local flip = (GetDirection(threat - p2)+1)%4
		local newthreat = p2 + DIR_VECTORS[flip]
		if not Board:IsValid(newthreat) then
			newthreat = p2 - DIR_VECTORS[flip]
		end
		ret:AddScript("Board:GetPawn("..p2:GetString().."):SetQueuedTarget("..newthreat:GetString()..")")
	end

	if (self.Damage==4 or Board:GetPawn(p1):IsBoosted()) and Board:IsPawnSpace(p2) then
		if Board:GetPawnTeam(p2) == TEAM_ENEMY and Board:GetPawn(p2):IsAcid() then
			ret:AddScript("Nico_Techno_Veks2squad_Chievo('Nico_Techno_Leaper')")
		end
	end
	return ret
end

function Leaper_Talons:GetSecondTargetArea(p1, p2)
	if (Global_Nico_Move_Speed == nil or Global_Nico_Move_Speed < 1)  then Global_Nico_Move_Speed = 1 end
	local ret = PointList()
	if Board:GetPawn(p1):GetType() == "Nico_Techno_Leaper" then
		ret = Board:GetReachable(p1, Global_Nico_Move_Speed, 1)
		local i = 1
		while i <= ret:size() do
			if Board:IsTerrain(ret:index(i),TERRAIN_HOLE) or ret:index(i) == p2 then
				ret:erase(i)
				i = i - 1
			end
			i = i + 1
		end
	else
		ret = Board:GetReachable(p1, Global_Nico_Move_Speed, Board:GetPawn(p1):GetPathProf())
		local i = 1
		while i <= ret:size() do
			if ret:index(i) == p2 then
				ret:erase(i)
				i = i - 1
			end
			i = i + 1
		end
	end
	ret:push_back(p1)
	return ret
end

function Leaper_Talons:IsTwoClickException(p1,p2)
	local second_area = self:GetSecondTargetArea(p1,p2)
	if second_area:size() == 1 then
		return true
	end
	return false
end

function Leaper_Talons:GetFinalEffect(p1, p2, p3)--copied from Control Shot since it's the same thing
	local ret = self:GetSkillEffect(p1, p2)
	if p1 == p3 then return ret end
	local target_pawn = Board:GetPawn(p1)
	if target_pawn:GetType() == "Nico_Techno_Leaper" then
		local move = PointList()
		move:push_back(p1)
		move:push_back(p3)

		ret:AddSound("/enemy/leaper_1/move")

		ret:AddLeap(move,FULL_DELAY)
		ret:AddBounce(p3, 1)

		ret:AddSound("/enemy/leaper_1/land")
	elseif target_pawn:IsJumper() then
		ret:AddLeap(Board:GetPath(p1, p3, target_pawn:GetPathProf()),FULL_DELAY)
	elseif target_pawn:IsBurrower() then
		ret:AddBurrow(Board:GetPath(p1, p3, target_pawn:GetPathProf()),FULL_DELAY)
	else
		ret:AddMove(Board:GetPath(p1, p3, target_pawn:GetPathProf()), FULL_DELAY)
	end
	return ret
end

Leaper_Talons_A= Leaper_Talons:new{
	Fire=true,
	UpgradeDescription = "Light the target on fire. If the target is killed, gain bonus movement equal to excess damage dealt.",
	TipImage = {
		Unit = Point(2,3),
		Enemy1 = Point(2,2),
		Building1 = Point(2,0),
		Queued1 = Point(2,1),
		Target = Point(2,2),
		Second_Click = Point(3,3),
		CustomEnemy = "Firefly2",
		CustomPawn = "Nico_Techno_Leaper",
	}
}
Leaper_Talons_B= Leaper_Talons:new{
	Damage = 4,
	UpgradeDescription = "Increases damage by 1.",
}
Leaper_Talons_AB=Leaper_Talons_B:new{
	Fire=true,
	CustomTipImage = "Leaper_Talons_Tip",
}

Leaper_Talons_Tip = Leaper_Talons:new{
	Class = "TechnoVek",
	Fire=true,
	TipImage = {
		Unit = Point(3,2),
		Enemy1 = Point(2,2),
		Building1 = Point(2,0),
		Queued1 = Point(2,1),
		Target = Point(2,2),
		Second_Click = Point(3,3),
		CustomEnemy = "FireflyBoss",
		CustomPawn = "Nico_Techno_Leaper",
	}
}

function Leaper_Talons_Tip:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	ret.piOrigin = Point(3,2)
	local damage = SpaceDamage(p2,4,DIR_FLIP)
	damage.sAnimation="SwipeClaw2"
	if self.Fire then
		damage.sImageMark ="combat/icons/icon_fire_glow.png"
		damage.iFire = 1
	end
	ret:AddMelee(p1, damage)
	ret:AddBounce(p2,3)
	--local damage = SpaceDamage(p2,0)
	--damage.bHide = true
	--damage.sAnimation = "ExploRepulseSmall"--"airpush_"..GetDirection(p2 - p1)
	--ret:AddArtillery(damage,"effects/upshot_confuse.png")
	ret:AddScript("Board:GetPawn("..Point(2,2):GetString().."):SetQueuedTarget("..Point(1,2):GetString()..")")
	return ret
end

Acidic_Vomit=CentipedeAtk1:new{
	Name="Splattering Gunk",
	Class="TechnoVek",
	Description="Fire a damaging projectile that applies A.C.I.D. and flips nearby targets.",
	Icon = "weapons/enemy_firefly2.png",
	Damage=1,
	Acid=EFFECT_CREATE,
	Spill = false,
	BuildingDamage=true,
	PowerCost=0,
	Upgrades=2,
	UpgradeCost={1,3},
	UpgradeList = { "Building Chain",  "Spill, Melt"},
	LaunchSound="/weapons/acid_shot",
	ImpactSound = "/impact/dynamic/enemy_projectile",
	Projectile = "effects/shot_firefly2",
	Explosion = "",--ExploFirefly2",
	TipImage = {
		Unit = Point(2,3),
		Enemy1 = Point(2,1),
		Building1 = Point(1,1),
		Building2 = Point(3,1),
		Queued1 = Point(2,2),
		Target = Point(2,2),
		CustomEnemy = "Firefly1",
		CustomPawn = "Nico_Techno_Centipede",
	}
}
function Acidic_Vomit:GetTargetArea(p1)
	local ret = PointList()
	for dir = DIR_START, DIR_END do
		for i = 1, 8 do
			local curr = Point(p1 + DIR_VECTORS[dir] * i)
			ret:push_back(curr)
			if Board:IsBlocked(curr,PATH_PROJECTILE) or not Board:IsValid(curr) then
				break
			end
		end
	end
	return ret
end
function Acidic_Vomit:DamageCalc(p1,p2,p3)
	local dir = GetDirection(p2 - p1)
    local target = GetProjectileEnd(p1,p2)
	local dam = SpaceDamage(p3,1)
	dam.iAcid = 1
	dam.sAnimation = "Splash_acid"
	target = GetProjectileEnd(p1,p2)
	if (p3 == target + DIR_VECTORS[(dir - 1)% 4]) or (p3 == target) or (p3 == target + DIR_VECTORS[(dir + 1)% 4]) then
		if self.Spill and ((Board:IsAcid(p3) and Board:GetTerrain(p3) ~= TERRAIN_ICE and Board:GetTerrain(p3) ~= TERRAIN_WATER and (not Board:IsCracked(p3)) and (not Board:IsBuilding(p3))) or (Board:IsPawnSpace(p3) and Board:GetPawn(p3):GetType() == "AcidVat")) then
			dam.iAcid = 0
			dam.iDamage = 0
			dam.iTerrain = TERRAIN_WATER
			dam.sImageMark = "combat/icons/icon_Nico_acid_water.png"
		else
			dam.iPush = DIR_FLIP
		end
		if not self.BuildingDamage then
			if Board:IsBuilding(p3) then dam.iDamage = 0 end
		end
	else
		if Board:IsAcid(p3) and Board:GetTerrain(p3) ~= TERRAIN_ICE and Board:GetTerrain(p3) ~= TERRAIN_WATER and (not Board:IsCracked(p3)) and Board:GetTerrain(p3) ~= TERRAIN_HOLE then
			dam.iDamage = 0
			dam.iAcid = 0
			dam.iTerrain = TERRAIN_WATER
			dam.sImageMark = "combat/icons/icon_Nico_acid_water.png"
		end
	end
	return dam
end
function Acidic_Vomit:GetSkillEffect(p1,p2)
    local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
    local target = GetProjectileEnd(p1,p2)
	local damaged_squares = {}--store all squares that have been damaged and exclude them from Building Chain
	local mirror_squares = {}--store all Firefly Leaders and Junebug Leader squares
	
	for j = 1,3 do
		local position = target + DIR_VECTORS[(dir + 1)% 4]*((j%3)-1)-- this is a small case so (j%3)-1 works, but if you wanted to make a centipede cannon that devastates all tiles perpendicular, use (-1)^j * (j//2) and run for j = 0,15
		damaged_squares[#damaged_squares+1] = position
		if position == target then
			ret:AddProjectile(self:DamageCalc(p1,p2,position),self.Projectile)
		else
			ret:AddDamage(self:DamageCalc(p1,p2,position))
		end
		if Board:IsPawnSpace(position) and (Board:GetPawn(position):GetType() == "FireflyBoss" or Board:GetPawn(position):GetType() == "DNT_JunebugBoss") and Board:GetPawn(position):IsQueued() then
			mirror_squares[#mirror_squares+1] = position
		end
	end
	
	if self.Spill then
		local curr = p1 + DIR_VECTORS[dir]
		while curr ~= target do
			damaged_squares[#damaged_squares+1] = curr
			ret:AddDamage(self:DamageCalc(p1,p2,curr))
			curr = curr + DIR_VECTORS[dir]
		end
	end
	
	if not self.BuildingDamage then-- this part is based off of Cascading Resonator and calculates what squares to chain to and what undamaged squares to damage
	-- The logic gets very unwieldy if I try to include this case in the DamageCalc function so I didn't try to merge them - Paradoxica
		local future = {target, target + DIR_VECTORS[(dir + 1)% 4], target + DIR_VECTORS[(dir - 1)% 4]}
		local explored = {target}
		
		while true do
			if #future == 0 then
				break
			end
			
			local curr = pop_back(future)
			local damage = SpaceDamage(curr,1,DIR_FLIP)
			damage.iAcid = 1
			damage.sAnimation = "Splash_acid"
			if Board:IsBuilding(curr) then
				damage.iDamage = 0
				for direc = DIR_START, DIR_END do
					local n = curr + DIR_VECTORS[direc]
					if not list_contains(explored, n) then
						explored[#explored+1] = n
						future[#future+1] = n
					end
				end
			end
			local empty_acid_flag = Board:IsAcid(curr) and (Board:GetTerrain(curr) ~= TERRAIN_ICE and Board:GetTerrain(curr) ~= TERRAIN_WATER and (not Board:IsCracked(curr)) and Board:GetTerrain(curr) ~= TERRAIN_HOLE and not Board:IsBlocked(curr,PATH_MASSIVE))
			local acid_vat_flag = Board:IsPawnSpace(curr) and Board:GetPawn(curr):GetType() == "AcidVat"
			if self.Spill and (empty_acid_flag or acid_vat_flag) then
				damage = SpaceDamage(curr,0)
				damage.iTerrain = TERRAIN_WATER
				damage.sImageMark = "combat/icons/icon_Nico_acid_water.png"
			end
			if (curr ~= p1 and not list_contains(damaged_squares, curr)) then
				ret:AddDamage(damage)
				if Board:IsPawnSpace(curr) and (Board:GetPawn(curr):GetType() == "FireflyBoss" or Board:GetPawn(curr):GetType() == "DNT_JunebugBoss") and Board:GetPawn(curr):IsQueued() then
					mirror_squares[#mirror_squares+1] = curr
				end
			end
			ret:AddDelay(0.05)
			ret:AddBounce(curr,3)
		end
	end
	
	--This section of code is custom flip for Firefly Leader and Junebug Leader
	--Note that it has not been conditioned to check that the Leaders still exist
	for val = 1, #mirror_squares do
		local curr = mirror_squares[val]
		local threat = Board:GetPawn(curr):GetQueuedTarget()
		local flip = (GetDirection(threat - curr)+1)%4
		local newthreat = curr + DIR_VECTORS[flip]
		if not Board:IsValid(newthreat) then
			newthreat = curr - DIR_VECTORS[flip]
		end
		ret:AddScript("Board:GetPawn("..curr:GetString().."):SetQueuedTarget("..newthreat:GetString()..")")
	end
	
    return ret
end
Acidic_Vomit_A=Acidic_Vomit:new{
	BuildingDamage=false,
	UpgradeDescription = "Chains through buildings instead of damaging them, damaging, flipping and applying A.C.I.D. to adjacent squares.",
}
Acidic_Vomit_B=Acidic_Vomit:new{
	Spill = true,
	UpgradeDescription = "Applies damaging A.C.I.D. on all tiles it passes through, and melts tiles with A.C.I.D. on them.",
	TipImage = {
		Unit = Point(2,4),
		Enemy1 = Point(2,0),
		Building1 = Point(1,0),
		Building2 = Point(3,0),
		Queued1 = Point(2,1),
		Target = Point(2,3),
		Second_Origin = Point(2,4),
		Second_Target = Point(2,3),
		CustomEnemy = "Firefly1",
		CustomPawn = "Nico_Techno_Centipede",
	}
}
Acidic_Vomit_AB=Acidic_Vomit_A:new{
	Spill = true,
	TipImage = {
		Unit = Point(2,4),
		Enemy1 = Point(2,0),
		Building1 = Point(1,0),
		Building2 = Point(3,0),
		Queued1 = Point(2,1),
		Target = Point(2,3),
		Second_Origin = Point(2,4),
		Second_Target = Point(2,3),
		CustomEnemy = "Firefly1",
		CustomPawn = "Nico_Techno_Centipede",
	}
}
ANIMS.Radio_Burst = Animation:new{
    Image = "combat/icons/radio_animate.png",
    PosX = -16, PosY = -8,
    NumFrames = 3,
    Time = 0.15,
    Loop = false
}
modApi:appendAsset("img/weapons/Psion_weapon.png", path .."img/weapons/Psion_weapon.png")
Tentacle_attack=Ranged_Artillerymech:new{
	Name="Psionic Transmitter",
	Class="TechnoVek",
	Description="Remotely damage and crack a tile, pushing adjacent tiles. Doesn't damage buildings.",
	Icon="weapons/Psion_weapon.png",
	Damage=1,
	BuildingDamage=false,
	PowerCost=0,
	Upgrades=2,
	UpgradeCost={2,2},
	UpgradeList={"Melt, Flip","+1 Damage, Heal Ally"},
	UpShot="",
	LaunchSound = "/weapons/arachnoid_ko",
	ExplosionCenter="Radio_Burst",
	Heal = false,
	Lava = false,
	TipImage = {
		Unit = Point(2,3),
		Second_Origin=Point(2,3),
		Enemy = Point(2,2),
		Building = Point(2,1),
		Target = Point(2,2),
		Second_Target=Point(2,1),
		CustomPawn = "Nico_Techno_Psion",
	}
}
function Tentacle_attack:GetTargetArea(p1)
	local ret = PointList()

	for dir = DIR_START, DIR_END do
		for i = 1, self.ArtillerySize do
			local curr = p1 + DIR_VECTORS[dir] * i
			if not Board:IsValid(curr) then
				break
			end
			ret:push_back(curr)
		end
	end
	return ret
end
function Tentacle_attack:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local radio=SpaceDamage(p1,0)--this is the animation that plays on the head of the shooter
	radio.sAnimation="Radio_Burst"
	radio.sSound="/mech/prime/punch_mech/"--the sound of a mech walking, to lure The Hive
	ret:AddBounce(p1, 1)
	ret:AddDamage(radio)
	local damage = SpaceDamage(p2,0)
	damage.sAnimation = self.ExplosionCenter
	damage.bHide=true
	ret:AddDelay(0.25)
	ret:AddDamage(damage)
	local Tanim1 = SpaceDamage(p2,0)--the tentacles attacking from the front
	local Tanim2 = SpaceDamage(p2,0)--the tentacles attacking from the back
	Tanim2.sAnimation ="PsionAttack_Back"

	ret:AddDelay(0.25)
	ret:AddBounce(p2,3)
	
	if self.Lava and Board:IsCrackable(p1) then--Make it only affect tiles that Flood Drill would also affect for consistency
		local slava=SpaceDamage(p1,0)
		slava.sImageMark = "combat/icons/icon_Nico_lava.png"
		slava.iTerrain = TERRAIN_LAVA
		ret:AddDamage(slava)
	end

	if self.Heal and Board:GetPawnTeam(p2) == TEAM_PLAYER then
		Tanim2.iDamage=-1--heals allies
		Tanim1.sAnimation ="PsionAttack_Front"
		ret:AddDamage(Tanim1)
		ret:AddDamage(Tanim2)
	elseif Board:IsBuilding(p2) then-- Target Buildings -
		Tanim1.iDamage = 0--doesn't damage buildings
		ret:AddDamage(Tanim1)
		ret:AddDamage(Tanim2)
	elseif Board:IsCrackable(p2) then --makes cracks
		Tanim1.iDamage=self.Damage--harms enemies
		Tanim1.sAnimation ="PsionAttack_Front"
		Tanim1.iCrack = EFFECT_CREATE
		ret:AddDamage(Tanim2)
		ret:AddDamage(Tanim1)
	else
		Tanim1.iDamage=self.Damage--harms enemies
		Tanim1.sAnimation ="PsionAttack_Front"
		ret:AddDamage(Tanim1)
		ret:AddDamage(Tanim2)
	end

	if self.BounceAmount ~= 0 then	ret:AddBounce(p2, self.BounceAmount) end

	for dir = 0, 3 do
		damage = SpaceDamage(p2 + DIR_VECTORS[dir],  self.DamageOuter)

		if self.Push == 1 then
			damage.iPush = dir
		end
		damage.sAnimation = self.OuterAnimation..dir

		if not self.BuildingDamage and Board:IsBuilding(p2 + DIR_VECTORS[dir]) then
			damage.iDamage = 0
			damage.sAnimation = "airpush_"..dir
		end

		ret:AddDamage(damage)
		if self.BounceOuterAmount ~= 0 then	ret:AddBounce(p2 + DIR_VECTORS[dir], self.BounceOuterAmount) end
	end

	return ret
end
Tentacle_attack_A=Tentacle_attack:new{
	TwoClick = true,
	Lava = true,
	UpgradeDescription = "Melts tile under self into lava, and fire a second non-pushing shot that flips in a different direction.",
	TipImage={
		Unit = Point(2,2),
		Mountain = Point(0,2),
		Enemy1 = Point(2,0),
		Queued1 = Point(2,1),
		Target = Point(0,2),
		Second_Click=Point(2,0),
		CustomEnemy = "Firefly1",
		CustomPawn = "Nico_Techno_Psion",
	}
}
function Tentacle_attack_A:GetSecondTargetArea(p1,p2)
	local ret = PointList()
	dir = GetDirection(p2-p1)
	for j = 1, 3 do
		for i = 1, self.ArtillerySize do
			local curr = p1 + DIR_VECTORS[(dir+j)%4] * i
			if Board:IsValid(curr) and (not Board:IsBuilding(curr)) then
				ret:push_back(curr)
			end
		end
	end
	return ret
end
function Tentacle_attack_A:GetFinalEffect(p1, p2, p3)
	local ret = SkillEffect()

	if Board:IsCrackable(p1) then--Make it only affect tiles that Flood Drill would also affect for consistency
		local slava=SpaceDamage(p1,0)
		slava.sImageMark = "combat/icons/icon_Nico_lava.png"
		slava.iTerrain = TERRAIN_LAVA
		ret:AddDamage(slava)
	end

	local radio=SpaceDamage(p1,0)
	radio.sAnimation="Radio_Burst"
	ret:AddDamage(radio)
	ret:AddDelay(0.15)
	local damage = SpaceDamage(p2,0)
	damage.sAnimation = self.ExplosionCenter
	damage.bHide=true
	ret:AddDamage(damage)
	ret:AddDelay(0.15)
	ret:AddBounce(p2,3)
	local damage = SpaceDamage(p3,0)
	damage.sAnimation = self.ExplosionCenter
	damage.bHide=true
	ret:AddDamage(damage)
	ret:AddDelay(0.15)
	ret:AddBounce(p3,3)
	
	local Tanim1 = SpaceDamage(p2,0)
	local Tanim2 = SpaceDamage(p2,0)
	Tanim2.sAnimation ="PsionAttack_Back"
	
	if self.Heal and Board:GetPawnTeam(p2) == TEAM_PLAYER then
		Tanim2.iDamage=-1--heals allies
		Tanim1.sAnimation ="PsionAttack_Front"
		ret:AddDamage(Tanim1)
		ret:AddDamage(Tanim2)
	elseif Board:IsBuilding(p2) then-- Target Buildings -
		ret:AddDamage(Tanim1)--doesn't damage buildings
		Tanim2.bHide=true
		ret:AddDamage(Tanim2)
	elseif Board:IsCrackable(p2) and Board:IsCracked(p2)~=true then 
		Tanim1.iDamage=self.Damage--harms enemies
		Tanim1.sAnimation ="PsionAttack_Front"
		Tanim1.iCrack = EFFECT_CREATE--makes cracks
		ret:AddDamage(Tanim2)
		ret:AddDamage(Tanim1)
	else
		Tanim1.iDamage=self.Damage--harms enemies
		Tanim1.sAnimation ="PsionAttack_Front"
		ret:AddDamage(Tanim1)
		ret:AddDamage(Tanim2)
	end

	if self.BounceAmount ~= 0 then	ret:AddBounce(p2, self.BounceAmount) end

	for dir = 0, 3 do
		damage = SpaceDamage(p2 + DIR_VECTORS[dir],  self.DamageOuter)

		if self.Push == 1 then
			damage.iPush = dir
		end
		damage.sAnimation = self.OuterAnimation..dir

		if not self.BuildingDamage and Board:IsBuilding(p2 + DIR_VECTORS[dir]) then
			damage.iDamage = 0
			damage.sAnimation = "airpush_"..dir
		end

		ret:AddDamage(damage)
		if self.BounceOuterAmount ~= 0 then	ret:AddBounce(p2 + DIR_VECTORS[dir], self.BounceOuterAmount) end
	end

	local Tanim3 = SpaceDamage(p3,0,DIR_FLIP)
	local Tanim2 = SpaceDamage(p3,0)
	Tanim2.sAnimation ="PsionAttack_Back"

	if self.Heal and Board:GetPawnTeam(p3) == TEAM_PLAYER then
		Tanim3.iDamage=-1--heals allies
		Tanim3.sAnimation ="PsionAttack_Front"
		ret:AddDamage(Tanim3)
		ret:AddDamage(Tanim2)
	elseif Board:IsBuilding(p3) then-- Target Buildings -
		Tanim3.iDamage = 0--doesn't damage buildings
		ret:AddDamage(Tanim3)
		ret:AddDamage(Tanim2)
	else
		Tanim3.iDamage=self.Damage--harms enemies
		Tanim3.sAnimation ="PsionAttack_Front"
		ret:AddDamage(Tanim3)
		ret:AddDamage(Tanim2)
	end

	if self.BounceAmount ~= 0 then	ret:AddBounce(p3, self.BounceAmount) end

	if Board:IsCrackable(p1) then--Make it only affect tiles that Flood Drill would also affect for consistency
		local slava=SpaceDamage(p1,0)
		slava.sImageMark = "combat/icons/icon_Nico_lava.png"
		slava.iTerrain = TERRAIN_LAVA
		ret:AddDamage(slava)
	end
	
	--This section of code is custom flip for Firefly Leader and Junebug Leader
	--Note that it has not been conditioned to check that the Leaders still exist
	local Mirror = false
	if Board:IsPawnSpace(p3) and (Board:GetPawn(p3):GetType() == "FireflyBoss" or Board:GetPawn(p3):GetType() == "DNT_JunebugBoss") and Board:GetPawn(p3):IsQueued()then
		Mirror = true
	end
	
	if Mirror then
		local threat = Board:GetPawn(p3):GetQueuedTarget()
		local flip = (GetDirection(threat - p3)+1)%4
		local newthreat = p3 + DIR_VECTORS[flip]
		if not Board:IsValid(newthreat) then
			newthreat = p3 - DIR_VECTORS[flip]
		end
		ret:AddScript("Board:GetPawn("..p3:GetString().."):SetQueuedTarget("..newthreat:GetString()..")")
	end

	return ret
end
Tentacle_attack_B=Tentacle_attack:new{
	Damage=2,
	Heal=true,
	UpgradeDescription="Increases damage to enemies by 1 and heals allies instead of damaging.",
	TipImage = {
		Unit = Point(2,4),
		Second_Origin=Point(2,4),
		Enemy = Point(2,0),
		Target = Point(2,2),
		Second_Target=Point(2,0),
		Friendly_Damaged = Point(2,2),
		CustomPawn = "Nico_Techno_Psion",
		Length = 5,
	},
}
Tentacle_attack_AB=Tentacle_attack_A:new{
	Damage=2,
	TwoClick = true,
	Heal=true,
	Lava = true,
	TipImage = {
		Unit = Point(2,2),
		Friendly_Damaged = Point(0,2),
		Enemy1 = Point(2,0),
		Queued1 = Point(2,1),
		Target = Point(0,2),
		Second_Click=Point(2,0),
		CustomEnemy = "Firefly1",
		CustomPawn = "Nico_Techno_Psion",
	}
}
Passive_Psions=Passive_Psions:new{
	Name="Psionic Receiver",
	Class="TechnoVek",
	Description="Mechs use bonuses from Vek Psion.",
	Icon = "weapons/passives/passive_psions.png",
	Passive = "Psion_Leech",
	TipImage = {
		Unit = Point(2,2),
		Enemy = Point(2,1),
		CustomEnemy = "Jelly_Health1",
	}
}

modApi:appendAsset("img/weapons/Shield_weapon.png", path .."img/weapons/Shield_weapon.png")
Shield_attack=Tentacle_attack:new{
	Name="Psionic Projector",
	Class="TechnoVek",
	Description="Remotely target a tile, pushing adjacent tiles. Shields Buildings and allied units.",
	Icon="weapons/Shield_weapon.png",
	Damage=0,
	DoDamage=false,
	ReAct=false,
	PowerCost=0,
	ExplosionCenter="Radio_Burst",
	Upgrades=1,
	UpgradeCost={3},
	UpgradeList={"OverCharge","+2 damage"},
	UpShot="",
	LaunchSound = "/weapons/arachnoid_ko",
	ExplosionCenter="Radio_Burst",
	TipImage = {
		Unit = Point(2,0),
		Enemy = Point(3,2),
		Building = Point(2,2),
		Target = Point(2,2),
		CustomPawn = "Nico_Techno_Shield",
	}
}
function Shield_attack:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local radio=SpaceDamage(p1,0)--this is the animation that plays on the head of the shooter
	radio.iShield=1
	radio.sAnimation="Radio_Burst"
	ret:AddBounce(p1, 1)
	ret:AddDamage(radio)
	local damage = SpaceDamage(p2,0)
	damage.sAnimation = self.ExplosionCenter
	damage.bHide=true
	ret:AddDelay(0.25)
	ret:AddDamage(damage)
	local damage = SpaceDamage(p2,0)
	ret:AddDelay(0.25)
	local tpawn = Board:GetPawn(p2)

	if Board:GetPawnTeam(p2) == TEAM_PLAYER and self.ReAct and not tpawn:IsActive() then
		damage.iShield=1
		damage.bHide=true
		damage.sImageMark="icon_Nico_power_glow.png"
		ret:AddScript(string.format("Board:GetPawn(%s):SetActive(true)", p2:GetString()))
        ret:AddScript(string.format("Board:GetPawn(%s):SetMovementSpent(false)", p2:GetString()))
		ret:AddScript(string.format("Board:Ping(%s,GL_Color(0,255,0))", p2:GetString())) -- cool animation
		ret:AddDamage(damage)
	elseif Board:GetPawnTeam(p2) == TEAM_PLAYER or Board:IsBuilding(p2) then
		damage.iShield=1
		damage.sImageMark="icon_Nico_shield_glow.png"
		ret:AddDamage(damage)
	elseif self.DoDamage then
		damage.iShield=0
		damage.iDamage=self.Damage
		ret:AddDamage(damage)
	else
		damage.iShield=1
		damage.sImageMark="icon_Nico_shield_glow.png"
		ret:AddDamage(damage)
	end
	if self.BounceAmount ~= 0 then	ret:AddBounce(p2, self.BounceAmount) end

	for dir = 0, 3 do
		damage = SpaceDamage(p2 + DIR_VECTORS[dir],  self.DamageOuter)

		if self.Push == 1 then
			damage.iPush = dir
		end
		damage.sAnimation = self.OuterAnimation..dir

		if not self.BuildingDamage and Board:IsBuilding(p2 + DIR_VECTORS[dir]) then
			damage.iDamage = 0
			damage.sAnimation = "airpush_"..dir
		end

		ret:AddDamage(damage)
		if self.BounceOuterAmount ~= 0 then	ret:AddBounce(p2 + DIR_VECTORS[dir], self.BounceOuterAmount) end
	end
	if self.ShieldAd then
		for i = DIR_START, DIR_END do
			damage.iShield=1
			damage.loc = p1 + DIR_VECTORS[i]
			ret:AddDamage(damage)
		end
	end
	return ret
end

Shield_attack_A=Shield_attack:new{
	UpgradeDescription="If the unit is an ally, reactivates it if it has already acted.",
	ReAct=true,
	TipImage = {
		Unit = Point(2,4),
		Second_Origin=Point(2,4),
		Enemy = Point(2,0),
		Target = Point(2,2),
		Second_Target=Point(2,0),
		Friendly = Point(2,2),
		Length = 5,
	},
}

Shield_attack_B=Shield_attack:new{
	DoDamage=true,
	UpgradeDescription = "Does 2 damage to a target if it's not an ally unit or a building instead of shielding",
	Damage=2,
	TipImage = {
		Unit = Point(2,4),
		Second_Origin=Point(2,4),
		Enemy = Point(2,0),
		Target = Point(2,2),
		Second_Target=Point(2,0),
		Friendly = Point(2,2),
		Length = 5,
	},
}
