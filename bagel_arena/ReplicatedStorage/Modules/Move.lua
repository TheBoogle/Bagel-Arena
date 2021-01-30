

local SM = {}

local RunS = game:GetService("RunService")
local InputS = game:GetService("UserInputService")

local player = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera

local function lerp(a, b, c)
	return a + ((b - a) * c)
end

local targetMoveVelocity = Vector3.new()
local moveVelocity = Vector3.new()
local isBusy = false

local MOVE_ACCELERATION = 4.5

local walkKeyBinds = {
	Forward = { Key = Enum.KeyCode.W, Direction = Enum.NormalId.Front },
	Backward = { Key = Enum.KeyCode.S, Direction = Enum.NormalId.Back },
	Left = { Key = Enum.KeyCode.A, Direction = Enum.NormalId.Left },
	Right = { Key = Enum.KeyCode.D, Direction = Enum.NormalId.Right }
}

local function getWalkDirectionCameraSpace()
	local walkDir = Vector3.new()

	for keyBindName, keyBind in pairs(walkKeyBinds) do
		if InputS:IsKeyDown(keyBind.Key) then
			walkDir += Vector3.FromNormalId( keyBind.Direction )
		end
	end

	if walkDir.Magnitude > 0 then --(0, 0, 0).Unit = NaN, do not want
		walkDir = walkDir.Unit --Normalize, because we (probably) changed an Axis so it's no longer a unit vector
	end

	return walkDir
end

local function getWalkDirectionWorldSpace()
	local walkDir = camera.CFrame:VectorToWorldSpace( getWalkDirectionCameraSpace() )
	walkDir *= Vector3.new(1, 0, 1) --Set Y axis to 0

	if walkDir.Magnitude > 0 then --(0, 0, 0).Unit = NaN, do not want
		walkDir = walkDir.Unit --Normalize, because we (probably) changed an Axis so it's no longer a unit vector
	end

	return walkDir
end


function SM.Update(character,dt, isTyping)
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid then
		MOVE_ACCELERATION = game.ReplicatedStorage.WorldAcceleration.Value
		if isTyping == false then
			local moveDir = getWalkDirectionWorldSpace()
			targetMoveVelocity = moveDir
		end
		
		moveVelocity = lerp( moveVelocity, targetMoveVelocity, math.clamp(dt * MOVE_ACCELERATION, 0, 1) )
		
		

		--print(moveVelocity.Magnitude)

		if isBusy or moveVelocity.Magnitude <= 0.2 then
			humanoid:Move(Vector3.new())
		else
			humanoid:Move( moveVelocity  )
		end
	end
end

return SM