--Uses Lemonymous' weapons api
local getWeaponsApi = require(mod_loader.mods[modApi.currentMod].scriptPath .."getWeapons")

WasteEject = Skill:new{
	Name = "Eject Waste",
	Class = "Brute",
	--Icon = "",
	Description = "Eject waste onto nearby tiles, allowing you to reuse the Matter Recycler.",
	--ProjectileArt = "effects/shot_spear",
	PathSize = 1,
	PowerCost = 0,
	Upgrades = 2,
	UpgradeCost = {1, 1},
	UpgradeList = {"+1 Range", "+1 Range"},
	TipImage = {
		Unit = Point(2,0),
		CustomPawn = "FactoryMech",
		Enemy = Point(2,1),
		Target = Point(2,1)
	},
}

function WasteEject:GetTargetArea(p1)
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

function WasteEject:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	local distance = p1:Manhattan(p2)
	
	for i = 1, distance do 
		local spaceDam = SpaceDamage(p1 + DIR_VECTORS[dir]*i, 0)
		spaceDam.iAcid = 1
		ret:AddDamage(spaceDam)
	 end
	
	if Board:IsMissionBoard() then
		local weapons = getWeaponsApi.GetPoweredBase(Board:GetPawn(p1))
		for i = 1, 2 do
			if weapons[i] == "Recycler" then
				ret:AddScript("Board:GetPawn(Point("..p1.x..","..p1.y..")):ResetUses()")
			end
		end
	end
	
	return ret
end

WasteEject_A = WasteEject:new{
	UpgradeDescription = "Acid can reach one more tile.",
	PathSize = 2,
	TipImage = {
		Unit = Point(2,0),
		CustomPawn = "FactoryMech",
		Enemy = Point(2,2),
		Target = Point(2,2)
	},
}

WasteEject_B = WasteEject:new{
	UpgradeDescription = "Acid can reach one more tile.",
	PathSize = 2,
	TipImage = {
		Unit = Point(2,0),
		CustomPawn = "FactoryMech",
		Enemy = Point(2,2),
		Target = Point(2,2)
	},
}

WasteEject_AB = WasteEject:new{
	PathSize = 3,
	TipImage = {
		Unit = Point(2,0),
		CustomPawn = "FactoryMech",
		Enemy = Point(2,3),
		Target = Point(2,3)
	},
}