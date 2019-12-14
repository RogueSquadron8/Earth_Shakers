local description = "A squad of mechs that fight using the land around them."
local ES_modApiExt

local function init(self)
	local extDir = self.scriptPath .."modApiExt/"
	ES_modApiExt = require(extDir .."modApiExt")
	ES_modApiExt:init(extDir)
	
	modApi:appendAsset("img/icons/Earth_Shakers_icon.png",self.resourcePath.."img/icons/Earth_Shakers_icon.png")
	modApi:appendAsset("img/weapons/EnergizeForests.png",self.resourcePath.."img/weapons/EnergizeForests.png")
	modApi:appendAsset("img/weapons/Fertilization.png",self.resourcePath.."img/weapons/Fertilization.png")
	modApi:appendAsset("img/weapons/ForcePalm.png",self.resourcePath.."img/weapons/ForcePalm.png")
	modApi:appendAsset("img/weapons/MobileFactory.png",self.resourcePath.."img/weapons/MobileFactory.png")
	
	require(self.scriptPath.."factoryPawns")
	require(self.scriptPath.."pawns")
	
	force_palm = require(self.scriptPath.."force_palm")
	
	mobile_factory = require(self.scriptPath.."mobile_factory")
	energize_forests = require(self.scriptPath.."energize_forests")
	fertilization = require(self.scriptPath.."fertilization")
	
end

local function load(self, options, version)
	ES_modApiExt:load(self, options, version)
	
	modApi:addSquadTrue({"Earth Shakers", "ForcePalmMech", "FactoryMech", "BotanyMech"}, "Earth Shakers", description)
	
	local factory_hooks = require(self.scriptPath.."mobile_factory")
	modApi:addMissionStartHook(factory_hooks.EnterMissionResetState)
	modApi:addMissionNextPhaseCreatedHook(factory_hooks.BetweenMissionPhasesResetState)
	modApi:addNextTurnHook(factory_hooks.SetStartOfTurnState)
	ES_modApiExt:addResetTurnHook(factory_hooks.RefreshState)
	
	local fertilization_hooks = require(self.scriptPath.."fertilization")
	ES_modApiExt:addPawnKilledHook(fertilization_hooks.GrowForestOnDeathHook)
	modApi:addNextTurnHook(fertilization_hooks.ConvertACIDHook)
end

return {
	id = "Earth Shakers",
	name = "Earth Shakers",
	version = "1.0",
	requirements = {},
	icon = "img/icons/Earth_Shakers_icon.png",
	init = init,
	load = load,
}