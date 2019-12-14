Factory_Tank = Pawn:new {
	Name = "Fabricated Tank",
	Health = 1,
	MoveSpeed = 3,
	Image = "SmallTank1",
	SkillList = { "Factory_Tank_Cannon" },
	SoundLocation = "/mech/brute/tank",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Corpse = false,
	IgnoreFire = true,
}
AddPawn("Factory_Tank")

Factory_Tank_Cannon = TankDefault:new {
	Name = "Light Cannon",
	Description = "Push and deal 1 damage to the target.",
	Rarity = 0,
	Damage = 1,
	Class = "Unique",
	Icon = "weapons/deploy_tank.png",
	Push = 1,
	LaunchSound = "/weapons/stock_cannons",
	ImpactSound = "/impact/generic/explosion",
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,1),
		Target = Point(2,1),
		CustomPawn = "Factory_Tank"
	}
}

Factory_Tank_Cannon_2 = Factory_Tank_Cannon:new {
	Name = "Medium Cannon",
	Description = "Push and deal 2 damage to the target.",
	Damage = 2,
}

Factory_Tank_A = Factory_Tank:new {
	SkillList = { "Factory_Tank_Cannon_2" },
}

Factory_Tank_B = Factory_Tank:new {
	Health = 2,
	MoveSpeed = 4,
}

Factory_Tank_AB = Factory_Tank:new {
	SkillList = { "Factory_Tank_Cannon_2" },
	Health = 2,
	MoveSpeed = 4,
}
