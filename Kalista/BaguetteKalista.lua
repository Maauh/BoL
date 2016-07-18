if myHero.charName ~= "Kalista" then return end
	
function OnLoad()

	Kalista();
end

class 'Kalista';

function Kalista:__init()
	self:Alerte("BaguetteKalista - by spyk, loading..");
	self:Lib();
	self:Update();
end

function Kalista:Alerte(msg)
	PrintChat("<b><font color=\"#F5D76E\">></font></b> <font color=\"#fd576e\"> " .. msg .. "</font>");
end

function Kalista:AutoLvlSpell()
 	if self.Time - self.Last_LevelSpell > 0.5 then
 		if self.Param.Extra.LVL.Enable then
	    	autoLevelSetSequence(levelSequence);
	    	self.Last_LevelSpell = self.Time;
	    elseif not self.Param.Extra.LVL.Enable then
	    	autoLevelSetSequence(nil);
	    	self.Last_LevelSpell = self.Time + 10;
	    end
  	end
end

function Kalista:AutoLVLSpellCombo()
	AddTickCallback(function()
		self:AutoLvlSpell();
	end);
	if self.Param.Extra.LVL.Enable then
		if self.Param.Extra.LVL.Combo == 1 then
			levelSequence =  {3,1,2,3,3,4,3,1,3,1,4,1,1,2,2,4,2,2} -- Max E/Q | E > Q > W
		else
			levelSequence =  {3,2,1,3,3,4,3,1,3,1,4,1,1,2,2,4,2,2} -- Max E/Q | E > W > Q
		end
	end
end

function Kalista:AutoLVLSpellCombo2()
	if self.Param.Extra.LVL.Enable then
		if self.Param.Extra.LVL.Combo == 1 then
			levelSequence =  {3,1,2,3,3,4,3,1,3,1,4,1,1,2,2,4,2,2} -- Max E/Q | E > Q > W
		else
			levelSequence =  {3,2,1,3,3,4,3,1,3,1,4,1,1,2,2,4,2,2} -- Max E/Q | E > W > Q
		end
	end
end

function Kalista:AutoBuy()
	if self.Param.Extra.AutoBuy.Enable then
		if GetGameTimer() < 200 then
			DelayAction(function()
				if self.Param.Extra.AutoBuy.Doran then
					DelayAction(function()
						BuyItem(1055);
					end, 1);
				end
				if self.Param.Extra.AutoBuy.Potion then
					DelayAction(function()
						BuyItem(2003)
					end, 2);
				end
				if self.Param.Extra.AutoBuy.Trinket then
					DelayAction(function()
						BuyItem(3340);
					end, 3)
				end
			end, 2);
		end
	end
end

function Kalista:AutoPotion()
	if self.Param.Extra.Items.POT then
		if self.Time - self.LastPotCheck > 1 then
			if Kalista:EIR(myHero, 1500) then
				self.LastPotCheck = self.Time;
				if self.Time - self.lastPotion > self.ActualPotTime then
					for SLOT = ITEM_1, ITEM_6 do
						if myHero:GetSpellData(SLOT).name == "RegenerationPotion" then
							self.ActualPotName = "Health Potion";
							self.ActualPotTime = 15;
							self.ActualPotData = "RegenerationPotion";
							self:Usepot();
						elseif myHero:GetSpellData(SLOT).name == "ItemMiniRegenPotion" then
							self.ActualPotName = "Cookie";
							self.ActualPotTime = 15;
							self.ActualPotData = "ItemMiniRegenPotion";
							self:Usepot();
						elseif myHero:GetSpellData(SLOT).name == "ItemCrystalFlaskJungle" then
							self.ActualPotName = "Hunter's Potion";
							self.ActualPotTime = 8;
							self.ActualPotData = "ItemCrystalFlaskJungle";
							self:Usepot();
						elseif myHero:GetSpellData(SLOT).name == "ItemCrystalFlask" then
							self.ActualPotName = "Refillable Potion";
							self.ActualPotTime = 12;
							self.ActualPotData = "ItemCrystalFlask";
							self:Usepot();
						elseif myHero:GetSpellData(SLOT).name == "ItemDarkCrystalFlask" then
							self.ActualPotName = "Corrupting Potion";
							self.ActualPotTime = 12;
							self.ActualPotData = "ItemDarkCrystalFlask";
							self:Usepot();
						end
					end
				end
			end
		end
	end
end

function Kalista:AutoWard() -- Credit to Ralphlol
	self.LastPos = {};
	self.LastTime = {};
	self.Next_WardTime = 0;
	self.BuffNames = {"rengarr", "monkeykingdecoystealth", "talonshadowassaultbuff", "vaynetumblefade", "twitchhideinshadows", "khazixrstealth", "akaliwstealth"};
    _G.GetInventorySlotItem = GetSlotItem;
    for _, c in pairs(GetEnemyHeroes()) do
        self.LastPos[c.networkID] = Vector(c);
    end
    AddNewPathCallback(function(unit, startPos, endPos, isDash ,dashSpeed,dashGravity, dashDistance)
        self:AutoWardPath(unit, startPos, endPos, isDash, dashSpeed, dashGravity, dashDistance);
    end)
    AddTickCallback(function()
        self:AutoWardTick();
    end)
    AddProcessSpellCallback(function(unit, spell)
        self:AutoWardProcessSpell(unit, spell);
    end)
    AddUpdateBuffCallback(function(unit, buff, stacks) 
        self:AutoWardUpdateBuff(unit, buff, stacks);
    end)
end

function Kalista:AutoWardPath(unit, startPos, endPos, isDash ,dashSpeed,dashGravity, dashDistance)
    if unit.team ~= myHero.team and isDash then
        self.LastPos[unit.networkID] = Vector(endPos);
    end
end

function Kalista:AutoWardItem(bush)
    local WardSlot = nil
    if bush then
        if self:GetSlotItem(2045) and myHero:CanUseSpell(self:GetSlotItem(2045)) == READY then
            WardSlot = self:GetSlotItem(2045);
        elseif self:GetSlotItem(2049) and myHero:CanUseSpell(self:GetSlotItem(2049)) == READY then
            WardSlot = self:GetSlotItem(2049);
        elseif self:GetSlotItem(3340) and myHero:CanUseSpell(self:GetSlotItem(3340)) == READY or self:GetSlotItem(3350) and myHero:CanUseSpell(self:GetSlotItem(3350)) == READY or self:GetSlotItem(3361) and myHero:CanUseSpell(self:GetSlotItem(3361)) == READY or self:GetSlotItem(3363) and myHero:CanUseSpell(self:GetSlotItem(3363)) == READY or self:GetSlotItem(3411) and myHero:CanUseSpell(self:GetSlotItem(3411)) == READY or self:GetSlotItem(3342) and myHero:CanUseSpell(self:GetSlotItem(3342)) == READY or self:GetSlotItem(3362) and myHero:CanUseSpell(self:GetSlotItem(3362)) == READY then
            WardSlot = 12;
        elseif self:GetSlotItem(2044) and myHero:CanUseSpell(self:GetSlotItem(2044)) == READY then
            WardSlot = self:GetSlotItem(2044);
        elseif self:GetSlotItem(2043) and myHero:CanUseSpell(self:GetSlotItem(2043)) == READY then
            WardSlot = self:GetSlotItem(2043);
        end
    else
        if self:GetSlotItem(3362) and myHero:CanUseSpell(self:GetSlotItem(3362)) == READY then
            WardSlot = 12;
        elseif  self:GetSlotItem(2043) and myHero:CanUseSpell(self:GetSlotItem(2043)) == READY then
            WardSlot = self:GetSlotItem(2043);
        end
    end
    return WardSlot
end

function Kalista:AutoWardTick()
    if not self.Param.Extra.Items.WARD then return end
    for _, c in pairs(GetEnemyHeroes()) do  
        if c.visible then
            self.LastPos[c.networkID] = Vector(c);
            self.LastTime[c.networkID] = os.clock();
        elseif not c.dead and not c.visible then
            self:AutoWardCheck(c, true);
        end
    end
end

function Kalista:AutoWardProcessSpell(unit, spell)
    if unit.team ~= myHero.team then
        if spell.name:lower():find("deceive") then
            local f = spell.endPos;
            if GetDistance(unit, spell.endPos) > 400 then
                f = Vector(unit) + (Vector(spell.endPos) - Vector(unit)):normalized() * (400);
            end
            if checkWall(f) then
                f = NearestNonWall(f.x, f.y, f.z, 400, 60);
            end
            self:AutoWardCheck(unit, false, f);
        end
    end
end

function Kalista:AutoWardUpdateBuff(unit, buff, stacks)
    if not unit or not buff then return end
    if unit.team ~= myHero.team then
        if (self.Param.Extra.Items.WARDCombo and self.Mode == "Combo") or not self.Param.Extra.Items.WARD then
            for _, buffN in pairs(self.BuffNames) do    
                if buff.name:lower():find(buffN) then
                    self:AutoWardCheck(unit, false)
                end
            end
        end
    end
end

function Kalista:AutoWardCheck(c, bush, cPos)
    local time = self.LastTime[c.networkID];
    local pos = cPos and cPos or self.LastPos[c.networkID];
    local clock = self.Time;

    if time and pos and clock - time < 1 and clock > self.Next_WardTime and GetDistanceSqr(pos) < 1000 * 1000 then

        local castPos, WardSlot
        if bush then
            castPos = self:AutoWardFindBush(pos.x, pos.y, pos.z, 100)
            if castPos and GetDistanceSqr(castPos) < 600 * 600 then
                WardSlot = self:AutoWardItem(bush);
            end
        else
            castPos = pos;
            if GetDistanceSqr(castPos) < 600 * 600 then
                WardSlot = self:AutoWardItem(bush);
            elseif GetDistanceSqr(castPos) < 900 * 900 then
                castPos = Vector(myHero) +  Vector(Vector(castPos) - Vector(myHero)):normalized()* 575;
                WardSlot = self:AutoWardItem(bush);
            end
        end
        if WardSlot then
            CastSpell(WardSlot,castPos.x,castPos.z);
            self.Next_WardTime = clock + 10;
            return
        end
    end
end

function Kalista:AutoWardFindBush(x0, y0, z0, maxRadius, precision) -- Credits to gReY
    local vec = D3DXVECTOR3(x0, y0, z0)
    precision = precision or 50
    maxRadius = maxRadius and math.floor(maxRadius / precision) or math.huge
    x0, z0 = math.round(x0 / precision) * precision, math.round(z0 / precision) * precision
    local radius = 2
    local function checkP(x, y)
        vec.x, vec.z = x0 + x * precision, z0 + y * precision 
        return IsWallOfGrass(vec) 
    end
    while radius <= maxRadius do
        if checkP(0, radius) or checkP(radius, 0) or checkP(0, -radius) or checkP(-radius, 0) then
            return vec 
        end
        local f, x, y = 1 - radius, 0, radius
        while x < y - 1 do
            x = x + 1
            if f < 0 then 
                f = f + 1 + 2 * x
            else 
                y, f = y - 1, f + 1 + 2 * (x - y)
            end
            if checkP(x, y) or checkP(-x, y) or checkP(x, -y) or checkP(-x, -y) or 
               checkP(y, x) or checkP(-y, x) or checkP(y, -x) or checkP(-y, -x) then
                return vec 
            end
        end
        radius = radius + 1
    end
end

function Kalista:AfterUpdate()
	self:Var();
	self:Menu();
	self:Loader();
	if VIP_USER then
		self:VIPLoader();
	end
	self:AutoWard();
	self:Orbwalker();
	AddTickCallback(function()
		self:CurrentMode();
		self:Checks();
		self:AutoE();
		self.Target = self:GetTarget();
		self:WallJumpHopHop();
	end);
	AddApplyBuffCallback(function(source, unit, buff)
		if self.Param.Extra.Items.QSS then
			self:ApplyBuff(source, unit, buff);
		end
	end);
	AddUpdateBuffCallback(function(unit, buff, stacks)
		self:OnUpdateBuff(unit, buff, stacks);
	end);
	AddRemoveBuffCallback(function(unit, buff)
		self:OnRemoveBuff(unit, buff);
	end);
	AddDrawCallback(function()
		self:OnDraw();
		self:RendDraw();
		self:WallHOPDraw();
	end);
	AddProcessAttackCallback(function(unit, spell)
        self:OnProcessAttack(unit, spell);
    end)
	AddMsgCallback(function(msg,key) 
        self:OnWndMsg(msg,key);
    end)
    AddUnloadCallback(function()
    	if self.Param.Draw.Misc.SKIN then
    		SetSkin(myHero, -1);
    	end
		self:Alerte("Unloaded, ciao !");
	end);
	AddLoadCallback(function()
		if self.Param.Draw.Misc.SKIN then
			SetSkin(myHero, self.Param.Draw.Misc.skins-1);
		end
	end);
end

function Kalista:ApplyBuff(source, unit, buff)
	if unit and unit.isMe and buff and source and source.valid then
		if (self.Param.Extra.Items.QSSCombo and self.Mode == "Combo") or not self.Param.Extra.Items.QSSCombo then
			if buff.name:lower() == "summonerexhaust" then
				self:CastQSS();
			end
			if source.charName:lower():find("baron") or source.charName:lower():find("spiderboss") or source.charName == "Blitzcrank" or source.charName == "LeeSin" or source.charName == "Hecarim" then return end
			if buff.name and buff.type == 24 or buff.type == 5 or buff.type == 11 or buff.type == 22 or buff.type == 21 or buff.type == 8 or (buff.type == 10 and buff.name and buff.name:lower():find("fleeslow")--[[terrorize]]) then
				if buff.name:lower():find("caitlynyor") and not self:EnemyInRange(myHero, 1250) then
					return false
				else
					self:CastQSS();
				end
			end
		end
	end
end

function Kalista:CastQ(t, y)
	if t ~= nil and GetDistance(t) < 1000 then
		if y ~= "Combo" and y ~= nil then
			if not self:Mana(y, "Q") then
				return
			end
		end
		if self.Param.Pred == 1 then
			local CastPosition, HitChance, Position = VP:GetLineCastPosition(t, .25, 70, 1000, 1750, myHero, false);
			if HitChance > 1 then
				CastSpell(_Q, CastPosition.x, CastPosition.z);
			elseif t.type == myHero.type then
				self:QEHarass();
			end
		elseif self.Param.Pred == 2 then
			local Position, HitChance = HPred:GetPredict(HPSkillshot({type = "DelayLine", delay = .25, range = 1000, speed = 1750, collisionH = false, collisionM = true, width = 70}), t, myHero);
			if HitChance > 0 then
				CastSpell(_Q, Position.x, Position.z);
			elseif t.type == myHero.type then
				self:QEHarass();
			end
		elseif self.Param.Pred == 3 then
			local pos, hc, info = FHPrediction.GetPrediction({range = 1000, speed = 1700, delay = .25, radius = 70, collision = true}, t);
			if hc > 0 then
				CastSpell(_Q, pos.x, pos.z);
			elseif t.type == myHero.type then
				self:QEHarass();
			end
		end
	end
end

function Kalista:QEHarass()
	if self.Target ~= nil and not self.Target.dead and self.Q then
		if GetDistance(self.Target) < 1000 and self.Param.Harass.Q then
			enemyMinions:update();
			local minion_on_vector = 0;
			local minion_killable = 0;
			local minion_stack = 0;
			for i, minion in pairs(enemyMinions.objects) do
				if ValidTarget(minion) then
					AB = math.sqrt((self.Target.x-myHero.x)*(self.Target.x-myHero.x)+(self.Target.y-myHero.y)*(self.Target.y-myHero.y)+(self.Target.z-myHero.z)*(self.Target.z-myHero.z));
					AP = math.sqrt((minion.x-myHero.x)*(minion.x-myHero.x)+(minion.y-myHero.y)*(minion.y-myHero.y)+(minion.z-myHero.z)*(minion.z-myHero.z));
					PB = math.sqrt((self.Target.x-minion.x)*(self.Target.x-minion.x)+(self.Target.y-minion.y)*(self.Target.y-minion.y)+(self.Target.z-minion.z)*(self.Target.z-minion.z));
					if AB > AP+PB-5 or AB > AP+PB+5 then
						minion_on_vector = minion_on_vector + 1;
						if self:GetStacks(minion) > -1 then
							D_Q = myHero:CalcDamage(minion, myHero:GetSpellData(_Q).level * 60 - 50 + myHero.totalDamage);
							if D_Q > minion.health then
								minion_killable = minion_killable + 1;
								minion_stack = minion_stack + self:GetStacks(minion);
							end
							if minion_killable == minion_on_vector and minion_stack > 2 then
								CastSpell(_Q, Target.x, Target.z);
							end
						end
					end
				end
			end
		end
	end
end

function Kalista:CastQSS()
	if self.Time - self.lastQSS > .5 then
		for SLOT = ITEM_1, ITEM_6 do
			if myHero:GetSpellData(SLOT).name == "QuicksilverSash" or myHero:GetSpellData(SLOT).name == "ItemMercurial" then
				if myHero:CanUseSpell(SLOT) == READY then
					DelayAction(function()
						CastSpell(SLOT);
					end, self.Param.Extra.Items.QSSDelay/1000);
					self.lastQSS = self.Time;
				end
			end
		end
	end
end

function Kalista:Checks()
	if myHero:CanUseSpell(_Q) == READY then
		self.Q = true;
	else
		self.Q = false;
	end
	if myHero:CanUseSpell(_W) == READY then
		self.W = true;
	else
		self.W = false;
	end
	if myHero:CanUseSpell(_E) == READY then
		self.E = true;
	else
		self.E = false;
	end
	if myHero:CanUseSpell(_R) == READY then
		self.R = true;
	else
		self.R = false;
	end
end

function Kalista:eDmg(unit)
	local l = myHero:GetSpellData(_E).level;
	local s = self:GetStacks(unit);
	local r = 15 * l + 5;
	local d_t = r + myHero.totalDamage * .6;
	if s > 1 then
		local ex = {10, 14, 19, 25, 32};
		local mx = {.2, .225, .25, .275, .3};
		local mux = ex[l] + mx[l] * myHero.totalDamage;
		local F = d_t + ((s-1)*mux);
		local Dmg = math.floor(myHero:CalcDamage(unit, F));
		if self.UnderExhaust == true then
			Dmg = Dmg * .4;
		end
		return Dmg
	else
		if s == 1 then
			if self.UnderExhaust == true then
				d_t = d_t * .4;
			end
			return math.floor(myHero:CalcDamage(unit, d_t))
		else
			return 0
		end
	end
end

function Kalista:ePercent(unit)
	return math.floor(self:eDmg(unit) / unit.health * 100)
end

function Kalista:EIR(t, r)
    local z = t or myHero;
    local x = r or 2500;
    local n = 0;
    for _, unit in pairs(GetEnemyHeroes()) do
        if ValidTarget(unit) and not unit.dead and unit.visible and GetDistanceSqr(z, unit) < x*x then
            n = n + 1;
        end
    end
    return n
end

function Kalista:EnemyInRange(t, r)
    if self:EIR(t, r) > 0 then
        return true
    else
        return false
    end
end

function Kalista:PerStack(unit)
	local l = myHero:GetSpellData(_E).level;
	local ex = {10, 14, 19, 25, 32};
	local mx = {.2, .225, .25, .275, .3};
	local mux = ex[l] + mx[l] * myHero.totalDamage;
	if self.UnderExhaust == true then
		mux = mux * .4;
	end
	return mux
end

function Kalista:GetStacks(u)
	return self.Stacks[u.networkID] or 0
end

function Kalista:GetSlotItem(id)
	local tab = {[3144] = "BilgewaterCutlass", [3153] = "ItemSwordOfFeastAndFamine", [3405] = "TrinketSweeperLvl1", [3411] = "TrinketOrbLvl1", [3166] = "TrinketTotemLvl1", [3450] = "OdinTrinketRevive", [2041] = "ItemCrystalFlask", [2054] = "ItemKingPoroSnack", [2138] = "ElixirOfIron", [2137] = "ElixirOfRuin", [2139] = "ElixirOfSorcery", [2140] = "ElixirOfWrath", [3184] = "OdinEntropicClaymore", [2050] = "ItemMiniWard", [3401] = "HealthBomb", [3363] = "TrinketOrbLvl3", [3092] = "ItemGlacialSpikeCast", [3460] = "AscWarp", [3361] = "TrinketTotemLvl3", [3362] = "TrinketTotemLvl4", [3159] = "HextechSweeper", [2051] = "ItemHorn", [3146] = "HextechGunblade", [3187] = "HextechSweeper", [3190] = "IronStylus", [2004] = "FlaskOfCrystalWater", [3139] = "ItemMercurial", [3222] = "ItemMorellosBane", [3180] = "OdynsVeil", [3056] = "ItemFaithShaker", [2047] = "OracleExtractSight", [3364] = "TrinketSweeperLvl3", [3140] = "QuicksilverSash", [3143] = "RanduinsOmen", [3074] = "ItemTiamatCleave", [3800] = "ItemRighteousGlory", [2045] = "ItemGhostWard", [3342] = "TrinketOrbLvl1", [3040] = "ItemSeraphsEmbrace", [3048] = "ItemSeraphsEmbrace", [2049] = "ItemGhostWard", [3345] = "OdinTrinketRevive", [2044] = "SightWard", [3341] = "TrinketSweeperLvl1", [3069] = "shurelyascrest", [3599] = "KalistaPSpellCast", [3185] = "HextechSweeper", [3077] = "ItemTiamatCleave", [2009] = "ItemMiniRegenPotion", [2010] = "ItemMiniRegenPotion", [3023] = "ItemWraithCollar", [3290] = "ItemWraithCollar", [2043] = "VisionWard", [3340] = "TrinketTotemLvl1", [3142] = "YoumusBlade", [3512] = "ItemVoidGate", [3131] = "ItemSoTD", [3137] = "ItemDervishBlade", [3352] = "RelicSpotter", [3350] = "TrinketTotemLvl2", [3085] = "AtmasImpalerDummySpell"};
	local name = tab[id];
	for i = 6, 12 do
		local item = myHero:GetSpellData(i).name;
		if ((#item > 0) and (item:lower() == name:lower())) then
			return i
		end
	end
end

function Kalista:GetDashRange()
	for _, v in pairs({ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6, ITEM_7}) do
		if myHero:getInventorySlot(v) == 3006 or myHero:getInventorySlot(v) == 3009 or myHero:getInventorySlot(v) == 3020 or myHero:getInventorySlot(v) == 3047 or myHero:getInventorySlot(v) == 3111 or myHero:getInventorySlot(v) == 3117 or myHero:getInventorySlot(v) == 3158 then
			return 375
		elseif myHero:getInventorySlot(v) == 1001 then
			return 325
		else
			return 275
		end
	end
end

function Kalista:GetTarget()
	if _G.AutoCarry and _G.AutoCarry.Keys and _G.Reborn_Loaded ~= nil then
		t = _G.AutoCarry.Crosshair:GetTarget();
	elseif _G.MMA_IsLoaded then
		t = _G.MMA_Target();
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

function Kalista:Immune(unit)
    for i = 1, unit.buffCount do
        local tBuff = unit:getBuff(i)
        if BuffIsValid(tBuff) then
            if self.buffs[tBuff.name] then
                return true
            end
        end
    end
    return false
end

function Kalista:KeyConversion(v)

    local K = {};
    K[8] = 'Back';
    K[9] = 'Tab';
    K[13] = 'Enter';
    K[16] = 'Shift';
    K[17] = 'Ctrl';
    K[18] = 'Alt';
    K[19] = 'Pause';
    K[20] = 'Capslock';
    K[21] ='KanaMode';
    K[23] = 'JunjaMode';
    K[24] = 'FinalMode';
    K[25] = 'HanjaMode';
    K[27] = 'Esc';
    K[28] = 'IMEConvert';
    K[29] = 'IMENonconvert';
    K[30] = 'IMEAceept';
    K[31] = 'IMEModeChange';
    K[32] = 'Space';
    K[33] = 'PageUp';
    K[34] = 'PageDown';
    K[35] = 'End';
    K[36] = 'Home';
    K[37] = 'Left';
    K[38] = 'Up';
    K[39] = 'Right';
    K[40] = 'Down';
    K[44] = 'PrintScreen';
    K[45] = 'Insert';
    K[46] = 'Delete';
    K[48] = '0';
    K[49] = '1';
    K[50] = '2';
    K[51] = '3';
    K[52] = '4';
    K[53] = '5';
    K[54] = '6';
    K[55] = '7';
    K[56] = '8';
    K[57] = '9';
    K[65] = 'A';
    K[66] = 'B';
    K[67] = 'C';
    K[68] = 'D';
    K[69] = 'E';
    K[70] = 'F';
    K[71] = 'G';
    K[72] = 'H';
    K[73] = 'I';
    K[74] = 'J';
    K[75] = 'K';
    K[76] = 'L';
    K[77] = 'M';
    K[78] = 'N';
    K[79] = 'O';
    K[80] = 'P';
    K[81] = 'Q';
    K[82] = 'R';
    K[83] = 'S';
    K[84] = 'T';
    K[85] = 'U';
    K[86] = 'V';
    K[87] = 'W';
    K[88] = 'X';
    K[89] = 'Y';
    K[90] = 'Z';
    K[91] = 'LWin';
    K[92] = 'RWin';
    K[93] = 'Apps';
    K[96] = 'NumPad0';
    K[97] = 'NumPad1';
    K[98] = 'NumPad2';
    K[99] = 'NumPad3';
    K[100] = 'NumPad4';
    K[101] = 'NumPad5';
    K[102] = 'NumPad6';
    K[103] = 'NumPad7';
    K[104] = 'NumPad8';
    K[105] = 'NumPad9';
    K[106] = 'Multiply';
    K[107] = 'Add';
    K[108] = 'Separator';
    K[109] = 'Subtract';
    K[110] = 'Decimal';
    K[111] = 'Divide';
    K[112] = 'F1';
    K[113] = 'F2';
    K[114] = 'F3';
    K[115] = 'F4';
    K[116] = 'F5';
    K[117] = 'F6';
    K[118] = 'F7';
    K[119] = 'F8';
    K[120] = 'F9';
    K[121] = 'F10';
    K[122] = 'F11';
    K[123] = 'F12';
    K[144] = 'NumLock';
    K[145] = 'ScrollLock';
    K[186] = ';';;
    K[187] = '=';
    K[188] = ',';
    K[189] = '-';
    K[190] = '.';
    K[191] = '/';
    K[192] = 'Oemtilde';
    K[219] = 'OemOpenBrackets';
    K[220] = 'Oem5';
    K[221] = 'Oem6';
    K[222] = "'";

    return K[v]
end

function Kalista:Lib()
	local LibPath = LIB_PATH.."SpikeLib.lua"
	if not FileExist(LibPath) then
		local Host = "raw.github.com";
		local Path = "/spyk1/BoL/master/bundle/SpikeLib.lua".."?rand="..math.random(1,10000);
		self:Alerte("Libs not found!");
		DownloadFile("https://"..Host..Path, LibPath, function()  end);
		DelayAction(function() 
			require("SpikeLib") 
		end, 5);
	else
		require("SpikeLib");
	end
end

function Kalista:Mana(Mode, Spell)
	local reqMana = self.Param[Mode] and self.Param[Mode]["Mana"..Spell] or 101;
	if 100 * myHero.mana / myHero.maxMana > reqMana then
		return true
	else
		return false
	end
end

function Kalista:CurrentMode()
    if _G.AutoCarry and _G.AutoCarry.Keys and _G.Reborn_Loaded ~= nil then
        if _G.AutoCarry.Keys.AutoCarry then 
            if self.Mode ~= "Combo" then
                self.Mode = "Combo";
                self:PermaShow("Combo");
            end
        elseif _G.AutoCarry.Keys.MixedMode then 
            if self.Mode ~= "Harass" then
                self.Mode = "Harass";
                self:PermaShow("Harass");
            end
        elseif _G.AutoCarry.Keys.LaneClear then 
            if self.Mode ~= "Harass" then
                self.Mode = "LaneClear";
                self:PermaShow("LaneClear");
            end
        elseif _G.AutoCarry.Keys.LastHit then
            if self.Mode ~= "LastHit" then
                self.Mode = "LastHit";
                self:PermaShow("LastHit");
            end
        else
            if self.Mode ~= "None" then
                self.Mode = "None";
                self:PermaShow("None");
            end
        end

    elseif _G.MMA_IsLoaded then

        if _G.MMA_IsOrbwalking then 
            if self.Mode ~= "Combo" then
                self.Mode = "Combo";
                self:PermaShow("Combo");
            end
        elseif _G.MMA_IsDualCarrying then 
            if self.Mode ~= "Harass" then
                self.Mode = "Harass";
                self:PermaShow("Harass");
            end
        elseif _G.MMA_IsLaneClearing then 
            if self.Mode ~= "LaneClear" then
                self.Mode = "LaneClear";
                self:PermaShow("LaneClear");
            end
        elseif _G.MMA_IsLastHitting then
            if self.Mode ~= "LastHit" then
                self.Mode = "LastHit";
                self:PermaShow("LastHit");
            end
        else
            if self.Mode ~= "None" then
                self.Mode = "None";
                self:PermaShow("None");
            end
        end

    elseif _Pewalk then

        if _G._Pewalk.GetActiveMode().Carry then 
            if self.Mode ~= "Combo" then
                self.Mode = "Combo";
                self:PermaShow("Combo");
            end
        elseif _G._Pewalk.GetActiveMode().Mixed then 
            if self.Mode ~= "Harass" then
                self.Mode = "Harass";
                self:PermaShow("Harass");
            end
        elseif _G._Pewalk.GetActiveMode().LaneClear then
            if self.Mode ~= "LaneClear" then
                self.Mode = "LaneClear";
                self:PermaShow("LaneClear");
            end
        elseif _G._Pewalk.GetActiveMode().Farm then 
            if self.Mode ~= "LastHit" then
                self.Mode = "LastHit";
                self:PermaShow("LastHit");
            end
        else
            if self.Mode ~= "None" then
                self.Mode = "None";
                self:PermaShow("None");
            end
        end

    elseif _G.NebelwolfisOrbWalkerLoaded then

        if _G.NebelwolfisOrbWalker.Config.k.Combo then
            if self.Mode ~= "Combo" then
                self.Mode = "Combo";
                self:PermaShow("Combo");
            end
        elseif _G.NebelwolfisOrbWalker.Config.k.Harass then
            if self.Mode ~= "Harass" then
                self.Mode = "Harass";
                self:PermaShow("Harass");
            end
        elseif _G.NebelwolfisOrbWalker.Config.k.LastHit then
            if self.Mode ~= "LastHit" then
                self.Mode = "LastHit";
                self:PermaShow("LastHit");
            end
        elseif _G.NebelwolfisOrbWalker.Config.k.LaneClear then
            if self.Mode ~= "LaneClear" then
                self.Mode = "LaneClear";
                self:PermaShow("LaneClear");
            end
        else
            if self.Mode ~= "None" then
                self.Mode = "None";
                self:PermaShow("None");
            end
        end
    end
end

function Kalista:Menu()
	self.Param = scriptConfig("[Baguette] Kalista", "Kalista");

	self.Param:addSubMenu("Combo Settings", "Combo");
		self.Param.Combo:addParam("Q", "Use Q :", SCRIPT_PARAM_ONOFF, true);

	self.Param:addSubMenu("Harass Settings", "Harass");
		self.Param.Harass:addParam("Q", "Use Q :", SCRIPT_PARAM_ONOFF, true);
		self.Param.Harass:addParam("ManaQ", "Set a value for (Q) in Mana :", SCRIPT_PARAM_SLICE, 40, 0, 100);
		self.Param.Harass:addParam("E", "Use E :", SCRIPT_PARAM_ONOFF, true);
		self.Param.Harass:addParam("ManaE", "Set a value for (E) in Mana :", SCRIPT_PARAM_SLICE, 40, 0, 100);

	self.Param:addSubMenu("KillSteal Settings", "KillSteal");
		self.Param.KillSteal:addParam("E", "Use E :", SCRIPT_PARAM_ONOFF, true);

	self.Param:addSubMenu("JungleClear Settings", "JungleClear");
		self.Param.JungleClear:addParam("Q", "Use Q :", SCRIPT_PARAM_ONOFF, true);
		self.Param.JungleClear:addParam("ManaQ", "Set a value for (Q) in Mana :", SCRIPT_PARAM_SLICE, 40, 0, 100);
		self.Param.JungleClear:addParam("E", "Use E :", SCRIPT_PARAM_ONOFF, true);
		self.Param.JungleClear:addParam("Mod", "Set a mode :", SCRIPT_PARAM_LIST, 1, {"Everything", "Epic Only", "Buff Only", "Epic + Buffs", ""});
		self.Param.JungleClear:addParam("n1", "", SCRIPT_PARAM_INFO, "");
		self.Param.JungleClear:addParam("Early", "Enable Early Jungle Help Security :", SCRIPT_PARAM_ONOFF, true);

	self.Param:addSubMenu("LaneClear Settings", "WaveClear");
		self.Param.WaveClear:addParam("Q", "Use Q :", SCRIPT_PARAM_ONOFF, true);
		self.Param.WaveClear:addParam("ManaQ", "Set a value for (Q) in Mana :", SCRIPT_PARAM_SLICE, 40, 0, 100);

	self.Param:addSubMenu("LaneClear Settings (Against Champion)", "WaveClear2");
		self.Param.WaveClear2:addParam("Q", "Use Q :", SCRIPT_PARAM_ONOFF, true);
		self.Param.WaveClear2:addParam("ManaQ", "Set a value for (Q) in Mana :", SCRIPT_PARAM_SLICE, 60, 0, 100);

	self.Param:addSubMenu("Last Hit Settings", "LastHit");
		self.Param.LastHit:addParam("E", "Use E :", SCRIPT_PARAM_ONOFF, true);

	self.Param:addSubMenu("Extra Settings", "Extra");
		self.Param.Extra:addSubMenu("Ultimate Settings", "R");
			self.Param.Extra.R:addParam("n1", "soon", SCRIPT_PARAM_INFO, "");
		self.Param.Extra:addSubMenu("WallJump Settings", "WallJump");
			self.Param.Extra.WallJump:addParam("Key", "WallJump Key :", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("G"));
			self.Param.Extra.WallJump:addParam("n1", "", SCRIPT_PARAM_INFO, "");
			self.Param.Extra.WallJump:addParam("n2", "You need to hold the key and to go", SCRIPT_PARAM_INFO, "");
			self.Param.Extra.WallJump:addParam("n3", "through the wall and to release the key", SCRIPT_PARAM_INFO, "");
		self.Param.Extra:addSubMenu("Sentinel Settings", "W");
			self.Param.Extra.W:addParam("WDrake", "Cast W trick on drake :", SCRIPT_PARAM_ONOFF, false);
			self.Param.Extra.W:setCallback("WDrake", function(BaronW) if BaronW and self.W then CastSpell(_W, 9866.148, -71, 4414.014) self.Param.Extra.W.WDrake = false; end end);
			self.Param.Extra.W:addParam("WBaron", "Cast W trick on baron :", SCRIPT_PARAM_ONOFF, false);
			self.Param.Extra.W:setCallback("WBaron", function(BaronW) if BaronW and self.W then CastSpell(_W, 5007.124, -71, 10471.45) self.Param.Extra.W.WBaron = false; end end);
		self.Param.Extra:addSubMenu("", "n1");
		self.Param.Extra:addSubMenu("Auto Buy Settings", "AutoBuy");
			self.Param.Extra.AutoBuy:addParam("Enable", "Enable auto buy :", SCRIPT_PARAM_ONOFF, true);
			self.Param.Extra.AutoBuy:addParam("n0", "", SCRIPT_PARAM_INFO, "");
			self.Param.Extra.AutoBuy:addParam("Doran", "Buy doran blade :", SCRIPT_PARAM_ONOFF, true);
			self.Param.Extra.AutoBuy:addParam("Potion", "Buy a potion :", SCRIPT_PARAM_ONOFF, true);
			self.Param.Extra.AutoBuy:addParam("Trinket", "Buy a Yellow Trinket :", SCRIPT_PARAM_ONOFF, true);
			self.Param.Extra.AutoBuy:addParam("n1", "", SCRIPT_PARAM_INFO, "");
			self.Param.Extra.AutoBuy:addParam("BlueTrinket", "Buy Blue Trinket at lvl.9 :", SCRIPT_PARAM_ONOFF, true);
		self.Param.Extra:addSubMenu("Auto Level Spell Settings", "LVL");
			self.Param.Extra.LVL:addParam("Enable", "Use auto LVL spell :", SCRIPT_PARAM_ONOFF, true);
			self.Param.Extra.LVL:addParam("Combo", "Combo :", SCRIPT_PARAM_LIST, 1, {"E > Q > W", "E > W > Q"});
			self.Param.Extra.LVL:setCallback("Combo", function(SpellCombo) if VIP_USER then if SpellCombo then self:AutoLVLSpellCombo2(); else self:AutoLVLSpellCombo(); end end end);
		self.Param.Extra:addSubMenu("Item Settings", "Items");
			self.Param.Extra.Items:addParam("QSS", "Enable auto QSS :", SCRIPT_PARAM_ONOFF, true);
			self.Param.Extra.Items:addParam("QSSDelay", "Humanizer :", SCRIPT_PARAM_SLICE, 0, 0, 300, 10);
			self.Param.Extra.Items:addParam("QSSCombo", "Use only on combo mode", SCRIPT_PARAM_ONOFF, true);
			self.Param.Extra.Items:addParam("n1", "", SCRIPT_PARAM_INFO, "");
			self.Param.Extra.Items:addParam("POT", "Enable auto Potions :", SCRIPT_PARAM_ONOFF, true);
			self.Param.Extra.Items:addParam("POTCombo", "Use only on combo mode :", SCRIPT_PARAM_ONOFF, true);
			self.Param.Extra.Items:addParam("POTHP", "Set an %HP value :", SCRIPT_PARAM_SLICE, 60, 0, 100, 5);
			self.Param.Extra.Items:addParam("n2", "", SCRIPT_PARAM_INFO, "");
			self.Param.Extra.Items:addParam("WARD", "Enable auto ward :", SCRIPT_PARAM_ONOFF, true);
			self.Param.Extra.Items:addParam("WARDCombo", "Use only on combo mode :", SCRIPT_PARAM_ONOFF, true);

	self.Param:addSubMenu("Drawings Settings", "Draw");
		self.Param.Draw:addSubMenu("Spells Settings", "Spell");
			self.Param.Draw.Spell:addParam("Q", "Display Q :", SCRIPT_PARAM_ONOFF, false);
			self.Param.Draw.Spell:addParam("W", "Display W :", SCRIPT_PARAM_ONOFF, false);
			self.Param.Draw.Spell:addParam("E", "Display E :", SCRIPT_PARAM_ONOFF, false);
			self.Param.Draw.Spell:addParam("R", "Display R :", SCRIPT_PARAM_ONOFF, false);
			self.Param.Draw.Spell:addParam("n1", "", SCRIPT_PARAM_INFO, "");
			self.Param.Draw.Spell:addParam("AA", "Display Auto Attack :", SCRIPT_PARAM_ONOFF, false);
		self.Param.Draw:addSubMenu("Rend (_E) Settings", "Rend");
			self.Param.Draw.Rend:addParam("Enable", "Use rand drawing :", SCRIPT_PARAM_ONOFF, true);
			self.Param.Draw.Rend:addParam("n1", "", SCRIPT_PARAM_INFO, "");
			self.Param.Draw.Rend:addParam("n", "Draw at :", SCRIPT_PARAM_LIST, 1, {"Heroes & Mobs", "Heroes Only", "Mobs Only"});
			self.Param.Draw.Rend:addParam("c", "Method : ", SCRIPT_PARAM_LIST, 1, {"Percent", "AA Remaining", "Total Damages"});
		self.Param.Draw:addSubMenu("General Settings", "General");
			self.Param.Draw.General:addParam("Hitbox", "Display Hitbox :", SCRIPT_PARAM_ONOFF, true);
			self.Param.Draw.General:addParam("Target", "Display Target :", SCRIPT_PARAM_ONOFF, true);
		self.Param.Draw:addSubMenu("Misc Settings", "Misc");
			self.Param.Draw.Misc:addParam("SKIN", "Enable Skin Changer :", SCRIPT_PARAM_ONOFF, false);
			self.Param.Draw.Misc:setCallback("SKIN", function(skin) if skin then SetSkin(myHero, self.Param.Draw.Misc.skins-1); else SetSkin(myHero, -1); end end);
			self.Param.Draw.Misc:addParam("skins", "Set a skin :", SCRIPT_PARAM_LIST, 1, {"Classic", "Blood Moon", "Championship"});
			self.Param.Draw.Misc:setCallback("skins", function(skin) if skin then if self.Param.Draw.Misc.SKIN then SetSkin(myHero, self.Param.Draw.Misc.skins-1); end end end);
			self.Param.Draw.Misc:addParam("n1", "", SCRIPT_PARAM_INFO, "");
			self.Param.Draw.Misc:addParam("PermaShow", "Display PermaShow :", SCRIPT_PARAM_ONOFF, true);
			self.Param.Draw.Misc:addParam("Hour", "Display Time & Latency :", SCRIPT_PARAM_ONOFF, true);
		self.Param.Draw:addParam("Enable", "Enable Drawings :", SCRIPT_PARAM_ONOFF, true);

	self.Param:addParam("n1", "", SCRIPT_PARAM_INFO, "");
	self.Param:addParam("Pred", "Prediction :", SCRIPT_PARAM_LIST, 2, {"VPred", "HPred", "FHPred"});
	self.Param:setCallback("Pred", function(Pred)
		if Pred then
			self:Loader();
		else
			self:Loader();
		end
	end);

	enemyMinions = minionManager(MINION_ENEMY, 1150, myHero, MINION_SORT_HEALTH_ASC);
	jungleMinions = minionManager(MINION_JUNGLE, 1150, myHero, MINION_SORT_MAXHEALTH_DEC);
end

function Kalista:OnUpdateBuff(unit, buff, stacks)
	if buff.name == "kalistaexpungemarker" then
		self.Stacks[unit.networkID] = stacks;
	end
	if buff.name:lower() == "summonerexhaust" and unit.isMe then
		self.UnderExhaust = true;
	end
end

function Kalista:OnRemoveBuff(unit, buff)
	if buff.name == "kalistaexpungemarker" then
		self.Stacks[unit.networkID] = nil;
	end
	if buff.name:lower() == "summonerexhaust" and unit.isMe then
		self.UnderExhaust = false;
	end
end

function Kalista:OnProcessAttack(unit, spell)
	if unit and unit.isMe then
		if spell.name:lower():find("atta") then
			DelayAction(function()
				if self.Mode == "Combo" then
					if self.Q and self.Param.Combo.Q then
						self:CastQ(self.Target, "Combo");
					end
					if self.E then
						self:LogicE();
					end
				elseif self.Mode == "Harass" then
					if self.Q and self.Param.Harass.Q then
						self:CastQ(self.Target, "Harass");
					end
					if self.E and self.Param.Harass.E then
						self:LogicE();
					end
				elseif self.Mode == "LaneClear" then
					self:LaneClear();
				elseif self.Mode == "LastHit" then
					self:LastHit();
				end
			end, .05 + GetLatency() / 1000);
		end
	end
end

function Kalista:AutoE()
	if self.E then
		self:KillSteal();
		self:JungleKillSteal();
	end
end

function Kalista:KillSteal()
	if self.Param.KillSteal.E then
		for _, unit in pairs(GetEnemyHeroes()) do
			if GetDistanceSqr(unit) < 1000000 and not self:Immune(unit) and not unit.dead then
				if self:GetStacks(unit) > 0 then
					local dmg = self:eDmg(unit);
					if dmg > unit.health + unit.shield then
						CastSpell(_E);
					end
				end
			end
		end
	end
end

function Kalista:JungleKillSteal()
	if self.Param.JungleClear.E then
		if self.Param.JungleClear.Early and GetGameTimer() < 200 then
			return
		end
		for i, unit in pairs(jungleMinions.objects) do
			if self:GetStacks(unit) > 0 and GetDistanceSqr(unit) < 1000000 and not unit.dead then
				local dmg = self:eDmg(unit);
				if dmg > unit.health then
					if self.JungleClear[self.Param.JungleClear.Mod][unit.name] or (unit.charName:lower():find("dragon") and not self.Param.JungleClear.Mod == 3) then
						CastSpell(_E);
					end
				end
			end
		end
	end
end

function Kalista:LogicE()
	if self:Mana("Harass", "E") then
		enemyMinions:update();
		local ccount = 0;
		local ccount2 = 0;
		for i, unit in pairs(enemyMinions.objects) do
			if ValidTarget(unit) and not unit.dead and GetDistanceSqr(unit) < 1000000 and self:GetStacks(unit) > 0 then
				if self:eDmg(unit) > unit.health then
					ccount = ccount + 1;
				end
			end
		end
		for _, unit in pairs(GetEnemyHeroes()) do
			if ValidTarget(unit) and GetDistanceSqr(unit) < 1000000 and not unit.dead and self:GetStacks(unit) > 0 then
				ccount2 = ccount2 + 1;
			end
		end
		if ccount2 > 0 and ccount > 1 then
			CastSpell(_E);
		end
	end
end

function Kalista:LaneClear()
	if self.Q then
		if self.Param.JungleClear.Q then
			jungleMinions:update();
			for i, unit in pairs(jungleMinions.objects) do
				if unit.type == "obj_AI_Minion" and GetDistance(unit) < 1000 then
					self:CastQ(unit, "JungleClear");
				end
			end
		end
		if not self:EnemyInRange(myHero, 2000) and self.Param.WaveClear.Q then
			enemyMinions:update();
			for i, unit in pairs(enemyMinions.objects) do
				if unit.type == "obj_AI_Minion" and GetDistance(unit) < 1000 then
					self:CastQ(unit, "WaveClear");
				end
			end
		elseif self.Param.WaveClear2.Q then
			enemyMinions:update();
			for i, unit in pairs(enemyMinions.objects) do
				if unit.type == "obj_AI_Minion" and GetDistance(unit) < 1000 then
					self:CastQ(unit, "WaveClear2");
				end
			end
		end
	end
end

function Kalista:LastHit()
	if self.E and self.Param.LastHit.E then
		enemyMinions:update();
		local ccount = 0;
		for i, unit in pairs(enemyMinions.objects) do
			if ValidTarget(unit) then
				if self:GetStacks(unit) > 0 then
					if self:eDmg(unit) > unit.health then
						ccount = ccount + 1;
					end
				end
			end
		end
		if ccount > 1 then
			CastSpell(_E);
		end
	end
end

function Kalista:OnDraw()
	if self.Param.Draw.Enable then
		if self.Q and self.Param.Draw.Spell.Q then
			DrawCircle3D(myHero.x, myHero.y, myHero.z, 1150, 1, 0xFFFFFFFF);
		end
		if self.W and self.Param.Draw.Spell.W then
			DrawCircleMinimap(myHero.x, myHero.y, myHero.z, 5000);
		end
		if self.E and self.Param.Draw.Spell.E then
			DrawCircle3D(myHero.x, myHero.y, myHero.z, 1000, 1, 0xFFFFFFFF);
		end
		if self.R and self.Param.Draw.Spell.R then
			DrawCircle3D(myHero.x, myHero.y, myHero.z, 1100, 1, 0xFFFFFFFF);
		end
		if self.Param.Draw.Spell.AA then
			DrawCircle3D(myHero.x, myHero.y, myHero.z, myHero.range+myHero.boundingRadius, 1, 0xFFFFFFFF)
		end
		if self.Param.Draw.General.Hitbox then
			DrawCircle3D(myHero.x, myHero.y, myHero.z, myHero.boundingRadius, 1, 0xFFFFFFFF);
		end
		if self.Param.Draw.General.Target then
			if self.Target ~= nil then
				DrawText3D(">> TARGET <<", self.Target.x-100, self.Target.y-50, self.Target.z, 20, 0xFFFFFFFF);
				DrawText(""..self.Target.charName.."", 50, 50, 200, 0xFFFFFFFF);
			end
		end
		if self.Param.Draw.Misc.Hour then 
			DrawText(os.date("%A, %B %d %Y - %X - "..GetLatency().." ms"), 15, WINDOW_W/1.45, WINDOW_W/180, 0xFFFFFFFF);
		end
	end
end

function Kalista:RendDraw()
	if self.Param.Draw.Enable then
		if self.Param.Draw.Rend.Enable and self.E then
			local m = self.Param.Draw.Rend.c;
			if self.Param.Draw.Rend.n == 1 then
				for _, unit in pairs(GetEnemyHeroes()) do
					self:DrawRend(unit, m);
				end
				jungleMinions:update();
				for i, unit in pairs(jungleMinions.objects) do
					if self.JungleClear[self.Param.JungleClear.Mod][unit.name] or unit.charName:lower():find("dragon") then
						self:DrawRend(unit, m);
					end
				end
			elseif self.Param.Draw.Rend.n == 2 then
				for _, unit in pairs(GetEnemyHeroes()) do
					self:DrawRend(unit, m);
				end
			elseif self.Param.Draw.Rend.n == 3 then
				jungleMinions:update();
				for i, unit in pairs(jungleMinions.objects) do
					if self.JungleClear[self.Param.JungleClear.Mod][unit.name] or unit.charName:lower():find("dragon") then
						self:DrawRend(unit, m);
					end
				end
			end
		end
	end
end

function Kalista:DrawRend(unit, m)
	if self:GetStacks(unit) > 0 then
		local Center = GetUnitHPBarPos(unit);
		if Center.x > -100 and Center.x < WINDOW_W+100 and Center.y > -100 and Center.y < WINDOW_H+100 and unit.visible then
			local Edmg = self:eDmg(unit);
			local off = GetUnitHPBarOffset(unit);
			local y = Center.y + (off.y * 53) + 2;
			local xOff = ({['AniviaEgg'] = -0.1,['Darius'] = -0.05,['Renekton'] = -0.05,['Sion'] = -0.05,['Thresh'] = -0.03,})[unit.charName];
			local x = Center.x + ((xOff or 0) * 140) - 66;
			local dmg = unit.health - Edmg;
			DrawLine(x+(((dmg > 0 and dmg or 0) / unit.maxHealth) * 101), y-15, x+(((dmg > 0 and dmg or 0) / unit.maxHealth) * 104), y-15, 50, ARGB(255, 245, 215, 110));
			DrawLine(x + ((unit.health / unit.maxHealth) * 150), y-40, x+(((dmg > 0 and dmg or 0) / unit.maxHealth) * 104), y-40, 2, ARGB(255, 245, 215, 110));
			if m == 1 then -- perc
				local ePerc = self:ePercent(unit);
				if ePerc < 100 then
					DrawText(""..ePerc.."%", 40, x + ((unit.health /unit.maxHealth) * 155), y-52, 0xFFFFFFFF);
				else
					DrawText("Killable", 40, x + ((unit.health /unit.maxHealth) * 155), y-52, 0xFFFFFFFF);
				end
			elseif m == 2 then -- aa
				local myAA = math.floor(myHero.totalDamage * .9);
				local PerStack = math.floor(myHero:CalcDamage(unit, self:PerStack(unit) + myAA));
				local Y = unit.health - Edmg;
				local Z = math.round(Y / PerStack, 2);
				DrawText(""..Z.." aa", 40, x + ((unit.health /unit.maxHealth) * 155), y-52, 0xFFFFFFFF);
			elseif m == 3 then -- dmg
				DrawText(""..Edmg.." dmg", 40, x + ((unit.health /unit.maxHealth) * 155), y-52, 0xFFFFFFFF);
			end
		end
	end
end

function Kalista:Usepot()
	if self.Param.Extra.Items.POTCombo and self.Mode == "Combo" or not self.Param.Extra.Items.POTCombo then
		for SLOT = ITEM_1, ITEM_6 do
			if myHero:GetSpellData(SLOT).name == self.ActualPotData and not InFountain() then
				if myHero:CanUseSpell(SLOT) == READY and (myHero.health * 100) / myHero.maxHealth < self.Param.Extra.Items.POTHP and not InFountain() then
					CastSpell(SLOT);
					self.lastPotion = self.Time;
					self:Alerte("1x "..self.ActualPotName.." => Used.");
				end
			end
		end
	end
end

function Kalista:Var()
	self.Skills = {
		Q = {range = 1150, delay = .25, speed = 1750, width = 70, radius = 35};
		W = {range = 5000};
		E = {range = 1000, delay = .25};
		R = {range = 1100};
	};
	self.buffs = {
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
		["kindredrnodeathbuff"] = true,
		["meditate"] = true,
	}
	self.JungleClear = {
		{
			['SRU_RiftHerald17.1.1'] = {true}, ['SRU_Baron12.1.1'] = {true}, ['SRU_Red4.1.1'] = {true}, ['SRU_Blue1.1.1'] = {true}, ['SRU_Blue7.1.1'] = {true}, ['SRU_Red10.1.1'] = {true}, ['SRU_Krug5.1.2'] = {true}, ['SRU_Razorbeak3.1.1'] = {true}, ['Sru_Crab15.1.1'] = {true},  ['SRU_Murkwolf2.1.1'] = {true}, ['SRU_Gromp13.1.1'] = {true}, ['Sru_Crab16.1.1'] = {true}, ['SRU_Gromp14.1.1'] = {true}, ['SRU_Murkwolf8.1.1'] = {true}, ['SRU_Razorbeak9.1.1'] = {true}, ['SRU_Krug11.1.2'] = {true},
		},
		{
			['SRU_RiftHerald17.1.1'] = {true}, ['SRU_Baron12.1.1'] = {true}
		},
		{
			['SRU_Red4.1.1'] = {true}, ['SRU_Blue1.1.1'] = {true}, ['SRU_Blue7.1.1'] = {true}, ['SRU_Red10.1.1'] = {true},
		},
		{
			['SRU_RiftHerald17.1.1'] = {true}, ['SRU_Baron12.1.1'] = {true}, ['SRU_Red4.1.1'] = {true}, ['SRU_Blue1.1.1'] = {true}, ['SRU_Blue7.1.1'] = {true}, ['SRU_Red10.1.1'] = {true},
		}
	};
	self.Stacks = {};
	self.UnderExhaust = false;
	self.Time = os.clock();
	self.Last_LevelSpell = 0;
	self.lastPotion = 0;
	self.lastQSS = 0;
	self.ActualPotTime = 0;
	self.ActualPotName = nil;
	self.ActualPotData = nil;
	self.Q = false;
	self.W = false;
	self.E = false;
	self.R = false; 
	self.Current = false;
	self.endPos = nil;
	self.startPos = nil;
	self.started = false;
	self.Mode = nil;
	self.Target = nil;
end

function Kalista:VIPLoader()
	self:AutoLVLSpellCombo();
	self:AutoBuy();
	AddRemoveBuffCallback(function(unit, buff)
		if unit and unit.isMe and buff.name == "recall" then
			if self.Param.Extra.AutoBuy.Enable and InFountain() then 
				if self.Param.Extra.AutoBuy.BlueTrinket then
					BuyItem(3363);
				end
			end
		end
	end);
end

function Kalista:OnWndMsg(msg, key)
	if self.Q then
		if msg == 256 and key == self.Param.Extra.WallJump._param[1].key and not self.started then -- Pressing G
			self.Current = true;
			self.startPos = Vector(mousePos);
			if IsWall(D3DXVECTOR3(self.startPos.x, self.startPos.y, self.startPos.z)) then
				self:Alerte("There is a wall at startPos.");
				self.Current = false;
				self.startPos = nil;
			end
		elseif msg == 256 and key == self.Param.Extra.WallJump._param[1].key and self.started then
			self:Alerte("Canceled WallJump.");
			self.started = false;
			self.endPos = nil;
			self.startPos = nil;
			self.Current = false;
		end
		if msg == 257 and key == self.Param.Extra.WallJump._param[1].key and self.Current == true and not self.started then -- Release of G
			local End = Vector(mousePos);
			local Point1 = self.startPos + (End-self.startPos):normalized()*self:GetDashRange(); -- startPos + range
			if not IsWall(D3DXVECTOR3(Point1.x, Point1.y, Point1.z))  then
				self.Current = false;
				self.endPos = Vector(Point1);
				self.started = true;
			else
				self.Current = false;
				if IsWall(D3DXVECTOR3(Point1.x, Point1.y, Point1.z)) then
					self:Alerte("There is a wall at endPos");
				end
			end
		end
	end
end

function Kalista:WallJumpHopHop()
	if self.Current == false and self.started then
		if GetDistance(self.startPos) > 20 then
			myHero:MoveTo(self.startPos.x, self.startPos.z);
		else
			self.started = false;
			CastSpell(_Q, self.endPos.x, self.endPos.z);
			DelayAction(function()
				player:MoveTo(self.endPos.x, self.endPos.z);
			end, GetLatency() / 1000);
		end
	end
end

function Kalista:WallHOPDraw()
	if self.Param.Draw.Enable then
		if self.Current == false and self.started then
			DrawText3D("Press "..self:KeyConversion(self.Param.Extra.WallJump._param[1].key).." to cancel", myHero.x, myHero.y, myHero.z, 20, ARGB(255, 245, 215, 100));
			DrawText3D(math.round(GetDistance(self.startPos)/myHero.ms, 2).."s", self.startPos.x, self.startPos.y, self.startPos.z, 20, ARGB(255, 245, 215, 100));
			DrawCircle3D(self.startPos.x, self.startPos.y, self.startPos.z, 20 + myHero.boundingRadius, 1, ARGB(255, 245, 215, 110));
			DrawCircle3D(self.endPos.x, self.endPos.y, self.endPos.z, 20 + myHero.boundingRadius, 1, ARGB(255, 245, 215, 110));
			DrawLine3D(myHero.x, myHero.y, myHero.z, self.startPos.x, self.startPos.y, self.startPos.z, 1, ARGB(255, 245, 215, 110));
			DrawLine3D(self.startPos.x, self.startPos.y, self.startPos.z, self.endPos.x, self.endPos.y, self.endPos.z, 1, ARGB(255, 245, 215, 110));
		end
	end
end

function Kalista:Update()
	local version = "0.80001";
	local author = "spyk";
	local SCRIPT_NAME = "BaguetteKalista";
	local UPDATE_HOST = "raw.githubusercontent.com";
	local UPDATE_PATH = "/spyk1/BoL/master/BaguetteKalista.lua".."?rand="..math.random(1,10000);
	local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME;
	local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH;
	local ServerData = GetWebResult(UPDATE_HOST, "/spyk1/BoL/master/BaguetteKalista.version")
	if ServerData then
		ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil;
		if ServerVersion then
			if tonumber(version) < ServerVersion then
				self:Alerte("New version available "..ServerVersion);
				self:Alerte(">>Updating, please don't press F9<<");
				DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () self:Alerte("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3);
			else
				DelayAction(function() self:Alerte("Hello, "..GetUser()..". You got the latest version! ("..ServerVersion..")") end, 3);
				self:AfterUpdate();
			end
		end
	else
		self:Alerte("Error downloading version info");
	end
end

function Kalista:Loader()
    if self.Param.Pred == 1 then
        self:LoadVPred();
    elseif self.Param.Pred == 2 then
        self:LoadHPred();
    elseif self.Param.Pred == 3 then
        self:LoadFHPred();
    end
end

function Kalista:LoadVPred()
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

function Kalista:LoadHPred()
    if FileExist(LIB_PATH .. "/HPrediction.lua") then
        require("HPrediction");
        HPred = HPrediction();
        UseHP = true;
    else
        local Host = "raw.githubusercontent.com";
        local Path = "/BolHTTF/BoL/master/HTTF/Common/HPrediction.lua".."?rand="..math.random(1,10000);
        self:Alerte("HPred not found, downloading..");
        DownloadFile("https://"..Host..Path, LibPath, function ()  end);
        DelayAction(function () require("HPrediction") end, 5);
    end
end

function Kalista:LoadFHPred()
    if FileExist(LIB_PATH.."FHPrediction.lua") then
        require("FHPrediction");
    else
        self:Alerte("You don't have FHPred!");
        self.Param.Pred = 2;
        self:Loader();
    end
end

function Kalista:PermaShow(p)
    if self.Param.Draw.Misc.PermaShow then
        CustomPermaShow("                         - Baguette | Kalista - ", nil, true, nil, nil, nil, 0);
        CustomPermaShow("Current Mode :", ""..p, true, nil, nil, nil, 1);
        CustomPermaShow("", "", true, nil, nil, nil, 2);
        CustomPermaShow("By spyk ", " - 0.8", true, nil, nil, nil, 180);
    else
        CustomPermaShow("                         - Baguette | Kalista - ", nil, false, nil, nil, nil, 0);
        CustomPermaShow("Current Mode :", ""..p, false, nil, nil, nil, 1);
        CustomPermaShow("", "", false, nil, nil, nil, 2);
        CustomPermaShow("By spyk ", " - 0.8", false, nil, nil, nil, 180);
    end
end

function Kalista:Orbwalker()
	if _G.Reborn_Loaded ~= nil then
   	elseif _Pewalk then
	elseif _G.MMA_IsLoaded then
	else
		self:NebelOrb()
	end
end

function Kalista:NebelOrb()
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
