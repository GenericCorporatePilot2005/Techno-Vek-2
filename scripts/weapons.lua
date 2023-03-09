-- this line just gets the file path for your mod, so you can find all your files easily.
local path = mod_loader.mods[modApi.currentMod].resourcePath

-- add assets from our mod so the game can find them.

local scriptPath = mod_loader.mods[modApi.currentMod].resourcePath

modApi:appendAsset("img/combat/icons/icon_Nico_lava.png", path.."img/combat/icons/icon_Nico_lava.png")
Location["combat/icons/icon_Nico_lava.png"] = Point(-12,12)

modApi:appendAsset("img/combat/icons/icon_Nico_shield_glow.png", path.."img/combat/icons/icon_Nico_shield_glow.png")
Location["combat/icons/icon_Nico_shield_glow.png"] = Point(-12,12)
modApi:appendAsset("img/combat/icons/icon_Nico_shield_miss.png", path.."img/combat/icons/icon_Nico_shield_miss.png")
Location["combat/icons/icon_Nico_shield_miss.png"] = Point(-12,12)

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
	Description = "Slice an adjacent tile, greatly damaging and pushing it.",
    Icon = "weapons/enemy_leaper2.png", -- notice how the game starts looking in /img/
	Damage = 3,
	Push=1,
	Smoke = false,
	SoundBase = "/enemy/leaper_2",
	PowerCost=0,
	Upgrades=2,
	UpgradeCost = { 2 , 3 },
	UpgradeList = { "Smoke",  "+2 Damage"  },
	TipImage = {
		Unit = Point(2,2),
		Enemy = Point(2,1),
		Target = Point(2,1),
		CustomPawn = "Nico_Techno_Leaper",
	}
}
function Leaper_Talons:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local direction = GetDirection(p2 - p1)

	local damage = SpaceDamage(p2,self.Damage,direction)
	damage.sSound="/weapons/sword"
	damage.sAnimation="SwipeClaw2"

	if self.Smoke then
		damage.sImageMark ="combat/icons/icon_Nico_smoke_glow.png"
		local push=SpaceDamage(p2,0)
		push.iSmoke = 1
		push.sAnimation = "airpush_"..direction
		ret:AddDamage(push)
		ret:AddDelay(0.40)
		ret:AddBounce(p2,3)
		ret:AddMelee(p2-DIR_VECTORS[direction],damage)
	else
		damage.loc = p2
		ret:AddBounce(p2,3)
		ret:AddMelee(p2 - DIR_VECTORS[direction], damage)
	end

	if self.Damage==5 and Board:IsPawnSpace(p2) then
		if Board:GetPawnTeam(p2) == TEAM_ENEMY and Board:GetPawn(p2):IsAcid() then
			ret:AddScript("Nico_Techno_Veks2squad_Chievo('Nico_Techno_Leaper')")
		end
	end
	return ret
end
Leaper_Talons_A= Leaper_Talons:new{
	Smoke=true,
	UpgradeDescription = "Smokes the target before slicing it.",
	TipImage = {
		Unit = Point(1,2),
		Enemy1 = Point(1,1),
		Target = Point(1,1),
		Queued1 = Point(2,1),
		Friendly = Point(3,1),
		CustomEnemy = "Firefly2",
		CustomPawn = "Nico_Techno_Leaper",
		Length = 4,
	}

}
Leaper_Talons_B= Leaper_Talons:new{
	Damage = 5,
	UpgradeDescription = "Increases damage by 2.",
	TipImage = {
		Unit = Point(2,2),
		Enemy = Point(2,1),
		Target = Point(2,1),
		CustomPawn = "Nico_Techno_Leaper",
	}
}
Leaper_Talons_AB=Leaper_Talons:new{
	Damage = 5,
	Smoke=true,
	TipImage = {
		Unit = Point(1,2),
		Enemy1 = Point(1,1),
		Target = Point(1,1),
		Queued1 = Point(2,1),
		Friendly = Point(3,1),
		CustomEnemy = "Firefly2",
		CustomPawn = "Nico_Techno_Leaper",
		Length = 4,
	}
}
Acidic_Vomit=CentipedeAtk1:new{
	Name="Splattering Gunk",
	Class="TechnoVek",
	Description="Fire a damaging projectile that applies A.C.I.D. to nearby targets.",
	Icon = "weapons/enemy_firefly2.png",
	Damage=1,
	Acid=EFFECT_CREATE,
	Bacid=false,
	Bpush=false,
	BuildingDamage=true,
	PowerCost=0,
	Upgrades=2,
	UpgradeCost={1,3},
	UpgradeList = { "Pull",  "+1 Damage, Leak"},
	LaunchSound="/weapons/acid_shot",
	ImpactSound = "/impact/dynamic/enemy_projectile",
	Projectile = "effects/shot_firefly2",
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,1),
		Target = Point(2,2),
		CustomPawn = "Nico_Techno_Centipede",
	}
}
function Acidic_Vomit:GetTargetArea(p1)

	local ret = PointList()

	for dir = DIR_START, DIR_END do
		for i = 1, 8 do
			local curr = Point(p1 + DIR_VECTORS[dir] * i)
			if not Board:IsValid(curr) then
				break
			end

			ret:push_back(curr)
		end
	end

	return ret

end
function Acidic_Vomit:GetSkillEffect(p1,p2)
    local ret = SkillEffect()
    local dir = GetDirection(p2 - p1)
	local altdir=GetDirection(p1-p2)
    local target = GetProjectileEnd(p1,p2)
	local damage1 = SpaceDamage(target, self.Damage)

	if self.Bacid then
		local Bacid = SpaceDamage(p1 - DIR_VECTORS[dir],0)
		Bacid.iAcid = self.Acid
		Bacid.sAnimation="Splash_acid"
		ret:AddDamage(Bacid)
	end

	damage1.iAcid=self.Acid
	damage1.sAnimation="Splash_acid"
	ret:AddBounce(p1,1)
	local damage2 = SpaceDamage(target + DIR_VECTORS[(dir + 1)% 4], self.Damage)
	local damage3 = SpaceDamage(target + DIR_VECTORS[(dir - 1)% 4], self.Damage)
	damage2.iAcid=self.Acid
	damage2.sAnimation="Splash_acid"
	damage3.iAcid=self.Acid
	damage3.sAnimation="Splash_acid"

	ret:AddProjectile(damage1, self.Projectile)
	if self.Bpush then
		damage2.iPush=altdir
		damage3.iPush=altdir
		ret:AddDamage(damage2)
		ret:AddDamage(damage3)
	else
		ret:AddDamage(damage2)
		ret:AddDamage(damage3)
	end
	
    return ret
end
Acidic_Vomit_A=Acidic_Vomit:new{
	Bpush=true,
	BuildingDamage=false,
	UpgradeDescription = "Pulls the outer two targets.",
	TipImage = {
		Unit=Point(2,3),
		Enemy1=Point(2,1),
		Enemy2=Point(3,1),
		Enemy3=Point(1,1),
		Target=Point(2,2),
		CustomPawn="Nico_Techno_Centipede",
	}
}
Acidic_Vomit_B=Acidic_Vomit:new{
	Damage=2,
	Bacid=true,
	UpgradeDescription = "Increases damage by 1, and creates A.C.I.D. behind the mech.",
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,1),
		Target = Point(2,2),
		CustomPawn = "Nico_Techno_Centipede",
	}
}
Acidic_Vomit_AB=Acidic_Vomit:new{
	Damage=2,
	Bacid=true,
	Bpush=true,
	TipImage = {
		Unit=Point(2,3),
		Enemy1=Point(2,1),
		Enemy2=Point(3,1),
		Enemy3=Point(1,1),
		Target=Point(2,2),
		CustomPawn="Nico_Techno_Centipede",
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
	UpgradeList={"Melt","+1 Damage, Heal Ally"},
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
	UpgradeDescription = "Melts tile under self into lava, and fire a second non-pushing shot in a different direction.",
	TipImage={
		Unit = Point(2,2),
		Mountain = Point(0,2),
		Enemy = Point(2,0),
		Target = Point(0,2),
		Second_Click=Point(2,0),
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



	local Tanim3 = SpaceDamage(p3,0)
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
	elseif Board:IsCrackable(p3) then --makes cracks
		Tanim3.iDamage=self.Damage--harms enemies
		Tanim3.sAnimation ="PsionAttack_Front"
		Tanim3.iCrack = EFFECT_CREATE
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
	Length = 5,
	}
}
Tentacle_attack_AB=Tentacle_attack_A:new{
	Damage=2,
	TwoClick = true,
	Heal=true,
	Lava = true,
	TipImage = {
		Unit = Point(2,2),
		Friendly_Damaged = Point(0,2),
		Enemy = Point(2,0),
		Target = Point(0,2),
		Second_Click=Point(2,0),
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
	Name="Psionic Shield Proyector",
	Class="TechnoVek",
	Description="Remotely targets a tile, pushing adjacent tiles. shields buildings and allies.",
	Icon="weapons/Shield_weapon.png",
	Damage=1,
	ShieldAd=false,
	DoDamage=false,
	PowerCost=0,
	Upgrades=0,
	--UpgradeCost={2,2},
	--UpgradeList={"Shield adjacent","hurt enemy"},
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
	radio.sAnimation="Radio_Burst"
	ret:AddBounce(p1, 1)
	ret:AddDamage(radio)
	local damage = SpaceDamage(p2,0)
	ret:AddDelay(0.25)

	if Board:GetPawnTeam(p2) == TEAM_PLAYER or Board:IsBuilding(p2) then
		damage.iShield=1
		damage.sImageMark="icon_Nico_shield_glow.png"
		ret:AddDamage(damage)
	else
		damage.sImageMark="icon_Nico_shield_miss.png"
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

	return ret
end

Shield_attack_A=Tentacle_attack:new{
	UpgradeDescription = "Shields mech, friendly units and buildings that are adjacent to mech.",
	TipImage={
		Unit = Point(2,2),
		Enemy = Point(2,0),
		Target = Point(0,2),
		friendly = Point(3,2),
		Building=Point(1,2),
	}
}