local mod = modApi:getCurrentMod()
local path = mod.scriptPath
require(path .."achievements")
require(path .."weapons/leaper")
require(path .."weapons/centipede")
require(path .."weapons/psion")
require(path .."weapons/shield")

if modApi.achievements:isComplete("Nico_Techno_Veks 2","Nico_Techno_Leaper") then
	modApi:addWeaponDrop("Leaper_Talons") end
if modApi.achievements:isComplete("Nico_Techno_Veks 2","Nico_Techno_Centipede") then
	modApi:addWeaponDrop("Acidic_Vomit") end
if modApi.achievements:isComplete("Nico_Techno_Veks 2","Nico_Techno_Psion") then
	modApi:addWeaponDrop("Tentacle_attack") end
if modApi.achievements:isComplete("Nico_Techno_Veks 2","Nico_Techno_Shield") then
	modApi:addWeaponDrop("Shield_attack") end

local options = mod_loader.currentModContent[mod.id].options
Passive_Psions.Class = options["Nico_Receiver_Class"].value