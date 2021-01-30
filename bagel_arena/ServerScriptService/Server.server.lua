local Players = game.Players
local RS = game:GetService("RunService")
local RepStorage = game.ReplicatedStorage
local Cmdr = require(RepStorage.Modules.Cmdr)
local Damage = nil
local onCooldownKillLog = {}
local maxDistance = 999999
local neckC0 = CFrame.new(0, 0.8, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1);
local waistC0 = CFrame.new(0, 0.2, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1);
local TPS = game:GetService("TeleportService")
local KillMessages = {
	"%s fragged %s",
	"%s incinerated %s",
	"%s annihilated %s",
	"%s vaporized %s",
	"%s murdered %s",
	"%s destroyed %s",
	"%s killed %s",
	"%s was better than %s",
}


game:BindToClose(function()
	if not RS:IsStudio() and #game.Players:GetPlayers() > 1 then
		TPS:TeleportPartyAsync(game.PlaceId, game.Players:GetPlayers())
	end
	
end)


Cmdr:RegisterCommandsIn(RepStorage.Modules.Commands)

Cmdr:RegisterHooksIn(RepStorage.Modules.Hooks)





workspace.Changed:Connect(function()
	
	
	for _, v in pairs(workspace:GetChildren()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") then
			if v:FindFirstChild("ForceField") then
				for _, b in pairs(v:GetChildren()) do
					if b:IsA("BasePart") and b.Name ~= 'HumanoidRootPart'  then
						b.Material = Enum.Material.Neon
					end
				end
			else
				for _, b in pairs(v:GetChildren()) do
					if b:IsA("BasePart") and b.Name ~= 'HumanoidRootPart' then
						b.Material = Enum.Material.SmoothPlastic

					end
				end
			end
		end
	end
	
	for _, v in pairs(game.Players:GetPlayers()) do
		local char = v.Character
		if not char then return end
		
		
		local Nametag = char:WaitForChild("Head"):WaitForChild("Nametag")
		
		Nametag.Tag.NameTag.Text = "♦ " .. v.Name
		Nametag.Tag.Healthbar.Progress.Size = UDim2.fromScale(char.Humanoid.Health / char.Humanoid.MaxHealth, 1)
		Nametag.Tag.HealthPercent.Text = tostring(math.floor((char.Humanoid.Health / char.Humanoid.MaxHealth) * 100)) .. "%"
		
	end
	
end)

function CharacterAdded(Player, Char)
	local HitBox = Char:WaitForChild("HumanoidRootPart"):Clone()
	HitBox.Parent = Char
	HitBox.Name = 'Hitbox'
	HitBox.Anchored = false
	HitBox.CanCollide = false
	HitBox.Size = Char.HumanoidRootPart.Size * 2
	HitBox.Transparency = 0.4
	HitBox.Position = Char.HumanoidRootPart.Position

	local weld = Instance.new("WeldConstraint", Char.HumanoidRootPart)
	weld.Part0 = Char.HumanoidRootPart
	weld.Part1 = HitBox

	for _, v in pairs(RepStorage.Parts.Loser:GetChildren()) do
		local b = v:Clone()
		b.Parent = Char.HumanoidRootPart
	end

	Char.HumanoidRootPart.Laser.Attachment0 = Char.HumanoidRootPart.B
	

	if Char:WaitForChild("ForceField",2) then
		Char:FindFirstChild("ForceField").Visible = false
	end

	Char.Humanoid.Died:Connect(function()
		
		wait(game.Players.RespawnTime)
		spawn_Plr(Player)
	end)
	
	Char.HumanoidRootPart.Laser.Attachment1 = Char.Head.Shoot
	
	
end

for _, v in pairs(workspace:GetDescendants()) do
	if v:IsA("SpawnLocation") then
		v.Transparency = 1
	elseif v.Name == 'Target' then
		v.Transparency = 1
	end
end

for _, v in pairs(workspace.Rays:GetDescendants()) do
	if v:IsA("BasePart") and v.Name == 'InvisibleWall' then
		v.Transparency = 1
	end
end

local RoundTime = 0
local StartRoundTime = tick()

function spawn_Plr(Player)
	if not Player:IsA("Player") then return end
	
	Player:LoadCharacter()
	
	local BestSpawn = game.Workspace.Spawns:GetChildren()[1]
	
	local BestDistance = 0
	
	for _, PlayerB in pairs(game.Players:GetPlayers()) do
		for _, v in pairs(game.Workspace.Spawns:GetChildren()) do
			local Char = PlayerB.Character
			if not Char then return end
			
			local RootPart = Char.HumanoidRootPart
			

			
			if ((RootPart.Position) - v.Position).Magnitude > BestDistance-50 then
				BestDistance = (RootPart.Position - v.Position).Magnitude
				BestSpawn = v
				

			
			end
			
			
			
		end
		
	end
	
	Player.RespawnLocation = BestSpawn
	repeat wait() until Player.Character
	CharacterAdded(Player, Player.Character)
end

function newRound()
	StartRoundTime = tick()
	RoundTime = 0
end




RepStorage.Remotes.RequestRoundtime.OnServerInvoke = function(plr)
	RoundTime = tick() - StartRoundTime
	return RoundTime
end

Players.PlayerAdded:Connect(function(Player)
	spawn_Plr(Player)
	onCooldownKillLog[Player.Name] = false
end)


RepStorage.Remotes.Isfiring.OnServerEvent:Connect(function(plr, start, WeaponName)
	if not WeaponName then return end
	local weaponMod = require(RepStorage.Modules.Weapons[WeaponName])
	
	local Char = plr.Character
	
	if plr.Character:FindFirstChildOfClass("ForceField") then
		plr.Character:FindFirstChildOfClass("ForceField"):Destroy()
	end
	
	if weaponMod.Type == 'laser' then
		if start then
			plr.Character.HumanoidRootPart.Laser.Enabled = true

			local StartSound = weaponMod.sounds.Start:Clone()

			StartSound.Parent = plr.Character.HumanoidRootPart

			StartSound:Play()

			StartSound.Ended:Connect(function()
				StartSound:Destroy()
			end)

			local HitSound = weaponMod.sounds.Hit:Clone()
			HitSound.Parent = plr.Character.HumanoidRootPart
			HitSound:Play()

			

		else
			plr.Character.HumanoidRootPart.Laser.Enabled = false

			if plr.Character and plr.Character:FindFirstChild('HumanoidRootPart'):FindFirstChild(weaponMod.sounds.Hit.Name) then
				plr.Character.HumanoidRootPart:FindFirstChild(weaponMod.sounds.Hit.Name):Destroy()
			end
		end
	elseif weaponMod.Type ~= 'laser' then
		if start then
			
			plr.Character.HumanoidRootPart.Laser.Enabled = false

			if plr.Character.HumanoidRootPart and  plr.Character.HumanoidRootPart:FindFirstChild("LightningHit") then
				plr.Character.HumanoidRootPart:FindFirstChild("LightningHit"):Destroy()
			end
			
			local FireSound = weaponMod.sounds.Fire:Clone()

			FireSound.Parent = Char.HumanoidRootPart

			FireSound:Play()

			FireSound.Ended:Connect(function()
				FireSound:Destroy()
			end)
		end
		
	end
	
	
end)

RepStorage.Remotes.Fire.OnServerEvent:Connect(function(Plr, ClientResult, Origin, Direction, Params)
	
	if Plr.Character:WaitForChild("Humanoid"):GetState() == Enum.HumanoidStateType.Dead then return end
	
	if ClientResult and ClientResult.WeaponMod then
		Damage = ClientResult.WeaponMod
	end
	
	if (Origin - Plr.Character:FindFirstChild("Head").Position).Magnitude > 28 then
		return
	end

	
	
	
	
	
	
	local Params = RaycastParams.new()

	Params.FilterType = Enum.RaycastFilterType.Blacklist
	
	local Ignore = {}
	
	for _, v in pairs(Plr.Character:GetDescendants()) do
		table.insert(Ignore, #Ignore, v)
	end
	
	for _, v in pairs(workspace.Rays:GetDescendants()) do
		table.insert(Ignore, #Ignore, v)
	end
	
	Params.FilterDescendantsInstances = Ignore
	Params.FilterType = Enum.RaycastFilterType.Blacklist
	
	local result = workspace:Raycast(Origin, Direction, Params)
	
	if ClientResult and ClientResult.WeaponMod.Type == 'projectile' then

		local Projectile = ClientResult.WeaponMod.ProjectileSettings.ProjectileModel:Clone()
		local ProjectileSettings = ClientResult.WeaponMod.ProjectileSettings
		
		Projectile.Owner.Value = Plr.Character
		
		
		
		
		Projectile.Parent = workspace.Rays
		Projectile:SetNetworkOwner(Plr)
		
		
		Projectile.Position = Origin + (Direction * 6)
		
		Projectile.CFrame = CFrame.new(Projectile.Position, Direction * 999)
		
		Projectile.BodyVelocity.Velocity = (Direction * ProjectileSettings.Speed)
		
		

		game.Debris:AddItem(Projectile, 6)
		

		return
	end
	
	result = ClientResult -- change this later lazy boogle
	
	if result then
		Plr.Character.HumanoidRootPart.B.WorldPosition = result.Position
	else
		Plr.Character.HumanoidRootPart.B.WorldPosition = Origin + Direction
	end
	
	Plr.Character.HumanoidRootPart.F.WorldPosition = Plr.Character.HumanoidRootPart.Position
	
	if ClientResult and ClientResult.Position and result and result.Position and (ClientResult.Position - result.Position).Magnitude >= maxDistance then
		print((ClientResult.Position - result.Position).Magnitude)
		ClientResult = result
	end

	
	if result and ClientResult and ClientResult.Instance then
		local oldResult = result
		result = {}
		result.Position = oldResult.Position
		result.Instance = ClientResult.Instance
	end
	
	
	
	
	if result and ClientResult then
		
		if result.Instance and result.Instance.Parent and not result.Instance.Parent:FindFirstChildOfClass("Humanoid") and ClientResult.WeaponMod.Type == 'shotgun' then
			local b = game.ReplicatedStorage.Weapons.Particles:Clone()
			b.Parent = workspace.Rays
			b.Position = result.Position
			
			b.Attachment.Smoke:Emit(12)
			for _, v in pairs(b.Attachment:GetChildren()) do
				if v:IsA("ParticleEmitter") and v.Name ~= 'Smoke' then
					v:Emit(50)
				end
			end
			
			
			game.Debris:AddItem(b, 0.8)
			
		end
		
		
		if result.Instance and result.Instance.Parent and result.Instance.Parent:FindFirstChildOfClass("Humanoid") and not result.Instance:FindFirstAncestor(Plr.Name) then
			
			
			local Humanoid = result.Instance.Parent:FindFirstChildOfClass("Humanoid")
			
			if Damage.Damage then
				Humanoid:TakeDamage(Damage.Damage * RepStorage.DamageMultiplier.Value)
			else
				Humanoid:TakeDamage(Damage.PelletDamage * RepStorage.DamageMultiplier.Value)
			end
			
			
			
			
			if Humanoid.Health <= 0 and not Humanoid.Parent:FindFirstChild("Claimed") then
				Plr.Character.Humanoid.Health = 100
				
				if onCooldownKillLog[Plr.Name] == false then
					onCooldownKillLog[Plr.Name] = true
					
					
					RepStorage.Remotes.KillLog:FireAllClients((KillMessages[math.random(1,#KillMessages)] .. " with %s"):format(Plr.Name, Humanoid.Parent.Name, Damage.Model.Name))
					
					RepStorage.Remotes.Fragged:FireClient(Plr, Humanoid.Parent.Name)
					Instance.new("Folder", Humanoid.Parent).Name = 'Claimed'
					
					for _, v in pairs(Humanoid.Parent:GetDescendants()) do
						
						pcall(function()
							v.Transparency = 1
						end)
						
						pcall(function()
							v.Visible = false
						end)
					end
					local char = Humanoid.Parent
					char.Parent = workspace.Rays
					
					spawn(function()
						wait(0.6)
						onCooldownKillLog[Plr.Name] = false
						
					end)
					
				end
				
			end
			
			pcall(function()
				if not result.Instance.Parent:FindFirstChild("ForceField") then
					
					for _, v in pairs(game.Players:GetPlayers()) do
						if v ~= Plr then
							RepStorage.Remotes.ReplicateAudio:FireClient(v, RepStorage.Sounds.PainNoises:GetChildren()[math.random(1,#RepStorage.Sounds.PainNoises:GetChildren())], result.Instance)
						end
					end
					
					
				end
			end)
			
		end
	end
end)


Players.PlayerAdded:Wait()

newRound()