pcall(function()
	local Character = script.Parent

	local Animation = Instance.new("Animation")
	Animation.AnimationId = 'rbxassetid://6122806044'

	local LoadedAnim = Character.Humanoid:LoadAnimation(Animation)

	LoadedAnim.Priority = Enum.AnimationPriority.Action
	LoadedAnim.Looped = true



	LoadedAnim:Play()

	local cam = workspace.CurrentCamera
	local plr = game:GetService("Players").LocalPlayer

	game:GetService("RunService").RenderStepped:connect(function()
		if plr.Character then
			local root = plr.Character.HumanoidRootPart
			if root then
				root.CFrame = CFrame.new(root.CFrame.p,root.CFrame.p+Vector3.new(cam.CFrame.lookVector.X,0,cam.CFrame.lookVector.Z))
			end
		end
	end)

	wait()

end)