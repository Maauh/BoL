--[[

Script by spyk for Sona.

BaguetteSona.lua

Github link : https://github.com/spyk1/BoL/blob/master/BaguetteSona/BaguetteSona.lua

Forum Thread : http://forum.botoflegends.com/topic/88896-beta-baguette-sona/

]]--


local buffs = {
    ["JudicatorIntervention"] = true,
    ["UndyingRage"] = true,
    ["ZacRebirthReady"] = true,
    ["AatroxPassiveDeath"] = true,
    ["FerociousHowl"] = true,
    ["VladimirSanguinePool"] = true,
    ["ChronoRevive"] = true,
    ["ChronoShift"] = true,
    ["KarthusDeathDefiedBuff"] = true,
    ["zhonyasringshield"] = true,
    ["lissandrarself"] = true,
    ["bansheesveil"] = true,
    ["SivirE"] = true,
    ["NocturneW"] = true,
    ["kindredrnodeathbuff"] = true
}

if myHero.charName ~= "Sona" then return end

function EnvoiMessage(msg)

	PrintChat("<font color=\"#e74c3c\"><b>[BaguetteSona]</b></font> <font color=\"#ffffff\">" .. msg .. "</font>")
end

function CurrentTimeInMillis()
	return (os.clock() * 1000);
end

local TextList = {"AA+ = Kill", "Ignite = Kill", "Q = Kill", "Q + Ignite = Kill", "Q + R = Kill", "Q + R + Ignite = Kill", "Q + R + Ignite + AA+ = KILL", "Not Killable"}
local KillText = {}
local Last_LevelSpell = 0
local Qdmg = ((40 * myHero:GetSpellData(_Q).level + 10 * myHero:GetSpellData(_R).level + .5 * myHero.ap) or 0)
local Rdmg = ((100 * myHero:GetSpellData(_R).level + 50 + .5 * myHero.ap) or 0)
local Ignite = "Aatrox", "FiddleSticks", "Galio", "Irelia", "Maokai", "MasterYi", "Nasus", "Nidalee", "Olaf", "Nunu", "Riven", "Ryze", "Soraka", "TahmKench", "Vladimir", "Warwick", "Zac"
local Exhaust = "Annie", "Akali", "Azir", "Brand", "Cassiopeia", "Darius", "Diana", "Draven", "Elise", "Fiora", "FiddleSticks", "Fizz", "Graves", "Illaoi", "Jax", "Karthus", "Katarina", "Khazix", "Kindred", "Leblanc", "Lux", "MasterYi", "Nasus", "Olaf", "Orianna", "Poppy", "Renekton", "Rengar", "Riven", "Ryze", "Syndra", "Talon", "Tryndamere", "Trundle", "Udyr", "Veigar", "Vayne", "Viktor", "VelKoz", "MonkeyKing", "Yasuo", "Zed", "Zyra"
local ExhaustI = "Zed", "Yasuo", "Vayne", "Twitch", "Varus", "Tryndamere", "Tristana", "Talon", "Sivir", "Ryze", "Riven", "Rengar", "Quinn", "MasterYi", "MissFortune", "Lucian", "KogMaw", "Kindred", "Katarina", "Kalista", "Jinx", "Ezreal", "Caitlyn", "Ashe", "Corki"
local OnRecall = 0

--- Starting AutoUpdate
local version = "0.302"
local author = "spyk"
local SCRIPT_NAME = "BaguetteSona"
local AUTOUPDATE = true
local UPDATE_HOST = "raw.githubusercontent.com"
local UPDATE_PATH = "/spyk1/BoL/master/BaguetteSona/BaguetteSona.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH
local whatsnew = 0

if AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/spyk1/BoL/master/BaguetteSona/BaguetteSona.version")
	if ServerData then
		ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
		if ServerVersion then
			if tonumber(version) < ServerVersion then
				EnvoiMessage("New version available "..ServerVersion)
				EnvoiMessage(">>Updating, please don't press F9<<")
				DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () EnvoiMessage("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
				whatsnew = 1
			else
				DelayAction(function() EnvoiMessage("Hello, "..GetUser()..". You got the latest version! :) ("..ServerVersion..")") end, 3)
			end
		end
		else
			EnvoiMessage("Error downloading version info")
	end
end
 --- End Of AutoUpdate

 function OnLoad()

	--
	print("<font color=\"#ffffff\">Loading</font><font color=\"#e74c3c\"><b> [BaguetteSona]</b></font> <font color=\"#ffffff\">by spyk</font>")
	--
	if whatsnew == 1 then
		DelayAction(function() EnvoiMessage("What's new : 'Fixed Nebelwolfi Orbwalker.'")end, 0)
		whatsnew = 0
	end
	--
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then Ignite = SUMMONER_1 elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then Ignite = SUMMONER_2 else Ignite = NONE end
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerExhaust") then Exhaust = SUMMONER_1 elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerExhaust") then Exhaust = SUMMONER_2 else Exhaust = NONE end
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerFlash") then Flash = SUMMONER_1 elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerFlash") then Flash = SUMMONER_2 else Flash = NONE end

	Menu()

	CustomLoad()

end

function OnUnload()
	EnvoiMessage("Unloaded.")
	EnvoiMessage("There is no music anymore between us... Ciao!")
	if Param.Miscellaneous.Skin.Enable then
		SetSkin(myHero, -1)
	end
end

function CustomLoad()
	enemyMinions = minionManager(MINION_ENEMY, 700, myHero, MINION_SORT_HEALTH_ASC)
	jungleMinions = minionManager(MINION_JUNGLE, 700, myHero, MINION_SORT_MAXHEALTH_DEC)
	ts = TargetSelector(TARGET_LESS_CAST_PRIORITY, 1000, DAMAGE_MAGIC)
	ts.name = "Sona"
	Param:addTS(ts)
	PriorityOnLoad()
	LoadVPred()
	AutoLvlSpellCombo()
	LoadVPred()
	if Param.Miscellaneous.Skin.Enable then
		SetSkin(myHero, Param.Miscellaneous.Skin.skins -1)
	end
	if _G.Reborn_Loaded ~= nil then
   		LoadSACR()
   	elseif _Pewalk then
   		LoadPewalk()
	elseif Param.orbwalker.n1 == 1 then
		EnvoiMessage("SxOrbWalk loading..")
		LoadSXOrb()
	elseif Param.orbwalker.n1 == 2 then
		EnvoiMessage("BigFat OrbWalker loading..")
		LoadBFOrb()
	elseif Param.orbwalker.n1 == 3 then
		local neo = 1
		EnvoiMessage("Nebelwolfi's Orb Walker loading..")
		NebelOrb()
	end
	LoadSpikeLib()
end

function OnDraw()
	if not Param.drawing.Enable then
		if not myHero.dead then
			for _, unit in pairs(GetEnemyHeroes()) do
				if unit ~= nil and GetDistance(unit) <= 1000 then
					if myHero:CanUseSpell(_R) == READY then
						local aoeCastPos, hitChance, castInfo, nTargets
						aoeCastPos, hitChance, nTargets = VP:GetLineAOECastPosition(unit, 0.5, 120, 900, 2400, myHero)
						nTargets = 1
						if nTargets > 0 and nTargets < 4 then
							DrawText("Can Hit : '"..nTargets.."' with _R.", 50, 50, 200, 0xFFFFFFFF)
						elseif nTargets > 4 then
							DrawText("Can Hit : '"..nTargets.."' with _R !!", 50, 50, 200, 0xFFFF0000)
						end
					end
				end
			end
			if myHero:CanUseSpell(_Q) == READY and Param.drawing.Qdraw then 
				DrawCircle3D(myHero.x, myHero.y, myHero.z, 850, 1, 0xFFFFFFFF)
			end
			if myHero:CanUseSpell(_W) == READY and Param.drawing.Wdraw then 
				DrawCircle3D(myHero.x, myHero.y, myHero.z, 1000, 1, 0xFFFFFFFF)
			end
			if myHero:CanUseSpell(_E) == READY and Param.drawing.Edraw then 
				DrawCircle3D(myHero.x, myHero.y, myHero.z, 350, 1, 0xFFFFFFFF)
			end
			if myHero:CanUseSpell(_R) == READY and Param.drawing.Rdraw then
				DrawCircle3D(myHero.x, myHero.y, myHero.z, 1000, 1, 0xFFFFFFFF)
			end
			if Param.drawing.AAdraw then
				DrawCircle3D(myHero.x, myHero.y, myHero.z, myHero.range+myHero.boundingRadius, 1, 0xFFFFFFFF)
			end
			if Param.drawing.HitBox then
				DrawCircle3D(myHero.x, myHero.y, myHero.z, myHero.boundingRadius, 1, 0xFFFFFFFF)
			end
			if target ~= nil and ValidTarget(target) then
				if Param.drawing.Current then
					DrawText3D("ACTUAL BITCH",target.x-100, target.y-50, target.z, 20, 0xFFFFFFFF) -- Acknowledgments to http://forum.botoflegends.com/user/25371-big-fat-corki/ and his Mark IV script for giving me the idea of the target name.
				end
			end
			if Param.drawing.drawKillable then
				for i = 1, heroManager.iCount do
					local enemy = heroManager:getHero(i)
					if enemy and ValidTarget(enemy) then
						local barPos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
						local PosX = barPos.x - 35
						local PosY = barPos.y - 50
						DrawText(TextList[KillText[i]], 15, PosX, PosY, ARGB(255,255,204,0))
					end 
				end 
			end 
			if Param.drawing.BarH then
				for _, unit in pairs(GetEnemyHeroes()) do
					if unit ~= nil and GetDistance(unit) < 3000 then
						local Center = GetUnitHPBarPos(unit)
						local QT = math.floor(myHero:CalcDamage(unit,Qdmg))
						local RT = math.floor(myHero:CalcDamage(unit,Rdmg))
						local QCalc = ((myHero:CanUseSpell(_Q) == READY and QT) or 0)
						local RCalc = ((myHero:CanUseSpell(_R) == READY and RT) or 0)
						local Y3QER = QCalc + RCalc
						if Center.x > -100 and Center.x < WINDOW_W+100 and Center.y > -100 and Center.y < WINDOW_H+100 then
							local off = GetUnitHPBarOffset(unit)
							local y=Center.y + (off.y * 53) + 2
							local xOff = ({['AniviaEgg'] = -0.1,['Darius'] = -0.05,['Renekton'] = -0.05,['Sion'] = -0.05,['Thresh'] = -0.03,})[unit.charName]
							local x = Center.x + ((xOff or 0) * 140) - 66
							if not TargetHaveBuff("SummonerExhaust", myHero) then
								dmg = unit.health - Y3QER 
							elseif TargetHaveBuff("SummonerExhaust", myHero) then
								dmg = unit.health - (Y3QER-((Y3QER*40)/100))
							end
							DrawLine(x + ((unit.health /unit.maxHealth) * 104),y, x+(((dmg > 0 and dmg or 0) / unit.maxHealth) * 104),y,9, GetDistance(unit) < 3000 and 0x6699FFFF)
						end
					end
				end
			end
		end
	end
end

function OnTick()
	if not myHero.dead then
		ts:update()
		target = GetCustomTarget()
		Consommables()
		KillSteal()
		Keys()
		if Param.Miscellaneous.RSettings.Enable then
			AutoR()
		end
		if Param.Harass.Auto then
			AutoHarass()
		end
		if Param.Miscellaneous.WSettings.EnableHeal then
			LogicW()
		end
	end
end

function Consommables()
	if Param.Miscellaneous.LVL.Enable then
		AutoLvlSpell()
	end
end

function Menu()

	--
	Param = scriptConfig("[Baguette] Sona", "BaguetteSona")
	--
	Param:addSubMenu("SBTW!","Combo")
		if Ignite or Exhaust then Param.Combo:addParam("Summoner", "When it will cast summoners?", SCRIPT_PARAM_LIST, 2, {"At the Start of the fight + ComboMode or to KS (Deny Burst / HP Heal)", "During fight (KS, Burst Reduction)"}) end
		Param.Combo:addParam("UseQ", "Use (Q) Spell in Combo?" , SCRIPT_PARAM_ONOFF, true)
		Param.Combo:addParam("UseW", "Use (W) Spell in Combo?" , SCRIPT_PARAM_ONOFF, true)
		Param.Combo:addParam("UseE", "Use (E) Spell in Combo?" , SCRIPT_PARAM_ONOFF, true)
		Param.Combo:addParam("UseR", "Use (R) Spell in Combo?" , SCRIPT_PARAM_ONOFF, true)
		Param.Combo:addParam("MinR", "How many in R to ult?", SCRIPT_PARAM_SLICE, 2, 1, 5)
		Param.Combo:addParam("ManaSpam", "Min. mana to Spam W/E :", SCRIPT_PARAM_SLICE, 250, 0, 5000)
	--
	Param:addSubMenu("Harass","Harass")
		Param.Harass:addParam("Auto", "Toggle Harass (Auto)", SCRIPT_PARAM_ONKEYTOGGLE, false, GetKey("I"))
		Param.Harass:addParam("Mana", "Required Mana to Harass :", SCRIPT_PARAM_SLICE, 50, 0, 100)
		Param.Harass:addParam("UseQ", "Use (Q) Spell in Harass?" , SCRIPT_PARAM_ONOFF, true)
	--
	Param:addSubMenu("WaveClear", "WaveClear")
		Param.WaveClear:addParam("Mana", "Required Mana to WaveClear :", SCRIPT_PARAM_SLICE, 50, 0, 100)
		Param.WaveClear:addParam("UseQ", "Use (Q) Spell in WaveClear?" , SCRIPT_PARAM_ONOFF, true)
	--
	Param:addSubMenu("JungleClear", "JungleClear")
		Param.JungleClear:addParam("Mana", "Required Mana to JungleClear :", SCRIPT_PARAM_SLICE, 50, 0, 100)
		Param.JungleClear:addParam("UseQ", "Use (Q) Spell in JungleClear?" , SCRIPT_PARAM_ONOFF, true)
	--
	Param:addSubMenu("KillSteal", "KillSteal")
		Param.KillSteal:addParam("Active", "Enable KillSteal?" , SCRIPT_PARAM_ONOFF, true)
		Param.KillSteal:addParam("UseQ", "Use (Q) Spell to KillSteal?", SCRIPT_PARAM_ONOFF, true)
		Param.KillSteal:addParam("UseR", "Use (R) Spell to KillSteal?", SCRIPT_PARAM_ONOFF, false)
		if Ignite then Param.KillSteal:addParam("UseIgnite", "Use (Ignite) Summoner Spell to KillSteal?", SCRIPT_PARAM_ONOFF, true) end
	--
	Param:addSubMenu("Miscellaneous", "Miscellaneous")
		if VIP_USER then Param.Miscellaneous:addSubMenu("Auto LVL Spell :", "LVL") end
		if VIP_USER then Param.Miscellaneous.LVL:addParam("Enable", "Enable Auto Level Spell?", SCRIPT_PARAM_ONOFF, true) end
		if VIP_USER then Param.Miscellaneous.LVL:addParam("Combo", "LVL Spell Order :", SCRIPT_PARAM_LIST, 1, {"R > Q > W > E (Max Q)"}) end
		if VIP_USER then Param.Miscellaneous.LVL:setCallback("Combo", function (nV)
			if nV then
				AutoLvlSpellCombo()
			else 
				AutoLvlSpellCombo()
			end
		end)
		end
		if VIP_USER then Last_LevelSpell = 0 end
		--
		if VIP_USER then Param.Miscellaneous:addSubMenu("Skin Changer", "Skin") end
			if VIP_USER then Param.Miscellaneous.Skin:addParam("Enable", "Enable Skin Changer : ", SCRIPT_PARAM_ONOFF, false)
				Param.Miscellaneous.Skin:setCallback("Enable", function (nV)
					if nV then
						SetSkin(myHero, Param.Miscellaneous.Skin.skins -1)
					else
						SetSkin(myHero, -1)
					end
				end)
			end				
			if VIP_USER then Param.Miscellaneous.Skin:addParam("skins", 'Which Skin :', SCRIPT_PARAM_LIST, 2,  {"Classic", "Muse", "Pentakill", "Silent Night", "Guqin", "Arcade", "DJ"})
				Param.Miscellaneous.Skin:setCallback("skins", function (nV)
					if nV then
						if Param.Miscellaneous.Skin.Enable then
							SetSkin(myHero, Param.Miscellaneous.Skin.skins -1)
						end
					end
				end)
			end
		--
		Param.Miscellaneous:addSubMenu("W Settings", "WSettings")
			Param.Miscellaneous.WSettings:addParam("EnableHeal", "Enable AutoHeal?", SCRIPT_PARAM_ONOFF, true)
			Param.Miscellaneous.WSettings:addParam("HealAuto", "Auto Heal allies under X %HP :", SCRIPT_PARAM_SLICE, 60, 0, 100)
			Param.Miscellaneous.WSettings:addParam("Mana", "Required Mana to AutoHeal :", SCRIPT_PARAM_SLICE, 50, 0, 100)
		--
		Param.Miscellaneous:addSubMenu("E Settings", "ESettings")
			Param.Miscellaneous.ESettings:addParam("FleeKey", "Flee Key :", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("G"))
			Param.Miscellaneous.Skin:setCallback("skins", function (nV)
					CastSpell(_E)
					myHero:MoveTo(mousePos.x, mousePos.z) 
			end)
			Param.Miscellaneous.ESettings:addParam("Fast", "Enable fast come back to lane?", SCRIPT_PARAM_ONOFF, true)
		--
		Param.Miscellaneous:addSubMenu("R Settings", "RSettings")
			Param.Miscellaneous.RSettings:addParam("Enable", "Enable auto ult?", SCRIPT_PARAM_ONOFF, true)
			Param.Miscellaneous.RSettings:addParam("Auto", "Auto Ult if ", SCRIPT_PARAM_SLICE, 4, 0, 5)
		--
		if Ignite or Exhaust then Param.Miscellaneous:addSubMenu("Summoner", "SummonerSetting") end
			if Ignite or Exhaust then Param.Miscellaneous.SummonerSetting:addParam("n10", "Here you can choose on who you want to cast Ignite and exhaust.", SCRIPT_PARAM_INFO, "") end
			if Ignite or Exhaust then Param.Miscellaneous.SummonerSetting:addParam("n11", "", SCRIPT_PARAM_INFO, "") end
			if Ignite or Exhaust then Param.Miscellaneous.SummonerSetting:addParam("Enable", "Enable Summoner Support?", SCRIPT_PARAM_ONOFF, true) end
			if Ignite or Exhaust then Param.Miscellaneous.SummonerSetting:addParam("n16", "", SCRIPT_PARAM_INFO, "") end
			if Ignite and Exhaust == NONE then Param.Miscellaneous.SummonerSetting:addParam("n12", "Ignite :", SCRIPT_PARAM_INFO, "True") end
			if Exhaust and Ignite == NONE then Param.Miscellaneous.SummonerSetting:addParam("n13", "Exhaust :", SCRIPT_PARAM_INFO, "True") end
			if Exhaust and Ignite then Param.Miscellaneous.SummonerSetting:addParam("n14", "Ignite and Exhaust :", SCRIPT_PARAM_INFO, "True") end
			if Ignite or Exhaust then Param.Miscellaneous.SummonerSetting:addParam("n19", "", SCRIPT_PARAM_INFO, "") end
			if Ignite or Exhaust then Param.Miscellaneous.SummonerSetting:addParam("n17", "It's simple, just put on ON to use you'r summoner on the combo", SCRIPT_PARAM_INFO, "") end
			if Ignite or Exhaust then Param.Miscellaneous.SummonerSetting:addParam("n18", "you choose in Combo Menu. Else, just put the caractere name on OFF.", SCRIPT_PARAM_INFO, "") end
			if Ignite or Exhaust then Param.Miscellaneous.SummonerSetting:addParam("n20", "", SCRIPT_PARAM_INFO, "") end
		--
		if VIP_USER then Param.Miscellaneous:addSubMenu("Auto Buy Starter :", "Starter") end
			if VIP_USER then Param.Miscellaneous.Starter:addParam("Doran", "Buy a doran ring :", SCRIPT_PARAM_ONOFF, true) end
			if VIP_USER then Param.Miscellaneous.Starter:addParam("Support", "Buy a support item :", SCRIPT_PARAM_ONOFF, true) end
			if VIP_USER then Param.Miscellaneous.Starter:addParam("Pots", "Buy a potion :", SCRIPT_PARAM_ONOFF, true) end
			if VIP_USER then Param.Miscellaneous.Starter:addParam("Trinket", "Buy a Green Trinket :", SCRIPT_PARAM_ONOFF, true) end
			if VIP_USER then Param.Miscellaneous.Starter:addParam("n1blank", "", SCRIPT_PARAM_INFO, "") end
			if VIP_USER then Param.Miscellaneous.Starter:addParam("TrinketBleu", "Buy a Blue Trinket at lvl.9 :", SCRIPT_PARAM_ONOFF, true) end
	--
	Param:addSubMenu("", "nil")
	--
	Param:addSubMenu("Drawing","drawing")
		Param.drawing:addParam("Enable", "Disable every draws?", SCRIPT_PARAM_ONOFF, false)
		Param.drawing:addParam("Qdraw","Display (Q) Spell draw?", SCRIPT_PARAM_ONOFF, true)
		Param.drawing:addParam("Wdraw","Display (W) Spell draw?", SCRIPT_PARAM_ONOFF, true)
		Param.drawing:addParam("Edraw","Display (E) Spell draw?", SCRIPT_PARAM_ONOFF, true)
		Param.drawing:addParam("Rdraw","Display (R) Spell draw?", SCRIPT_PARAM_ONOFF, true)
		Param.drawing:addParam("AAdraw", "Display Auto Attack draw?", SCRIPT_PARAM_ONOFF, true)
		Param.drawing:addParam("Current", "Draw text on current target?", SCRIPT_PARAM_ONOFF, true)
		Param.drawing:addParam("drawKillable", "Draw Killable Text?", SCRIPT_PARAM_ONOFF, true)
		Param.drawing:addParam("HitBox", "Draw HitBox?", SCRIPT_PARAM_ONOFF, true)
		Param.drawing:addParam("BarH", "Draw Damage on health bar?", SCRIPT_PARAM_ONOFF, true)
	--
	Param:addSubMenu("", "nil")
	--
	Param:addSubMenu("OrbWalker", "orbwalker")
		Param.orbwalker:addParam("n1", "OrbWalker :", SCRIPT_PARAM_LIST, 3, {"SxOrbWalk", "BigFat OrbWalker", "Nebelwolfi's Orb Walker"})
		Param.orbwalker:addParam("n2", "If you want to change OrbWalker,", SCRIPT_PARAM_INFO, "")
		Param.orbwalker:addParam("n3", "Then, change it and press double F9.", SCRIPT_PARAM_INFO, "")
		Param.orbwalker:addParam("n4", "", SCRIPT_PARAM_INFO, "")
		Param.orbwalker:addParam("n5", "=> SAC:R & Pewalk are automaticly loaded.", SCRIPT_PARAM_INFO, "")
		Param.orbwalker:addParam("n6", "=> Enable one of them in BoLStudio", SCRIPT_PARAM_INFO, "")
	--
	Param:addSubMenu("", "nil")
end

function LogicQ()
	if target and GetDistance(target) < 850 then
		CastSpell(_Q) 
	end
end

function LogicW()
	if OnRecall == 0 then
		if Param.Miscellaneous.WSettings.EnableHeal then
			for _, unit in pairs(GetAllyHeroes()) do
				health = unit.health
				if GetDistance(unit) < 950 and myHero.mana < (myHero.maxMana * ( Param.Miscellaneous.WSettings.Mana / 100)) then
					if unit.health < (unit.maxHealth * (Param.Miscellaneous.WSettings.HealAuto/100)) then
						CastSpell(_W)
					end
				elseif myHero.health < (myHero.maxHealth * (Param.Miscellaneous.WSettings.HealAuto/100)) and myHero.mana < (myHero.maxMana * ( Param.Miscellaneous.WSettings.Mana / 100)) then
					CastSpell(_W)
				end
			end
		end
	end
end

function LogicE()
	if myHero.mana > Param.Combo.ManaSpam then
		CastSpell(_E)
	end
end

function LogicR()
	if not Immune(unit) and OnRecall == 0 then
		if target ~= nil and ValidTarget(target) and GetDistance(target) <= 1000 then
			local aoeCastPos, hitChance, castInfo, nTargets
			aoeCastPos, hitChance, nTargets = VP:GetLineAOECastPosition(target, 0.5, 120, 900, 2400, myHero)
			if Param.Combo.UseR then
				if nTargets == Param.Combo.MinR then
					CastSpell(_R, aoeCastPos.x, aoeCastPos.z) 
				end
			end
		end
	end
end

function AutoR()
	if target ~= nil and ValidTarget(target) and GetDistance(target) <= 1000 then
		local aoeCastPos, hitChance, castInfo, nTargets
		aoeCastPos, hitChance, nTargets = VP:GetLineAOECastPosition(target, 0.5, 120, 900, 2400, myHero)
		if nTargets >= Param.Miscellaneous.RSettings.Auto then
			CastSpell(_R, aoeCastPos.x, aoeCastPos.z) 
		end
	end
end

function AutoLvlSpell()
	if VIP_USER and os.clock()-Last_LevelSpell > 0.5 then
		if Param.Miscellaneous.LVL.Enable then
			autoLevelSetSequence(levelSequence)
			Last_LevelSpell = os.clock()
		elseif not Param.Miscellaneous.LVL.Enable then
			autoLevelSetSequence(nil)
			Last_LevelSpell = os.clock()+10
		end
	end
end

function AutoLvlSpellCombo()
	if Param.Miscellaneous.LVL.Combo == 1 then
		levelSequence = {1,2,1,3,1,4,1,2,1,2,4,2,2,3,3,4,3,3}
	end
end

function LoadVPred()
	if FileExist(LIB_PATH .. "/VPrediction.lua") then
		require("VPrediction")
		EnvoiMessage("Succesfully loaded VPred")
		VP = VPrediction()
	else
		local Host = "raw.githubusercontent.com"
		local Path = "/SidaBoL/Scripts/master/Common/VPrediction.lua".."?rand="..math.random(1,10000)
		EnvoiMessage("VPred not found!")
		DownloadFile("https://"..Host..Path, LibPath, function ()  end)
		DelayAction(function () 
			require("VPrediction") 
			VP = VPrediction() 
		end, 5)
	end
end

local priorityTable = {
 
    AP_Carry = {
        "Annie", "Ahri", "Akali", "Anivia", "Annie", "Brand", "Cassiopeia", "Diana", "Evelynn", "FiddleSticks", "Fizz", "Gragas", "Heimerdinger", "Karthus",
        "Kassadin", "Katarina", "Kayle", "Kennen", "Leblanc", "Lissandra", "Lux", "Malzahar", "Mordekaiser", "Morgana", "Nidalee", "Orianna",
        "Rumble", "Ryze", "Sion", "Swain", "Syndra", "Teemo", "TwistedFate", "Veigar", "Viktor", "Vladimir", "Xerath", "Ziggs", "Zyra", "MasterYi", "VelKoz", "Azir", "Ekko",
    },

    Support = {
        "Alistar", "Blitzcrank", "Janna", "Karma", "Leona", "Lulu", "Nami", "Nunu", "Sona", "Soraka", "Taric", "Thresh", "Zilean", "Braum", "Bard", "TahmKench",
    },
 
    Tank = {
        "Amumu", "Chogath", "DrMundo", "Galio", "Hecarim", "Malphite", "Maokai", "Nasus", "Rammus", "Sejuani", "Shen", "Singed", "Skarner", "Volibear",
        "Warwick", "Yorick", "Zac", "Illaoi", "RekSai",
    },
 
    AD_Carry = {
        "Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jayce", "KogMaw", "MissFortune", "Pantheon", "Quinn", "Shaco", "Sivir",
        "Talon", "Tristana", "Twitch", "Urgot", "Varus", "Vayne", "Zed", "Lucian", "Jinx",
 
    },
 
    Bruiser = {
        "Aatrox", "Darius", "Elise", "Fiora", "Gangplank", "Garen", "Irelia", "JarvanIV", "Jax", "Khazix", "LeeSin", "Nautilus", "Nocturne", "Olaf", "Poppy",
        "Renekton", "Rengar", "Riven", "Shyvana", "Trundle", "Tryndamere", "Udyr", "Vi", "MonkeyKing", "XinZhao", "Gnar", "Kindred"
    },
}

function SetPriority(table, hero, priority)
    for i=1, #table, 1 do
    	if hero.charName:find(table[i]) ~= nil then
        	TS_SetHeroPriority(priority, hero.charName)
        	if Ignite or Exhaust then
	        	if MenuPerso == "Premier" then
	        		Param.Miscellaneous.SummonerSetting:addParam("n1", hero.charName, SCRIPT_PARAM_ONOFF, false)
	        		MenuPerso = "Second"
	        		n1 = hero.charName
	        	elseif MenuPerso == "Second" then
	        		Param.Miscellaneous.SummonerSetting:addParam("n2", hero.charName, SCRIPT_PARAM_ONOFF, false)
	        		MenuPerso = "Troisieme"
	        		n2 = hero.charName
	        	elseif MenuPerso == "Troisieme" then
	        		Param.Miscellaneous.SummonerSetting:addParam("n3", hero.charName, SCRIPT_PARAM_ONOFF, false)
	        		MenuPerso = "Quatrieme"
	        		n3 = hero.charName
	        	elseif MenuPerso == "Quatrieme" then
	        		Param.Miscellaneous.SummonerSetting:addParam("n4", hero.charName, SCRIPT_PARAM_ONOFF, false)
	        		MenuPerso = "Cinquieme"
	        		n4 = hero.charName
	        	elseif MenuPerso == "Cinquieme" then
	        		Param.Miscellaneous.SummonerSetting:addParam("n5", hero.charName, SCRIPT_PARAM_ONOFF, false)
	        		MenuPerso = "0"
	        		n5 = hero.charName
	        	end
	        end
        end
    end
end

function arrangePrioritys()
    for i, enemy in ipairs(GetEnemyHeroes()) do
        SetPriority(priorityTable.AD_Carry, enemy, 1)
        SetPriority(priorityTable.AP_Carry, enemy, 2)
        SetPriority(priorityTable.Support, enemy, 3)
        SetPriority(priorityTable.Bruiser, enemy, 4)
        SetPriority(priorityTable.Tank, enemy, 5)
    end
end
 
function PriorityOnLoad()
        if heroManager.iCount < 10 then
			EnvoiMessage("Impossible to Arrange Priority Table.. There is not enough champions... (less than 10)")	
        else
            arrangePrioritys()
        end
end

function GetCustomTarget()
	ts:update()
	if ValidTarget(ts.target) and ts.target.type == myHero.type then
		return ts.target
	else
		return nil
	end
end

function SummonerManager()
	if Exhaust then
		if Param.Miscellaneous.Summoner == 1 then
			if (unit.charName == Exhaust) and ComboKey and (myHero:CanUseSpell(Exhaust) == READY) and ValidTarget(unit) then
				CastSpell(Exhaust, unit)
			end
		elseif Param.Miscellaneous.Summoner == 2 then
			if (unit.charName == ExhaustI) and ComboKey and (myHero:CanUseSpell(Exhaust) == READY) and ValidTarget(unit) then
				CastSpell(Exhaust, unit)
			end
		end
	end
	if Ignite then
		if Param.Miscellaneous.Summoner == 1 then
			if ComboKey and (myHero:CanUseSpell(Ignite) == READY) and ValidTarget(unit) and (unit.charName == Ignite or unit.lifeSteal > 9) then
				CastSpell(Ignite, unit)
			end
		end
	end
end
 
function DrawKillable()
	for i = 1, heroManager.iCount, 1 do
		local enemy = heroManager:getHero(i)
		if enemy and ValidTarget(enemy) then
			if enemy.team ~= myHero.team then 
				if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") or myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then
					if (myHero:CanUseSpell(Ignite) == READY) then
						iDmg = 40 + (20 * myHero.level)
					elseif (myHero:CanUseSpell(Ignite) ~= READY) then
						iDmg = 0
					end
				end
				Qdmg = ((40 * myHero:GetSpellData(_Q).level + 10 * myHero:GetSpellData(_R).level + .5 * myHero.ap) or 0)
				Rdmg = ((100 * myHero:GetSpellData(_R).level + 50 + .5 * myHero.ap) or 0)
				AAdmg = (myHero.level * 9 + 0.2 * myHero.ap)
				if AADmg > enemy.health then
					KillText[i] = 1
				elseif iDmg > enemy.health then
					KillText[i] = 2
				elseif Qdmg > enemy.health then
					KillText[i] = 3
				elseif Qdmg + iDmg > enemy.health then
					KillText[i] = 4
				elseif Qdmg + Rdmg > enemy.health then
					KillText[i] = 5
				elseif Qdmg + Rdmg + iDmg > enemy.health then
					KillText[i] = 6
				elseif Qdmg + Rdmg + iDmg + AADmg > enemy.health then
					KillText[i] = 7
				else
					KillText[i] = 8
				end 
			end 
		end 
	end 
end

function KillSteal()
	for _, unit in pairs(GetEnemyHeroes()) do
		if not Immune(unit) and OnRecall == 0 then
			health = unit.health
			Qdmg = ((40 * myHero:GetSpellData(_Q).level + 10 * myHero:GetSpellData(_R).level + .5 * myHero.ap) or 0)
			QmagicDamage = myHero:CalcMagicDamage(unit, Qdmg)
			Rdmg = ((100 * myHero:GetSpellData(_R).level + 50 + .5 * myHero.ap) or 0)
			RmagicDamage = myHero:CalcMagicDamage(unit, Rdmg)
			if GetDistance(unit) < 850 then
				if Param.KillSteal.Active then
					if health <= QmagicDamage and Param.KillSteal.UseQ and myHero:CanUseSpell(_Q) == READY and ValidTarget(unit) then
						CastSpell(_Q)
					end
					if health <= RmagicDamage and Param.KillSteal.UseR and myHero:CanUseSpell(_R) == READY and ValidTarget(unit) then
						local HitPos = VP:GetLineAOECastPosition(target, 0.5, 140, 850, 2400, myHero, false)
						CastSpell(_R, HitPos.x, HitPos.z)
					end
					if myHero:GetSpellData(SUMMONER_1).name:find("SumonnerDot") or myHero:GetSpellData(SUMMONER_2).name:find("SumonnerDot") then
						if health <= 40 + (20 * myHero.level) and Param.KillSteal.UseIgnite and (myHero:CanUseSpell(Ignite) == READY) and ValidTarget(unit) then
							CastSpell(Ignite, unit)
						end
					end
				end
			end
		end
	end
end

function OnNewPath(unit, startPos, endPos, isDash, dashSpeed, dashGravity, dashDistance)
	if unit.isMe and Param.Miscellaneous.ESettings.Fast then
		if myHero:CanUseSpell(_E) == READY then
			if GetGame().map.shortName == "summonerRift" and GetDistance(myHero.endPath) > 3000 then
				CastSpell(_E)
			end
		end
	end
end

function LoadSXOrb()
	if FileExist(LIB_PATH .. "/SxOrbWalk.lua") then
		require("SxOrbWalk")
		EnvoiMessage("Loaded SxOrbWalk")
		Param:addSubMenu("SxOrbWalk", "SXMenu")
		SxOrb:LoadToMenu(Param.SXMenu)
	else
		EnvoiMessage("Download a Fresh BoL Folder.")
	end
end

function LoadBFOrb()
	local LibPath = LIB_PATH.."Big Fat Orbwalker.lua"
	local ScriptPath = SCRIPT_PATH.."Big Fat Orbwalker.lua"
	if not (FileExist(ScriptPath) and _G["BigFatOrb_Loaded"] == true) then
			local Host = "raw.github.com"
			local Path = "/BigFatNidalee/BoL-Releases/master/LimitedAccess/Big Fat Orbwalker.lua?rand="..math.random(1,10000)
			DownloadFile("https://"..Host..Path, LibPath, function ()  end)
		require "Big Fat Orbwalker"
	end
end

function NebelOrb()
	local function LoadOrb()
		if not _G.NebelwolfisOrbWalkerLoaded then
			require "Nebelwolfi's Orb Walker"
			NebelwolfisOrbWalkerClass()
		end
	end
	if not FileExist(LIB_PATH.."Nebelwolfi's Orb Walker.lua") then
		DownloadFile("http://raw.githubusercontent.com/nebelwolfi/BoL/master/Common/Nebelwolfi's Orb Walker.lua", LIB_PATH.."Nebelwolfi's Orb Walker.lua", function()
			LoadOrb()
		end)
	else
		local f = io.open(LIB_PATH.."Nebelwolfi's Orb Walker.lua")
		f = f:read("*all")
		if f:sub(1,4) == "func" then
			DownloadFile("http://raw.githubusercontent.com/nebelwolfi/BoL/master/Common/Nebelwolfi's Orb Walker.lua", LIB_PATH.."Nebelwolfi's Orb Walker.lua", function()
				LoadOrb()
			end)
		else
			LoadOrb()
		end
	end
end

function LoadSACR()
	if _G.Reborn_Initialised then
	elseif _G.Reborn_Loaded then
		EnvoiMessage("Loaded SAC:R")
	else
		DelayAction(function()EnvoiMessage("Failed to Load SAC:R")end, 7)
	end 
end

function LoadPewalk()
	if _Pewalk then
		EnvoiMessage("Loaded Pewalk")
		DelayAction(function ()EnvoiMessage("[Pewalk] Disable every spell usage in Pewalk for better performances with my script.")end, 7)
	elseif not _Pewalk then
		EnvoiMessage("Pewalk loading error")
	end
end

function LoadSpikeLib()
	local LibPath = LIB_PATH.."SpikeLib.lua"
	if not FileExist(LibPath) then
		local Host = "raw.github.com"
		local Path = "/spyk1/BoL/master/bundle/SpikeLib.lua".."?rand="..math.random(1,10000)
		DownloadFile("https://"..Host..Path, LibPath, function ()  end)
		DelayAction(function () require("SpikeLib") end, 5)
	else
		require("SpikeLib")
		DelayAction(function ()EnvoiMessage("Loaded Libraries with success!") end, 3)
	end
end

function Keys()
	if _G.AutoCarry and _G.AutoCarry.Keys and _G.Reborn_Loaded ~= nil then

		if _G.AutoCarry.Keys.AutoCarry then 
			Combo()
		elseif  _G.AutoCarry.Keys.MixedMode then 
			Harass()
		elseif  _G.AutoCarry.Keys.LaneClear then 
			LaneClear()
		elseif  _G.AutoCarry.Keys.LastHit then 
			LastHit()
		end

	elseif _Pewalk then

		if _G._Pewalk.GetActiveMode().Carry then 
			Combo()
		elseif _G._Pewalk.GetActiveMode().Mixed then 
			Harass()
		elseif _G._Pewalk.GetActiveMode().LaneClear then
			LaneClear()
		elseif _G._Pewalk.GetActiveMode().Farm then 
			LastHit()
		end

	elseif Param.orbwalker.n1 == 1 and _G.SxOrbMenu then

		if _G.SxOrbMenu.AutoCarry then 
			Combo()
		elseif  _G.SxOrbMenu.MixedMode then 
			Harass()
		elseif  _G.SxOrbMenu.LaneClear then 
			LaneClear() 
		elseif  _G.SxOrbMenu.LastHit then 
			LastHit()
		end

	elseif Param.orbwalker.n1 == 2 and _G["BigFatOrb_Loaded"] == true then

		if _G["BigFatOrb_Mode"] == 'Combo' then
			Combo()
		elseif _G["BigFatOrb_Mode"] == 'Harass' then
			Harass()
		elseif _G["BigFatOrb_Mode"] == 'LastHit' then
			LastHit()
		elseif _G["BigFatOrb_Mode"] == 'LaneClear' then
			LaneClear()
		end

	elseif Param.orbwalker.n1 == 3 and _G.NebelwolfisOrbWalkerLoaded then

		if _G.NebelwolfisOrbWalker.Config.k.Combo then
			Combo()
		elseif _G.NebelwolfisOrbWalker.Config.k.Harass then
			Harass()
		elseif _G.NebelwolfisOrbWalker.Config.k.LastHit then
			LastHit()
		elseif _G.NebelwolfisOrbWalker.Config.k.LaneClear then
			LaneClear()
		end

	end
end

function Combo()
	if not Immune(unit) and OnRecall == 0 then
		if Param.Combo.UseR then
			LogicR()
		end
		if Param.Combo.UseQ then
			LogicQ()
		end
		if myHero.mana > Param.Combo.ManaSpam then
			CastSpell(_W)
			CastSpell(_E)
		end
		if Ignite or Exhaust and Param.Miscellaneous.SummonerSetting.Enable then
			SummonerManager()
		end
	end
end

function Harass()
	if not Immune(unit) and OnRecall == 0 then
		if target and GetDistance(target) < 850 then
			if myHero.mana < (myHero.maxMana * ( Param.Harass.Mana / 100)) then
				LogicQ()
			end
		end
	end
end

function AutoHarass()
	if not Immune(unit) and OnRecall == 0 then
		if target and GetDistance(target) < 850 then
			if myHero.mana < (myHero.maxMana * ( Param.Harass.Mana / 100)) then
				CastSpell(_Q)
			end
		end
	end
end

function LaneClear()
	enemyMinions:update()
	for i, minion in pairs(enemyMinions.objects) do
		if ValidTarget(minion) and minion ~= nil and GetDistance(minion) < 850 and ((myHero.mana / myHero.maxMana)*100 > Param.WaveClear.Mana) then
			CastSpell(_Q)
		end
	end
	jungleMinions:update()
	for i, jungleMinion in pairs(jungleMinions.objects) do
		if jungleMinion ~= nil and GetDistance(jungleMinion) < 850 and ((myHero.mana / myHero.maxMana)*100 > Param.JungleClear.Mana) then
			CastSpell(_Q)
		end
	end
end

function LastHit()
end

function SummonerManager()
	if Exhaust then
		if Param.Combo.Summoner == 1 then
			if (unit.charName == Exhaust) and (myHero:CanUseSpell(Exhaust) == READY) and ValidTarget(unit) then
				CastSpell(Exhaust, unit)
			end
		elseif Param.Combo.Summoner == 2 then
			if (unit.charName == ExhaustI) and (myHero:CanUseSpell(Exhaust) == READY) and ValidTarget(unit) then
				CastSpell(Exhaust, unit)
			end
		end
	end
	if Ignite then
		if Param.Combo.Summoner == 1 then
			if ComboKey and (myHero:CanUseSpell(Ignite) == READY) and ValidTarget(unit) and (unit.charName == Ignite or unit.lifeSteal > 9) then
				CastSpell(Ignite, unit)
			end
		end
	end
end

function AutoBuy()
	if VIP_USER and GetGameTimer() < 60 then
		if Param.miscellaneous.Starter.Support then
			BuyItem(3303)
		end
		if Param.miscellaneous.Starter.Doran then
			BuyItem(1056)
		end
		if Param.miscellaneous.Starter.Pots then
			BuyItem(2003)
		end
		if Param.miscellaneous.Starter.Pots then
			BuyItem(2003)
		end
		if Param.miscellaneous.Starter.Trinket then
			BuyItem(3340)
		end
	end
end

function OnRemoveBuff(unit, buff)
	if buff.name == "recall" and unit.isMe then
		if myHero.level >= 9 then
			if VIP_USER then
				if Param.miscellaneous.Starter.TrinketBleu then
					BuyItem(3363)
				end
			end
		end
		OnRecall = 0
	end
end

function Immune(unit)
	if unit ~= nil then
	    for i = 1, unit.buffCount do
	        local tBuff = unit:getBuff(i)
	        if BuffIsValid(tBuff) then
	            if buffs[tBuff.name] then
	                return true
	            end
	        end
	    end
	    return false
	else
   		return false
   	end
end

function OnApplyBuff(source, unit, buff)
	if buff.name == "recall" and unit.isMe then
		OnRecall = 1
	end
end
