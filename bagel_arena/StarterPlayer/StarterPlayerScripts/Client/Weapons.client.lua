local RepStorage = game.ReplicatedStorage
local Framework = require(RepStorage.Modules.Framework)

local Debugger = require(RepStorage.Modules.Debugger)

local DebugGui = Debugger.new(game.ReplicatedStorage.Frames.Data, RepStorage.UI.Debugger, true, true)


local RS = game:GetService("RunService")

local CAS = game:GetService("ContextActionService")
local UIS = game:GetService("UserInputService")


UIS.MouseIconEnabled = false

_G.Frags = 0

function sleep(length)
	if not length then length = 1/60 end
	local startTick = tick()

	while tick() - startTick < length do RS.Heartbeat:Wait() end
	
	return true
	
end




local Player = game.Players.LocalPlayer

local ViewHeight = Instance.new("NumberValue", Player)
ViewHeight.Name = 'ViewHeight'
ViewHeight.Value = -0.25


local CrosshairValue = Instance.new("IntValue", Player)
CrosshairValue.Name = 'Crosshair'
CrosshairValue.Value = 1


local CrosshairSize = Instance.new("NumberValue", Player)
CrosshairSize.Name = 'CrosshairSize'
CrosshairSize.Value = 1

local CustomCrosshair = Instance.new("BoolValue", Player)
CustomCrosshair.Name = 'CustomCrosshair'
CustomCrosshair.Value = false

repeat sleep() until Player.Character

spawn(function()
	while sleep(1) do
		local RoundTime = RepStorage.Remotes.RequestRoundtime:InvokeServer()
		Player.PlayerGui.ScreenGui.Timer.Text = secondsToMinutes(RoundTime)

	end

end)

DebugGui.Parent = Player.PlayerGui

local Crosshair = Player.PlayerGui:WaitForChild("ScreenGui").crosshair

game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)

repeat sleep() until Player.Character.Head

local LastHealth = 100





local Heartbeat = game:GetService("RunService").Heartbeat
local tick = tick

local LastIteration, Start
local FrameUpdateTable = { }

local guns = {
	"Shotgun",
	"LightningGun",
	"Rocket Launcher"
}

local gunBinds = {
	[Enum.KeyCode.One] = 1,
	[Enum.KeyCode.Two] = 2,
	[Enum.KeyCode.Three] = 3,
	[Enum.KeyCode.Four] = 4,
	[Enum.KeyCode.Five] = 5,
	[Enum.KeyCode.Six] = 6,
	[Enum.KeyCode.Seven] = 7,
	[Enum.KeyCode.Eight] = 8,
	[Enum.KeyCode.Nine] = 9,
}

for _, v in pairs(game.Players:GetPlayers()) do
	v.Chatted:Connect(function()
		game.SoundService.talk:Play()
	end)
end

game.Players.PlayerAdded:Connect(function(v)
	v.Chatted:Connect(function()
		game.SoundService.talk:Play()
	end)
end)

Player.PlayerGui:WaitForChild("ScreenGui")

local function HeartbeatUpdate()
	LastIteration = tick()
	for Index = #FrameUpdateTable, 1, -1 do
		FrameUpdateTable[Index + 1] = (FrameUpdateTable[Index] >= LastIteration - 1) and FrameUpdateTable[Index] or nil
	end

	FrameUpdateTable[1] = LastIteration
	local CurrentFPS = (tick() - Start >= 1 and #FrameUpdateTable) or (#FrameUpdateTable / (tick() - Start))
	CurrentFPS = CurrentFPS - CurrentFPS % 1
	Debugger.UpdateValue("FPS", CurrentFPS)
	
	
	
	Player.PlayerGui.ScreenGui.FPS.Text = ("%sfps"):format(tostring(CurrentFPS))
	
end

Start = tick()
Heartbeat:Connect(HeartbeatUpdate)



local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient"))




Cmdr:SetActivationKeys({Enum.KeyCode.Backquote})

workspace.CurrentCamera.FieldOfView = 100

local Weapons= Framework.new({
	['Cam'] = workspace.CurrentCamera,
	['Char'] = Player.Character
})

game.ReplicatedStorage.Modules.Framework:Destroy()

spawn(function()
	wait()
	for _, v in pairs(game:GetDescendants()) do
		pcall(function()
			if v.Name == 'Framework' and v:IsA("ModuleScript") then
				v:Destroy()
				Player:Kick()
				return
			end
		end)
	end
end)


function secondsToMinutes(seconds)
	seconds = math.floor(seconds)

	local minutes = seconds / 60
	local seconds = seconds % 60

	return ("%01d:%02d"):format(minutes, seconds)


end

function equip(Gun)
	local cross, size = Weapons:Equip(Gun)
	print(cross,size,CustomCrosshair.Value)
	if cross and size and CustomCrosshair.Value == false then
		CrosshairValue.Value = cross
		CrosshairSize.Value = size
	elseif not cross and not size and CustomCrosshair.Value == false then
		CrosshairValue.Value = 1
		CrosshairSize.Value = 1
	end
	
end

equip(guns[1])



RepStorage.Remotes.ReplicateAudio.OnClientEvent:Connect(function(audio, parent)
	local Sound = audio:Clone()
	Sound.Parent = parent
	Sound:Play()

	Sound.Ended:Connect(function()
		wait(0.2)
		Sound:Destroy()
	end)
end)

local tween

local DamageTime = 0.1
spawn(function()
	while wait() do
		repeat sleep() until Player.Character:FindFirstChild("Humanoid")
		if Player.Character.Humanoid.Health < LastHealth then
			local DamageGui = Player.PlayerGui.ScreenGui.Damage
			
			DamageGui.Transparency = 1
			
			local Sound = RepStorage.Sounds.PainNoises:GetChildren()[math.random(1,#RepStorage.Sounds.PainNoises:GetChildren())]:Clone()
			Sound.Parent = game.Workspace.CurrentCamera
			Sound:Play()
			
			Sound.Ended:Connect(function()
				wait(0.2)
				Sound:Destroy()
			end)
			
			game:GetService("TweenService"):Create(DamageGui, TweenInfo.new(DamageTime), {ImageTransparency = 0.8}):Play()
			sleep(DamageTime)
			game:GetService("TweenService"):Create(DamageGui, TweenInfo.new(DamageTime), {ImageTransparency = 1}):Play()
			
			

			
			
			
			
		end
		
		LastHealth = Player.Character.Humanoid.Health


	end

end)

local CurrentGun = 1



RepStorage.Remotes.KillLog.OnClientEvent:Connect(function(message)
	
	local b = RepStorage.Frames.Player:Clone()
	b.Parent = Player.PlayerGui.ScreenGui.KillLog
	b.Message.Text = message
	
	game.Debris:AddItem(b, 5)
	
end)

local Crosshairs = require(RepStorage.Modules.Crosshairs)

RS.RenderStepped:Connect(function()
	if Player.Character:FindFirstChild("HumanoidRootPart") then
		Player.Character:FindFirstChild("HumanoidRootPart"):WaitForChild("Laser").Enabled = false
	end
end)

RepStorage.Remotes.ForceEquip.OnClientEvent:Connect(function(WeaponName)
	if not RepStorage.Modules.Weapons:FindFirstChild(WeaponName) then return end
	CurrentGun = -1
	equip(WeaponName)
end)

RS:BindToRenderStep("MoveWeapon", Enum.RenderPriority.Camera.Value + 1, function(DT)
	repeat RS.Heartbeat:Wait() until Player.Character:FindFirstChild("Head")
	
	Weapons.ViewHeight = ViewHeight.Value
	
	Crosshair.Image = Crosshairs[CrosshairValue.Value]
	Crosshair.Size = UDim2.fromOffset(32*CrosshairSize.Value, 32*CrosshairSize.Value)
	
	
	UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
	
	Debugger.UpdateValue("Damage Multiplier", RepStorage.DamageMultiplier.Value)
	Debugger.UpdateValue("Gravity", game.Workspace.Gravity)
	Debugger.UpdateValue("Acceleration", RepStorage.WorldAcceleration.Value)	
	
	
	Weapons:Update({
		['Cam'] = workspace.CurrentCamera,
		['Char'] = Player.Character,
		['DT'] = DT,
		['MouseDelta'] = UIS:GetMouseDelta()
	})
	
	repeat sleep() until Player.Character
	
	
	Player.PlayerGui.ScreenGui.Health.Text = tostring(math.floor(Player.Character:WaitForChild("Humanoid").Health)) .. "%"
	Player.PlayerGui.ScreenGui.KillLog.CanvasSize = UDim2.fromOffset(Player.PlayerGui.ScreenGui.KillLog.UIListLayout.AbsoluteContentSize.X,Player.PlayerGui.ScreenGui.KillLog.UIListLayout.AbsoluteContentSize.Y)
	Player.PlayerGui.ScreenGui.KillLog.CanvasPosition = Vector2.new(0,Player.PlayerGui.ScreenGui.KillLog.AbsoluteWindowSize.Y)
	
	
	
	Debugger.DisplayValues()
end)

local CanFire = true

CAS:BindAction("Fire", function(a,b)
	if not CanFire then return end
	if b == Enum.UserInputState.Begin then
		Weapons:Fire({
			['Cam'] = workspace.CurrentCamera,
			['Char'] = Player.Character
		},true)
		
		CanFire = false
		sleep(Weapons.WeaponModule.FireRate)
		CanFire = true
	elseif Enum.UserInputState.End then
		Weapons:Fire({
			['Cam'] = workspace.CurrentCamera,
			['Char'] = Player.Character
		},false)

		
	end
	
end, false, Enum.UserInputType.MouseButton1)


function toggleDebugger(a, b)
	if b == Enum.UserInputState.Begin then
		Player.PlayerGui.Debugger.Enabled = not Player.PlayerGui.Debugger.Enabled
		
		for _, v in pairs(workspace:GetDescendants()) do
			if v:IsA("SpawnLocation") then
				if v.Transparency ~= 0.5 then
					v. Transparency = 0.5
				else
					v.Transparency = 1
				end
			elseif v.Name == 'Target' then
				if v.Transparency ~= 0.5 then
					v. Transparency = 0.5
				else
					v.Transparency = 1
				end
			end
		end
		
	end
	
end

local Playerlist = game.Players.LocalPlayer.PlayerGui.ScreenGui:WaitForChild("PlayerList")

function ShowList(a,b,c)
	if c.KeyCode ~= Enum.KeyCode.Tab then return end
	
	
	if b == Enum.UserInputState.End then Playerlist.Visible = false else Playerlist.Visible = true end
	
	for _, v in pairs(Playerlist:GetChildren()) do
		if v:IsA('Frame') then
			v:Destroy()
		end
	end
	
	for _, v in pairs(game.Players:GetPlayers()) do
		local b = RepStorage.Frames.Player2:Clone()
		b.Parent = Playerlist
		b.PlayerName.Text = v.Name
	end
	Playerlist.Size = UDim2.new(0.286,0, 0,Playerlist.UIListLayout.AbsoluteContentSize.Y)
end



function ChangeGun(a,b,c)
	if b ~= Enum.UserInputState.Begin then return end
	for k, v in pairs(gunBinds) do
		if c.KeyCode == k and CurrentGun ~= v then
			CurrentGun = v
			if CurrentGun <= #guns then
				equip(guns[CurrentGun])
			end
		end
	end
	
end

function NextGun(a,b,c)
	if c.Position.Z == -1 then
		CurrentGun = CurrentGun - 1
	elseif c.Position.Z == 1 then
		CurrentGun = CurrentGun + 1
	end
	
	if CurrentGun > #guns then
		CurrentGun = 1
	elseif CurrentGun < 1 then
		CurrentGun = #guns
	end
	
	equip(guns[CurrentGun])
	
	
end


CAS:BindAction("ToggleDebug", toggleDebugger, false, Enum.KeyCode.F1)


CAS:BindAction("PlayerList", ShowList, false, Enum.KeyCode.Tab)


for k, v in pairs(gunBinds) do
	CAS:BindAction("ChangeGun"..v, ChangeGun, false, k)
end



CAS:BindAction("NextGun", NextGun, false, Enum.UserInputType.MouseWheel)
