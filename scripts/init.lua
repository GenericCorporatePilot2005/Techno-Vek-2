
-- init.lua is the entry point of every mod

local mod = {
	id = "Nico_Techno_Veks 2",
	name = "Secret Squad II",
	version = "1.2.5",
	requirements = {},
	dependencies = { --This requests modApiExt from the mod loader
		modApiExt = "1.17", --We can get this by using the variable `modapiext`
		memedit = "1.2.0",
	},
	modApiVersion = "2.8.3",
	icon = "img/mod_icon.png"
}

function mod:init()
	-- look in template/mech to see how to code mechs.
	require(self.scriptPath .."weapons/weapons")
	require(self.scriptPath .."pawns")
	require(self.scriptPath .."pilots")
	require(self.scriptPath .."assets")
	require(self.scriptPath .."achievements")
	if modApi.achievements:isComplete("Nico_Techno_Veks 2","Nico_Techno_Shield") then
		-- add extra mech to selection screen
		modApi.events.onModsInitialized:subscribe(function()

			local oldGetStartingSquad = getStartingSquad
			function getStartingSquad(choice, ...)
			local result = oldGetStartingSquad(choice, ...)

			if choice == 0 then
				return add_arrays(result, {"Nico_Techno_Shield"})
			end
			return result
			end
		end)
	end
	require(self.scriptPath .."libs/trait")

end

function mod:metadata()
	modApi:addGenerationOption(
		"Nico_Receiver_Class", "Psionic Receiver's Class.",
		"Changes the Mech Class of the Psionic Receiver from none to Cyborg, this makes Cyborgs not need to pay additional cores for this passive.\nREQUIRES A RESTART TO APPLY.",
		{
			strings = { "Cyborg.", "All Classes."},
			values = {"TechnoVek", ""},
			value = "TechnoVek",
			tooltips = {"Makes the passive cost 1 extra core to all other classes BUT CYBORG.", "Same as Vanilla."},
		}
	)
end
function mod:load( options, version)
	-- after we have added our mechs, we can add a squad using them.
	modApi:addSquad(
		{
			"Secret Squad II",		-- title
			"Nico_Techno_Centipede",	-- mech #2
			"Nico_Techno_Leaper",-- mech #1
			"Nico_Techno_Psion",	-- mech #3
			id="Nico_Techno_Veks 2"
		},
		"Secret Squad II",
		"Humanity's newest hope is another blend of Machine and Vek created to defend Earth",
		self.resourcePath .."img/mod_icon.png"
	)
end

return mod
