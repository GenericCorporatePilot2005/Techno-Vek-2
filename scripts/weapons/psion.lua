local path = mod_loader.mods[modApi.currentMod].resourcePath
modApi:appendAsset("img/combat/icons/icon_Nico_lava.png", path.."img/combat/icons/icon_Nico_lava.png")
Location["combat/icons/icon_Nico_lava.png"] = Point(-12,12)
modApi:appendAsset("img/weapons/Psion_weapon.png", path .."img/weapons/Psion_weapon.png")
ANIMS.Radio_Burst = Animation:new{
	Image = "combat/icons/radio_animate.png",
	PosX = -16, PosY = -8,
	NumFrames = 3,
	Time = 0.2,
	Loop = false,
}
Tentacle_attack=Skill:new{
	Name="Psionic Transmitter",
	Class="TechnoVek",
	Description="Remotely damage and crack a tile, pushing adjacent tiles. Doesn't damage buildings. If the target is an ally or building, crack adjacent tiles instead.",
	Icon="weapons/Psion_weapon.png",
	Damage=1,
	PowerCost=0,
	Upgrades=2,
	UpgradeCost={2,2},
	UpgradeList={"Melt & Flip","+1 Damage & Heal Ally"},
	LaunchSound = "/weapons/arachnoid_ko",
	ImpactSound = "/impact/generic/explosion",
	TipImage={
		Unit = Point(2,2),
		Second_Origin=Point(2,2),
		Mountain = Point(0,2),
		Enemy1 = Point(2,0),
		Target = Point(0,2),
		Second_Target=Point(2,0),
		CustomPawn = "Nico_Techno_Psion",
	}
}

function Tentacle_attack:GetTargetArea(point)
	local ret = PointList()
	
	for dir = DIR_START, DIR_END do
		for i = 1, 8 do
			local curr = Point(point + DIR_VECTORS[dir] * i)
			if not Board:IsValid(curr) then
				break
			end
			
			if not self.OnlyEmpty or not Board:IsBlocked(curr,PATH_GROUND) then
				ret:push_back(curr)
			end

		end
	end
	
	return ret
end

function Tentacle_attack:GetSkillEffect(p1, p2)	
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	local radio=SpaceDamage(p1,0)
	radio.sAnimation="Radio_Burst"
	radio.sSound=self.LaunchSound
	ret:AddBounce(p1,1)
	ret:AddDamage(radio)
	radio=SpaceDamage(p2,0)
	radio.sAnimation="Radio_Burst"
	ret:AddBounce(p2,2)
	ret:AddDamage(radio)

	local anim1=SpaceDamage(p2)
	anim1.sAnimation="PsionAttack_Front"
	anim1.sSound=self.ImpactSound
	local anim2=SpaceDamage(p2)
	anim2.sAnimation="PsionAttack_Back"
	anim2.bHide=true
	if Board:IsBuilding(p2) then
		anim1.iDamage=DAMAGE_ZERO
	elseif self.Heal and Board:GetPawnTeam(p2) == TEAM_PLAYER then
		anim1.iDamage=-1
	else
		anim1.iDamage=self.Damage
		if Board:IsTerrain(p2,TERRAIN_FOREST) and Board:IsPawnSpace(p2) and not Board:GetPawn(p2):IsShield() and not Board:GetPawn(p2):IsFrozen() then
			anim1.iFire = 1
			anim1.sScript = "modApi:runLater(function() Board:SetFire("..p2:GetString()..",false) end)"
		end
		if Board:IsCrackable(p2) and not Board:IsCracked(p2) then
			anim1.iCrack=EFFECT_CREATE
		elseif Board:GetTerrain(p2) == TERRAIN_HOLE then
			anim1.sAnimation="tentacles"
			anim2.sAnimation=""
		elseif Board:GetTerrain(p2) == TERRAIN_WATER then
			local watereffect=SpaceDamage(p2,0)
			if Board:IsAcid(p2) then
				watereffect.sAnimation="Splash_acid"
			elseif Board:IsTerrain(p2,TERRAIN_LAVA) then
				watereffect.sAnimation="Splash_lava"
			else
				watereffect.sAnimation="Splash"
			end
			ret:AddDamage(watereffect)
		end
	end
	ret:AddDamage(anim1)
	ret:AddDamage(anim2)
	
	for i = DIR_START,DIR_END do
		local curr = p2 + DIR_VECTORS[i]
		local spaceDamage = SpaceDamage(curr, 0, i)
		
		if Board:GetPawnTeam(p2) == TEAM_PLAYER or Board:IsBuilding(p2) then
			spaceDamage.iCrack = 1
		end
		
		spaceDamage.sAnimation = "airpush_"..i
		ret:AddDamage(spaceDamage)
		
		ret:AddBounce(curr,-1)
	end
	return ret
end

modApi:addWeaponDrop("Tentacle_attack")

Tentacle_attack_A=Tentacle_attack:new{
	TwoClick = true,
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
		for i = 1, 8 do
			local curr = p1 + DIR_VECTORS[(dir+j)%4] * i
			if Board:IsValid(curr) and (not Board:IsBuilding(curr)) then
				ret:push_back(curr)
			end
		end
	end
	return ret
end
function Tentacle_attack_A:GetFinalEffect(p1, p2, p3)
	local ret = self:GetSkillEffect(p1,p2)
	dir = GetDirection(p3-p1)
	
	radio=SpaceDamage(p3,0)
	radio.sAnimation="Radio_Burst"
	ret:AddBounce(p3,2)
	ret:AddDamage(radio)

	local anim1=SpaceDamage(p3)
	anim1.sAnimation="PsionAttack_Front"
	local anim2=SpaceDamage(p3)
	anim2.sAnimation="PsionAttack_Back"
	anim2.bHide=true
	if Board:IsBuilding(p3) then
		anim1.iDamage=0
	elseif self.Heal and Board:GetPawnTeam(p3) == TEAM_PLAYER then
		anim1.iDamage=-1
	else
		if Board:GetPawnTeam(p3)==TEAM_ENEMY then
			anim1=SpaceDamage(p3,self.Damage,DIR_FLIP)
		elseif Board:GetTerrain(p3) == TERRAIN_HOLE then
			anim1.sAnimation="tentacles"
			anim2.sAnimation=""
		else
			anim1.iDamage=self.Damage
		end
		if Board:GetTerrain(p3) == TERRAIN_WATER then
			local watereffect=SpaceDamage(p3,0)
			if Board:IsAcid(p3) then
				watereffect.sAnimation="Splash_acid"
			elseif Board:IsTerrain(p3,TERRAIN_LAVA) then
				watereffect.sAnimation="Splash_lava"
			else
				watereffect.sAnimation="Splash"
			end
			ret:AddDamage(watereffect)
		end
	end
	ret:AddDamage(anim1)
	ret:AddDamage(anim2)
	
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

	ret:AddDelay(0.35)
	local lava=SpaceDamage(p1)
	lava.sImageMark="combat/icons/icon_Nico_lava.png"
	lava.iTerrain = TERRAIN_LAVA
	lava.sAnimation="Splash_lava"
	ret:AddBounce(p1,3)
	ret:AddDelay(0.15)
	if Board:IsCrackable(lava.loc) then
		ret:AddDamage(lava)
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
