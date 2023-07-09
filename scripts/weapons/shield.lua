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
	UpgradeCost={3,2},
	UpgradeList={"OverCharge","+2 Damage"},
	UpShot="",
	LaunchSound = "/weapons/arachnoid_ko",
	ImpactSound = "/impact/generic/explosion",
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
	local dir = GetDirection(p2 - p1)
	local tpawn=Board:GetPawn(p2)
	local radio=SpaceDamage(p1,0)
	radio.sAnimation="Radio_Burst"
	radio.sSound=self.LaunchSound
	ret:AddBounce(p1,1)
	ret:AddDamage(radio)
	radio=SpaceDamage(p2,0)
	radio.sAnimation="Radio_Burst"
	ret:AddBounce(p2,2)
	ret:AddDamage(radio)

	local shield=SpaceDamage(p2)
	local powered=SpaceDamage(p2)
	if Board:GetPawnTeam(p2) == TEAM_PLAYER then
		shield.iShield=1
		if self.ReAct and (not tpawn:IsActive() or Board:GetSize() == Point(6,6)) then
			shield.bHide=true
			powered.sImageMark="combat/icons/icon_Nico_power_glow.png"
			ret:AddScript(string.format("Board:GetPawn(%s):SetActive(true)", p2:GetString()))
			ret:AddScript(string.format("Board:GetPawn(%s):SetMovementSpent(false)", p2:GetString()))
			ret:AddScript(string.format("Board:Ping(%s,GL_Color(197,255,255))", p2:GetString())) -- cool animation
			ret:AddDamage(shield)
			ret:AddDamage(powered)
		else
			ret:AddDamage(shield)
		end
	elseif Board:IsBuilding(p2) then
		shield.iShield=1
		ret:AddDamage(shield)
	elseif self.DoDamage then
		shield.iShield=0
		shield.sAnimation="shield_explo"
		shield.iDamage=self.Damage
		ret:AddDamage(shield)
	else
		shield.iShield=1
		ret:AddDamage(shield)
	end
	
	
	for i = DIR_START,DIR_END do
		local curr = p2 + DIR_VECTORS[i]
		local spaceDamage = SpaceDamage(curr, 0, i)
		
		spaceDamage.sAnimation = "airpush_"..i
		ret:AddDamage(spaceDamage)
		
		ret:AddBounce(curr,-1)
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