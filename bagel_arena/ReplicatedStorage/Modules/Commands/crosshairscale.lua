return {
	Name = "crosshair_size";
	Description = "Changes crosshair size";
	Group = "client";
	Args = {
		{
			Type = "number";
			Name = "Size";
			Description = "New Size";
		},
	};
	ClientRun = function(context, bool)
		context.Executor.CrosshairSize.Value = bool
		return "Crosshair size is now equal to: " .. bool 
	end
	
	
}