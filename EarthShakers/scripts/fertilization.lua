Fertilization = Skill:new{
	Name = "Fertilization",
	Icon = "weapons/Fertilization.png",
	Description = "Causes a forest to grow on any tile where a vek dies.",
	Passive = "Fertilization",
	PowerCost = 0,
	Upgrades = 2,
	UpgradeCost = {2, 1},
	UpgradeList = {"Mass Growth", "ACID"},
	--CustomTipImage = "Fertilization_Tip",
}

Fertilization_A = Fertilization:new{
	Passive = "Fertilization_A",
	UpgradeDescription = "Grows an additional forest in a randomly chosen adjacent space if possible.",
}

Fertilization_B = Fertilization:new{
	Passive = "Fertilization_B",
	UpgradeDescription = "Grows forests on unoccupied tiles with ACID at the start of each turn.",
}

Fertilization_AB = Fertilization:new{
	Passive = "Fertilization_AB",
}

--[[		Cannot get SkillEffect to show up
Fertilization_Tip = Fertilization:new{
	TipImage = {
		
		Enemy = Point(2,3),
		Target = Point(2,3),
		--Length = 2
	}
}
function Fertilization_Tip:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local damage = SpaceDamage(Point(2,3), DAMAGE_DEATH)
	damage.bHide = true
	ret:AddDamage(damage)
	return ret
end
]]

local function isSafeToGrow(p)
	if (Board:GetTerrain(p) ~= 1) and (Board:GetTerrain(p) ~= TERRAIN_HOLE) and (Board:GetTerrain(p) ~= 9) and (Board:GetTerrain(p) ~= 5) and (Board:GetTerrain(p) ~= 14) 
	and (Board:GetTerrain(p) ~= 4) and (Board:GetTerrain(p) ~= 3) and Board:IsValid(p) and not (Board:GetTerrain(p) == TERRAIN_FOREST and not Board:IsFire(p)) then
		return true
	else
		return false
	end
end

local function GetRandValidDir(p, alreadyChosenDirection)
	local canGrow = false
	for dir = DIR_START, DIR_END do
		local curr = Point(p + DIR_VECTORS[dir])
		if not ((not isSafeToGrow(Point(p + DIR_VECTORS[dir]))) or Board:GetTerrain(Point(p + DIR_VECTORS[dir])) == TERRAIN_FOREST or dir == alreadyChosenDirection) then
			canGrow = true
		end
	end
	if not canGrow then return -1 end
	local dir = math.random(0, 3)
	while (not isSafeToGrow(Point(p + DIR_VECTORS[dir]))) or Board:GetTerrain(Point(p + DIR_VECTORS[dir])) == TERRAIN_FOREST or dir == alreadyChosenDirection do
		dir = math.random(0, 3)
	end
	return dir
end

local GrowForestOnDeathHook = function(mission, pawn)
	if pawn:GetTeam() == TEAM_ENEMY then
		local p = pawn:GetSpace()
		
		if IsPassiveSkill("Fertilization") or IsPassiveSkill("Fertilization_A") or IsPassiveSkill("Fertilization_B") or IsPassiveSkill("Fertilization_AB") then
			--LOG("Passive Seen")
			if isSafeToGrow(p) then
				Board:SetFire(p, false)
				Board:SetTerrain(p, TERRAIN_FOREST)
				Board:AddAlert(p, "Forest Grown")
			end
			if IsPassiveSkill("Fertilization_A") or IsPassiveSkill("Fertilization_AB") then
				local dir1 = GetRandValidDir(p, -1)
				local dir2 = -1
				if dir1 ~= -1 then
					point = Point(p + DIR_VECTORS[dir1])
					Board:SetFire(point, false)
					Board:SetTerrain(point, TERRAIN_FOREST)
					Board:AddAlert(point, "Forest Grown")
					--[[
					dir2 = GetRandValidDir(p, dir1)
					if dir2 ~= -1 then 
						point = Point(p + DIR_VECTORS[dir2])
						Board:SetFire(point, false)
						Board:SetTerrain(point, TERRAIN_FOREST)
						Board:AddAlert(point, "Forest Grown")
					end
					]]
				end
				--LOG(dir1.." "..dir2)
			end
		else
			--LOG("Passive not seen")
		end
	end
end

local ConvertACIDHook = function(mission)
	if IsPassiveSkill("Fertilization_B") or IsPassiveSkill("Fertilization_AB") then
		local acidSpaces = PointList()
		if Board then
			local size = Board:GetSize()
			for y = 0, size.y - 1 do
				for x = 0, size.x - 1 do
					local curr = Point(x, y)
					if Board:IsAcid(curr) and (Board:GetTerrain(curr) == TERRAIN_ROAD or Board:GetTerrain(curr) == TERRAIN_RUBBLE or Board:GetTerrain(curr) == TERRAIN_SAND)
							and not Board:IsPawnSpace(curr) then
						acidSpaces:push_back(curr)
					end
				end
			end
		end

		for _, space in pairs(extract_table(acidSpaces)) do
			
			if not Board:IsSpawning(space) then
				Board:ClearSpace(space)
			else 
				Board:SetFire(space, false)
			end
			Board:SetTerrain(space, TERRAIN_FOREST)
			Board:AddAlert(space, "Forest Grown")
		end
	end
end

return {
	GrowForestOnDeathHook = GrowForestOnDeathHook,
	ConvertACIDHook = ConvertACIDHook,
}