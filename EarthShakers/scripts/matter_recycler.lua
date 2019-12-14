Recycler = Skill:new{
	Name = "Matter Recycler",
	Class = "Brute",
	--Icon = "",
	Description = "Destroy a Mountain or rock and convert it into a combat-ready tank. Only 2 tanks can be active at one time.",
	PathSize = 1,
	Limited = 1,
	PowerCost = 0,
	PawnProduced = "Factory_Tank",
	Upgrades = 2,
	UpgradeCost = {3, 2},
	UpgradeList = {"+2 damage", "+1 HP and move"},
	TipImage = {
		Unit = Point(2,2),
		CustomPawn = "FactoryMech",
		Mountain = Point(2,3),
		Target = Point(2,3)
	},
}

function Recycler:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local spaceDam = SpaceDamage(p2, 0)

	if Board:GetTerrain(p2) == TERRAIN_MOUNTAIN or (Board:IsPawnSpace(p2) and (Board:GetPawn(p2):GetType() == "RockThrown" or Board:GetPawn(p2):GetType() == "Wall")) then
		spaceDam = SpaceDamage(p2, DAMAGE_DEATH)
		spaceDam.sPawn = self.PawnProduced
	end
	 
	ret:AddDamage(spaceDam)
	return ret
end

Recycler_A = Recycler:new {
	UpgradeDescription = "Tanks deal 3 damage",
	PawnProduced = "Factory_Tank_A",
}

Recycler_B = Recycler:new {
	UpgradeDescription = "Tanks have more health and movement",
	PawnProduced = "Factory_Tank_B",
}

Recycler_AB = Recycler:new {
	PawnProduced = "Factory_Tank_AB",
}