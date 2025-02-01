Acidic_Vomit = CentipedeAtk1:new{
	Name = "Splattering Gunk",
	Class = "TechnoVek",
	Description = "Fire a damaging projectile that applies A.C.I.D. and flips nearby targets.",
	Icon = "weapons/enemy_firefly2.png",
	Damage = 1,
	Acid = EFFECT_CREATE,
	Spill = false,
	BuildingDamage = true,
	PowerCost = 0,
	Upgrades = 2,
	UpgradeCost = {1,3},
	UpgradeList = { "Building Chain",  "Spill & Melt"},
	LaunchSound = "/weapons/acid_shot",
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
	if Board:GetCustomTile(dam.loc) == "tosx_whirlpool_0.png" then
	else
		if Board:IsPawnSpace(dam.loc) then
			dam.sImageMark = "combat/icons/icon_swap_acid_glow.png"
		elseif Board:IsBuilding(dam.loc) and not self.BuildingDamage then
			dam.sImageMark = "combat/icons/icon_swap_acid_off_glowB.png"
		elseif not Board:IsPawnSpace(dam.loc) then
			dam.sImageMark = "combat/icons/icon_swap_acid_off_glow.png"
		end
	end
	target = GetProjectileEnd(p1,p2)
	if (p3 == target + DIR_VECTORS[(dir - 1)% 4]) or (p3 == target) or (p3 == target + DIR_VECTORS[(dir + 1)% 4]) then
		if self.Spill and ((Board:IsAcid(p3) and Board:GetTerrain(p3) ~= TERRAIN_ICE and Board:GetTerrain(p3) ~= TERRAIN_WATER and (not Board:IsCracked(p3)) and (not Board:IsBuilding(p3))) or (Board:IsPawnSpace(p3) and (Board:GetPawn(p3):GetType() == "AcidVat" or Board:GetPawn(p3):GetType() == "Storm_Generator"))) then
			dam.iAcid = 0
			dam.iDamage = 0
			dam.iTerrain = TERRAIN_WATER
			if Board:GetCustomTile(dam.loc) ~= "tosx_whirlpool_0.png" then dam.sImageMark = "combat/icons/icon_Nico_acid_water.png" end
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
			if Board:GetCustomTile(damage.loc) ~= "tosx_whirlpool_0.png" then
				if Board:IsPawnSpace(damage.loc) then
					damage.sImageMark = "combat/icons/icon_swap_acid_glow.png"
				else
					damage.sImageMark = "combat/icons/icon_swap_acid_off_glow.png"
				end
			end
			damage.sAnimation = "Splash_acid"
			if Board:IsBuilding(curr) then
				damage.iDamage = 0
				for direc = DIR_START, DIR_END do
					if Board:GetCustomTile(damage.loc) ~= "tosx_whirlpool_0.png" then
						if Board:IsBuilding(damage.loc) then
							damage.sImageMark = "combat/icons/icon_swap_acid_off_glowB.png"
						elseif Board:IsPawnSpace(damage.loc) then
							damage.sImageMark = "combat/icons/icon_swap_acid_glow.png"
						else
							damage.sImageMark = "combat/icons/icon_swap_acid_off_glow.png"
						end
					end
					local n = curr + DIR_VECTORS[direc]
					if not list_contains(explored, n) then
						explored[#explored+1] = n
						future[#future+1] = n
					end
				end
			end
			if self.Spill and ((Board:IsAcid(curr) and Board:GetTerrain(curr) ~= TERRAIN_ICE and Board:GetTerrain(curr) ~= TERRAIN_WATER and (not Board:IsCracked(curr)) and (not Board:IsBuilding(curr))) or (Board:IsPawnSpace(curr) and (Board:GetPawn(curr):GetType() == "AcidVat" or Board:GetPawn(curr):GetType() == "Storm_Generator"))) then
				damage = SpaceDamage(curr,0)
				damage.iTerrain = TERRAIN_WATER
				if Board:GetCustomTile(damage.loc) ~= "tosx_whirlpool_0.png" then damage.sImageMark = "combat/icons/icon_Nico_acid_water.png" end
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
Acidic_Vomit_A = Acidic_Vomit:new{
	BuildingDamage = false,
	UpgradeDescription = "Chains through buildings instead of damaging them, damaging, flipping and applying A.C.I.D. to adjacent squares.",
}
Acidic_Vomit_B = Acidic_Vomit:new{
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
Acidic_Vomit_AB = Acidic_Vomit_A:new{
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