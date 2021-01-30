return {
	Name = "brightness";
	Description = "Changes brightness";
	Group = "client";
	Args = {
		{
			Type = "number";
			Name = "Brightness";
			Description = "New Brightness";
		},
	};
	ClientRun = function(context, bool)
		bool = math.clamp(bool, -1,1)
		game.Lighting.ColorCorrection.Brightness = bool
		return "Brightness is now equal to: "..tostring(bool)
	end
	
	
}