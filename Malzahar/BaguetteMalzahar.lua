--[[

	Script by spyk for Malzahar.

	BaguetteMalzahar.lua

	Github link : https://github.com/spyk1/BoL/blob/master/BaguetteMalzahar/BaguetteMalzahar.lua

	Forum Thread : http://forum.botoflegends.com/topic/89837-beta-baguette-malzahar/

]]--

if myHero.charName ~= "Malzahar" then return end

function OnLoad()

	Malzahar();
end

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
};
local priorityTable = {
 
    AP_Carry = {
        "Annie", "Ahri", "Akali", "Anivia", "Annie", "Brand", "Cassiopeia", "Diana", "Evelynn", "FiddleSticks", "Fizz", "Gragas", "Heimerdinger", "Karthus",
        "Kassadin", "Katarina", "Kayle", "Kennen", "Leblanc", "Lissandra", "Lux", "Malzahar", "Mordekaiser", "Morgana", "Nidalee", "Orianna",
        "Rumble", "Ryze", "Sion", "Swain", "Syndra", "Teemo", "TwistedFate", "Veigar", "Viktor", "Vladimir", "Xerath", "Ziggs", "Zyra", "MasterYi", "VelKoz", "Azir", "Ekko", "AurelionSol", "Taliyah"
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
};
local version = "0.32";
local author = "spyk";
local SCRIPT_NAME = "BaguetteMalzahar";
local AUTOUPDATE = true;
local UPDATE_HOST = "raw.githubusercontent.com";
local UPDATE_PATH = "/spyk1/BoL/master/BaguetteMalzahar/BaguetteMalzahar.lua".."?rand="..math.random(1,10000);
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME;
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH;
local damageQ = 30 + myHero:GetSpellData(_Q).level * 40 + .7 * myHero.ap;
local damageW = (((27.5 + 2.5 * myHero:GetSpellData(_W).level) / 100) * myHero.totalDamage) + (((5 + 5 * myHero:GetSpellData(_W).level) / 100) * myHero.ap);
local damageE = 6 + 4 * myHero:GetSpellData(_E).level + 0.0875 * myHero.ap; 
local damageR = 3 + myHero:GetSpellData(_R).level * 2 + .015 * myHero.ap;
local Qdmg, Edmg, Rdmg, iDmg, totalDamage, health, mana, maxHealth, maxMana = 0 , 0, 0, 0, 0, 0, 0, 0, 0, 0;
local TextList = {"Ignite = Kill","Q = Kill", "E = Kill", "Q + E = Kill", "Q + E + Ignite = Kill", "Q + E + Ignite + R = Kill", "Full Combo = Kill", "Not Killable"};
local KillText = {};
local ultTimer = 0;
local CurrentMode = "";
local Last_LevelSpell = 0;
local lastPotion = 0;
local ActualPotTime = 15;
local ActualPotName = "None";
local ActualPotData = "None";
local poisson = {};

class 'Malzahar';
	
	function Malzahar:__init()
		print("<font color=\"#ffffff\">Loading</font><font color=\"#e74c3c\"><b> [BaguetteMalzahar]</b></font> <font color=\"#ffffff\">by spyk</font>");
		self:Update();

		if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then 
			Ignite = SUMMONER_1;
		elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then
			Ignite = SUMMONER_2;
		end

		self:Menu();
		self:CustomLoad();
	end

	function Malzahar:Alerte(msg)

		PrintChat("<font color=\"#e74c3c\"><b>[BaguetteMalzahar]</b></font> <font color=\"#ffffff\">" .. msg .. "</font>");
	end

	function Malzahar:AutoBuy()
		DelayAction(function()
			if VIP_USER and GetInGameTimer()/60 < 3 then
				if Param.Misc.Buy.Doran then
					BuyItem(1056);
				end
				if Param.Misc.Buy.Pots then
					BuyItem(2003);
				end
				if Param.Misc.Buy.Pots then
					BuyItem(2003);
				end
				if Param.Misc.Buy.Trinket then
					BuyItem(3340);
				end
			end
		end, 1);
	end

	function Malzahar:AutoLVLCombo()
		if Param.Misc.LVL.Combo == 1 then
			levelSequence =  {3,1,3,2,3,4,3,1,3,1,4,1,1,2,2,4,2,2};
		else
			levelSequence = nil;
		end
	end

	function Malzahar:AutoLVLSpell()
		if VIP_USER and os.clock()-Last_LevelSpell > 0.5 then
			if Param.Misc.LVL.Enable then
				autoLevelSetSequence(levelSequence);
				Last_LevelSpell = os.clock();
			else
				autoLevelSetSequence(nil);
				Last_LevelSpell = os.clock()+10;
			end
		end
	end

	function Malzahar:AutoPotions()
		if Param.Misc.Pots.Enable then
			if os.clock() - lastPotion > ActualPotTime then
				for SLOT = ITEM_1, ITEM_6 do
					if myHero:GetSpellData(SLOT).name == "RegenerationPotion" then
						ActualPotName = "Health Potion";
						ActualPotTime = 15;
						ActualPotData = "RegenerationPotion";
						self:Usepot();
					elseif myHero:GetSpellData(SLOT).name == "ItemMiniRegenPotion" then
						ActualPotName = "Cookie";
						ActualPotTime = 15;
						ActualPotData = "ItemMiniRegenPotion";
						self:Usepot();
					elseif myHero:GetSpellData(SLOT).name == "ItemCrystalFlaskJungle" then
						ActualPotName = "Hunter's Potion";
						ActualPotTime = 8;
						ActualPotData = "ItemCrystalFlaskJungle";
						self:Usepot();
					elseif myHero:GetSpellData(SLOT).name == "ItemCrystalFlask" then
						ActualPotName = "Refillable Potion";
						ActualPotTime = 12;
						ActualPotData = "ItemCrystalFlask";
						self:Usepot();
					elseif myHero:GetSpellData(SLOT).name == "ItemDarkCrystalFlask" then
						ActualPotName = "Corrupting Potion";
						ActualPotTime = 12;
						ActualPotData = "ItemDarkCrystalFlask";
						self:Usepot();
					end
				end
			end
		end
	end

	function Malzahar:CurrentTime()

		return (os.clock() * 1000);
	end

	function Malzahar:Combo()
		if ultTimer > self:CurrentTime() then return end
		if Target ~= nil and not self:Immune(Target) and not Target.dead then
			if (myHero:CanUseSpell(_R) == READY) == false then
				if myHero:CanUseSpell(_Q) == READY and Param.Combo.UseQ then
					self:LogicQ();
				end
				if myHero:CanUseSpell(_E) == READY and Param.Combo.UseE then
					self:LogicE();
				end
				if myHero:CanUseSpell(_W) == READY and Param.Combo.UseW then
					self:LogicW();
				end
			else
				if GetDistance(Target) < SkillR.range then
					self:LogicQ();
					DelayAction(function()
						self:LogicW();
						DelayAction(function()
							self:LogicE();
							DelayAction(function ()
								self:LogicR();
							end, .35)
						end, .35)
					end, .05)
				elseif GetDistance(Target) < SkillQ.range then
					self:LogicQ();
				end
			end
		end
		if Param.Draw.Misc.PermaShow then
			CustomPermaShow("Current Mode :", ""..CurrentMode, true, ARGB(255,52,73,94), nil, nil, 1);
		else
			CustomPermaShow("Current Mode :", ""..CurrentMode, false, ARGB(255,52,73,94), nil, nil, 1);
		end
		if CurrentMode ~= "Combo" then
			CurrentMode = "Combo";
		end
	end

	function Malzahar:CustomLoad()


		self:LoadSpikeLib();
		self:PredLoader();
		self:Skills();
		self:AutoLVLCombo();

		enemyMinions = minionManager(MINION_ENEMY, 700, myHero, MINION_SORT_HEALTH_ASC)
		jungleMinions = minionManager(MINION_JUNGLE, 700, myHero, MINION_SORT_MAXHEALTH_DEC)
		ts = TargetSelector(TARGET_LESS_CAST_PRIORITY, 1000, DAMAGE_MAGIC)
		ts.name = "Malzahar"
		Param:addTS(ts)

		self:AutoBuy();

		if Param.Draw.Skin.Enable then
			SetSkin(myHero, Param.Draw.Skin.skins -1);
		end

		AddUnloadCallback(function()

			self:Unload();
		end)

		AddDrawCallback(function()

			self:OnDraw();
		end)

		AddTickCallback(function()
			ts:update()
			Target = self:GetTarget();
			self:KillSteal();
			self:Keys();

			if VIP_USER then
				self:AutoLVLSpell();
			end

			self:AutoPotions();
			self:DrawKillable();
		end)

		AddRemoveBuffCallback(function(unit, buff)

			self:Remove(unit, buff);
		end)
	end

	function Malzahar:KillSteal()
		if ultTimer > self:CurrentTime() then return end
		for _, unit in pairs(GetEnemyHeroes()) do
			if GetDistance(unit) < 900 and Param.KillSteal.Enable and not unit.dead then
				health = unit.health;
				Rdmg = unit.maxHealth * damageR / 100;
				if myHero:CanUseSpell(_R) == READY and myHero:CanUseSpell(_E) == READY and health < myHero:CalcMagicDamage(unit, Rdmg) + myHero:CalcMagicDamage(unit, damageE*8) and GetDistance(unit) < SkillE.range then 
					CastSpell(_E, unit);
					DelayAction(function()
						self:LogicR(unit);
					end, .25);
				end
				if myHero:CanUseSpell(_Q) == READY and health < myHero:CalcMagicDamage(unit, damageQ) and Param.KillSteal.UseQ and GetDistance(unit) < SkillQ.range then
					self:LogicQ(unit);
				elseif myHero:CanUseSpell(_E) == READY and health < myHero:CalcMagicDamage(unit, damageE*8) and Param.KillSteal.UseE and GetDistance(unit) < 700 then
					self:LogicE(unit);
				elseif myHero:CanUseSpell(_R) == READY and health < myHero:CalcMagicDamage(unit, Rdmg) and Param.KillSteal.UseR and GetDistance(unit) < SkillR.range then
					self:LogicR(unit);
				elseif Ignite and myHero:CanUseSpell(Ignite) == READY and health < (50 + 20 * myHero.level) and Param.KillSteal.UseIgnite and ValidTarget(unit, 600) then
					CastSpell(Ignite, unit);
				elseif myHero:CanUseSpell(_Q) == READY and myHero:CanUseSpell(_W) == READY and myHero:CanUseSpell(_E) == READY and myHero:CanUseSpell(_R) == READY and GetDistance(unit) < 600 then
					if Param.KillSteal.UseQ and Param.KillSteal.UseW and Param.KillSteal.UseE and Param.KillSteal.UseR then 
						if health < myHero:CalcMagicDamage(unit, Rdmg) + myHero:CalcMagicDamage(unit, damageE*8) + myHero:CalcMagicDamage(unit, damageQ) + 150 then
							self:LogicQ();
							DelayAction(function()
								if GetDistance(unit) < SkillW.range then
									CastSpell(_W, unit.x, unit.z);
								else
									CastSpell(_W, myHero.x, myHero.z);
								end
								DelayAction(function()
									self:LogicE();
									DelayAction(function ()
										self:LogicR();
									end, .35)
								end, .35)
							end, .05)
						end
					end
				end
			end
		end
	end

	function Malzahar:Menu()

		Param = scriptConfig("[Baguette] Malzahar", "BaguettMalzahar");

		Param:addSubMenu("Combo Settings", "Combo")
			Param.Combo:addParam("UseQ", "Use (Q) Spell in Combo :" , SCRIPT_PARAM_ONOFF, true);
			Param.Combo:addParam("UseW", "Use (W) Spell in Combo :" , SCRIPT_PARAM_ONOFF, true);
			Param.Combo:addParam("UseE", "Use (E) Spell in Combo :" , SCRIPT_PARAM_ONOFF, true);
			Param.Combo:addParam("UseR", "Use (R) Spell in Combo :" , SCRIPT_PARAM_ONOFF, true);

		Param:addSubMenu("Harass Settings", "Harass");
			Param.Harass:addParam("UseQ", "Use (Q) Spell in Harass :" , SCRIPT_PARAM_ONOFF, true);
			Param.Harass:addParam("ManaQ", "Set a value for (Q) in Mana :", SCRIPT_PARAM_SLICE, 40, 0, 100);
			Param.Harass:addParam("UseE", "Use (E) Spell in Harass :" , SCRIPT_PARAM_ONOFF, true);
			Param.Harass:addParam("ManaE", "Set a value for (E) in Mana :", SCRIPT_PARAM_SLICE, 60, 0, 100);
			Param.Harass:addParam("UseW", "Use (W) Spell in Harass :" , SCRIPT_PARAM_ONOFF, true);
			Param.Harass:addParam("ManaW", "Set a value for (W) in Mana :", SCRIPT_PARAM_SLICE, 50, 0, 100);

		Param:addSubMenu("KillSteal Settings", "KillSteal");
			Param.KillSteal:addParam("Enable", "Use KillSteal :", SCRIPT_PARAM_ONOFF, true);
			Param.KillSteal:addParam("n1", "", SCRIPT_PARAM_INFO, "");
			Param.KillSteal:addParam("UseQ", "Use (Q) Spell in KillSteal :", SCRIPT_PARAM_ONOFF, true);
			Param.KillSteal:addParam("UseE", "Use (E) Spell in KillSteal :", SCRIPT_PARAM_ONOFF, true);
			if Ignite then Param.KillSteal:addParam("UseIgnite", "Use (Ignite) Spell in KillSteal :", SCRIPT_PARAM_ONOFF, true); end

		Param:addSubMenu("", "n3");

		Param:addSubMenu("WaveClear Settings", "WaveClear");
			Param.WaveClear:addParam("UseQ", "Use (Q) Spell in WaveClear :" , SCRIPT_PARAM_ONOFF, true);
			Param.WaveClear:addParam("ManaQ", "Set a value for (Q) in Mana :", SCRIPT_PARAM_SLICE, 60, 0, 100);
			Param.WaveClear:addParam("UseE", "Use (E) Spell in WaveClear :" , SCRIPT_PARAM_ONOFF, true);
			Param.WaveClear:addParam("ManaE", "Set a value for (E) in Mana :", SCRIPT_PARAM_SLICE, 80, 0, 100);
			Param.WaveClear:addParam("UseW", "Use (W) Spell in WaveClear :" , SCRIPT_PARAM_ONOFF, true);
			Param.WaveClear:addParam("ManaW", "Set a value for (W) in Mana :", SCRIPT_PARAM_SLICE, 70, 0, 100);

		Param:addSubMenu("Jungle Settings", "Jungle");
			Param.Jungle:addParam("UseQ", "Use (Q) Spell in JungleClear :" , SCRIPT_PARAM_ONOFF, true);
			Param.Jungle:addParam("ManaQ", "Set a value for (Q) in Mana :", SCRIPT_PARAM_SLICE, 40, 0, 100);
			Param.Jungle:addParam("UseE", "Use (E) Spell in JungleClear :" , SCRIPT_PARAM_ONOFF, true);
			Param.Jungle:addParam("ManaE", "Set a value for (E) in Mana :", SCRIPT_PARAM_SLICE, 60, 0, 100);
			Param.Jungle:addParam("UseW", "Use (W) Spell in JungleClear :" , SCRIPT_PARAM_ONOFF, true);
			Param.Jungle:addParam("ManaW", "Set a value for (W) in Mana :", SCRIPT_PARAM_SLICE, 50, 0, 100);

		Param:addSubMenu("", "n2");

		Param:addSubMenu("Draw Settings", "Draw");

			Param.Draw:addSubMenu("Spell Settings", "Spell");
				Param.Draw.Spell:addParam("Q", "Display (Q) Range :", SCRIPT_PARAM_ONOFF, false);
				Param.Draw.Spell:addParam("W", "Display (W) Range :", SCRIPT_PARAM_ONOFF, false);
				Param.Draw.Spell:addParam("E", "Display (E) Range :", SCRIPT_PARAM_ONOFF, false);
				Param.Draw.Spell:addParam("R", "Display (R) Range :", SCRIPT_PARAM_ONOFF, false);
				Param.Draw.Spell:addParam("n1", "", SCRIPT_PARAM_INFO, "");
				Param.Draw.Spell:addParam("AA", "Display Auto Attack Range :", SCRIPT_PARAM_ONOFF, false);
				Param.Draw.Spell:addParam("Egg", "Display UltTimer :", SCRIPT_PARAM_ONOFF, true);

			Param.Draw:addSubMenu("Damages Settings", "Damages");
				Param.Draw.Damages:addParam("Bar", "Display damages on HP bar :", SCRIPT_PARAM_ONOFF, true);
				Param.Draw.Damages:addParam("Killable", "Display Killable informations :", SCRIPT_PARAM_ONOFF, true);

			Param.Draw:addSubMenu("Skin Changer", "Skin");
				Param.Draw.Skin:addParam("Enable", "Enable Skin Changer : ", SCRIPT_PARAM_ONOFF, false);
					Param.Draw.Skin:setCallback("Enable", function (nV)
						if nV then
							SetSkin(myHero, Param.Draw.Skin.skins -1)
						else
							SetSkin(myHero, -1)
						end
					end);
				Param.Draw.Skin:addParam("skins", 'Which Skin :', SCRIPT_PARAM_LIST, 1, {"Classic", "Vizier", "Shadow Prince", "Djinn", "Overlord", "Snow Day"});
					Param.Draw.Skin:setCallback("skins", function (nV)
						if nV then
							if Param.Draw.Skin.Enable then
								SetSkin(myHero, Param.Draw.Skin.skins -1)
							end
						end
					end);

			Param.Draw:addSubMenu("Misc", "Misc");
				Param.Draw.Misc:addParam("PermaShow", "Draw PermaShow :", SCRIPT_PARAM_ONOFF, true);
				Param.Draw.Misc:setCallback("PermaShow", function(Perma)
					if Perma then
						self:Alerte("PermaShow Enabled.");
						self:PermaShow();
					else
						self:Alerte("PermaShow Disabled.");
						self:PermaShow();
					end
				end);
				Param.Draw.Misc:addParam("n1", "", SCRIPT_PARAM_INFO, "");
				Param.Draw.Misc:addParam("HitBox", "Draw HitBox :", SCRIPT_PARAM_ONOFF, true);
				Param.Draw.Misc:addParam("Target", "Draw Target :", SCRIPT_PARAM_ONOFF, true);

			Param.Draw:addParam("Disable", "Disable all draws :", SCRIPT_PARAM_ONOFF, false);
			Param.Draw:setCallback("Disable", function(Disable)
				if Disable then
					Param.Draw.Misc.PermaShow = false;
					Param.Draw.Skin.Enable = false;
					SetSkin(myHero, -1);
					self:PermaShow();
				end
			end)

		Param:addSubMenu("Miscellaneous Settings", "Misc");

			Param.Misc:addSubMenu("AutoBuy", "Buy");
				Param.Misc.Buy:addParam("Enable", "Enable AutoBuy :", SCRIPT_PARAM_ONOFF, true);
				Param.Misc.Buy:addParam("n1", "", SCRIPT_PARAM_INFO, "");
				Param.Misc.Buy:addParam("Doran", "Buy Doran Ring :", SCRIPT_PARAM_ONOFF, true);
				Param.Misc.Buy:addParam("Pots", "Buy 2x Potions :", SCRIPT_PARAM_ONOFF, true);
				Param.Misc.Buy:addParam("Trinket", "Buy Yellow Trinket :", SCRIPT_PARAM_ONOFF, true);
				Param.Misc.Buy:addParam("n2", "", SCRIPT_PARAM_INFO, "");
				Param.Misc.Buy:addParam("BlueTrinket", "Auto Upgrade trinket :", SCRIPT_PARAM_ONOFF, true);

			if VIP_USER then
				Param.Misc:addSubMenu("AutoLevel", "LVL");
					Param.Misc.LVL:addParam("Enable", "Enable Auto LEVEL Spell :", SCRIPT_PARAM_ONOFF, true);
					Param.Misc.LVL:addParam("Combo", "LVL Spell Order :", SCRIPT_PARAM_LIST, 1, {"E > Q > E > W (Max E)"});
					Param.Misc.LVL:setCallback("Combo", function(Spell)
						if Spell then
							self:AutoLVLCombo();
						else
							self:AutoLVLCombo();
						end
					end)
			end

			Param.Misc:addSubMenu("Potions Settings", "Pots");
				Param.Misc.Pots:addParam("Enable", "Use Auto Potions :", SCRIPT_PARAM_ONOFF, true);
				Param.Misc.Pots:addParam("Combo", "Use only on Combo mode :", SCRIPT_PARAM_ONOFF, true);
				Param.Misc.Pots:addParam("HP", "Set an %HP value :", SCRIPT_PARAM_SLICE, 60, 0, 100);

		Param:addSubMenu("", "n1");

		Param:addSubMenu("Orbwalker Settings", "Orb");
			Param.Orb:addParam("n1", "OrbWalker :", SCRIPT_PARAM_LIST, 3, {"SxOrbWalk", "BigFat OrbWalker", "Nebelwolfi's Orb Walker"});
			Param.Orb:addParam("n2", "If you want to change OrbWalker,", SCRIPT_PARAM_INFO, "");
			Param.Orb:addParam("n3", "Then, change it and press double F9.", SCRIPT_PARAM_INFO, "");
			Param.Orb:addParam("n4", "", SCRIPT_PARAM_INFO, "");
			Param.Orb:addParam("n5", "=> SAC:R & Pewalk are automaticly loaded.", SCRIPT_PARAM_INFO, "");
			Param.Orb:addParam("n6", "=> Enable one of them in BoLStudio", SCRIPT_PARAM_INFO, "");

		Param:addSubMenu("Prediction Settings", "Pred");
			Param.Pred:addParam("n1", "Pred", SCRIPT_PARAM_LIST, 2, {"VPrediction", "HPrediction"});
			Param.Pred:setCallback("n1", function(Pred)
				if Pred then
					self:PredLoader();
				else
					self:PredLoader();
				end
			end);
	end

	function Malzahar:OnDraw()
		if not myHero.dead and not Param.Draw.Disable then
			if myHero:CanUseSpell(_Q) == READY and Param.Draw.Spell.Q then 
				DrawCircle3D(myHero.x, myHero.y, myHero.z, SkillQ.range, 1, 0xFFFFFFFF)
			end
			if myHero:CanUseSpell(_W) == READY and Param.Draw.Spell.W then 
				DrawCircle3D(myHero.x, myHero.y, myHero.z, SkillW.range, 1, 0xFFFFFFFF)
			end
			if myHero:CanUseSpell(_E) == READY and Param.Draw.Spell.E then 
				DrawCircle3D(myHero.x, myHero.y, myHero.z, SkillE.range, 1, 0xFFFFFFFF)
			end
			if myHero:CanUseSpell(_R) == READY and Param.Draw.Spell.R then
				DrawCircle3D(myHero.x, myHero.y, myHero.z, SkillR.range, 1, 0xFFFFFFFF)
			end
			if Param.Draw.Spell.AA then
				DrawCircle3D(myHero.x, myHero.y, myHero.z, myHero.range, 1, 0xFFFFFFFF)
			end
			if Param.Draw.Misc.HitBox then
				DrawCircle3D(myHero.x, myHero.y, myHero.z, myHero.boundingRadius, 1, 0xFFFFFFFF)
			end
			if Param.Draw.Spell.Egg and ultTimer > self:CurrentTime() then
				DrawText3D("Ult :"..math.round((ultTimer - self:CurrentTime())/1000, 2).."s", myHero.x-100, myHero.y-50, myHero.z, 20, 0xFFFFFFFF);
			end
			if Target ~= nil and ValidTarget(Target) then
				if Param.Draw.Misc.Target then
					DrawText3D(">> TARGET <<",Target.x-100, Target.y-50, Target.z, 20, 0xFFFFFFFF);
					DrawText(""..Target.charName.."", 50, 50, 200, 0xFFFFFFFF);
				end
			end
			if Param.Draw.Damages.Killable then
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
			if Param.Draw.Damages.Bar then 
				for _, unit in pairs(GetEnemyHeroes()) do
					if unit ~= nil and GetDistance(unit) < 3000 then
						local Center = GetUnitHPBarPos(unit);
						local Y3QER = (math.floor(myHero:CalcDamage(unit,Edmg)))*8;
						if Center.x > -100 and Center.x < WINDOW_W+100 and Center.y > -100 and Center.y < WINDOW_H+100 then
							local off = GetUnitHPBarOffset(unit);
							local y = Center.y + (off.y * 53) + 2;
							local xOff = ({['AniviaEgg'] = -0.1,['Darius'] = -0.05,['Renekton'] = -0.05,['Sion'] = -0.05,['Thresh'] = -0.03,})[unit.charName];
							local x = Center.x + ((xOff or 0) * 140) - 66;
							if not TargetHaveBuff("SummonerExhaust", myHero) then
								dmg = unit.health - Y3QER;
							elseif TargetHaveBuff("SummonerExhaust", myHero) then
								dmg = unit.health - (Y3QER-((Y3QER*40)/100));
							end
							DrawLine(x + ((unit.health /unit.maxHealth) * 104),y, x+(((dmg > 0 and dmg or 0) / unit.maxHealth) * 104),y,9, GetDistance(unit) < 3000 and 0x6699FFFF);
						end
					end
				end
				for x, v in pairs(poisson) do
					if poisson[x][1] ~= nil then
						unit = poisson[x][1];
						if GetDistance(unit) < 3000 then
							local Center = GetUnitHPBarPos(unit);
							local Y3QER = (math.floor(myHero:CalcDamage(unit,Edmg)))*((poisson[x][2] - os.clock())*2);
							if Center.x > -100 and Center.x < WINDOW_W+100 and Center.y > -100 and Center.y < WINDOW_H+100 then
								local off = GetUnitHPBarOffset(unit);
								local y = Center.y + (off.y * 53) + 2;
								local xOff = ({['AniviaEgg'] = -0.1,['Darius'] = -0.05,['Renekton'] = -0.05,['Sion'] = -0.05,['Thresh'] = -0.03,})[unit.charName];
								local x = Center.x + ((xOff or 0) * 140) - 66;
								if not TargetHaveBuff("SummonerExhaust", myHero) then
									dmg = unit.health - Y3QER;
								elseif TargetHaveBuff("SummonerExhaust", myHero) then
									dmg = unit.health - (Y3QER-((Y3QER*40)/100));
								end
								DrawLine(x + ((unit.health /unit.maxHealth) * 104),y, x+(((dmg > 0 and dmg or 0) / unit.maxHealth) * 104),y,9, GetDistance(unit) < 3000 and 0x6699FFFF);
							end
						end
					end
				end
			end
		end
	end

	function Malzahar:DrawKillable()
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
					Qdmg = ((myHero:CanUseSpell(_Q) == READY and myHero:CalcMagicDamage(enemy,damageQ)) or 0);
					Edmg = ((myHero:CanUseSpell(_E) == READY and myHero:CalcMagicDamage(enemy,damageE)) or 0);
					Rdmg = ((myHero:CanUseSpell(_R) == READY and myHero:CalcMagicDamage(enemy,damageR)) or 0);
					if iDmg > enemy.health then
						KillText[i] = 1
					elseif Qdmg > enemy.health then
						KillText[i] = 2
					elseif Edmg > enemy.health then
						KillText[i] = 3
					elseif Qdmg + Edmg > enemy.health then
						KillText[i] = 4
					elseif Qdmg + Edmg + iDmg > enemy.health then
						KillText[i] = 5
					elseif Qdmg + Edmg + iDmg + Rdmg > enemy.health then
						KillText[i] = 6
					elseif Qdmg + Edmg + iDmg + Rdmg + 200 > enemy.health then
						KillText[i] = 7
					else
						KillText[i] = 8
					end
				end 
			end 
		end 
	end

	function Malzahar:GetEnemyHPBarPos(enemy)
	    if not enemy.barData then return end
	    local barPos = GetUnitHPBarPos(enemy)
	    local barPosOffset = GetUnitHPBarOffset(enemy)
	    local barOffset = Point(enemy.barData.PercentageOffset.x, enemy.barData.PercentageOffset.y)
	    local barPosPercentageOffset = Point(enemy.barData.PercentageOffset.x, enemy.barData.PercentageOffset.y)
	    local BarPosOffsetX = 169
	    local BarPosOffsetY = 47
	    local CorrectionX = 16
	    local CorrectionY = 4
	    barPos.x = barPos.x + (barPosOffset.x - 0.5 + barPosPercentageOffset.x) * BarPosOffsetX + CorrectionX
	    barPos.y = barPos.y + (barPosOffset.y - 0.5 + barPosPercentageOffset.y) * BarPosOffsetY + CorrectionY 
	    local StartPos = Point(barPos.x, barPos.y)
	    local EndPos = Point(barPos.x + 103, barPos.y)
	    return Point(StartPos.x, StartPos.y), Point(EndPos.x, EndPos.y)
	end

	function Malzahar:Harass()
		if ultTimer > self:CurrentTime() then return end
		if Target ~= nil and not Target.dead and GetDistance(Target) < SkillQ.range then
			if myHero:CanUseSpell(_Q) == READY and not self:ManaManager("Harass", "Q") and Param.Harass.UseQ then 
		  		self:LogicQ(Target);
			end
			if myHero:CanUseSpell(_W) == READY and not self:ManaManager("Harass", "W") and Param.Harass.UseW then 
		 		self:LogicW(Target);
			end
			if myHero:CanUseSpell(_E) == READY and not self:ManaManager("Harass", "E") and Param.Harass.UseE then
				self:LogicE(Target);
			end
		end
		if Param.Draw.Misc.PermaShow then
			CustomPermaShow("Current Mode :", ""..CurrentMode, true, ARGB(255,52,73,94), nil, nil, 1);
		else
			CustomPermaShow("Current Mode :", ""..CurrentMode, false, ARGB(255,52,73,94), nil, nil, 1);
		end
		if CurrentMode ~= "Harass" then
			CurrentMode = "Harass";
		end
	end

	function Malzahar:LaneClear()
		if ultTimer > self:CurrentTime() then return end
		jungleMinions:update()
		for i, jungleMinion in pairs(jungleMinions.objects) do
			if jungleMinion ~= nil and not jungleMinion.dead then
				if Param.Jungle.UseE and GetDistance(jungleMinion) < SkillE.range and myHero:CanUseSpell(_E) == READY then
					if not self:ManaManager("Jungle", "E") then
						if not TargetHaveBuff("MalzaharE", jungleMinion) then
							CastSpell(_E, jungleMinion);
						end
					end
				end
				if Param.Jungle.UseW and myHero:CanUseSpell(_W) == READY then 
					if not self:ManaManager("Jungle", "W") then
						if GetDistance(jungleMinion) < SkillW.range then
							CastSpell(_W, jungleMinion.x, jungleMinion.z);
						elseif GetDistance(jungleMinion) < 1000 then
							CastSpell(_W, myHero.x, myHero.z);
						end
					end
				end
				if Param.Jungle.UseQ and GetDistance(jungleMinion) < SkillQ.range and myHero:CanUseSpell(_Q) == READY then
					if not self:ManaManager("Jungle", "Q") then
						if QMissile ~= nil then return end
						if Param.Pred.n1 == 1 then
							CastPosition,  HitChance,  Position = VP:GetLineCastPosition(jungleMinion, SkillQ.delay, SkillQ.width, SkillQ.range, SkillQ.speed, myHero, false);
							if HitChance >= 2 then
								CastSpell(_Q, CastPosition.x, CastPosition.z);
							end
						elseif Param.Pred.n1 == 2 then
							local CastPosition, HitChance = HPred:GetPredict(HP_Q, jungleMinion, myHero);
				  			if HitChance >= 1 then
				    			CastSpell(_Q, CastPosition.x, CastPosition.z);
				  			end
						else
							self:Alertet("Cast(Q) bug???");
						end
					end
				end
			end
		end

		enemyMinions:update()
		for i, minion in pairs(enemyMinions.objects) do
			if ValidTarget(minion) and GetDistance(minion) < 1100 and not minion.dead then
				if Param.WaveClear.UseQ and GetDistance(minion) < SkillQ.range and myHero:CanUseSpell(_Q) == READY then
					if not self:ManaManager("WaveClear", "Q") then
						if Param.Pred.n1 == 1 then
							CastPosition,  HitChance,  Position = VP:GetLineCastPosition(minion, SkillQ.delay, SkillQ.width, SkillQ.range, SkillQ.speed, myHero, false);
							if HitChance >= 2 then
								CastSpell(_Q, CastPosition.x, CastPosition.z);
							end
						elseif Param.Pred.n1 == 2 then
							CastPosition, HitChance = HPred:GetPredict(HP_Q, minion, myHero);
							if HitChance > 0 then
								CastSpell(_Q, CastPosition.x, CastPosition.z);
							end
						end
					end
				end
				if Param.WaveClear.UseE and GetDistance(minion) < SkillE.range and myHero:CanUseSpell(_E) == READY then
					if not self:ManaManager("WaveClear", "E") then
						if not TargetHaveBuff("MalzaharE", minion) then
							CastSpell(_E, minion);
						end
					end
				end
				if Param.WaveClear.UseW and GetDistance(minion) < SkillW.range and myHero:CanUseSpell(_W) == READY then
					if not self:ManaManager("WaveClear", "W") then
						if GetDistance(minion) < myHero.range + myHero.boundingRadius and not minion.dead then 
							CastSpell(_W, minion.x, minion.z);
						else
							CastSpell(_W, myHero.x, myHero.z);
						end
					end
				end
			end
		end

		if Param.Draw.Misc.PermaShow then
			CustomPermaShow("Current Mode :", ""..CurrentMode, true, ARGB(255,52,73,94), nil, nil, 1);
		else
			CustomPermaShow("Current Mode :", ""..CurrentMode, false, ARGB(255,52,73,94), nil, nil, 1);
		end
		if CurrentMode ~= "LaneClear" then
			CurrentMode = "LaneClear";
		end
	end

	function Malzahar:LastHit()
		if Param.Draw.Misc.PermaShow then
			CustomPermaShow("Current Mode :", ""..CurrentMode, true, ARGB(255,52,73,94), nil, nil, 1);
		else
			CustomPermaShow("Current Mode :", ""..CurrentMode, false, ARGB(255,52,73,94), nil, nil, 1);
		end
		if CurrentMode ~= "LastHit" then
			CurrentMode = "LastHit";
		end
	end

	function Malzahar:ManaManager(Mode, Spell)
		local String = "Param."..""..Mode..".Mana"..Spell.."";
		if myHero.mana < (myHero.maxMana * (self:Mv(String) / 100)) then
			return true
		else
			return false
		end
	end

	function Malzahar:Mv(String)

		return string.byte(String);
	end

	function Malzahar:LogicQ()
		if ultTimer > self:CurrentTime() then return end
		if Target ~= nil and GetDistance(Target) < SkillQ.range and myHero:CanUseSpell(_Q) == READY and not Target.dead then
			if Param.Pred.n1 == 1 then
				CastPosition,  HitChance,  Position = VP:GetLineCastPosition(Target, SkillQ.delay, SkillQ.width, SkillQ.range, SkillQ.speed, myHero, false);
				if HitChance >= 2 then
					CastSpell(_Q, CastPosition.x, CastPosition.z);
				end
			elseif Param.Pred.n1 == 2 then
				CastPosition, HitChance = HPred:GetPredict(HP_Q, Target, myHero);
				if HitChance > 0 then
					CastSpell(_Q, CastPosition.x, CastPosition.z);
				end
			end
		end
	end

	function Malzahar:LogicW()
		if ultTimer > self:CurrentTime() then return end
		if GetDistance(Target) < myHero.range + myHero.boundingRadius and not Target.dead then 
			CastSpell(_W, Target.x, Target.z);
		else
			CastSpell(_W, myHero.x, myHero.z);
		end
 	end

	function Malzahar:LogicE()
		if ultTimer > self:CurrentTime() then return end
		if myHero:CanUseSpell(_E) == READY and GetDistance(Target) < SkillE.range and not Target.dead then
			if not TargetHaveBuff("MalzaharE", Target) then
				CastSpell(_E, Target);
			end
		end
	end

	function Malzahar:LogicR()
		if myHero:CanUseSpell(_R) == READY and GetDistance(Target) < SkillR.range and Target.health > 200 and not Target.dead then
			ultTimer = self:CurrentTime() + 2500;
			self:DisableOrbwalker();
			CastSpell(_R, Target);
			DelayAction(function()
				self:EnableOrbwalker();
			end, 2.5);
		end
	end

	function Malzahar:GetTarget()
		ts:update()	
		if ValidTarget(ts.target) and ts.target.type == myHero.type then
			return ts.target
		else
			return nil
		end
	end

	function Malzahar:EnableOrbwalker()
		if _G.AutoCarry then
			_G.AutoCarry.MyHero:MovementEnabled(true)
			_G.AutoCarry.MyHero:AttacksEnabled(true)
		elseif Param.prediction.n1 == 3 then
			_G.NebelwolfisOrbWalker:SetOrb(true)
		elseif Param.prediction.n1 == 1 then
			SxOrb:EnableMove()
			SxOrb:EnableAttacks()
		elseif Param.prediction.n1 == 2 then
			_G["BigFatOrb_DisableMove"] = false
			_G["BigFatOrb_DisableAttacks"] = false
		end
	end

	function Malzahar:DisableOrbwalker()
		if _G.AutoCarry then
			_G.AutoCarry.MyHero:AttacksEnabled(false)
			_G.AutoCarry.MyHero:MovementEnabled(false)
		elseif Param.prediction.n1 == 3 then
			_G.NebelwolfisOrbWalker:SetOrb(false)
		elseif Param.prediction.n1 == 1 then
			SxOrb:DisableAttacks()
			SxOrb:DisableMove()
		elseif Param.prediction.n1 == 2 then
			_G["BigFatOrb_DisableMove"] = true
			_G["BigFatOrb_DisableAttacks"] = true
		end
	end

	function Malzahar:Skills()
		SkillQ = { name = "AlZaharCalloftheVoid", range = 900, delay = 0.25, speed = math.huge, width = 80, ready = false } --400
		SkillW = { name = "AlZaharNullZone", range = 450, delay = 0.25, speed = math.huge, width = nil, ready = false }
		SkillE = { name = "AlZaharMaleficVisions", range = 650, delay = 0.25, speed = math.huge, width = nil, ready = false }
		SkillR = { name = "AlZaharNetherGrasp", range = 650, delay = 0.25, speed = math.huge, width = nil, ready = false }
	end

	function Malzahar:Usepot()
		if Param.Misc.Pots.Combo and CurrentMode == "Combo" or not Param.Misc.Pots.Combo then
			for SLOT = ITEM_1, ITEM_6 do
				if myHero:GetSpellData(SLOT).name == ActualPotData and not InFountain() then
					if myHero:CanUseSpell(SLOT) == READY and (myHero.health*100)/myHero.maxHealth < Param.Misc.Pots.HP and not InFountain() then
						CastSpell(SLOT);
						lastPotion = os.clock();
						self:Alerte("1x "..ActualPotName.." => Used.");
					end
				end
			end
		end
	end

	function Malzahar:Unload()

		self:Alerte("Unloaded, there is no void anymore between us... Ciao!");
		if Param.Draw.Skin.Enable then
			SetSkin(myHero, -1);
		end
	end

	function Malzahar:Update()
		if AUTOUPDATE then
			local ServerData = GetWebResult(UPDATE_HOST, "/spyk1/BoL/master/BaguetteMalzahar/BaguetteMalzahar.version")
			if ServerData then
				ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil;
				if ServerVersion then
					if tonumber(version) < ServerVersion then
						self:Alerte("New version available "..ServerVersion);
						self:Alerte(">>Updating, please don't press F9<<");
						DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () self:Alerte("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3);
					else
						DelayAction(function() self:Alerte("Hello, "..GetUser()..". You got the latest version! :) ("..ServerVersion..")") end, 3);
					end
				end
			else
				self:Alerte("Error downloading version info");
			end
		end
	end

	function Malzahar:PredLoader()
		if Param.Pred.n1 == 1 then
			self:LoadVPred();
		elseif Param.Pred.n1 == 2 then
			self:LoadHPred();
		end
	end

	function Malzahar:Immune(unit)
		for i = 1, unit.buffCount do
			local tBuff = unit:getBuff(i);
			if BuffIsValid(tBuff) then
				if buffs[tBuff.name] then
					return true
				end
			end
		end
		return false
	end

	function Malzahar:Remove(unit, buff)
		if buff and unit and buff.name == "recall" and unit.isMe then
			if myHero.level >= 9 then
				if Param.Misc.Buy.BlueTrinket then
					BuyItem(3363);
				end
			end
		end
	end

	function Malzahar:PermaShow()
		if Param.Draw.Misc.PermaShow then
			CustomPermaShow("                         - Baguette "..myHero.charName.." - ", nil, true, nil, nil, nil, 0);
			CustomPermaShow("Current Mode :", ""..CurrentMode, true, ARGB(255,52,73,94), nil, nil, 1);
			CustomPermaShow("", "", true, nil, nil, nil, 2);
			CustomPermaShow("By spyk ", "v"..version, true, ARGB(255,52,73,94), nil, nil, 3);
		else
			CustomPermaShow("                         - Baguette ("..myHero.charName..") - ", nil, false, nil, nil, nil, 0);
			CustomPermaShow("Current Mode :", ""..CurrentMode, false, ARGB(255,52,73,94), nil, nil, 1);
			CustomPermaShow("", "", false, nil, nil, nil, 2);
			CustomPermaShow("By spyk ", "v"..version, false, ARGB(255,52,73,94), nil, nil, 3);
		end
	end

	function Malzahar:OnProcessSpell(unit, spell)
		if Param.Misc.Gap.Enable then
			if unit.team ~= myHero.team and myHero:CanUseSpell(_R) == READY then
				if isAGapcloserToDo[spell.name] and unit.health < 2300 then
					if spell.name ==  "ZedR" and spell.target and spell.target.networkID == myHero.networkID then
						if myHero:CanUseSpell(_W) == READY and Param.Misc.Gap.UseW then
							CastSpell(_W, myHero.x, myHero.z)
						end
						if myHero:CanUseSpell(_Q) == READY and Param.Misc.Gap.UseQ then
							DelayAction(function()
								CastSpell(_Q, myHero.x-50, myHero.z-50)
							end, 0.50)
						end
						DelayAction(function()
							if myHero:CanUseSpell(_E) == READY and Param.Misc.Gap.UseE then
								DelayAction(function()
									LogicE(unit)
								end, 0.05)
							end
							if myHero:CanUseSpell(_R) == READY and Param.Misc.GapUseR then
								DelayAction(function()
									LogicR(unit)
								end, 0.20)
							end
						end, 0.80)
					end

					if spell.name ~= "ZedR" then
						DelayAction(function()
						if myHero:CanUseSpell(_E) == READY and Param.miscellaneous.GapCloser.UseE then
							LogicE(unit)
						end
						end, 0.05)
						if myHero:CanUseSpell(_W) == READY and Param.miscellaneous.GapCloser.UseW then
							LogicW(unit)
						end
						DelayAction(function()
						if myHero:CanUseSpell(_R) == READY then
							LogicR(unit)
						end
						end, 0.20)
					end
				end
			end
		end
	end

	function OnUpdateBuff(src, buff, stacks)
    	if buff and buff.name and buff.name == "MalzaharE" then
    		if unit and unit.type and unit.type == myHero.type then
	    		table.insert(poisson, {unit, os.clock()});
	    		DelayAction(function()
	    			table.remove(poisson, unit);
	    		end, 4)
	    	end
    	end
	end

	function Malzahar:Keys()
		if not (ultTimer > self:CurrentTime()) then
			if _G.AutoCarry and _G.AutoCarry.Keys and _G.Reborn_Loaded ~= nil then

				if _G.AutoCarry.Keys.AutoCarry then 
					self:Combo();
				elseif  _G.AutoCarry.Keys.MixedMode then 
					self:Harass();
				elseif  _G.AutoCarry.Keys.LaneClear then 
					self:LaneClear();
				elseif  _G.AutoCarry.Keys.LastHit then 
					self:LastHit();
				else
					self:Nothing();
				end

			elseif _Pewalk then

				if _G._Pewalk.GetActiveMode().Carry then 
					self:Combo();
				elseif _G._Pewalk.GetActiveMode().Mixed then 
					self:Harass();
				elseif _G._Pewalk.GetActiveMode().LaneClear then
					self:LaneClear();
				elseif _G._Pewalk.GetActiveMode().Farm then 
					self:LastHit();
				else
					self:Nothing();
				end

			elseif _G.NebelwolfisOrbWalkerLoaded then

				if _G.NebelwolfisOrbWalker.Config.k.Combo then
					self:Combo();
				elseif _G.NebelwolfisOrbWalker.Config.k.Harass then
					self:Harass();
				elseif _G.NebelwolfisOrbWalker.Config.k.LastHit then
					self:LastHit();
				elseif _G.NebelwolfisOrbWalker.Config.k.LaneClear then
					self:LaneClear();
				else
					self:Nothing();
				end
			end
		else
			self:Mode();
		end
	end

	function Malzahar:Mode()
		if Param.Draw.Misc.PermaShow then
			CustomPermaShow("Current Mode :", ""..CurrentMode, true, ARGB(255,52,73,94), nil, nil, 1);
		else
			CustomPermaShow("Current Mode :", ""..CurrentMode, false, ARGB(255,52,73,94), nil, nil, 1);
		end
		if CurrentMode ~= ">>Ulting<<" then
			CurrentMode = ">>Ulting<<";
		end
	end

	function Malzahar:Nothing()
		if Param.Draw.Misc.PermaShow then
			CustomPermaShow("Current Mode :", ""..CurrentMode, true, ARGB(255,52,73,94), nil, nil, 1);
		else
			CustomPermaShow("Current Mode :", ""..CurrentMode, false, ARGB(255,52,73,94), nil, nil, 1);
		end
		if CurrentMode ~= "None" then
			CurrentMode = "None";
		end
	end

function Malzahar:LoadVPred()
	if FileExist(LIB_PATH .. "/VPrediction.lua") then
		require("VPrediction");
		VP = VPrediction();
	else
		local Host = "raw.githubusercontent.com";
		local Path = "/SidaBoL/Scripts/master/Common/VPrediction.lua".."?rand="..math.random(1,10000);
		self:Alerte("VPred not found, downloading...");
		DownloadFile("https://"..Host..Path, LibPath, function ()  end);
		DelayAction(function () require("VPrediction") end, 5);
	end
end

function Malzahar:LoadHPred()
	if FileExist(LIB_PATH .. "/HPrediction.lua") then
		require("HPrediction");
		HPred = HPrediction();
		HP_Q = HPSkillshot({type = "DelayLine", delay = 0.250, range = 1075, width = 110, speed = 850});
		HP_R = HPSkillshot({type = "DelayLine", delay = 0.100, range = 625, width = 350, speed = math.huge});
		UseHP = true;
	else
		local Host = "raw.githubusercontent.com";
		local Path = "/BolHTTF/BoL/master/HTTF/Common/HPrediction.lua".."?rand="..math.random(1,10000);
		self:Alerte("HPred not found, downloading..");
		DownloadFile("https://"..Host..Path, LibPath, function ()  end);
		DelayAction(function () require("HPrediction") end, 5);
	end
end

function Malzahar:LoadSACR()
	if _G.Reborn_Initialised then
	elseif _G.Reborn_Loaded then
	else
		DelayAction(function() self:Alerte("Failed to Load SAC:R")end, 7);
	end 
end

function Malzahar:LoadPewalk()
	if _Pewalk then
	elseif not _Pewalk then
		self:Alerte("Pewalk loading error");
	end
end

function Malzahar:LoadNEOrb()
	local function LoadOrb()
		if not _G.NebelwolfisOrbWalkerLoaded then
			require "Nebelwolfi's Orb Walker";
			NebelwolfisOrbWalkerClass();
		end
	end
	if not FileExist(LIB_PATH.."Nebelwolfi's Orb Walker.lua") then
		DownloadFile("http://raw.githubusercontent.com/nebelwolfi/BoL/master/Common/Nebelwolfi's Orb Walker.lua", LIB_PATH.."Nebelwolfi's Orb Walker.lua", function()
			LoadOrb();
		end)
	else
		local f = io.open(LIB_PATH.."Nebelwolfi's Orb Walker.lua")
		f = f:read("*all")
		if f:sub(1,4) == "func" then
			DownloadFile("http://raw.githubusercontent.com/nebelwolfi/BoL/master/Common/Nebelwolfi's Orb Walker.lua", LIB_PATH.."Nebelwolfi's Orb Walker.lua", function()
				LoadOrb();
			end)
		else
			LoadOrb();
		end
	end
end

function Malzahar:LoadSpikeLib()
	local LibPath = LIB_PATH.."SpikeLib.lua"
	if not FileExist(LibPath) then
		local Host = "raw.github.com";
		local Path = "/spyk1/BoL/master/bundle/SpikeLib.lua".."?rand="..math.random(1,10000);
		DownloadFile("https://"..Host..Path, LibPath, function ()  end);
		DelayAction(function() require("SpikeLib") end, 5);
	else
		require("SpikeLib");
		self:PermaShow();
	end
end

function Malzahar:LoadBFOrb()
	local LibPath = LIB_PATH.."Big Fat Orbwalker.lua";
	local ScriptPath = SCRIPT_PATH.."Big Fat Orbwalker.lua";
		if not (FileExist(ScriptPath) and _G["BigFatOrb_Loaded"] == true) then
			local Host = "raw.github.com";
			local Path = "/BigFatNidalee/BoL-Releases/master/LimitedAccess/Big Fat Orbwalker.lua?rand="..math.random(1,10000);
			DownloadFile("https://"..Host..Path, LibPath, function ()  end);
		require "Big Fat Orbwalker";
	end
end

function Malzahar:LoadSXOrb()
	if FileExist(LIB_PATH .. "/SxOrbWalk.lua") then
		require("SxOrbWalk")
		self:Alerte("Loaded SxOrbWalk")
		Param:addSubMenu("SxOrbWalk", "SXMenu")
		SxOrb:LoadToMenu(Param.SXMenu)
	else
		self:Alerte("Download a Fresh BoL Folder.")
	end
end
