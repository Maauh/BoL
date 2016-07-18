--[[

	Script by spyk for Anivia.

	BaguetteAnivia.lua

	Github link : https://github.com/spyk1/BoL/blob/master/BaguetteAnivia/BaguetteAnivia.lua

	Forum Thread : http://forum.botoflegends.com/topic/87964-beta-baguette-anivia/

]]--


if myHero.charName ~= "Anivia" then return end

function OnLoad()

	Anivia:_init();
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

local version = "0.711";
local author = "spyk";
local SCRIPT_NAME = "BaguetteAnivia";
local AUTOUPDATE = true;
local UPDATE_HOST = "raw.githubusercontent.com";
local UPDATE_PATH = "/spyk1/BoL/master/BaguetteAnivia/BaguetteAnivia.lua".."?rand="..math.random(1,10000);
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME;
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH;
local Last_LevelSpell = 0;
local QMissile = nil;
local RMissile = nil;
local RTime = 0;
local Target;
local CurrentMode = "None";
local lastTP = 0;
local ActualTPTime = 0;
local damageQ = 25 * myHero:GetSpellData(_Q).level + 35 + .4 * myHero.ap;
local damageE = 30 * myHero:GetSpellData(_E).level + 25 + .5 * myHero.ap;
local damageR = 40 * myHero:GetSpellData(_R).level + 40 + .25 * myHero.ap;
local lastPotion = 0;
local ActualPotTime = 15;
local ActualPotName = "None";
local ActualPotData = "None";
local Qdmg, Edmg, Rdmg, iDmg, totalDamage, health, mana, maxHealth, maxMana = 0 , 0, 0, 0, 0, 0, 0, 0, 0, 0;
local TextList = {"Ignite = Kill", "Q = Kill", "DoubleQ = Kill", "Q + Ignite = Kill", "DoubleQ + Ignite = Kill", "Q + FrozenE = Kill", "DoubleQ + FrozenE = Kill", "Q + FrozenE + Ignite = Kill", "DoubleQ + FrozenE + Ignite = Kill", "Q + FrozenE + R for 1s = Kill", "DoubleQ + FrozenE + R for 1s = Kill", "DoubleQ + FrozenE + R for 3s = Kill", "Q + FrozenE + R + Ignite = Kill", "DoubleQ + FrozenE + R + Ignite = Kill", "DoubleQ + FrozenE + R for 3s + Ignite = Kill", "Not Killable"};
local KillText = {};
local startTime = 0;
local OeufTimerDraw = 0;

class 'Anivia';
	
	function Anivia:_init()
		self:Alerte("[Beta] Baguette Anivia - by spyk, loading.");
		self:Update();

		if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then 
			Ignite = SUMMONER_1;
		elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then 
			Ignite = SUMMONER_2;
		end

		if myHero:GetSpellData(SUMMONER_1).name:find("SummonerTeleport") then 
			Teleport = SUMMONER_1;
		elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerTeleport") then 
			Teleport = SUMMONER_2;
		end

		self:Menu();
		self:CustomLoad();
		self:PriorityOnLoad();
	end

	function Anivia:AutoBuy()
		if VIP_USER and GetGameTimer() < 200 then
			DelayAction(function()
				if Param.Misc.Buy.Doran then
					BuyItem(1056);
				end
				DelayAction(function()
					if Param.Misc.Buy.Pots then
						BuyItem(2003);
					end
					DelayAction(function()
						if Param.Misc.Buy.Pots then
							BuyItem(2003);
						end
						DelayAction(function()
							if Param.Misc.Buy.Trinket then
								BuyItem(3340);
							end
						end, 1)
					end, 1)
				end, 1)
			end, 1)
		end
	end

	function Anivia:Alerte(msg)

		PrintChat("<b><font color=\"#2c3e50\">></font></b> </font><font color=\"#c5eff7\"> " .. msg .. "</font>");
	end

	function Anivia:AngleDifference(from, p1, p2)
		local p1Z = p1.z - from.z;
		local p1X = p1.x - from.x;
		local p1Angle = math.atan2(p1Z , p1X) * 180 / math.pi;
		
		local p2Z = p2.z - from.z;
		local p2X = p2.x - from.x;
		local p2Angle = math.atan2(p2Z , p2X) * 180 / math.pi;
		
		return math.sqrt((p1Angle - p2Angle) ^ 2)
	end

	function Anivia:arrangePrioritys()
		for i, enemy in ipairs(GetEnemyHeroes()) do
			self:SetPriority(priorityTable.AD_Carry, enemy, 1);
			self:SetPriority(priorityTable.AP_Carry, enemy, 2);
			self:SetPriority(priorityTable.Support,  enemy, 3);
			self:SetPriority(priorityTable.Bruiser,  enemy, 4);
			self:SetPriority(priorityTable.Tank,     enemy, 5);
		end
	end

	function Anivia:AutoLVLSpell()
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

	function Anivia:AutoLVLCombo()
		if Param.Misc.LVL.Combo == 1 then
			levelSequence = {1,3,2,3,3,4,3,1,3,1,4,1,1,2,2,4,2,2};
		elseif Param.Misc.LVL.Combo == 2 then			
			levelSequence = {1,3,3,2,3,4,3,1,3,1,4,1,1,2,2,4,2,2};
		else 
			levelSequence = nil;
		end
	end

	function Anivia:AutoPotions()
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

	function Anivia:CustomLoad()

		if Param.Draw.Skin.Enable then

			SetSkin(myHero, Param.Draw.Skin.skins -1);
		end

		self:AutoBuy();
		self:Tables();
		self:PredLoader();
		self:LoadSpikeLib();
		self:Skills();
		self:PermaShow();

		if VIP_USER then

			self:AutoLVLCombo();
		end

		AddTickCallback(function()
			if not myHero.dead then
				ts:update()
				Target = self:GetTarget();

				self:Keys();
				self:KillSteal();
				self:WintoR(Target);

				if VIP_USER then
					self:AutoLVLSpell();
				end

				if Teleport then
					if Param.Exp.Egg.Enable then
						self:ExpTP();
					end
				end

				if QMissile ~= nil then
					self:DetectQ();
				end

				if RMissile ~= nil and Param.Misc.Spell.AutoR then
					if not self:ValidR() then
						CastSpell(_R);
					end
				end

				self:AutoPotions();
				self:DrawKillable();
			end
		end)

		AddUnloadCallback(function()

			self:Unload();
		end)

		AddRemoveBuffCallback(function(unit, buff)

			self:Remove(unit, buff);
		end)

		AddProcessSpellCallback(function(unit, spell)

			self:ProSpell(unit, spell);
		end)

		AddDrawCallback(function()

			self:OnDraw()

		end)

		enemyMinions = minionManager(MINION_ENEMY, 700, myHero, MINION_SORT_HEALTH_ASC);
		jungleMinions = minionManager(MINION_JUNGLE, 700, myHero, MINION_SORT_MAXHEALTH_DEC);
		ts = TargetSelector(TARGET_LESS_CAST_PRIORITY, 1000, DAMAGE_MAGIC);
		ts.name = "Anivia";
		Param:addTS(ts);

		if _G.Reborn_Loaded ~= nil then
	   		self:LoadSACR();
	   	elseif _Pewalk then
	   		self:LoadPewalk();
		elseif Param.Orb.n1 == 1 then
			self:LoadSXOrb();
		elseif Param.Orb.n1 == 2 then
			self:LoadBFOrb();
		elseif Param.Orb.n1 == 3 then
			self:LoadNEOrb();
		end
	end

	function Anivia:CurrentTime()

		return (os.clock() * 1000);
	end

	function Anivia:KillSteal()
		for _, unit in pairs(GetEnemyHeroes()) do
			health = unit.health;
			Qdmg = ((myHero:CanUseSpell(_Q) == READY and damageQ) or 0);
			Edmg = ((myHero:CanUseSpell(_E) == READY and damageE) or 0);
			Rdmg = ((myHero:CanUseSpell(_R) == READY and damageR) or 0);
			if GetDistance(unit) < 1000 then
				if Param.KillSteal.Enable then
					if health <= Qdmg and Param.KillSteal.UseQ and myHero:CanUseSpell(_Q) == READY and ValidTarget(unit) then
						self:LogicQ(unit);
					end
					if health <= Edmg and Param.KillSteal.UseE and myHero:CanUseSpell(_E) == READY and ValidTarget(unit) then
						CastSpell(_E, unit);
					end
					if health <= Rdmg and Param.KillSteal.UseR and myHero:CanUseSpell(_R) == READY and ValidTarget(unit) then
						self:LogicR(unit);
					end
					if Ignite then
						if health <= 40 + (20 * myHero.level) and Param.KillSteal.UseIgnite and (myHero:CanUseSpell(Ignite) == READY) and ValidTarget(unit) then
							CastSpell(Ignite, unit);
						end
					end
				end
			end
		end
	end

	function OnCreateObj(object)
		if object.name == "cryo_FlashFrost_Player_mis.troy" then
			QMissile = object;
		end
		if object.name == "cryo_storm_green_team.troy" then
			RMissile = object;
		end
	end

	function OnDeleteObj(object)
		if object.name == "cryo_FlashFrost_mis.troy" then
			QMissile = nil;
		end
		if object.name == "cryo_storm_green_team.troy" then
			RMissile = nil;
		end
	end

	function OnNewPath(unit,startPos,endPos,isDash,dashSpeed,dashGravity,dashDistance)
		if isDash and myHero:CanUseSpell(_W) == READY and Param.Misc.Spell.WintoR then
			if GetDistance(startPos, endPos) < 0.55 * dashSpeed then
				castPos = Vector(startPos) + (Vector(endPos) - Vector(startPos)):normalized() * 0.55 * dashSpeed;
			else
				castPos = Vector(startPos) + (Vector(endPos) - Vector(startPos)):normalized() * (dashDistance + 50);
			end
				
			if Anivia:AngleDifference(myHero, startPos, castPos) < 45 and GetDistance(castPos) > 50 and GetDistance(castPos) < 500 then
				CastSpell(_W, castPos.x, castPos.z);
			end
		end
	end

	function Anivia:GetBestCircularFarmPosition(range, radius, objects)
	    local BestPos 
	    local BestHit = 0
	    for i, object in ipairs(objects) do
	        local hit = self:CountObjectsNearPos(object.pos or object, range, radius, objects)
	        if hit > BestHit then
	            BestHit = hit
	            BestPos = Vector(object)
	            if BestHit == #objects then
	               break
	            end
	         end
	    end

	    return BestPos, BestHit
	end

	function Anivia:CountObjectsNearPos(pos, range, radius, objects)
	    local n = 0
	    for i, object in ipairs(objects) do
	        if GetDistanceSqr(pos, object) <= radius * radius then
	            n = n + 1
	        end
	    end

	    return n
	end

	function Anivia:DetectQ()
		local QZone = 150;
		if CurrentMode == "Combo" then
			if ValidTarget(Target) and Target.visible and not Target.dead and GetDistance(Target, QMissile) < 150 then
				CastSpell(_Q);
			else
				for k, unit in ipairs(GetEnemyHeroes()) do
					if ValidTarget(unit) and unit.visible and QMissile and not unit.dead then
						if GetDistance(unit, QMissile) < 150 then
							CastSpell(_Q);
						end
					end
				end
			end
		elseif CurrentMode == "LaneClear" then
			-- enemyMinions:update();
			-- for i, minion in ipairs(enemyMinions.objects) do
			-- 	if ValidTarget(minion) and minion.visible and QMissile and not minion.dead then
			-- 		if GetDistance(minion, QMissile) <= QZone then
			-- 			CastSpell(_Q);
			-- 		end
			-- 	end
			-- end
			jungleMinions:update();
			for i, jungleMinion in pairs(jungleMinions.objects) do
				if ValidTarget(jungleMinion) and jungleMinion.visible and QMissile and not jungleMinion.dead then
					if GetDistance(jungleMinion, QMissile) <= QZone then
						CastSpell(_Q);
					end
				end
			end
		elseif CurrentMode == "Harass" then
			for k, unit in ipairs(GetEnemyHeroes()) do
				if ValidTarget(unit) and unit.visible and QMissile and not unit.dead then
					if GetDistance(unit, QMissile) <= QZone then
						CastSpell(_Q);
					end
				end
			end
		elseif CurrentMode == "LastHit" then
			for k, unit in ipairs(GetEnemyHeroes()) do
				if ValidTarget(unit) and unit.visible and QMissile and not unit.dead then
					if GetDistance(unit, QMissile) <= QZone then
						CastSpell(_Q);
					end
				end
			end
		end
	end

	function Anivia:Combo()

		if Target ~= nil then

			if ValidTarget(Target) and Target.type == myHero.type and not self:Immune(Target) then
				if Param.Combo.UseQ then
					self:LogicQ(Target);
				end
				if Param.Combo.UseE then
					self:LogicE(Target);
				end
				if Param.Combo.UseR then
					self:LogicR(Target);
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

	function Anivia:DrawKillable()
		for i = 1, heroManager.iCount, 1 do
			local enemy = heroManager:getHero(i)
			if enemy and ValidTarget(enemy) then
				if enemy.team ~= myHero.team then 
					if Ignite then
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
					elseif Qdmg*2 > enemy.health then
						KillText[i] = 3
					elseif Qdmg + iDmg > enemy.health then
						KillText[i] = 4
					elseif Qdmg*2 + iDmg > enemy.health then
						KillText[i] = 5
					elseif Qdmg + Edmg*2 > enemy.health then
						KillText[i] = 6
					elseif Qdmg*2 + Edmg*2 > enemy.health then
						KillText[i] = 7
					elseif Qdmg + Edmg*2 + iDmg > enemy.health then
						KillText[i] = 9
					elseif Qdmg*2 + Edmg*2 + iDmg > enemy.health then
						KillText[i] = 9
					elseif Qdmg + Edmg*2 + Rdmg > enemy.health then
						KillText[i] = 11
					elseif Qdmg*2 + Edmg*2 + Rdmg > enemy.health then
						KillText[i] = 11
					elseif Qdmg*2 + Edmg*2 + Rdmg*3 > enemy.health then
						KillText[i] = 12
					elseif Qdmg + Edmg*2 + Rdmg + iDmg > enemy.health then
						KillText[i] = 13
					elseif Qdmg*2 + Edmg*2 + Rdmg + iDmg > enemy.health then
						KillText[i] = 14
					elseif Qdmg*2 + Edmg*2 + Rdmg*3 + iDmg > enemy.health then
						KillText[i] = 15
					else
						KillText[i] = 16
					end 
				end 
			end 
		end 
	end

	function Anivia:LaneClear()

		jungleMinions:update()
		for i, jungleMinion in pairs(jungleMinions.objects) do
			if jungleMinion ~= nil and not jungleMinion.dead then
				if Param.Jungle.UseE and GetDistance(jungleMinion) < SkillE.range and myHero:CanUseSpell(_E) == READY then
					if not self:ManaManager("Jungle", "E") then
						self:LogicE(jungleMinion);
					end
				end
				if Param.Jungle.UseR and GetDistance(jungleMinion) < SkillR.range and myHero:CanUseSpell(_R) == READY then 
					if not self:ManaManager("Jungle", "R") then
						if RMissile == nil then
							if Param.Pred.n1 == 1 then
								CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(jungleMinion, SkillR.delay, SkillR.width, SkillR.range, SkillR.speed, myHero, false);
								if HitChance >= 2 then
									CastSpell(_R, CastPosition.x, CastPosition.z);
								end
							elseif Param.Pred.n1 == 2 then
								local CastPosition, HitChance = HPred:GetPredict(HP_R, jungleMinion, myHero);
								if HitChance >= 1 then
									CastSpell(_R, CastPosition.x, CastPosition.z);
								end
							end
						end
					end
				end
				if Param.Jungle.UseQ and GetDistance(jungleMinion) < SkillQ.range and myHero:CanUseSpell(_Q) == READY then
					if not self:ManaManager("Jungle", "Q") then
						if QMissile ~= nil then return end
						if Param.Pred.n1 == 1 then
							CastPosition,  HitChance,  Position = VP:GetLineCastPosition(minion, SkillQ.delay, SkillQ.width, SkillQ.range, SkillQ.speed, myHero, false);
							if HitChance >= 2 then
								CastSpell(_Q, CastPosition.x, CastPosition.z);
							end
						elseif Param.Pred.n1 == 2 then
							local CastPosition, HitChance = HPred:GetPredict(HP_Q, minion, myHero);
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
			if ValidTarget(minion) and minion ~= nil and not minion.dead then
				if Param.WaveClear.UseQ and GetDistance(minion) < SkillQ.range and myHero:CanUseSpell(_Q) == READY then
					if not self:ManaManager("WaveClear", "Q") then
						local BestPos, BestHit = self:GetBestCircularFarmPosition(SkillQ.range, 200, enemyMinions.objects)
						if BestPos ~= nil and BestHit > 0 then
							CastSpell(_Q, BestPos.x, BestPos.z);
							Timing = GetDistance(Vector(BestPos), Vector(myHero)) / 850;
							DelayAction(function()
								CastSpell(_Q);
							end, Timing)
						end
					end
				end
				if Param.WaveClear.UseE and GetDistance(minion) <= SkillE.range and myHero:CanUseSpell(_E) == READY then
					if not self:ManaManager("WaveClear", "E") then
						self:LogicE(minion);
					end
				end
				if Param.WaveClear.UseR and GetDistance(minion) <= SkillR.range and myHero:CanUseSpell(_R) == READY then
					if not self:ManaManager("WaveClear", "R") then
						local BestPos, BestHit = self:GetBestCircularFarmPosition(SkillR.range, SkillR.width, enemyMinions.objects)
						if BestPos ~= nil and BestHit > 2 then
							CastSpell(_R, BestPos.x, BestPos.z);
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

	function Anivia:ManaManager(Mode, Spell)
		local String = "Param."..""..Mode..".Mana"..Spell..""
		if myHero.mana < (myHero.maxMana * (self:Mv(String) / 100)) then
			return true
		else
			return false
		end
	end

	function Anivia:Mv(String)
		
		return string.byte(String)
	end

	function Anivia:Harass()

		if Target ~= nil then
			if ValidTarget(Target) and Target.type == myHero.type then
				if myHero:CanUseSpell(_Q) == READY and Param.Harass.UseQ and not self:ManaManager("Harass", "Q") then 
			  		self:LogicQ(Target);
				end
				if myHero:CanUseSpell(_E) == READY and Param.Harass.UseE and not self:ManaManager("Harass", "E") then 
			 		self:LogicE(Target);
				end
				if myHero:CanUseSpell(_R) == READY and Param.Harass.UseR and not self:ManaManager("Harass", "R") then
					self:LogicR(Target);
				end
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

	function Anivia:LastHit()
		if Param.Draw.Misc.PermaShow then
			CustomPermaShow("Current Mode :", ""..CurrentMode, true, ARGB(255,52,73,94), nil, nil, 1);
		else
			CustomPermaShow("Current Mode :", ""..CurrentMode, false, ARGB(255,52,73,94), nil, nil, 1);
		end
		if CurrentMode ~= "LastHit" then
			CurrentMode = "LastHit";
		end
	end

	function Anivia:ExpTP()
		if Param.Exp.Egg.Enable then
			if (myHero.health*100)/myHero.maxHealth < Param.Exp.Egg.HP then
				if self:E() and self:E2() then
					if os.clock() - lastTP > ActualTPTime then
						local turrets = GetTurrets();
						local targetTurret = nil;
						for _, turret in pairs(turrets) do
							if turret ~= nil and turret.team == player.team then
								if targetTurret == nil then 
									targetTurret = turret.object 
								end
								if turret.object.attackSpeed == 9 then
									targetTurret = turret.object;
								end
							end
						end
					if targetTurret ~= nil then
						ActualTPTime = 300;
						lastTP = os.clock();
						CastSpell(Teleport, targetTurret);
						end 
					end
				end
			end
		end
	end

	function Anivia:E()
		if TargetHaveBuff("rebirthready", myHero) then
			return true;
		else 
			return false;
		end
	end

	function Anivia:E2()
		local count = 0;
		for k, unit in ipairs(GetEnemyHeroes()) do
			if GetDistance(unit) < 1000 then
				count = count + 1;
			end
		end
		if count > 0 then
			return true
		else
			return false
		end
	end

	function Anivia:GetTarget()
		ts:update();
		if ValidTarget(ts.target) and ts.target.type == myHero.type then
			return ts.target;
		else
			return nil;
		end
	end

	function Anivia:Menu()

		Param = scriptConfig("[Baguette] Anivia", "BaguetteAniva");

		Param:addSubMenu("Combo Settings", "Combo")
			Param.Combo:addParam("UseQ", "Use (Q) Spell in Combo :" , SCRIPT_PARAM_ONOFF, true);
			Param.Combo:addParam("UseE", "Use (E) Spell in Combo :" , SCRIPT_PARAM_ONOFF, true);
			Param.Combo:addParam("UseR", "Use (R) Spell in Combo :" , SCRIPT_PARAM_ONOFF, true);

		Param:addSubMenu("Harass Settings", "Harass");
			Param.Harass:addParam("UseQ", "Use (Q) Spell in Harass :" , SCRIPT_PARAM_ONOFF, true);
			Param.Harass:addParam("ManaQ", "Set a value for (Q) in Mana :", SCRIPT_PARAM_SLICE, 40, 0, 100);
			Param.Harass:addParam("UseE", "Use (E) Spell in Harass :" , SCRIPT_PARAM_ONOFF, true);
			Param.Harass:addParam("ManaE", "Set a value for (E) in Mana :", SCRIPT_PARAM_SLICE, 60, 0, 100);
			Param.Harass:addParam("UseR", "Use (R) Spell in Harass :" , SCRIPT_PARAM_ONOFF, true);
			Param.Harass:addParam("ManaR", "Set a value for (R) in Mana :", SCRIPT_PARAM_SLICE, 50, 0, 100);

		Param:addSubMenu("KillSteal Settings", "KillSteal");
			Param.KillSteal:addParam("Enable", "Use KillSteal :", SCRIPT_PARAM_ONOFF, true);
			Param.KillSteal:addParam("n1", "", SCRIPT_PARAM_INFO, "");
			Param.KillSteal:addParam("UseQ", "Use (Q) Spell in KillSteal :", SCRIPT_PARAM_ONOFF, true);
			Param.KillSteal:addParam("UseE", "Use (E) Spell in KillSteal :", SCRIPT_PARAM_ONOFF, true);
			Param.KillSteal:addParam("UseR", "Use (R) Spell in KillSteal :", SCRIPT_PARAM_ONOFF, true);
			if Ignite then Param.KillSteal:addParam("UseIgnite", "Use (Ignite) Spell in KillSteal :", SCRIPT_PARAM_ONOFF, true); end

		Param:addSubMenu("", "n1");

		Param:addSubMenu("WaveClear Settings", "WaveClear");
			Param.WaveClear:addParam("UseQ", "Use (Q) Spell in WaveClear :" , SCRIPT_PARAM_ONOFF, true);
			Param.WaveClear:addParam("ManaQ", "Set a value for (Q) in Mana :", SCRIPT_PARAM_SLICE, 60, 0, 100);
			Param.WaveClear:addParam("UseE", "Use (E) Spell in WaveClear :" , SCRIPT_PARAM_ONOFF, false);
			Param.WaveClear:addParam("ManaE", "Set a value for (E) in Mana :", SCRIPT_PARAM_SLICE, 80, 0, 100);
			Param.WaveClear:addParam("UseR", "Use (R) Spell in WaveClear :" , SCRIPT_PARAM_ONOFF, false);
			Param.WaveClear:addParam("ManaR", "Set a value for (R) in Mana :", SCRIPT_PARAM_SLICE, 70, 0, 100);

		Param:addSubMenu("Jungle Settings", "Jungle");
			Param.Jungle:addParam("UseQ", "Use (Q) Spell in JungleClear :" , SCRIPT_PARAM_ONOFF, true);
			Param.Jungle:addParam("ManaQ", "Set a value for (Q) in Mana :", SCRIPT_PARAM_SLICE, 40, 0, 100);
			Param.Jungle:addParam("UseE", "Use (E) Spell in JungleClear :" , SCRIPT_PARAM_ONOFF, true);
			Param.Jungle:addParam("ManaE", "Set a value for (E) in Mana :", SCRIPT_PARAM_SLICE, 60, 0, 100);
			Param.Jungle:addParam("UseR", "Use (R) Spell in JungleClear :" , SCRIPT_PARAM_ONOFF, true);
			Param.Jungle:addParam("ManaR", "Set a value for (R) in Mana :", SCRIPT_PARAM_SLICE, 50, 0, 100);

		Param:addSubMenu("", "n2");

		Param:addSubMenu("Draw", "Draw");

			Param.Draw:addSubMenu("Spell Settings", "Spell");
				Param.Draw.Spell:addParam("Q", "Display (Q) Range :", SCRIPT_PARAM_ONOFF, false);
				Param.Draw.Spell:addParam("W", "Display (W) Range :", SCRIPT_PARAM_ONOFF, false);
				Param.Draw.Spell:addParam("E", "Display (E) Range :", SCRIPT_PARAM_ONOFF, false);
				Param.Draw.Spell:addParam("R", "Display (R) Range :", SCRIPT_PARAM_ONOFF, false);
				Param.Draw.Spell:addParam("n1", "", SCRIPT_PARAM_INFO, "");
				Param.Draw.Spell:addParam("AA", "Display Auto Attack Range :", SCRIPT_PARAM_ONOFF, false);
				Param.Draw.Spell:addParam("QT", "Display (Q) Traveling :", SCRIPT_PARAM_ONOFF, false);
				Param.Draw.Spell:addParam("Egg", "Display EggTimer :", SCRIPT_PARAM_ONOFF, false);

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
				Param.Draw.Skin:addParam("skins", 'Which Skin :', SCRIPT_PARAM_LIST, 2, {"Classic", "Team Spirit", "Bird of Prey", "Noxus Hunter", "Hextech", "Blackfrost", "Prehistoric"});
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

		Param:addSubMenu("Miscellaneous", "Misc");

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
					Param.Misc.LVL:addParam("Combo", "LVL Spell Order :", SCRIPT_PARAM_LIST, 2, {"Q > E > W > E (Max E)", "Q > E > E > W (Max E)"});
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

			Param.Misc:addSubMenu("Spell Settings", "Spell");
				Param.Misc.Spell:addParam("AutoR", "Auto disable Ulti if nothing in :", SCRIPT_PARAM_ONOFF, true);
				Param.Misc.Spell:addParam("WintoR", "Cast (W) into (R) :", SCRIPT_PARAM_ONOFF, true);

			Param.Misc:addSubMenu("Interrupt Settings", "Interrupt");
				Param.Misc.Interrupt:addSubMenu("Enable", "Use Auto Interrupt :", SCRIPT_PARAM_ONOFF, true);

			Param.Misc:addSubMenu("GapCloser Settings", "Gap");
				Param.Misc.Gap:addParam("Enable", "Use GapCloser :", SCRIPT_PARAM_ONOFF, true);
				Param.Misc.Gap:addParam("n1", "", SCRIPT_PARAM_INFO, "");
				Param.Misc.Gap:addParam("UseE", "Use (E) in GapClosing :", SCRIPT_PARAM_ONOFF, true);
				Param.Misc.Gap:addParam("UseR", "Use (R) in GapClosing :", SCRIPT_PARAM_ONOFF, true);
				Param.Misc.Gap:addParam("n2", "", SCRIPT_PARAM_INFO, "");
				Param.Misc.Gap:addParam("n3", "- (Q) Is used by default.", SCRIPT_PARAM_INFO, true);

		Param:addSubMenu("Exploits", "Exp");
			if Teleport then
				Param.Exp:addSubMenu("Teleportation", "Egg");
					Param.Exp.Egg:addParam("Enable", "Enable Egg Teleport Exploit :", SCRIPT_PARAM_ONOFF, false);
					Param.Exp.Egg:addParam("n1", "", SCRIPT_PARAM_INFO, "");
					Param.Exp.Egg:addParam("HP", "Set a value in %HP :", SCRIPT_PARAM_SLICE, 25, 0, 100);
			end

		Param:addSubMenu("", "n3");

		Param:addSubMenu("Orbwalker", "Orb");
			Param.Orb:addParam("n1", "OrbWalker :", SCRIPT_PARAM_LIST, 3, {"SxOrbWalk", "BigFat OrbWalker", "Nebelwolfi's Orb Walker"});
			Param.Orb:addParam("n2", "If you want to change OrbWalker,", SCRIPT_PARAM_INFO, "");
			Param.Orb:addParam("n3", "Then, change it and press double F9.", SCRIPT_PARAM_INFO, "");
			Param.Orb:addParam("n4", "", SCRIPT_PARAM_INFO, "");
			Param.Orb:addParam("n5", "=> SAC:R & Pewalk are automaticly loaded.", SCRIPT_PARAM_INFO, "");
			Param.Orb:addParam("n6", "=> Enable one of them in BoLStudio", SCRIPT_PARAM_INFO, "");

		Param:addSubMenu("Prediction", "Pred");
			Param.Pred:addParam("n1", "Pred", SCRIPT_PARAM_LIST, 1, {"VPrediction", "HPrediction"});
			Param.Pred:setCallback("n1", function(Pred)
				if Pred then
					self:PredLoader();
				else
					self:PredLoader();
				end
			end);
	end

	function Anivia:Nothing()
		if CurrentMode ~= "None" then
			CurrentMode = "None"
			CustomPermaShow("Current Mode :", ""..CurrentMode, true, ARGB(255,52,73,94), nil, nil, 1)
		end
	end

	function Anivia:Immune(unit)
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

	function Anivia:Keys()
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
	end

	function Anivia:PriorityOnLoad()
	    if heroManager.iCount < 10 then
			self:Alerte("Impossible to Arrange Priority Table.. There is not enough champions... (less than 10)");
	    else
	        self:arrangePrioritys();
	    end
	end

	function Anivia:ProSpell(unit, spell)
		if Param.Misc.Interrupt then
			if unit.team ~= myHero.team then
		   	 	if isAChampToInterrupt[spell.name] and GetDistance(unit) <= SkillW.range then
		   	 		if not unit.dead then
		   	 			if myHero:CanUseSpell(_W) == READY then
		       	 			CastSpell(_W, unit.x, unit.z);
		       	 		end
		       	 	end
		    	end
		    end
		end
		if Param.Misc.Gap.Enable and myHero:CanUseSpell(_Q) == READY then
		    if unit.team ~= myHero.team then
		    	if spell.name == "ZedR" and spell.target and spell.target.networkID == myHero.networkID then
		    		if myHero:CanUseSpell(_R) == READY and myHero.mana > 300 and not RMissile ~= nil and Param.Misc.Gap.UseR then
		    			CastSpell(_R, myHero.x, myHero.z);
		    		end
		    		if myHero:CanUseSpell(_Q) == READY then
		    			DelayAction(function()
		    				if not unit.dead then
		    					CastSpell(_Q, myHero.x-50, myHero.z-50);
		    				end
		    			end, .8);
		    		end
		    		if myHero:CanUseSpell(_E) == READY and Param.Misc.Gap.UseE then
		    			DelayAction(function()
		    				if not unit.dead then
		    					CastSpell(_E, unit);
		    				end
		    			end, 1);
		    		end
		    	end
		        if isAGapcloserUnitTarget[spell.name] and not spell.name == "ZedR" then
		            if spell.target and spell.target.networkID == myHero.networkID then
		            	if Param.Misc.Gap.UseR and myHero:CanUseSpell(_R) == READY and not RMissile ~= nil then
		            		CastSpell(_R, myHero.x, myHero.z);
		            	end
		            	DelayAction(function()
		            		if not unit.dead then
		            			CastSpell(_Q, unit);
		            		end
		            	end, .05);
		            	DelayAction(function()
			            	if Param.Misc.Gap.UseE and myHero:CanUseSpell(_E) == READY then
			            		if not unit.dead then
			            			CastSpell(_E, unit);
			            		end
			            	end
			            end, .25);
		            end
		        end
		        if isAGapcloserUnitNoTarget[spell.name] and GetDistance(unit) <= SKillQ.range and (spell.target == nil or (spell.target and spell.target.isMe)) and not spell.name == "ZedR" then
		        	if Param.Misc.Gap.UseR and myHero:CanUseSpell(_R) == READY and not RMissile ~= nil then
		        		LogicR(unit);
		        	end
		        	DelayAction(function()
		        		LogicQ(unit);
		        	end, .05);
		        	DelayAction(function()
		        		if Param.Misc.Gap.UseQ and myHero:CanUseSpell(_E) == READY then
		        			if not unit.dead then
		        				CastSpell(_E, unit);
		        			end
		        		end
		        	end, .25);
		       	end
		    end
		end
	end

	function Anivia:OnDraw()
		if not myHero.dead and not Param.Draw.Disable then
			if myHero:CanUseSpell(_Q) == READY and Param.Draw.Spell.Q then 
				DrawCircle3D(myHero.x, myHero.y, myHero.z, SkillQ.range, 1, 0xFFFFFFFF);
			end
			if myHero:CanUseSpell(_W) == READY and Param.Draw.Spell.W then 
				DrawCircle3D(myHero.x, myHero.y, myHero.z, SkillW.range, 1, 0xFFFFFFFF);
			end
			if myHero:CanUseSpell(_E) == READY and Param.Draw.Spell.E then 
				DrawCircle3D(myHero.x, myHero.y, myHero.z, SkillE.range, 1, 0xFFFFFFFF);
			end
			if myHero:CanUseSpell(_R) == READY and Param.Draw.Spell.R then
				DrawCircle3D(myHero.x, myHero.y, myHero.z, SkillR.range, 1, 0xFFFFFFFF);
			end
			if Param.Draw.Spell.AA then
				DrawCircle3D(myHero.x, myHero.y, myHero.z, myHero.range+myHero.boundingRadius, 1, 0xFFFFFFFF)
			end
			if Param.Draw.Misc.HitBox then
				DrawCircle3D(myHero.x, myHero.y, myHero.z, myHero.boundingRadius, 1, 0xFFFFFFFF);
			end
			if Param.Draw.Spell.Egg and OeufTimerDraw == 1 then
				DrawText3D("REBIRTH :"..math.round(startTime - os.clock(), 2).."s", myHero.x-100, myHero.y-50, myHero.z, 20, 0xFFFFFFFF);
			end
			if Target ~= nil and ValidTarget(Target) then
				if Param.Draw.Misc.Target then
					DrawText3D(">> TARGET <<",Target.x-100, Target.y-50, Target.z, 20, 0xFFFFFFFF);
					DrawText(""..Target.charName.."", 50, 50, 200, 0xFFFFFFFF);
				end
			end
			if Param.Draw.Spell.QT then
				if QMissile ~= nil then
					local Vec2 = Vector(QMissile.pos) + (Vector(myHero.pos) - Vector(QMissile.pos)):normalized();
					DrawCircle3D(Vec2.x, Vec2.y, Vec2.z, 200, 1, 0xFFFFFFFF);
				end
			end

			if Param.Draw.Damages.Bar then
				for _, unit in pairs(GetEnemyHeroes()) do
					if unit ~= nil and GetDistance(unit) < 3000 then
						local Center = GetUnitHPBarPos(unit)
						Qdmg = ((myHero:CanUseSpell(_Q) == READY and myHero:CalcMagicDamage(unit,damageQ)) or 0)
						Edmg = ((myHero:CanUseSpell(_E) == READY and myHero:CalcMagicDamage(unit,damageE)) or 0)
						Rdmg = ((myHero:CanUseSpell(_R) == READY and myHero:CalcMagicDamage(unit,damageR)) or 0)
						local Y3QER = Qdmg*2 + Edmg*2 + Rdmg*2
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
		end
	end

	function Anivia:PredLoader()
		if Param.Pred.n1 == 1 then
			self:LoadVPred();
		elseif Param.Pred.n1 == 2 then
			self:LoadHPred();
		end
	end

	function Anivia:PermaShow()
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

	function Anivia:SetPriority(table, hero, priority)
		for i=1, #table, 1 do
			if hero.charName:find(table[i]) ~= nil then
				TS_SetHeroPriority(priority, hero.charName);
			end
		end
	end

	function Anivia:Remove(unit, buff)
		if buff and unit and buff.name == "recall" and unit.isMe then
			if myHero.level >= 9 then
				if Param.Misc.Buy.BlueTrinket then
					BuyItem(3363);
				end
			end
		end
		if unit and unit.valid and unit.isMe and buff and buff.name == "rebirthready" then
			startTime = os.clock() + 6
			OeufTimerDraw = 1
			DelayAction(function() OeufTimerDraw = 0 end, 6)
		end
	end

	function Anivia:Skills()
		SkillQ = { name = "Flash Frost", range = 1100, delay = .25, speed = 850, width = 150, ready = false }
		SkillW = { name = "Crystallize", range = 1000, delay = .25, speed = math.huge, width = 100, ready = false }
		SkillE = { name = "Frostbite", range = 600, delay = .25, speed = 1600, width = nil, ready = false }
		SkillR = { name = "Glacial Storm", range = 750, delay = .25, speed = math.huge, width = 200, ready = false }
	end

	function Anivia:Tables()

		isABuff = {
			[1]=false,
			[2]=false,
			[3]=false,
			[4]=false,
			[5]=true,
			[6]=false,
			[7]=true,
			[8]=true,
			[9]=true,
			[10]=false,
			[11]=false,
			[12]=false,
			[13]=false,
			[14]=false,
			[15]=false,
			[16]=false,
			[17]=false,
			[18]=false,
			[19]=false,
			[20]=true,
			[21]=true,
			[22]=false,
			[23]=true,
			[24]=true,
			[25]=false,
			[26]=false,
			[27]=false,
			[28]=false,
			[29]=true,
			[30]=false,
			[31]=false
		}

	    isAGapcloserUnitTarget = {
	        ['AkaliShadowDance']	= {true, Champ = 'Akali', 	spellKey = 'R'},
	        ['Headbutt']     	= {true, Champ = 'Alistar', 	spellKey = 'W'},
	        ['DianaTeleport']       	= {true, Champ = 'Diana', 	spellKey = 'R'},
	        ['IreliaGatotsu']     	= {true, Champ = 'Irelia',	spellKey = 'Q'},
	        ['JaxLeapStrike']         	= {true, Champ = 'Jax', 	spellKey = 'Q'},
	        ['JayceToTheSkies']       	= {true, Champ = 'Jayce',	spellKey = 'Q'},
	        ['MaokaiUnstableGrowth']    = {true, Champ = 'Maokai',	spellKey = 'W'},
	        ['MonkeyKingNimbus']  	= {true, Champ = 'MonkeyKing',	spellKey = 'E'},
	        ['Pantheon_LeapBash']   	= {true, Champ = 'Pantheon',	spellKey = 'W'},
	        ['PoppyHeroicCharge']       = {true, Champ = 'Poppy',	spellKey = 'E'},
	        ['QuinnE']       	= {true, Champ = 'Quinn',	spellKey = 'E'},
	        ['XenZhaoSweep']     	= {true, Champ = 'XinZhao',	spellKey = 'E'},
	        ['blindmonkqtwo']	    	= {true, Champ = 'LeeSin',	spellKey = 'Q'},
	        ['FizzPiercingStrike']	    = {true, Champ = 'Fizz',	spellKey = 'Q'},
	        ['RengarLeap']	    	= {true, Champ = 'Rengar',	spellKey = 'Q/R'},
	        ['YasuoDashWrapper']	    = {true, Champ = 'Yasuo',	spellKey = 'E'},
	    }

	    isAGapcloserUnitNoTarget = {
	        ['AatroxQ']	= {true, Champ = 'Aatrox', 	range = 1000,  	projSpeed = 1200, spellKey = 'Q'},
	        ['GragasE']	= {true, Champ = 'Gragas', 	range = 600,   	projSpeed = 2000, spellKey = 'E'},
	        ['GravesMove']	= {true, Champ = 'Graves', 	range = 425,   	projSpeed = 2000, spellKey = 'E'},
	        ['HecarimUlt']	= {true, Champ = 'Hecarim', 	range = 1000,   projSpeed = 1200, spellKey = 'R'},
	        ['JarvanIVDragonStrike']	= {true, Champ = 'JarvanIV',	range = 770,   	projSpeed = 2000, spellKey = 'Q'},
	        ['JarvanIVCataclysm']	= {true, Champ = 'JarvanIV', 	range = 650,   	projSpeed = 2000, spellKey = 'R'},
	        ['KhazixE']	= {true, Champ = 'Khazix', 	range = 900,   	projSpeed = 2000, spellKey = 'E'},
	        ['khazixelong']	= {true, Champ = 'Khazix', 	range = 900,   	projSpeed = 2000, spellKey = 'E'},
	        ['LeblancSlide']	= {true, Champ = 'Leblanc', 	range = 600,   	projSpeed = 2000, spellKey = 'W'},
	        ['LeblancSlideM']	= {true, Champ = 'Leblanc', 	range = 600,   	projSpeed = 2000, spellKey = 'WMimic'},
	        ['LeonaZenithBlade']	= {true, Champ = 'Leona', 	range = 900,  	projSpeed = 2000, spellKey = 'E'},
	        ['UFSlash']	= {true, Champ = 'Malphite', 	range = 1000,  	projSpeed = 1800, spellKey = 'R'},
	        ['RenektonSliceAndDice']	= {true, Champ = 'Renekton', 	range = 450,  	projSpeed = 2000, spellKey = 'E'},
	        ['SejuaniArcticAssault']	= {true, Champ = 'Sejuani', 	range = 650,  	projSpeed = 2000, spellKey = 'Q'},
	        ['ShenShadowDash']	= {true, Champ = 'Shen', 	range = 575,  	projSpeed = 2000, spellKey = 'E'},
	        ['RocketJump']	= {true, Champ = 'Tristana', 	range = 900,  	projSpeed = 2000, spellKey = 'W'},
	        ['slashCast']	= {true, Champ = 'Tryndamere', 	range = 650,  	projSpeed = 1450, spellKey = 'E'},
	    }

	    isAChampToInterrupt = {
	        ['KatarinaR']	= {true, Champ = 'Katarina',	spellKey = 'R'},
	        ['GalioIdolOfDurand']	= {true, Champ = 'Galio',	spellKey = 'R'},
	        ['Crowstorm']	= {true, Champ = 'FiddleSticks',spellKey = 'R'},
	        ['Drain']	= {true, Champ = 'FiddleSticks',spellKey = 'W'},
	        ['AbsoluteZero']	= {true, Champ = 'Nunu',	spellKey = 'R'},
	        ['ShenStandUnited']	= {true, Champ = 'Shen',	spellKey = 'R'},
	        ['UrgotSwap2']	= {true, Champ = 'Urgot',	spellKey = 'R'},
	        ['AlZaharNetherGrasp']	= {true, Champ = 'Malzahar',	spellKey = 'R'},
	        ['FallenOne']	= {true, Champ = 'Karthus',	spellKey = 'R'},
	        ['Pantheon_GrandSkyfall_Jump']	= {true, Champ = 'Pantheon',	spellKey = 'R'},
	        ['VarusQ']	= {true, Champ = 'Varus',	spellKey = 'Q'},
	        ['CaitlynAceintheHole']	= {true, Champ = 'Caitlyn',	spellKey = 'R'},
	        ['MissFortuneBulletTime']	= {true, Champ = 'MissFortune',	spellKey = 'R'},
	        ['InfiniteDuress']	= {true, Champ = 'Warwick',	spellKey = 'R'},
	        ['LucianR']	= {true, Champ = 'Lucian',	spellKey = 'R'}
	    }
	end

	function Anivia:Unload()

		self:Alerte("Unloaded. There is no bird anymore between us... Ciao!");
		if Param.Draw.Skin.Enable then
			SetSkin(myHero, -1);
		end
	end

	function Anivia:Usepot()
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

	function Anivia:Update()
		if AUTOUPDATE then
			local ServerData = GetWebResult(UPDATE_HOST, "/spyk1/BoL/master/BaguetteAnivia/BaguetteAnivia.version")
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

	function Anivia:ValidR()
		local TargetCount = 0
		for i = 1, heroManager.iCount, 1 do
			local hero = heroManager:GetHero(i)
			if hero.team ~= myHero.team and ValidTarget(hero) then
				if GetDistance(hero, RMissile) < 400 then
					TargetCount = TargetCount + 1
				end
			end
		end
		enemyMinions:update()
		for i, minion in pairs(enemyMinions.objects) do
			if ValidTarget(minion) and minion ~= nil and GetDistance(minion, RMissile) < 400 then
				TargetCount = TargetCount + 1
			end
		end
		jungleMinions:update()
		for i, jungleMinion in pairs(jungleMinions.objects) do
			if jungleMinion ~= nil and GetDistance(jungleMinion, RMissile) < 400 then
				TargetCount = TargetCount + 1
			end
		end
		if TargetCount > 0 then 
			return true 
		else 
			return false 
		end	
	end

	function Anivia:WintoR(unit)
		if Param.Misc.Spell.WintoR then
			if unit and unit.type == myHero.type and unit.team ~= myHero.team then
				if unit.hasMovePath and unit.path.count > 1 and RMissile and myHero:CanUseSpell(_W) == READY then
				local path = unit.path:Path(2)
					if GetDistance(path, RMissile) > 210 and GetDistance(unit, RMissile) < 175  then
					local p1 = Vector(unit) + (Vector(path) - Vector(unit)):normalized() * 0.6 * unit.ms
						if GetDistance(p1) < 1000 and GetDistance(RMissile, p1) > 150 and GetDistance(RMissile, p1) < 250 and GetDistance(unit, path) > GetDistance(unit, p1) then
							CastSpell(_W, p1.x, p1.z);
						end
					end
				end
			end
		end
	end

	function Anivia:LogicQ(unit)
		if QMissile ~= nil then return end
		if unit ~= nil and GetDistance(unit) < SkillQ.range and myHero:CanUseSpell(_Q) == READY and unit.visible and not unit.dead then
			if Param.Pred.n1 == 1 then
				CastPosition,  HitChance,  Position = VP:GetLineCastPosition(unit, SkillQ.delay, SkillQ.width, SkillQ.range, SkillQ.speed, myHero, false);
				if HitChance >= 2 then
					CastSpell(_Q, CastPosition.x, CastPosition.z);
				end
			elseif Param.Pred.n1 == 2 then
				local CastPosition, HitChance = HPred:GetPredict(HP_Q, unit, myHero);
	  			if HitChance >= 0 then
	    			CastSpell(_Q, CastPosition.x, CastPosition.z);
	  			end
			else
				self:Alertet("Cast(Q) bug???");
			end
		end
	end

	function Anivia:LogicW(unit)
		if unit ~= nil and GetDistance(unit) <= SkillW.range and myHero:CanUseSpell(_W) == READY and not unit.dead and unit.visible then
			if Param.Pred.n1 == 1 then
				CastPosition,  HitChance,  Position = VP:GetLineCastPosition(unit, SkillW.delay, SkillW.width, SkillW.range, SkillW.speed, myHero, false)
				if HitChance >= 2 then
					CastSpell(_W, CastPosition.x, CastPosition.z);
				end
			elseif Param.Pred.n1 == 2 then
		 		local Position, HitChance = HPred:GetPredict(HP_W, unit, myHero);
		  		if HitChance >= 1 then
		    		CastSpell(_W, Position.x, Position.z);
		  		end
			end
		end
	end

	function Anivia:LogicE(unit)
		if myHero:CanUseSpell(_E) == READY then
			if TargetHaveBuff("chilled", unit) then
				CastSpell(_E, unit);
			end
		end
	end

	function Anivia:LogicR(unit)
		if RMissile == nil then
			if unit ~= nil and GetDistance(unit) <= SkillR.range and myHero:CanUseSpell(_R) == READY and not unit.dead and unit.visible then
				if Param.Pred.n1 == 1 then
					CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(unit, SkillR.delay, SkillR.width, SkillR.range, SkillR.speed, myHero, false);
					if HitChance >= 2 then
						CastSpell(_R, CastPosition.x, CastPosition.z);
					end
				elseif Param.Pred.n1 == 2 then
					local CastPosition, HitChance = HPred:GetPredict(HP_R, unit, myHero);
					if HitChance >= 1 then
						CastSpell(_R, CastPosition.x, CastPosition.z);
					end
				end
			end
		end
	end

	function Anivia:FindBestCircle(target, range, radius)
		if Param.Pred.n1 == 1 then
			local points = {};
			
			local rgDsqr = (range + radius) * (range + radius);
			local diaDsqr = (radius * 2) * (radius * 2);

			local Position = VP:GetPredictedPos(target, 0.25);

			table.insert(points,Position);
			
			for i, enemy in ipairs(GetEnemyHeroes()) do
				if enemy.networkID ~= target.networkID and not enemy.dead and GetDistanceSqr(enemy) <= rgDsqr and GetDistanceSqr(target,enemy) < diaDsqr then
					local Position = VP:GetPredictedPos(enemy, 0.25);
					table.insert(points, Position);
				end
			end
			
			while true do
				local MECObject = MEC(points);
				local OurCircle = MECObject:Compute();
				
				if OurCircle.radius <= radius then
					return OurCircle.center, #points;
				end
				
				local Dist = -1;
				local MyPoint = points[1];
				local index = 0;
				
				for i=2, #points, 1 do
					local DistToTest = GetDistanceSqr(points[i], MyPoint);
					if DistToTest >= Dist then
						Dist = DistToTest;
						index = i;
					end
				end
				if index > 0 then
					table.remove(points, index);
				else
					return points[1], 1;
				end
			end
		end
	end

	function Anivia:AngleDifference(from, p1, p2)
		local p1Z = p1.z - from.z;
		local p1X = p1.x - from.x;
		local p1Angle = math.atan2(p1Z , p1X) * 180 / math.pi;
		
		local p2Z = p2.z - from.z;
		local p2X = p2.x - from.x;
		local p2Angle = math.atan2(p2Z , p2X) * 180 / math.pi;
		
		return math.sqrt((p1Angle - p2Angle) ^ 2);
	end

	function Anivia:PointsOfIntersection(A, B, C, R)
		local D, E, F, G = {}, {}, {}, {};

		LAB = math.sqrt((B.x-A.x)^ 2+(B.y-A.y)^ 2);
		D.x = (B.x-A.x)/LAB;
		D.y = (B.y-A.y)/LAB;
		t = D.x*(C.x-A.x) + D.y*(C.y-A.y);
		E.x = t*D.x+A.x;
		E.y = t*D.y+A.y;
		LEC = math.sqrt( (E.x-C.x)^ 2+(E.y-C.y)^ 2 );
		if LEC < R then
			dt = math.sqrt( R^ 2 - LEC^ 2);
			F.x = (t-dt)*D.x + A.x;
			F.y = (t-dt)*D.y + A.y;
			G.x = (t+dt)*D.x + A.x;
			G.y = (t+dt)*D.y + A.y;
		end
		
		return F, G;
	end

	function Anivia:LoadVPred()
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

	function Anivia:LoadHPred()
		if FileExist(LIB_PATH .. "/HPrediction.lua") then
			require("HPrediction");
			HPred = HPrediction();
			HP_Q = HPSkillshot({type = "DelayLine", delay = 0.250, range = 1075, width = 110, speed = 850});
			HP_W = HPSkillshot({type = "DelayLine", delay = 0.25, range = 1000, width = 100, speed = math.huge});
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

	function Anivia:LoadSACR()
		if _G.Reborn_Initialised then
		elseif _G.Reborn_Loaded then
		else
			DelayAction(function() self:Alerte("Failed to Load SAC:R")end, 7);
		end 
	end

	function Anivia:LoadPewalk()
		if _Pewalk then
		elseif not _Pewalk then
			self:Alerte("Pewalk loading error");
		end
	end

	function Anivia:LoadNEOrb()
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

	function Anivia:LoadSpikeLib()
		local LibPath = LIB_PATH.."SpikeLib.lua"
		if not FileExist(LibPath) then
			local Host = "raw.github.com";
			local Path = "/spyk1/BoL/master/bundle/SpikeLib.lua".."?rand="..math.random(1,10000);
			DownloadFile("https://"..Host..Path, LibPath, function ()  end);
			DelayAction(function() require("SpikeLib") end, 5);
		else
			require("SpikeLib");
		end
	end

	function Anivia:LoadBFOrb()
		local LibPath = LIB_PATH.."Big Fat Orbwalker.lua";
		local ScriptPath = SCRIPT_PATH.."Big Fat Orbwalker.lua";
			if not (FileExist(ScriptPath) and _G["BigFatOrb_Loaded"] == true) then
				local Host = "raw.github.com";
				local Path = "/BigFatNidalee/BoL-Releases/master/LimitedAccess/Big Fat Orbwalker.lua?rand="..math.random(1,10000);
				DownloadFile("https://"..Host..Path, LibPath, function ()  end);
			require "Big Fat Orbwalker";
		end
	end

	function Anivia:LoadSXOrb()
		if FileExist(LIB_PATH .. "/SxOrbWalk.lua") then
			require("SxOrbWalk")
			self:Alerte("Loaded SxOrbWalk")
			Param:addSubMenu("SxOrbWalk", "SXMenu")
			SxOrb:LoadToMenu(Param.SXMenu)
		else
			self:Alerte("Download a Fresh BoL Folder.")
		end
	end
