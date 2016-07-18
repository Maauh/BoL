--[[

Script by spyk for Kayle.

=> BaguetteKayle.lua

- Github link : https://github.com/spyk1/BoL/blob/master/BaguetteKalye/BaguetteKayle.lua

- Forum Thread : http://forum.botoflegends.com/topic/92596-beta-baguette-kayle/

]]--

if myHero.charName ~= "Kayle" then return end

function EnvoiMessage(msg)

	PrintChat("<font color=\"#e74c3c\"><b>[BaguetteKayle]</b></font> <font color=\"#ffffff\">" .. msg .. "</font>")
end

function CurrentTimeInMillis()

	return (os.clock() * 1000)
end


local TextList = {"Ignite = Kill", "Q = Kill"}
local KillText = {}
local dmgQ = 10 + 50 * myHero:GetSpellData(_Q).level + .6 * myHero.ap + myHero.addDamage
local healW = 15 + 45 * myHero:GetSpellData(_W).level + .45 * myHero.ap 
local dmgEPassif = 5 + 5 * myHero:GetSpellData(_E).level + .15 * myHero.ap
local dmgE = dmgEPassif * 2
local dmgSmite, D_SX = 0,0
local Last_LevelSpell, Last_Item_Check = 0,0
local DE_BASE, DH, D_NASH, D_GUIN, D_IJ, DTT_I, DAA_E, DTOT, DAA, DX, D3E1, D4E1, dmg = 0,0,0,0,0,0,0,0,0,0,0,0,0
local D_GUIN_S = 20 + .15 * myHero.totalDamage + .075 * myHero.ap
local D_NASH_S = 15 + .15 * myHero.ap
local GuinsooGet, NashorGet, HurricanGet, Item_Jungle_Get, GuinsooStacks = 0,0,0,0,0
local OrbwalkManager_AA = {LastTime = 0, LastTarget = nil, IsAttacking = false, Object = nil}
local OrbwalkManager_DataUpdated = false
local OrbwalkManager_BaseWindUpTime = 3
local OrbwalkManager_BaseAnimationTime = 0.665
local recall = 0
local Hero1 = ""
local Hero2 = ""
local Hero3 = ""
local Hero4 = ""
local T1 = 0

--- Starting AutoUpdate
local version = "0.165"
local author = "spyk"
local SCRIPT_NAME = "BaguetteKayle"
local AUTOUPDATE = true
local UPDATE_HOST = "raw.githubusercontent.com"
local UPDATE_PATH = "/spyk1/BoL/master/BaguetteKayle/BaguetteKayle.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

if AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/spyk1/BoL/master/BaguetteKayle/BaguetteKayle.version")
	if ServerData then
		ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
		if ServerVersion then
			if tonumber(version) < ServerVersion then
				EnvoiMessage("New version available "..ServerVersion)
				EnvoiMessage(">>Updating, please don't press F9<<")
				DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () EnvoiMessage("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
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
	print("<font color=\"#ffffff\">Loading</font><font color=\"#e74c3c\"><b> [BaguetteKayle]</b></font> <font color=\"#ffffff\">by spyk</font>")
	--
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerSmite") then Smite = SUMMONER_1 elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerSmite") then Smite = SUMMONER_2 end
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then Ignite = SUMMONER_1 elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then Ignite = SUMMONER_2 end
	if Ignite then EnvoiMessage("Found : Ignite [SUPPORTED]") end
	if Smite then 
		EnvoiMessage("Found : Smite [SUPPORTED]") 
		AddTickCallback(function() 
			if Param.JungleClear.Enable then
				AutoSmite()
			end
		end)
	end

	Menu()

	CustomLoad()
end

function CustomLoad()
	enemyMinions = minionManager(MINION_ENEMY, 900, myHero, MINION_SORT_HEALTH_ASC)
	jungleMinions = minionManager(MINION_JUNGLE, 900, myHero, MINION_SORT_MAXHEALTH_DEC)
	ts = TargetSelector(TARGET_LESS_CAST_PRIORITY, 1000, DAMAGE_MAGIC)
	ts.name = "Kayle"
	Param:addTS(ts)

	if _G.Reborn_Loaded ~= nil then
   		LoadSACR()
   	elseif _Pewalk then
   		LoadPewalk()
	else
		EnvoiMessage("Nebelwolfi's Orb Walker loading..")
		NebelOrb()
	end

	LoadSpikeLib()

	Skills()

	AutoLvlSpellCombo()

	if VIP_USER then
		if Param.Draw.Skin.Enable then
			SetSkin(myHero, Param.Draw.Skin.skins -1)
		end
	end
end

function OnTick()
	if not myHero.dead then
		ts:update()
		target = GetCustomTarget()
		KillSteal()
		Keys()
		AutoHeal()
		AutoR()
		DrawKillable()
		AutoLvlSpell()
		FleeMod()
	end
end

function OnUnload()
	EnvoiMessage("Unloaded.")
	EnvoiMessage("There is no justice anymore between us... Ciao!")

	if VIP_USER then
		if Param.Draw.Skin.Enable then
			SetSkin(myHero, -1);
		end
	end
end

function Skills()
	SkillQ = { name = "JudicatorReckoning", range = 650, delay = 0, speed = math.huge, width = nil, ready = false }
	SkillW = { name = "JudicatorDivineBlessing", range = 900, delay = 0, speed = math.huge, width = nil, ready = false }
	SkillE = { name = "JudicatorRighteousFury", range = 525, delay = 0, speed = math.huge, width = 150, ready = false }
	SkillR = { name = "JudictorIntervention", range = 900, delay = 0, speed = math.huge, width = nil, ready = false }
end

function Menu()
	--
	Param = scriptConfig("[Baguette] Kayle", "BaguetteKayle")
	--
	Param:addSubMenu("Combo Settings","Combo")
			Param.Combo:addParam("UseQ", "Use (Q) Spell in Combo :" , SCRIPT_PARAM_ONOFF, true)
			Param.Combo:addParam("UseW", "Use (W) Spell in Combo :" , SCRIPT_PARAM_ONOFF, true)
			Param.Combo:addParam("UseWValue", "Use (W) Spell under %life : ", SCRIPT_PARAM_SLICE, 50, 0, 100)
			Param.Combo:addParam("ManaW", "Mana Manager for (W) :", SCRIPT_PARAM_SLICE, 30, 0, 100)
			Param.Combo:addParam("UseE", "Use (E) Spell in Combo :" , SCRIPT_PARAM_ONOFF, true)
		--
	Param:addSubMenu("Harass Settings","Harass")
		Param.Harass:addParam("Mana", "Required Mana to Harass :", SCRIPT_PARAM_SLICE, 50, 0, 100)
		Param.Harass:addParam("UseQ", "Use (Q) Spell in Harass :" , SCRIPT_PARAM_ONOFF, true)
		Param.Harass:addParam("UseW", "Use (W) Spell in Harass :" , SCRIPT_PARAM_ONOFF, false)
		Param.Harass:addParam("UseE", "Use (E) Spell in Harass :" , SCRIPT_PARAM_ONOFF, true)
	--
	Param:addSubMenu("", "n1")
	--
	Param:addSubMenu("LastHit Settings", "LastHit")
		Param.LastHit:addParam("UseQ", "Use Q :", SCRIPT_PARAM_ONOFF, true)
		Param.LastHit:addParam("QMana", "Set a value for Mana (%)", SCRIPT_PARAM_SLICE, 30, 0, 100)
	--
	Param:addSubMenu("WaveClear Settings", "WaveClear")
		Param.WaveClear:addParam("Mana", "Required Mana to WaveClear :", SCRIPT_PARAM_SLICE, 50, 0, 100)
		Param.WaveClear:addParam("UseE", "Use (E) Spell in WaveClear :" , SCRIPT_PARAM_ONOFF, true)
	--
	Param:addSubMenu("JungleClear Settings", "JungleClear")
		Param.JungleClear:addParam("Mana", "Required Mana to JungleClear :", SCRIPT_PARAM_SLICE, 50, 0, 100)
		Param.JungleClear:addParam("UseQ", "Use (Q) Spell in JungleClear :" , SCRIPT_PARAM_ONOFF, true)
		Param.JungleClear:addParam("UseE", "Use (E) Spell in JungleClear :", SCRIPT_PARAM_ONOFF, true)
		if Smite then Param.JungleClear:addParam("n1blank", "", SCRIPT_PARAM_INFO, "") end
		if Smite then Param.JungleClear:addParam("Enable", "Use auto smite :", SCRIPT_PARAM_ONOFF, true) end
		if Smite then Param.JungleClear:addParam("Selector", "Choose a mode :", SCRIPT_PARAM_LIST, 1, {"Only Epics", "Only Buffs", "Only Buff & Epics", "Everything"}) end
	--
	Param:addSubMenu("", "n1")
	--
	Param:addSubMenu("KillSteal Settings", "KillSteal")
		Param.KillSteal:addParam("Enable", "Enable KillSteal :" , SCRIPT_PARAM_ONOFF, true)
		Param.KillSteal:addParam("UseQ", "Use (Q) Spell to KillSteal :", SCRIPT_PARAM_ONOFF, true)
		if Ignite then Param.KillSteal:addParam("UseIgnite", "Use (Ignite) Summoner Spell to KillSteal :", SCRIPT_PARAM_ONOFF, true) end

	--
	Param:addSubMenu("", "n1")
	--
	Param:addSubMenu("Miscellaneous Settings", "Misc")
		--
		if VIP_USER then Param.Misc:addSubMenu("Auto LVL Spell :", "LVL") end
			if VIP_USER then Param.Misc.LVL:addParam("Enable", "Enable Auto Level Spell :", SCRIPT_PARAM_ONOFF, true) end
			if VIP_USER then Param.Misc.LVL:addParam("Combo", "LVL Spell Order :", SCRIPT_PARAM_LIST, 1, {"Q > E > E > W (Max E)"}) end
			if VIP_USER then Param.Misc.LVL:setCallback("Combo", function (nV)
				if nV then
					AutoLvlSpellCombo()
				else 
					AutoLvlSpellCombo()
				end
			end)
			end
			if VIP_USER then Last_LevelSpell = 0 end
		--
		if VIP_USER then Param.Misc:addSubMenu("Auto Buy :", "Buy") end
			if VIP_USER then Param.Misc.Buy:addParam("TrinketBleu", "Buy a Blue Trinket at lvl.9 :", SCRIPT_PARAM_ONOFF, true) end
		--
		Param.Misc:addSubMenu("Flee Settings", "Flee")
			Param.Misc.Flee:addParam("Key", "Flee Key :",SCRIPT_PARAM_ONKEYDOWN, false, GetKey("G"))
			Param.Misc.Flee:addParam("n1", "", SCRIPT_PARAM_INFO, "")
			Param.Misc.Flee:addParam("Move", "Move to Mouse Position while flee :", SCRIPT_PARAM_ONOFF, true)
			Param.Misc.Flee:addParam("UseQ", "Use Spell (Q) while flee :", SCRIPT_PARAM_ONOFF, true)
			Param.Misc.Flee:addParam("UseW", "Use Spell (W) while flee :", SCRIPT_PARAM_ONOFF, true)
		--
		Param.Misc:addSubMenu("_W Settings", "W")
			Param.Misc.W:addParam("Enable", "Use Auto Healing :", SCRIPT_PARAM_ONOFF, true)
			Param.Misc.W:addParam("LifeA", "For ally with life under :", SCRIPT_PARAM_SLICE, 25, 0, 100)
			Param.Misc.W:addParam("ManaA", "Until (%) Mana :", SCRIPT_PARAM_SLICE, 65, 0, 100)
			Param.Misc.W:addParam("n1blank", "", SCRIPT_PARAM_INFO, "")
			Param.Misc.W:addParam("LifeH", "For yourself with life under :", SCRIPT_PARAM_SLICE, 30, 0, 100)
			Param.Misc.W:addParam("ManaH", "Until (%) Mana", SCRIPT_PARAM_SLICE, 50, 0, 100)
			Param.Misc.W:addParam("", "", SCRIPT_PARAM_INFO, "")
			Param.Misc.W:addParam("Fast", "Fast comeback to the lane :", SCRIPT_PARAM_ONOFF, true)
		--
		Param.Misc:addSubMenu("_R Settings", "R")
			Param.Misc.R:addParam("Enable", "Enable Auto _R :", SCRIPT_PARAM_ONOFF, true)
			Param.Misc.R:addParam("n1blank", "", SCRIPT_PARAM_INFO, "")
			Param.Misc.R:addParam("EnableH", "Use auto _R on yourself :", SCRIPT_PARAM_ONOFF, true)
			Param.Misc.R:addParam("LifeH", "Use under X Life :", SCRIPT_PARAM_SLICE, 15, 0, 100)
			Param.Misc.R:addParam("Number", "Do not Cast R if enemy in range are :", SCRIPT_PARAM_SLICE, 0, 0, 6)
			Param.Misc.R:addParam("Cast", "Cast _R on yourself :", SCRIPT_PARAM_ONKEYTOGGLE, false, GetKey("R"))
			Param.Misc.R:setCallback("Cast", function (nB)
				if nB then
					CastSpell(_R, myHero)
				end
			end)
			Param.Misc.R:addParam("n2blank", "", SCRIPT_PARAM_INFO, "")
			Param.Misc.R:addParam("CARE", "Enable tower dive _R function", SCRIPT_PARAM_ONOFF, true)
			Param.Misc.R:addParam("n1blank", "", SCRIPT_PARAM_INFO, "")
			Param.Misc.R:addParam("EnableA", "Use auto _R on allys :", SCRIPT_PARAM_ONOFF, false)
			Param.Misc.R:addParam("LifeA", "Use under X Life :", SCRIPT_PARAM_SLICE, 10, 0, 100)
			Param.Misc.R:addParam("","", SCRIPT_PARAM_INFO, "")
			for _, unit in pairs(GetAllyHeroes()) do
				if T1 == 0 then
					Param.Misc.R:addParam("A", "Enable _R on : "..unit.charName, SCRIPT_PARAM_ONOFF, true)
					T1 = 1
					Hero1 = unit.charName
				elseif T1 == 1 then
					Param.Misc.R:addParam("B", "Enable _R on : "..unit.charName, SCRIPT_PARAM_ONOFF, true)
					T1 = 2
					Hero2 = unit.charName
				elseif T1 == 2 then
					Param.Misc.R:addParam("C", "Enable _R on : "..unit.charName, SCRIPT_PARAM_ONOFF, true)
					T1 = 3
					Hero3 = unit.charName
				elseif T1 == 3 then
					Param.Misc.R:addParam("D", "Enable _R on : "..unit.charName, SCRIPT_PARAM_ONOFF, true)
					T1 = 4
					Hero4 = unit.charName
				end
			end
	--
	Param:addSubMenu("", "n2")
	--
	Param:addSubMenu("Drawing Settings", "Draw")

		--
		if VIP_USER then Param.Draw:addSubMenu("Skin Changer", "Skin") end
			if VIP_USER then Param.Draw.Skin:addParam("Enable", "Enable Skin Changer : ", SCRIPT_PARAM_ONOFF, false)
				Param.Draw.Skin:setCallback("Enable", function (nV)
					if nV then
						SetSkin(myHero, Param.Draw.Skin.skins -1)
					else
						SetSkin(myHero, -1)
					end
				end)
			end				
			if VIP_USER then Param.Draw.Skin:addParam("skins", 'Which Skin :', SCRIPT_PARAM_LIST, 1, {"Classic", "Silver", "Viridian", "Unmasked", "Battleborn", "Judgment", "Aether Wing", "Riot"})
				Param.Draw.Skin:setCallback("skins", function (nV)
					if nV then
						if Param.Draw.Skin.Enable then
							SetSkin(myHero, Param.Draw.Skin.skins -1)
						end
					end
				end)
			end
		--

		Param.Draw:addParam("Enable","Enable Draws :", SCRIPT_PARAM_ONOFF, true)
		Param.Draw:addParam("n1blank", "", SCRIPT_PARAM_INFO, "")
		Param.Draw:addParam("Target", "Draw Current Target Text :", SCRIPT_PARAM_ONOFF, true)
		Param.Draw:addParam("Killable", "Draw Killable Text (I/Q) :", SCRIPT_PARAM_ONOFF, true)
		Param.Draw:addParam("Hitbox", "Draw Kayle's Hitbox :", SCRIPT_PARAM_ONOFF, true)
		Param.Draw:addSubMenu("Damages Draw", "D")
			Param.Draw.D:addParam("AA", "Draw AA remaining to kill :", SCRIPT_PARAM_ONOFF, true)
			Param.Draw.D:addParam("Perc", "Draw %dmg per AA :", SCRIPT_PARAM_ONOFF, true)
			Param.Draw.D:addParam("D", "Draw damages for each AA :", SCRIPT_PARAM_ONOFF, true)
			Param.Draw.D:addParam("blank", "Draw on health bar before kill :", SCRIPT_PARAM_ONOFF, true)
		Param.Draw:addSubMenu("Charactere Draws","S")
			Param.Draw.S:addParam("Qdraw","Display (Q) Spell draw :", SCRIPT_PARAM_ONOFF, true)
			Param.Draw.S:addParam("Wdraw","Display (W) Spell draw :", SCRIPT_PARAM_ONOFF, true)
			Param.Draw.S:addParam("Edraw","Display (E) Spell draw :", SCRIPT_PARAM_ONOFF, true)
			Param.Draw.S:addParam("Rdraw","Display (R) Spell draw :", SCRIPT_PARAM_ONOFF, true)
			Param.Draw.S:addParam("AAdraw", "Display Auto Attack draw :", SCRIPT_PARAM_ONOFF, true)
			Param.Draw.S:addParam("", "", SCRIPT_PARAM_INFO, "")
			Param.Draw.S:addParam("L", "Display you'r life under Kayle :", SCRIPT_PARAM_ONOFF, true)
			if Smite then Param.Draw.S:addParam("n1blank", "", SCRIPT_PARAM_INFO, "") end
			if Smite then Param.Draw.S:addParam("Smite", "Display Smite draw :", SCRIPT_PARAM_ONOFF, true) end
	--
	Param:addSubMenu("", "n3")
	--
	Param:addParam("n4", "Baguette Kayle | Version", SCRIPT_PARAM_INFO, ""..version.."")
	Param:permaShow("n4")
end

function KillSteal()
	if Param.KillSteal.Enable then
		for _, unit in pairs(GetEnemyHeroes()) do
			Qdmg = ((myHero:CanUseSpell(_Q) == READY and dmgQ) or 0)
			if GetDistance(unit) < SkillQ.range then

				DQ_K = math.floor(myHero:CalcMagicDamage(unit,dmgQ))

				if unit ~= nil and not unit.dead and unit.health < DQ_K and Param.KillSteal.UseQ and myHero:CanUseSpell(_Q) == READY and ValidTarget(unit) then
					CastSpell(_Q, unit)
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

function Combo()
	if Param.Combo.UseQ then
		if target ~= nil and myHero:CanUseSpell(_Q) == READY and GetDistance(target) < SkillQ.range then
			CastSpell(_Q, target)
		end
	end
	if Param.Combo.UseW then
		if myHero:CanUseSpell(_W) == READY and not ManaWCombo() then
			if myHero.maxHealth - myHero.health > healW and myHero.health < (myHero.maxHealth * (Param.Combo.UseWValue / 100)) then
				CastSpell(_W, myHero)
			end
		end
	end
	if Param.Combo.UseE then
		if target ~= nil and myHero:CanUseSpell(_E) == READY and GetDistance(target) < SkillE.range+100 then
			CastSpell(_E)
		end
	end
end

function Harass()
	if not ManaHarass() then
		if Param.Harass.UseQ then
			if target ~= nil and myHero:CanUseSpell(_Q) == READY and GetDistance(target) < SkillQ.range then
				CastSpell(_Q, target)
			end
		end
		if Param.Harass.UseW then
			if myHero:CanUseSpell(_W) == READY and not ManaWCombo() then
				if myHero.maxHealth - myHero.health > healW and myHero.health < (myHero.maxHealth * (Param.Combo.UseWValue / 100)) then
					CastSpell(_W, myHero)
				end
			end
		end
		if Param.Harass.UseE then
			if target ~= nil and myHero:CanUseSpell(_E) == READY and GetDistance(target) < SkillE.range+100 then
				CastSpell(_E)
			end
		end
	end
end

function FleeMod()
	if Param.Misc.Flee.Key then
		if myHero:CanUseSpell(_W) == READY and Param.Misc.Flee.UseW then 
			CastSpell(_W, myHero) 
		end
		if Param.Misc.Flee.Move then
			player:MoveTo(mousePos.x, mousePos.z)
		end
		if Param.Misc.Flee.UseQ then
			for _, unit in pairs(GetEnemyHeroes()) do
				if GetDistance(unit) < SkillQ.range and myHero:CanUseSpell(_Q) == READY then
					CastSpell(_Q, unit)
				end
			end
		end
	end
end

function ManaHarass()
    if myHero.mana < (myHero.maxMana * ( Param.Harass.Mana / 100)) then
        return true
    else
        return false
    end
end

function LastHit() 

	LastHit_Gather()
end

function LaneClear()
	LastHit_Gather()
	JungleClear()
	WaveClear()
end

function JungleClear()
	jungleMinions:update()
	if not ManaJungleClear() then
		for i, jungleMinion in pairs(jungleMinions.objects) do
			if jungleMinion ~= nil and not jungleMinion.dead then
				if Param.JungleClear.UseE and GetDistance(jungleMinion) <= SkillE.range+200 and myHero:CanUseSpell(_E) == READY then
					CastSpell(_E)
				end
				if Param.JungleClear.UseQ and GetDistance(jungleMinion) <= SkillQ.range and myHero:CanUseSpell(_Q) == READY then
					CastSpell(_Q, jungleMinion)
				end
			end
		end
	end
end

function ManaJungleClear()
    if myHero.mana < (myHero.maxMana * ( Param.JungleClear.Mana / 100)) then
        return true
    else
        return false
    end
end

function WaveClear()
	enemyMinions:update()
	if not ManaWaveClear() then
		for i, minion in pairs(enemyMinions.objects) do
			if ValidTarget(minion) and minion ~= nil and not minion.dead then
				if GetDistance(minion) <= SkillE.range+200 and myHero:CanUseSpell(_E) == READY and Param.WaveClear.UseE then
					CastSpell(_E)
				end
			end
		end
	end
end

function ManaWaveClear()
    if myHero.mana < (myHero.maxMana * ( Param.JungleClear.Mana / 100)) then
        return true
    else
        return false
    end
end

function LastHit_Gather()
	enemyMinions:update()
	if not ManaLastHit() then
		for i, minion in pairs(enemyMinions.objects) do
			if ValidTarget(minion) and minion ~= nil and GetDistance(minion) < SkillQ.range then
				if Param.LastHit.UseQ then

					DQ_L = math.floor(myHero:CalcDamage(minion,dmgQ))

					if DQ_L > minion.health then
						if not CanAttack() then
							if OrbwalkManager_AA.LastTarget and minion.networkID ~= OrbwalkManager_AA.LastTarget.networkID and not IsAttacking() then
								CastSpell(_Q, minion)
				 			end
				 		end
					end

				end
			end
		end
	end
end

function ManaWCombo()
    if myHero.mana < (myHero.maxMana * ( Param.Combo.ManaW / 100)) then
        return true
    else
        return false
    end
end

function ManaLastHit()
    if myHero.mana < (myHero.maxMana * ( Param.LastHit.QMana / 100)) then
        return true
    else
        return false
    end
end

function IsAutoAttack(name)

    return name and ((tostring(name):lower():find("attack")))
end

function OnProcessAttack(unit, spell)
	if unit and spell and unit.team then
		if unit.type == "obj_AI_Turret" and GetDistance(myHero, unit) < 1500 then
			if unit.team ~= myHero.team then
				if spell.target.isMe then
					if myHero.health < 300 and myHero:CanUseSpell(_R) == READY and Param.Misc.R.CARE then
						CastSpell(_R, myHero)
					end
				end
			end
		end
	end
    if unit and spell and unit.isMe and spell.name then
        if IsAutoAttack(spell.name) then
            if not OrbwalkManager_DataUpdated then
                 OrbwalkManager_BaseAnimationTime = 1 / (spell.animationTime * myHero.attackSpeed)
                 OrbwalkManager_BaseWindUpTime = 1 / (spell.windUpTime * myHero.attackSpeed)
                 OrbwalkManager_DataUpdated = true
            end
            OrbwalkManager_AA.LastTarget = spell.target
            OrbwalkManager_AA.IsAttacking = false
            OrbwalkManager_AA.LastTime = GetTime() - Latency() - WindUpTime()
        end
    end
end

function GetTime()

	return 1 * os.clock()
end

function Latency()

	return GetLatency() / 2000
end

function WindUpTime()

	return (1 / (myHero.attackSpeed *  OrbwalkManager_BaseWindUpTime))
end

function IsAttacking()

	return not CanMove()
end

function CanMove()
	if _G.AutoCarry and _G.AutoCarry.Keys and _G.Reborn_Loaded ~= nil then
		return _G.AutoCarry.Orbwalker:CanMove()
	elseif _Pewalk then
		return _G._Pewalk.CanMove()
	elseif _G.SxOrbMenu then
		return _G.SxOrb:CanMove()
	elseif _G["BigFatOrb_Loaded"] == true then

	elseif _G.NebelwolfisOrbWalkerLoaded then
		_G.NOWi:TimeToMove()
	end
end

function CanAttack()
	if _G.AutoCarry and _G.AutoCarry.Keys and _G.Reborn_Loaded ~= nil then
		return _G.AutoCarry.Orbwalker:CanShoot()
	elseif _Pewalk then
		return _G._Pewalk.CanAttack()
	elseif _G.SxOrbMenu then
		return _G.SxOrb:CanAttack()
	elseif _G["BigFatOrb_Loaded"] == true then

	elseif _G.NebelwolfisOrbWalkerLoaded then
		_G.NOWi:TimeToAttack()
	end
end

function AutoHeal()
	if myHero:CanUseSpell(_W) == READY then
		if Param.Misc.W.Enable and recall == 0 then
			for _, unit in pairs(GetAllyHeroes()) do
				if GetDistance(unit) < SkillW.range and not ManaAA() then
					if unit.health < (unit.maxHealth * (Param.Misc.W.LifeA/100)) then
						CastSpell(_W, unit)
					end
				end
			end
			if myHero.health < (myHero.maxHealth * (Param.Misc.W.LifeH/100)) and not ManaHH() then
				CastSpell(_W, myHero)
			end
		end
	end
end

function ManaHH()
    if myHero.mana < (myHero.maxMana * ( Param.Misc.W.ManaH / 100)) then
        return true
    else
        return false
    end
end

function ManaAA()
    if myHero.mana < (myHero.maxMana * ( Param.Misc.W.ManaA / 100)) then
        return true
    else
        return false
    end
end

function AutoR()
	if myHero:CanUseSpell(_R) == READY and recall == 0 then
		if Param.Misc.R.Enable and ERange() > Param.Misc.R.Number then
			if Param.Misc.R.EnableH then
				if myHero.health < myHero.maxHealth * Param.Misc.R.LifeH / 100 then
					CastSpell(_R, myHero)
				end
			end
			if Param.Misc.R.EnableA then
				for _, unit in pairs(GetAllyHeroes()) do
					t = unit.charName
					if Param.Misc.R.t then
						if GetDistance(unit) < SkillR.range then
							if unit.health < (unit.maxHealth * (Param.Misc.R.LifeA / 100)) then
								for _, eney in pairs(GetAllyHeroes()) do
									if eney == unit then
										if eney.charName == Hero1 and Param.Misc.R.A then
											CastSpell(_R, eney)
										elseif eney.charName == Hero2 and Param.Misc.R.B then
											CastSpell(_R, eney)
										elseif eney.charName == Hero3 and Param.Misc.R.C then
											CastSpell(_R, eney)
										elseif eney.charName == Hero4 and Param.Misc.R.D then
											CastSpell(_R, eney)
										elseif eney.charName == Hero5 and Param.Misc.R.E then
											CastSpell(_R, eney)
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

function AutoLvlSpell()
 	if VIP_USER and os.clock()-Last_LevelSpell > 0.5 then
 		if Param.Misc.LVL.Enable then
	    	autoLevelSetSequence(levelSequence)
	    	Last_LevelSpell = os.clock()
	    elseif not Param.Misc.LVL.Enable then
	    	autoLevelSetSequence(nil)
	    	Last_LevelSpell = os.clock()+10
	    end
  	end
end

function AutoLvlSpellCombo()
	if VIP_USER then
		if Param.Misc.LVL.Combo == 1 then
			levelSequence =  { 3,1,2,3,3,4,3,1,3,1,4,1,1,2,2,4,2,2};
		end
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

	elseif _G.NebelwolfisOrbWalkerLoaded then

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
        "Talon", "Tristana", "Twitch", "Urgot", "Varus", "Vayne", "Zed", "Lucian", "Jinx", "Jhin",
 
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

function OnRemoveBuff(unit, buff)
	if buff.name == "rageblade" and unit.isMe then
		GuinsooStacks = 0
	end
	if buff.name == "recall" and unit.isMe then
		recall = 0
		if myHero.level >= 9 then
			if Param.Misc.Buy.TrinketBleu then
				BuyItem(3363)
			end
		end
	end
end

function OnUpdateBuff(unit, buff, Stacks)
	if buff.name == "recall" and unit.isMe then
		recall = 1
	end
	if buff.name == "rageblade" and unit.isMe then
		if Stacks > 0 then
			GuinsooStacks = Stacks
		end
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
	end
end

function ItemCheck()
	if os.clock()-Last_Item_Check > 20 then
		Last_Item_Check = os.clock()
		for SLOT = ITEM_1, ITEM_6 do
			if GetInventoryHaveItem(3085) and HurricanGet == 0 then
				HurricanGet = 1
				EnvoiMessage("Found : Runaan's Hurricane")
			end
			if GetInventoryHaveItem(3115) and NashorGet == 0 then
				NashorGet = 1
				EnvoiMessage("Found : Nashor's Tooth")
			end
			if GetInventoryHaveItem(3124) and GuinsooGet == 0 then
				GuinsooGet = 1
				EnvoiMessage("Found : Guinsoo's Rageblade")
			end
			if (GetInventoryHaveItem(3931) and Item_Jungle_Get == 0) or (GetInventoryHaveItem(3932) and Item_Jungle_Get == 0) or (GetInventoryHaveItem(3930) and Item_Jungle_Get == 0) then
				Item_Jungle_Get = 1
				EnvoiMessage("Found : Enchantment: Sated Devourer")
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
					elseif (myHero:CanUseSpell(Ignite) == not READY) then
						iDmg = 0
					end
				else 
					iDmg = 0
				end
				Qdmg = ((myHero:CanUseSpell(_Q) == READY and damageQ) or 0)
				if iDmg > enemy.health then
					KillText[i] = 1
				elseif Qdmg > enemy.health then
					KillText[i] = 2
				else
					KillText[i] = nil
				end
			end 
		end 
	end 
end

function OnDraw()
	if not myHero.dead and Param.Draw.Enable then

		if myHero:CanUseSpell(_Q) == READY and Param.Draw.S.Qdraw then 
			DrawCircle3D(myHero.x, myHero.y, myHero.z, SkillQ.range, 1, 0xFFFFFFFF)
		end
		if myHero:CanUseSpell(_W) == READY and Param.Draw.S.Wdraw then 
			DrawCircle3D(myHero.x, myHero.y, myHero.z, SkillW.range, 1, 0xFFFFFFFF)
		end
		if myHero:CanUseSpell(_E) == READY and Param.Draw.S.Edraw then 
			DrawCircle3D(myHero.x, myHero.y, myHero.z, SkillE.range, 1, 0xFFFFFFFF)
		end
		if myHero:CanUseSpell(_R) == READY and Param.Draw.S.Rdraw then
			DrawCircle3D(myHero.x, myHero.y, myHero.z, SkillR.range, 1, 0xFFFFFFFF)
		end

		if Param.Draw.S.AAdraw then
			DrawCircle3D(myHero.x, myHero.y, myHero.z, myHero.range+myHero.boundingRadius, 1, 0xFFFFFFFF)
		end

		if Smite then
			if Param.Draw.S.Smite then
				DrawCircle3D(myHero.x, myHero.y, myHero.z, 500+myHero.boundingRadius, 1, 0xFFFFFFFF)
			end
		end

		if Param.Draw.Hitbox then
			DrawCircle3D(myHero.x, myHero.y, myHero.z, myHero.boundingRadius, 1, 0xFFFFFFFF)
		end

		if Param.Draw.S.L then
			DrawText3D("% "..math.ceil(myHero.health*100/myHero.maxHealth, 2),myHero.x-10, myHero.y-50, myHero.z, 20, 0xFFFFFFFF)
		end

		-- TARGET DRAW
		if target ~= nil and ValidTarget(target) then
			if Param.Draw.Target then
				DrawText3D(">> Current |Target <<",target.x-100, target.y-50, target.z, 20, 0xFFFFFFFF)
				DrawText(""..target.charName.."", 50, 50, 200, 0xFFFFFFFF)
			end
		end

		-- I / Q

		if Param.Draw.Killable then
			for i = 1, heroManager.iCount do
				local enemy = heroManager:getHero(i)
				if enemy and ValidTarget(enemy) then
					local barPos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
					DrawText(TextList[KillText[i]], 15, barPos.x - 35, barPos.y - 50, ARGB(255,255,204,0))
				end 
			end
		end 

		-- DMG

		if Param.Draw.D.AA or Param.Draw.D.Perc or Param.Draw.D.D or Param.Draw.D.blank then
			for _, unit in pairs(GetEnemyHeroes()) do
				if unit ~= nil and GetDistance(unit) < 3000 and not unit.dead and unit.visible then
					DE_BASE = math.floor(myHero:CalcDamage(unit,dmgE))

					ItemCheck()

					if HurricanGet == 1 then
						DH = myHero:CalcDamage(unit, 15)
					else
						DH = 0
					end

					if NashorGet == 1 then
						D_NASH = myHero:CalcMagicDamage(unit, D_NASH_S)
					else
						D_NASH = 0
					end

					if GuinsooGet == 1 then
						if GuinsooStacks == 8 then
							D_GUIN = myHero:CalcMagicDamage(unit, D_GUIN_S)
						end
					else
						D_GUIN = 0
					end

					if Item_Jungle_Get == 1 then
						D_IJ = myHero:CalcMagicDamage(unit, 60)
					else		
						D_IJ = 0
					end

					DTT_I = DH + D_NASH + D_GUIN + D_IJ


					DAA_E = math.floor(myHero:CalcMagicDamage(unit,dmgE))

					if TargetHaveBuff("JudicatorRighteousFury", myHero) then
						DTOT = DAA_E + DTT_I
					else
						DTOT = DTT_I
					end

					DAA1 = math.floor(myHero:CalcDamage(unit,myHero.totalDamage)) + math.floor(myHero:CalcMagicDamage(unit,dmgEPassif))

					if not TargetHaveBuff("SummonerExhaust", myHero) then
						DZ = math.floor(DAA1+DTOT)
					elseif TargetHaveBuff("SummonerExhaust", myHero) then
						DZ = math.floor((DAA1+DTOT)-(((DAA1+DTOT)*40)/100))
					end

					if Param.Draw.D.Perc then

						D3E1 = math.floor(DZ/unit.health*100)

						if D3E1 < 80 then
							DrawText3D(D3E1.."%", unit.x+155, unit.y+125, unit.z+175, 30, ARGB(255,250,250,250), 0)
						elseif D3E1 >= 80 and D3E1 < 100 then
							DrawText3D(D3E1.."%", unit.x+155, unit.y+125, unit.z+175, 30, ARGB(255,205,51,51), 0)
						elseif D3E1 >= 100 then
							DrawText3D("100% !", unit.x+155, unit.y+125, unit.z+175, 30, ARGB(255,205,51,51), 0)
						end
					end

					if Param.Draw.D.AA then

						D4E1 = math.floor(unit.health/DZ)

						if D4E1 > 1 then
							DrawText3D(""..D4E1.."", unit.x+125, unit.y+85, unit.z+155, 30, ARGB(255,250,250,250), 0)
						else 
							DrawText3D("Last hit ^^", unit.x+125, unit.y+85, unit.z+155, 30, ARGB(255,250,250,250), 0)
						end

					end

					if Param.Draw.D.D then
						DrawText3D(""..DZ.."", unit.x+50, unit.y+125, unit.z+155, 30, ARGB(255,250,250,250), 0)
					end

					if Param.Draw.D.blank then
						local Center = GetUnitHPBarPos(unit)
						if Center.x > -100 and Center.x < WINDOW_W+100 and Center.y > -100 and Center.y < WINDOW_H+100 then
							local off = GetUnitHPBarOffset(unit)
							local y=Center.y + (off.y * 53) + 2
							local xOff = ({['AniviaEgg'] = -0.1,['Darius'] = -0.05,['Renekton'] = -0.05,['Sion'] = -0.05,['Thresh'] = -0.03,})[unit.charName]
							local x = Center.x + ((xOff or 0) * 140) - 66
							dmg = unit.health - DZ
							DrawLine(x + ((unit.health /unit.maxHealth) * 104),y, x+(((dmg > 0 and dmg or 0) / unit.maxHealth) * 104),y,9, GetDistance(unit) < 3000 and 0x6699FFFF)
						end
					end
				end
			end
		end

		-- SMITE
		if Param.Draw.S.Smite and Smite then
			jungleMinions:update()
			for i, jungleMinion in pairs(jungleMinions.objects) do
				if jungleMinion ~= nil and GetDistance(jungleMinion) < 500*4+myHero.boundingRadius and Epiques[jungleMinion.name] or Normal[jungleMinion.name] or Buff[jungleMinion.name] or jungleMinion.charName:lower():find("dragon") then
					D_SX = math.round(D_SM() * 100 / jungleMinion.health, 2)
					if D_SX >= 100 then
						DrawText3D(">>SMITE.<<", jungleMinion.x+125, jungleMinion.y+85, jungleMinion.z+155, 30, ARGB(255,205,51,51), 0)
					elseif D_SX < 100 and D_SX >= 80 then
						DrawText3D(D_SX.." %", jungleMinion.x+125, jungleMinion.y+85, jungleMinion.z+155, 30, ARGB(255,205,51,51), 0)
					elseif D_SX < 80 then
						DrawText3D(D_SX.." %", jungleMinion.x+125, jungleMinion.y+85, jungleMinion.z+155, 30, ARGB(255,250,250,250), 0)
					end
				end
			end
		end
	end
end

function OnNewPath(unit, startPos, endPos, isDash, dashSpeed, dashGravity, dashDistance)
	if unit.isMe and Param.Misc.W.Fast then
		if myHero:CanUseSpell(_W) == READY then
			if GetGame().map.shortName == "summonerRift" and GetDistance(myHero.endPath) > 3569 then
				CastSpell(_W, myHero)
			end
		end
	end
end

Epiques = {
	['SRU_RiftHerald17.1.1'] = {true}, -- Blue | Haut
	['SRU_Baron12.1.1'] = {true}, -- Blue | Haut
	['SRU_Dragon_Water'] = {true}, -- Blue | Bas
	['SRU_Dragon_Fire'] = {true}, -- Blue | Bas
	['SRU_Dragon_Earth'] = {true}, -- Blue | Bas
	['SRU_Dragon_Air'] = {true}, -- Blue | Bas
	['SRU_Dragon_Elder'] = {true} -- Blue | Bas
}

Buff = {
	['SRU_Red4.1.1'] = {true}, -- Blue | Bas
	['SRU_Blue1.1.1'] = {true}, -- Blue | Haut
	['SRU_Blue7.1.1'] = {true}, -- Red | Bas
	['SRU_Red10.1.1'] = {true} -- Red | Haut
}

Normal = {
	-- Blue | Bas
	['SRU_Krug5.1.2'] = {true},
	['SRU_Razorbeak3.1.1'] = {true},
	['Sru_Crab15.1.1'] = {true},
	-- Blue | Haut
	['SRU_Murkwolf2.1.1'] = {true},
	['SRU_Gromp13.1.1'] = {true},
	['Sru_Crab16.1.1'] = {true},
	-- Red | Bas
	['SRU_Gromp14.1.1'] = {true},
	['SRU_Murkwolf8.1.1'] = {true},
	-- Red | Haut
	['SRU_Razorbeak9.1.1'] = {true},
	['SRU_Krug11.1.2'] = {true}
}

function AutoSmite()
	if Param.JungleClear.Enable then
		jungleMinions:update()
		for i, jungleMinion in pairs(jungleMinions.objects) do
			if jungleMinion ~= nil and GetDistance(jungleMinion) < 500+myHero.boundingRadius then
				if jungleMinion.health < D_SM() and myHero:CanUseSpell(Smite) == READY and ValidTarget(jungleMinion) then
					if Param.JungleClear.Selector == 1 then
						if Epiques[jungleMinion.name] or jungleMinion.charName:lower():find("dragon") then
							CastSpell(Smite, jungleMinion)
						end
					elseif Param.JungleClear.Selector == 2 then
						if Buff[jungleMinion.name] then
							CastSpell(Smite, jungleMinion)
						end
					elseif Param.JungleClear.Selector == 3 then
						if Epiques[jungleMinion.name] or Buff[jungleMinion.name] then
							CastSpell(Smite, jungleMinion)
						end
					elseif Param.JungleClear.Selector == 4 then
						if Epiques[jungleMinion.name] or Normal[jungleMinion.name] or Buff[jungleMinion.name] or jungleMinion.charName:lower():find("dragon") then
							CastSpell(Smite, jungleMinion)
						end
					end
				end
			end
		end
	end
end

function D_SM()
	if myHero.level <= 4 then
		dmgSmite = 370 + (myHero.level*20)
	end
	if myHero.level > 4 and myHero.level <= 9 then
		dmgSmite = 330 + (myHero.level*30)
	end
	if myHero.level > 9 and myHero.level <= 14 then
		dmgSmite = 240 + (myHero.level*40)
	end
	if myHero.level > 14 then
		dmgSmite = 100 + (myHero.level*50)
	end
	return dmgSmite
end

function ERange() 
	EnnemyInRange = 0
	for _, unit in pairs(GetEnemyHeroes()) do
		if unit.visible and not unit.dead then
			if GetDistance(unit) < 2000 then
				EnnemyInRange = EnnemyInRange + 1
			end
		end
	end
	return EnnemyInRange
end
