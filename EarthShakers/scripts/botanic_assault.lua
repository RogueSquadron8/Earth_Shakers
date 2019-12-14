BotanicAssault = Skill:new{
	Name = "Botanic Assault",
	Class = "Science",
	--Icon = "",
	Description = "Pull all enemies towards adjacent undamaged forests if possible, and damage enemies already in undamaged forests. Also convert non-spawning acid tiles into forests, and create forests under all enemies if there are more enemies than undamaged forests.",
	Shield = false,
	Damage = 2,
	PowerCost = 0,
	Upgrades = 2,
	UpgradeCost = {2, 1},
	UpgradeList = {"Forest Shield", "+1 Damage"},
	--[[
	TipImage = {
	},
	]]
}

BotanicAssault_A = BotanicAssault:new{
	Shield = true,
}

BotanicAssault_B = BotanicAssault:new{
	Damage = 3,
}

BotanicAssault_AB = BotanicAssault:new{
	Shield = true,
	Damage = 3,
}

function BotanicAssault:GetTargetArea(p1)
	local ret = PointList()
	
	for dir = DIR_START, DIR_END do
		local curr = Point(p1 + DIR_VECTORS[dir])
		if Board:IsValid(curr) then
			ret:push_back(curr)
		end
	end
	
	return ret
end

function BotanicAssault:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local damage = self.Damage
	local enemyIds = Board:GetPawns(TEAM_ENEMY)
	local numEnemies = BotanicAssault:GetNumEnemies()
	local numForests =  BotanicAssault:GetNumForestSpaces()
	
	--If more enemies than forests on board, add forests under all possible enemies (need to fix so that water tiles are not transformed)
	if numEnemies > numForests then
		for _, enemyId in pairs(extract_table(enemyIds)) do
			local enemy = Board:GetPawn(enemyId)
			local p = Board:GetPawnSpace(enemyId)
			ret:AddSafeDamage(SpaceDamage(p, damage))
			ret:AddScript("Board:SetTerrain(Point("..p.x..","..p.y.."), TERRAIN_FOREST)")
			--[[				*****In case above technique fails*****
			if (Board:GetTerrain(p) == TERRAIN_ROAD or Board:GetTerrain(p) == TERRAIN_RUBBLE or Board:GetTerrain(p) == TERRAIN_SAND) then
				local AddForestDamage = SpaceDamage(p, DAMAGE_ZERO)
				AddForestDamage.iTerrain = TERRAIN_FOREST
				ret:AddDamage(AddForestDamage)
			end
			]]
		end
	end
	
	-- If upgrade is powered, shield adjacent allies and buildings
	if self.Shield then
		if Board then
			local size = Board:GetSize()
			for y = 0, size.y - 1 do
				for x = 0, size.x - 1 do
					local curr = Point(x, y)
					if Board:GetTerrain(curr) == TERRAIN_FOREST then
						for dir = 0, 3 do
							if BotanicAssault:CanShield(curr + DIR_VECTORS[dir]) then
								local shieldDam = SpaceDamage(curr + DIR_VECTORS[dir], DAMAGE_ZERO)
								shieldDam.iShield = 1
								ret:AddDamage(shieldDam)
							end
						end
					end
				end
			end
		end
	end
	
	-- Attack enemies with forests
	for _, enemyId in pairs(extract_table(enemyIds)) do
		local currTarget = Board:GetPawn(enemyId)
		local targetSpace = currTarget:GetSpace()
		if Board:GetTerrain(targetSpace) == TERRAIN_FOREST then		--For enemies on forests
			ret:AddDamage(SpaceDamage(targetSpace, damage))			--intentionally set forests on fire
		else
			for i = 0, 3 do										--For enemies near forests
				local space = targetSpace + DIR_VECTORS[i]
				if Board:GetTerrain(space) == TERRAIN_FOREST and not Board:IsPawnSpace(space) and Board:GetTerrain(targetSpace) ~= TERRAIN_FOREST then
					pushDir = GetDirection(space - targetSpace)
					ret:AddDamage(SpaceDamage(targetSpace, 0, pushDir))
				end
			end
		end
	end
	
	-- Convert acid tiles to forests
	local acidSpaces = BotanicAssault:GetUnoccupiedAcidSpaces()
	for _, space in pairs(extract_table(acidSpaces)) do
		if not Board:IsSpawning(space) then
			ret:AddScript("Board:ClearSpace(Point("..space.x..","..space.y.."))")
		else 
			ret:AddScript("Board:SetFire(Point("..space.x..","..space.y.."), false)")
		end
		local addForestDam = SpaceDamage(space, 0)
		addForestDam.iTerrain = TERRAIN_FOREST
		ret:AddDamage(addForestDam)
	end
	
	return ret
end


function BotanicAssault:GetUnoccupiedAcidSpaces()
	local ret = PointList()
	if Board then
		local size = Board:GetSize()
		for y = 0, size.y - 1 do
			for x = 0, size.x - 1 do
				local curr = Point(x, y)
				if Board:IsAcid(curr) and (Board:GetTerrain(curr) == TERRAIN_ROAD or Board:GetTerrain(curr) == TERRAIN_RUBBLE or Board:GetTerrain(curr) == TERRAIN_SAND)
						and not Board:IsPawnSpace(curr) then
					ret:push_back(curr)
				end
			end
		end
	end
	return ret
end

function BotanicAssault:GetNumForestSpaces()
	local numForests = 0
	if Board then
		local size = Board:GetSize()
		for y = 0, size.y - 1 do
			for x = 0, size.x - 1 do
				local curr = Point(x, y)
				if Board:GetTerrain(curr) == TERRAIN_FOREST then
					numForests = numForests + 1
				end
			end
		end
	end
	return numForests
end

function BotanicAssault:GetNumEnemies()
	local numEnemies = 0
	local enemyIds = Board:GetPawns(TEAM_ENEMY)
	for _, enemyId in pairs(extract_table(enemyIds)) do
		numEnemies = numEnemies + 1
	end
	return numEnemies
end

function BotanicAssault:CanShield(p)
	return Board:IsBuilding(p) or (Board:IsPawnSpace(p) and Board:IsPawnTeam(p, TEAM_PLAYER))
end

--[[
function BotanicAssault:GetNumEnemies()
	local numEnemies = 0
	if Board then
		local size = Board:GetSize()
		for y = 0, size.y - 1 do
			for x = 0, size.x - 1 do
				local curr = Point(x, y)
				if Board:IsPawnSpace(curr) and Board:IsPawnTeam(curr, TEAM_ENEMY) then
					numEnemies = numEnemies + 1
				end
			end
		end
	end
	return numEnemies
end]]

-- Make shield work on special structures?

--[[		IDEAS
Split into 2 weapons:
	Weapon 1: Energize Forests: Causes Forests to damage enemies and shield allies on top of them. (Do not light fires)
	Additionally, the forest on the tile that is specifically targeted will affect all adjacent tiles
		Upgrade 1 (2): Boosted energy - deals 1 more damage and heals allies by 1
		Upgrade 2 (1): ??? - grow forests under enemies until there are an equal number of undamaged forests and enemies on the board (does not damage)
	Weapon 2: Fertilization (Passive): Causes a forest to grow on any tile where an enemy dies
		Upgrade 1 (3): Mass Growth - grows 3 forests in a randomized cross pattern instead of one
		Upgrade 2 (1): ACID - grows forests on ACID tiles
]]