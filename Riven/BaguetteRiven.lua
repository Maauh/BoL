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
local version = "0.111";
local author = "spyk";
local SCRIPT_NAME = "BaguetteRiven";
local AUTOUPDATE = true;
local UPDATE_HOST = "raw.githubusercontent.com";
local UPDATE_PATH = "/spyk1/BoL/master/BaguetteRiven/BaguetteRiven.lua".."?rand="..math.random(1,10000);
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME;
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH;
local Last_LevelSpell = 0;
local CurrentMode = "";
local lastPotion = 0;
local ActualPotTime = 15;
local ActualPotName = "None";
local ActualPotData = "None";

if myHero.charName ~= "Riven" then return end

-- http://bol-tools.com/ tracker
assert(load(Base64Decode("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"), nil, "bt", _ENV))();
TrackerLoad("yWUSzAdF5gYudn3S");
-- http://bol-tools.com/ tracker

function OnLoad()

	Riven();
end

class 'Riven';

function Riven:__init()

	self:Update();
	self:Alerte("[Beta] Baguette Riven - by spyk, loading.");
end

function Riven:Alerte(msg)

	PrintChat("<b><font color=\"#2c3e50\">></font></b> </font><font color=\"#c5eff7\"> " .. msg .. "</font>");
end

function Riven:AutoBuy()
	if Param.Misc.Buy.Enable then
		if VIP_USER and GetGameTimer() < 200 then
			DelayAction(function()
				if Param.Misc.Buy.Trinket then
					BuyItem(3340);
				end
				DelayAction(function()
					if Param.Misc.Buy.Doran and Param.Misc.Buy.Sword then
						self:Alerte("Wrong Buy Param - You can't buy doran & long sword.");
					else
						if Param.Misc.Buy.Doran then 
							BuyItem(1055);
							DelayAction(function()
								if Param.Misc.Buy.Pots then
									BuyItem(2003);
								end
							end, 1);
						end
						if Param.Misc.Buy.Sword then
							BuyItem(1036);
							DelayAction(function()
								if Param.Misc.Buy.Pots then
									for i=1,3 do
										BuyItem(2003);
									end
								end
							end, 1);
						end
					end
				end, 1);
			end, 1);
		end
	end
end

function Riven:AutoPotions()
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

function Riven:Usepot()
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

function Riven:AutoLVLCombo()
	if Param.Misc.LVL.Combo == 1 then
		levelSequence = {1,3,2,1,1,4,1,3,1,3,4,3,3,2,2,4,2,2}; -- Max RQEW Start Q>E>W
	elseif Param.Misc.LVL.Combo == 2 then
		levelSequence = {1,3,2,1,1,4,1,3,1,3,4,3,3,2,2,4,2,2}; -- Max RQEW Start Q>W>E
	elseif Param.Misc.LVL.Combo == 3 then
		levelSequence = {1,2,3,2,1,4,1,1,1,2,4,2,2,3,3,4,3,3}; -- Max RQWE Start Q>E>W
	elseif Param.Misc.LVL.Combo == 4 then
		levelSequence = {1,2,3,2,1,4,1,1,1,2,4,2,2,3,3,4,3,3}; -- Max RQWE Start Q>W>E
	else
		levelSequence = nil;
	end
end

function Riven:AutoLVLSpell()
	if VIP_USER and os.clock() - Last_LevelSpell > .5 then
		if Param.Misc.LVL.Enable then
			autoLevelSetSequence(levelSequence);
			Last_LevelSpell = os.clock();
		else
			autoLevelSetSequence(nil);
			Last_LevelSpell = os.clock()+10;
		end
	end
end

function Riven:CastQ(unit, distance, t)
	self.QT = unit;
	self.QT_Type = t;
	if ValidTarget(unit) then
		if self:Distance(unit) < 270 then
			self.QAA = true;
		elseif self:Distance(unit) > 270 then
			self.QAA = true;
		end
	end
end
	
function Riven:CastW(unit)
	if ValidTarget(unit) and self:D_Width(unit) > self:Distance(unit) then
		CastSpell(_W);
	end
end

function Riven:CastE(unit)
	Zeubi = unit or Target;
	if ValidTarget(Zeubi) then
		CastSpell(_E, Zeubi.x, Zeubi.z);
	end
end

function Riven:CastR(unit)
	local Target = unit or Target;
	if self.Ult == false then
		CastSpell(_R);
	else
		if Target ~= nil then
			CastSpell(_R, Target.x, Target.z);
		end
	end
end

function Riven:CastT(unit)
	if self:Distance(unit) < 350 then
		CastSpell(self.TiamatSlot);
	end
end

function Riven:CustomLoad()

	if myHero:GetSpellData(SUMMONER_1).name:lower():find("summonerflash") then 
		Flash = SUMMONER_1;
	elseif myHero:GetSpellData(SUMMONER_2).name:lower():find("summonerflash") then 
		Flash = SUMMONER_2;
	end
	if myHero:GetSpellData(SUMMONER_1).name:lower():find("summonerdot") then 
		Ignite = SUMMONER_1;
	elseif myHero:GetSpellData(SUMMONER_2).name:lower():find("summonerdot") then 
		Ignite = SUMMONER_2;
	end

	if _G.Reborn_Loaded ~= nil then
		self:LoadSACR();
	elseif _Pewalk then
		self:LoadPewalk();
	else
		self:LoadNEOrb();
	end

	self:LoadSpikeLib();
	self:Menu();
	self:AutoBuy();
	self:PermaShow();
	self.Ult = false;
	self.T_Q = 0;
	self.QAA = false;
	self.QReady = false;
	self.WReady = false;
	self.EReady = false;
	self.RReady = false;
	self.QT_Type = "";
	self.QT = nil;

	self.Last_Item_Check = 0;
	self.Tiamat = false;
	self.TiamatSlot = nil;
	self.TiamatReady = false;
	self.Told = 0;

	self.Started = false;
	self.Spyk = 1;
	self.Etape = 1;
	self.QAAC2 = true;
	self.QAAC3 = 0;

	if Param.Draw.Skin.Enable then 
		SetSkin(myHero, Param.Draw.Skin.skins-1);
	end

	if VIP_USER then
		self:AutoLVLCombo();
	end

	AddTickCallback(function()
		if not myHero.dead then
			Target = self:GetTarget();

			self:ComboStarted();
			self:Ready();
			self:Keys();
			self:Flee();
			self:AutoPotions();
			self:Item();
			if Ignite then
				self:KillSteal();
			end
			if VIP_USER then 
				self:AutoLVLSpell();
			end
		end
	end)

	AddDrawCallback(function()
		self:OnDraw();
	end)

	AddProcessAttackCallback(function(unit, spell)
		self:OnProcessAttack(unit, spell);
	end)

	AddAnimationCallback(function(unit, animation)
		self:Animation(unit, animation);
	end)

	AddUpdateBuffCallback(function(unit, buff)
		self:UpdBuff(unit, buff);
	end)

	AddRemoveBuffCallback(function(unit, buff)
		self:RmvBuff(unit, buff);
	end)

	AddUnloadCallback(function()
		self:Unload();
	end)
end

function Riven:Combo()

	if Target ~= nil then
		if self.Started == false then
			self.Etape = 1;
			if Param.Combo.Flash then
				self:FCombo();
			else
				if self:Distance(Target) < 300 and self.QReady == true and self.WReady == true and self.EReady == true and self.RReady == true and self.Ult == false then
					self:ComboInRange();
				else
					self:ComboOutRange();
				end
			end
		else
			self:ComboStarted();
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

function Riven:ComboOutRange()
	self.Spyk = 1;
	if self.QReady == true and self.WReady == false and self.EReady == false and self.RReady == false then
		if self:Distance(unit) < 350 then
			self:CastQ(Target, self:Distance(Target), "Combo");
		elseif self:Distance(unit) > 350 then
			CastSpell(_Q, Target.x, Target.z);
			self:SpykOP(Target);
		end
	end
	if self.QReady == true and self.WReady == false and self.EReady == false and self.RReady == true and self.Ult == true then
		if Target.health < self:D_R(Target) + self:D_Q(Target) + self:D_P(Target) then
			self:CastR(Target);
			self:CastQ(Target, self:Distance(Target), "Combo");
		else
			if self:Distance(unit) < 350 then
				self:CastQ(Target, self:Distance(Target), "Combo");
			elseif self:Distance(unit) > 350 then
				CastSpell(_Q, Target.x, Target.z);
				self:SpykOP(Target);
			end
		end
	end
	if self.QReady == true and self.WReady == false and self.EReady == true and self.RReady == false then
		if self:Distance(Target) > 325 and self:Distance(Target) < 580 then
			self:CastE(Target);
			if self.Tiamat == true and self.TiamatReady == true then
				self:CastT(Target);
			end
			self:CastQ(Target, self:Distance(Target), "Combo");
		end
	end
	if self.QReady == false and self.WReady == true and self.EReady == false and self.RReady == false and self.Tiamat == true and self.TiamatReady == true then
		self:CastW(Target);
		self:CastT(Target);
	end
	if self.QReady == false and self.WReady == true and self.EReady == true and self.RReady == false then
		self:CastE(Target);
		self:CastW(Target);
		if self.Tiamat == true and self.TiamatReady == true then
			self:CastT(Target);
		end
	end
	if self.QReady == false and self.WReady == false and self.EReady == true and self.RReady == true and ((self.Ult == true and Target.health < self:D_R(Target)) or (self.Ult == false and Target.health < self:D_R(Target) + self:D_P(Target) * 2)) then
		self:CastE(Target);
		if self.Tiamat == true and self.TiamatReady == true then
			self:CastT(Target);
		end
		self:CastR(Target);
	end
	if self.QReady == true and self.WReady == false and self.EReady == false and self.RReady == true and ((self.Ult == true and Target.health < self:D_R(Target) + self:D_Q(Target) + self:D_P(Target)) or (self.Ult == false and Target.health < self:D_R(Target) + self:D_Q(Target) * 2 + self:D_P(Target) * 4)) then
		self:CastR(Target)
		self:CastQ(Target, self:Distance(Target), "Combo");
	end
	if self.QReady == false and self.WReady == true and self.EReady == false and self.RReady == true and ((self.Ult == true and Target.health < self:D_R(Target) + self:D_W(Target) + self:D_P(Target)) or (self.Ult == false and Target.health < self:D_R(Target) + self:D_W(Target) + self:D_P(Target) * 4)) then
		self:CastR(Target);
		self:CastW(Target);
	end
	if self.QReady == false and self.WReady == false and self.EReady == false and self.RReady == true and self.Ult == true and Target.health < self:D_R(Target) then
		self:CastR(Target);
	end
	if self.QReady == true and self.WReady == true and self.EReady == false and self.RReady == false then
		self:CastE(Target);
		if self.Tiamat == true and self.TiamatReady == true then
			self:CastT(Target);
		end
		self:CastW(Target);
		self:CastQ(Target, self:Distance(Target), "Combo");
	end
	if self.QReady == true and self.WReady == true and self.EReady == true and self.RReady == true and ((self.Ult == true and Target.health < self:D_R(Target) + self:D_W(Target) + self:D_Q(Target) + self:D_P(Target) * 3) or (self.Ult == false)) then
		self:CastE(Target);
		self:CastR(Target);
		if self.Tiamat == true and self.TiamatReady == true then
			self:CastT(Target);
		end
		self:CastW(Target);
		self:CastQ(Target, self:Distance(Target), "Combo");
	end
	if self.QReady == true and self.WReady == true and self.EReady == true and self.RReady == true and self.Ult == true and Target.health > self:D_R(Target) + self:D_W(Target) + self:D_Q(Target) + self:D_P(Target) * 3 then
		self:CastE(Target);
		if self.Tiamat == true and self.TiamatReady == true then
			self:CastT(Target);
		end
		self:CastW(Target);
		self:CastQ(Target, self:Distance(Target), "Combo");
	end
	if self.QReady == true and self.WReady == false and self.EReady == true and self.RReady == true and ((self.Ult == true and Target.health < self:D_R(Target) + self:D_Q(Target) + self:D_P(Target) * 3) or (self.Ult == false)) then
		self:CastE(Target);
		if self.Tiamat == true and self.TiamatReady == true then
			self:CastT(Target);
		end
		self:CastR(Target);
		self:CastQ(Target, self:Distance(Target), "Combo");
	end
	if self.QReady == true and self.WReady == false and self.EReady == true and self.RReady == true and self.Ult == true and Target.health > self:D_R(Target) + self:D_Q(Target) + self:D_P(Target) * 3 then
		self:CastE(Target);
		if self.Tiamat == true and self.TiamatReady == true then
			self:CastT(Target);
		end
		self:CastQ(Target, self:Distance(Target), "Combo");
	end
	if self.QReady == true and self.WReady == true and self.EReady == true and self.RReady == false then 
		self:CastE(Target);
		if self.Tiamat == true and self.TiamatReady == true then
			self:CastT(Target);
		end
		self:CastQ(Target, self:Distance(Target), "Combo");
		self:CastW(Target);
	end
	if self.RReady == true and self.Ult == true and Target.health < self:D_R(Target) then
		CastSpell(_R, Target.x, Target.z);
	end
end

function Riven:ComboStarted()
	if self.Started == true then
		if self.Spyk == 2 then
			if self.Etape == 1 then
				if self.RReady == true then
					self.Etape = 2;
					self:CastR(Target)
				else
					self.Etape = 2;
				end
			elseif self.Etape == 2 then
				DelayAction(function()
					if self.WReady == true then
						self.Etape = 3;
						self:CastW(Target);
					else
						self.Etape = 3;
					end
				end, .05);
			elseif self.Etape == 3 then
				DelayAction(function()
					if self.Tiamat == true then
						self.Etape = 4;
						if self.TiamatReady == true then
							self:CastT(Target);
						end
					else
						self.Etape = 4;
					end
				end, .05);
			elseif self.Etape == 4 then
				if self.QReady == true then
					self.Etape = 5;
					self.QAA = true;
					self.QAAC2 = true;
				else
					self.Etape = 5;
				end
			elseif self.Etape == 5 then
				DelayAction(function()
					if self.EReady == true then
						self.Etape = 6;
						self:CastE(Target);
					else
						self.Etape = 6;
					end
				end, .05);
			elseif self.Etape == 6 then
				DelayAction(function()
					if self.QReady == true then
						self.Etape = 7;
						self.QAA = true;
						self.QAAC2 = true;
					else
						self.Etape = 7;
					end
				end, .05);
			elseif self.Etape == 7 then
				DelayAction(function()
					if self.RReady == true and self.Ult == true then
						self.Etape = 8;
						self:CastR(Target);
					else
						self.Etape = 8;
					end
				end, .05);
			elseif self.Etape == 8 then
				DelayAction(function()
					if self.QReady == true then
						self.Etape = 9;
						self.QAA = true;
						self.QAAC2 = true;
					else
						self.Etape = 9;
					end
				end, 05);
			elseif self.Etape == 9 then
				self.Etape = 1;
				self.Spyk = 1;
				self.Started = false;
			end
		elseif self.Spyk == 3 then
			if self.Etape == 1 then
				if self.EReady == true then
					self.Etape = 2;
					self:CastE(Target);
				else
					self.Etape = 2;
				end
			elseif self.Etape == 2 then
				if self.RReady == true then
					self.Etape = 3;
					self:CastR(Target);
				else
					self.Etape = 3;
				end
			elseif self.Etape == 3 then
				if self.FlashReady == true then
					self.Etape = 4;
					if self:Distance(Target) > 300 and self:Distance(Target) < 750 then
						CastSpell(Flash, Target.x, Target.z);
					elseif self:Distance(Target) > (self:D_Width(Target) + 425) then
						self.Etape = 1;
						self.Spyk = 1;
						self.Started = false;
						Param.Combo.Flash = false;
						self:Alerte("[F]Combo aborted, Target is too far.");
					end
				else
					self.Etape = 4;
				end
			elseif self.Etape == 4 then
				if self.QReady == true and self.WReady == true then
					self:CastW(Target);
					self:SpykOP(Target);
					if self.Tiamat == true and self.TiamatReady == true then
						self:CastT(Target);
						self:SpykOP(Target);
					end
					CastSpell(_Q, Target.x, Target.z);
					self:SpykOP(Target);
				elseif self.QReady == false and self.WReady == true then
					self.Etape = 5;
					self:CastW(Target);
					self:SpykOP(Target);
					if self.Tiamat == true and self.TiamatReady == true then
						self:CastT(Target);
					end
				else
					self.Etape = 5;
				end
			elseif self.Etape == 5 then
				if self.RReady == true and self.QReady == true then
					self.Etape = 6;
					self:CastR(Target);
					DelayAction(function()
						CastSpell(_Q, Target.x, Target.z);
						self:SpykOP(Target);
					end, .25);
				else
					self.Etape = 6;
				end
			elseif self.Etape == 6 then
				self.Etape = 1;
				self.Spyk = 1;
				self.Started = false;
				Param.Combo.Flash = false;
			end
		end
	end
end

function Riven:ComboInRange()
	if Param.Combo.UseQ and Param.Combo.UseW and Param.Combo.UseE and Param.Combo.UseR and Param.Combo.UseT then
		if GetDistance(Target) < self:D_Width(Target) then
			if self.Ult == false then
				self.Started = true;
				self.Spyk = 2;
				self.Etape = 1;
			end
		end
	end
end

function Riven:FCombo()
	if self.QReady == true and self.WReady == true and self.EReady == true and self.RReady == true and self.FlashReady == true then
		if self:Distance(Target) < 325 + 425 then
			if self.Ult == false then
				self.Started = true;
				self.Spyk = 3;
				self.Etape = 1;
			end
		end
	end
end

function Riven:CheckingQ(mode)
	if mode == "Combo" then
		if Param.Combo.UseQ then
			return true
		else 
			return false
		end
	elseif mode == "LaneClear" then
		if self.QT_Type == "JungleClear" then
			if Param.JungleClear.UseQ then
				return true
			else
				return false
			end
		elseif self.QT_Type == "WaveClear" then
			if Param.WaveClear.UseQ then
				return true
			else
				return false
			end
		end
	elseif mode == "Harass" then
		if Param.Harass.UseQ then
			return true
		else 
			return false
		end
	end
end

function Riven:CheckingW(mode)
	if mode == "Combo" then
		if Param.Combo.UseW then
			return true
		else 
			return false
		end
	elseif mode == "LaneClear" then
		if self.QT_Type == "JungleClear" then
			if Param.JungleClear.UseW then
				return true
			else
				return false
			end
		elseif self.QT_Type == "WaveClear" then
			if Param.WaveClear.UseW then
				return true
			else
				return false
			end
		end
	elseif mode == "Harass" then
		if Param.Harass.UseW then
			return true
		else 
			return false
		end
	end
end

function Riven:CheckingE(mode)
	if mode == "Combo" then
		if Param.Combo.UseE then
			return true
		else 
			return false
		end
	elseif mode == "LaneClear" then
		if self.QT_Type == "JungleClear" then
			if Param.JungleClear.UseE then
				return true
			else
				return false
			end
		elseif self.QT_Type == "WaveClear" then
			if Param.WaveClear.UseE then
				return true
			else
				return false
			end
		end
	elseif mode == "Harass" then
		if Param.Harass.UseE then
			return true
		else 
			return false
		end
	end
end

function Riven:D_P(unit)
	local multi = 0;
	if myHero.level < 6 then
		multi = 25;
	else
		if myHero.level > 5 and myHero.level < 9 then
			multi = 30;
		elseif myHero.level > 8 and myHero.level < 12 then
			multi = 35;
		elseif myHero.level > 11 and myHero.level < 15 then
			multi = 40;
		elseif myHero.level > 14 and myHero.level < 18 then
			multi = 45;
		elseif myHero.level == 18 then
			multi = 50;
		end
	end
	local D_AA = myHero.totalDamage;
	local D_TA = (multi / 100) * myHero.totalDamage;
	local D_TOT = D_AA + D_TA;
	return D_TOT;
end

function Riven:D_Q(unit)
	local L = myHero:GetSpellData(_Q).level;
	local C_D = -10 + L * 20;
	local A_D = 35 + L * 5;
	local P_AD = myHero.totalDamage * (A_D / 100);
	return myHero:CalcDamage(unit, C_D + P_AD)
end

function Riven:D_W(unit)
	local L = myHero:GetSpellData(_W).level;
	local C_D = 20 + L * 30;
	local A_D = myHero.addDamage;
	return myHero:CalcDamage(unit, C_D + A_D)
end

function Riven:D_Width(unit)
	if unit == n then
		if self.Ult == true then
			return 330
		else
			return 265
		end
	else
		return 125 + myHero.boundingRadius + unit.boundingRadius
	end
end

function Riven:D_E()

	return 0
end

function Riven:D_Yo(unit)
	if self:D_Q(unit) > self:D_W(unit) then
		return self:D_Q(unit)
	else
		return self:D_W(unit)
	end
end

function Riven:S_E()
	local L = myHero:GetSpellData(_E).level;
	local C_D = 60 + L * 30;
	local A_D = myHero.addDamage;
	return C_D + A_D
end

function Riven:D_R(unit)
	local L = myHero:GetSpellData(_R).level;
	if L > 0 then
		local T_D = 0;
		local HPerc = 0;
		local ld = 40 * L + 40;
		local ld2 = ld + myHero.addDamage * .6;
		if 1 - unit.health / unit.maxHealth > .75 then
			T_D = ld2 * 3;
		else
			T_D = ld2 + ld2 * 2.65 * (1 - unit.health / unit.maxHealth);
		end
		return myHero:CalcDamage(unit, T_D)
	else
		return 0
	end
end

function Riven:Distance(unit, unit2)
	p1 = unit or Target;
	p2 = unit2 or myHero;
    return math.sqrt((p1.x - p2.x) ^ 2 + ((p1.z or p1.y) - (p2.z or p2.y)) ^ 2)
end

function Riven:Flee()
	if Param.Misc.Flee.Enable then
		myHero:MoveTo(mousePos.x, mousePos.z);
		if self.QReady == true and self.EReady == true then
			CastSpell(_E, mousePos.x, mousePos.z);
			DelayAction(function()
				CastSpell(_Q, mousePos.x, mousePos.z);
			end, 0.1);
		else
			if self.QReady == true then
				CastSpell(_Q, mousePos.x, mousePos.z);
			end
			if self.EReady == true then
				CastSpell(_E, mousePos.x, mousePos.z);
			end
		end
	end
end

function Riven:GetTarget()
	if _G.AutoCarry and _G.AutoCarry.Keys and _G.Reborn_Loaded ~= nil then
		t = _G.AutoCarry.Crosshair:GetTarget();
	elseif _Pewalk then
		t = _Pewalk.GetTarget();
	elseif _G.NebelwolfisOrbWalkerLoaded then
		t = _G.NebelwolfisOrbWalker:GetTarget();
	end
	if ValidTarget(t) and t.type == myHero.type then
		return t
	else
		return nil
	end
end

function Riven:Harass()
	if Param.Draw.Misc.PermaShow then
		CustomPermaShow("Current Mode :", ""..CurrentMode, true, ARGB(255,52,73,94), nil, nil, 1);
	else
		CustomPermaShow("Current Mode :", ""..CurrentMode, false, ARGB(255,52,73,94), nil, nil, 1);
	end
	if CurrentMode ~= "Harass" then
		CurrentMode = "Harass";
	end
end

function Riven:Item()
	if os.clock()-self.Last_Item_Check > 5 then
		self.Last_Item_Check = os.clock()
		for SLOT = ITEM_1, ITEM_6 do
			if GetInventoryHaveItem(3077) or GetInventoryHaveItem(3074) or GetInventoryHaveItem(3748) then
				self.Tiamat = true;
				if myHero:GetSpellData(SLOT).name == "ItemTiamatCleave" or myHero:GetSpellData(SLOT).name == "ItemTitanicHydraCleave" then
					if self.Told == 0 then
						self.TiamatSlot = SLOT;
						self:Alerte("[ITEM] Found Tiamat.");
						self.Told = 1;
					end
				end
			end
		end
	end
end

function Riven:JungleClear()
	jungleMinions:update()
	for i, unit in pairs(jungleMinions.objects) do
		local unit = unit;
		if self.QReady == true and self.WReady == true and self.EReady == true and self.TiamatReady == true and Param.JungleClear.UseQ and Param.JungleClear.UseW and Param.JungleClear.UseE and Param.JungleClear.UseT then
			self:CastE(unit);
			self:CastT(unit);
			DelayAction(function()
				self:CastW(unit);
				DelayAction(function()
					self:CastQ(unit, self:Distance(unit), "JungleClear");
				end, self:Time(self.T_Q));
			end, .15)
		elseif self.EReady == true and self.TiamatReady == true and (self.WReady == true or self.QReady == true) and Param.JungleClear.UseE and Param.JungleClear.UseT and Param.JungleClear.UseQ and Param.JungleClear.UseW then
			self:CastE(unit);
			self:CastT(unit);
			if self.WReady == true then
				self:CastW(unit);
			elseif self.QReady == true then
				self:CastQ(unit, self:Distance(unit), "JungleClear");
			end
		elseif (self.WReady == true or self.QReady == true) and self.TiamatReady == true and Param.JungleClear.UseW and Param.JungleClear.UseQ and Param.JungleClear.UseT then
			self:CastT(unit);
			if self.WReady == true then
				self:CastW(unit);
			elseif self.QReady == true then
				self:CastQ(unit, self:Distance(unit), "JungleClear");
			end
		elseif self.QReady == true and self.WReady == true and Param.JungleClear.UseQ and Param.JungleClear.UseW then
			self:CastQ(unit, self:Distance(unit), "JungleClear");
			DelayAction(function()
				self:CastW(unit);
			end, .1);
		elseif self.QReady == true and Param.JungleClear.UseQ then
			self:CastQ(unit, self:Distance(unit), "JungleClear");
		end
	end
end

function Riven:Keys()
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

function Riven:KillSteal()
	for i, unit in pairs(GetEnemyHeroes()) do
		if self:Distance(unit) <= 600 and myHero:CanUseSpell(Ignite) == READY then
			if (unit.health + unit.shield + 5) < 50 + (20 * myHero.level) then
				CastSpell(Ignite, unit);
			end
		end
	end
end

function Riven:LaneClear()

	self:JungleClear();
	self:WaveClear();

	if Param.Draw.Misc.PermaShow then
		CustomPermaShow("Current Mode :", ""..CurrentMode, true, ARGB(255,52,73,94), nil, nil, 1);
	else
		CustomPermaShow("Current Mode :", ""..CurrentMode, false, ARGB(255,52,73,94), nil, nil, 1);
	end
	if CurrentMode ~= "LaneClear" then
		CurrentMode = "LaneClear";
	end
end

function Riven:LastHit()

	enemyMinions:update()
	for i, unit in pairs(enemyMinions.objects) do
		local HP = unit.health;
		if unit.health < self:D_Yo(unit) then
			if Param.LastHit.UseQ and HP < self:D_Q(unit) then
				self:CastQ(unit, self:Distance(unit), "LastHit");
			elseif Param.LastHit.UseW and HP < self:D_W(unit) then
				self:CastW(unit);
			end
		end
	end

	jungleMinions:update()
	for i, unit in pairs(jungleMinions.objects) do
		local HP = unit.health;
		if unit.health < self:D_Yo(unit) then
			if Param.LastHit.UseQ and HP < self:D_Q(unit) then
				self:CastQ(unit, self:Distance(unit), "LastHit");
			elseif Param.LastHit.UseW and HP < self:D_W(unit) then
				self:CastW(unit);
			end
		end
	end

	if Param.Draw.Misc.PermaShow then
		CustomPermaShow("Current Mode :", ""..CurrentMode, true, ARGB(255,52,73,94), nil, nil, 1);
	else
		CustomPermaShow("Current Mode :", ""..CurrentMode, false, ARGB(255,52,73,94), nil, nil, 1);
	end
	if CurrentMode ~= "LastHit" then
		CurrentMode = "LastHit";
	end
end

function Riven:Menu()
	Param = scriptConfig("Baguette Riven", "BaguetteRiven");

	Param:addSubMenu("Combo Settings", "Combo");
		Param.Combo:addParam("UseQ", "Use (Q) Spell in Combo :", SCRIPT_PARAM_ONOFF, true);
		Param.Combo:addParam("UseW", "Use (W) Spell in Combo :", SCRIPT_PARAM_ONOFF, true);
		Param.Combo:addParam("UseE", "Use (E) Spell in Combo :", SCRIPT_PARAM_ONOFF, true);
		Param.Combo:addParam("UseR", "Use (R) Spell in Combo :", SCRIPT_PARAM_ONOFF, true);
		Param.Combo:addParam("n1", "", SCRIPT_PARAM_INFO, "");
		Param.Combo:addParam("UseT", "Use Tiamat for reset in Combo :", SCRIPT_PARAM_ONOFF, true);
		Param.Combo:addParam("n2", "", SCRIPT_PARAM_INFO, "");
		Param.Combo:addParam("Flash", "Set Combo to Flash Combo :", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("T"));
		Param.Combo:setCallback("Flash", function(AntiNoob)
			if AntiNoob then
				self.Spyk = 1;
				self.Etape = 1;
				self.Started = false;
			end
		end)

	Param:addSubMenu("", "n29");

	Param:addSubMenu("WaveClear Settings", "WaveClear");
		Param.WaveClear:addParam("UseQ", "Use (Q) Spell in WaveClear :", SCRIPT_PARAM_ONOFF, true);
		Param.WaveClear:addParam("UseW", "Use (W) Spell in WaveClear :", SCRIPT_PARAM_ONOFF, true);
		Param.WaveClear:addParam("UseE", "Use (E) Spell in WaveClear :", SCRIPT_PARAM_ONOFF, true);
		Param.WaveClear:addParam("n1", "", SCRIPT_PARAM_INFO, "");
		Param.WaveClear:addParam("UseT", "Use Tiamat for reset in WaveClear :", SCRIPT_PARAM_ONOFF, true);

	Param:addSubMenu("JungleClear Settings", "JungleClear");
		Param.JungleClear:addParam("UseQ", "Use (Q) Spell in JungleClear :", SCRIPT_PARAM_ONOFF, true);
		Param.JungleClear:addParam("UseW", "Use (W) Spell in JungleClear :", SCRIPT_PARAM_ONOFF, true);
		Param.JungleClear:addParam("UseE", "Use (E) Spell in JungleClear :", SCRIPT_PARAM_ONOFF, true);
		Param.JungleClear:addParam("n1", "", SCRIPT_PARAM_INFO, "");
		Param.JungleClear:addParam("UseT", "Use Tiamat for reset in JungleClear :", SCRIPT_PARAM_ONOFF, true);

	Param:addSubMenu("LastHit Settings", "LastHit");
		Param.LastHit:addParam("UseQ", "Use (Q) Spell in LastHit :", SCRIPT_PARAM_ONOFF, false);
		Param.LastHit:addParam("UseW", "Use (W) Spell in LastHit :", SCRIPT_PARAM_ONOFF, false);
		Param.LastHit:addParam("UseE", "Use (E) Spell in LastHit :", SCRIPT_PARAM_ONOFF, false);
		Param.LastHit:addParam("n1", "", SCRIPT_PARAM_INFO, "");
		Param.LastHit:addParam("UseT", "Use Tiamat for reset in LastHit :", SCRIPT_PARAM_ONOFF, false);

	Param:addSubMenu("", "n99");

	Param:addSubMenu("Draw", "Draw");

		Param.Draw:addSubMenu("Spell Settings", "Spell");
			Param.Draw.Spell:addParam("Q", "Display (Q) Range :", SCRIPT_PARAM_ONOFF, false);
			Param.Draw.Spell:addParam("W", "Display (W) Range :", SCRIPT_PARAM_ONOFF, false);
			Param.Draw.Spell:addParam("E", "Display (E) Range :", SCRIPT_PARAM_ONOFF, false);
			Param.Draw.Spell:addParam("R", "Display (R) Range :", SCRIPT_PARAM_ONOFF, false);
			Param.Draw.Spell:addParam("n1", "", SCRIPT_PARAM_INFO, "");
			Param.Draw.Spell:addParam("AA", "Display Auto Attack Range :", SCRIPT_PARAM_ONOFF, false);
			Param.Draw.Spell:addParam("n2", "", SCRIPT_PARAM_INFO, "");
			Param.Draw.Spell:addParam("F", "Display (F) Combo informations :", SCRIPT_PARAM_ONOFF, true);

		Param.Draw:addSubMenu("Damages Settings", "Damages");
			Param.Draw.Damages:addParam("Enable", "Enable damages APROX :", SCRIPT_PARAM_ONOFF, true);

		Param.Draw:addSubMenu("Skin Changer", "Skin");
			Param.Draw.Skin:addParam("Enable", "Enable Skin Changer :", SCRIPT_PARAM_ONOFF, false);
			Param.Draw.Skin:setCallback("Enable", function(SkinC)
				if SkinC then
					SetSkin(myHero, Param.Draw.Skin.skins-1);
				else
					SetSkin(myHero, -1);
				end
			end)
			Param.Draw.Skin:addParam("skins", "Set Skin :", SCRIPT_PARAM_LIST, 1, {"Classic", "Redeemed", "Crimson Elite", "Battle Bunny", "Championship", "Dragonblade", "Arcade"});
			Param.Draw.Skin:setCallback("skins", function(ChangeSkinC)
				if ChangeSkinC then
					if Param.Draw.Skin.Enable then
						SetSkin(myHero, Param.Draw.Skin.skins-1);
					end
				end
			end)

		Param.Draw:addSubMenu("Misc", "Misc");
			Param.Draw.Misc:addParam("PermaShow", "Draw PermaShow :", SCRIPT_PARAM_ONOFF, true);
			Param.Draw.Misc:setCallback("PermaShow", function(Perma)
				if Perma then
					self:PermaShow();
					self:Alerte("PermaShow enabled.");
				else
					self:PermaShow();
					self:Alerte("PermaShow disabled.");
				end
			end)
			Param.Draw.Misc:addParam("n1", "", SCRIPT_PARAM_INFO, "");
			Param.Draw.Misc:addParam("HitBox", "Draw HitBox :", SCRIPT_PARAM_ONOFF, true);
			Param.Draw.Misc:addParam("Target", "Draw Target :", SCRIPT_PARAM_ONOFF, true);
			Param.Draw:addParam("n1", "", SCRIPT_PARAM_INFO, "");
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
			Param.Misc.Buy:addParam("Doran", "Buy Doran Blade :", SCRIPT_PARAM_ONOFF, true);
			Param.Misc.Buy:addParam("Sword", "Buy a Long Sword :", SCRIPT_PARAM_ONOFF, false);
			Param.Misc.Buy:addParam("Pots", "Buy Potions :", SCRIPT_PARAM_ONOFF, true);
			Param.Misc.Buy:addParam("Trinket", "Buy Yellow Trinket :", SCRIPT_PARAM_ONOFF, true);
			Param.Misc.Buy:addParam("n2", "", SCRIPT_PARAM_INFO, "");
			Param.Misc.Buy:addParam("BlueTrinket", "Auto Upgrade Trinket (lvl.9) :", SCRIPT_PARAM_ONOFF, true);

		if VIP_USER then Param.Misc:addSubMenu("Auto LVL Spell", "LVL");
			Param.Misc.LVL:addParam("Enable", "Enable Auto Level Spell?", SCRIPT_PARAM_ONOFF, true);
			Param.Misc.LVL:addParam("Combo", "LVL Spell Order :", SCRIPT_PARAM_LIST, 2, {"Q > E > W (Max Q>E)", "Q > E > W (Max Q>W)", "Q > W > E (Max Q>E)", "Q > W > E (Max Q>W)"});
			Param.Misc.LVL:setCallback("Combo", function (nV)
				if nV then
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

		Param.Misc:addSubMenu("", "n1");

		Param.Misc:addSubMenu("Q Settings", "Q");
			Param.Misc.Q:addParam("Emote", "Use Emote to Cancel (Q) animation :", SCRIPT_PARAM_ONOFF, false);
			Param.Misc.Q:addParam("CEmote", "Which Emote :", SCRIPT_PARAM_LIST, 1, {"Dance", "Taunt", "Laugh", "Joke"});
			Param.Misc.Q:addParam("n1", "", SCRIPT_PARAM_INFO, "");
			Param.Misc.Q:addParam("Q3", "Only emote (Q3) :", SCRIPT_PARAM_ONOFF, false);

		Param.Misc:addSubMenu("Flee Settings", "Flee");
			Param.Misc.Flee:addParam("Enable", "Flee Mode :", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("G"));


	enemyMinions = minionManager(MINION_ENEMY, 700, myHero, MINION_SORT_HEALTH_ASC);
	jungleMinions = minionManager(MINION_JUNGLE, 700, myHero, MINION_SORT_MAXHEALTH_DEC);
end

function Riven:Move(unit)

	myHero:MoveTo(mousePos.x, mousePos.z);
end

function Riven:Nothing()
	if Param.Draw.Misc.PermaShow then
		CustomPermaShow("Current Mode :", ""..CurrentMode, true, ARGB(255,52,73,94), nil, nil, 1);
	else
		CustomPermaShow("Current Mode :", ""..CurrentMode, false, ARGB(255,52,73,94), nil, nil, 1);
	end
	if CurrentMode ~= "None" then
		CurrentMode = "None";
	end
end

function Riven:PermaShow()
	if Param.Draw.Misc.PermaShow then
		CustomPermaShow("                         - Baguette "..myHero.charName.." - ", nil, true, nil, nil, nil, 0);
		CustomPermaShow("Current Mode :", ""..CurrentMode, true, ARGB(255,52,73,94), nil, nil, 1);
		CustomPermaShow("", "", true, nil, nil, nil, 2);
		CustomPermaShow("By spyk ", "v"..version, true, ARGB(255,52,73,94), nil, nil, 3);
	else
		CustomPermaShow("                         - Baguette "..myHero.charName.." - ", nil, false, nil, nil, nil, 0);
		CustomPermaShow("Current Mode :", ""..CurrentMode, false, ARGB(255,52,73,94), nil, nil, 1);
		CustomPermaShow("", "", false, nil, nil, nil, 2);
		CustomPermaShow("By spyk ", "v"..version, false, ARGB(255,52,73,94), nil, nil, 3);
	end
end

function Riven:OnProcessAttack(unit, spell)
	if unit and unit.isMe then
		if spell.name:lower():find("attack") then
			if CurrentMode ~= "None" and CurrentMode ~= "LastHit" then
				if spell.target.charName:lower():find("turret") then return end
				if self:CheckingQ(CurrentMode) then
					local T = myHero.spell.target;
					if self.QAA == true and self.Spyk ~= 2 and self.Spyk ~= 3 then
						self.QAA = false;
						CastSpell(_Q, T.x, T.z);
						self:SpykOP(T);
					end
					if CurrentMode == "Combo" then
						if self.Spyk == 2 and Target ~= nil then
							local Target = T;
							if self.QAA == true and self.QAAC2 == true then
								self.QAA = false;
								self.QAAC2 = false;
								CastSpell(_Q, T.x, T.z);
								self:SpykOP(T);
							end
						end
						if self.Spyk == 1 and Target ~= nil then
							local Target = T;
							if self.QReady == true and self.WReady == false and self.EReady == false and self.RReady == false then
								if self:Distance(spell.target) < 270 then
									CastSpell(_Q, T.x, T.z);
									self:SpykOP(T);
								end --Q
							end
							if self.QReady == true and self.WReady == false and self.EReady == true and self.RReady == false then
								self:CastE(spell.target);
								if self.Tiamat == true and self.TiamatReady == true then 
									self:CastT(spell.target);
								end
								CastSpell(_Q, T.x, T.z);
								self:SpykOP(T); --QE
							end
							if self.QReady == false and self.WReady == false and self.EReady == true and self.RReady == false then

								self:CastE(spell.target); -- E
							end
							if self.QReady == false and self.WReady == true and self.EReady == false and self.RReady == false then 
								self:CastW(spell.target);
								if self.Tiamat == true then
									if self.TiamatReady == true then
										self:CastT(spell.target);
									end
								end-- W
							end
							if self.QReady == false and self.WReady == true and self.EReady == true and self.RReady == false then
								self:CastE(spell.target);
								self:CastW(spell.target);
								if self.Tiamat == true and self.TiamatReady == true then
									self:CastT(spell.target);
								end -- WE
							end
							if self.QReady == false and self.WReady == false and self.EReady == true and self.RReady == true and ((self.Ult == true and Target.health < self:D_R(Target)) or (self.Ult == false and Target.health < self:D_R(Target) + self:D_P(Target) * 2)) then
								self:CastE(Target);
								if self.Tiamat == true and self.TiamatReady == true then
									self:CastT(Target);
								end
								self:CastR(Target);
							end
							if self.QReady == false and self.WReady == true and self.EReady == true and self.RReady == true and self.Ult == true then
								self:CastW(Target);
							end
							if self.QReady == true and self.WReady == false and self.EReady == false and self.RReady == true and self.Ult == true and Target.health > self:D_R(Target) + self:D_Q(Target) + self:D_P(Target) then
								self:CastQ(Target, self:Distance(Target), "Combo");
							end
							if self.QReady == true and self.WReady == false and self.EReady == false and self.RReady == true and ((self.Ult == true and Target.health < self:D_R(Target) + self:D_Q(Target) + self:D_P(Target)) or (self.Ult == false and Target.health < self:D_R(Target) + self:D_Q(Target) * 2 + self:D_P(Target) * 4)) then
								self:CastR(Target);
								self:CastQ(Target, self:Distance(Target), "Combo");
							end
							if self.QReady == false and self.WReady == true and self.EReady == false and self.RReady == true and ((self.Ult == true and Target.health < self:D_R(Target) + self:D_W(Target) + self:D_P(Target)) or (self.Ult == false and Target.health < self:D_R(Target) + self:D_W(Target) + self:D_P(Target) * 4)) then
								self:CastR(Target);
								self:CastW(Target);
							end
							if self.QReady == false and self.WReady == true and self.EReady == false and self.RReady == true and self.Ult == true and Target.health > self:D_R(Target) + self:D_W(Target) + self:D_P(Target) then
								self:CastW(Target);
							end
							if self.QReady == false and self.WReady == false and self.EReady == false and self.RReady == true and self.Ult == true and Target.health < self:D_R(Target) then
								self:CastR(Target);
							end
							if self.QReady == true and self.WReady == true and self.EReady == true and self.RReady == false then
								self:CastE(Target);
								if self.Tiamat == true and self.TiamatReady == true then
									self:CastT(Target);
								end
								self:CastW(Target);
								self:CastQ(Target, self:Distance(Target), "Combo");
							end
							if self.QReady == true and self.WReady == true and self.EReady == true and self.RReady == true and ((self.Ult == true and Target.health < self:D_R(Target) + self:D_W(Target) + self:D_Q(Target) + self:D_P(Target) * 3) or (self.Ult == false)) then
								self:CastE(Target);
								self:CastR(Target);
								if self.Tiamat == true and self.TiamatReady == true then
									self:CastT(Target);
								end
								self:CastW(Target);
								self:CastQ(Target, self:Distance(Target), "Combo");
							end
							if self.QReady == true and self.WReady == true and self.EReady == true and self.RReady == true and self.Ult == true and Target.health > self:D_R(Target) + self:D_W(Target) + self:D_Q(Target) + self:D_P(Target) * 3 then
								self:CastE(Target);
								if self.Tiamat == true and self.TiamatReady == true then
									self:CastT(Target);
								end
								self:CastW(Target);
								self:CastQ(Target, self:Distance(Target), "Combo");
							end
							if self.QReady == true and self.WReady == false and self.EReady == true and self.RReady == true and ((self.Ult == true and Target.health < self:D_R(Target) + self:D_Q(Target) + self:D_P(Target) * 3) or (self.Ult == false)) then
								self:CastE(Target);
								if self.Tiamat == true and self.TiamatReady == true then
									self:CastT(Target);
								end
								self:CastR(Target);
								self:CastQ(Target, self:Distance(Target), "Combo");
							end
							if self.QReady == true and self.WReady == false and self.EReady == true and self.RReady == true and self.Ult == true and Target.health > self:D_R(Target) + self:D_Q(Target) + self:D_P(Target) * 3 then
								self:CastE(Target);
								if self.Tiamat == true and self.TiamatReady == true then
									self:CastT(Target);
								end
								self:CastQ(Target, self:Distance(Target), "Combo");
							end
							if self.QReady == true and self.WReady == true and self.EReady == true and self.RReady == false then 
								self:CastE(Target);
								if self.Tiamat == true and self.TiamatReady == true then
									self:CastT(Target);
								end
								self:CastQ(Target, self:Distance(Target), "Combo");
								self:CastW(Target);
							end
							if self.QReady == true and self.WReady == true and self.EReady == true and self.RReady == false then
								self:CastE(Target);
								if self:Distance(Target) < 300 then
									CastSpell(_Q, T.x, T.z);
									self:SpykOP(T);
								else
									self:CastQ(Target, self:Distance(Target), "Combo");
								end
								self:CastW(Target);
							end
							if self.QReady == true and self.WReady == true and self.EReady == false and self.RReady == false then
								if self:Distance(Target) < 500 then
									CastSpell(_Q, T.x, T.z);
									self:SpykOP(T);
								else
									self:CastQ(Target, self:Distance(Target), "Combo");
								end
								self:CastW(Target);
							end
							if self.QReady == true and self.WReady == true and self.EReady == false and self.Ult == true then
								if self:Distance(Target) < 500 then
									CastSpell(_Q, T.x, T.z);
									self:SpykOP(T);
								else
									self:CastQ(Target, self:Distance(Target), "Combo");
								end
								self:CastW(Target);
							end
						end
					end
					if CurrentMode == "LaneClear" then
						if self.WReady == true and self:CheckingW(CurrentMode) then
							self:CastW(spell.target);
						elseif self.EReady == true and self:CheckingE(CurrentMode) then
							self:CastE(spell.target);
						end
					end
				end
			end
		end
		if spell.name:lower():find("ItemTiamatCleave") then
			if self.TiamatReady == true then
				self.TiamatReady = false;
			end
		end
	end
end

function Riven:Animation(unit, animation)
	if unit and animation and unit.isMe then
		if animation == "Spell1a" or animation == "Spell1b" or animation == "Spell1c" then
			DelayAction(function()
				self:SpykOP(self.QT);
			end, self:Time(animation));
		end
	end
end

function Riven:Update()
	if AUTOUPDATE then
		local ServerData = GetWebResult(UPDATE_HOST, "/spyk1/BoL/master/BaguetteRiven/BaguetteRiven.version")
		if ServerData then
			ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil;
			if ServerVersion then
				if tonumber(version) < ServerVersion then
					self:Alerte("New version available "..ServerVersion);
					self:Alerte(">>Updating, please don't press F9<<");
					DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () self:Alerte("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3);
				else
					DelayAction(function() self:Alerte("Hello, "..GetUser()..". You got the latest version! ("..ServerVersion..")") end, 3);
					self:CustomLoad();
				end
			end
		else
			self:Alerte("Error downloading version info");
		end
	end
end

function Riven:Unload()
	if Param.Draw.Skin.Enable then
		SetSkin(myHero, -1);
	end
	self:Alerte("Unloaded, ciao !");
end

function Riven:UpdBuff(unit, buff)
	if unit and buff and unit.isMe and buff.name then
		if buff.name == "RivenTriCleave" then
			self.T_Q = self.T_Q + 1;
		end
		if buff.name == "RivenFengShuiEngine" then
			self.Ult = true;
		end
	end
end

function Riven:RmvBuff(unit, buff)
	if unit and buff and unit.isMe and buff.name then
		if buff.name == "RivenTriCleave" then
			self.T_Q = 0;
		end
		if buff.name == "RivenFengShuiEngine" then
			self.Ult = false;
		end
	end
end

function Riven:Ready()
	if (myHero:CanUseSpell(_Q) == READY or myHero:GetSpellData(_Q).currentCd == 0) and myHero:GetSpellData(_Q).level > 0 then
		self.QReady = true;
	else
		self.QReady = false;
	end
	if (myHero:GetSpellData(_W).currentCd == 0 or myHero:CanUseSpell(_W) == READY) and myHero:GetSpellData(_W).level > 0 then
		self.WReady = true;
	else
		self.WReady = false;
	end
	if (myHero:GetSpellData(_E).currentCd == 0 or myHero:CanUseSpell(_E) == READY) and myHero:GetSpellData(_E).level > 0 then
		self.EReady = true;
	else
		self.EReady = false;
	end
	if (myHero:GetSpellData(_R).currentCd == 0 or myHero:CanUseSpell(_R) == READY) and myHero:GetSpellData(_R).level > 0 then
		self.RReady = true;
	else
		self.RReady = false;
	end
	if myHero:GetSpellData(Flash).currentCd == 0 or myHero:CanUseSpell(Flash) == READY then
		self.FlashReady = true;
	else
		self.FlashReady = false;
	end
	if self.Tiamat then
		if myHero:GetSpellData(self.TiamatSlot).currentCd == 0 or myHero:CanUseSpell(self.TiamatSlot) == READY then
			self.TiamatReady = true;
		else
			self.TiamatReady = false;
		end
	end
end

function Riven:SpykOP(Target)
	unit = Target or myHero;
	if Param.Misc.Q.Emote then
		if Param.Misc.Q.Q3 then
			if self.T_Q == 2 then
				DoEmote(Param.Misc.Q.CEmote-1);
			else
				self:Move(unit);
			end
		else
			DoEmote(Param.Misc.Q.CEmote-1);
		end
	else
		self:Move(unit);
	end
	if _G.AutoCarry and _G.Reborn_Loaded ~= nil then
		_G.AutoCarry.Orbwalker:ResetAttackTimer();
	elseif _G.NebelwolfisOrbWalkerLoaded then
		_G.NebelwolfisOrbWalker:ResetAA();
	elseif _G.EloSpike_OrbLoaded then
		_G.EloSpike.Orb:ResetAA();
	end
end

function Riven:Time(a)
	if a == "Spell1a"then
		return .28 - GetLatency() / 1000;
	elseif a == "Spell1b" then
		return .29 - GetLatency() / 1000;
	elseif a == "Spell1c" then
		return .38 - GetLatency() / 1000;
	end
end

function Riven:WaveClear()
	enemyMinions:update()
	for i, unit in pairs(enemyMinions.objects) do
		if self.QReady == true and self.WReady == true and self.EReady == true and self.TiamatReady == true and Param.WaveClear.UseQ and Param.WaveClear.UseW and Param.WaveClear.UseE and Param.WaveClear.UseT then
			self:CastE(unit);
			self:CastT(unit);
			DelayAction(function()
				self:CastW(unit);
				DelayAction(function()
					self:CastQ(unit, self:Distance(unit), "WaveClear");
				end, self:Time(self.T_Q))
			end, .15)
		elseif self.EReady == true and self.TiamatReady == true and (self.WReady == true or self.QReady == true) and Param.WaveClear.UseE and Param.WaveClear.UseT and Param.WaveClear.UseQ and Param.WaveClear.UseW then
			self:CastE(unit);
			self:CastT(unit);
			if self.WReady == true then
				self:CastW(unit);
			elseif self.QReady == true then
				self:CastQ(unit, self:Distance(unit), "WaveClear");
			end
		elseif (self.WReady == true or self.QReady == true) and self.TiamatReady == true and Param.WaveClear.UseW and Param.WaveClear.UseQ and Param.WaveClear.UseT then
			self:CastT(unit);
			if self.WReady == true then
				self:CastW(unit);
			elseif self.QReady == true then
				self:CastQ(unit, self:Distance(unit), "WaveClear");
			end
		elseif self.QReady == true and self.WReady == true and Param.WaveClear.UseQ and Param.WaveClear.UseW then
			self:CastQ(unit, self:Distance(unit), "WaveClear");
			DelayAction(function()
				self:CastW(unit);
			end, .1);
		elseif self.QReady == true and Param.WaveClear.UseQ then
			self:CastQ(unit, self:Distance(unit), "WaveClear");
		end
	end
end

function Riven:LoadSpikeLib()
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

function Riven:LoadSACR()
	if _G.Reborn_Initialised then
	elseif _G.Reborn_Loaded then
	else
		DelayAction(function() self:Alerte("Failed to Load SAC:R")end, 7);
	end 
end

function Riven:LoadPewalk()
	if _Pewalk then
	elseif not _Pewalk then
		self:Alerte("Pewalk loading error");
	end
end

function Riven:LoadNEOrb()
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

function Riven:OnDraw()
	if not myHero.dead and not Param.Draw.Disable then
		if myHero:CanUseSpell(_Q) == READY and Param.Draw.Spell.Q then 
			DrawCircle3D(myHero.x, myHero.y, myHero.z, 260, 1, 0xFFFFFFFF);
		end
		if myHero:CanUseSpell(_W) == READY and Param.Draw.Spell.W then 
			DrawCircle3D(myHero.x, myHero.y, myHero.z, self:D_Width(myHero), 1, 0xFFFFFFFF);
		end
		if myHero:CanUseSpell(_E) == READY and Param.Draw.Spell.E then 
			DrawCircle3D(myHero.x, myHero.y, myHero.z, 325, 1, 0xFFFFFFFF);
		end
		if myHero:CanUseSpell(_R) == READY and Param.Draw.Spell.R then
			local R = 200;
			if self.Ult == true then
				R = 900;
			end
			DrawCircle3D(myHero.x, myHero.y, myHero.z, R, 1, 0xFFFFFFFF);
		end
		if Param.Draw.Spell.AA then
			DrawCircle3D(myHero.x, myHero.y, myHero.z, myHero.range+myHero.boundingRadius, 1, 0xFFFFFFFF)
		end
		if Param.Draw.Misc.HitBox then
			DrawCircle3D(myHero.x, myHero.y, myHero.z, myHero.boundingRadius, 1, 0xFFFFFFFF);
		end
		if Target ~= nil and ValidTarget(Target) then
			if Param.Draw.Misc.Target then
				DrawText3D(">> TARGET <<",Target.x-100, Target.y-50, Target.z, 20, 0xFFFFFFFF);
				DrawText(""..Target.charName.."", 50, 50, 200, 0xFFFFFFFF);
			end
		end
		if Param.Combo.Flash then
			if Param.Draw.Spell.F then
				DrawText("<Flash Combo Enabled!>", 50, 50, 250, 0xFFFFFFFF);
				if self.QReady == true then
					DrawText3D("[Q]",myHero.x-150, myHero.y-100, myHero.z+100, 20, ARGB(255, 39, 174, 96));
				else
					DrawText3D("[Q]",myHero.x-150, myHero.y-100, myHero.z+100, 20, ARGB(255, 192, 57, 43));
				end
				if self.WReady == true then
					DrawText3D("[W]",myHero.x-100, myHero.y-100, myHero.z+100, 20, ARGB(255, 39, 174, 96));
				else
					DrawText3D("[W]",myHero.x-100, myHero.y-100, myHero.z+100, 20, ARGB(255, 192, 57, 43));
				end
				if self.EReady == true then
					DrawText3D("[E]",myHero.x-50, myHero.y-100, myHero.z+100, 20, ARGB(255, 39, 174, 96));
				else
					DrawText3D("[E]",myHero.x-50, myHero.y-100, myHero.z+100, 20, ARGB(255, 192, 57, 43));
				end
				if self.RReady == true then
					DrawText3D("[R]",myHero.x, myHero.y-100, myHero.z+100, 20, ARGB(255, 39, 174, 96));
				else
					DrawText3D("[R]",myHero.x, myHero.y-100, myHero.z+100, 20, ARGB(255, 192, 57, 43));
				end
				if self.FlashReady == true then
					DrawText3D("[F]",myHero.x+50, myHero.y-100, myHero.z+100, 20, ARGB(255, 39, 174, 96));
				else
					DrawText3D("[F]",myHero.x+50, myHero.y-100, myHero.z+100, 20, ARGB(255, 192, 57, 43));
				end
				if self.Tiamat == true and self.TiamatReady == true then
					DrawText3D("[T]",myHero.x+100, myHero.y-100, myHero.z+100, 20, ARGB(255, 39, 174, 96));
				else
					DrawText3D("[T]",myHero.x+100, myHero.y-100, myHero.z+100, 20, ARGB(255, 192, 57, 43));
				end
			end
		end

		if Param.Draw.Damages.Enable then
			for _, unit in pairs(GetEnemyHeroes()) do
				if unit ~= nil and self:Distance(unit) < 1000 and unit.visible and not unit.dead then
					local DTT = 0;
					if self.QReady == true then
						if self.T_Q == 0 then
							DTT = DTT + self:D_Q(unit) * 3 + self:D_P(unit) * 3;
						elseif self.T_Q == 1 then
							DTT = DTT + self:D_Q(unit) * 2 + self:D_P(unit) * 2;
						elseif self.T_Q == 2 then
							DTT = DTT + self:D_Q(unit) + self:D_P(unit);
						end
					end
					if self.WReady == true then
						DTT = DTT + self:D_W(unit);
					end
					if self.EReady == true then
						DTT = DTT + self:D_P(unit);
					end
					if self.RReady == true then
						DTT = DTT + self:D_R(unit) + self:D_P(unit);
					end
					if self.Tiamat == true and self.TiamatReady == true then
						DTT = DTT + self:D_P(unit);
					end
					DTT = DTT + math.floor(myHero:CalcDamage(unit,myHero.totalDamage));
					local DTTTT = math.round(DTT) - math.round(unit.health);
					DTT = math.floor(DTT/unit.health*100);
					if DTT < 100 then
						DrawText3D(DTT.."%", unit.x+125, unit.y+85, unit.z+155, 30, ARGB(255,250,250,250), 0);
					else
						DrawText3D("Killable - +"..DTTTT, unit.x+125, unit.y+85, unit.z+155, 30, ARGB(255,250,250,250), 0);
					end
				end
			end
		end
	end
end
