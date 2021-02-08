-- This script was intended for use with CloneTrooper's VMF importer, it helped optimize maps into something uploadable to Roblox.


local Map = game.Workspace.world
local Groups = {}

local UseFolders = true -- If this is true it will use folders rather then models, and vice versa if false.

-- =======================================================
function createGroup()
	if UseFolders then return Instance.new("Folder", workspace) end
	return Instance.new("Model", workspace)
end

for _, v in pairs(Map:GetDescendants()) do
	if v:IsA("BasePart") then
		local BrickColor = tostring(v.BrickColor)
		local Material = string.gsub(tostring(v.Material), "Enum.Material.", "")
		
		if Groups[BrickColor] then
			
			if Groups[BrickColor]:FindFirstChild(Material) then
				v.Parent = Groups[BrickColor]:FindFirstChild(Material)
			else
				local GM = createGroup() -- Group Material
				GM.Parent = Groups[BrickColor]
				GM.Name = Material
			end
			
			
		else
			local G = createGroup() -- Group
			G.Name = BrickColor
			Groups[BrickColor] = G
			
			if Groups[BrickColor]:FindFirstChild(Material) then
				v.Parent = Groups[BrickColor]:FindFirstChild(Material)
			else
				local GM = createGroup() -- Group Material
				GM.Parent = Groups[BrickColor]
				GM.Name = Material
				v.Parent = Groups[BrickColor]:FindFirstChild(Material)
			end
			
		end
		
		
	end
end
