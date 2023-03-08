
-- init.lua is the entry point of every mod

local mod = {
	id = "Nico_Techno_Veks 2",
	name = "Secret Squad II",
	version = "1.2.0",
	requirements = {},
	dependencies = { --This requests modApiExt from the mod loader
		modApiExt = "1.17", --We can get this by using the variable `modapiext`
	},
	modApiVersion = "2.8.3",
	icon = "img/mod_icon.png"
}

function mod:init()
	-- look in template/mech to see how to code mechs.
	require(self.scriptPath .."weapons")
	require(self.scriptPath .."pawns")
	require(self.scriptPath .."achievements")
	require(self.scriptPath .."libs/trait")
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

function mod:load( options, version)
	-- after we have added our mechs, we can add a squad using them.
	modApi:addSquad(
		{
			"Secret Squad II",		-- title
			"Nico_Techno_Leaper",	-- mech #1
			"Nico_Techno_Centipede",-- mech #2
			"Nico_Techno_Psion",	-- mech #3
			id="Nico_Techno_Veks 2"
		},
		"Secret Squad II",
		"The second known attempt to combine Vek and machines; in their timeline, different veks were used as inspiration.",
		self.resourcePath .."img/mod_icon.png"
	)
end

return mod