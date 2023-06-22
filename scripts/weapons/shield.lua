local path = mod_loader.mods[modApi.currentMod].resourcePath

-- add assets from our mod so the game can find them.
modApi:appendAsset("img/combat/icons/icon_Nico_power_glow.png", path.."img/combat/icons/icon_Nico_power_glow.png")
Location["combat/icons/icon_Nico_power_glow.png"] = Point(-12,12)

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
	Upgrades=2,
	BounceAmount = 1,
	UpgradeCost={3,2},
	UpgradeList={"OverCharge","+2 Damage"},
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
modApi:appendAsset("img/effects/shield_explo.png", path.. "img/effects/shield_explo.png")
ANIMS.shield_explo = Animation:new{
	Image = "effects/shield_explo.png",
	NumFrames = 8,
	Time = 0.05,
	
	PosX = -33,
	PosY = -14
}
function Shield_attack:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local radiop1=SpaceDamage(p1,0)--this is the animation that plays on the head of the shooter
	radiop1.iShield=1
	radiop1.sAnimation="Radio_Burst"
	ret:AddBounce(p1, 1)
	ret:AddDamage(radiop1)
	local radiop2 = SpaceDamage(p2,0)
	radiop2.sAnimation = self.ExplosionCenter
	radiop2.bHide=true
	ret:AddDelay(0.25)
	ret:AddDamage(radiop2)
	local damage = SpaceDamage(p2,0)
	ret:AddDelay(0.25)
	local tpawn = Board:GetPawn(p2)
	local powered=SpaceDamage(p2,0)

	if Board:GetPawnTeam(p2) == TEAM_PLAYER and self.ReAct and not tpawn:IsActive() then
		damage.iShield=1
		damage.bHide=true
		powered.sImageMark="combat/icons/icon_Nico_power_glow.png"
		ret:AddScript(string.format("Board:GetPawn(%s):SetActive(true)", p2:GetString()))
        ret:AddScript(string.format("Board:GetPawn(%s):SetMovementSpent(false)", p2:GetString()))
		ret:AddScript(string.format("Board:Ping(%s,GL_Color(197,255,255))", p2:GetString())) -- cool animation
		ret:AddDamage(powered)
		ret:AddDamage(damage)
	elseif Board:GetPawnTeam(p2) == TEAM_PLAYER or Board:IsBuilding(p2) then
		damage.iShield=1
		ret:AddDamage(damage)
	elseif self.DoDamage then
		damage.iShield=0
		damage.sAnimation="shield_explo"
		damage.iDamage=self.Damage
		ret:AddDamage(damage)
	else
		damage.iShield=1
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
	-- for the tip
	if Board:GetSize() == Point(6,6) and self.ReAct then
		ret:AddDelay(1.0)
		ret:AddBounce(p2,4)
		ret:AddDelay(0.4)
		ret:AddBurst(Point(2,0),"Emitter_Burst_tiles_grass",DIR_NONE)
		ret:AddBounce(Point(2,0),-4)
		ret:AddScript("Board:DamageSpace(Point(2,0),1)")
		ret:AddDelay(0.2)
		for dir = DIR_START, DIR_END do
			ret:AddBounce(Point(2,0)+DIR_VECTORS[dir],-2)
			ret:AddBurst(Point(2,0)+DIR_VECTORS[dir],"Emitter_Burst_tiles_grass",DIR_NONE)
		end
		ret:AddDelay(1.0)
		
	end
	return ret
end

Shield_attack_A=Shield_attack:new{
	UpgradeDescription="Reactivates allied units if they have already acted.",
	ReAct=true,
	TipImage = {
		Unit = Point(2,4),
		Enemy = Point(2,0),
		Target = Point(2,2),
		Friendly = Point(2,2),
		Length = 5,
	},
}

Shield_attack_B=Shield_attack:new{
	DoDamage=true,
	UpgradeDescription = "Deals 2 damage to non-friendly targets instead of shielding.",
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

Shield_attack_AB=Shield_attack_A:new{
	DoDamage=true,
	Damage=2,
	ReAct=true,
}
