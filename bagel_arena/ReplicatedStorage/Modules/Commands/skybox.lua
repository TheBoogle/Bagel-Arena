return {
	Name = "skybox";
	Description = "Enables/Disables skybox";
	Group = "client";
	Args = {
		{
			Type = "boolean";
			Name = "enabled";
			Description = "If skybox should be enabled/disabled (true/false)";
		},
	};
	ClientRun = function(context, bool)
		if bool == true then
			game.Workspace.Rays.Skybox.Transparency = 0
		else
			game.Workspace.Rays.Skybox.Transparency = 1
		end
		return "The skybox is now: "..tostring(bool)
	end
	
	
}