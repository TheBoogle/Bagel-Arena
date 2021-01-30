return {
	Name = "shadows";
	Description = "Enables/Disables shadows";
	Group = "client";
	Args = {
		{
			Type = "boolean";
			Name = "enabled";
			Description = "If shadows should be enabled/disabled (true/false)";
		},
	};
	ClientRun = function(context, bool)
		game.Lighting.GlobalShadows = bool
		return "Shadows are now: "..tostring(bool)
	end
	
	
}