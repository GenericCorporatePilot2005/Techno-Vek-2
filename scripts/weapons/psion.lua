local path = mod_loader.mods[modApi.currentMod].resourcePath
modApi:appendAsset("img/combat/icons/icon_Nico_lava.png", path.."img/combat/icons/icon_Nico_lava.png")
Location["combat/icons/icon_Nico_lava.png"] = Point(-12,12)
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
	UpgradeList={"Melt & Flip","+1 Damage & Heal Ally"},
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

modApi:addWeaponDrop("Tentacle_attack")

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
		ret:AddBurst(p2,"Emitter_Crack_Start", DIR_NONE)
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
		ret:AddBurst(p2,"Emitter_Crack_Start", DIR_NONE)
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