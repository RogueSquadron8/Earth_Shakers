ForcePalm = Skill:new{
	Name = "Force Palm",
	Class = "Prime",
	Icon = "weapons/ForcePalm.png",
	Description = "Push an adjacent unit up to 3 tiles and damage it, or create rocks on up to 3 tiles while damaging units in the way. Does not damage friendly units or buildings.",
	PathSize = 3,
	Damage = 2,
	BounceAmount = 3,
	PowerCost = 0,
	Upgrades = 2,
	UpgradeCost = {3, 2},
	UpgradeList = {"+1 Range", "+1 Damage"},
	TipImage = {
		Unit = Point(2,1),
		CustomPawn = "ForcePalmMech",
		Enemy = Point(2,3),
		Target = Point(2,3),
		Enemy2 = Point(3,1),
		Second_Origin = Point(2,1),
		Second_Target = Point(3,1),
	},
}

function ForcePalm:GetTargetArea(p1)
	local ret = PointList()
	
		for dir = DIR_START, DIR_END do
			for i = 1, self.PathSize do
				local curr = Point(p1 + DIR_VECTORS[dir] * i)
				if not Board:IsValid(curr) or Board:GetTerrain(curr) == TERRAIN_MOUNTAIN then
					break
				end
				
				ret:push_back(curr)
			end
		end
	
	return ret
end

function ForcePalm:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	local distance = p1:Manhattan(p2)
	local adjacent = p1 + DIR_VECTORS[dir]
	
	if Board:IsPawnSpace(adjacent) and not Board:GetPawn(adjacent):IsGuarding() then
		local damage = self.Damage
		if Board:GetPawn(adjacent):GetTeam() == TEAM_PLAYER then damage = 0 end
		ret:AddDamage(SpaceDamage(adjacent, damage))
		if adjacent ~= p2 then 
			local chargeEnd = adjacent
			repeat chargeEnd = chargeEnd + DIR_VECTORS[dir]
				until Board:IsBlocked(chargeEnd, PATH_PROJECTILE) or chargeEnd == p2
			ret:AddCharge(Board:GetSimplePath(adjacent, chargeEnd), NO_DELAY)
		end
	else
		for i = 1, distance do 
			local curr = Point(p1 + DIR_VECTORS[dir]*i)
			local damage = self.Damage
			if (Board:IsPawnSpace(curr) and Board:GetPawn(curr):GetTeam() == TEAM_PLAYER) or Board:IsBuilding(curr) then
				damage = 0
			end
			local spaceDam = SpaceDamage(curr, damage)
			if not Board:IsBlocked(curr, PATH_PROJECTILE) then 
				spaceDam.sPawn = "RockThrown"
				ret:AddBounce(curr, self.BounceAmount)
			end
			ret:AddBoardShake(0.15)
			ret:AddDamage(spaceDam)
		end
	end
	return ret
end

ForcePalm_A = ForcePalm:new{
	PathSize = 4,
}

ForcePalm_B = ForcePalm:new{
	Damage = 3,
}

ForcePalm_AB = ForcePalm:new{
	PathSize = 4,
	Damage = 3,
}
