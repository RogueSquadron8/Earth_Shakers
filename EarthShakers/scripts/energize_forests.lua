EnergizeForests = Skill:new{
	Name = "Energize Forests",
	Class = "Science",
	Icon = "weapons/EnergizeForests.png",
	Description = "For all units on forest tiles or near a targeted forest tile, deal 1 damage if the target is an enemy or give a shield if the unit is an ally. Up to two units can be shielded per use. Affects tiles adjacent to the targeted tile.",
	Damage = 1,
	ShieldCap = 2,
	Heal = false,
	Stun = false,
	PowerCost = 0,
	Upgrades = 2,
	UpgradeCost = {2, 1},
	UpgradeList = {"Boosted Energy", "Forest Stun"},
	CustomTipImage = "EnergizeForests_Tip",
	Projectile = "effects/shot_pull_U.png",
}

function EnergizeForests:GetTargetArea(p1)
	local ret = PointList()
	for dir = DIR_START, DIR_END do
		for i = 2, 8 do
			local curr = Point(p1 + DIR_VECTORS[dir] * i)
			if not Board:IsValid(curr) then
				break
			end
			--Allow any forest space to be targeted, as well as any tile occupied by an enemy if the forest stun upgrade is powered
			if Board:GetTerrain(curr) == TERRAIN_FOREST or (Board:IsPawnSpace(curr) and Board:GetPawnTeam(curr) == TEAM_ENEMY and self.Stun) then
				ret:push_back(curr)
			end
		end
	end
	return ret
end

function EnergizeForests:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local targets = EnergizeForests:GetImpactedSpaces(p2)
	local enemyIds = Board:GetPawns(TEAM_ENEMY)
	local shieldsAdded = 0
	
	if self.Stun and Board:IsPawnSpace(p2) and Board:IsPawnTeam(p2, TEAM_ENEMY) then
		local damage = SpaceDamage(p2, 0)
		damage.sAnimation = "ExploRepulse3"
		ret:AddDamage(damage)
		ret:AddScript("Board:GetPawn(Point("..p2.x..","..p2.y..")):ClearQueued()")
		ret:AddScript("Board:AddAlert(Point("..p2.x..","..p2.y.."),\"Attack cancelled\")")
	end
	
	artyDam = SpaceDamage(p2, 0)
	ret:AddArtillery(artyDam, self.Projectile) 
	
	for _, p in pairs(extract_table(targets)) do
		local dam = SpaceDamage(p, 0)
		if Board:IsPawnSpace(p) then
			if Board:IsPawnTeam(p, TEAM_ENEMY) then
				dam.iDamage = self.Damage
			elseif Board:IsPawnTeam(p, TEAM_PLAYER) then
				if not Board:GetPawn(p):IsShield() and shieldsAdded < self.ShieldCap then
					dam.iShield = 1
					shieldsAdded = shieldsAdded + 1
				end
				if self.Heal then
					dam.iDamage = -1
				end
			end
		else
			dam.iShield = 1
		end
		ret:AddDamage(dam)
	end
	return ret
end

EnergizeForests_A = EnergizeForests:new{
	UpgradeDescription = "Deal 1 extra damage to enemies and heal allies by 1",
	Damage = 2,
	Heal = true,
	CustomTipImage = "EnergizeForests_Tip_A",
}
EnergizeForests_B = EnergizeForests:new{
	UpgradeDescription = "If targeting an enemy, cancel its attack",
	Stun = true,
	CustomTipImage = "EnergizeForests_Tip_B",
}
EnergizeForests_AB = EnergizeForests:new{
	Damage = 2,
	Heal = true,
	Stun = true,
	CustomTipImage = "EnergizeForests_Tip_AB",
}

function EnergizeForests:GetForestSpaces()
	local ret = PointList()
	if Board then
		local size = Board:GetSize()
		for y = 0, size.y - 1 do
			for x = 0, size.x - 1 do
				local curr = Point(x, y)
				if Board:GetTerrain(curr) == TERRAIN_FOREST then
					ret:push_back(curr)
				end
			end
		end
	end
	return ret
end

--Figure out which spaces need damage or shields applied
function EnergizeForests:GetImpactedSpaces(TargetedPoint)
	local ret = PointList()
	local possibleTargets = EnergizeForests:GetForestSpaces()
	if Board:GetTerrain(TargetedPoint) == TERRAIN_FOREST then
		for dir = DIR_START, DIR_END do
			local curr = Point(TargetedPoint + DIR_VECTORS[dir])
			if Board:GetTerrain(curr) ~= TERRAIN_FOREST then
				possibleTargets:push_back(curr)
			end
		end
	end
	for _, p in pairs(extract_table(possibleTargets)) do
		if Board:IsPawnSpace(p) or Board:IsBuilding(p) then
			ret:push_back(p)
		end
	end
	return ret
end

EnergizeForests_Tip = EnergizeForests:new{
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,1),
		Target = Point(2,1),
		Forest = Point(2,1),
		CustomEnemy = "Firefly2",
		Enemy2 = Point(3,3),
		Forest2 = Point(3,3),
		Length = 4
	}
}

function EnergizeForests_Tip:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	ret.piOrigin = Point(2,3)
	local damage
	if self.Stun then
		-- qeue enemy attack
		damage = SpaceDamage(0)
		damage.bHide = true
		damage.sScript = "Board:GetPawn(Point(2,1)):FireWeapon(Point(2,2),1)"
		ret:AddDamage(damage)
		-- add delay
		damage = SpaceDamage(0)
		damage.bHide = true
		damage.fDelay = 1.5
		ret:AddDamage(damage)
	end
	-- artillery projectile
	artyDam = SpaceDamage(Point(2,1), 0)
	artyDam.bHide = true
	ret:AddArtillery(artyDam, self.Projectile)
	if self.Stun then
		-- cancel enemy attack
		damage = SpaceDamage(p2,0,DIR_FLIP)
		damage.bHide = true
		damage.sAnimation = "ExploRepulse3"
		damage.sScript = "Board:GetPawn(Point("..p2.x..","..p2.y..")):ClearQueued()"
		ret:AddDamage(damage)
		ret:AddScript("Board:AddAlert(Point("..p2.x..","..p2.y.."),\"Attack cancelled\")")
	end 
	-- damage enemies on forests
	damage = SpaceDamage(Point(2,1), self.Damage)
	damage.bHide = true
	ret:AddDamage(damage)
	damage = SpaceDamage(Point(3,3), self.Damage)
	damage.bHide = true
	damage.fDelay = 0.5
	ret:AddDamage(damage)
	return ret
end

EnergizeForests_Tip_A = EnergizeForests_Tip:new{
	Damage = 2,
}

EnergizeForests_Tip_B = EnergizeForests_Tip:new{
	Stun = true,
}

EnergizeForests_Tip_AB = EnergizeForests_Tip_A:new{
	Stun = true,
}