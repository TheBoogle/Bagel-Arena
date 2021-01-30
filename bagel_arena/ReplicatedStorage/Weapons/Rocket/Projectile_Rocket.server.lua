local maxDamage = 250

script.Parent.Touched:Connect(function(part)
	
	local Allowed = true
	
	
	for _, v in pairs(game.Workspace.Rays:GetDescendants()) do
		if v:IsA("BasePart") and v == part then
			Allowed = false
		end
	end


	if part.Parent == script.Parent.Owner.Value then 
		Allowed = false
	end
	
	
	if not Allowed then return end
	
	local b = Instance.new("Explosion")
	b.DestroyJointRadiusPercent = 0
	b.Parent = workspace
	print(b.BlastPressure)
	b.BlastPressure = 500000 * 0.5
	b.BlastRadius = 10
	b.Position = script.Parent.Position
	
	
	local sound = Instance.new("Part", workspace.Rays)
	sound.Anchored = true
	sound.Size = Vector3.new(0.5,0.5,0.5)
	sound.Transparency = 1
	sound.CanCollide = false
	
	local sfx = script.Parent.explosion:Clone()
	sfx.Parent = sound
	sfx:Play()
	
	sfx.Ended:Connect(function()
		sound:Destroy()
	end)
	
	
	
	script.Parent:Destroy()
end)