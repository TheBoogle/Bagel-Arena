local Crosshairs = require(game.ReplicatedStorage.Modules.Crosshairs)

return {
	Name = "crosshair";
	Description = "Changes crosshair";
	Group = "client";
	Args = {
		{
			Type = "integer";
			Name = "Crosshair";
			Description = ("New Crosshair. (%s-%s)"):format(tostring(1), tostring(#Crosshairs));
		},
	};
	ClientRun = function(context, bool)
		if bool == 0 then
			context.Executor.CustomCrosshair.Value = false
		else
			context.Executor.CustomCrosshair.Value = true
		end
		
		bool = math.clamp(bool, 1, #Crosshairs)
		context.Executor.Crosshair.Value = bool
		return "Crosshair updated."
	end
	
	
}