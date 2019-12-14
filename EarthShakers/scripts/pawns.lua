ForcePalmMech = {
	Name = "Force Mech",
	Class = "Prime",
	Image = "MechLeap",
	ImageOffset = 0,
	Health = 2,
	MoveSpeed = 4,
	SkillList = { "ForcePalm" },
	SoundLocation = "/mech/prime/punch_mech/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true,
}
AddPawn("ForcePalmMech")


FactoryMech = {
	Name = "Factory Mech",
	Class = "Brute",
	Image = "MechCharge",
	ImageOffset = 0,
	Health = 4,
	MoveSpeed = 2,
	SkillList = { "MobileFactory" },
	SoundLocation = "/mech/prime/punch_mech/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true,
}
AddPawn("FactoryMech")


BotanyMech = {
	Name = "Nature Mech",
	Class = "Science",
	Image = "MechScience",
	ImageOffset = 0,
	Health = 2,
	MoveSpeed = 4,
	SkillList = { "EnergizeForests", "Fertilization" },
	SoundLocation = "/mech/science/science_mech/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true,
	Flying = true,
}
AddPawn("BotanyMech")