-- Viewmodel framework and other weapon things, some code in here may be a bit odd.

local module = {}
local MT = {__index = module}
local self = {}
local Debugger = require(game.ReplicatedStorage.Modules.Debugger)

local spring = require(game.ReplicatedStorage.Modules.SpringModule)

local current = 0

local GlobalSpring = spring.new(0)

GlobalSpring.Speed = 25
GlobalSpring.Damper = 0.35

local TAU = math.pi * 2


local RS = game:GetService('RunService')

function sleep(length)
	if not length then length = 1/30 end
	local startTick = tick()

	while tick() - startTick < length do RS.Heartbeat:Wait() end

end


function calcBob(RootPart, DT, Y, camLook)
	local bob
	local cycle
	
	current = current + (0.025 * (DT*100))
	
	local vel = RootPart.Velocity
	
	Debugger.UpdateValue("DeltaTime", DT)
	
	if not Y then
		bob = math.sqrt(vel.X * vel.X + vel.Z * vel.Z) * 2
		bob = (bob*math.sin(current)) / 500
		return bob
	elseif Y == 1 then
		bob = math.sqrt(vel.X * vel.X + vel.Z * vel.Z) * 2
		bob = (bob*math.sin(current)) / 700
		return (1/700) - math.abs(bob)
	else
		bob = math.sqrt(vel.Y * vel.Y) * 2
		bob = bob / 1200
		GlobalSpring.Target = bob
		return GlobalSpring.Position
	end	
end

function module.new(args)
	
	self = {}

	
	
	
	self.HitMarkerNoise = game.ReplicatedStorage.Sounds.Hitmarker:Clone()
	
	self.DamageIndicator = game.ReplicatedStorage.Parts.DamageIndicator:Clone()
	
	self.WeaponModule = nil
	
	self.ViewHeight = -0.25
	
	for k, v in pairs(args) do
		self[k] = v
	end
	
	args.Cam.CameraType = Enum.CameraType.Scriptable
	
	self.Spring = spring.new(Vector3.new())
	
	self.HitMarkerNoise.Parent = self.Cam
	
	self.KillNoise = game.ReplicatedStorage.Sounds.KillIndicator:Clone()
	self.KillNoise.Parent = self.Cam
	

	
	local Player = game.Players.LocalPlayer
	

	
	self.Cooldown = false
	
	self.CurrentGun = {
		['Instance'] = nil,
		
	}
	self.Firing = false
	
	self.cameraRotation = Vector2.new()
	
	
	Debugger.UpdateValue("FragCount", _G.Frags)
	
	return setmetatable(self, MT)
end

function module:Equip(GunName)
	game.ReplicatedStorage.Remotes.Isfiring:FireServer(false, self.CurrentWeaponName)
	
	game.ReplicatedStorage.Remotes.Fragged.OnClientEvent:Connect(function(Result)
		self:_kill(Result)
	end)
	
	if self.CurrentGun then
		
		if self.CurrentGun.Instance then
			self.CurrentGun.Instance:Destroy()
		end
		
		self.CurrentGun = {
			['Instance'] = nil,

		}
	end
	
	self.Firing = false
	
	
	self.WeaponModule = require(game.ReplicatedStorage.Modules.Weapons[GunName])
	
	self.ModulePath = game.ReplicatedStorage.Modules.Weapons[GunName]
	
	if not self.WeaponModule then return end
	
	self.CurrentGun.Instance = self.WeaponModule.Model:Clone()
	self.CurrentGun.Instance:SetPrimaryPartCFrame(CFrame.new(0,100000,0))
	self.CurrentGun.Instance.Parent = self.Cam
	
	self.CurrentWeaponName = GunName
	
	self.CurrentDamage = self.WeaponModule.Damage
	
	local Anim = Instance.new("Animation")
	Anim.AnimationId = self.WeaponModule.FireAnimation
	
	self.FireAnimation = self.CurrentGun.Instance.AnimationController:LoadAnimation(Anim)
	
	if self.WeaponModule.Type ~= 'laser' then
		self.FireAnimation.Looped = false
	end
	
	Anim:Destroy()
	
	self.Tween = nil
	
	Debugger.UpdateValue("EquippedGun", self.WeaponModule.Model.Name)
	
	
	for _, v in pairs(self.CurrentGun.Instance:GetDescendants()) do
		if self.WeaponModule.Type == 'laser' and v:IsA("Beam") or v:IsA("Light") or v:IsA("ParticleEmitter") then
			v.Enabled = false
		end
	end
	
	self.CanFire = false
	sleep(0.1)
	self.CanFire = true
	
	return self.WeaponModule.Crosshair, self.WeaponModule.Crosshair_Size
	
end

local function lerp(a, b, c)
	return a + ((b - a) * c)
end

function isGrounded(rootPart, Height)
	
	local params = RaycastParams.new()

	params.FilterType = Enum.RaycastFilterType.Blacklist
	
	params.FilterDescendantsInstances = rootPart.Parent:GetDescendants()
	
	local result = workspace:Raycast(rootPart.Position, Vector3.new(0,-1,0) * Height, params)
	
	if result then
		return true
	end
	
end

local lastXBob = 0
local currentX = 0
function module:Update(args)
	
	local rotation = args.MouseDelta
	
	self.cameraRotation = self.cameraRotation + rotation*math.rad(0.25)

	self.cameraRotation = Vector2.new(
		self.cameraRotation.X,
		math.clamp(self.cameraRotation.Y, -math.rad(85), math.rad(85))
	)

	local cameraRotationCFrame = CFrame.Angles(0, -self.cameraRotation.X, 0)*CFrame.Angles(-self.cameraRotation.Y, 0, 0)

	args.Cam.CFrame = cameraRotationCFrame + args.Char.Head.Position
	
	local hrp = args.Char:WaitForChild("HumanoidRootPart")

	hrp.CFrame = CFrame.fromMatrix(hrp.Position, args.Cam.CFrame.RightVector, Vector3.new(0,1,0))
	
	Debugger.UpdateValue("On Cooldown", self.Cooldown)

	
	
	if args['Char']:WaitForChild("Humanoid").Health > 0 then
		local RootPart = args['Char']['HumanoidRootPart']
		local onGround = isGrounded(RootPart, RootPart.Parent.Humanoid.HipHeight*4)

		if not self.Firing and not self.Cooldown then
			if not onGround then
				self.CurrentGun.Instance:SetPrimaryPartCFrame((self.Cam.CFrame * CFrame.new(0,self.ViewHeight,0)):ToWorldSpace(CFrame.new(
						currentX,
						calcBob(RootPart,args.DT, true, args.Cam.CFrame.LookVector) + calcBob(RootPart,args.DT, 1, args.Cam.CFrame.LookVector), 
						0
						) 
					)
				)
			else
				currentX = lerp(currentX, calcBob(RootPart,args.DT, false, args.Cam.CFrame.LookVector), (2 * args.DT))
				self.CurrentGun.Instance:SetPrimaryPartCFrame((self.Cam.CFrame * CFrame.new(0,self.ViewHeight,0)):ToWorldSpace(
					CFrame.new(
						currentX, 
						calcBob(RootPart,args.DT, true, args.Cam.CFrame.LookVector) + calcBob(RootPart,args.DT, 1, args.Cam.CFrame.LookVector), 
						0) 
					)
				)
				lastXBob = calcBob(RootPart,args.DT, false, args.Cam.CFrame.LookVector)
				
			end
		else
			self.CurrentGun.Instance:SetPrimaryPartCFrame((self.Cam.CFrame * CFrame.new(0,self.ViewHeight,0):ToWorldSpace(CFrame.new(0,calcBob(RootPart,args.DT, true, args.Cam.CFrame.LookVector) + calcBob(RootPart,args.DT, 1, args.Cam.CFrame.LookVector),0)) ))
		end
	

		for k, v in pairs(args) do
			self[k] = v
		end
		
		

		Debugger.UpdateValue("FragCount", _G.Frags)
	else
		self.CurrentGun.Instance:SetPrimaryPartCFrame(CFrame.new(0,10000,0))

	end
	
	
end

local KillCooldown = false

function module:_kill(Result)
	if KillCooldown then return end
	KillCooldown = true
	_G.Frags += 1


	for _, v in pairs(game.Players.LocalPlayer.PlayerGui.ScreenGui:GetChildren()) do
		if v:IsA('TextLabel') and v.Name ~= 'Health' and v.Name ~= 'FPS' and v.Name ~= 'Timer' then
			v:Destroy()
		end
	end

	local b = game.ReplicatedStorage.Frames.Killed:Clone()
	b.Parent = game.Players.LocalPlayer.PlayerGui.ScreenGui
	self.KillNoise:Play()
	b.Text = [[YOU fragged <font color="rgb(255,10,0)">]] .. string.upper(Result) .. "</font>"





	spawn(function()
		sleep(2.5)
		b:Destroy()
		
	end)
	sleep(0.1)
	KillCooldown = false
end


function module:_LaserFire(args, firing)
	

	while wait() do
		if self.StartFireTick then
			if tick() - self.StartFireTick <= 0.1 then self.CanDamage = false else self.CanDamage = true end
		end
		
		if self.Firing and self.Char.Humanoid.Health > 0 then


			for _, v in pairs(self.CurrentGun.Instance:GetDescendants()) do
				if v:IsA("Beam") or v:IsA("Light")  or v:IsA("ParticleEmitter") then
					v.Enabled = true
				end

				if v:IsA("Light") then
					v.Brightness = math.random(100,300) / 100
				end

			end

			local Params = RaycastParams.new()

			Params.FilterType = Enum.RaycastFilterType.Blacklist

			local Ignore = {}

			for _, v in pairs(self.Char:GetDescendants()) do
				table.insert(Ignore, #Ignore, v)
			end


			for _, v in pairs(self.CurrentGun.Instance:GetDescendants()) do
				table.insert(Ignore, #Ignore, v)
			end

			for _, v in pairs(workspace.Rays:GetDescendants()) do
				table.insert(Ignore, #Ignore, v)
			end


			Params.FilterDescendantsInstances = Ignore

			local Result = workspace:Raycast(self.Char.Head.Position, self.Cam.CFrame.LookVector * 9999, Params)



			if Result then
				if self.CanDamage then
					game.ReplicatedStorage.Remotes.Fire:FireServer({Instance = Result.Instance, Position = Result.Position, WeaponMod = self.WeaponModule}, self.Char.Head.Position, self.Cam.CFrame.LookVector * 9999, Params)
				end
				self.CurrentGun.Instance.Gun.B.WorldPosition = Result.Position

				Debugger.UpdateValue("HitPos", Result.Position)


				if Result.Instance.Parent:FindFirstChild("Humanoid") and not Result.Instance.Parent:FindFirstChild("ForceField") then

					if Result.Instance.Parent:FindFirstChild("Humanoid"):GetState() == Enum.HumanoidStateType.Dead or Result.Instance.Parent:FindFirstChild('Humanoid').Health <= 0 then

						

						
						
					elseif self.CanDamage then

						



						if Result.Instance.Parent:FindFirstChild("Humanoid") ~= self.LastHum then
							self.CurrentDamage = 0
							self.Break = true
						end

						self.CurrentDamage += self.WeaponModule.Damage * game.ReplicatedStorage.DamageMultiplier.Value

						self.DamageIndicator.BG.Damage.Text = math.clamp(self.CurrentDamage, 0, Result.Instance.Parent:FindFirstChild("Humanoid").MaxHealth)

						self.LastHum = Result.Instance.Parent:FindFirstChild("Humanoid")
						self.HitMarkerNoise.TimePosition = 0

						self.HitMarkerNoise.PlaybackSpeed = math.clamp(2 - (Result.Instance.Parent:FindFirstChild("Humanoid").Health / Result.Instance.Parent:FindFirstChild("Humanoid").MaxHealth), 1, 2)

						Debugger.UpdateValue("HitMarkerNoiseSpeed", self.HitMarkerNoise.PlaybackSpeed)

						self.HitMarkerNoise:Play()


						self.DamageIndicator.Parent = workspace.Rays
						if self.Tween then
							self.Tween:Cancel()
							self.Tween = nil
						end

						self.DamageIndicator.Position = Result.Position




						self.DamageIndicator.BG.Enabled = true



						spawn(function()
							self.Tween = game:GetService("TweenService"):Create(self.DamageIndicator, TweenInfo.new(1.5), {Position = self.DamageIndicator.Position + Vector3.new(0,5,0)})
							self.Tween:Play()
							self.Tween.Completed:Wait()
							self.DamageIndicator.BG.Enabled = false
							self.Tween = nil
						end)


					end

				end


			else
				game.ReplicatedStorage.Remotes.Fire:FireServer(nil, self.Char.Head.Position, self.Cam.CFrame.LookVector * 9999, Params)

				self.CurrentGun.Instance.Gun.B.WorldPosition += self.Cam.CFrame.LookVector * 9999

				Debugger.UpdateValue("HitPos", 'nil')
			end


			if self.WeaponModule.Firerate ~= 0 then
				
				local startTick = tick()
				
				repeat game:GetService('RunService').Heartbeat:Wait() until tick() - startTick > self.WeaponModule.Firerate
			end


		else
			self.Firing = false
			game.ReplicatedStorage.Remotes.Isfiring:FireServer(false, self.CurrentWeaponName)
			

			for _, v in pairs(self.CurrentGun.Instance:GetDescendants()) do
				if v:IsA("Beam") or v:IsA("Light") or v:IsA("ParticleEmitter") then
					v.Enabled = false
				end
			end

			self.FireAnimation:Stop()

			break
		end
	end
end

function module:_ShotgunFire(args, firing)
	
	local PelletRays = {}
	
	local Params = RaycastParams.new()

	Params.FilterType = Enum.RaycastFilterType.Blacklist

	local Ignore = {}

	for _, v in pairs(self.Char:GetDescendants()) do
		table.insert(Ignore, #Ignore, v)
	end


	for _, v in pairs(self.CurrentGun.Instance:GetDescendants()) do
		table.insert(Ignore, #Ignore, v)
	end

	for _, v in pairs(workspace.Rays:GetDescendants()) do
		table.insert(Ignore, #Ignore, v)
	end


	Params.FilterDescendantsInstances = Ignore

	
	for _, v in pairs(self.CurrentGun.Instance:GetDescendants()) do
		if v:IsA("ParticleEmitter") then
			v:Emit(math.random(3,6))
		end
	end
	
	
	for i = 1, self.WeaponModule.PelletCount do
		
		
		local dir = (self.Cam.CFrame.LookVector)
		
		local dirCF = CFrame.new(Vector3.new(), dir)
		
		dir = (dirCF * CFrame.fromOrientation(0, 0, math.random(0, TAU)) * CFrame.fromOrientation(math.rad(math.random(0.1, self.WeaponModule.Spread)), 0, 0)).LookVector
		
		
		local Result = workspace:Raycast(self.Char.Head.Position, dir * self.WeaponModule.MaxRange, Params)
		

		
		if Result then
			table.insert(PelletRays, #PelletRays, Result)

			
			game.ReplicatedStorage.Remotes.Fire:FireServer({Instance = Result.Instance, Position = Result.Position, WeaponMod = self.WeaponModule}, self.Char.Head.Position, dir * self.WeaponModule.MaxRange, Params)
			

			
		end
		
		
		
	end
	
	
	
	local OverallDamage = 0
	
	local Result = nil
	
	
	
	for _, v in pairs(PelletRays) do
		if v.Instance and v.Instance.Parent:FindFirstChildOfClass("Humanoid") then
			OverallDamage += self.WeaponModule.PelletDamage * game.ReplicatedStorage.DamageMultiplier.Value
			Result = v
			
			
			
			
			
		end
	end

	if Result and OverallDamage > 0 then
		self.DamageIndicator.BG.Damage.Text = OverallDamage

		self.HitMarkerNoise.TimePosition = 0

		self.HitMarkerNoise.PlaybackSpeed = 1

		Debugger.UpdateValue("HitMarkerNoiseSpeed", self.HitMarkerNoise.PlaybackSpeed)

		self.HitMarkerNoise:Play()


		self.DamageIndicator.Parent = workspace.Rays
		if self.Tween then
			self.Tween:Cancel()
			self.Tween = nil
		end

		self.DamageIndicator.Position = Result.Position

		self.DamageIndicator.BG.Enabled = true

		spawn(function()
			self.Tween = game:GetService("TweenService"):Create(self.DamageIndicator, TweenInfo.new(1.5), {Position = self.DamageIndicator.Position + Vector3.new(0,5,0)})
			self.Tween:Play()
			self.Tween.Completed:Wait()
			self.DamageIndicator.BG.Enabled = false
			self.Tween = nil
		end)
	end
	sleep()
	
end

function module:_ProjFire(args, firing)
	
	while self.Firing do
		if not self.Firing then return end
		self.FireAnimation:Play()
		game.ReplicatedStorage.Remotes.Fire:FireServer({WeaponMod = self.WeaponModule}, self.Char.Head.Position, self.Cam.CFrame.LookVector)
		

		sleep(self.WeaponModule.Firerate)
	end
	
	
end

function module:Fire(args, firing)
	if not self.CanFire then return end
	if self.FireAnimation.IsPlaying and firing then return end
	if firing and self.Cooldown then return end
	
	if args.Char.Humanoid.Health <= 0 then self.Firing = false; game.ReplicatedStorage.Remotes.Isfiring:FireServer(false, self.CurrentWeaponName) return end
	
	if self.Firing then
		self.Firing = false
		game.ReplicatedStorage.Remotes.Isfiring:FireServer(false, self.CurrentWeaponName)
		sleep()
	end
	
	self.Firing = firing
	
	if firing then
		self.StartFireTick = tick()
	end
	
	if firing and not self.Cooldown and self.CanFire then
		game.ReplicatedStorage.Remotes.Isfiring:FireServer(true, self.CurrentWeaponName)
		self.FireAnimation:Play()
		self.CurrentDamage = 0
		self.StartFireTick = tick()
	else
		game.ReplicatedStorage.Remotes.Isfiring:FireServer(false, self.CurrentWeaponName)
	end
	
	Debugger.UpdateValue("IsFiring", firing)

	
	if self.WeaponModule.Type == 'laser' then
		self:_LaserFire(args, firing)
	elseif self.WeaponModule.Type == 'shotgun' and firing then
		self:_ShotgunFire(args,firing)
	elseif self.WeaponModule.Type == 'projectile' and firing and not self.Cooldown then
		self:_ProjFire(args, firing)
	end
	
	
	if not self.Cooldown and firing then
		self.Cooldown = true
		sleep(self.WeaponModule.Firerate)
		if self.Cooldown then
			self.Cooldown = false
		else
			self.Cooldown = true
		end
		
	end
	
	
end



return module
