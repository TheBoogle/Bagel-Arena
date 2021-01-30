local RS = game:GetService("RunService")
local Player = game.Players.LocalPlayer
local Char = script.Parent
local Move = require(game.ReplicatedStorage.Modules.Move)
local Debugger = require(game.ReplicatedStorage.Modules.Debugger)

local alwaysRun = true

local RunSpeed = game.StarterPlayer.CharacterWalkSpeed


local CAS = game:GetService('ContextActionService')

local camera = game.Workspace.CurrentCamera


local CanJumpPad = true

for _, v in pairs(Char:GetDescendants()) do
	if v:IsA("BasePart") then
		v.Transparency = 1
	end
end
local UIS = game:GetService("UserInputService")

function sleep(length)
	if not length then length = 1/30 end
	local startTick = tick()

	while tick() - startTick < length do RS.Heartbeat:Wait() end

end


local IsTyping = false

local bannedKeys = {
	Enum.UserInputType.MouseButton1,
	Enum.UserInputType.MouseButton2,
	Enum.KeyCode.Tab,
	Enum.KeyCode.One,
	Enum.KeyCode.Two,
	Enum.KeyCode.Three,
	Enum.KeyCode.Four,
	Enum.KeyCode.Five,
	Enum.KeyCode.Six,
	Enum.KeyCode.Seven,
	Enum.KeyCode.Eight,
	Enum.KeyCode.Nine,
	Enum.KeyCode.Zero,
	Enum.KeyCode.F1,
	Enum.KeyCode.F2,
	Enum.KeyCode.F3,
	Enum.KeyCode.F4,
	Enum.KeyCode.F5,
	Enum.KeyCode.F6,
	Enum.KeyCode.F7,
	Enum.KeyCode.F8,
	Enum.KeyCode.F9,
	Enum.KeyCode.F10,
	Enum.KeyCode.F11,
	Enum.KeyCode.F12
}

local isJumping

UIS.InputBegan:Connect(function(i, GP)
	
	if i.UserInputType == Enum.UserInputType.Keyboard and i.KeyCode == Enum.KeyCode.Space and not GP and Char:FindFirstChild("Humanoid") or i.UserInputType == Enum.UserInputType.Keyboard and i.KeyCode == Enum.KeyCode.C and not GP and Char:FindFirstChild("Humanoid") then

		isJumping = true
		return
	end
	
	local isBanned = false
	
	for _, v in pairs(bannedKeys) do
		if i.UserInputType == v or i.UserInputType == Enum.UserInputType.Keyboard and i.KeyCode == v then
			isBanned = true

		end
	end
	
	if isBanned then return end
	
	if GP then
		IsTyping = true

	else
		IsTyping = false
	end
	
end)

UIS.InputEnded:Connect(function(i, GP)
	if i.UserInputType == Enum.UserInputType.Keyboard and i.KeyCode == Enum.KeyCode.Space and not GP or i.UserInputType == Enum.UserInputType.Keyboard and i.KeyCode == Enum.KeyCode.C and not GP then

		isJumping = false
		return
	end
end)
	



for _, v in pairs(workspace:GetDescendants()) do
	if v.Name == "JumppadPart" then
		local Target = v.Parent.Target



		local Height = ((Target.Position - v.Position) * Vector3.new(0,1,0)).Magnitude

		v.Touched:Connect(function(Touched)
			
			if CanJumpPad and game.Players:GetPlayerFromCharacter(Touched.Parent) == game.Players.LocalPlayer then
				CanJumpPad = false

				require(game.ReplicatedStorage.Modules.Jump).Jump(Height,Touched)
				sleep(0.10)
				CanJumpPad = true
			
			end


		end)
	end
	
	if v.Name == "DirectionalJump" then
		v.Touched:Connect(function(Touched)
			if CanJumpPad and game.Players:GetPlayerFromCharacter(Touched.Parent) == game.Players.LocalPlayer then
				local Direction = (v.Parent.Target.Position - v.Position)				
				CanJumpPad = false
				
				if v.Parent.Anchor.Orientation.Y == -135 or v.Parent.Anchor.Orientation.Y == 180 or v.Parent.Anchor.Orientation.Y == 135 then
					if Direction.X < Direction.Z then
						Direction = Direction * Vector3.new(1.5,1.8,0)
					elseif Direction.Z < Direction.X then
						Direction = Direction * Vector3.new(0,3,1.5)
					end
				else
					if Direction.X > Direction.Z then
						Direction = Direction * Vector3.new(1.5,1.8,0)
					elseif Direction.Z > Direction.X then
						Direction = Direction * Vector3.new(0,3,1.5)
					end
				end
				
				
				
				require(game.ReplicatedStorage.Modules.Jump).DirectionalJump(Direction, Touched)
				sleep(0.1)
				CanJumpPad = true

			end


		end)
	end
	
end

local canGain = true

RS.RenderStepped:Connect(function(dt)
	
	if isJumping and Char:FindFirstChild("Humanoid") then
		Char.Humanoid.Jump = true
	end
	
	RunSpeed = game.ReplicatedStorage.RunSpeed.Value
	
	if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
		Debugger.UpdateValue("Velocity (SPS)", tostring(math.floor(Player.Character.HumanoidRootPart.Velocity.Magnitude)))	
		Debugger.UpdateValue("JumpPower", Player.Character.Humanoid.JumpPower)
		Debugger.UpdateValue("RunSpeed", game.ReplicatedStorage.RunSpeed.Value)
		for _, v in pairs(Player.Character:GetDescendants()) do
			if v:IsA("BasePart") and v.Transparency <= 0 then
				v.Transparency = 1
			end
		end
		
		Player.Character.Humanoid.WalkSpeed = RunSpeed
	
		Move.Update(Char, dt, IsTyping)

	end
	
	

end)

