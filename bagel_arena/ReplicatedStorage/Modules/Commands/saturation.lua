return {
	Name = "saturation";
	Description = "Changes saturation";
	Group = "client";
	Args = {
		{
			Type = "number";
			Name = "Saturation";
			Description = "New saturation";
		},
	};
	ClientRun = function(context, bool)
		bool = math.clamp(bool, -1,1)
		game.Lighting.ColorCorrection.Contrast = bool
		return "Saturation is now equal to: "..tostring(bool)
	end
	
	
}