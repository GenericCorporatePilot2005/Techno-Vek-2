Leaper_Talons = LeaperAtk1:new{
	Name = "Titanite Talons",
	Class="TechnoVek",
	Description = "Slice an adjacent tile, greatly damaging and flipping it, then move away up to one tile.",
    Icon = "weapons/enemy_leaper2.png",
	Damage = 3,
	Fire = false,
	TwoClick = true,
	SoundBase = "/enemy/leaper_2",
	PowerCost=0,
	Upgrades=2,
	UpgradeCost = { 2 , 2 },
	UpgradeList = { "Ignite & Overkill Move",  "Damage & Move"  },
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
modApi:addWeaponDrop("Leaper_Talons")

function Leaper_Talons:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local direction = GetDirection(p2 - p1)

	local damage = SpaceDamage(p2,self.Damage,DIR_FLIP)
	damage.sSound="/weapons/sword"
	damage.sAnimation="SwipeClaw2"
	damage.bKO_Effect = false
	Global_Nico_Move_Speed = (self.Damage == 4 and 2) or 1
	if self.Fire then
		local dpawn = Board:GetPawn(p2)
		if not Board:IsTerrain(damage.loc,TERRAIN_WATER) and Board:IsPawnSpace(damage.loc) or Board:IsTerrain(damage.loc,TERRAIN_WATER) and Board:IsPawnSpace(damage.loc) and dpawn:IsFlying() then
			damage.sImageMark = "combat/icons/Nico_icon_swap_fire_glowA.png"
		elseif not Board:IsTerrain(damage.loc,TERRAIN_WATER) and not Board:IsPawnSpace(damage.loc) then
			damage.sImageMark = "combat/icons/Nico_icon_swap_fire_off_glowB.png"
		elseif Board:IsTerrain(damage.loc,TERRAIN_WATER) and Board:IsPawnSpace(damage.loc) and not dpawn:IsFlying() then
			damage.sImageMark = "combat/icons/Nico_icon_swap_fire_glowB.png"
		elseif Board:IsTerrain(damage.loc,TERRAIN_WATER) and not Board:IsPawnSpace(damage.loc) then
			damage.sImageMark = "combat/icons/Nico_icon_swap_fire_off_glowA.png"
		end
		damage.iFire = 1
		if Board:IsDeadly(damage,Pawn) then
			damage.bKO_Effect = true
			local dam_dealt = self.Damage
			local dpawn = Board:GetPawn(p2)
			local health = dpawn:GetHealth()
			if Board:GetPawn(p1):IsBoosted() then dam_dealt = dam_dealt + 1 end
			if dpawn:IsArmor() and not dpawn:IsAcid() then dam_dealt = dam_dealt - 1 end
			if dpawn:IsAcid() then dam_dealt = dam_dealt*2 end
			if (Board:IsCracked(p2) and not dpawn:IsFlying()) then
				health = 1
				if dpawn:IsArmor() and not dpawn:IsAcid() then dam_dealt = dam_dealt + 1 end
			elseif Board:IsTerrain(p2,TERRAIN_ICE) and not dpawn:IsFlying() and not dpawn:IsMassive() then
				health = 0
			end
			Global_Nico_Move_Speed = Global_Nico_Move_Speed + dam_dealt - health
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

	if (self.Damage==4 or Board:GetPawn(p1):IsBoosted()) and Board:IsPawnSpace(p2) and GAME.additionalSquadData.squad == "Nico_Techno_Veks 2" and not modApi.achievements:isComplete("Nico_Techno_Veks 2","Nico_Techno_Leaper") then
		if Board:GetPawnTeam(p2) == TEAM_ENEMY and Board:GetPawn(p2):IsAcid() then
			ret:AddScript("Nico_Techno_Veks2squad_Chievo('Nico_Techno_Leaper')")
			if modApi.achievements:isComplete("Nico_Techno_Veks 2", "Nico_Techno_Centipede") and modApi.achievements:isComplete("Nico_Techno_Veks 2", "Nico_Techno_Psion") then ret:AddScript("Nico_Techno_Veks2squad_Chievo('Nico_Techno_Shield')") end
		end
	end
	return ret
end

function Leaper_Talons:GetSecondTargetArea(p1, p2)
	if self.Damage == 4 then
		if (Global_Nico_Move_Speed == nil or Global_Nico_Move_Speed < 2) then Global_Nico_Move_Speed = 2 end
	elseif (Global_Nico_Move_Speed == nil or Global_Nico_Move_Speed < 1) then
		Global_Nico_Move_Speed = 1
	end
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
		ret:AddBurst(p1,"Emitter_Burst_$tile",DIR_NONE)
		ret:AddLeap(move,FULL_DELAY)
		ret:AddBurst(p3,"Emitter_Crack_Start2",DIR_NONE)
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
	UpgradeDescription = "Increases damage by 1 and gain +1 bonus movement.",
	TipImage = {
		Unit = Point(2,3),
		Enemy1 = Point(2,2),
		Building1 = Point(2,0),
		Queued1 = Point(2,1),
		Target = Point(2,2),
		Second_Click = Point(4,3),
		CustomEnemy = "Firefly2",
		CustomPawn = "Nico_Techno_Leaper",
	}
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
		Second_Click = Point(4,3),
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
