return {
	Name = "contrast";
	Description = "Changes contrast";
	Group = "client";
	Args = {
		{
			Type = "number";
			Name = "Contrast";
			Description = "New contrast";
		},
	};
	ClientRun = function(context, bool)
		bool = math.clamp(bool, -1,1)
		game.Lighting.ColorCorrection.Contrast = bool
		return "Contrast is now equal to: "..tostring(bool)
	end
	
	
}