-- Debugger Module GUI Thingy 
-- Created by Boogagle
-- Version 1.0 (December 27th, 2020)

-- It's best if this all goes somewhere in game.ReplicatedStorage


local module = {}
local RS = game:GetService("RunService")

module.DebugGui = nil
module.DataTemplate = nil

_G.DebugValues = {}

function module.new(DataTemplate, DebugGui, Autoscale, RandomColors)

	if RS:IsServer() then warn("Debugger Module was attempted to be used in server code") return end

	if not DebugGui:IsA("ScreenGui") then warn("Passed DebugGui Instance is not a ScreenGui") return end
	if not DataTemplate:IsA("Frame") then warn("Passed DataTemplate Instance is not a Frame") return end

	local GUI = DebugGui:Clone()

	module.DebugGui = GUI -- Screen Gui Instance

	module.DataTemplate = DataTemplate -- Frame Instance

	module.Autoscale = Autoscale -- Boolean

	module.RandomColors = RandomColors -- Boolean

	return GUI
end

function module.UpdateValue(Name, NewValue)
	if RS:IsServer() then warn("Debugger Module was attempted to be used in server code") return end

	if _G.DebugValues[Name] then
		_G.DebugValues[Name]['Value'] = NewValue -- If a value is already in the table, update it rather then rewrite it.
	else
		math.randomseed(#Name*320) -- This is for coloring the GUIS randomly based off of the length of their name, the 320 was a random number I thought of.

		if module.RandomColors then
			_G.DebugValues[Name] = {Value = NewValue, Color = Color3.fromRGB(math.random(50,150),math.random(50,150),math.random(50,150))} -- Creates a new value, key & color
		else
			_G.DebugValues[Name] = {Value = NewValue} -- Creates a new value & key
		end

	end

end


function module.DisplayValues()

	if RS:IsServer() then warn("Debugger Module was attempted to be used in server code") return end


	local StartTick = tick()

	for _, v in pairs(module.DebugGui.Main:GetChildren()) do
		if v:IsA("Frame") then
			v:Destroy() -- Wipes out the previous frames, would use ClearAllChildren but it would delete the list, so.
		end
	end

	for k, v in pairs(_G.DebugValues) do -- Loops through all the data stored and saves it
		if v.Value == nil then
			_G.DebugValues[k] = nil
		else
			local b = module.DataTemplate:Clone()
			b.Parent = module.DebugGui.Main
			b.Label.Text = tostring(k)
			b.Value.Text = tostring(v.Value)
			if module.RandomColors then
				b.Value.TextColor3 = v.Color
				b.Label.BackgroundColor3 = v.Color
			end
		end


	end

	if module.Autoscale then
		module.DebugGui.Main.Size = UDim2.new(0,250,0,module.DebugGui.Main.UIListLayout.AbsoluteContentSize.Y)
	end


	return tick() - StartTick -- Returns time it took to display values.
end


return module
