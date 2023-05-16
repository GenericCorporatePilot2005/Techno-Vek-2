local mod = modApi:getCurrentMod()
local path = mod.scriptPath
require(path .."weapons/leaper")
require(path .."weapons/centipede")
require(path .."weapons/psion")
require(path .."weapons/shield")

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