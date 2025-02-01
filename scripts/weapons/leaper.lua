Leaper_Talons = LeaperAtk1:new{
	Name = "Titanite Talons",
	Class = "TechnoVek",
	Description = "Slice an adjacent tile, greatly damaging and flipping it, and gain 1 bonus tile movement.",
    Icon = "weapons/enemy_leaper2.png",
	Damage = 3,
	Fire = false,
	SoundBase = "/enemy/leaper_2",
	PowerCost = 0,
	Upgrades = 2,
	UpgradeCost = { 2 , 2 },
	UpgradeList = { "Ignite & Overkill Move",  "Damage & Move"  },
	TipImage = {
		Unit = Point(2,2),
		Enemy1 = Point(2,1),
		Building1 = Point(2,0),
		Queued1 = Point(2,0),
		Target = Point(2,1),
		CustomEnemy = "Firefly2",
		CustomPawn = "Nico_Techno_Leaper",
	}
}

function Leaper_Talons:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local direction = GetDirection(p2 - p1)
	local mechId = Board:GetPawn(p1):GetId()
	local damage = SpaceDamage(p2,self.Damage,DIR_FLIP)
	damage.sSound = "/weapons/sword"
	damage.sAnimation = "SwipeClaw2"
	damage.bKO_Effect = false
	local bonusMove = (self.Damage == 4 and 2) or 1
	if self.Fire then
		local dpawn = Board:GetPawn(p2)
		if Board:GetCustomTile(damage.loc) ~= "tosx_whirlpool_0.png" then
			if (not Board:IsTerrain(damage.loc,TERRAIN_WATER) and Board:IsPawnSpace(damage.loc)) or (Board:IsTerrain(damage.loc,TERRAIN_WATER) and Board:IsPawnSpace(damage.loc) and dpawn:IsFlying()) then
				damage.sImageMark = "combat/icons/Nico_icon_swap_fire_glowA.png"
			elseif not Board:IsTerrain(damage.loc,TERRAIN_WATER) and not Board:IsPawnSpace(damage.loc) then
				damage.sImageMark = "combat/icons/Nico_icon_swap_fire_off_glowB.png"
			elseif Board:IsTerrain(damage.loc,TERRAIN_WATER) and not Board:IsPawnSpace(damage.loc) then
				damage.sImageMark = "combat/icons/Nico_icon_swap_fire_off_glowA.png"
			else
				damage.sImageMark = "combat/icons/Nico_icon_swap_fire_off_glowB.png"
			end
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
			bonusMove = bonusMove + dam_dealt - health
		end
		damage.bKO_Effect = false
	end
	ret:AddBounce(p2,3)
	ret:AddMelee(p2 - DIR_VECTORS[direction], damage)
	if self.Fire then ret:AddAnimation(p2,"explo_fire1",ANIM_NO_DELAY) end

	--This section of code is custom flip for Firefly Leader and Junebug Leader
	--Note that it has not been conditioned to check that the Leaders still exist
	local Mirror = false
	if Board:IsPawnSpace(p2) and (Board:GetPawn(p2):GetType() == "FireflyBoss" or Board:GetPawn(p2):GetType() == "DNT_JunebugBoss")
	and Board:GetPawn(p2):IsQueued()then
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
	
	ret:AddScript("Board:GetPawn("..mechId.."):SetActive(true)")
	if self.Damage == 4 then
		if bonusMove < 2 then bonusMove = 2 end
	elseif bonusMove < 1 then
		bonusMove = 1
	end
	if Board:GetSize() == Point(6,6) then
		local move = PointList()
		move:push_back(Point(2,2))
		if self.Fire and self.Damage == 4 then move:push_back(Point(0,1))--3 tiles
		elseif self.Fire or self.Damage == 4 then move:push_back(Point(0,2))--2 tiles
		else move:push_back(Point(1,2)) end--1 tile
	
		ret:AddSound("/enemy/leaper_1/move")
		ret:AddBurst(p1,"Emitter_Burst_$tile",DIR_NONE)
		ret:AddLeap(move,FULL_DELAY)
	else
		ret:AddScript("Board:GetPawn("..mechId.."):SetBonusMove("..bonusMove..")")
	end

	return ret
end

Leaper_Talons_A= Leaper_Talons:new{
	Fire=true,
	UpgradeDescription = "Light the target on fire. If the target is killed, gain bonus movement equal to excess damage dealt.",
	OnKill = "Excess Damage into Movement",
	TipImage = {
		Unit = Point(2,2),
		Enemy1 = Point(2,1),
		Building1 = Point(2,0),
		Queued1 = Point(2,0),
		Target = Point(2,1),
		CustomEnemy = "Mosquito1",
		CustomPawn = "Nico_Techno_Leaper",
	}
}
Leaper_Talons_B= Leaper_Talons:new{
	Damage = 4,
	UpgradeDescription = "Increases damage by 1 and gain +1 bonus movement.",
	TipImage = {
		Unit = Point(2,2),
		Enemy1 = Point(2,1),
		Building1 = Point(2,0),
		Queued1 = Point(2,0),
		Target = Point(2,1),
		CustomEnemy = "Firefly2",
		CustomPawn = "Nico_Techno_Leaper",
	}
}
Leaper_Talons_AB=Leaper_Talons_B:new{
	Fire=true,
	OnKill = "Excess Damage into Movement",
	TipImage = {
		Unit = Point(2,2),
		Enemy1 = Point(2,1),
		Building1 = Point(2,0),
		Queued1 = Point(2,0),
		Target = Point(2,1),
		CustomEnemy = "Firefly1",
		CustomPawn = "Nico_Techno_Leaper",
	}
}