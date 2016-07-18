--[[

Script by spyk for Kalista.

=> BaguetteKalista.lua

- Github link : https://github.com/spyk1/BoL/blob/master/BaguetteKalista/BaguetteKalista.lua

- Forum Thread : http://forum.botoflegends.com/topic/90794-beta-baguette-kalista/

]]--

if myHero.charName ~= "Kalista" then return end

function EnvoiMessage(msg)

	PrintChat("<font color=\"#e74c3c\"><b>[BaguetteKalista]</b></font> <font color=\"#ffffff\">" .. msg .. "</font>")
end

function drawCircles(x,y,z,color)

    DrawCircle(x, y, z, 50, color)
end

function CurrentTimeInMillis()

	return (os.clock() * 1000)
end

-- Misc
local bind = 0
local D3E1 = 0
local DAA = 0
local dmg = 0
local HurricanGet = 0
local Last_Hurrican = 120
local Human = 0
local Last_Humanizer = 10
-- Immune check
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
-- E gather
local OrbwalkManager_AA = {LastTime = 0, LastTarget = nil, IsAttacking = false, Object = nil}
local OrbwalkManager_DataUpdated = false
local OrbwalkManager_BaseWindUpTime = 3
local OrbwalkManager_BaseAnimationTime = 0.665
-- E
local unitStacks = {}
-- Jgl security
local LastMSG = 0
local Dragons = 0
-- Pred dmgs
local dmgQ = 60 * myHero:GetSpellData(_Q).level + 10 + myHero.totalDamage
local dmgE = 15 * myHero:GetSpellData(_E).level + 5 + .6 * myHero.totalDamage
local Exhausted = 0
-- Potions
local lastPotion = 0
local ActualPotTime = 15
local ActualPotName = "None"
local ActualPotData = "None"
-- QSS
local Last_Item_Check = 0
local lastRemove = 0
local MercurialGet = 0
local QSSGet = 0
-- Kite
local AAON = 0
--- Starting AutoUpdate
local version = "0.30004"
local author = "spyk"
local SCRIPT_NAME = "BaguetteKalista"
local AUTOUPDATE = true
local UPDATE_HOST = "raw.githubusercontent.com"
local UPDATE_PATH = "/spyk1/BoL/master/BaguetteKalista/BaguetteKalista.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

if AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/spyk1/BoL/master/BaguetteKalista/BaguetteKalista.version")
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
 	print("<font color=\"#ffffff\">Loading</font><font color=\"#e74c3c\"><b> [BaguetteKalista]</b></font> <font color=\"#ffffff\">by spyk</font>")

 	-------------------MENU|PARAMETRES--------------------------
	Param = scriptConfig("[Baguette] Kalista", "BaguetteKalista")
	-------------------COMBO|OPTION-----------------------------
	Param:addSubMenu("Combo Settings", "Combo")
		Param.Combo:addParam("Q", "Use (Q) Spell in Combo :", SCRIPT_PARAM_ONOFF, true)
		Param.Combo:addParam("E", "Use (E) Spell in Combo :", SCRIPT_PARAM_ONOFF, true)
		Param.Combo:addParam("Kite", "Kite on minion if the target is outrange :", SCRIPT_PARAM_ONOFF, true)
	-------------------HARASS|OPTION----------------------------
	Param:addSubMenu("Harass Settings", "Harass")
		Param.Harass:addParam("Q", "Use (Q) Spell in Harass :", SCRIPT_PARAM_ONOFF, true)
		Param.Harass:addParam("E", "Use (E) Spell in Harass :", SCRIPT_PARAM_ONOFF, true)
		Param.Harass:addSubMenu("(E) Spell Settings", "E")
			Param.Harass.E:addParam("Auto", "Enable Auto (E) Harass :", SCRIPT_PARAM_ONOFF, true)
			Param.Harass.E:addParam("n0Blank", "", SCRIPT_PARAM_INFO, "")
			Param.Harass.E:addParam("n1blank", "Set a value for how many minions", SCRIPT_PARAM_INFO, "")
			Param.Harass.E:addParam("Minions", "have to be killed :", SCRIPT_PARAM_SLICE, 1, 0, 6)
			Param.Harass.E:addParam("n2blank", "", SCRIPT_PARAM_INFO, "")
			Param.Harass.E:addParam("n3blank", "Set a value for how many (E) Stacks", SCRIPT_PARAM_INFO, "")
			Param.Harass.E:addParam("AAHero", "have to be on Hero :", SCRIPT_PARAM_SLICE, 1, 0, 10)
			Param.Harass.E:addParam("n4blank", "", SCRIPT_PARAM_INFO, "")
			Param.Harass.E:addParam("Mana", "Set a value for the Mana (%)", SCRIPT_PARAM_SLICE, 50, 0, 100)
		Param.Harass:addSubMenu("Q/E Harass :", "QE")
			Param.Harass.QE:addParam("Enable", "Enable Q/E On Harass:", SCRIPT_PARAM_ONOFF, true)
			Param.Harass.QE:addParam("Stacks", "Min. stacks to Q/E :", SCRIPT_PARAM_SLICE, 2, 1, 10)
	------------------------------------------------------------
	Param:addSubMenu("", "n1")
	------------------------------------------------------------

	-------------------KILLSTEAL|OPTION-------------------------
	Param:addSubMenu("KillSteal Settings", "KillSteal")
		Param.KillSteal:addParam("Enable", "Enable KillSteal :", SCRIPT_PARAM_ONOFF, true)
		Param.KillSteal:addParam("Q", "Use (Q) Spell in KillSteal :", SCRIPT_PARAM_ONOFF, true)
		Param.KillSteal:addParam("E", "Use (E) Spell in KillSteal :", SCRIPT_PARAM_ONOFF, true)

	------------------------------------------------------------
	Param:addSubMenu("", "n2")
	------------------------------------------------------------

	-------------------LASTHIT|OPTION---------------------------
	Param:addSubMenu("LastHit Settings", "LastHit")
		Param.LastHit:addSubMenu("(E) Spell Settings", "E")
			Param.LastHit.E:addParam("Enable", "Enable (E) Spell to LastHit :", SCRIPT_PARAM_ONOFF, true)
			Param.LastHit.E:addParam("n0Blank", "", SCRIPT_PARAM_INFO, "")
			Param.LastHit.E:addParam("Count", "(Auto)How many creeps to kill :", SCRIPT_PARAM_SLICE, 2, 1, 6)
			Param.LastHit.E:addParam("n1blank", "", SCRIPT_PARAM_INFO, "")
			Param.LastHit.E:addParam("Hurrican", "Enable Hurrican Check :", SCRIPT_PARAM_ONOFF, false)
			Param.LastHit.E:addParam("CountHurrican", "How many with Hurrican :", SCRIPT_PARAM_SLICE, 3, 1, 6)
			Param.LastHit.E:addParam("n2blank", "", SCRIPT_PARAM_INFO, "")
			Param.LastHit.E:addParam("Gather", "Enable anti AA fail last hit :", SCRIPT_PARAM_ONOFF, true)
			Param.LastHit.E:addParam("n3Blank", "", SCRIPT_PARAM_INFO, "")
			Param.LastHit.E:addParam("Mana", "Set a value for the Mana (%)", SCRIPT_PARAM_SLICE, 50, 0, 100)
	-------------------WAVECLEAR|OPTION-------------------------
	Param:addSubMenu("WaveClear Settings", "WaveClear")
		--Param.WaveClear:addParam("Key", "Advanced WaveClear Key :", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("T"))
		Param.WaveClear:addParam("Q", "Enable (Q) Spell in WaveClear :", SCRIPT_PARAM_ONOFF, false)
		Param.WaveClear:addParam("QMana", "Set a value for the Mana (%)", SCRIPT_PARAM_SLICE, 50, 0, 100)
	-------------------JUNGLE|OPTIONS---------------------------
	Param:addSubMenu("Jungle Settings", "Jungle")
		Param.Jungle:addSubMenu("(E) Spell Settings", "E")
			Param.Jungle.E:addParam("Enable", "Enable (E) Spell with Jungle Mobs :", SCRIPT_PARAM_ONOFF, true)
			--
			Param.Jungle.E:addParam("n0Blank", "", SCRIPT_PARAM_INFO, "")
			--
			Param.Jungle.E:addParam("SpecialMob", "Enable Auto Kill on SpecialMobs :", SCRIPT_PARAM_ONOFF, true)
			Param.Jungle.E:addParam("n1SpecialMob", "SpecialMobs : Drake, Rift Herald and Baron.", SCRIPT_PARAM_INFO, "")
			--
			Param.Jungle.E:addParam("n1Blank", "", SCRIPT_PARAM_INFO, "")
			--
			Param.Jungle.E:addParam("BuffMob", "Enable Auto Kill on BuffMobs :", SCRIPT_PARAM_ONOFF, true)
			Param.Jungle.E:addParam("n1BuffMob", "BuffMobs : Red Buff and Blue Buff on the both sides.", SCRIPT_PARAM_INFO, "")
			--
			Param.Jungle.E:addParam("n2Blank", "", SCRIPT_PARAM_INFO, "")
			--
			Param.Jungle.E:addParam("NormalMob", "Enable Auto Kill on NormalMob :", SCRIPT_PARAM_ONOFF, true)
			Param.Jungle.E:addParam("n1NormalMob", "NormalMob : Krug, Razorbeak, Murkwolf, Crab, Gromp.", SCRIPT_PARAM_INFO, "")
			Param.Jungle.E:addParam("All", "Use (E) Spell if you has > 1 mobs to kill?", SCRIPT_PARAM_ONOFF, true)
			Param.Jungle.E:addParam("early", "Enable Early Jungle Help Security?", SCRIPT_PARAM_ONOFF, true)

		Param.Jungle:addParam("Q", "Enable (Q) Spell in Jungle :", SCRIPT_PARAM_ONOFF, true)
		Param.Jungle:addParam("QMana", "Set a value for the Mana (%)", SCRIPT_PARAM_SLICE, 50, 0, 100)
	
	------------------------------------------------------------
	Param:addSubMenu("", "n3")
	------------------------------------------------------------

	-------------------DRAW|OPTIONS-----------------------------------
	Param:addSubMenu("Draw", "Draw")
		Param.Draw:addParam("AA", "Display (AA) Range :", SCRIPT_PARAM_ONOFF, false)
		Param.Draw:addParam("HitBox", "Display (HitBox) of Kalista :", SCRIPT_PARAM_ONOFF, true)
		Param.Draw:addParam("Q", "Display (Q) Spell Range :", SCRIPT_PARAM_ONOFF, false)
		Param.Draw:addParam("W", "Display (W) Spell Range :", SCRIPT_PARAM_ONOFF, false)
		Param.Draw:addParam("E", "Display (E) Spell Range :", SCRIPT_PARAM_ONOFF, true)
		Param.Draw:addSubMenu("Special Draw Settings for (E) Spell :", "EDraw")
			Param.Draw.EDraw:addParam("Hero", "Display percent deal by (E) on Heroes :", SCRIPT_PARAM_ONOFF, true) 
			Param.Draw.EDraw:addParam("Mob", "Display percent deal by (E) on Mobs :", SCRIPT_PARAM_ONOFF, true) 
			Param.Draw.EDraw:addParam("n1Blank", "", SCRIPT_PARAM_INFO, "")
			Param.Draw.EDraw:addParam("Hero2", "Display AA remaining for (E) Spell on Hero :", SCRIPT_PARAM_ONOFF, true)
			Param.Draw.EDraw:addParam("Mob2", "Display AA reamining for (E) Spell on Mob :", SCRIPT_PARAM_ONOFF, true)
			Param.Draw.EDraw:addParam("n2Blank", "", SCRIPT_PARAM_INFO, "")
			Param.Draw.EDraw:addParam("Hero3", "Display current damages for (E) Spell on Hero :", SCRIPT_PARAM_ONOFF, true)
			Param.Draw.EDraw:addParam("Mob3", "Display current damages for (E) Spell on Mob :", SCRIPT_PARAM_ONOFF, true)
			Param.Draw.EDraw:addParam("n3Blank", "", SCRIPT_PARAM_INFO, "")
			Param.Draw.EDraw:addParam("HeroBlock", "Display damages on health bar :", SCRIPT_PARAM_ONOFF, true)
		Param.Draw:addParam("R", "Display (R) Spell Range :", SCRIPT_PARAM_ONOFF, false)
		Param.Draw:addParam("Target", "Display Target Draw :", SCRIPT_PARAM_ONOFF, true)
		Param.Draw:addParam("n1Blank", "", SCRIPT_PARAM_INFO, "")
		Param.Draw:addParam("LagFree", "Enable LagFree Draws :", SCRIPT_PARAM_ONOFF, true)
		Param.Draw:addParam("n2blank", "", SCRIPT_PARAM_INFO, "")
		Param.Draw:addParam("Disable", "Disable every Draws :", SCRIPT_PARAM_ONOFF, false)
		Param.Draw:addSubMenu("WallJump", "WallJump")
			Param.Draw.WallJump:addParam("Enable", " Enable WallJump :", SCRIPT_PARAM_ONOFF, true)

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
			if VIP_USER then Param.Draw.Skin:addParam("skins", 'Which Skin :', SCRIPT_PARAM_LIST, 1, {"Classic", "Blood Moon", "Championship"})
				Param.Draw.Skin:setCallback("skins", function (nV)
					if nV then
						if Param.Draw.Skin.Enable then
							SetSkin(myHero, Param.Draw.Skin.skins -1)
						end
					end
				end)
			end

	------------------------------------------------------------
	Param:addSubMenu("", "n4")
	------------------------------------------------------------

	-------------------MISC|OPTIONS-----------------------------------
	Param:addSubMenu("Miscellaneous", "Misc")
		Param.Misc:addSubMenu("(R) Saver Settings", "R")
			Param.Misc.R:addParam("Enable", "Enable this feature :", SCRIPT_PARAM_ONOFF, true)
			Param.Misc.R:addParam("n1Blank", "", SCRIPT_PARAM_INFO, "")
			Param.Misc.R:addParam("Life", "Auto ult if HP < X :", SCRIPT_PARAM_SLICE, 15, 0, 100)
			Param.Misc.R:addParam("n2Blank", "", SCRIPT_PARAM_INFO, "")
			Param.Misc.R:addParam("ninf", "Anti Ults (Annie/Malph) should come soon !", SCRIPT_PARAM_INFO, "")
		if VIP_USER then Param.Misc:addSubMenu("Auto LVL Spell :", "LVL") end
			if VIP_USER then Param.Misc.LVL:addParam("Enable", "Enable Auto Level Spell?", SCRIPT_PARAM_ONOFF, true) end
			if VIP_USER then Param.Misc.LVL:addParam("Combo", "LVL Spell Order :", SCRIPT_PARAM_LIST, 1, {"E > W > Q (Max E)", "W > E > Q (Max E)", "Q > E > W (Max E)", "E > Q > W (Max E)"}) end
			if VIP_USER then Param.Misc.LVL:setCallback("Combo", function (nV)
				if nV then
					AutoLvlSpellCombo()
				else 
					AutoLvlSpellCombo()
				end
			end)
			end
			if VIP_USER then Last_LevelSpell = 0 end
		Param.Misc:addSubMenu("Masteries :", "Masteries")
			Param.Misc.Masteries:addParam("DoubleEdgedSword", "Double Edeged Sword :", SCRIPT_PARAM_ONOFF, false)
			Param.Misc.Masteries:addParam("BountyHunter", "Bounty Hunter :", SCRIPT_PARAM_ONOFF, false)
			Param.Misc.Masteries:addParam("Merciless", "Merciless :", SCRIPT_PARAM_ONOFF, false)
			Param.Misc.Masteries:addParam("Oppresor", "Oppresor :", SCRIPT_PARAM_ONOFF, false)
			Param.Misc.Masteries:addParam("Assassin", "Assassin :", SCRIPT_PARAM_ONOFF, false)
			Param.Misc.Masteries:addParam("n1Blank", "If you took my Masteries Config on the forum, then,", SCRIPT_PARAM_INFO, "")
			Param.Misc.Masteries:addParam("n1Blank", "set only : 'Merciless' and 'Oppresor' to true.", SCRIPT_PARAM_INFO, "")
		if VIP_USER then Param.Misc:addSubMenu("Auto Buy Starter :", "Starter") end
			if VIP_USER then Param.Misc.Starter:addParam("Doran", "Buy a doran blade :", SCRIPT_PARAM_ONOFF, true) end
			if VIP_USER then Param.Misc.Starter:addParam("Pots", "Buy a potion :", SCRIPT_PARAM_ONOFF, true) end
			if VIP_USER then Param.Misc.Starter:addParam("Trinket", "Buy a Green Trinket :", SCRIPT_PARAM_ONOFF, true) end
			if VIP_USER then Param.Misc.Starter:addParam("n1blank", "", SCRIPT_PARAM_INFO, "") end
			if VIP_USER then Param.Misc.Starter:addParam("TrinketBleu", "Buy a Blue Trinket at lvl.9 :", SCRIPT_PARAM_ONOFF, true) end
		Param.Misc:addSubMenu("Sentinel Trick :", "WTrick")
			Param.Misc.WTrick:addParam("Drake", "Cast (W) Spell trick on Drake :", SCRIPT_PARAM_ONOFF, false)
				Param.Misc.WTrick:setCallback("Drake", function (nV)
					if nV then
						CastSpell(_W, 9866.148, -71, 4414.014)
						Param.Misc.WTrick.Drake = false
					end
				end)
			Param.Misc.WTrick:addParam("DrakeKey", "Cast (W) Spell trick on Drake :", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("Y"))
				Param.Misc.WTrick:setCallback("DrakeKey", function (nV)
					if nV then
						CastSpell(_W, 9866.148, -71, 4414.014)
					end
				end)
			Param.Misc.WTrick:addParam("n1blank", "", SCRIPT_PARAM_INFO, "")
			Param.Misc.WTrick:addParam("Baron", "Cast (W) Spell trick on Baron :", SCRIPT_PARAM_ONOFF, false)
				Param.Misc.WTrick:setCallback("Baron", function (nV)
					if nV then
						CastSpell(_W, 5007.124, -71, 10471.45)
						Param.Misc.WTrick.Baron = false
					end
				end)
			Param.Misc.WTrick:addParam("BaronKey", "Cast (W) Spell trick on Baron :", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("M"))
				Param.Misc.WTrick:setCallback("BaronKey", function (nV)
						if nV then
							CastSpell(_W, 5007.124, -71, 10471.45)
						end
					end)
		Param.Misc:addSubMenu("Items :", "Items")
			Param.Misc.Items:addParam("Pot", "Use potions with this script :", SCRIPT_PARAM_ONOFF, true)
			Param.Misc.Items:addParam("PotXHP", "At how many %HP :", SCRIPT_PARAM_SLICE, 60, 0, 100)
			Param.Misc.Items:addParam("PotCombo", "Use potions only in ComboMode :", SCRIPT_PARAM_ONOFF, true)
		Param.Misc:addSubMenu("Auto QSS", "QSS")
				Param.Misc.QSS:addParam("Enable", "Enable the Auto Qss :", SCRIPT_PARAM_ONOFF, true)
				Param.Misc.QSS:addParam("n1blank", "", SCRIPT_PARAM_INFO, "")
				Param.Misc.QSS:addParam("n1blank", "------------------------- Buff To QSS ------------------------", SCRIPT_PARAM_INFO, "")
				Param.Misc.QSS:addParam("n1blank", "", SCRIPT_PARAM_INFO, "")
				Param.Misc.QSS:addParam("Exhaust", "On Exhaust :", SCRIPT_PARAM_ONOFF, true)
				Param.Misc.QSS:addParam("n1blank", "", SCRIPT_PARAM_INFO, "")
				Param.Misc.QSS:addParam("Stun", "On Stun :", SCRIPT_PARAM_ONOFF, true)
				Param.Misc.QSS:addParam("Taunt", "On Taunt :", SCRIPT_PARAM_ONOFF, true)
				Param.Misc.QSS:addParam("Slow", "On Slow :", SCRIPT_PARAM_ONOFF, false)
				Param.Misc.QSS:addParam("Trap", "On Trap :", SCRIPT_PARAM_ONOFF, true)
				Param.Misc.QSS:addParam("Fear", "On Fear :", SCRIPT_PARAM_ONOFF, true)
				Param.Misc.QSS:addParam("Charm", "On Charm :", SCRIPT_PARAM_ONOFF, true)
				Param.Misc.QSS:addParam("Blind", "On Blind :", SCRIPT_PARAM_ONOFF, false)
				Param.Misc.QSS:addParam("n1blank", "", SCRIPT_PARAM_INFO, "")
				Param.Misc.QSS:addParam("BlitzQ", "On BlitzQ :", SCRIPT_PARAM_ONOFF, true)
		Param.Misc:addSubMenu("Balista / Tahmista :", "Blitz")
			Param.Misc.Blitz:addParam("Blitz", "Enable Balista Combo :", SCRIPT_PARAM_ONOFF, true)
			Param.Misc.Blitz:addParam("BlitzRangeMin", "Set the minimum range to use :", SCRIPT_PARAM_SLICE, 400, 0, 1400)
			Param.Misc.Blitz:addParam("BlitzRangeMax", "Set the maximum range to use :", SCRIPT_PARAM_SLICE, 1400, 0, 1400)
			Param.Misc.Blitz:addParam("n1Blank", "", SCRIPT_PARAM_INFO, "")
			Param.Misc.Blitz:addParam("Tahm", "Enable TahmKench Combo :", SCRIPT_PARAM_ONOFF, true)
			Param.Misc.Blitz:addParam("TahmRangeMin", "Set the minimum range to use :", SCRIPT_PARAM_SLICE, 800, 0, 1400)
			Param.Misc.Blitz:addParam("TahmRangeMax", "Set the maximum range to use :", SCRIPT_PARAM_SLICE, 1400, 0, 1400)
		Param.Misc:addSubMenu("WallJump", "WallJump")
			Param.Misc.WallJump:addParam("Enable", " Enable WallJump :", SCRIPT_PARAM_ONOFF, true)
			Param.Misc.WTrick:addParam("n1blank", "", SCRIPT_PARAM_INFO, "")
			Param.Misc.WTrick:addParam("n1info", "You have to right-click where you are on a spot", SCRIPT_PARAM_INFO, "")
			Param.Misc.WTrick:addParam("n2info", "to use the wall jump function. ", SCRIPT_PARAM_INFO, "")
		Param.Misc:addParam("PermaE", "Enable (E) to kill when it's possible :", SCRIPT_PARAM_ONOFF, true)

	------------------------------------------------------------
	Param:addSubMenu("", "n5")
	------------------------------------------------------------

	-------------------ORBWALKER & PREDICTION-------------------------
	Param:addSubMenu("OrbWalker", "orbwalker")
		Param.orbwalker:addParam("n1", "OrbWalker :", SCRIPT_PARAM_LIST, 3, {"SxOrbWalk", "BigFat OrbWalker", "Nebelwolfi's Orb Walker", "Simple Orbwalker"})
		Param.orbwalker:addParam("n2", "If you want to change OrbWalker,", SCRIPT_PARAM_INFO, "")
		Param.orbwalker:addParam("n3", "Then, change it and press double F9.", SCRIPT_PARAM_INFO, "")
		Param.orbwalker:addParam("n4", "", SCRIPT_PARAM_INFO, "")
		Param.orbwalker:addParam("n5", "=> SAC:R & Pewalk are automaticly loaded.", SCRIPT_PARAM_INFO, "")
		Param.orbwalker:addParam("n6", "=> Enable one of them in BoLStudio", SCRIPT_PARAM_INFO, "")
	--

	------------------------------------------------------------
	Param:addSubMenu("", "n6")
	------------------------------------------------------------
	Param:addParam("n7", "", SCRIPT_PARAM_INFO, "")
	------------------------------------------------------------
	Param:addParam("Humanizer", "Use Humanizer ? -not recommanded-", SCRIPT_PARAM_ONOFF, false)
	------------------------------------------------------------
	Param:addParam("n6", "", SCRIPT_PARAM_INFO, "")
	------------------------------------------------------------

	Param:addParam("n4", "Baguette Kalista | Version", SCRIPT_PARAM_INFO, ""..version.."")
	Param:permaShow("n4")

	CustomLoad()
end

function CustomLoad()

	Param.Misc.WTrick.Drake = false
	Param.Misc.WTrick.Baron = false

	enemyMinions = minionManager(MINION_ENEMY, 1150, myHero, MINION_SORT_HEALTH_ASC)
	jungleMinions = minionManager(MINION_JUNGLE, 1150, myHero, MINION_SORT_MAXHEALTH_DEC)
	ts = TargetSelector(TARGET_LESS_CAST_PRIORITY, 1150, DAMAGE_MAGIC)
	ts.name = "Kalista"
	Param:addTS(ts)
	LoadVPred()

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

	DelayAction(function() AutoBuy() end, 3)

	LoadSpikeLib()

	local BlackSpearCheck = 0

	for SLOT = ITEM_1, ITEM_6 do
		if GetInventoryHaveItem(3599) then
			BlackSpearCheck = 1
		end
	end
	if BlackSpearCheck == 1 then
		DelayAction(function()
			local BlackSpear = 0
			for SLOT = ITEM_1, ITEM_6 do
				if GetInventoryHaveItem(3599) then
					BlackSpear = 1
				end
			end
			if bind == 0 and BlackSpear == 1 then 
				EnvoiMessage("You should bind with an ally!")
			end
		end, 300)
	elseif FileExist(LIB_PATH .. "BaguetteKalista.key") then
		local file = assert(io.open(LIB_PATH .. "BaguetteKalista.key","r"))
		local userKey = file:read("*l")
		bind = userKey
	end

	AutoLvlSpellCombo()

	if VIP_USER then
		if Param.Draw.Skin.Enable then
			SetSkin(myHero, Param.Draw.Skin.skins -1)
		end
	end
end

function LoadSXOrb()
	if FileExist(LIB_PATH .. "/SxOrbWalk.lua") then
		require("SxOrbWalk")
		Param:addSubMenu("SxOrbWalk", "SXMenu")
		SxOrb:LoadToMenu(Param.SXMenu)
	else
		EnvoiMessage("Download a Fresh BoL Folder.")
	end
end

function LoadSimpleOrb()
	if FileExist(LIB_PATH.."/S1mpleorbWalker.lua") then
		require("S1mpleOrbWalker")
	else
		local Host = "scarjit.de"
		local Path = "/S1mpleScripts/Scripts/BolStudio/OrbWalker/S1Loader.lua".."?rand="..math.random(1,10000)
		EnvoiMessage("Simple OrbWalker not found!")
		DownloadFile("https://"..Host..Path, LibPath, function ()  end)
		DelayAction(function () 
			require("S1mpleOrbWalker") 
		end, 5)
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
	else
		DelayAction(function()EnvoiMessage("Failed to Load SAC:R")end, 7)
	end 
end

function LoadPewalk()
	if _Pewalk then
	elseif not _Pewalk then
		EnvoiMessage("Pewalk loading error")
	end
end

function LoadVPred()
	if FileExist(LIB_PATH .. "/VPrediction.lua") then
		require("VPrediction")
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

function OnTick()
	if not myHero.dead then

		ts:update()

		Target = GetCustomTarget()

		Keys()

		KillSteal()

		Spell()

		Consommables()

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
		else 
			LastHit_Gather()
		end

		if not _G.AutoCarry.Keys.AutoCarry and AAON == 1 then
			_G.AutoCarry.Keys.LaneClear = false
			AAON = 0
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
		else
			LastHit_Gather()
		end

		if not _G._Pewalk.GetActiveMode().Carry and AAON == 1 then
			_G._Pewalk.GetActiveMode().LaneClear = false
			AAON = 0
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
		else
			LastHit_Gather()
		end

		if not _G.SxOrbMenu.AutoCarry and AAON == 1 then
			_G.SxOrbMenu.LaneClear = false
			AAON = 0
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
		else
			LastHit_Gather()
		end
	
		if not _G["BigFatOrb_Mode"] == 'Combo' and AAON == 1 then
		 	_G["BigFatOrb_Mode"] = 'Combo'
		 	AAON = 0
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
		else 
			LastHit_Gather()
		end

		if not _G.NebelwolfisOrbWalker.Config.k.Combo and AAON == 1 then
			_G.NebelwolfisOrbWalker.Config.k.LaneClear = false 
			AAON = 0
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

function KillSteal()
	if Param.KillSteal.Enable then
		for _, unit in pairs(GetEnemyHeroes()) do
			Qdmg = ((myHero:CanUseSpell(_Q) == READY and myHero:CalcDamage(unit,dmgQ)) or 0)
			if GetDistance(unit) < SkillQ.range then
				if unit.health < Qdmg and Param.KillSteal.Q and myHero:CanUseSpell(_Q) == READY and ValidTarget(unit) and unit ~= nil then
					local castPos, HitChance, pos = VP:GetLineCastPosition(unit, SkillQ.delay, SkillQ.width, SkillQ.range, SkillQ.speed, myHero, true)
					if HitChance >= 2 then
						CastSpell(_Q, castPos.x, castPos.z)
					end
				end
				if Param.KillSteal.E and not Param.Misc.PermaE and myHero:CanUseSpell(_E) == READY and ValidTarget(unit) and GetDistance(unit) < SkillE.range then
					AutoEHero()
				end
			end
		end
	end
end

function Spell()
	if Param.Misc.PermaE then
		AutoEHero()
	end
	if Param.LastHit.E.Enable then
		AutoEMinion()
	end
	if Param.Jungle.E.Enable then
		AutoEMob()
	end
	if Param.Harass.E and Param.Harass.E.Auto then
		EHarass()
	end
	ItemCheck()
	RunnanHurricaneCheck()
	if Param.Humanizer then
		Humanizing()
	end
end

function Combo()
	if Param.Combo.Q then
		LogicQ()
	end
	if Param.Combo.E then
		AutoEHero()
	end
	if Param.Misc.Items.Pot and Param.Misc.Items.PotCombo then
		AutoPotions()
	end
	if Param.Combo.Kite then
		-- OutOfAA()
	end
end

function OutOfAA()
	for _, unit in pairs(GetEnemyHeroes()) do
		if GetDistance(unit) < myHero.range+myHero.boundingRadius+50 and not unit.dead then
			if _G.AutoCarry and _G.AutoCarry.Keys and _G.Reborn_Loaded ~= nil then
				_G.AutoCarry.Keys.LaneClear = false
			elseif Param.orbwalker.n1 == 1 and _G.SxOrbMenu then
				_G.SxOrbMenu.LaneClear = false
			elseif Param.orbwalker.n1 == 2 and _G["BigFatOrb_Loaded"] == true then
				_G["BigFatOrb_Mode"] = 'Combo'
			elseif Param.orbwalker.n1 == 3 and _G.NebelwolfisOrbWalkerLoaded then
				_G.NebelwolfisOrbWalker.Config.k.LaneClear = false
			end
		elseif GetDistance(unit) > myHero.range+myHero.boundingRadius+50 and AAON == 0 or GetDistance(unit) < myHero.range+myHero.boundingRadius+50 and unit.dead then
			if _G.AutoCarry and _G.AutoCarry.Keys and _G.Reborn_Loaded ~= nil then
				_G.AutoCarry.Keys.LaneClear = true
			elseif Param.orbwalker.n1 == 1 and _G.SxOrbMenu then
				_G.SxOrbMenu.LaneClear = true
			elseif Param.orbwalker.n1 == 2 and _G["BigFatOrb_Loaded"] == true then
				_G["BigFatOrb_Mode"] = 'LaneClear'
			elseif Param.orbwalker.n1 == 3 and _G.NebelwolfisOrbWalkerLoaded then
				_G.NebelwolfisOrbWalker.Config.k.LaneClear = true
			end
			AAON = 1
		end
	end
end

function OnUnload()
	if VIP_USER then
		if Param.Draw.Skin.Enable then
			SetSkin(myHero, -1)
		end
	end
	if bind ~= 0 then
		if not FileExist(LIB_PATH .. "BaguetteKalista.key") then
			local file =  assert(io.open(LIB_PATH .. "BaguetteKalista.key", "w"))
			file:write(bind)
			file:close()
		else
			local file =  assert(io.open(LIB_PATH .. "BaguetteKalista.key", "w"))
			file:write(bind)
			file:close()
		end
	end
end

function LaneClear()
	LastHit_Gather()
	if Param.Jungle.Q then
		if not ManaQJungle() and myHero:CanUseSpell(_Q) == READY then
			jungleMinions:update()
			for i, jungleMinion in pairs(jungleMinions.objects) do
				if jungleMinion ~= nil and jungleMinion.type == "obj_AI_Minion" and GetDistance(jungleMinion) < 1150 and not jungleMinion.dead and not CPASBOJEU[jungleMinion.name] then
					CastPosition,  HitChance,  Position = VP:GetLineCastPosition(jungleMinion, SkillQ.delay, 70, 1150, SkillQ.speed, myHero, true)
					if HitChance >= 2 then
						CastSpell(_Q, CastPosition.x, CastPosition.z)
					end
				end
			end
		end
	end
	if Param.WaveClear.Q then
		if not ManaQWaveClear() then
			enemyMinions:update()
			for i, minion in pairs(enemyMinions.objects) do
				if minion ~= nil and not minion.dead and not CPASBOJEU[minion.name] then
					if GetDistance(minion) <= 1150 and myHero:CanUseSpell(_Q) == READY then
						if minion.health < dmgQ then
							CastPosition,  HitChance,  Position = VP:GetLineCastPosition(minion, SkillQ.delay, 70, 1150, SkillQ.speed, myHero, true)
							if HitChance >= 2 then
								CastSpell(_Q, CastPosition.x, CastPosition.z)
							end
						end
					end
				end
			end
		end
	end
end

function LastHit_Gather()
	enemyMinions:update()
	if not ManaELastHit() and Param.LastHit.E.Gather then
		for i, minion in pairs(enemyMinions.objects) do
			if ValidTarget(minion) and minion ~= nil and GetDistance(minion) < SkillE.range and not minion.dead then
				if GetStacks(minion) > 0 then
  					local health = minion.health
  					if Param.LastHit.E.Enable then

  						D1 = math.floor(myHero:CalcDamage(minion,dmgE))

						ELvl()

						D2 = math.floor(myHero:CalcDamage(minion,dmgEX))
						D3 = D1 + ((GetStacks(minion)-1) * D2)
						if D3 > minion.health-5 then
							if not CanAttack() then
								if OrbwalkManager_AA.LastTarget and minion.networkID ~= OrbwalkManager_AA.LastTarget.networkID and not IsAttacking() then
									CastSpell(_E)
						 		end
						 	end
						end
					end
				end
			end
		end
	end
end

function IsAutoAttack(name)

    return name and ((tostring(name):lower():find("attack")))
end

function OnProcessAttack(unit, spell)
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
		_G.NebelwolfisOrbWalker:TimeToMove()
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
		_G.NebelwolfisOrbWalker:TimeToAttack()
	end
end

function Harass()
	if Param.Harass.QE.Enable then
		QEHarass()
	end
	LastHit_Gather()
	if Param.Harass.Q then
		LogicQ()
	end
	if Param.Harass.E then
		EHarass()
	end
end

function EHarass()
	if not ManaEHarass() then
		if myHero:CanUseSpell(_E) == READY then
			enemyMinions:update()
			local ccount = 0
			for i, minion in pairs(enemyMinions.objects) do
				if ValidTarget(minion) and minion ~= nil and not minion.dead then
					if GetStacks(minion) > 0 and GetDistance(minion) < SkillE.range then
						D1 = math.floor(myHero:CalcDamage(minion,dmgE))

						ELvl()

						D2 = math.floor(myHero:CalcDamage(minion,dmgEX))
						D3 = D1 + ((GetStacks(minion)-1) * D2)

						if D3 > minion.health then
							ccount = ccount + 1
						end
					end
				end
			end
			local ccounthero = 0
			for _, unit in pairs(GetEnemyHeroes()) do
				if unit ~= nil and GetDistance(unit) < SkillE.range and not unit.dead then
					if GetStacks(unit) > 0 and not unit.dead then
						if GetStacks(unit) >= Param.Harass.E.AAHero and GetDistance(unit) < SkillE.range then
							ccounthero = ccounthero + GetStacks(unit)
						end
					end
				end
			end
			if ccounthero >= Param.Harass.E.AAHero and ccount >= Param.Harass.E.Minions then
				if not Param.Humanizer then 
					CastSpell(_E)
				else 
					DelayAction(function()
						CastSpell(_E)
					end, Human)
				end
			end
		end
	end
end

function ManaEHarass()
    if myHero.mana < (myHero.maxMana * ( Param.Harass.E.Mana / 100)) then
        return true
    else
        return false
    end
end

function ManaELastHit()
    if myHero.mana < (myHero.maxMana * ( Param.LastHit.E.Mana / 100)) then
        return true
    else
        return false
    end
end

function ManaQJungle()
    if myHero.mana < (myHero.maxMana * ( Param.Jungle.QMana / 100)) then
        return true
    else
        return false
    end
end

function ManaQWaveClear()
    if myHero.mana < (myHero.maxMana * ( Param.WaveClear.QMana / 100)) then
        return true
    else
        return false
    end
end

function LastHit()

	LastHit_Gather()
end

function LogicQ()
	if Target ~= nil and myHero:CanUseSpell(_Q) == READY and not Target.dead then
		local castPos, HitChance, pos = VP:GetLineCastPosition(Target, SkillQ.delay, SkillQ.width, SkillQ.range, SkillQ.speed, myHero, true)
		if HitChance >= 2 then
			CastSpell(_Q, castPos.x, castPos.z)
		end
	end
end

function AutoEMinion()
	if myHero:CanUseSpell(_E) == READY then
		enemyMinions:update()
		local ccount = 0
		for i, minion in pairs(enemyMinions.objects) do
			if ValidTarget(minion) and minion ~= nil and not minion.dead then
				if GetStacks(minion) > 0 then

					D1 = math.floor(myHero:CalcDamage(minion,dmgE))

					ELvl()

					D2 = math.floor(myHero:CalcDamage(minion,dmgEX))
					D3 = D1 + ((GetStacks(minion)-1) * D2)

					if D3 > minion.health then
						ccount = ccount + 1
					end
				end
			end
		end
		if ccount >= Param.LastHit.E.Count then
			if HurricanGet <= 0 then
				if not Param.Humanizer then 
					CastSpell(_E)
				else 
					DelayAction(function()
						CastSpell(_E)
					end, Human)
				end
			elseif HurricanGet >= 1 then
				if not Param.LastHit.E.HurricanGet then
					if not Param.Humanizer then 
						CastSpell(_E)
					else 
						DelayAction(function()
							CastSpell(_E)
						end, Human)
					end
				end
			end
		elseif ccount >= Param.LastHit.E.Count then
			if HurricanGet >= 1 then
				if Param.LastHit.E.CountHurrican then
					if Param.LastHit.E.HurricanGet then
						if not Param.Humanizer then 
							CastSpell(_E)
						else 
							DelayAction(function()
								CastSpell(_E)
							end, Human)
						end
					end
				end
			elseif HurricanGet <= 0 then
				if ccount >= Param.LastHit.E.Count then
					if not Param.Humanizer then 
						CastSpell(_E)
					else 
						DelayAction(function()
							CastSpell(_E)
						end, Human)
					end
				end
			end
		end
	end
end

function ELvl()
	if myHero:GetSpellData(_E).level == 1 then
		dmgEX = 10 + 0.2 * myHero.totalDamage
	elseif myHero:GetSpellData(_E).level == 2 then	
		dmgEX = 14 + 0.225 * myHero.totalDamage
	elseif myHero:GetSpellData(_E).level == 3 then
		dmgEX = 19 + 0.25 * myHero.totalDamage
	elseif myHero:GetSpellData(_E).level == 4 then
		dmgEX = 25 + 0.275 * myHero.totalDamage
	elseif myHero:GetSpellData(_E).level == 5 then
		dmgEX = 32 + 0.3 * myHero.totalDamage
	end
end

function AutoEMob()
	if Param.Jungle.E.Enable then
		if myHero:CanUseSpell(_E) == READY then
			jungleMinions:update()
			local ccount = 0
			for i, jungleMinion in pairs(jungleMinions.objects) do
				if jungleMinion ~= nil then
					if GetStacks(jungleMinion) > 0 and GetDistance(jungleMinion) < SkillE.range and not jungleMinion.dead then

						D1 = math.floor(myHero:CalcDamage(jungleMinion,dmgE))

						ELvl()

						D2 = math.floor(myHero:CalcDamage(jungleMinion,dmgEX))
						D3 = D1 + ((GetStacks(jungleMinion)-1) * D2)

						if Exhausted == 0 then
							D3E1 = D3
						elseif Exhausted == 1 then
							D3E1 = (D3 - ((D3 * 40)/100))
						end

						if (D3 > (jungleMinion.health)) and IsSpecialAMobToE[jungleMinion.name] and Param.Jungle.E.SpecialMob and jungleMinion.name == "SRU_Baron12.1.1" then
							if not TargetHaveBuff("barontarget", myHero) then
								CastSpell(_E)
							elseif TargetHaveBuff("barontarget", myHero) then
								if (D3/2) > jungleMinion.health then
									if not Param.Humanizer then 
										CastSpell(_E)
									else 
										DelayAction(function()
											CastSpell(_E)
										end, Human)
									end
								end
							end
						end

						if (D3 > (jungleMinion.health)) and Param.Jungle.E.SpecialMob and (IsSpecialAMobToE[jungleMinion.name] or jungleMinion.charName:lower():find("dragon")) then
							if Dragons ~= 0 then
								if (D3-(((D3*7)/100)*Dragons)) > jungleMinion.health then
									if not Param.Humanizer then 
										CastSpell(_E)
									else 
										DelayAction(function()
											CastSpell(_E)
										end, Human)
									end
								end
							elseif Dragons == 0 then
								if not Param.Humanizer then 
									CastSpell(_E)
								else 
									DelayAction(function()
										CastSpell(_E)
									end, Human)
								end
							end
						end

						if (D3 > (jungleMinion.health)) and IsSpecialAMobToE[jungleMinion.name] and Param.Jungle.E.SpecialMob and jungleMinion.name == "SRU_RiftHerald17.1.1" then
							if not Param.Humanizer then 
								CastSpell(_E)
							else 
								DelayAction(function()
									CastSpell(_E)
								end, Human)
							end
						end

						if D3 > jungleMinion.health and IsABuffMobToE[jungleMinion.name] and Param.Jungle.E.BuffMob then
							if not Param.Humanizer then 
								CastSpell(_E)
							else 
								DelayAction(function()
									CastSpell(_E)
								end, Human)
							end
						end

						if D3 > jungleMinion.health and IsANormalMobToE[jungleMinion.name] and Param.Jungle.E.NormalMob then
							if Param.Jungle.E.early and GetGameTimer() > 200 then
								if not Param.Humanizer then 
									CastSpell(_E)
								else 
									DelayAction(function()
										CastSpell(_E)
									end, Human)
								end
							elseif not Param.Jungle.E.early then
								if not Param.Humanizer then 
									CastSpell(_E)
								else 
									DelayAction(function()
										CastSpell(_E)
									end, Human)
								end
							elseif Param.Jungle.E.early and GetGameTimer() < 200 then
								if os.clock() - LastMSG > 1 then
									LastMSG = os.clock()
									EnvoiMessage("Cannont Steal, Menu > Jungle > (E) > Security")
								end
							end
						end

						if D3 > jungleMinion.health and Param.Jungle.E.All then
							ccount = ccount + 1
						end
					end 
				end
			end
			if ccount > 1 then
				if not Param.Humanizer then 
					CastSpell(_E)
				else 
					DelayAction(function()
						CastSpell(_E)
					end, Human)
				end
			end
		end
	end
end

CPASBOJEU = {
	["YellowTrinket"] = true,
	["BlueTrinket"] = true,
	["SightWard"] = true,
	["VisionWard"] = true
}

IsSpecialAMobToE = {
	['SRU_RiftHerald17.1.1'] = {true}, -- Blue | Haut
	['SRU_Baron12.1.1'] = {true}, -- Blue | Haut
	['SRU_Dragon_Water'] = {true}, -- Blue | Bas
	['SRU_Dragon_Fire'] = {true}, -- Blue | Bas
	['SRU_Dragon_Earth'] = {true}, -- Blue | Bas
	['SRU_Dragon_Air'] = {true}, -- Blue | Bas
	['SRU_Dragon_Elder'] = {true} -- Blue | Bas
}

IsABuffMobToE = {
	['SRU_Red4.1.1'] = {true}, -- Blue | Bas
	['SRU_Blue1.1.1'] = {true}, -- Blue | Haut
	['SRU_Blue7.1.1'] = {true}, -- Red | Bas
	['SRU_Red10.1.1'] = {true} -- Red | Haut
}

IsANormalMobToE = {
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

function AutoEHero()
	if myHero:CanUseSpell(_E) == READY then
		for _, unit in pairs(GetEnemyHeroes()) do
			if unit ~= nil and GetDistance(unit) < SkillE.range and not unit.dead then
				if GetStacks(unit) > 0 then

					D1 = math.floor(myHero:CalcDamage(unit,dmgE))

					ELvl()

					D2 = math.floor(myHero:CalcDamage(unit,dmgEX))
					D3 = D1 + ((GetStacks(unit)-1) * D2)

					if Exhausted == 0 and not TargetHaveBuff("meditate", unit) then
						D3E1 = D3
					elseif Exhausted == 1 and not TargetHaveBuff("meditate", unit) then
						D3E1 = (D3 - ((D3 * 40)/100))
					elseif TargetHaveBuff("meditate", unit) then
						dmgmajoration = (UnitHaveBuff(unit, "meditate") and 1-(unit:GetSpellData(_W).level * 0.05 + 0.5) or 1)
						if Exhausted == 0 then
							D3E1 = D3*dmgmajoration
						elseif Exhausted == 1 then
							D3E1 = (D3 - ((D3 * 40)/100))*dmgmajoration
						end
					end

					if unit.charName == "Blitzcrank" then
						if TargetHaveBuff("manabarrier", myHero) then
							if (D3E1 > (unit.health+((unit.mana*50)/100))) and not Immune(unit) and unit.shield < 1 then
								if not Param.Humanizer then 
									CastSpell(_E)
								else 
									DelayAction(function()
										CastSpell(_E)
									end, Human)
								end
							elseif (D3E1 > (unit.health+unit.shield+((unit.mana*50)/100))) and not Immune(unit) and unit.shield > 1 then
								if not Param.Humanizer then 
									CastSpell(_E)
								else 
									DelayAction(function()
										CastSpell(_E)
									end, Human)
								end
							end
						elseif not TargetHaveBuff("manabarrier", myHero) then
							if D3E1 > unit.health and not Immune(unit) and unit.shield < 1 then
								if not Param.Humanizer then 
									CastSpell(_E)
								else 
									DelayAction(function()
										CastSpell(_E)
									end, Human)
								end
							elseif (D3E1 > (unit.health+unit.shield)) and not Immune(unit) and unit.shield > 1 then
								if not Param.Humanizer then 
									CastSpell(_E)
								else 
									DelayAction(function()
										CastSpell(_E)
									end, Human)
								end
							end
						end
					end
					if D3E1 > unit.health and not Immune(unit) and unit.shield < 1 and unit.charName ~= "Blitzcrank" then
						if not Param.Humanizer then 
							CastSpell(_E)
						else 
							DelayAction(function()
								CastSpell(_E)
							end, Human)
						end
					elseif (D3E1 > (unit.health+unit.shield)) and not Immune(unit) and unit.shield > 1 and unit.charName ~= "Blitzcrank"  then
						if not Param.Humanizer then 
							CastSpell(_E)
						else 
							DelayAction(function()
								CastSpell(_E)
							end, Human)
						end
					end
				end
			end
		end
	end
end

function OnUpdateBuff(unit, buff, Stacks)
	if buff.name == "kalistaexpungemarker" then
		unitStacks[unit.networkID] = Stacks
	end
	if buff.name == "SummonerExhaust" and unit.isMe then
		Exhausted = 1
	end
end
 
function OnRemoveBuff(unit, buff)
	if VIP_USER then
		if buff.name == "recall" and unit.isMe then
			if myHero.level >= 9 then
				if Param.Misc.Starter.TrinketBleu then
					BuyItem(3363)
				end
			end
		end
	end
    if buff.name == "kalistaexpungemarker" then
      unitStacks[unit.networkID] = nil
    end
    if buff.name == "SummonerExhaust" and unit.isMe then
    	Exhausted = 0
    end
end

function OnApplyBuff(source, unit, buff)
	
	if buff.name == "kalistavobindally" and unit.team == myHero.team and unit.name ~= "Disabled member" then
		EnvoiMessage("Succesfully binded with : "..unit.name.." - "..unit.charName)
		bind = unit.name
	end

	if buff.name == "s5tooltip_dragonslayerbuffv1" and unit.isMe then
		Dragons = 1
	elseif buff.name == "s5tooltip_dragonslayerbuffv2" and unit.isMe then
		Dragons = 2
	elseif buff.name == "s5tooltip_dragonslayerbuffv3" and unit.isMe then
		Dragons = 3
	elseif buff.name == "s5tooltip_dragonslayerbuffv4" and unit.isMe then
		Dragons = 4
	elseif buff.name == "s5tooltip_dragonslayerbuffv5" and unit.isMe then
		Dragons = 5
	end

	if unit ~= nil and unit.isMe and Param.Misc.QSS.Enable and not source.charName:lower():find("baron") and not source.charName:lower():find("spiderboss") then
		if buff.name == "SummonerExhaust" and Param.Misc.QSS.Exhaust then
			QSS()
		end
		if buff.name == "rocketgrab2" and Param.Misc.QSS.BlitzQ then
			QSS()
		end
		if buff.type == 6 and Param.Misc.QSS.Stun then
			QSS()
		end
		if buff.type == 8 and Param.Misc.QSS.Taunt then
			QSS()
		end
		if buff.type == 10 and Param.Misc.QSS.Slow then
			QSS()
		end
		if buff.type == 11 and Param.Misc.QSS.Trap then
			QSS()
		end
		if buff.type == 20 and Param.Misc.QSS.Fear then
			QSS()
		end
		if buff.type == 21 and Param.Misc.QSS.Charm then
			QSS()
		end
		if buff.type == 24 and Param.Misc.QSS.Blind then
			QSS()
		end
	end

	if TargetHaveBuff("rocketgrab2", unit) and Param.Misc.Blitz.Blitz then
		if unit.team ~= myHero.team and unit.type == myHero.type then
			if GetDistance(unit) > Param.Misc.Blitz.BlitzRangeMin and GetDistance(unit) < Param.Misc.Blitz.BlitzRangeMax then
				CastSpell(_R)
			end
		end
	end

	if TargetHaveBuff("tamhkenchdevoured", unit) and Param.Misc.Blitz.Tahm then
		if unit.team ~= myHero.team and unit.type == myHero.type then
			if GetDistance(unit) > Param.Misc.Blitz.TahmRangeMin and GetDistance(unit) < Param.Misc.Blitz.TahmRangeMax then
				CastSpell(_R)
			end
		end
	end
end

function OnProcessSpell(unit, spell)
	if spell.target then 
		if spell.target.name ~= nil and spell.target.name == bind then
			if spell.target.health < ((spell.target.maxHealth * Param.Misc.R.Life) / 100 ) then
				CastSpell(_R)
			end
		end
    end
end

function GetStacks(unit)

	return unitStacks[unit.networkID] or 0
end

SkillQ = { name = "Pierce", range = 1150, delay = 0.25, speed = 1750, width = 70, ready = false}
SkillW = { name = "Sentinel", range = 5000, delay = 0.25, speed = math.huge, width = 250, ready = false }
SkillE = { name = "Rend", range = 1000, delay = 0.50, speed = nil, width = nil, ready = false }
SkillR = { name = "Fate's Call", range = 1100, delay = nil, speed = nil, width = nil, ready = false }

function OnDraw()
	if not myHero.dead and not Param.Draw.Disable then

		-- SPELL DRAW

		if myHero:CanUseSpell(_W) == READY and Param.Draw.W then 
			DrawCircleMinimap(myHero.x, myHero.y, myHero.z, SkillW.range)
		end

		if Param.Draw.LagFree then
			if myHero:CanUseSpell(_Q) == READY and Param.Draw.Q then 
				DrawCircle3D(myHero.x, myHero.y, myHero.z, SkillQ.range, 1, 0xFFFFFFFF)
			end
			if myHero:CanUseSpell(_E) == READY and Param.Draw.E then 
				DrawCircle3D(myHero.x, myHero.y, myHero.z, SkillE.range, 1, 0xFFFFFFFF)
			end
			if myHero:CanUseSpell(_R) == READY and Param.Draw.R then
				DrawCircle3D(myHero.x, myHero.y, myHero.z, SkillR.range, 1, 0xFFFFFFFF)
			end
			if Param.Draw.AA then
				DrawCircle3D(myHero.x, myHero.y, myHero.z, myHero.range+myHero.boundingRadius, 1, 0xFFFFFFFF)
			end
			if Param.Draw.HitBox then
				DrawCircle3D(myHero.x, myHero.y, myHero.z, myHero.boundingRadius, 1, 0xFFFFFFFF)
			end
		end

		-- TARGET DRAW
		if Target ~= nil and ValidTarget(Target) then
			if Param.Draw.Target then
				DrawText(""..Target.charName.."", 50, 50, 200, 0xFFFFFFFF)
				DrawText3D(">> Current |Target <<",Target.x-100, Target.y-50, Target.z, 20, 0xFFFFFFFF)
			end
		end

		-- Percent E draw

		-- Heroes
		if Param.Draw.EDraw.Hero then
			if myHero:CanUseSpell(_E) == READY then

				for _, unit in pairs(GetEnemyHeroes()) do

					if unit ~= nil and GetDistance(unit) < 3000 and unit.visible and not unit.dead then

						if GetStacks(unit) > 0 then

							D1 = math.floor(myHero:CalcDamage(unit,dmgE))

							ELvl()

							D2 = math.floor(myHero:CalcDamage(unit,dmgEX))
							D3E = D1 + ((GetStacks(unit)-1) * D2)

							DAA1 = math.round(myHero:CalcDamage(unit,myHero.totalDamage*90/100))

							if Exhausted == 0 then
								D3E1 = math.floor(D3E/unit.health*100)
								DAA = math.floor(unit.health/(D3E+DAA1))
							elseif Exhausted == 1 then
								D3E1 = math.floor(D3E/unit.health*100)-((math.floor(D3E/unit.health*100)*40)/100)
								DAA = math.floor(unit.health/(D3E+DAA1))-((math.floor(unit.health/(D3E+DAA1))*40)/100)
							end

							if not Param.Draw.EDraw.Hero2 then
								if D3E1 < 80 then
									DrawText3D(D3E1.."%", unit.x+125, unit.y+85, unit.z+155, 30, ARGB(255,250,250,250), 0)
								elseif D3E1 >= 80 and D3E1 < 100 then
									DrawText3D(D3E1.."%", unit.x+125, unit.y+85, unit.z+155, 30, ARGB(255,205,51,51), 0)
								elseif D3E1 >= 100 then
									DrawText3D("100% !", unit.x+125, unit.y+85, unit.z+155, 30, ARGB(255,205,51,51), 0)
								end
							end

							-- AA remaining & %

							if Param.Draw.EDraw.Hero2 then

								if D3E1 < 80 then
									DrawText3D(D3E1.."%".." | "..DAA, unit.x+125, unit.y+85, unit.z+155, 30, ARGB(255,250,250,250), 0)
								elseif D3E1 >= 80 and D3E1 < 100 then
									DrawText3D(D3E1.."%".." | "..DAA, unit.x+125, unit.y+85, unit.z+155, 30, ARGB(255,205,51,51), 0)
								elseif D3E1 >= 100 then
									DrawText3D("100% ! | 0 !", unit.x+125, unit.y+85, unit.z+155, 30, ARGB(255,205,51,51), 0)
								end
							end

							-- COLOR BLOCK
							if Param.Draw.EDraw.HeroBlock then
								local Center = GetUnitHPBarPos(unit)
								if Center.x > -100 and Center.x < WINDOW_W+100 and Center.y > -100 and Center.y < WINDOW_H+100 then
									local off = GetUnitHPBarOffset(unit)
									local y=Center.y + (off.y * 53) + 2
									local xOff = ({['AniviaEgg'] = -0.1,['Darius'] = -0.05,['Renekton'] = -0.05,['Sion'] = -0.05,['Thresh'] = -0.03,})[unit.charName]
									local x = Center.x + ((xOff or 0) * 140) - 66
									if not TargetHaveBuff("SummonerExhaust", myHero) then
										dmg = unit.health - D3E
									elseif TargetHaveBuff("SummonerExhaust", myHero) then
										dmg = unit.health - (D3E-((D3E*40)/100))
									end
									DrawLine(x + ((unit.health /unit.maxHealth) * 104),y, x+(((dmg > 0 and dmg or 0) / unit.maxHealth) * 104),y,9, GetDistance(unit) < 3000 and 0x6699FFFF)
								end
							end

							-- DMG DRAW SIMPLE

							if Param.Draw.EDraw.Hero3 then
								if not TargetHaveBuff("SummonerExhaust", myHero) then
									DrawText3D(""..D3E.."", unit.x+125, unit.y+175, unit.z+155, 30, ARGB(255,250,250,250), 0)
								elseif TargetHaveBuff("SummonerExhaust", myHero) then
									DrawText3D(""..(D3E-((D3E*40)/100)).."", unit.x+125, unit.y+175, unit.z+155, 30, ARGB(255,250,250,250), 0)
								end
							end
						end
					end
				end
			end
		end

		-- Mobs

		if Param.Draw.EDraw.Mob then
			if myHero:CanUseSpell(_E) == READY then

				jungleMinions:update()

				for i, jungleMinion in pairs(jungleMinions.objects) do

					if jungleMinion ~= nil and GetDistance(jungleMinion) < 3000 then

						if IsANormalMobToE[jungleMinion.name] or IsABuffMobToE[jungleMinion.name] or IsSpecialAMobToE[jungleMinion.name] or jungleMinion.charName:lower():find("dragon") then

							if GetStacks(jungleMinion) > 0 then

								D1 = math.floor(myHero:CalcDamage(jungleMinion,dmgE))

								ELvl()

								D2 = math.floor(myHero:CalcDamage(jungleMinion,dmgEX))
								D3E = D1 + ((GetStacks(jungleMinion)-1) * D2)

								DAA1 = math.round(myHero:CalcDamage(jungleMinion,myHero.totalDamage*90/100))

								if Exhausted == 0 then
									D3E1 = math.floor(D3E/jungleMinion.health*100)
									DAA = math.round(jungleMinion.health/(D3E+DAA1))
								elseif Exhausted == 1 then
									D3E1 = math.floor(D3E/jungleMinion.health*100)-((math.floor(D3E/jungleMinion.health*100)*40)/100)
									DAA = math.floor(jungleMinion.health/(D3E+DAA1))-((math.floor(jungleMinion.health/(D3E+DAA1))*40)/100)
								end

								if not Param.Draw.EDraw.Mob2 then
										if D3E1 < 80 then
											DrawText3D(D3E1.."%", jungleMinion.x+125, jungleMinion.y+85, jungleMinion.z+155, 30, ARGB(255,250,250,250), 0)
										elseif D3E1 >= 80 and D3E1 < 100 then
											DrawText3D(D3E1.."%", jungleMinion.x+125, jungleMinion.y+85, jungleMinion.z+155, 30, ARGB(255,205,51,51), 0)
										elseif D3E1 >= 100 then
											DrawText3D("100% !", jungleMinion.x+125, jungleMinion.y+85, jungleMinion.z+155, 30, ARGB(255,205,51,51), 0)
										end

								-- AA remaining & %

								elseif Param.Draw.EDraw.Mob2 then

									if D3E1 < 80 then
										DrawText3D(D3E1.."%".." | "..DAA, jungleMinion.x+125, jungleMinion.y+85, jungleMinion.z+155, 30, ARGB(255,250,250,250), 0)
									elseif D3E1 >= 80 and D3E1 < 100 then
										DrawText3D(D3E1.."%".." | "..DAA, jungleMinion.x+125, jungleMinion.y+85, jungleMinion.z+155, 30, ARGB(255,205,51,51), 0)
									elseif D3E1 >= 100 then
										DrawText3D("100% ! | 0 !", jungleMinion.x+125, jungleMinion.y+85, jungleMinion.z+155, 30, ARGB(255,205,51,51), 0)
									end
								end

								-- DMG DRAW SIMPLE

								if Param.Draw.EDraw.Mob3 then
									if Exhausted == 0 then
										DrawText3D(""..D3E.."", jungleMinion.x+125, jungleMinion.y+175, jungleMinion.z+155, 30, ARGB(255,250,250,250), 0)
									elseif Exhausted == 1 then
										DrawText3D(""..(D3E-((D3E*40)/100)).."", jungleMinion.x+125, jungleMinion.y+175, jungleMinion.z+155, 30, ARGB(255,250,250,250), 0)
									end
								end
							end
						end
					end
				end
			end
		end

		-- WallJump

		if GetGame().map.shortName == "summonerRift" then
			if Param.Draw.WallJump.Enable then
				for i,group in pairs(wallSpots) do
					for x, wallSpot in pairs(group.Locations) do
						if GetDistance(wallSpot) < 1000 then
							DrawCircle3D(wallSpot.x, wallSpot.y, wallSpot.z, 50, 1, 0xFFFFFFFF)
						end
					end
				end
			end
		end

	end
end

function QEHarass()
	if Target ~= nil and not Target.dead then
		if GetDistance(Target) < SkillQ.range and Param.Harass.QE.Enable then
			enemyMinions:update()
			local minion_on_vector = 0
			local minion_killable = 0
			local minion_stack = 0
			for i, minion in pairs(enemyMinions.objects) do
				if ValidTarget(minion) and minion ~= nil then
					AB = math.sqrt((Target.x-myHero.x)*(Target.x-myHero.x)+(Target.y-myHero.y)*(Target.y-myHero.y)+(Target.z-myHero.z)*(Target.z-myHero.z))
					AP = math.sqrt((minion.x-myHero.x)*(minion.x-myHero.x)+(minion.y-myHero.y)*(minion.y-myHero.y)+(minion.z-myHero.z)*(minion.z-myHero.z))
					PB = math.sqrt((Target.x-minion.x)*(Target.x-minion.x)+(Target.y-minion.y)*(Target.y-minion.y)+(Target.z-minion.z)*(Target.z-minion.z))
					if AB > AP+PB-5 or AB > AP+PB+5 then
						minion_on_vector = minion_on_vector + 1
						if GetStacks(minion) > -1 then
							D_Q = ((myHero:CanUseSpell(_Q) == READY and myHero:CalcDamage(minion,dmgQ)) or 0)
							if D_Q > minion.health then
								minion_killable = minion_killable + 1
								minion_stack = minion_stack + GetStacks(minion)
							end
							if minion_killable == minion_on_vector and minion_stack > Param.Harass.QE.Stacks then
								CastSpell(_Q, Target.x, Target.z)
							end
						end
					end
				end
			end
		end
	end
end

function Consommables()
	if VIP_USER then
		if Param.Misc.LVL.Enable then
	 		AutoLvlSpell()
		end
	end
	if Param.Misc.Items.Pot and not Param.Misc.Items.PotCombo then
		AutoPotions()
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
		if Param.Misc.LVL.Enable then
			if Param.Misc.LVL.Combo == 1 then
				levelSequence =  {3,2,1,3,3,4,3,1,3,1,4,1,1,2,2,4,2,2} -- Max E | E > W > Q
			elseif Param.Misc.LVL.Combo == 2 then
				levelSequence =  {2,3,1,3,3,4,3,1,3,1,4,1,1,2,2,4,2,2} -- Max E | W > E > Q
			elseif Param.Misc.LVL.Combo == 3 then
				levelSequence =  {1,3,2,3,3,4,3,1,3,1,4,1,1,2,2,4,2,2} -- Max E | Q > E > W
			elseif Param.Misc.LVL.Combo == 4 then
				levelSequence =  {3,1,2,3,3,4,3,1,3,1,4,1,1,2,2,4,2,2} -- Max E | E > Q > W
			end
		end
	end
end

function AutoBuy()
	if VIP_USER and GetGameTimer() < 60 then
		if Param.Misc.Starter.Doran then
			BuyItem(1055)
		end
		if Param.Misc.Starter.Pots then
			BuyItem(2003)
		end
		if Param.Misc.Starter.Trinket then
			BuyItem(3340)
		end
	end
end

function AutoPotions()
	if not Param.Misc.Items.Pot then return end
		if os.clock() - lastPotion < ActualPotTime then return end
			for SLOT = ITEM_1, ITEM_6 do
				if myHero:GetSpellData(SLOT).name == "RegenerationPotion" then 
					ActualPotName = "Health Potion"
					ActualPotTime = 15
					ActualPotData = "RegenerationPotion"
					Usepot()
				elseif myHero:GetSpellData(SLOT).name == "ItemMiniRegenPotion" then
					ActualPotName = "Cookie"
					ActualPotTime = 15
					ActualPotData = "ItemMiniRegenPotion"
					Usepot()
				elseif myHero:GetSpellData(SLOT).name == "ItemCrystalFlaskJungle" then
					ActualPotName = "Hunter's Potion"
					ActualPotTime = 8
					ActualPotData = "ItemCrystalFlaskJungle"
					Usepot()
				elseif myHero:GetSpellData(SLOT).name == "ItemCrystalFlask" then
					ActualPotName = "Refillable Potion"
					ActualPotTime = 12
					ActualPotData = "ItemCrystalFlask"
					Usepot()
				elseif myHero:GetSpellData(SLOT).name == "ItemDarkCrystalFlask" then
					ActualPotName = "Corrupting Potion"
					ActualPotTime = 12
					ActualPotData = "ItemDarkCrystalFlask" 
					Usepot()
				else end
			end
		--
	--
end

function Usepot()
	for SLOT = ITEM_1, ITEM_6 do
		if myHero:GetSpellData(SLOT).name == ActualPotData then
			if myHero:CanUseSpell(SLOT) == READY and (myHero.health*100)/myHero.maxHealth < Param.Misc.Items.PotXHP then
				CastSpell(SLOT)
				lastPotion = os.clock()
				EnvoiMessage("1x "..ActualPotName.." => Used.")
			end
		end
	end
end

Items = {
		["QSS"]	        = { id = 3140, range = 2500, target = false},
		["MercScim"]	= { id = 3139, range = 2500, target = false},
}

function QSS()
	if lastRemove > os.clock() then return end
		for SLOT = ITEM_1, ITEM_6 do
			if QSSGet == 1 or MercurialGet == 1 and not myHero.dead then
				if myHero:GetSpellData(SLOT).name == "QuicksilverSash" or myHero:GetSpellData(SLOT).name == "ItemMercurial" then
					lastRemove = os.clock()+90
					if QSSGet == 1 then
						CastItem(3140)
						EnvoiMessage("Casted : Quicksilver Sash")
					elseif MercurialGet == 1 then
						CastItem(3139)
						EnvoiMessage("Casted : Mercurial Scimitar")
					end
				end
			end
		end
	--
end

function Immune(unit)
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

function OnWndMsg(msg, key)
	if key == 1 then
		if Param.Misc.WallJump.Enable and GetGame().map.shortName == "summonerRift" then
			if Param.Draw.WallJump.Enable then
				for i,group in pairs(wallSpots) do
 					for x, wallSpot in pairs(group.Locations) do
 						if GetDistance(wallSpot,myHero) <= 50 then
 							if x == 1 then
 								CastSpell(_Q, 3058, 6942)
 								player:MoveTo(3058, 6942)
 							elseif x == 2 then
 								CastSpell(_Q, 2809, 6936)
 								player:MoveTo(2809, 6936)
 							elseif x == 3 then
 								CastSpell(_Q, 3072, 6607)
 								player:MoveTo(3072,6607)
 							elseif x == 4 then
 								CastSpell(_Q, 2755, 6523)
 								player:MoveTo(2755,6523)
 							elseif x == 5 then
 								CastSpell(_Q, 3195,6307 )
 								player:MoveTo(3195,6307)
 							elseif x == 6 then
 								CastSpell(_Q, 3022,6111 )
 								player:MoveTo(3022,6111)
 							elseif x == 7 then
 								CastSpell(_Q, 11513,8762 )
 								player:MoveTo(11513,8762)
 							elseif x == 8 then
 								CastSpell(_Q, 11817,8903 )
 								player:MoveTo(11817,8903)
 							elseif x == 9 then
 								CastSpell(_Q, 12095,8281 )
 								player:MoveTo(12095,8281)
 							elseif x == 10 then
 								CastSpell(_Q, 11755,8206 )
 								player:MoveTo(11755,8206)
 							elseif x == 11 then
 								CastSpell(_Q, 12110,7980 )
 								player:MoveTo(12110,7980)
 							elseif x == 12 then
 								CastSpell(_Q, 11767,7900 )
 								player:MoveTo(11767,7900)
 							elseif x == 13 then
 								CastSpell(_Q, 11647,5452 )
 								player:MoveTo(11647,5452)
 							elseif x == 14 then
 								CastSpell(_Q, 11354,5511 )
 								player:MoveTo(11354,5511)
 							elseif x == 15 then
 								CastSpell(_Q, 11345,4813 )
 								player:MoveTo(11345,4813)
 							elseif x == 16 then
 								CastSpell(_Q, 11725,5120 )
 								player:MoveTo(11725,5120)
 							elseif x == 17 then
 								CastSpell(_Q, 11960,4802 )
 								player:MoveTo(11960,4802)
 							elseif x == 18 then
 								CastSpell(_Q, 11697,4614 )
 								player:MoveTo(11697,4614)
 							elseif x == 19 then
 								CastSpell(_Q, 3437,10186 )
 								player:MoveTo(3437,10186)
 							elseif x == 20 then
 								CastSpell(_Q, 2964,10012 )
 								player:MoveTo(2964,10012)
 							elseif x == 21 then
 								CastSpell(_Q, 3104,9701 )
 								player:MoveTo(3104,9701)
 							elseif x == 22 then
 								CastSpell(_Q, 3519,9833 )
 								player:MoveTo(3519,9833)
 							elseif x == 23 then
 								CastSpell(_Q, 3224,9440 )
 								player:MoveTo(3224,9440)
 							elseif x == 24 then
 								CastSpell(_Q, 3478,9422 )
 								player:MoveTo(3478,9422)
 							elseif x == 25 then
 								CastSpell(_Q, 6685,9116 )
 								player:MoveTo(6685,9116)
 							elseif x == 26 then
 								CastSpell(_Q, 6484,8804 )
 								player:MoveTo(6484,8804)
 							elseif x == 27 then
 								CastSpell(_Q, 6685,9116 )
 								player:MoveTo(6685,9116)
 							elseif x == 28 then
 								CastSpell(_Q, 6848,8804 )
 								player:MoveTo(6848,8804)
 							elseif x == 29 then
 								CastSpell(_Q, 7095,8727 )
 								player:MoveTo(7095,8727)
 							elseif x == 30 then
 								CastSpell(_Q, 6857,8517 )
 								player:MoveTo(6857,8517)
 							elseif x == 31 then
 								CastSpell(_Q, 7456,8539 )
 								player:MoveTo(7456,8539)
 							elseif x == 32 then
 								CastSpell(_Q, 7100,8159 )
 								player:MoveTo(7100,8159)
 							elseif x == 33 then
 								CastSpell(_Q, 7378,6298 )
 								player:MoveTo(7378,6298)
 							elseif x == 34 then
 								CastSpell(_Q, 7714,6544 )
 								player:MoveTo(7714,6544)
 							elseif x == 35 then
 								CastSpell(_Q, 7813,5938 )
 								player:MoveTo(7813,5938)
 							elseif x == 36 then
 								CastSpell(_Q, 8139,6210 )
 								player:MoveTo(8139,6210)
 							elseif x == 37 then
 								CastSpell(_Q, 8412,6081 )
 								player:MoveTo(8412,6081)
 							elseif x == 38 then
 								CastSpell(_Q, 8194,5742 )
 								player:MoveTo(8194,5742)
 							elseif x == 39 then
 								CastSpell(_Q, 5355,10832 )
 								player:MoveTo(5355,10832)
 							elseif x == 40 then
 								CastSpell(_Q, 5812,10832 )
 								player:MoveTo(5812,10832)
 							elseif x == 41 then
 								CastSpell(_Q, 4292,10199 )
 								player:MoveTo(4292,10199)
 							elseif x == 42 then
 								CastSpell(_Q, 4480,10437 )
 								player:MoveTo(4480,10437)
 							elseif x == 43 then
 								CastSpell(_Q, 4993,9706 )
 								player:MoveTo(4993,9706)
 							elseif x == 44 then
 								CastSpell(_Q, 5083,9998 )
 								player:MoveTo(5083,9998)
 							elseif x == 45 then
 								CastSpell(_Q, 8971,4284 )
 								player:MoveTo(8971,4284)
 							elseif x == 46 then
 								CastSpell(_Q, 9378,4431 )
 								player:MoveTo(9378,4431)
 							elseif x == 47 then
 								CastSpell(_Q, 9803,5249 )
 								player:MoveTo(9803,5249)
 							elseif x == 48 then
 								CastSpell(_Q, 9751,4884 )
 								player:MoveTo(9751,4884)
 							elseif x == 49 then
 								CastSpell(_Q, 10643,4641 )
 								player:MoveTo(10643,4641)
 							elseif x == 50 then
 								CastSpell(_Q, 10375,4441 )
 								player:MoveTo(10375,4441)
 							elseif x == 51 then
 								CastSpell(_Q, 6553,11666 )
 								player:MoveTo(6553,11666)
 							elseif x == 52 then
 								CastSpell(_Q, 6543,12054 )
 								player:MoveTo(6543,12054)
 							elseif x == 53 then
 								CastSpell(_Q, 8213,3326 )
 								player:MoveTo(8213,3326)
 							elseif x == 54 then
 								CastSpell(_Q, 8282,2741 )
 								player:MoveTo(8282,2741)
 							elseif x == 55 then
 								CastSpell(_Q, 9535,3203 )
 								player:MoveTo(9535,3203)
 							elseif x == 56 then
 								CastSpell(_Q, 9505,2756 )
 								player:MoveTo(9505,2756)
 							elseif x == 57 then
 								CastSpell(_Q, 9862,3111 )
 								player:MoveTo(9862,3111)
 							elseif x == 58 then
 								CastSpell(_Q, 9815,2673 )
 								player:MoveTo(9815,2673)
 							elseif x == 59 then
 								CastSpell(_Q, 10046,2675 )
 								player:MoveTo(10046,2675)
 							elseif x == 60 then
 								CastSpell(_Q, 10259,2925 )
 								player:MoveTo(10259,2925)
 							elseif x == 61 then
 								CastSpell(_Q, 5363,12158 )
 								player:MoveTo(5363,12158)
 							elseif x == 62 then
 								CastSpell(_Q, 5269,11725 )
 								player:MoveTo(5269,11725)
 							elseif x == 63 then
 								CastSpell(_Q, 5110,12210 )
 								player:MoveTo(5110,12210)
 							elseif x == 64 then
 								CastSpell(_Q, 4993,11836 )
 								player:MoveTo(4993,11836)
 							elseif x == 65 then
 								CastSpell(_Q, 4825,12307 )
 								player:MoveTo(4825,12307)
 							elseif x == 66 then
 								CastSpell(_Q, 4605,11970 )
 								player:MoveTo(4605,11970)
 							elseif x == 67 then
 								CastSpell(_Q, 7115,5524 )
 								player:MoveTo(7115,5524)
 							elseif x == 68 then
 								CastSpell(_Q, 7424,5905 )
 								player:MoveTo(7424,5905)
 							elseif x == 69 then
 								CastSpell(_Q, 3856,7412 )
 								player:MoveTo(3856,7412)
 							elseif x == 70 then
 								CastSpell(_Q, 3802,7743 )
 								player:MoveTo(3802,7743)
 							elseif x == 71 then
 								CastSpell(_Q, 3422,7759 )
 								player:MoveTo(3422,7759)
 							elseif x == 72 then
 								CastSpell(_Q, 3437,7398 )
 								player:MoveTo(3437,7398)
 							elseif x == 73 then
 								CastSpell(_Q, 4382,8149 )
 								player:MoveTo(4382,8149)
 							elseif x == 74 then
 								CastSpell(_Q, 4124,8022 )
 								player:MoveTo(4124,8022)
 							elseif x == 75 then
 								CastSpell(_Q, 4624,9010 )
 								player:MoveTo(4624,9010)
 							elseif x == 76 then
 								CastSpell(_Q, 4672,8519 )
 								player:MoveTo(4672,8519)
 							elseif x == 77 then
 								CastSpell(_Q, 4074,9322 )
 								player:MoveTo(4074,9322)
 							elseif x == 78 then
 								CastSpell(_Q, 3737,8233 )
 								player:MoveTo(3737,8233)
 							elseif x == 79 then
 								CastSpell(_Q, 10904,7512 )
 								player:MoveTo(10904,7512)
 							elseif x == 80 then
 								CastSpell(_Q, 11040,7179 )
 								player:MoveTo(11040,7179)
 							elseif x == 81 then
 								CastSpell(_Q, 11449,7514 )
 								player:MoveTo(11449,7514)
 							elseif x == 82 then
 								CastSpell(_Q, 11458,7155 )
 								player:MoveTo(11458,7155)
 							elseif x == 83 then
 								CastSpell(_Q, 10189,5922 )
 								player:MoveTo(10189,5922)
 							elseif x == 84 then
 								CastSpell(_Q, 10185,6286 )
 								player:MoveTo(10185,6286)
 							elseif x == 85 then
 								CastSpell(_Q, 11049,5660 )
 								player:MoveTo(11049,5660)
 							elseif x == 86 then
 								CastSpell(_Q, 10665,5662 )
 								player:MoveTo(10665,5662)
 							elseif x == 87 then
 								CastSpell(_Q, 2800,9596 )
 								player:MoveTo(2800,9596)
 							elseif x == 88 then
 								CastSpell(_Q, 2573,9674 )
 								player:MoveTo(2573,9674)
 							elseif x == 89 then
 								CastSpell(_Q, 2500,9262 )
 								player:MoveTo(2500,9262)
 							elseif x == 90 then
 								CastSpell(_Q, 2884,9291 )
 								player:MoveTo(2884,9291)
 							elseif x == 91 then
 								CastSpell(_Q, 4772,5636 )
 								player:MoveTo(4772,5636)
 							elseif x == 92 then
 								CastSpell(_Q, 4644,5876 )
 								player:MoveTo(4644,5876)
 							elseif x == 93 then
 								CastSpell(_Q, 4869,6452 )
 								player:MoveTo(4869,6452)
 							elseif x == 94 then
 								CastSpell(_Q, 4938,6062 )
 								player:MoveTo(4938,6062)
 							elseif x == 95 then
 								CastSpell(_Q, 5998,5536 )
 								player:MoveTo(5998,5536)
 							elseif x == 96 then
 								CastSpell(_Q, 6199,5286 )
 								player:MoveTo(6199,5286)
 							elseif x == 97 then
 								CastSpell(_Q, 12027,5265 )
 								player:MoveTo(12027,5265)
 							elseif x == 98 then
 								CastSpell(_Q, 12327,5243 )
 								player:MoveTo(12327,5243)
 							elseif x == 99 then
 								CastSpell(_Q, 12343,5498 )
 								player:MoveTo(12343,5498)
 							elseif x == 100 then
 								CastSpell(_Q, 11969,5480 )
 								player:MoveTo(11969,5480)
 							elseif x == 101 then
 								CastSpell(_Q, 8831,9384 )
 								player:MoveTo(8831,9384)
 							elseif x == 102 then
 								CastSpell(_Q, 8646,9635 )
 								player:MoveTo(8646,9635)
 							elseif x == 103 then
 								CastSpell(_Q, 10061,9282 )
 								player:MoveTo(10061,9282)
 							elseif x == 104 then
 								CastSpell(_Q, 10193,9052 )
 								player:MoveTo(10193,9052)
 							elseif x == 105 then
 								CastSpell(_Q, 9856,8831 )
 								player:MoveTo(9856,8831)
 							elseif x == 106 then
 								CastSpell(_Q, 9967,8429 )
 								player:MoveTo(9967,8429)
 							elseif x == 107 then
 								CastSpell(_Q, 8369,9807 )
 								player:MoveTo(8369,9807)
 							elseif x == 108 then
 								CastSpell(_Q, 8066,9796 )
 								player:MoveTo(8066,9796)
 							elseif x == 109 then
 								CastSpell(_Q, 4780,3460 )
 								player:MoveTo(4780,3460)
 							elseif x == 110 then
 								CastSpell(_Q, 4463,3260 )
 								player:MoveTo(4463,3260)
 							elseif x == 111 then
 								CastSpell(_Q, 3182,4917 )
 								player:MoveTo(3182,4917)
 							elseif x == 112 then
 								CastSpell(_Q, 3085,4539 )
 								player:MoveTo(3085,4539)
 							elseif x == 113 then
 								CastSpell(_Q, 11621,10092 )
 								player:MoveTo(11621,10092)
 							elseif x == 114 then
 								CastSpell(_Q, 11735,10430 )
 								player:MoveTo(11735,10430)
 							elseif x == 115 then
 								CastSpell(_Q, 9999,11554 )
 								player:MoveTo(9999,11554)
 							elseif x == 116 then
 								CastSpell(_Q, 10321,11664 )
 								player:MoveTo(10321,11664)
 							else
 								EnvoiMessage("WallJump ERROR | Report it on the forum thread please!")
 							end
 						end
 					end
 				end
	    	end
		end
	end
end

wallSpots = {
	worksWell = {
		Locations = {
		-- Walls Spots -- 
					{x= 2848, y= 53,z= 6942},
				--	{x= 3058, y= 52,z= 6960},
					
					{x= 3064, y= 52, z= 6962},
				--	{x= 2809, y= 53,z= 6936},
					
					-- 

					{x= 2774, y= 57 ,z= 6558},
				--	{x= 3072, y= 51, z= 6607},
					
					{x= 3074, y= 51, z= 6608},
				--	{x= 2755, y= 57, z= 6523},

					--

					{x= 3024, y= 57, z= 6108},
				--	{x= 3195, y= 52, z= 6307},
					
					{x= 3200, y= 52, z= 6243},
				--	{x= 3022, y= 57, z= 6111},

					--
					
					{x= 11772, y= 50, z= 8856},
				--	{x= 11513, y= 65, z= 8762},
					
					{x= 11572, y= 64, z= 8706},
				--	{x= 11817, y= 50, z= 8903},

					--
					
					{x= 11772, y= 55, z= 8206},
				--	{x= 12095, y= 52, z= 8281},
					
					{x= 12072, y= 52, z= 8256},
				--	{x= 11755, y= 55, z= 8206},

					--
					
					{x= 11772, y= 52, z= 7906},
				--	{x= 12110, y= 53, z= 7980},
					
					{x= 12072, y= 53, z= 7906},
				--	{x= 11767, y= 52, z= 7900},

					--
					
					{x= 11410, y= 23, z= 5526},
				--	{x= 11647, y= 54, z= 5452},
					
					{x= 11646, y= 54, z= 5452},
				--	{x= 11354, y= 8, z= 5511},

					--

					{x= 11722, y= 52, z= 5058},
				--	{x= 11345, y= -71, z= 4813},
					
					{x= 11428, y= -71, z= 4984},
				--	{x= 11725, y= 52, z= 5120},

					--

					{x= 11772, y= -71, z= 4608},
				--	{x= 11960, y= 51, z= 4802},
					
					{x= 11922, y= 51, z= 4758},
				--	{x= 11697, y= -71, z= 4614},

					--

					{x= 3074, y= 54, z= 10056},
				--	{x= 3437, y= -66, z= 10186},
					
					{x= 3324, y= -65, z= 10206},
				--	{x= 2964, y= 54, z= 10012},

					--

					{x= 3474, y= -65, z= 9856},
				--	{x= 3104, y= 52, z= 9701},
					
					{x= 3226, y= 52, z= 9752},
				--	{x= 3519, y= -65, z= 9833},

					--

					{x= 3488, y= 13, z= 9414},
				--	{x= 3224, y= 51, z= 9440},
					
					{x= 3226, y= 51, z= 9438},
				--	{x= 3478, y= 16, z= 9422},

					--

					{x= 6524, y= -71, z= 8856},
				--	{x= 6685, y= 49, z= 9116},
					
					{x= 6664, y= 43, z= 9002},
				--	{x= 6484, y= -71, z= 8804},

					--

					{x= 6874, y= -69, z= 8856},
				--	{x= 6685, y= 49, z= 9116},
					
					{x= 6664, y= 43, z= 9002},
				--	{x= 6848, y= -71, z= 8804},

					--

					{x= 6874, y= -69, z= 8606},
				--	{x= 7095, y= 52, z= 8727},
					
					{x= 7074, y= 52, z= 8706},
				--	{x= 6857, y= -71, z= 8517},

					--

					{x= 7174, y= -33, z= 8256},
				--	{x= 7456, y= 53, z= 8539},
					
					{x= 7422, y= 53, z= 8406},
				--	{x= 7100, y= -24, z= 8159},

					--

					{x= 7658, y= 5, z= 6512},
				--	{x= 7378, y= 52, z= 6298},
					
					{x= 7470, y= 52, z= 6260},
				--	{x= 7714, y= -1, z= 6544},

					--

					{x= 8034, y= -71, z= 6198},
				--	{x= 7813, y= 52, z= 5938},
					
					{x= 7898, y= 51, z= 6004},
				--	{x= 8139, y= -71, z= 6210},

					--

					{x= 8222, y= 32, z= 5808},
				--	{x= 8412, y= -71, z= 6081},
					
					{x= 8344, y= -71, z= 6022},
				--	{x= 8194, y= 42, z= 5742},

					--

					{x= 5774, y= 55, z= 10656},
				--	{x= 5355, y= -71, z= 10832},
					
					{x= 5474, y= -71, z= 10656},
				--	{x= 5812, y= 55, z= 10832},

					--

					{x= 4474, y= -71, z= 10406},
				--	{x= 4292, y= -71, z= 10199},
					
					{x= 4292, y= -71, z= 10270},
				--	{x= 4480, y= -71, z= 10437},

					--

					{x= 5074, y= -71, z= 10006},
				--	{x= 4993, y= -70, z= 9706},
					
					{x= 5000, y= -71, z= 9754},
				--	{x= 5083, y= -71, z= 9998},

					--

					{x= 9322, y= -71, z= 4358},
				--	{x= 8971, y= 52, z= 4284},
					
					{x= 9072, y= 53, z= 4208},
				--	{x= 9378, y= -71, z= 4431},

					--

					{x= 9812, y= -71, z= 4918},
				--	{x= 9803, y= -68, z= 5249},
					
					{x= 9822, y= -71, z= 5158},
				--	{x= 9751, y= -71, z= 4884},

					--

					{x= 10422, y= -71, z= 4458},
				--	{x= 10643, y= -68, z= 4641},
					
					{x= 10622, y= -71, z= 4558},
				--	{x= 10375, y= -71, z= 4441},

					--

					{x= 6524, y= 56, z= 12006},
				--	{x= 6553, y= 53, z= 11666},
					
					{x= 6574, y= 53, z= 11706},
				--	{x= 6543, y= 56, z= 12054},

					--

					{x= 8250, y= 51, z= 2894},
				--	{x= 8213, y= 51, z= 3326},
					
					{x= 8222, y= 51, z= 3158},
				--	{x= 8282, y= 51, z= 2741},

					--

					{x= 9482, y= 49, z= 2786},
				--	{x= 9535, y= 55, z= 3203},
					
					{x= 9530, y= 59, z= 3126},
				--	{x= 9505, y= 49, z= 2756},

					--

					{x= 9772, y= 49, z= 2758},
				--	{x= 9862, y= 58, z= 3111},
					
					{x= 9872, y= 58, z= 3066},
				--	{x= 9815, y= 49, z= 2673},

					--

					{x= 10206, y= 49, z= 2888},
				--	{x= 10046, y= 49, z= 2675},
					
					{x= 10022, y= 49, z= 2658},
				--	{x= 10259, y= 49, z= 2925},

					--

					{x= 5274, y= 57, z= 11806},
				--	{x= 5363, y= 56, z= 12185},
					
					{x= 5324, y= 56, z= 12106},
				--	{x= 5269, y= 57, z= 11725},

					--

					{x= 5000, y= 57, z= 11874},
				--	{x= 5110, y= 56, z= 12210},
					
					{x= 5072, y= 56, z= 12146},
				--	{x= 4993, y= 57, z= 11836},

					--

					{x= 4624, y= 57, z= 12006},
				--	{x= 4825, y= 56, z= 12307},
					
					{x= 4776, y= 56, z= 12224},
				--	{x= 4605, y= 57, z= 11970},

					--

					{x= 7372, y= 52, z= 5858},
				--	{x= 7115, y= 55, z= 5524},
					
					{x= 7174, y= 58, z= 5608},
				--	{x= 7424, y= 52, z= 5905},

					--

					{x= 3774, y= 52, z= 7706},
				--	{x= 3856, y= 51, z= 7412},
					
					{x= 3828, y= 51, z= 7428},
				--	{x= 3802, y= 52, z= 7743},

					--

					{x= 3424, y= 52, z= 7408},
				--	{x= 3422, y= 53, z= 7759},
					
					{x= 3434, y= 52, z= 7722},
				--	{x= 3437, y= 52, z= 7398},

					--

					{x= 4144, y= 50, z= 8030},
				--	{x= 4382, y= 48, z= 8149},
					
					{x= 4374, y= 49, z= 8156},
				--	{x= 4124, y= 50, z= 8022},

					--

					{x= 4664, y= -10, z= 8652},
				--	{x= 4624, y= -68, z= 9010},
					
					{x= 4662, y= -69, z= 8896},
				--	{x= 4672, y= 26, z= 8519},

					--

					{x= 3774, y= -14, z= 9206},
				--	{x= 4074, y= -67, z= 9322},
					
					{x= 4024, y= -68, z= 9306},
				--	{x= 3737, y= -8, z= 8233},

					--

					{x= 11022, y= 51, z= 7208},
				--	{x= 10904, y= 52, z= 7512},
					
					{x= 11022, y= 52, z= 7506},
				--	{x= 11040, y= 51, z= 7179},

					--

					{x= 11440, y= 52, z= 7208},
				--	{x= 11449, y= 52, z= 7517},
					
					{x= 11470, y= 52, z= 7486},
				--	{x= 11458, y= 52, z= 7155},

					--

					{x= 10172, y= 16, z= 6208},
				--	{x= 10189, y= -71, z= 5922},
					
					{x= 10172, y= -71, z= 5958},
				--	{x= 10185, y= 29, z= 6286},

					--

					{x= 10722, y= -66, z= 5658},
				--	{x= 11049, y= -22, z= 5660},
					
					{x= 11022, y= -30, z= 5658},
				--	{x= 10665, y= -68, z= 5662},

					--

					{x= 2574, y= 54, z= 9656},
				--	{x= 2800, y= 52, z= 9596},
					
					{x= 2774, y= 53, z= 9656},
				--	{x= 2537, y= 54, z= 9674},

					--

					{x= 2874, y= 51, z= 9306},
				--	{x= 2500, y= 52, z= 9262},
					
					{x= 2598, y= 52, z= 9272},
				--	{x= 2884, y= 51, z= 9291},

					--

					{x= 4624, y= 51, z= 5858},
				--	{x= 4772, y= 50, z= 5636},
					
					{x= 4774, y= 50, z= 5658},
				--	{x= 4644, y= 51, z= 5876},

					--

					{x= 4924, y= 52, z= 6158},
				--	{x= 4869, y= 51, z= 6452},
					
					{x= 4874, y= 51, z= 6408},
				--	{x= 4938, y= 51, z= 6062},

					--

					{x= 6174, y= 49, z= 5308},
				--	{x= 5998, y= 52, z= 5536},
					
					{x= 6024, y= 52, z= 5508},
				--	{x= 6199, y= 59, z= 5286},

					--

					{x= 12260, y= 52, z= 5220},
				--	{x= 12027, y= 54, z= 5265},
					
					{x= 12122, y= 54, z= 5208},
				--	{x= 12327, y= 52, z= 5243},

					--

					{x= 11972, y= 54, z= 5558},
				--	{x= 12343, y= 53, z= 5498},
					
					{x= 12272, y= 53, z= 5558},
				--	{x= 11969, y= 55, z= 5480},

					--

					{x= 8672, y= 50, z= 9606},
				--	{x= 8831, y= 52, z= 9384},
					
					{x= 8830, y= 52, z= 9382},
				--	{x= 8646, y= 50, z= 9635},

					--

					{x= 10222, y= 50, z= 9056},
				--	{x= 10061, y= 52, z= 9282},
					
					{x= 10072, y= 52, z= 9306},
				--	{x= 10193, y= 50, z= 9052},

					--

					{x= 9972, y= 68, z= 8506},
				--	{x= 9856, y= 50, z= 8831},
					
					{x= 9782, y= 50, z= 8765},
				--	{x= 9967, y= 65, z= 8429},

					--

					{x= 8072, y= 51, z= 9806},
				--	{x= 8369, y= 50, z= 9807},
					
					{x= 8372, y= 50, z= 9806},
				--	{x= 8066, y= 51, z= 9796},

					--

					{x= 4524, y= 96, z= 3258},
				--	{x= 4780, y= 51, z= 3460},
					
					{x= 4774, y= 51, z= 3408},
				--	{x= 4463, y= 96, z= 3260},

					--

					{x= 3074, y= 96, z= 4558},
				--	{x= 3182, y= 54, z= 4917},
					
					{x= 3174, y= 54, z= 4858},
				--	{x= 3085, y= 96, z= 4539},

					--

					{x= 11712, y= 91, z= 10390},
				--	{x= 11621, y= 52, z= 10092},
					
					{x= 11622, y= 52, z= 10106},
				--	{x= 11735, y= 91, z= 10430},

					--

					{x= 10308, y= 91, z= 11682},
				--	{x= 9999, y= 52, z= 11554},
					
					{x= 10022, y= 91, z= 11682},
				--	{x= 10321, y= 91, z= 11664},

		--Wall Spots
					},
 	},
}

function RunnanHurricaneCheck()
	if Param.LastHit.Hurrican and os.clock()-Last_Hurrican > 20 then
		Last_Hurrican = os.clock()
		for SLOT = ITEM_1, ITEM_6 do
			if GetInventoryHaveItem(3085) then
				HurricanGet = 1
				EnvoiMessage("Found : Runaan's Hurricane")
			end
		end
	end
end

function ItemCheck()
	if os.clock()-Last_Item_Check > 20 then
		Last_Item_Check = os.clock()
		for SLOT = ITEM_1, ITEM_6 do
			if GetInventoryHaveItem(3140) and QSSGet == 0 then
				QSSGet = 1
				EnvoiMessage("Found : Quicksilver Sash")
			end
			if GetInventoryHaveItem(3139) and MercurialGet == 0 then
				MercurialGet = 1
				if QSSGet == 1 then
					QSSGet = 0
				end
				EnvoiMessage("Found : Mercurial Scimitar")
			end
		end
	end
end

function Humanizing()
	if Param.Humanizer and Last_Humanizer > 10 then
		Human = (math.random(250)/1000)
		Last_Humanizer = os.clock()
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
	end
end
