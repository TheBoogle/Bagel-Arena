return {
	Name = "bgmvolume";
	Description = "Changes Music Volume";
	Group = "client";
	Args = {
		{
			Type = "number";
			Name = "newvalue";
			Description = "New volume, default is: " .. tostring(game.Workspace.Music.Volume);
		},
	};
	ClientRun = function(context, newValue)
		local originalValue = game.Workspace.Music.Volume
		game.Workspace.Music.Volume = newValue
		if newValue < originalValue then
			return "Volume was reduced to: " .. tostring(newValue)
		elseif newValue == originalValue then
			return "Volume was not changed, as the new value is equal to the current value."
		else
			return "Volume was increased to: " .. tostring(newValue)
		end 
		
		
	end
	
	
}