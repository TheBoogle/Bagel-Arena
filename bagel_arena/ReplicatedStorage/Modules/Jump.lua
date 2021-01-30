local module = {}
local OriginalJumpHeight = game.StarterPlayer.CharacterJumpPower


function module.Jump(Height, Touched)
	Height = Height + 2
	if Touched and Touched.Parent:FindFirstChild("Humanoid") and game.Players:GetPlayerFromCharacter(Touched.Parent) == game.Players.LocalPlayer then
		local RootPart = Touched.Parent.HumanoidRootPart

		--local Force = Instance.new("BodyVelocity", RootPart)
		--Force.MaxForce = Vector3.new(0,1000000,0)
		--Force.P = 3000
		--Force.Velocity = Vector3.new(0,BoostForce,0)
		
		Touched.Parent.Humanoid.UseJumpPower = false
		
		Touched.Parent.Humanoid.JumpHeight = Height
		Touched.Parent.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		
		spawn(function()
			
			local b = game.ReplicatedStorage.Sounds.Jump:Clone()
			b.Parent = workspace.Camera
			b:Play()
			b.Ended:Connect(function()
				b:Destroy()
			end)
		end)
		
		wait()
		if Touched.Parent and Touched.Parent:FindFirstChild("Humanoid") then
			Touched.Parent.Humanoid.UseJumpPower = true
			Touched.Parent.Humanoid.JumpPower = OriginalJumpHeight
		end
		
		Touched.Parent.Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)


		--Touched.Parent.Humanoid.StateChanged:Connect(function(oldState, newState)
		--	if newState == Enum.HumanoidStateType.Landed then
		--		Force:Destroy()
		--	end
		--end)

		--wait(1)
		--if Force then
		--	Force:Destroy()
		--end

	end
end


function module.DirectionalJump(Direction, Touched)
	if Touched and Touched.Parent:FindFirstChild("Humanoid") and game.Players:GetPlayerFromCharacter(Touched.Parent) == game.Players.LocalPlayer then
		local RootPart = Touched.Parent:FindFirstChild("HumanoidRootPart")
		
		RootPart.Velocity += Direction
		
		Touched.Parent.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

		spawn(function()

			local b = game.ReplicatedStorage.Sounds.Jump:Clone()
			b.Parent = workspace.Camera
			b:Play()
			b.Ended:Connect(function()
				b:Destroy()
			end)
		end)

		wait()


		
		
	end
end

return module
