MobileFactory = Skill:new{
	Name = "Matter Recycler",
	Class = "Brute",
	Icon = "weapons/MobileFactory.png",
	Description = "Destroy a Mountain or rock and convert it into a flame-resistant tank. Between uses, excess ACID waste must be ejected.",
	PathSize = 1,
	NeedEjectStateAtStartOfTurn = false,
	NeedEject = false,
	PowerCost = 0,
	PawnProduced = "Factory_Tank",
	Upgrades = 2,
	UpgradeCost = {2, 2},
	UpgradeList = {"+1 damage", "+1 HP and move"},
	CustomTipImage = "MobileFactory_Tip",
}

function MobileFactory:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local spaceDam
	local dir = GetDirection(p2 - p1)
	local UserID = Board:GetPawn(p1):GetId()
	
	if not self.NeedEject then
		if Board:GetTerrain(p2) == TERRAIN_MOUNTAIN or (Board:IsPawnSpace(p2) and (Board:GetPawn(p2):GetType() == "RockThrown" or Board:GetPawn(p2):GetType() == "Wall")) then
			spaceDam = SpaceDamage(p2, DAMAGE_DEATH)
			spaceDam.sPawn = self.PawnProduced
			ret:AddDamage(spaceDam)
		end
		ret:AddScript("MobileFactory.NeedEject = true")
	else
		for i = 2, 1, -1 do 
			local spaceDam = SpaceDamage(p1 + DIR_VECTORS[dir]*i, 0)
			spaceDam.iAcid = 1
			spaceDam.iPush = dir
			ret:AddDamage(spaceDam)
			if i == 2 then ret:AddDelay(0.1) end
		end
		ret:AddScript("MobileFactory.NeedEject = false")
	end
	
	return ret
end

MobileFactory_A = MobileFactory:new{
	UpgradeDescription = "Tanks deal 2 damage",
	PawnProduced = "Factory_Tank_A",
	CustomTipImage = "MobileFactory_Tip_A",
}

MobileFactory_B = MobileFactory:new{
	UpgradeDescription = "Tanks have more health and movement",
	PawnProduced = "Factory_Tank_B",
}

MobileFactory_AB = MobileFactory:new{
	PawnProduced = "Factory_Tank_AB",
	CustomTipImage = "MobileFactory_Tip_A",
}

MobileFactory_Tip = MobileFactory:new{
	TipImage = {
		Unit = Point(2,2),
		CustomPawn = "FactoryMech",
		Mountain = Point(2,3),
		Target = Point(2,3),
		Enemy = Point(3,3),
		Enemy2 = Point(2,1),
		Second_Origin = Point(2,3),
		Second_Target = Point(3,3),
	},
}

function MobileFactory_Tip:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	ret.piOrigin = Point(2,2)
	local damage
	
	damage = SpaceDamage(p2, DAMAGE_DEATH)
	damage.sPawn = self.PawnProduced
	damage.bHide = true
	ret:AddDamage(damage)
	ret:AddDelay(2.5)
	damage = SpaceDamage(Point(2,1), 0)
	damage.iAcid = 1
	damage.iPush = 0
	damage.bHide = true
	ret:AddDamage(damage)

	return ret
end

MobileFactory_Tip_A = MobileFactory_Tip:new{
	PawnProduced = "Factory_Tank_A",
}

-- Ensures that the weapon is ready to fabricate a tank at the start of each mission
local EnterMissionResetState = function(mission)
	MobileFactory.NeedEject = false
	--LOG("hook fired")
end
local BetweenMissionPhasesResetState = function(p, n)
	MobileFactory.NeedEject = false
	--LOG("hook fired")
end

--These functions ensure that the state of the weapon is renewed when reset turn is called
local SetStartOfTurnState = function(mission)
	if Game:GetTeamTurn() == TEAM_PLAYER then
		MobileFactory.NeedEjectStateAtStartOfTurn = MobileFactory.NeedEject
	end
	--LOG("hook fired")
end
local RefreshState = function(mission)
	MobileFactory.NeedEject = MobileFactory.NeedEjectStateAtStartOfTurn
	--LOG("hook fired")
end

return {
	EnterMissionResetState = EnterMissionResetState,
	BetweenMissionPhasesResetState = BetweenMissionPhasesResetState,
	SetStartOfTurnState = SetStartOfTurnState,
	RefreshState = RefreshState,
}