return {
	Name = "fov";
	Description = "Changes FOV of the camera";
	Group = "client";
	Args = {
		{
			Type = "number";
			Name = "FOV";
			Description = "New FOV";
		},
	};
	ClientRun = function(context, bool)
		bool = math.clamp(bool, 30, 120)
		game.Workspace.CurrentCamera.FieldOfView = bool
		return "Camera FOV is now equal to: "..tostring(bool)
	end
	
	
}