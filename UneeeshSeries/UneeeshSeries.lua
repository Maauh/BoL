local Version = 0.30
local FileName = GetCurrentEnv().FILE_NAME
local Debug = false

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

local Keys2={}

Keys2[8]='Back'
Keys2[9]='Tab'
Keys2[13]='Enter'
Keys2[16]='Shift'
Keys2[17]='Ctrl'
Keys2[18]='Alt'
Keys2[19]='Pause'
Keys2[20]='Capslock'
Keys2[21]='KanaMode'
Keys2[23]='JunjaMode'
Keys2[24]='FinalMode'
Keys2[25]='HanjaMode'
Keys2[27]='Esc'
Keys2[28]='IMEConvert'                                  
Keys2[29]='IMENonconvert'
Keys2[30]='IMEAceept'
Keys2[31]='IMEModeChange'
Keys2[32]='Space'
Keys2[33]='PageUp'
Keys2[34]='PageDown'
Keys2[35]='End'
Keys2[36]='Home'
Keys2[37]='Left'
Keys2[38]='Up'
Keys2[39]='Right'
Keys2[40]='Down'
Keys2[44]='PrintScreen'
Keys2[45]='Insert'
Keys2[46]='Delete'
Keys2[48]='0'
Keys2[49]='1'
Keys2[50]='2'
Keys2[51]='3'
Keys2[52]='4'
Keys2[53]='5'
Keys2[54]='6'
Keys2[55]='7'
Keys2[56]='8'
Keys2[57]='9'
Keys2[65]='A'
Keys2[66]='B'
Keys2[67]='C'
Keys2[68]='D'
Keys2[69]='E'
Keys2[70]='F'
Keys2[71]='G'
Keys2[72]='H'
Keys2[73]='I'
Keys2[74]='J'
Keys2[75]='K'
Keys2[76]='L'
Keys2[77]='M'
Keys2[78]='N'
Keys2[79]='O'
Keys2[80]='P'
Keys2[81]='Q'
Keys2[82]='R'
Keys2[83]='S'
Keys2[84]='T'
Keys2[85]='U'
Keys2[86]='V'
Keys2[87]='W'
Keys2[88]='X'
Keys2[89]='Y'
Keys2[90]='Z'
Keys2[91]='LWin'
Keys2[92]='RWin'
Keys2[93]='Apps'
Keys2[96]='NumPad0'
Keys2[97]='NumPad1'
Keys2[98]='NumPad2'
Keys2[99]='NumPad3'
Keys2[100]='NumPad4'
Keys2[101]='NumPad5'
Keys2[102]='NumPad6'
Keys2[103]='NumPad7'
Keys2[104]='NumPad8'
Keys2[105]='NumPad9'
Keys2[106]='Multiply'
Keys2[107]='Add'
Keys2[108]='Separator'
Keys2[109]='Subtract'
Keys2[110]='Decimal'
Keys2[111]='Divide'
Keys2[112]='F1'
Keys2[113]='F2'
Keys2[114]='F3'
Keys2[115]='F4'
Keys2[116]='F5'
Keys2[117]='F6'
Keys2[118]='F7'
Keys2[119]='F8'
Keys2[120]='F9'
Keys2[121]='F10'
Keys2[122]='F11'
Keys2[123]='F12'
Keys2[144]='NumLock'
Keys2[145]='ScrollLock'
Keys2[186]=';'
Keys2[187]='='
Keys2[188]=','
Keys2[189]='-'
Keys2[190]='.'
Keys2[191]='/'
Keys2[192]='Oemtilde'
Keys2[219]='OemOpenBrackets'
Keys2[220]='Oem5'
Keys2[221]='Oem6'
Keys2[222]="'"

org_txtKey= _G.scriptConfig._txtKey

_G.scriptConfig._txtKey =
function(self,key)
  return Keys2[key]
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

local Hero = {"Vayne", "Corki", "Ezreal", "Caitlyn"}

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

if not VIP_USER then
  print('<font color=\'#FF1493\'><b>[Uneeesh ADC Series]</b></font> <font color=\'#FF0000\'> Loading Failed. Required VIP.</font>')
  return
end

if not FileExist(LIB_PATH.."VPrediction.lua") then print('<font color=\'#FF1493\'><b>[Uneeesh ADC Series]</b></font> <font color=\'#FF0000\'> Loading Failed. Required VPrediction.</font>')
  return
end

if FileExist(LIB_PATH.."VPrediction.lua") then
require "VPrediction"
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

class("ScriptUpdate")

function ScriptUpdate:__init(LocalVersion, UseHttps, Host, VersionPath, ScriptPath, SavePath, CallbackUpdate, CallbackNoUpdate, CallbackNewVersion,CallbackError)
  self.LocalVersion = LocalVersion
  self.Host = Host
  self.VersionPath = '/BoL/TCPUpdater/GetScript' .. (UseHttps and '5' or '6') .. '.php?script=' .. self:Base64Encode(self.Host .. VersionPath) .. '&rand=' .. math.random(99999999)
  self.ScriptPath = '/BoL/TCPUpdater/GetScript' .. (UseHttps and '5' or '6') .. '.php?script=' .. self:Base64Encode(self.Host .. ScriptPath) .. '&rand=' .. math.random(99999999)
  self.SavePath = SavePath
  self.CallbackUpdate = CallbackUpdate
  self.CallbackNoUpdate = CallbackNoUpdate
  self.CallbackNewVersion = CallbackNewVersion
  self.CallbackError = CallbackError
  AddDrawCallback(function() self:OnDraw() end)
  self:CreateSocket(self.VersionPath)
  self.DownloadStatus = 'Connect to Server for VersionInfo'
  AddTickCallback(function() self:GetOnlineVersion() end)
end

function ScriptUpdate:print(str)
  print('<font color="#FFFFFF">' .. os.clock() .. ': ' .. str)
end

function ScriptUpdate:OnDraw()

  if self.DownloadStatus ~= 'Downloading Script (100%)' and self.DownloadStatus ~= 'Downloading VersionInfo (100%)' then
    DrawText('Download Status: ' .. (self.DownloadStatus or 'Unknown'), 40, 5, 40, ARGB(0xFF, 0, 0xFF, 0))
  end

end

function ScriptUpdate:CreateSocket(url)

  if not self.LuaSocket then
    self.LuaSocket = require("socket")
  else
    self.Socket:close()
    self.Socket = nil
    self.Size = nil
    self.RecvStarted = false
  end

  self.LuaSocket = require("socket")
  self.Socket = self.LuaSocket.tcp()
  self.Socket:settimeout(0, 'b')
  self.Socket:settimeout(99999999, 't')
  self.Socket:connect('sx-bol.eu', 80)
  self.Url = url
  self.Started = false
  self.LastPrint = ""
  self.File = ""
end

function ScriptUpdate:Base64Encode(data)

  local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

  return ((data:gsub('.', function(x)

    local r,b='',x:byte()

    for i=8, 1, -1 do
      r=r .. (b%2^i-b%2^(i-1)>0 and '1' or '0')
    end

    return r;
  end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)

    if (#x < 6) then
      return ''
    end

    local c=0

    for i = 1, 6 do
      c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0)
    end

    return b:sub(c+1,c+1)
  end) .. ({ '', '==', '=' })[#data%3+1])

end

function ScriptUpdate:GetOnlineVersion()

  if self.GotScriptVersion then
    return
  end

  self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)

  if self.Status == 'timeout' and not self.Started then
    self.Started = true
    self.Socket:send("GET " .. self.Url .. " HTTP/1.1\r\nHost: sx-bol.eu\r\n\r\n")
  end

  if (self.Receive or (#self.Snipped > 0)) and not self.RecvStarted then
    self.RecvStarted = true
    self.DownloadStatus = 'Downloading VersionInfo (0%)'
  end

  self.File = self.File .. (self.Receive or self.Snipped)

  if self.File:find('</s' .. 'ize>') then

    if not self.Size then
      self.Size = tonumber(self.File:sub(self.File:find('<si' .. 'ze>')+6, self.File:find('</si' .. 'ze>')-1))
    end

    if self.File:find('<scr' .. 'ipt>') then

      local _, ScriptFind = self.File:find('<scr' .. 'ipt>')
      local ScriptEnd = self.File:find('</scr' .. 'ipt>')

      if ScriptEnd then
        ScriptEnd = ScriptEnd-1
      end

      local DownloadedSize = self.File:sub(ScriptFind+1, ScriptEnd or -1):len()

      self.DownloadStatus = 'Downloading VersionInfo (' .. math.round(100/self.Size*DownloadedSize, 2) .. '%)'
    end

  end

  if self.File:find('</scr' .. 'ipt>') then
    self.DownloadStatus = 'Downloading VersionInfo (100%)'

    local a,b = self.File:find('\r\n\r\n')

    self.File = self.File:sub(a, -1)
    self.NewFile = ''

    for line,content in ipairs(self.File:split('\n')) do

      if content:len() > 5 then
        self.NewFile = self.NewFile .. content
      end

    end

    local HeaderEnd, ContentStart = self.File:find('<scr' .. 'ipt>')
    local ContentEnd, _ = self.File:find('</sc' .. 'ript>')

    if not (ContentStart and ContentEnd) then

      if self.CallbackError and type(self.CallbackError) == 'function' then
        self.CallbackError()
      end

    else
      self.OnlineVersion = (Base64Decode(self.File:sub(ContentStart+1,ContentEnd-1)))
      self.OnlineVersion = tonumber(self.OnlineVersion)

      if self.OnlineVersion > self.LocalVersion then

        if self.CallbackNewVersion and type(self.CallbackNewVersion) == 'function' then
          self.CallbackNewVersion(self.OnlineVersion, self.LocalVersion)
        end

        self:CreateSocket(self.ScriptPath)
        self.DownloadStatus = 'Connect to Server for ScriptDownload'
        AddTickCallback(function() self:DownloadUpdate() end)
      else

        if self.CallbackNoUpdate and type(self.CallbackNoUpdate) == 'function' then
          self.CallbackNoUpdate(self.LocalVersion)
        end

      end

    end

    self.GotScriptVersion = true
  end

end

function ScriptUpdate:DownloadUpdate()

  if self.GotScriptUpdate then
    return
  end

  self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)

  if self.Status == 'timeout' and not self.Started then
    self.Started = true
    self.Socket:send("GET " .. self.Url .. " HTTP/1.1\r\nHost: sx-bol.eu\r\n\r\n")
  end

  if (self.Receive or (#self.Snipped > 0)) and not self.RecvStarted then
    self.RecvStarted = true
    self.DownloadStatus = 'Downloading Script (0%)'
  end

  self.File = self.File .. (self.Receive or self.Snipped)

  if self.File:find('</si' .. 'ze>') then

    if not self.Size then
      self.Size = tonumber(self.File:sub(self.File:find('<si' .. 'ze>')+6, self.File:find('</si' .. 'ze>')-1))
    end

    if self.File:find('<scr' .. 'ipt>') then

      local _, ScriptFind = self.File:find('<scr' .. 'ipt>')
      local ScriptEnd = self.File:find('</scr' .. 'ipt>')

      if ScriptEnd then
        ScriptEnd = ScriptEnd-1
      end

      local DownloadedSize = self.File:sub(ScriptFind+1, ScriptEnd or -1):len()

      self.DownloadStatus = 'Downloading Script (' .. math.round(100/self.Size*DownloadedSize, 2) .. '%)'
    end

  end

  if self.File:find('</scr' .. 'ipt>') then
    self.DownloadStatus = 'Downloading Script (100%)'

    local a,b = self.File:find('\r\n\r\n')

    self.File = self.File:sub(a, -1)
    self.NewFile = ''

    for line,content in ipairs(self.File:split('\n')) do

      if content:len() > 5 then
        self.NewFile = self.NewFile .. content
      end

    end

    local HeaderEnd, ContentStart = self.NewFile:find('<sc' .. 'ript>')
    local ContentEnd, _ = self.NewFile:find('</scr' .. 'ipt>')

    if not (ContentStart and ContentEnd) then

      if self.CallbackError and type(self.CallbackError) == 'function' then
        self.CallbackError()
      end

    else

      local newf = self.NewFile:sub(ContentStart+1,ContentEnd-1)
      local newf = newf:gsub('\r','')

      if newf:len() ~= self.Size then

        if self.CallbackError and type(self.CallbackError) == 'function' then
          self.CallbackError()
        end

        return
      end

      local newf = Base64Decode(newf)

      if type(load(newf)) ~= 'function' then

        if self.CallbackError and type(self.CallbackError) == 'function' then
          self.CallbackError()
        end

      else

        local f = io.open(self.SavePath,"w+b")

        f:write(newf)
        f:close()

        if self.CallbackUpdate and type(self.CallbackUpdate) == 'function' then
          self.CallbackUpdate(self.OnlineVersion, self.LocalVersion)
        end

      end

    end

    self.GotScriptUpdate = true
  end

end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function Update()

  local Script = {}

  Script.Host = "raw.githubusercontent.com"
  Script.VersionPath = "/Project4706/BoL/master/UneeeshSeries.version"
  Script.Path = "/Project4706/BoL/master/UneeeshSeries.lua"
  Script.SavePath = SCRIPT_PATH .. FileName
  Script.CallbackUpdate = function(NewVersion, OldVersion) ScriptMsg("Updated to (" .. NewVersion .. "). Please reload script.") end
  Script.CallbackNoUpdate = function(OldVersion) ScriptMsg("No Updates Found.") end
  Script.CallbackNewVersion = function(NewVersion) ScriptMsg("New Version found (" .. NewVersion .. "). Please wait until its downloaded.") end
  Script.CallbackError = function(NewVersion) ErrorMsg("Error while Downloading. Please try again.") end
  ScriptUpdate(Version, true, Script.Host, Script.VersionPath, Script.Path, Script.SavePath, Script.CallbackUpdate,Script.CallbackNoUpdate, Script.CallbackNewVersion,Script.CallbackError)
end
---------------------------------------------------------------------------------==============================================================================================================================
---------------------------------------------------------------------------------==============================================================================================================================
---------------------------------------------------------------------------------==============================================================================================================================

if myHero.charName == Hero[1] then


function ScriptMsg(msg)
  print("<font color=\"#FF1493\">[Uneeesh Series - Vayne]</b></font>  <font color=\"#FFFF00\">".. msg .."</font>")
end

function ErrorMsg(msg)
  print("<font color=\"#FF1493\">[Uneeesh Series - Vayne]</b></font>  <font color=\"#FF0000\">".. msg .."</font>")
end

if FileExist(LIB_PATH.."FHPrediction.lua") then
require "FHPrediction"
end

if not FileExist(LIB_PATH.."FHPrediction.lua") and not FHPrediction.IsAuthed() then ErrorMsg("Loading Failed. Required FHPrediction.")
  return
end

local Q, W, E, R, I = {}, {}, {}, {}, {}
local Loaded = false
local lasttime = {}
local Wstacks = {}
local lastTime = 0
local DisableAA = false
local ActiveR = false
local LastLevelCheck = 0
local lastpos = {}
local lastRemove = 0
local spellExpired = true
local function Slot(name)
  if myHero:GetSpellData(SUMMONER_1).name:lower():find(name) then
    return SUMMONER_1
  elseif myHero:GetSpellData(SUMMONER_2).name:lower():find(name) then
    return SUMMONER_2
  end
end
local function dChat()
  chat1B = _G.print
  chat2B = _G.PrintChat
  _G.print = function() end
  _G.PrintChat = function() end
  DisableOverlay()
  ChatOff = true
end
local function eChat()
  _G.print = chat1B
  _G.PrintChat = chat2B
  EnableOverlay()
  ChatOff = false
end
local ts = TargetSelector(TARGET_LESS_CAST, 1453, DAMAGE_PHYSICAL, true)
local eRange, eSpeed, eDelay, eRadius = 1000, 2200, 0.30, nil
local ToInterrupt = {}
local InterruptList = {
    { charName = "Caitlyn", spellName = "CaitlynAceintheHole"},
    { charName = "FiddleSticks", spellName = "Crowstorm"},
    { charName = "FiddleSticks", spellName = "DrainChannel"},
    { charName = "Galio", spellName = "GalioIdolOfDurand"},
    { charName = "Karthus", spellName = "FallenOne"},
    { charName = "Katarina", spellName = "KatarinaR"},
    { charName = "Lucian", spellName = "LucianR"},
    { charName = "Malzahar", spellName = "AlZaharNetherGrasp"},
    { charName = "MissFortune", spellName = "MissFortuneBulletTime"},
    { charName = "Nunu", spellName = "AbsoluteZero"},                            
    { charName = "Pantheon", spellName = "Pantheon_GrandSkyfall_Jump"},
    { charName = "Shen", spellName = "ShenStandUnited"},
    { charName = "Urgot", spellName = "UrgotSwap2"},
    { charName = "Varus", spellName = "VarusQ"},
    { charName = "Warwick", spellName = "InfiniteDuress"},
    { charName = "Velkoz", spellName = "VelkozR"}
}

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function OnLoad()
  
  ItemNames       = {
    [3303]        = "ArchAngelsDummySpell",
    [3007]        = "ArchAngelsDummySpell",
    [3144]        = "BilgewaterCutlass",
    [3188]        = "ItemBlackfireTorch",
    [3153]        = "ItemSwordOfFeastAndFamine",
    [3405]        = "TrinketSweeperLvl1",
    [3411]        = "TrinketOrbLvl1",
    [3166]        = "TrinketTotemLvl1",
    [3450]        = "OdinTrinketRevive",
    [2054]        = "ItemKingPoroSnack",
    [2138]        = "ElixirOfIron",
    [2137]        = "ElixirOfRuin",
    [2139]        = "ElixirOfSorcery",
    [2140]        = "ElixirOfWrath",
    [3184]        = "OdinEntropicClaymore",
    [2050]        = "ItemMiniWard",
    [3401]        = "HealthBomb",
    [3363]        = "TrinketOrbLvl3",
    [3092]        = "ItemGlacialSpikeCast",
    [3460]        = "AscWarp",
    [3361]        = "TrinketTotemLvl3",
    [3362]        = "TrinketTotemLvl4",
    [3159]        = "HextechSweeper",
    [2051]        = "ItemHorn",
    [3146]        = "HextechGunblade",
    [3187]        = "HextechSweeper",
    [3190]        = "IronStylus",
    [3139]        = "ItemMercurial",
    [3222]        = "ItemMorellosBane",
    [3042]        = "Muramana",
    [3043]        = "Muramana",
    [3180]        = "OdynsVeil",
    [3056]        = "ItemFaithShaker",
    [2047]        = "OracleExtractSight",
    [3364]        = "TrinketSweeperLvl3",
    [2052]        = "ItemPoroSnack",
    [3140]        = "QuicksilverSash",
    [3143]        = "RanduinsOmen",
    [3074]        = "ItemTiamatCleave",
    [5000]        = "ItemTitanicHydraCleave",
    [3800]        = "ItemRighteousGlory",
    [2045]        = "ItemGhostWard",
    [3342]        = "TrinketOrbLvl1",
    [3040]        = "ItemSeraphsEmbrace",
    [3048]        = "ItemSeraphsEmbrace",
    [2049]        = "ItemGhostWard",
    [3345]        = "OdinTrinketRevive",
    [2044]        = "SightWard",
    [3341]        = "TrinketSweeperLvl1",
    [3069]        = "shurelyascrest",
    [3599]        = "KalistaPSpellCast",
    [3185]        = "HextechSweeper",
    [3077]        = "ItemTiamatCleave",
    [2009]        = "ItemMiniRegenPotion",
    [2010]        = "ItemMiniRegenPotion",
    [3023]        = "ItemWraithCollar",
    [3290]        = "ItemWraithCollar",
    [2043]        = "VisionWard",
    [3340]        = "TrinketTotemLvl1",
    [3090]        = "ZhonyasHourglass",
    [3154]        = "wrigglelantern",
    [3142]        = "YoumusBlade",
    [3157]        = "ZhonyasHourglass",
    [3512]        = "ItemVoidGate",
    [3131]        = "ItemSoTD",
    [3137]        = "ItemDervishBlade",
    [3352]        = "RelicSpotter",
    [3350]        = "TrinketTotemLvl2",
    [3085]        = "AtmasImpalerDummySpell",
  }

  Items = {
    ["ELIXIR"]      = { id = 2140, range = 2140, target = false},
    ["QSS"]         = { id = 3140, range = 2500, target = false},
    ["MercScim"]  = { id = 3139, range = 2500, target = false},
    ["BRK"]     = { id = 3153, range = 550, target = true},
    ["BWC"]     = { id = 3144, range = 550, target = true},
    ["HXG"]     = { id = 3146, range = 700, target = false},
    ["ODYNVEIL"]  = { id = 3180, range = 525, target = false},
    ["DVN"]     = { id = 3131, range = 200, target = false},
    ["ENT"]     = { id = 3184, range = 350, target = false},
    ["HYDRA"]   = { id = 3074, range = 350, target = false},
    ["TIAMAT"]    = { id = 3077, range = 350, target = false},
    ["TITANIC"]   = { id = 5000, range = 350, target = false},
    ["RanduinsOmen"]  = { id = 3143, range = 500, target = false},
    ["YGB"]     = { id = 3142, range = 600, target = false},
    ["HEX"]     = { id = 5555, range = 600, target = false},
  }

  AutoLevelSpellTable = {
        ['SpellOrder']  = {'QWE', 'QEW', 'WQE', 'WEQ', 'EQW', 'EWQ'},
        ['QWE'] = {_Q,_W,_E,_Q,_Q,_R,_Q,_W,_Q,_W,_R,_W,_W,_E,_E,_R,_E,_E},
        ['QEW'] = {_Q,_E,_W,_Q,_Q,_R,_Q,_E,_Q,_E,_R,_E,_E,_W,_W,_R,_W,_W},
        ['WQE'] = {_W,_Q,_E,_W,_W,_R,_W,_Q,_W,_Q,_R,_Q,_Q,_E,_E,_R,_E,_E},
        ['WEQ'] = {_W,_E,_Q,_W,_W,_R,_W,_E,_W,_E,_R,_E,_E,_Q,_Q,_R,_Q,_Q},
        ['EQW'] = {_E,_Q,_W,_E,_E,_R,_E,_Q,_E,_Q,_R,_Q,_Q,_W,_W,_R,_W,_W},
        ['EWQ'] = {_E,_W,_Q,_E,_E,_R,_E,_W,_E,_W,_R,_W,_W,_Q,_Q,_R,_Q,_Q}
    }

  ___GetInventorySlotItem = rawget(_G, "GetInventorySlotItem")
  _G.GetInventorySlotItem = GetSlotItem
  if myHero:GetSpellData(4).name:lower():find("exhaust") then
    exhaust = { slot = 4, key = "D", range =  650, ready = false }
  elseif myHero:GetSpellData(5).name:lower():find("exhaust") then
    exhaust = { slot = 5, key = "F", range =  650, ready = false }
  end
  checkDistance = 3000 * 3000
  SummonerSlot = Slot("summonerboost")
  ignite = Slot("summonerdot")
  heal = HealSlot()
  Update()
  Variables()
  VayneMenu()
  SkinLoad()
  DelayAction(function()LoadOrbwalk() end, 1)
  DelayAction(function()AutoBuy()end, 3)
  Loaded = true
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function Variables()

  SACLoaded, PEWLoaded, MMALoaded, SxOrbLoaded = false, false, false, false
  
  Q = {range = 250}
  W = {}
  E = {range = 800}
  R = {}
  I = {range = 600}
  
  S5SR = false
  TT = false
  
  if GetGame().map.index == 15 then
    S5SR = true
  elseif GetGame().map.index == 4 then
    TT = true
  end
  
  if S5SR then
    FocusJungleNames =
    {
    "SRU_Blue1.1.1",
    "SRU_Blue7.1.1",
    "Sru_Crab15.1.1",
    "Sru_Crab16.1.1",
    "SRU_Gromp13.1.1",
    "SRU_Gromp14.1.1",
    "SRU_Krug5.1.2",
    "SRU_Krug11.1.2",
    "SRU_Murkwolf2.1.1",
    "SRU_Murkwolf8.1.1",
    "SRU_Razorbeak3.1.1",
    "SRU_Razorbeak9.1.1",
    "SRU_Red4.1.1",
    "SRU_Red10.1.1"
    }
  JungleMobNames =
    {
    "SRU_BlueMini1.1.2",
    "SRU_BlueMini7.1.2",
    "SRU_BlueMini21.1.3",
    "SRU_BlueMini27.1.3",
    "SRU_KrugMini5.1.1",
    "SRU_KrugMini11.1.1",
    "SRU_MurkwolfMini2.1.2",
    "SRU_MurkwolfMini2.1.3",
    "SRU_MurkwolfMini8.1.2",
    "SRU_MurkwolfMini8.1.3",
    "SRU_RazorbeakMini3.1.2",
    "SRU_RazorbeakMini3.1.3",
    "SRU_RazorbeakMini3.1.4",
    "SRU_RazorbeakMini9.1.2",
    "SRU_RazorbeakMini9.1.3",
    "SRU_RazorbeakMini9.1.4",
    "SRU_RedMini4.1.2",
    "SRU_RedMini4.1.3",
    "SRU_RedMini10.1.2",
    "SRU_RedMini10.1.3"
    }
  elseif TT then
    FocusJungleNames =
    {
    "TT_NWraith1.1.1",
    "TT_NGolem2.1.1",
    "TT_NWolf3.1.1",
    "TT_NWraith4.1.1",
    "TT_NGolem5.1.1",
    "TT_NWolf6.1.1",
    "TT_Spiderboss8.1.1"
    }   
    JungleMobNames =
    {
    "TT_NWraith21.1.2",
    "TT_NWraith21.1.3",
    "TT_NGolem22.1.2",
    "TT_NWolf23.1.2",
    "TT_NWolf23.1.3",
    "TT_NWraith24.1.2",
    "TT_NWraith24.1.3",
    "TT_NGolem25.1.1",
    "TT_NWolf26.1.2",
    "TT_NWolf26.1.3"
    }
  else
    FocusJungleNames =
    {
    }   
    JungleMobNames =
    {
    }
  end

  for _, enemy in ipairs(GetEnemyHeroes()) do
    Wstacks[enemy.networkID] = 0
  end
  VPred = VPrediction()
  EnemyHeroes = GetEnemyHeroes()
  EnemyMinions = minionManager(MINION_ENEMY, 550, myHero, MINION_SORT_MAXHEALTH_DEC)
  JungleMobs = minionManager(MINION_JUNGLE, 550, myHero, MINION_SORT_MAXHEALTH_DEC)
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function VayneMenu()

    Menu = scriptConfig("Uneeesh Vayne", "UV_MAIN")
    
    Menu:addSubMenu("[Vayne]: Control Settings", "Control")
    Menu.Control:addParam("OnC", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
    Menu.Control:addParam("OnF", "LaneClear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
    Menu.Control:addParam("OnJF", "JungleClear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
    Menu.Control:addParam("eafteraakey", "Condemn after Next AA", SCRIPT_PARAM_ONKEYTOGGLE, false, GetKey("E"))
    Menu.Control:addParam("AGP", "Anti-GapCloser Toggle", SCRIPT_PARAM_ONKEYTOGGLE, true, GetKey("J"))  
    Menu.Control:addParam("Interrupt", "Interrupt Spells Toggle", SCRIPT_PARAM_ONKEYTOGGLE, true, GetKey("Y"))
    Menu.Control:addParam("autoWallCondemn", "Wall-Condemn Toggle", SCRIPT_PARAM_ONKEYTOGGLE, true, GetKey("N"))
    Menu.Control.autoWallCondemn = true
    Menu.Control:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Control:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")

    Menu:addSubMenu("[Vayne]: Condemn Settings", "Condemn")
    Menu.Condemn:addParam("wcdmethod", "Wall-Condemn Method", SCRIPT_PARAM_LIST, 1, {"Smart Multi-Spot", "High Frequance"})
    Menu.Condemn:addSubMenu("WhiteList to Wall-Condemn", "condemnSubMenu")   
    Menu.Condemn:addParam("MaxDistance", "Multi-Spot Prediction Distance", SCRIPT_PARAM_SLICE, 900, 250, 1000, 0)
  Menu.Condemn:addParam("CheckDistance", "Multi-spot check Distance", SCRIPT_PARAM_SLICE, 25, 1, 200, 0)
  Menu.Condemn:addParam("Checks", "Enemy check to Wall-Condemn", SCRIPT_PARAM_SLICE, 2, 0, 5, 0)
    for i, enemy in ipairs(EnemyHeroes) do
    Menu.Condemn.condemnSubMenu:addParam("enableCondemn"..i, " >> "..enemy.charName, SCRIPT_PARAM_ONOFF, true)
    Menu.Condemn["enableCondemn"..i] = true
    end
    Menu.Condemn:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Condemn:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
   
    Menu:addSubMenu("[Vayne]: Combo Settings", "Combo")
    Menu.Combo:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addParam("R", "Use R", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addParam("focus", "Left Click Focus Target", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addParam("vision", "Auto vision on Bush", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addParam("qforgap", "Use Q For Gapcloser", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addParam("qmethod", "Q Method", SCRIPT_PARAM_LIST, 1, {"AA Reset", "Passive Proc."})
    Menu.Combo:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    
    Menu:addSubMenu("[Vayne]: Ultimate Settings", "ultimate")
    Menu.ultimate:addParam("enemy", "Enemies in range for R", SCRIPT_PARAM_SLICE, 3, 1, 5, 0)
    Menu.ultimate:addParam("ally", "Allies in range for R", SCRIPT_PARAM_SLICE, 2, 0, 5, 0)
    Menu.ultimate:addParam("hp", "Min. own % Health to use", SCRIPT_PARAM_SLICE, 65, 1, 100, 0)
    Menu.ultimate:addParam("minblock", "Stay invis. if enemy around", SCRIPT_PARAM_SLICE, 3, 0, 5, 0)
    Menu.ultimate:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.ultimate:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")

    Menu:addSubMenu("[Vayne]: LaneClear Settings", "Farm")
    Menu.Farm:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
    Menu.Farm:addParam("Q2", "Use if Mana Percent > % >", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
    Menu.Farm:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Farm:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")

    Menu:addSubMenu("[Vayne]: JungleClear Settings", "JFarm")
    Menu.JFarm:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
    Menu.JFarm:addParam("Q2", "Use if Mana Percent > % >", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
    Menu.JFarm:addParam("E", "Wall-Condemn on Large Junglemob", SCRIPT_PARAM_ONOFF, true)
    Menu.JFarm:addParam("E2", "Use if Mana Percent > % >", SCRIPT_PARAM_SLICE, 30, 0, 100, 0)
    Menu.JFarm:addParam("E3", "Disable E if my level > x >", SCRIPT_PARAM_SLICE, 9, 4, 16, 0)
    Menu.JFarm:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.JFarm:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    
    Menu:addSubMenu("[Vayne]: Display Settings", "Draw")
    Menu.Draw:addParam("On", "Enable Draws", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("AA", "Draw AA range", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("CLA", "Color AA range", SCRIPT_PARAM_COLOR, {144, 144, 40, 164})
    Menu.Draw:addParam("Q", "Draw Q range", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("CLQ", "Color Q range", SCRIPT_PARAM_COLOR, {141, 23, 123, 22})
    Menu.Draw:addParam("E", "Draw E range", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("CLE", "Color E range", SCRIPT_PARAM_COLOR, {141, 31, 69, 123})
    if ignite then
    Menu.Draw:addParam("I", "Draw Ignite range", SCRIPT_PARAM_ONOFF, false)
    Menu.Draw:addParam("CLI", "Color Ignite range", SCRIPT_PARAM_COLOR, {141, 124, 114, 114})
    end
    Menu.Draw:addParam("CLFPS", "Enable FPS Friendly Draws", SCRIPT_PARAM_ONOFF, false)
    Menu.Draw:addParam("Quality", "FPS Draws Quality(High=Better FPS)", SCRIPT_PARAM_SLICE, 176, 75, 2000, 0)
    Menu.Draw:addParam("Trg", "Draw Current Target", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("CondemnAssistant", "Wall-Condemn Assistance", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("ownp", "Enable Pathway Draw", SCRIPT_PARAM_ONOFF, false)
    Menu.Draw:addParam("opp", "Draw Enemy Pathway", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("Info","", SCRIPT_PARAM_INFO, "")
    Menu.Draw:addParam("stream", "Enable Streaming Mode", SCRIPT_PARAM_ONKEYTOGGLE, false, 118)
    Menu.Draw:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Draw:addParam("Info1", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    
    Menu:addSubMenu("[Vayne]: Item&Summoner Settings", "Items")
    Menu.Items:addSubMenu("BotRK", "BotRK")
    Menu.Items.BotRK:addParam("bork", "Use BotRK", SCRIPT_PARAM_ONOFF, true)
    Menu.Items.BotRK:addParam('maxownhealth', 'Max. own % Health to use', SCRIPT_PARAM_SLICE, 50, 1, 100, 0)
    Menu.Items.BotRK:addParam('minenemyhealth', 'Min. enemy % Health to use', SCRIPT_PARAM_SLICE, 20, 1, 100, 0)
    Menu.Items:addSubMenu("Bilgewater", "Bilgewater")
    Menu.Items.Bilgewater:addParam("bilg", "Use Bilgewater", SCRIPT_PARAM_ONOFF, true)
    Menu.Items.Bilgewater:addParam("maxownhealth", "Max. own % Health to use", SCRIPT_PARAM_SLICE, 50, 1, 100, 0)
    Menu.Items.Bilgewater:addParam("minenemyhealth", "Min. enemy % Health to use", SCRIPT_PARAM_SLICE, 20, 1, 100, 0)
    --Menu.Items:addSubMenu("Youmuu", "Youmuu")
    --Menu.Items.Youmuu:addParam("yomu", "Use Youmuu", SCRIPT_PARAM_ONOFF, true)

    Menu.Items:addSubMenu("Health Potions", "potion")
    Menu.Items.potion:addParam("Key", "Use Only Press to", SCRIPT_PARAM_ONKEYDOWN, false, 32)
    Menu.Items.potion:addParam("Always", "Use Always", SCRIPT_PARAM_ONOFF, false)
    Menu.Items.potion:addParam("enemy", "Use if not enemies", SCRIPT_PARAM_ONOFF, false)
    Menu.Items.potion:addParam("health", "If My Health % is <", SCRIPT_PARAM_SLICE, 60, 0, 100, 0) 
    Menu.Items:addSubMenu("Remove CC", "cc")
    Menu.Items.cc:addParam("Key", "Use Only Press to", SCRIPT_PARAM_ONKEYDOWN, false, 32)
    Menu.Items.cc:addParam("Always", "Use Always", SCRIPT_PARAM_ONOFF, true) 
    if SummonerSlot then
    Menu.Items.cc:addParam("Summoner", "Use Cleanse", SCRIPT_PARAM_ONOFF, true) 
    end
    Menu.Items.cc:addParam("delay", "Remove Delay (ms)", SCRIPT_PARAM_SLICE, 0, 0, 400, 0)
    if ignite then
    Menu.Items:addSubMenu("Ignite", "ignite")
    Menu.Items.ignite:addParam("set", "Use Smart Ignite", SCRIPT_PARAM_LIST, 2, {"OFF", "Optimal", "Aggressive"})
    end
    if exhaust then 
    Menu.Items:addSubMenu("Exhaust", "exhaust")
    Menu.Items.exhaust:addParam("exh", "Exhaust Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey(exhaust.key))
    Menu.Items:addTS(TES)
    TES = TargetSelector(TARGET_PRIORITY, 600, DAMAGE_MAGIC) 
    TES.name = "Exhaust"
    end
    if heal then
    Menu.Items:addSubMenu("Heal/Barrier", "heal")
    Menu.Items.heal:addParam("enable", "Enable to use", SCRIPT_PARAM_ONOFF, true)
    Menu.Items.heal:addParam("health", "If My Health % is Less Than", SCRIPT_PARAM_SLICE, 10, 0, 100, 0)
    if realheals then
    Menu.Items.heal:addParam("ally", "Use for Ally", SCRIPT_PARAM_ONOFF, false)
    end
    end 
    Menu.Items:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Items:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    
    Menu:addSubMenu("[Vayne]: Automation", "Autom")
    Menu.Autom:addSubMenu("AutoLevelSpells Settings", "autolevel")
    Menu.Autom.autolevel:addParam("UseAutoLevelFirst", "Use AutoLevelSpells Level 1-3", SCRIPT_PARAM_ONOFF, false)
    Menu.Autom.autolevel:addParam("UseAutoLevelRest", "Use AutoLevelSpells Level 4-18", SCRIPT_PARAM_ONOFF, false)
    Menu.Autom.autolevel:addParam("First3Level", "Level 1-3", SCRIPT_PARAM_LIST, 1, {"Q-W-E", "Q-E-W", "W-Q-E", "W-E-Q", "E-Q-W", "E-W-Q"})
    Menu.Autom.autolevel:addParam("RestLevel", "Level 4-18", SCRIPT_PARAM_LIST, 1, {"Q-W-E", "Q-E-W", "W-Q-E", "W-E-Q", "E-Q-W", "E-W-Q"})
    Menu.Autom.autolevel:addParam("Blank", "", SCRIPT_PARAM_INFO, "","" )
    Menu.Autom.autolevel:addParam("Blank", "You can Click on the Q-W-E", SCRIPT_PARAM_INFO, "","" )
    Menu.Autom.autolevel:addParam("Blank", "to change the AutoLevelOrder", SCRIPT_PARAM_INFO, "","" )
    Menu.Autom:addSubMenu("Skin Changer", "ChgSki")
    Menu.Autom:addSubMenu("Auto Buy Item", "buyme")
    Menu.Autom.buyme:addParam("buydoran", "Doran's Blade", SCRIPT_PARAM_ONOFF, true)
    Menu.Autom.buyme:addParam("buypot", "Potion", SCRIPT_PARAM_ONOFF, true)
    Menu.Autom.buyme:addParam("taketrinket", "Green Trinket", SCRIPT_PARAM_ONOFF, true)
    Menu.Autom.buyme:addParam("changeblue", "Lvl 9 Blue Trinket", SCRIPT_PARAM_ONOFF, true)
    Menu.Autom:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Autom:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
  

    Menu:addSubMenu("[Vayne]: Orbwalker Settings", "Orbwalker")
    Menu:addTS(ts)
    ts.name = "[Vayne]"
    
    
  Menu:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
  Menu:addParam("Info", "http://botoflegends.com", SCRIPT_PARAM_INFO, "")
  Menu:addParam("SVersion", "Script Version ", SCRIPT_PARAM_LIST, 1, {"" .. Version})
  Menu:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
  Menu:addParam("popup", "Click For Latest Changelog", SCRIPT_PARAM_ONOFF, false)

  Menu.Control:permaShow("autoWallCondemn")
  Menu.Control:permaShow("Interrupt")
  Menu.Control:permaShow("AGP")
  Menu.Condemn:permaShow("wcdmethod")
  Menu.Combo:permaShow("qmethod")

    Menu.Control.OnC = false
    Menu.Control.OnF = false
    Menu.Control.OnJF = false

  for i = 1, heroManager.iCount, 1 do
        local enemy = heroManager:getHero(i)
        if enemy.team ~= myHero.team then
            for _, champ in pairs(InterruptList) do
                if enemy.charName == champ.charName then
                    table.insert(ToInterrupt, champ.spellName)
                end
            end
        end
    end
end

---------------------------------------------------------------------------------

function LoadOrbwalk()

  if _G.AutoCarry and _G.Reborn_Initialised then
    SACLoaded = true
    Menu.Orbwalker:addParam("Info", "             ----->>> SAC Detected & Loaded <<<-----   ", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    ScriptMsg("Sida's Auto Carry Detected.")
  elseif _G.Reborn_Loaded then
    DelayAction(function() LoadOrbwalk() end, 1)
  elseif _G.MMA_IsLoaded then
    MMALoaded = true
    Menu.Orbwalker:addParam("Info", "             ----->>> MMA Detected & Loaded <<<-----   ", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    ScriptMsg("Marksman's Mighty Assistant Detected.")
  elseif _G._Pewalk then
    PEWLoaded = true
    Menu.Orbwalker:addParam("Info", "             ----->>> Pewalk Detected & Loaded <<<-----   ", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    ScriptMsg("Pewalk Detected.")
  elseif FileExist(LIB_PATH .. "SxOrbWalk.lua") then
    require 'SxOrbWalk'
    SxOrb = SxOrbWalk()
    SxOrb:LoadToMenu(Menu.Orbwalker)
    Menu.Orbwalker:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    SxOrbLoaded = true
    ScriptMsg("Optional orbwalker not found, SxOrbwalk Loaded.")
  else
    ErrorMsg("WARNING:Orbwalker Not Found!")
  end
  
end

---------------------------------------------------------------------------------

function OnTick()
  if not Loaded then
    return
  end

  if myHero.dead then
    return
  end
  
  Checks()
  Targets()
  
  if Menu.Control.OnC and Menu.Combo.vision then
    Bushfind()
  end
  
  if Menu.Autom.autolevel.UseAutoLevelFirst or Menu.Autom.autolevel.UseAutoLevelRest then
    CheckLevelChange()
    LevelUpSpell()
  end
  
  if Menu.Control.OnE then
    Flee()
  end

  if Menu.popup then
    Menu.popup = false
    PopUp = true
  end
  
  if Menu.Draw.stream and not ChatOff then
    dChat()
  elseif not Menu.Draw.stream and ChatOff then
    eChat()
  end

  if Menu.Control.autoWallCondemn and Menu.Control.OnC and Menu.Condemn.wcdmethod == 1 then
    WallCondemnMultiPrediction()
  end

  if Menu.Control.autoWallCondemn and Menu.Control.OnC and Menu.Condemn.wcdmethod == 2 then
    WallCondemn()
  end

  if Menu.JFarm.E and Menu.Control.OnJF then
    JungleWallCondemnMultiPrediction()
  end

  if DisableAA and ActiveR then
    DisableAA = false
    BlockAA(false)
  end

  if not R.ready then
    BlockAA(false)
    DisableAA = false
  end

  if Menu.Items.BotRK.bork then
    if myHero.health / myHero.maxHealth <=  Menu.Items.BotRK.maxownhealth / 100 then
      local unit = Targets()
      if ValidTarget(unit, 1000) then
        if unit.health / unit.maxHealth <=  Menu.Items.BotRK.minenemyhealth  / 100 then
          BotrK(unit)
        end
      end
    end 
  end 
  
  if EnemiesAround(myHero, 600) >= Menu.ultimate.enemy and AlliesAround(myHero, 600) >= Menu.ultimate.ally and (math.floor(myHero.health / myHero.maxHealth * 100)) <= Menu.ultimate.hp then
    if Menu.Combo.R and Menu.Control.OnC then
        if R.ready and not ActiveR then
           CastSpell(_R)
        end
    end
end

    if Menu.Items.Bilgewater.bilg then
    if myHero.health / myHero.maxHealth <=  Menu.Items.Bilgewater.maxownhealth / 100 then
      local unit = Targets()
      if ValidTarget(unit, 1000) then
        if unit.health / unit.maxHealth <=  Menu.Items.Bilgewater.minenemyhealth / 100 then
          Bilgewater(unit)
        end
      end
    end 
  end 
    
    if exhaust and Menu.Items.exhaust.exh then 
    if myHero:CanUseSpell(exhaust.slot) == 0 then
      TES:update()
      if ValidTarget(TES.target) and TES.target.type == myHero.type then
        exhFunction(TES.target) 
      end
    end
  end

  if heal then
    if ValidTarget(Targets(), 1000) then
      if Menu.Items.heal.enable and myHero:CanUseSpell(heal) == 0 then
        if myHero.level > 5 and myHero.health/myHero.maxHealth < Menu.Items.heal.health/100 then
          CastSpell(heal)
        elseif  myHero.level < 6 and myHero.health/myHero.maxHealth < (Menu.Items.heal.health/100)*.75 then
          CastSpell(heal)
        end
        
        if realheals and Menu.Items.heal.ally then
          local ally = findClosestAlly(myHero)
          if ally and not ally.dead and GetDistance(ally) < 850 then
            if  ally.health/ally.maxHealth < Menu.Items.heal.health/100 then
              CastSpell(heal)
            end
          end
        end
      end
    end
  end

  if not myHero.dead then
    if (Menu.Items.potion.Key or Menu.Items.potion.Always) and not potionOn and not InFountain() and (myHero.health/myHero.maxHealth)*100 < Menu.Items.potion.health then
      UsePotion()
    end
  end
  
  if ignite and Menu.Items.ignite.set > 1 and (myHero:CanUseSpell(ignite) == READY) then 
    AutoIgnite()
  end

end

---------------------------------------------------------------------------------

function Checks()

  Q.ready = myHero:CanUseSpell(_Q) == READY
  W.ready = myHero:CanUseSpell(_W) == READY
  E.ready = myHero:CanUseSpell(_E) == READY
  R.ready = myHero:CanUseSpell(_R) == READY
  
  Q.level = myHero:GetSpellData(_Q).level
  W.level = myHero:GetSpellData(_W).level
  E.level = myHero:GetSpellData(_E).level
  R.level = myHero:GetSpellData(_R).level
  
  EnemyMinions:update()
  JungleMobs:update()
  SpellExpired()
  
end

---------------------------------------------------------------------------------

function Targets()
  
  local target = nil
  
  if ValidTarget(SelectedTarget) then
    target = SelectedTarget
  elseif _G.MMA_IsLoaded then 
    target = _G.MMA_Target()
  elseif _G.AutoCarry and _G.Reborn_Initialised then 
    target = _G.AutoCarry.Crosshair:GetTarget()
  elseif _G._Pewalk then 
    target = _G._Pewalk.GetTarget()
  elseif SxOrbLoaded then
    target = SxOrb:GetTarget()
  end

  if target and target.type == myHero.type and ValidTarget(target, TrueRange(target)) then
    target = target
  else
    ts:update()
    target = ts.target
  end
end

function OnWndMsg(Msg, Key)
  if Msg == WM_LBUTTONDOWN then
if PopUp then
PopUp = false
end
end
  if Msg == WM_LBUTTONDOWN and Menu.Combo.focus then
    local minDis = 0
    local starget = nil
    for i, enemy in ipairs(GetEnemyHeroes()) do
      if ValidTarget(enemy) then
        if GetDistance(enemy, mousePos) <= minDis or starget == nil then
          minDis = GetDistance(enemy, mousePos)
          starget = enemy
        end
      end
    end

    if starget and minDis < starget.boundingRadius*2 then
      if SelectedTarget and starget.charName == SelectedTarget.charName then
        SelectedTarget = nil
        ScriptMsg("Target Unlocked", true)
      else
        SelectedTarget = starget
        ScriptMsg("Target Locked  - "..starget.charName.."", true)
      end
      elseif SelectedTarget ~= nil then
        SelectedTarget = nil
        ScriptMsg("Target Unlocked", true)
    end
  end
end

function AddRange(unit)
  return unit.boundingRadius
end

function TrueRange(enemy)
  return myHero.range+AddRange(myHero)+AddRange(enemy)
end

---------------------------------------------------------------------------------

function OrbwalkCanMove()

  if SACLoaded then
    return _G.AutoCarry.Orbwalker:CanMove()
  elseif PEWLoaded then
    return _Pewalk.CanMove()
  elseif MMALoaded then
    return _G.MMA_CanMove()
  end
  
end

function BlockAA(bool)
    if not bool then
        if MMALoaded then
            _G.MMA_StopAttacks(false)
        elseif SACLoaded then
            _G.AutoCarry.MyHero:AttacksEnabled(true)
        elseif SxOrbLoaded then
            _G.SxOrb:EnableAttacks()
        elseif PEWLoaded then
            _G._Pewalk.AllowAttack(true)
        end
    elseif bool then
        if MMALoaded then
            _G.MMA_StopAttacks(true)
        elseif SACLoaded then
            _G.AutoCarry.MyHero:AttacksEnabled(false)
        elseif SxOrbLoaded then
            _G.SxOrb:DisableAttacks()
        elseif PEWLoaded then
            _G._Pewalk.AllowAttack(false)
        end
    end
end

---------------------------------------------------------------------------------

function AlliesAround(Unit, range)
    local c=0
    if Unit == nil then return 0 end
    for i=1,heroManager.iCount do hero = heroManager:GetHero(i) if hero.team == myHero.team and hero.x and hero.y and hero.z and GetDistance(hero, Unit) < range then c=c+1 end end return c
end

function EnemiesAround(Unit, range)
    local c=0
    if Unit == nil then return 0 end
    for i=1,heroManager.iCount do hero = heroManager:GetHero(i) if hero ~= nil and hero.team ~= myHero.team and hero.x and hero.y and hero.z and GetDistance(hero, Unit) < range then c=c+1 end end return c
  end

function findClosestAlly(obj)
    local closestAlly = nil
    local currentAlly = nil
  for i, currentAlly in pairs(GetAllyHeroes()) do
        if currentAlly and not currentAlly.dead then
            if closestAlly == nil then
                closestAlly = currentAlly
      end
            if GetDistanceSqr(currentAlly.pos, obj) < GetDistanceSqr(closestAlly.pos, obj) then
        closestAlly = currentAlly
            end
        end
    end
  return closestAlly
end

---------------------------------------------------------------------------------

function CheckItem(ItemName)
  for i = 6, 12 do
    local item = myHero:GetSpellData(i).name
    if item and item:lower() == ItemName then
      return i
    end
  end
end

function checkSpecific(unit, buffname)
  if unit.buffCount then
    for i = 1, unit.buffCount do
      local buff = unit:getBuff(i)
      if buff and buff.valid and buff.name then
        if buff.name:lower():find(buffname) then
          return true
        end
      end
    end
  end
end

function exhFunction(unit)
  moveToCursor()
  CastSpell(exhaust.slot, unit)
end

function moveToCursor()
  local MouseMove = Vector(myHero) + (Vector(mousePos) - Vector(myHero)):normalized() * 500
  myHero:MoveTo(MouseMove.x, MouseMove.z) 
end

function OnUpdateBuff(unit, buff, stacks)
  if not unit or not buff then return end
  if unit and unit.isMe and buff.name == "VayneInquisition" then
      ActiveR = false
    end
  if unit.isMe then
    if buff.name:lower():find("regenerationpotion") or buff.name:lower():find("itemminiregenpotion") or buff.name:lower():find("crystalflask") then
      potionOn = true
    end
  end
  if buff.name:lower():find("vaynesilvereddebuff") then
    if Debug then ScriptMsg(stacks) end
      Wstacks[unit.networkID] = stacks
    end
end

function OnRemoveBuff(unit, buff)
  if not unit or not buff then return end
  if unit and unit.isMe and buff.name == "vaynetumblefade" then
      BlockAA(false)
      DisableAA = false
    end
  if buff.name == "vaynesilvereddebuff" then
    Wstacks[unit.networkID] = 0
  end
  if unit.isMe then
    if buff.name:lower():find("regenerationpotion") or buff.name:lower():find("itemminiregenpotion") or buff.name:lower():find("crystalflask") then
      potionOn = false
    end
  end
end
local lastPotion = 0

function UsePotion()
  if os.clock() - lastPotion < 8 then return end
  if not Menu.Items.potion.enemy then
    if CountEnemiesNearUnitReg(myHero, 750) == 0 then return end
  end
  
  local slot = GetSlotItemFromName("crystalflask")
  if not slot then
    slot = GetSlotItemFromName("RegenerationPotion")
  end
  if not slot then
    slot = GetSlotItemFromName("itemminiregenpotion")
  end
  if slot then
    CastSpell(slot)
    lastPotion = os.clock()
  end
end
local lastPotionMana = 0

function UsePotionMana()
  if CountEnemiesNearUnitReg(myHero, 1000) == 0 then return end
  if os.clock() - lastPotionMana < 8 then return end
  local slot = GetSlotItemFromName("crystalflask")
  if not slot then
    slot = GetSlotItemFromName("flaskofcrystalwater")
  end
  if slot then
    CastSpell(slot)
    lastPotionMana = os.clock()
  end
end

function GetSlotItemFromName(itemname)
  local slot
  for i = 6, 12 do
    local item = myHero:GetSpellData(i).name
    if item and item:lower():find(itemname:lower()) and myHero:CanUseSpell(i) == READY then
      slot = i
    end
  end
  return slot
end

function GetSlotItem(id, unit)
  unit = unit or myHero

  if (not ItemNames[id]) then
    return ___GetInventorySlotItem(id, unit)
  end

  local name  = ItemNames[id]
  
  for slot = ITEM_1, ITEM_7 do
    local item = unit:GetSpellData(slot).name
    if item and item:lower() == name:lower() and myHero:CanUseSpell(slot) == READY then
      return slot
    end
  end
end

local lastTAttack = 0
local tDamage = 1
if AddProcessAttackCallback and heal and Menu.Items.heal.enable then
  AddProcessAttackCallback(function(unit, spell) AProc(unit, spell) end)
end

function AProc(unit, spell)
  if not unit or not unit.valid or not spell then return end

  if spell.target and spell.target.type == myHero.type and spell.target.team == myHero.team and (spell.name:lower():find("_turret_chaos") or spell.name:lower():find("_turret_order")) and not (spell.name:lower():find("4") or spell.name:lower():find("3")) then
    if GetDistance(unit) < 2000 then
      if clock() - lastTAttack < 1.75 then
        if tDamage < 1.75 then
          tDamage = tDamage + 0.375
        else
          tDamage = tDamage + 0.250
          tDamage = tDamage > 2.25 and 2.25 or tDamage
        end
      else
        tDamage = 1
      end
      lastTAttack = clock()
      
      if myHero:CanUseSpell(heal) == 0 and spell.target.isMe then
        local realDamage = unit.totalDamage / (((myHero.armor * 0.7) / 100) + 1)

        if VPred:GetPredictedHealth(myHero, 0.5) + myHero.shield <= realDamage * tDamage then
          DelayAction(function()
            CastSpell(heal)
            ScriptMsg("Saving from tower")
          end, 0.5)
        end
      end
    end
  end
end

function OnApplyBuff(source, unit, buff)
  if not buff or not source or not source.valid or not unit or not unit.valid then return end

  if unit and unit.isMe and buff.name == "vaynetumblefade" then
        if EnemiesAround(myhero, 600) >= Menu.ultimate.minblock then
            if not IsTowerNear() then
                BlockAA(true)
                DisableAA = true
            end
        end
    end
    
    if unit and unit.isMe and buff.name == "VayneInquisition" then
        ActiveR = true
    end

  if unit.isMe and (Menu.Items.cc.Always or Menu.Items.cc.Key) then
    if (source.charName == "Rammus" and buff.type ~= 8) or source.charName == "Alistar" or source.charName:lower():find("baron") or source.charName:lower():find("spiderboss") or source.charName == "LeeSin" or (source.charName == "Hecarim" and not buff.name:lower():find("fleeslow")) then return end  
    if buff.name and ((not cleanse and buff.type == 24) or buff.type == 5 or buff.type == 11 or buff.type == 22 or buff.type == 21 or buff.type == 8)
    or (buff.type == 10 and buff.name and buff.name:lower():find("fleeslow")) then
      if buff.name and buff.name:lower():find("caitlynyor") and CountEnemiesNearUnitReg(myHero, 700) == 0   then
        return false
      elseif not source.charName:lower():find("blitzcrank") then
        UseItemsCC(myHero, true)
      end          
    end           
  end  
end

function IsTowerNear()
    local tHealth = {1000, 1200, 1300, 1500, 2000, 2300, 2500}
    for i = 1, objManager.iCount, 1 do
        local unit = objManager:getObject(i)
        if unit ~= nil then
            if unit.type == "obj_AI_Turret" and unit.team ~= unit.team and not string.find(unit.name, "TurretShrine") and GetDistance(unit) < 950 then
                return true
            end
        end
    end
    return false
end

function CountEnemiesNearUnitReg(unit, range)
  local count = 0
  for i, enemy in pairs(GetEnemyHeroes()) do
    if not enemy.dead and enemy.visible then
      if  GetDistanceSqr(unit, enemy) < range * range  then 
        count = count + 1 
      end
    end
  end
  return count
end

function UseItemsCC(unit, scary)
  if os.clock() - lastRemove < 1 then return end
  for i, Item in pairs(Items) do
    local Item = Items[i]
    if GetInventoryItemIsCastable(Item.id) and GetDistanceSqr(unit) <= Item.range * Item.range then
      if Item.id == 3139 or Item.id ==  3140 then
        if scary then
          DelayAction(function()
            CastItem(Item.id)
          end, Menu.Items.cc.delay/1000)  
          lastRemove = os.clock()
          return true
        end
      end
    end
  end
  if Menu.Items.cc.Summoner and SummonerSlot and myHero:CanUseSpell(SummonerSlot) == 0 then
    DelayAction(function()
      CastSpell(SummonerSlot)
    end, Menu.Items.cc.delay/1000)
    lastRemove = os.clock()
  end
end

function findClosestEnemy(obj)
    local closestEnemy = nil
    local currentEnemy = nil
  for i, currentEnemy in pairs(GetEnemyHeroes()) do
        if ValidTarget(currentEnemy) then
            if closestEnemy == nil then
                closestEnemy = currentEnemy
      end
            if GetDistanceSqr(currentEnemy.pos, obj) < GetDistanceSqr(closestEnemy.pos, obj) then
        closestEnemy = currentEnemy
            end
        end
    end
  return closestEnemy
end

function HealSlot()
  if myHero:GetSpellData(SUMMONER_1).name:lower():find("summonerheal") or myHero:GetSpellData(SUMMONER_2).name:lower():find("summonerheal") then
    realheals = true
  end
  if myHero:GetSpellData(SUMMONER_1).name:lower():find("summonerheal")  or myHero:GetSpellData(SUMMONER_1).name:lower():find("summonerbar") then
    return SUMMONER_1
  elseif myHero:GetSpellData(SUMMONER_2).name:lower():find("summonerheal") or myHero:GetSpellData(SUMMONER_2).name:lower():find("summonerbar") then
    return SUMMONER_2
  end
end

function BotrK(unit, scary)
  for i, Item in pairs(Items) do
    local Item = Items[i]
    if Item.id ~= 3140 and Item.id ~= 3139 then
      if GetInventoryItemIsCastable(Item.id) and GetDistanceSqr(unit) <= Item.range * Item.range then
        if Item.id == 3153 then
          CastItem(Item.id)
        else
          CastItem(Item.id, unit) return true
        end
      end
    end
  end
end

function Bilgewater(unit, scary)
  for i, Item in pairs(Items) do
    local Item = Items[i]
    if Item.id ~= 3140 and Item.id ~= 3139 then
      if GetInventoryItemIsCastable(Item.id) and GetDistanceSqr(unit) <= Item.range * Item.range then
        if Item.id == 3144 then
          CastItem(Item.id)
        else
          CastItem(Item.id, unit) return true
        end
      end
    end
  end
end

--[[function Youmuu()
  if Menu.Items.Youmuu.yomu then
  local slot = GetInventorySlotItem(3142)
  if target ~= nil and ValidTarget(target) and not target.dead and slot ~= nil and myHero:CanUseSpell(slot) == READY then
  CastSpell(slot)
  end
end
end]]--

---------------------------------------------------------------------------------

function AutoIgnite()
  local IgniteDmg = 50 + (20 * myHero.level)
  local aggro = Menu.Items.ignite.set == 3 and 0.05 or 0
  for i, enemy in pairs(GetEnemyHeroes()) do
    if ValidTarget(enemy, 600) then
      local spellDamage = 0
      local adDamage = myHero:CalcDamage(enemy, myHero.totalDamage)
      spellDamage = spellDamage + adDamage
      if myHero.health < myHero.maxHealth*(0.35+aggro) and enemy.health < enemy.maxHealth*(0.34+aggro) and GetDistanceSqr(enemy) < 420 * 420 then
        CastSpell(ignite, enemy)
      end
      local r = myHero.range+65
      local trange = r < 575 and r or 575
      if isFleeingFromMe(enemy, trange) then
        if enemy.health < IgniteDmg + spellDamage  + 10 then    
          if myHero.ms < enemy.ms then
            CastSpell(ignite, enemy)  
            if Debug then
              ScriptMsg("+++++++!")
            end 
          else
            if Debug then
              ScriptMsg("-------!")
            end
          end
        end 
      end
      if (GetDistanceSqr(enemy) > 160000 and (myHero.health+myHero.shield) < myHero.maxHealth*0.3) then 
        if enemy.health > spellDamage-(500*aggro) and enemy.health < IgniteDmg + spellDamage-(500*aggro)  then
          CastSpell(ignite, enemy)              
          if Debug then
            ScriptMsg("ignite Q")
          end
        end
      end
    end
  end
end
function CountAlliesNearUnit(unit, range)
  local count = 0
  for i, ally in pairs(GetAllyHeroes()) do
    if GetDistanceSqr(ally, unit) <= range * range and not ally.dead then count = count + 1 end
  end
  return count
end

function isFleeingFromMe(target, range)
  local pos = VPred:GetPredictedPos(target, 0.26)
  
  if pos and GetDistanceSqr(pos) > range*range then
    return true
  end
  return false
end
function amIFleeing(target, range)
  local pos = VPred:GetPredictedPos(myHero, 0.26)
  
  if pos and GetDistanceSqr(pos, target) > range*range then
    return true
  end
  return false
end

---------------------------------------------------------------------------------

function OnProcessSpell(unit, spell)
if not unit or not unit.valid or not spell then return end

  if heal and Menu.Items.heal.enable and myHero:CanUseSpell(heal) == 0 and spell.target and spell.target.isMe and unit.team ~= myHero.team and unit.type == myHero.type then
    if myHero.health/myHero.maxHealth <= (Menu.Items.heal.health/100)*1.5 then
      CastSpell(heal)
    end
  end
  if spell.name:lower():find("zedr") and spell.target == myHero then
    DelayAction(function()
    end, 1.7)
  end
        
    if Menu.Control.Interrupt and E.ready and #ToInterrupt > 0 then
        for _, ability in pairs(ToInterrupt) do
            if spell.name == ability and unit.team ~= myHero.team then
                if GetDistance(unit) <= 450 then CastSpell(_E, unit) end
            end
        end
    end
    if Menu.Control.AGP and E.ready then
            local jarvanAddition = unit.charName == "JarvanIV" and unit:CanUseSpell(_Q) ~= READY and _R or _Q
            local isAGapcloserUnit = {
                ['Aatrox']      = {true, spell = _Q,                  range = 1000,  projSpeed = 1200, },
                ['Akali']       = {true, spell = _R,                  range = 800,   projSpeed = 2200, }, 
                ['Alistar']     = {true, spell = _W,                  range = 650,   projSpeed = 2000, }, 
                ['Diana']       = {true, spell = _R,                  range = 825,   projSpeed = 2000, }, 
                ['Gragas']      = {true, spell = _E,                  range = 600,   projSpeed = 2000, },
                ['Hecarim']     = {true, spell = _R,                  range = 1000,  projSpeed = 1200, },
                ['Irelia']      = {true, spell = _Q,                  range = 650,   projSpeed = 2200, }, 
                ['JarvanIV']    = {true, spell = jarvanAddition,      range = 770,   projSpeed = 2000, }, 
                ['Jax']         = {true, spell = _Q,                  range = 700,   projSpeed = 2000, }, 
                ['Jayce']       = {true, spell = 'JayceToTheSkies',   range = 600,   projSpeed = 2000, }, 
                ['Khazix']      = {true, spell = _E,                  range = 900,   projSpeed = 2000, },
                ['Leblanc']     = {true, spell = _W,                  range = 600,   projSpeed = 2000, },
                ['LeeSin']      = {true, spell = 'blindmonkqtwo',     range = 1300,  projSpeed = 1800, },
                ['Leona']       = {true, spell = _E,                  range = 900,   projSpeed = 2000, },
                ['Malphite']    = {true, spell = _R,                  range = 1000,  projSpeed = 1500 + unit.ms},
                ['Maokai']      = {true, spell = _Q,                  range = 600,   projSpeed = 1200, }, 
                ['MonkeyKing']  = {true, spell = _E,                  range = 650,   projSpeed = 2200, }, 
                ['Pantheon']    = {true, spell = _W,                  range = 600,   projSpeed = 2000, }, 
                ['Poppy']       = {true, spell = _E,                  range = 525,   projSpeed = 2000, }, 
                ['Renekton']    = {true, spell = _E,                  range = 450,   projSpeed = 2000, },
                ['Sejuani']     = {true, spell = _Q,                  range = 650,   projSpeed = 2000, },
                ['Shen']        = {true, spell = _E,                  range = 575,   projSpeed = 2000, },
                ['Tristana']    = {true, spell = _W,                  range = 900,   projSpeed = 2000, },
                ['Tryndamere']  = {true, spell = 'Slash',             range = 650,   projSpeed = 1450, },
                ['XinZhao']     = {true, spell = _E,                  range = 650,   projSpeed = 2000, }, 
            }
            if unit.type == myHero.type and unit.team ~= myHero.team and isAGapcloserUnit[unit.charName] and GetDistance(unit) < 2000 and spell ~= nil then
                if spell.name == (type(isAGapcloserUnit[unit.charName].spell) == 'number' and unit:GetSpellData(isAGapcloserUnit[unit.charName].spell).name or isAGapcloserUnit[unit.charName].spell) then
                    if spell.target ~= nil and spell.target.isMe or isAGapcloserUnit[unit.charName].spell == 'blindmonkqtwo' then
                        if E.ready then
                            E.target = unit
                            CastSpell(_E, unit)
                        end
                    else
                        spellExpired = false
                        informationTable = {
                            spellSource = unit,
                            spellCastedTick = GetTickCount(),
                            spellStartPos = Point(spell.startPos.x, spell.startPos.z),
                            spellEndPos = Point(spell.endPos.x, spell.endPos.z),
                            spellRange = isAGapcloserUnit[unit.charName].range,
                            spellSpeed = isAGapcloserUnit[unit.charName].projSpeed
                        }
                    end
                end
            end  
    end
    
    --[[if Q.ready and Menu.Control.OnH then
        
           if unit.isMe and spell.name:lower():find("attack") and Menu.Harass.Q and myHero.mana / myHero.maxMana > Menu.Harass.Q2 /100 then
              SpellTarget = spell.target
              if SpellTarget.type == myHero.type then
              DelayAction(function() CastSpell(_Q, mousePos.x, mousePos.z) end, spell.windUpTime - GetLatency() / 2000)         
              end
            end  
            
    end]]--
    
    --[[if Menu.Control.OnH and Menu.Harass.E and E.ready then
        if unit.isMe and spell.name == "VayneTumble" and myHero.mana / myHero.maxMana > Menu.Harass.E2 /100 then       
          DelayAction(function() CastSpell(_E, target) end, 0.6)    
        end
    end]]--
    
end         


--[[function harass()
    if ValidTarget(target) then
      if Menu.Control.OnH and Menu.Harass.E and E.ready then
        if unit.isMe and spell.name == "VayneTumble" and myHero.mana / myHero.maxMana > Menu.Harass.E2 /100 then       
          DelayAction(function() CastSpell(_E, target) end, 0.6)    
        end
      end
    end
end]]

function OnProcessAttack(unit, spell)

  if unit.isMe and spell.name:lower():find("attack") and Menu.Control.OnC and Menu.Combo.Q and Q.ready and Menu.Combo.qmethod == 1 then
        SpellTarget = spell.target
        if SpellTarget.type == myHero.type then
            CastSpell(_Q, mousePos.x, mousePos.z)
        end
    end

   if unit.isMe and spell.name:lower():find("attack") and Menu.Control.OnC and Menu.Combo.Q and Q.ready and Menu.Combo.qmethod == 2 then
        SpellTarget = spell.target
        if SpellTarget.type == myHero.type and Wstacks[SpellTarget.networkID] == 1 then
            CastSpell(_Q, mousePos.x, mousePos.z)
        end
    end

   if Menu.Control.OnF and Q.ready then
      EnemyMinions:update()
        for i, minion in pairs(EnemyMinions.objects) do   
  if unit.isMe and spell.name:lower():find("attack") and Menu.Control.OnF and Menu.Farm.Q and ManaPercent() >= Menu.Farm.Q2 then
        SpellTarget = spell.target
        CastSpell(_Q, mousePos.x, mousePos.z)
       end
      end

      JungleMobs:update()
         for i, junglemob in pairs(JungleMobs.objects) do
        if unit.isMe and spell.name:lower():find("attack") and Menu.Control.OnJF and Menu.JFarm.Q and ManaPercent() >= Menu.JFarm.Q2 then
        SpellTarget = spell.target
        CastSpell(_Q, mousePos.x, mousePos.z)
      end
    end
  end

  if unit.isMe and spell.name:lower():find("attack") then
        if spell.target then SpellTarget = spell.target end
        if Menu.Control.eafteraakey and SpellTarget.type == myHero.type and E.ready then
            DelayAction(function() CastSpell(_E, SpellTarget) end, spell.windUpTime + GetLatency()/2000)
            Menu.Control.eafteraakey = false
        else
            DelayAction(function() CastSpell(_Q, SpellTarget) end, spell.windUpTime + GetLatency()/2000)
        end
  end

if unit.isMe and spell.name:lower():find("attack") then
        if spell.target then SpellTarget = spell.target end
        if Menu.Combo.qforgap and SpellTarget.type == myHero.type and Q.ready and GetDistance(SpellTarget) > 715 and Menu.Control.OnC then
        DelayAction(function() CastSpell(_Q, SpellTarget) end, spell.windUpTime + GetLatency()/2000)
  end
end
end



function SpellExpired()
    if ValidTarget(target) then
    if Menu.Control.AGP and not spellExpired and (GetTickCount() - informationTable.spellCastedTick) <= (informationTable.spellRange / informationTable.spellSpeed) * 1000 then
        local spellDirection     = (informationTable.spellEndPos - informationTable.spellStartPos):normalized()
        local spellStartPosition = informationTable.spellStartPos + spellDirection
        local spellEndPosition   = informationTable.spellStartPos + spellDirection * informationTable.spellRange
        local heroPosition = Point(myHero.x, myHero.z)
        local lineSegment = LineSegment(Point(spellStartPosition.x, spellStartPosition.y), Point(spellEndPosition.x, spellEndPosition.y))
      local lineSegment = LineSegment(Point(spellStartPosition.x, spellStartPosition.y), Point(spellEndPosition.x, spellEndPosition.y))
              if lineSegment:distance(heroPosition) <= 400 and E.ready then    
                CastSpell(_E, target)
            end
        else
            spellExpired = true
            informationTable = {}
        end
  end   
end

------------------------------------------------------------------------------------------------

function ManaPercent()
  return (myHero.mana/myHero.maxMana)*100
end

------------------------------------------------------------------------------------------------

function WallCondemnMultiPrediction()

    if myHero.dead then return end

    if E.ready then
        if Menu.Control.AGP then
            if not spellExpired and (GetTickCount() - informationTable.spellCastedTick) <= (informationTable.spellRange/informationTable.spellSpeed)*1000 then
                local spellDirection     = (informationTable.spellEndPos - informationTable.spellStartPos):normalized()
                local spellStartPosition = informationTable.spellStartPos + spellDirection
                local spellEndPosition   = informationTable.spellStartPos + spellDirection * informationTable.spellRange
                local heroPosition = Point(myHero.x, myHero.z)
 
                local lineSegment = LineSegment(Point(spellStartPosition.x, spellStartPosition.y), Point(spellEndPosition.x, spellEndPosition.y))
                --lineSegment:draw(ARGB(255, 0, 255, 0), 70)
 
                if lineSegment:distance(heroPosition) <= (not informationTable.spellIsAnExpetion and 65 or 200) then
                    CastSpell(_E, informationTable.spellSource)
                end
            else
                spellExpired = true
                informationTable = {}
            end
        end
 
    if E.ready and Menu.Condemn.wcdmethod == 1 then
 
        if Menu.Control.autoWallCondemn then
        for i, enemyHero in ipairs(EnemyHeroes) do
        if Menu.Condemn.condemnSubMenu["enableCondemn"..i] then
        if enemyHero ~= nil and enemyHero.valid and not enemyHero.dead and enemyHero.visible and GetDistance(enemyHero) <= 715 and GetDistance(enemyHero) > 0 then
        local predPosition = FHPrediction.PredictPosition(enemyHero, eDelay)
      
      if predPosition and not IsWall(D3DXVECTOR3(predPosition.x, predPosition.y, predPosition.z)) then
          
      local checkHeroDistance = Menu.Condemn.CheckDistance
      local heroChecks = Menu.Condemn.Checks
      local AllInsideWall = true
      local checkCount = 0
      local sumCheckDist = 0
      
      for i= -math.floor(heroChecks/2), math.floor(heroChecks/2), 1 do
      checkCount = checkCount + 1
      
      local enemyPosition = predPosition + (Vector(enemyPosition) - Vector(myHero)):normalized()*(checkHeroDistance*i)
      
      local checkDistance = 50
      local checks = math.ceil(425/checkDistance)            
            local InsideTheWall = false
      local checksPos = nil
      
            for k=1, checks, 1 do
                checksPos = enemyPosition + (Vector(enemyPosition) - Vector(myHero)):normalized()*(checkDistance*k)
                        
        if IsWall(D3DXVECTOR3(checksPos.x, checksPos.y, checksPos.z)) then
                    InsideTheWall = true
                    break
                end         
            end
      
      if InsideTheWall then
          
        if Menu.Draw.CondemnAssistant and Menu.Control.OnC and E.ready then
        DrawLine3D(enemyHero.x, enemyHero.y, enemyHero.z, checksPos.x, checksPos.y, checksPos.z, 2, 0xFFFF0000) -- Here OnDraw() if need <-- Disabled
        end
      else
        AllInsideWall = false
        
        if Menu.Draw.CondemnAssistant and Menu.Control.OnC and E.ready then
        DrawLine3D(enemyHero.x, enemyHero.y, enemyHero.z, checksPos.x, checksPos.y, checksPos.z, 2, 0xFF00FF00) -- Here OnDraw() if need <-- Disabled
        end
      end

      sumCheckDist = sumCheckDist + GetDistance(checksPos, myHero)
      
      end
      
      if AllInsideWall then
      if Menu.Control.autoWallCondemn and sumCheckDist/checkCount < Menu.Condemn.MaxDistance
        and GetDistance(enemyHero) < sumCheckDist/checkCount then
        CastSpell(_E, enemyHero)
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

function WallCondemn()

  if myHero.dead then return end

    if E.ready and Menu.Condemn.wcdmethod == 2 then

    if E.ready then
        if Menu.Control.AGP then
            if not spellExpired and (GetTickCount() - informationTable.spellCastedTick) <= (informationTable.spellRange/informationTable.spellSpeed)*1000 then
                local spellDirection     = (informationTable.spellEndPos - informationTable.spellStartPos):normalized()
                local spellStartPosition = informationTable.spellStartPos + spellDirection
                local spellEndPosition   = informationTable.spellStartPos + spellDirection * informationTable.spellRange
                local heroPosition = Point(myHero.x, myHero.z)
 
                local lineSegment = LineSegment(Point(spellStartPosition.x, spellStartPosition.y), Point(spellEndPosition.x, spellEndPosition.y))
                --lineSegment:draw(ARGB(255, 0, 255, 0), 70)
 
                if lineSegment:distance(heroPosition) <= (not informationTable.spellIsAnExpetion and 65 or 200) then
                    CastSpell(_E, informationTable.spellSource)
                end
            else
                spellExpired = true
                informationTable = {}
            end
        end

        if Menu.Control.autoWallCondemn then
            for i, enemyHero in ipairs(EnemyHeroes) do
                if Menu.Condemn.condemnSubMenu["enableCondemn"..i] then 
                    if enemyHero ~= nil and enemyHero.valid and not enemyHero.dead and enemyHero.visible and GetDistance(enemyHero) <= 715 and GetDistance(enemyHero) > 0 then
                        local enemyPosition = FHPrediction.PredictPosition(enemyHero, eDelay)
                        local PushPos = enemyPosition + (Vector(enemyPosition) - myHero):normalized()*420

                        if enemyHero.x > 0 and enemyHero.z > 0 then
                            local checks = math.ceil(420/65) --134
                            local checkDistance = (420)/checks
                            local InsideTheWall = false
                            for k=1, checks, 1 do
                                local checksPos = enemyPosition + (Vector(enemyPosition) - myHero):normalized()*(checkDistance*k)
                                local WallContainsPosition = IsWall(D3DXVECTOR3(checksPos.x, checksPos.y, checksPos.z))
                                if WallContainsPosition then
                                    InsideTheWall = true
                                    break
                                end
                            end

                            if InsideTheWall then CastSpell(_E, enemyHero) end
                        end
                    end
                end
            end
        end
    end
end
end

---------------------------------------------------------------------------------

function JungleWallCondemnMultiPrediction()

    if myHero.dead then return end
    if myHero.level > Menu.JFarm.E3 then return end
  
    if E.ready and Menu.Control.OnJF and Menu.JFarm.E and ManaPercent() >= Menu.JFarm.E2 then

    for i, junglemob in pairs(JungleMobs.objects) do
  local LargeJunglemob = nil
        if Menu.JFarm.E then
        for j = 1, #FocusJungleNames do
        if junglemob.name == FocusJungleNames[j] then
          LargeJunglemob = junglemob
          break
        end
      end
        if LargeJunglemob ~= nil and GetDistance(LargeJunglemob, mousePos) <= 650 and ValidTarget(LargeJunglemob, 650) then
        local predPosition = FHPrediction.PredictPosition(LargeJunglemob, eDelay)
      
      if predPosition and not IsWall(D3DXVECTOR3(predPosition.x, predPosition.y, predPosition.z)) then
          
      local checkMobDistance = Menu.Condemn.CheckDistance
      local mobChecks = Menu.Condemn.Checks
      local AllInsideWall = true
      local checkCount = 0
      local sumCheckDist = 0
      
      for i= -math.floor(mobChecks/2), math.floor(mobChecks/2), 1 do
      checkCount = checkCount + 1
      
      local LargeJunglemobPosition = predPosition + (Vector(LargeJunglemobPosition) - Vector(myHero)):normalized()*(checkMobDistance*i)
      
      local checkDistance = 50
      local checks = math.ceil(425/checkDistance)            
            local InsideTheWall = false
      local checksPos = nil
      
            for k=1, checks, 1 do
                checksPos = LargeJunglemobPosition + (Vector(LargeJunglemobPosition) - Vector(myHero)):normalized()*(checkDistance*k)
                        
        if IsWall(D3DXVECTOR3(checksPos.x, checksPos.y, checksPos.z)) then
                    InsideTheWall = true
                    break
                end         
            end
      
      if InsideTheWall then
          
        if Menu.Draw.CondemnAssistant and Menu.Control.OnJF and E.ready then
        DrawLine3D(junglemob.x, junglemob.y, junglemob.z, checksPos.x, checksPos.y, checksPos.z, 2, 0xFFFF0000) -- Will move to OnDraw() if need
        end
      else
        AllInsideWall = false
        
        if Menu.Draw.CondemnAssistant and Menu.Control.OnJF and E.ready then
        DrawLine3D(junglemob.x, junglemob.y, junglemob.z, checksPos.x, checksPos.y, checksPos.z, 2, 0xFF00FF00) -- Will move to OnDraw() if need
        end
      end

      sumCheckDist = sumCheckDist + GetDistance(checksPos, myHero)
      
      end
      
      if AllInsideWall then
      if Menu.JFarm.E and sumCheckDist/checkCount < Menu.Condemn.MaxDistance
        and GetDistance(LargeJunglemob) < sumCheckDist/checkCount then
        CastSpell(_E, LargeJunglemob)
      end
      end
      end
      end
    end   
  end
end
end

---------------------------------------------------------------------------------

function DrawRectangleButton(x, y, w, h, color)
local floor = math.floor
local points = {}
points[1] = D3DXVECTOR2(floor(x), floor(y))
points[2] = D3DXVECTOR2(floor(x + w), floor(y))
local points2 = {}
points2[1] = D3DXVECTOR2(floor(x), floor(y - h/2))
points2[2] = D3DXVECTOR2(floor(x + w), floor(y - h/2))
points2[3] = D3DXVECTOR2(floor(x + w), floor(y + h/2))
points2[4] = D3DXVECTOR2(floor(x), floor(y + h/2))
local t = GetCursorPos()
polygon = Polygon(Point(points2[1].x, points2[1].y), Point(points2[2].x, points2[2].y), Point(points2[3].x, points2[3].y), Point(points2[4].x, points2[4].y))
if polygon:contains(Point(t.x, t.y)) then
DrawLines2(points, floor(h), color)
else
DrawLines2(points, floor(h), ARGB(255, 49, 112, 131))
end
end

function OnDraw()
    if not Loaded then return
  end
    
    if Menu.Draw.CLFPS then return
    OnDrawFPS()
  end

    if not Menu.Draw.On or myHero.dead then
    return
  end
  
  if Menu.Draw.Trg then
    if target ~= nil then
    DrawCircle(target.x, target.y, target.z, 75, 0x78FF7D00 or 0x78FFFFFF)
    end
  end

  if PopUp then
              local w, h1, h2 = (WINDOW_W*0.50), (WINDOW_H*.15), (WINDOW_H*.9)
              DrawLine(w, h1/1.05, w, h2/1.97, w/1.75, ARGB(80, 0, 0, 0)) -- border & aero
              DrawLine(w, h1, w, h2/2, w/1.8, ARGB(255, 22, 12, 0)) -- background
              DrawTextA(tostring("Welcome to Uneeesh Series - Vayne"), WINDOW_H*.028, (WINDOW_W/2), (WINDOW_H*.18), ARGB(255, 0, 222, 225),"center","center")
              DrawTextA(tostring("Latest Changelog (" .. Version .. ") ;"), WINDOW_H*.015, (WINDOW_W/2.65), (WINDOW_H*.210), ARGB(255, 0, 222, 225))
              DrawTextA(tostring(" "), WINDOW_H*.015, (WINDOW_W/2.65), (WINDOW_H*.210), ARGB(255, 255, 255, 255))
              DrawTextA(tostring(" "), WINDOW_H*.015, (WINDOW_W/2.65), (WINDOW_H*.225), ARGB(255, 255, 255, 255))
              DrawTextA(tostring("- Re-Enabled SAC:Reborn."), WINDOW_H*.015, (WINDOW_W/2.70), (WINDOW_H*.240), ARGB(255, 0, 222, 225))
              DrawTextA(tostring("- Added Soulstealer skin."), WINDOW_H*.015, (WINDOW_W/2.70), (WINDOW_H*.260), ARGB(255, 0, 222, 225))
              DrawTextA(tostring(""), WINDOW_H*.015, (WINDOW_W/2.70), (WINDOW_H*.280), ARGB(255, 0, 222, 225))
              local w, h1, h2 = (WINDOW_W*0.49), (WINDOW_H*.70), (WINDOW_H*.75)
              DrawLine(w, h1/1.775, w, h2/1.68, w*.11, ARGB(255, 0, 0, 0))
              DrawRectangleButton(WINDOW_W*0.467, WINDOW_H/2.375, WINDOW_W*.047, WINDOW_H*.041, ARGB(255, 255, 0, 0))
              DrawTextA(tostring("OK"), WINDOW_H*.02, (WINDOW_W/2)*.98, (WINDOW_H/2.375), ARGB(255, 0, 222, 225),"center","center")
              DrawTextA(tostring("                                                                                                      IZSHA"), WINDOW_H*.015, (WINDOW_W/2.65), (WINDOW_H*.355), ARGB(255, 0, 222, 225))
  end

  if Menu.Draw.ownp then
    
    if myHero.hasMovePath and myHero.pathCount >= 1 then
    
      local IndexPath = myHero:GetPath(myHero.pathIndex)
      
      if IndexPath then
        DrawLine3D(myHero.x, myHero.y, myHero.z, IndexPath.x, IndexPath.y, IndexPath.z, 1, ARGB(255, 152, 130, 147))
      end
      
      for i=myHero.pathIndex, myHero.pathCount-1 do
      
        local Path = myHero:GetPath(i)
        local Path2 = myHero:GetPath(i+1)
        
        DrawLine3D(Path.x, Path.y, Path.z, Path2.x, Path2.y, Path2.z, 1, ARGB(255, 152, 130, 147))
      end
      
    end
  
  if Menu.Draw.opp then
    
    for i, enemy in ipairs(EnemyHeroes) do
    
      if enemy == nil then
        return
      end
      
      if enemy.hasMovePath and enemy.pathCount >= 1 then
      
        local IndexPath = enemy:GetPath(enemy.pathIndex)
        
        if IndexPath then
          DrawLine3D(enemy.x, enemy.y, enemy.z, IndexPath.x, IndexPath.y, IndexPath.z, 1, ARGB(255, 255, 255, 255))
        end
        
        for i=enemy.pathIndex, enemy.pathCount-1 do
        
          local Path = enemy:GetPath(i)
          local Path2 = enemy:GetPath(i+1)
          
          DrawLine3D(Path.x, Path.y, Path.z, Path2.x, Path2.y, Path2.z, 1, ARGB(255, 255, 255, 255))
          
        end
        
      end
      
    end
    
  end
  
  end

  --[[if Menu.Draw.CondemnAssistant and Menu.Control.OnC and E.ready then
    for i, enemyHero in ipairs(EnemyHeroes) do
    if Menu.Condemn.condemnSubMenu["enableCondemn"..i] then
    if enemyHero ~= nil and enemyHero.valid and not enemyHero.dead and enemyHero.visible and GetDistance(enemyHero) <= 715 and GetDistance(enemyHero) > 0 then
    local enemyPosition = UnitPath(enemyHero):getPosAtTime(eDelay)
    local PushPos = enemyPosition + (Vector(enemyPosition) - myHero):normalized()*Menu.Condemn.pushDistance
    if PushPos.x > 0 and PushPos.z > 0 then
      DrawCircle(PushPos.x, PushPos.y, PushPos.z, 55, ARGB(0xFF, 0, 0xFF, 0))
    end
  end
end
end
end]]--

  if Menu.Draw.CondemnAssistant and Menu.Control.OnC and E.ready and Menu.Condemn.wcdmethod == 1 then
    for i, enemyHero in ipairs(EnemyHeroes) do
        if Menu.Condemn.condemnSubMenu["enableCondemn"..i] then
        if enemyHero ~= nil and enemyHero.valid and not enemyHero.dead and enemyHero.visible and GetDistance(enemyHero) <= 715 and GetDistance(enemyHero) > 0 then
        local predPosition = FHPrediction.PredictPosition(enemyHero, eDelay)
      
      if predPosition and not IsWall(D3DXVECTOR3(predPosition.x, predPosition.y, predPosition.z)) then
          
      local checkHeroDistance = Menu.Condemn.CheckDistance
      local heroChecks = Menu.Condemn.Checks
      local AllInsideWall = true
      local checkCount = 0
      local sumCheckDist = 0
      
      for i= -math.floor(heroChecks/2), math.floor(heroChecks/2), 1 do
      checkCount = checkCount + 1
      
      local enemyPosition = predPosition + (Vector(enemyPosition) - Vector(myHero)):normalized()*(checkHeroDistance*i)
      
      local checkDistance = 50
      local checks = math.ceil(425/checkDistance)            
            local InsideTheWall = false
      local checksPos = nil
      
            for k=1, checks, 1 do
                checksPos = enemyPosition + (Vector(enemyPosition) - Vector(myHero)):normalized()*(checkDistance*k)
                        
        if IsWall(D3DXVECTOR3(checksPos.x, checksPos.y, checksPos.z)) then
                    InsideTheWall = true
                    break
                end         
            end
      
      if InsideTheWall then
          
        if Menu.Draw.CondemnAssistant and Menu.Control.OnC and E.ready then
        DrawLine3D(enemyHero.x, enemyHero.y, enemyHero.z, checksPos.x, checksPos.y, checksPos.z, 2, 0xFF00FF00)
        CircleDraw(checksPos.x, checksPos.y, checksPos.z, 20, ARGB(0xFF, 0, 0xFF, 0))
        end
      else
        AllInsideWall = false
        
        if Menu.Draw.CondemnAssistant and Menu.Control.OnC and E.ready then
        DrawLine3D(enemyHero.x, enemyHero.y, enemyHero.z, checksPos.x, checksPos.y, checksPos.z, 2, 0xFF000000)
        CircleDraw(checksPos.x, checksPos.y, checksPos.z, 20, ARGB(0xFF, 0x00, 0x00, 0x00))
        end
      end

      sumCheckDist = sumCheckDist + GetDistance(checksPos, myHero)
      
      end
      end
      end
      end
    end   
  end

if Menu.Draw.CondemnAssistant and Menu.Control.OnC and E.ready and Menu.Condemn.wcdmethod == 2 then
            for i, enemyHero in ipairs(EnemyHeroes) do
                if Menu.Condemn.condemnSubMenu["enableCondemn"..i] then 
                    if enemyHero ~= nil and enemyHero.valid and not enemyHero.dead and enemyHero.visible and GetDistance(enemyHero) <= 715 and GetDistance(enemyHero) > 0 then
                        local enemyPosition = FHPrediction.PredictPosition(enemyHero, eDelay)
                        local PushPos = enemyPosition + (Vector(enemyPosition) - myHero):normalized()*420

                        if enemyHero.x > 0 and enemyHero.z > 0 then
                            local checks = math.ceil(420/65) --134
                            local checkDistance = (420)/checks
                            local InsideTheWall = false
                            for k=1, checks, 1 do
                                local checksPos = enemyPosition + (Vector(enemyPosition) - myHero):normalized()*(checkDistance*k)
                                local WallContainsPosition = IsWall(D3DXVECTOR3(checksPos.x, checksPos.y, checksPos.z))
                                if WallContainsPosition then
                                    InsideTheWall = true
                                    break
                                end

                            if PushPos.x > 0 and PushPos.z > 0 and InsideTheWall then
                               DrawCircle(PushPos.x, PushPos.y, PushPos.z, 35, ARGB(0xFF, 0, 0xFF, 0))
                            else
                            AllInsideWall = false
                            if PushPos.x > 0 and PushPos.z > 0 then
                               DrawCircle(PushPos.x, PushPos.y, PushPos.z, 35, ARGB(0xFF, 0x00, 0x00, 0x00))
                            end
                            end
                        end
                    end
                end
            end
        end
    end

  if E.ready and Menu.Control.eafteraakey then
    local myPos = WorldToScreen(D3DXVECTOR3(myHero.x, myHero.y, myHero.z))
    DrawText("Condemn After Next AA is Active", 20, myPos.x, myPos.y, ARGB(0xFF, 0xFF, 0xFF, 0xFF))
  end


  if Menu.Draw.AA then
    DrawCircle(myHero.x, myHero.y, myHero.z, myHero.range-5+myHero.boundingRadius, RGB(Menu.Draw.CLA[2], Menu.Draw.CLA[3], Menu.Draw.CLA[4]))
  end
  
  if Menu.Draw.Q and Q.ready then
    DrawCircle(myHero.x, myHero.y, myHero.z, Q.range, RGB(Menu.Draw.CLQ[2], Menu.Draw.CLQ[3], Menu.Draw.CLQ[4]))
  end
    
  if Menu.Draw.E and E.ready then
    DrawCircle(myHero.x, myHero.y, myHero.z, E.range-30, RGB(Menu.Draw.CLE[2], Menu.Draw.CLE[3], Menu.Draw.CLE[4]))
  end
  
  if Menu.Draw.I and I.ready then
    DrawCircle(myHero.x, myHero.y, myHero.z, I.range, RGB(Menu.Draw.CLI[2], Menu.Draw.CLI[3], Menu.Draw.CLI[4]))
  end
end

function OnDrawFPS()
  
  if not Menu.Draw.On or myHero.dead then
    return
  end
  
  if Menu.Draw.Trg then
    ts:update()
    if ts.target ~= nil then
    CircleDraw(ts.target.x, ts.target.y, ts.target.z, 75, 0x78FF7D00 or 0x78FFFFFF)
    end
  end

  if PopUp then
              local w, h1, h2 = (WINDOW_W*0.50), (WINDOW_H*.15), (WINDOW_H*.9)
              DrawLine(w, h1/1.05, w, h2/1.97, w/1.75, ARGB(80, 0, 0, 0)) -- border & aero
              DrawLine(w, h1, w, h2/2, w/1.8, ARGB(255, 22, 12, 0)) -- background
              DrawTextA(tostring("Welcome to Uneeesh Series - Vayne"), WINDOW_H*.028, (WINDOW_W/2), (WINDOW_H*.18), ARGB(255, 0, 222, 225),"center","center")
              DrawTextA(tostring("Latest Changelog (" .. Version .. ") ;"), WINDOW_H*.015, (WINDOW_W/2.65), (WINDOW_H*.210), ARGB(255, 0, 222, 225))
              DrawTextA(tostring(" "), WINDOW_H*.015, (WINDOW_W/2.65), (WINDOW_H*.210), ARGB(255, 255, 255, 255))
              DrawTextA(tostring(" "), WINDOW_H*.015, (WINDOW_W/2.65), (WINDOW_H*.225), ARGB(255, 255, 255, 255))
              DrawTextA(tostring("- Re-Enabled SAC:Reborn."), WINDOW_H*.015, (WINDOW_W/2.70), (WINDOW_H*.240), ARGB(255, 0, 222, 225))
              DrawTextA(tostring("- Added Soulstealer skin."), WINDOW_H*.015, (WINDOW_W/2.70), (WINDOW_H*.260), ARGB(255, 0, 222, 225))
              DrawTextA(tostring(""), WINDOW_H*.015, (WINDOW_W/2.70), (WINDOW_H*.280), ARGB(255, 0, 222, 225))
              local w, h1, h2 = (WINDOW_W*0.49), (WINDOW_H*.70), (WINDOW_H*.75)
              DrawLine(w, h1/1.775, w, h2/1.68, w*.11, ARGB(255, 0, 0, 0))
              DrawRectangleButton(WINDOW_W*0.467, WINDOW_H/2.375, WINDOW_W*.047, WINDOW_H*.041, ARGB(255, 255, 0, 0))
              DrawTextA(tostring("OK"), WINDOW_H*.02, (WINDOW_W/2)*.98, (WINDOW_H/2.375), ARGB(255, 0, 222, 225),"center","center")
              DrawTextA(tostring("                                                                                                      IZSHA"), WINDOW_H*.015, (WINDOW_W/2.65), (WINDOW_H*.355), ARGB(255, 0, 222, 225))
  end

  if Menu.Draw.ownp then
    
    if myHero.hasMovePath and myHero.pathCount >= 1 then
    
      local IndexPath = myHero:GetPath(myHero.pathIndex)
      
      if IndexPath then
        DrawLine3D(myHero.x, myHero.y, myHero.z, IndexPath.x, IndexPath.y, IndexPath.z, 1, ARGB(255, 152, 130, 147))
      end
      
      for i=myHero.pathIndex, myHero.pathCount-1 do
      
        local Path = myHero:GetPath(i)
        local Path2 = myHero:GetPath(i+1)
        
        DrawLine3D(Path.x, Path.y, Path.z, Path2.x, Path2.y, Path2.z, 1, ARGB(255, 152, 130, 147))
      end
      
    end
  
  if Menu.Draw.opp then
    
    for i, enemy in ipairs(EnemyHeroes) do
    
      if enemy == nil then
        return
      end
      
      if enemy.hasMovePath and enemy.pathCount >= 1 then
      
        local IndexPath = enemy:GetPath(enemy.pathIndex)
        
        if IndexPath then
          DrawLine3D(enemy.x, enemy.y, enemy.z, IndexPath.x, IndexPath.y, IndexPath.z, 1, ARGB(255, 255, 255, 255))
        end
        
        for i=enemy.pathIndex, enemy.pathCount-1 do
        
          local Path = enemy:GetPath(i)
          local Path2 = enemy:GetPath(i+1)
          
          DrawLine3D(Path.x, Path.y, Path.z, Path2.x, Path2.y, Path2.z, 1, ARGB(255, 255, 255, 255))
          
        end
        
      end
      
    end
    
  end
  
  end

  --[[if Menu.Draw.CondemnAssistant and Menu.Control.OnC and E.ready then
    for i, enemyHero in ipairs(EnemyHeroes) do
    if Menu.Condemn.condemnSubMenu["enableCondemn"..i] then
    if enemyHero ~= nil and enemyHero.valid and not enemyHero.dead and enemyHero.visible and GetDistance(enemyHero) <= 715 and GetDistance(enemyHero) > 0 then
    local enemyPosition = UnitPath(enemyHero):getPosAtTime(eDelay)
    local PushPos = enemyPosition + (Vector(enemyPosition) - myHero):normalized()*Menu.Condemn.pushDistance
    if PushPos.x > 0 and PushPos.z > 0 then
      CircleDraw(PushPos.x, PushPos.y, PushPos.z, 55, ARGB(0xFF, 0, 0xFF, 0))
    end
  end
end
end
end]]--

  if Menu.Draw.CondemnAssistant and Menu.Control.OnC and E.ready and Menu.Condemn.wcdmethod == 1 then
    for i, enemyHero in ipairs(EnemyHeroes) do
        if Menu.Condemn.condemnSubMenu["enableCondemn"..i] then
        if enemyHero ~= nil and enemyHero.valid and not enemyHero.dead and enemyHero.visible and GetDistance(enemyHero) <= 715 and GetDistance(enemyHero) > 0 then
        local predPosition = FHPrediction.PredictPosition(enemyHero, eDelay)
      
      if predPosition and not IsWall(D3DXVECTOR3(predPosition.x, predPosition.y, predPosition.z)) then
          
      local checkHeroDistance = Menu.Condemn.CheckDistance
      local heroChecks = Menu.Condemn.Checks
      local AllInsideWall = true
      local checkCount = 0
      local sumCheckDist = 0
      
      for i= -math.floor(heroChecks/2), math.floor(heroChecks/2), 1 do
      checkCount = checkCount + 1
      
      local enemyPosition = predPosition + (Vector(enemyPosition) - Vector(myHero)):normalized()*(checkHeroDistance*i)
      
      local checkDistance = 50
      local checks = math.ceil(425/checkDistance)            
            local InsideTheWall = false
      local checksPos = nil
      
            for k=1, checks, 1 do
                checksPos = enemyPosition + (Vector(enemyPosition) - Vector(myHero)):normalized()*(checkDistance*k)
                        
        if IsWall(D3DXVECTOR3(checksPos.x, checksPos.y, checksPos.z)) then
                    InsideTheWall = true
                    break
                end         
            end
      
      if InsideTheWall then
          
        if Menu.Draw.CondemnAssistant and Menu.Control.OnC and E.ready then
        DrawLine3D(enemyHero.x, enemyHero.y, enemyHero.z, checksPos.x, checksPos.y, checksPos.z, 2, 0xFF00FF00)
        CircleDraw(checksPos.x, checksPos.y, checksPos.z, 20, ARGB(0xFF, 0, 0xFF, 0))
        end
      else
        AllInsideWall = false
        
        if Menu.Draw.CondemnAssistant and Menu.Control.OnC and E.ready then
        DrawLine3D(enemyHero.x, enemyHero.y, enemyHero.z, checksPos.x, checksPos.y, checksPos.z, 2, 0xFF000000)
        CircleDraw(checksPos.x, checksPos.y, checksPos.z, 20, ARGB(0xFF, 0x00, 0x00, 0x00))
        end
      end

      sumCheckDist = sumCheckDist + GetDistance(checksPos, myHero)
      
      end
      end
      end
      end
    end   
  end

  if Menu.Draw.CondemnAssistant and Menu.Control.OnC and E.ready and Menu.Condemn.wcdmethod == 2 then
            for i, enemyHero in ipairs(EnemyHeroes) do
                if Menu.Condemn.condemnSubMenu["enableCondemn"..i] then 
                    if enemyHero ~= nil and enemyHero.valid and not enemyHero.dead and enemyHero.visible and GetDistance(enemyHero) <= 715 and GetDistance(enemyHero) > 0 then
                        local enemyPosition = FHPrediction.PredictPosition(enemyHero, eDelay)
                        local PushPos = enemyPosition + (Vector(enemyPosition) - myHero):normalized()*420

                        if enemyHero.x > 0 and enemyHero.z > 0 then
                            local checks = math.ceil(420/65) --134
                            local checkDistance = (420)/checks
                            local InsideTheWall = false
                            for k=1, checks, 1 do
                                local checksPos = enemyPosition + (Vector(enemyPosition) - myHero):normalized()*(checkDistance*k)
                                local WallContainsPosition = IsWall(D3DXVECTOR3(checksPos.x, checksPos.y, checksPos.z))
                                if WallContainsPosition then
                                    InsideTheWall = true
                                    break
                                end

                            if PushPos.x > 0 and PushPos.z > 0 and InsideTheWall then
                               CircleDraw(PushPos.x, PushPos.y, PushPos.z, 35, ARGB(0xFF, 0, 0xFF, 0))
                            else
                            AllInsideWall = false
                            if PushPos.x > 0 and PushPos.z > 0 then
                               CircleDraw(PushPos.x, PushPos.y, PushPos.z, 35, ARGB(0xFF, 0xFF, 0, 0))
                            end
                            end
                        end
                    end
                end
            end
        end
    end

  if E.ready and Menu.Control.eafteraakey then
    local myPos = WorldToScreen(D3DXVECTOR3(myHero.x, myHero.y, myHero.z))
    DrawText("Condemn After Next AA is Active", 20, myPos.x, myPos.y, ARGB(0xFF, 0xFF, 0xFF, 0xFF))
  end
  
  if Menu.Draw.AA then
      CircleDraw(myHero.x, myHero.y, myHero.z, myHero.range+45+myHero.boundingRadius, ARGB(Menu.Draw.CLA[1], Menu.Draw.CLA[2],Menu.Draw.CLA[3],Menu.Draw.CLA[4]))
    end
  
  if Menu.Draw.CLFPS and Menu.Draw.Q and Q.ready then
      CircleDraw(myHero.x, myHero.y, myHero.z, Q.range+25, ARGB(Menu.Draw.CLQ[1], Menu.Draw.CLQ[2],Menu.Draw.CLQ[3],Menu.Draw.CLQ[4]))
    end
  
  if Menu.Draw.CLFPS and Menu.Draw.E and E.ready then
      CircleDraw(myHero.x, myHero.y, myHero.z, E.range+25, ARGB(Menu.Draw.CLE[1], Menu.Draw.CLE[2],Menu.Draw.CLE[3],Menu.Draw.CLE[4]))
    end
  
  if Menu.Draw.I and I.ready then
    CircleDraw(myHero.x, myHero.y, myHero.z, I.range, ARGB(Menu.Draw.CLI[1], Menu.Draw.CLI[2],Menu.Draw.CLI[3],Menu.Draw.CLI[4]))
   end
end

function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
    radius = radius or 300
    quality = math.max(8,math.floor(180/math.deg((math.asin((chordlength/(2*radius)))))))
    quality = 2 * math.pi / quality
    radius = radius*.92
    local points = {}
    for theta = 0, 2 * math.pi + quality, quality do
        local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
        points[#points + 1] = D3DXVECTOR2(c.x, c.y)
    end
    DrawLines2(points, width or 1, color or 4294967295)
end

function DrawCircle2(x, y, z, radius, color)
    local vPos1 = Vector(x, y, z)
    local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
    local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
    local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
    if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y })  then
    DrawCircleNextLvl(x, y, z, radius, 2, color, Menu.Draw.Quality)
    end
end

function CircleDraw(x,y,z,radius, color)
  DrawCircle2(x, y, z, radius, color)
end

---------------------------------------------------------------------------------

function SkinLoad()
    Menu.Autom.ChgSki:addParam("upski", "Change Skin", SCRIPT_PARAM_ONOFF, false);
    Menu.Autom.ChgSki:setCallback("upski", function(nV)
        if (nV) then
            SetSkin(myHero, Menu.Autom.ChgSki.skinID)
        else
            SetSkin(myHero, -1)
        end
    end)
    Menu.Autom.ChgSki:addParam('skinID', 'Skin', SCRIPT_PARAM_LIST, 1, {"Vindicator", "Aristocrat", "Dragonslayer", "Heartseeker", "SKT T1", "Arclight", "Chroma Pack: Green", "Chroma Pack: Red", "Chroma Pack: Silver", "Soulstealer", "Classic"})
    Menu.Autom.ChgSki:setCallback('skinID', function(nV)
        if (Menu.Autom.ChgSki.upski) then
            SetSkin(myHero, nV)
        end
    end)
    
    if (Menu.Autom.ChgSki.upski) then
        SetSkin(myHero, Menu.Autom.ChgSki.skinID)
    end
end

---------------------------------------------------------------------------------

function AutoBuy()
  
  if GetGameTimer() < 60 then
    if Menu.Autom.buyme.buydoran then
      BuyItem(1055)
    end
    if Menu.Autom.buyme.buypot then
      BuyItem(2003)
    end
    if Menu.Autom.buyme.taketrinket then
      BuyItem(3340)
    end
  end
end

---------------------------------------------------------------------------------

function CheckLevelChange()
    if LastLevelCheck + 250 < GetTickCount() and myHero.level < 19 then
        if GetGame().map.index == 8 and myHero.level < 4 and Menu.Autom.autolevel.UseAutoLevelFirst then
            LevelSpell(_Q)
            LevelSpell(_W)
            LevelSpell(_E)
        end

        LastLevelCheck = GetTickCount()
        if myHero.level ~= LastHeroLevel then
            DelayAction(function() LevelUpSpell() end, 0.25)
            LastHeroLevel = myHero.level
        end
    end
end

function LevelUpSpell()
    if Menu.Autom.autolevel.UseAutoLevelFirst and myHero.level < 4 then
        LevelSpell(AutoLevelSpellTable[AutoLevelSpellTable["SpellOrder"][Menu.Autom.autolevel.First3Level]][myHero.level])
    end

    if Menu.Autom.autolevel.UseAutoLevelRest and myHero.level > 3 then
        LevelSpell(AutoLevelSpellTable[AutoLevelSpellTable["SpellOrder"][Menu.Autom.autolevel.RestLevel]][myHero.level])
    end
end

---------------------------------------------------------------------------------

function OnBush()

local WardSlot = nil
  if GetInventorySlotItem(2045) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(2045)) == READY then
    WardSlot = GetInventorySlotItem(2045)
  elseif GetInventorySlotItem(2049) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(2049)) == READY then
    WardSlot = GetInventorySlotItem(2049)
  elseif GetInventorySlotItem(3340) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(3340)) == READY or 
  GetInventorySlotItem(3350) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(3350)) == READY or 
  GetInventorySlotItem(3361) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(3361)) == READY or 
  GetInventorySlotItem(3363) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(3363)) == READY or
  GetInventorySlotItem(3411) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(3411)) == READY or
  GetInventorySlotItem(3342) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(3342)) == READY or
  GetInventorySlotItem(3362) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(3362)) == READY  then
    WardSlot = 12
  elseif GetInventorySlotItem(2044) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(2044)) == READY then
    WardSlot = GetInventorySlotItem(2044)
  elseif GetInventorySlotItem(2043) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(2043)) == READY then
    WardSlot = GetInventorySlotItem(2043)
  end

  return WardSlot
end

function FindBush(x0, y0, z0, maxRadius, precision)

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

function Bushfind()
  if lastTime +15 > os.clock() then return end
  for _,c in pairs(GetEnemyHeroes()) do   
    if not c.dead and not c.visible then
      local time=lasttime[ c.networkID ]  --last seen time
      local pos=lastpos [ c.networkID ]   --last seen pos
      local clock=os.clock()
      
      if time and pos and clock-time < 5 and GetDistanceSqr(pos)< 1005000 then
        local FoundBush = FindBush(pos.x,pos.y,pos.z,100)
    
        if FoundBush and GetDistanceSqr(FoundBush)<600*600 then
          local WardSlot = OnBush()
          
          if WardSlot then
            CastSpell(WardSlot,FoundBush.x,FoundBush.z)
            lastTime = os.clock()
            return
          end
        end
      end
    end
  end
end

---------------------------------------------------------------------------------

function OnAnimation(unit, animation)

  if not unit.isMe then
    return
  end
  
  if animation == "recall" then
    IsRecall = true
  elseif animation == "recall_winddown" or animation == "Run" or animation == "Spell1" or animation == "Spell2" or animation == "Spell3" or animation == "Spell4" then
    IsRecall = false
  end
  
end

---------------------------------------------------------------------------------

--[[function GetDmg(spell, enemy)

  if enemy.health == 0 then
    return 0
  end
  
  local ADDmg = 0
  local APDmg = 0
  
  local Level = myHero.level
  local TotalDmg = myHero.totalDamage
  local AddDmg = myHero.addDamage
  local AP = myHero.ap
  local ArmorPen = myHero.armorPen
  local ArmorPenPercent = myHero.armorPenPercent
  local MagicPen = myHero.magicPen
  local MagicPenPercent = myHero.magicPenPercent
  
  local Armor = math.max(0, enemy.armor*ArmorPenPercent-ArmorPen)
  local ArmorPercent = Armor/(100+Armor)
  local MagicArmor = math.max(0, enemy.magicArmor*MagicPenPercent-MagicPen)
  local MagicArmorPercent = MagicArmor/(100+MagicArmor)
    
    if spell == "AA" then
    ADDmg = TotalDmg
    elseif spell == "Q" then
  
    if Q.ready then
      ADDmg = 20*Q.level+15+1.1*TotalDmg+.4*AP
    end
    
    elseif spell == "W" then
  
    if W.ready then
      APDmg = 45*W.level+25+.8*AP
    end
    
    elseif spell == "E" then
  
    if E.ready then
      APDmg = 50*E.level+25+.75*AP
    end
    
    elseif spell == "R" then
  
    if R.ready then
      APDmg = 200*R.level+150+AddDmg+.9*AP
    end
    
  end
  
  local TrueDmg = ADDmg*(1-ArmorPercent)+APDmg*(1-MagicArmorPercent)
  
  return TrueDmg
end]]--

end


---------------------------------------------------------------------------------==============================================================================================================================
---------------------------------------------------------------------------------==============================================================================================================================
---------------------------------------------------------------------------------==============================================================================================================================


if myHero.charName == Hero[2] then

function ScriptMsg(msg)
  print("<font color=\"#FF1493\">[Uneeesh Series - Corki]</b></font>  <font color=\"#FFFF00\">".. msg .."</font>")
end

function ErrorMsg(msg)
  print("<font color=\"#FF1493\">[Uneeesh Series - Corki]</b></font>  <font color=\"#FF0000\">".. msg .."</font>")
end

local Q, W, E, R, I = {}, {}, {}, {}, {}
local Loaded = false
local DPExist = FileExist(LIB_PATH.."DivinePred.lua") and FileExist(LIB_PATH.."DivinePred.luac")
local lasttime = {}
local lastTime = 0
local LastLevelCheck = 0
local lastpos = {}
local lastRemove = 0
local function Slot(name)
  if myHero:GetSpellData(SUMMONER_1).name:lower():find(name) then
    return SUMMONER_1
  elseif myHero:GetSpellData(SUMMONER_2).name:lower():find(name) then
    return SUMMONER_2
  end
end
local function dChat()
  chat1B = _G.print
  chat2B = _G.PrintChat
  _G.print = function() end
  _G.PrintChat = function() end
  DisableOverlay()
  ChatOff = true
end
local function eChat()
  _G.print = chat1B
  _G.PrintChat = chat2B
  EnableOverlay()
  ChatOff = false
end

if FileExist(LIB_PATH .. "VPrediction.lua") then
  require("VPrediction")
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function OnLoad()
  
  ItemNames       = {
    [3303]        = "ArchAngelsDummySpell",
    [3007]        = "ArchAngelsDummySpell",
    [3144]        = "BilgewaterCutlass",
    [3188]        = "ItemBlackfireTorch",
    [3153]        = "ItemSwordOfFeastAndFamine",
    [3405]        = "TrinketSweeperLvl1",
    [3411]        = "TrinketOrbLvl1",
    [3166]        = "TrinketTotemLvl1",
    [3450]        = "OdinTrinketRevive",
    [2054]        = "ItemKingPoroSnack",
    [2138]        = "ElixirOfIron",
    [2137]        = "ElixirOfRuin",
    [2139]        = "ElixirOfSorcery",
    [2140]        = "ElixirOfWrath",
    [3184]        = "OdinEntropicClaymore",
    [2050]        = "ItemMiniWard",
    [3401]        = "HealthBomb",
    [3363]        = "TrinketOrbLvl3",
    [3092]        = "ItemGlacialSpikeCast",
    [3460]        = "AscWarp",
    [3361]        = "TrinketTotemLvl3",
    [3362]        = "TrinketTotemLvl4",
    [3159]        = "HextechSweeper",
    [2051]        = "ItemHorn",
    [3146]        = "HextechGunblade",
    [3187]        = "HextechSweeper",
    [3190]        = "IronStylus",
    [3139]        = "ItemMercurial",
    [3222]        = "ItemMorellosBane",
    [3042]        = "Muramana",
    [3043]        = "Muramana",
    [3180]        = "OdynsVeil",
    [3056]        = "ItemFaithShaker",
    [2047]        = "OracleExtractSight",
    [3364]        = "TrinketSweeperLvl3",
    [2052]        = "ItemPoroSnack",
    [3140]        = "QuicksilverSash",
    [3143]        = "RanduinsOmen",
    [3074]        = "ItemTiamatCleave",
    [5000]        = "ItemTitanicHydraCleave",
    [3800]        = "ItemRighteousGlory",
    [2045]        = "ItemGhostWard",
    [3342]        = "TrinketOrbLvl1",
    [3040]        = "ItemSeraphsEmbrace",
    [3048]        = "ItemSeraphsEmbrace",
    [2049]        = "ItemGhostWard",
    [3345]        = "OdinTrinketRevive",
    [2044]        = "SightWard",
    [3341]        = "TrinketSweeperLvl1",
    [3069]        = "shurelyascrest",
    [3599]        = "KalistaPSpellCast",
    [3185]        = "HextechSweeper",
    [3077]        = "ItemTiamatCleave",
    [2009]        = "ItemMiniRegenPotion",
    [2010]        = "ItemMiniRegenPotion",
    [3023]        = "ItemWraithCollar",
    [3290]        = "ItemWraithCollar",
    [2043]        = "VisionWard",
    [3340]        = "TrinketTotemLvl1",
    [3090]        = "ZhonyasHourglass",
    [3154]        = "wrigglelantern",
    [3142]        = "YoumusBlade",
    [3157]        = "ZhonyasHourglass",
    [3512]        = "ItemVoidGate",
    [3131]        = "ItemSoTD",
    [3137]        = "ItemDervishBlade",
    [3352]        = "RelicSpotter",
    [3350]        = "TrinketTotemLvl2",
    [3085]        = "AtmasImpalerDummySpell",
  }

  Items = {
    ["ELIXIR"]      = { id = 2140, range = 2140, target = false},
    ["QSS"]         = { id = 3140, range = 2500, target = false},
    ["MercScim"]  = { id = 3139, range = 2500, target = false},
    ["BRK"]     = { id = 3153, range = 550, target = true},
    ["BWC"]     = { id = 3144, range = 550, target = true},
    ["HXG"]     = { id = 3146, range = 700, target = false},
    ["ODYNVEIL"]  = { id = 3180, range = 525, target = false},
    ["DVN"]     = { id = 3131, range = 200, target = false},
    ["ENT"]     = { id = 3184, range = 350, target = false},
    ["HYDRA"]   = { id = 3074, range = 350, target = false},
    ["TIAMAT"]    = { id = 3077, range = 350, target = false},
    ["TITANIC"]   = { id = 5000, range = 350, target = false},
    ["RanduinsOmen"]  = { id = 3143, range = 500, target = false},
    ["YGB"]     = { id = 3142, range = 600, target = false},
    ["HEX"]     = { id = 5555, range = 600, target = false},
  }

  AutoLevelSpellTable = {
        ['SpellOrder']  = {'QWE', 'QEW', 'WQE', 'WEQ', 'EQW', 'EWQ'},
        ['QWE'] = {_Q,_W,_E,_Q,_Q,_R,_Q,_W,_Q,_W,_R,_W,_W,_E,_E,_R,_E,_E},
        ['QEW'] = {_Q,_E,_W,_Q,_Q,_R,_Q,_E,_Q,_E,_R,_E,_E,_W,_W,_R,_W,_W},
        ['WQE'] = {_W,_Q,_E,_W,_W,_R,_W,_Q,_W,_Q,_R,_Q,_Q,_E,_E,_R,_E,_E},
        ['WEQ'] = {_W,_E,_Q,_W,_W,_R,_W,_E,_W,_E,_R,_E,_E,_Q,_Q,_R,_Q,_Q},
        ['EQW'] = {_E,_Q,_W,_E,_E,_R,_E,_Q,_E,_Q,_R,_Q,_Q,_W,_W,_R,_W,_W},
        ['EWQ'] = {_E,_W,_Q,_E,_E,_R,_E,_W,_E,_W,_R,_W,_W,_Q,_Q,_R,_Q,_Q}
    }

  ___GetInventorySlotItem = rawget(_G, "GetInventorySlotItem")
  _G.GetInventorySlotItem = GetSlotItem
  if myHero:GetSpellData(4).name:lower():find("exhaust") then
    exhaust = { slot = 4, key = "D", range =  650, ready = false }
  elseif myHero:GetSpellData(5).name:lower():find("exhaust") then
    exhaust = { slot = 5, key = "F", range =  650, ready = false }
  end
  SummonerSlot = Slot("summonerboost")
  ignite = Slot("summonerdot")
  heal = HealSlot()
  Update()
  Variables()
  CorkiMenu()
  SkinLoad()
  DelayAction(function()LoadOrbwalk() end, 1)
  DelayAction(function()AutoBuy()end, 3)
  Loaded = true
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function Variables()

  SACLoaded, PEWLoaded, MMALoaded, SxOrbLoaded = false, false, false, false
  
  Q = {range = 825, radius = 270, speed = 700, delay = 0.4}
  W = {}
  E = {range = 200}
  R = {range = 1300, width = 60, speed = 2000, delay = 0.200}
  I = {range = 600}
  
  QTargetRange = Q.range+Q.radius+100
  RTargetRange = R.range+100
  
  QMinionRange = Q.range+Q.radius+100
  QJunglemobRange = Q.range+Q.radius+100
  
  S5SR = false
  TT = false
  
  if GetGame().map.index == 15 then
    S5SR = true
  elseif GetGame().map.index == 4 then
    TT = true
  end
  
  if S5SR then
    FocusJungleNames =
    {
    "SRU_Baron12.1.1",
    "SRU_RiftHerald17.1.1",
    "SRU_Blue1.1.1",
    "SRU_Blue7.1.1",
    "Sru_Crab15.1.1",
    "Sru_Crab16.1.1",
    "SRU_Dragon_Air",
    "SRU_Dragon_Fire",
    "SRU_Dragon_Water",
    "SRU_Dragon_Earth",
    "SRU_Dragon_Elder",
    "SRU_Gromp13.1.1",
    "SRU_Gromp14.1.1",
    "SRU_Krug5.1.2",
    "SRU_Krug11.1.2",
    "SRU_Murkwolf2.1.1",
    "SRU_Murkwolf8.1.1",
    "SRU_Razorbeak3.1.1",
    "SRU_Razorbeak9.1.1",
    "SRU_Red4.1.1",
    "SRU_Red10.1.1"
    }
  JungleMobNames =
    {
    "SRU_BlueMini1.1.2",
    "SRU_BlueMini7.1.2",
    "SRU_BlueMini21.1.3",
    "SRU_BlueMini27.1.3",
    "SRU_KrugMini5.1.1",
    "SRU_KrugMini11.1.1",
    "SRU_MurkwolfMini2.1.2",
    "SRU_MurkwolfMini2.1.3",
    "SRU_MurkwolfMini8.1.2",
    "SRU_MurkwolfMini8.1.3",
    "SRU_RazorbeakMini3.1.2",
    "SRU_RazorbeakMini3.1.3",
    "SRU_RazorbeakMini3.1.4",
    "SRU_RazorbeakMini9.1.2",
    "SRU_RazorbeakMini9.1.3",
    "SRU_RazorbeakMini9.1.4",
    "SRU_RedMini4.1.2",
    "SRU_RedMini4.1.3",
    "SRU_RedMini10.1.2",
    "SRU_RedMini10.1.3"
    }
  elseif TT then
    FocusJungleNames =
    {
    "TT_NWraith1.1.1",
    "TT_NGolem2.1.1",
    "TT_NWolf3.1.1",
    "TT_NWraith4.1.1",
    "TT_NGolem5.1.1",
    "TT_NWolf6.1.1",
    "TT_Spiderboss8.1.1"
    }   
    JungleMobNames =
    {
    "TT_NWraith21.1.2",
    "TT_NWraith21.1.3",
    "TT_NGolem22.1.2",
    "TT_NWolf23.1.2",
    "TT_NWolf23.1.3",
    "TT_NWraith24.1.2",
    "TT_NWraith24.1.3",
    "TT_NGolem25.1.1",
    "TT_NWolf26.1.2",
    "TT_NWolf26.1.3"
    }
  else
    FocusJungleNames =
    {
    }   
    JungleMobNames =
    {
    }
  end
  
  QTS = TargetSelector(TARGET_LESS_CAST, QTargetRange, DAMAGE_MAGIC, false)
  RTS = TargetSelector(TARGET_LESS_CAST, RTargetRange, DAMAGE_MAGIC, false)
  TES = TargetSelector(TARGET_PRIORITY, 600, DAMAGE_MAGIC)
  
  EnemyHeroes = GetEnemyHeroes()
  EnemyMinions = minionManager(MINION_ENEMY, QMinionRange, myHero, MINION_SORT_MAXHEALTH_DEC)
  JungleMobs = minionManager(MINION_JUNGLE, QJunglemobRange, myHero, MINION_SORT_MAXHEALTH_DEC)
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function CorkiMenu()

    Menu = scriptConfig("Uneeesh Corki", "UC_MAIN")
    
    Menu:addSubMenu("[Corki]: Control Settings", "Control")
    Menu.Control:addParam("OnC", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
    Menu.Control:addParam("OnF", "Laneclear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('V'))
    Menu.Control:addParam("OnJF", "Jungleclear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('V'))
    Menu.Control:addParam("OnP", "Poke Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('C'))
    Menu.Control:addParam("OnL", "Lasthit Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('X'))
    Menu.Control:addParam("OnJS", "Junglesteal Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('X'))
    Menu.Control:addParam("OnE", "Flee Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('L'))
    Menu.Control:addParam("OnPT", "Poke Toggle", SCRIPT_PARAM_ONKEYTOGGLE, true, GetKey('N'))
    Menu.Control:addParam("OnJST", "Junglesteal Toggle", SCRIPT_PARAM_ONKEYTOGGLE, true, GetKey('J'))
    Menu.Control:addParam("tmpdisable", "Stop Junglesteal Toggle", SCRIPT_PARAM_ONKEYDOWN, false, 17)
    Menu.Control:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Control:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
   
    Menu:addSubMenu("[Corki]: Combo Settings", "Combo")
    Menu.Combo:addParam("Mode", "Casting Mode", SCRIPT_PARAM_LIST, 1, {"Insane", "Humanoid"})
    Menu.Combo:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addParam("Q2", "Use if Mana Percent > % >", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
    Menu.Combo:addParam("R", "Use R", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addParam("R2", "Use if Mana Percent > % >", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
    Menu.Combo:addParam("focus", "Left Click Focus Target", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addParam("vision", "Auto vision on Bush", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    
    Menu:addSubMenu("[Corki]: Laneclear Settings", "Farm")
    Menu.Farm:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
    Menu.Farm:addParam("Q2", "Use if Mana Percent > % >", SCRIPT_PARAM_SLICE, 70, 0, 100, 0)
    Menu.Farm:addParam("R", "Use R", SCRIPT_PARAM_ONOFF, true)
    Menu.Farm:addParam("R2", "Use if Mana Percent > % >", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
    Menu.Farm:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Farm:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
        
    Menu:addSubMenu("[Corki]: Jungleclear Settings", "JFarm")
    Menu.JFarm:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
    Menu.JFarm:addParam("Q2", "Use if Mana Percent > % >", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
    Menu.JFarm:addParam("R", "Use R", SCRIPT_PARAM_ONOFF, true)
    Menu.JFarm:addParam("R2", "Use if Mana Percent > % >", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
    Menu.JFarm:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.JFarm:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
      
    Menu:addSubMenu("[Corki]: Poke Settings", "Harass")
    Menu.Harass:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
    Menu.Harass:addParam("Q2", "Use if Mana Percent > % >", SCRIPT_PARAM_SLICE, 70, 0, 100, 0)
    Menu.Harass:addParam("R", "Use R", SCRIPT_PARAM_ONOFF, true)
    Menu.Harass:addParam("R2", "Use if Mana Percent > % >", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
    Menu.Harass:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Harass:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    
    Menu:addSubMenu("[Corki]: LastHit Settings", "LastHit")
    Menu.LastHit:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, false)
    Menu.LastHit:addParam("Q2", "Use if Mana Percent > % >", SCRIPT_PARAM_SLICE, 80, 0, 100, 0)
    Menu.LastHit:addParam("R", "Use R", SCRIPT_PARAM_ONOFF, true)
    Menu.LastHit:addParam("R2", "Use if Mana Percent > % >", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
    Menu.LastHit:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.LastHit:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")

    
    Menu:addSubMenu("[Corki]: Junglesteal Settings", "JSteal")
    Menu.JSteal:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
    Menu.JSteal:addParam("R", "Use R", SCRIPT_PARAM_ONOFF, true)
    Menu.JSteal:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.JSteal:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    
    Menu:addSubMenu("[Corki]: Killsteal Settings", "KillSteal")
    Menu.KillSteal:addParam("On", "Enable Killsteal", SCRIPT_PARAM_ONOFF, true)
    Menu.KillSteal:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
    Menu.KillSteal:addParam("R", "Use R", SCRIPT_PARAM_ONOFF, true)
    Menu.KillSteal:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.KillSteal:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    
    Menu:addSubMenu("[Corki]: Display Settings", "Draw")
    Menu.Draw:addParam("On", "Enable Draws", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("AA", "Draw AA range", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("CLA", "Color AA range", SCRIPT_PARAM_COLOR, {144, 144, 40, 164})
    Menu.Draw:addParam("Q", "Draw Q range", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("CLQ", "Color Q range", SCRIPT_PARAM_COLOR, {141, 124, 4, 4})
    Menu.Draw:addParam("R", "Draw R range", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("CLR", "Color R range", SCRIPT_PARAM_COLOR, {255, 255, 40, 164})
    if ignite then
    Menu.Draw:addParam("I", "Draw Ignite range", SCRIPT_PARAM_ONOFF, false)
    Menu.Draw:addParam("CLI", "Color Ignite range", SCRIPT_PARAM_COLOR, {141, 124, 114, 114})
    end
    Menu.Draw:addParam("CLFPS", "Enable FPS Friendly Draws", SCRIPT_PARAM_ONOFF, false)
    Menu.Draw:addParam("Quality", "FPS Draws Quality(High=Better FPS)", SCRIPT_PARAM_SLICE, 176, 75, 2000, 0)
    Menu.Draw:addParam("Trg", "Draw Current Target", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("ownp", "Enable Pathway Draw", SCRIPT_PARAM_ONOFF, false)
    Menu.Draw:addParam("opp", "Draw Enemy Pathway", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("ComboDamage", "Draw Predicted Damage", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("Info","", SCRIPT_PARAM_INFO, "")
    Menu.Draw:addParam("stream", "Enable Streaming Mode", SCRIPT_PARAM_ONKEYTOGGLE, false, 118)
    Menu.Draw:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Draw:addParam("Info1", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    
    Menu:addSubMenu("[Corki]: Item&Summoner Settings", "Items")
    Menu.Items:addSubMenu("BotRK", "BotRK")
    Menu.Items.BotRK:addParam("bork", "Use BotRK", SCRIPT_PARAM_ONOFF, true)
    Menu.Items.BotRK:addParam('maxownhealth', 'Max. own % Health to use', SCRIPT_PARAM_SLICE, 50, 1, 100, 0)
    Menu.Items.BotRK:addParam('minenemyhealth', 'Min. enemy % Health to use', SCRIPT_PARAM_SLICE, 20, 1, 100, 0)
    Menu.Items:addSubMenu("Bilgewater", "Bilgewater")
    Menu.Items.Bilgewater:addParam("bilg", "Use Bilgewater", SCRIPT_PARAM_ONOFF, true)
    Menu.Items.Bilgewater:addParam("maxownhealth", "Max. own % Health to use", SCRIPT_PARAM_SLICE, 50, 1, 100, 0)
    Menu.Items.Bilgewater:addParam("minenemyhealth", "Min. enemy % Health to use", SCRIPT_PARAM_SLICE, 20, 1, 100, 0)
    --Menu.Items:addSubMenu("Youmuu", "Youmuu")
    --Menu.Items.Youmuu:addParam("yomu", "Use Youmuu", SCRIPT_PARAM_ONOFF, true)

    Menu.Items:addSubMenu("Health Potions", "potion")
    Menu.Items.potion:addParam("Key", "Use Only Press to", SCRIPT_PARAM_ONKEYDOWN, false, 32)
    Menu.Items.potion:addParam("Always", "Use Always", SCRIPT_PARAM_ONOFF, false)
    Menu.Items.potion:addParam("enemy", "Use if not enemies", SCRIPT_PARAM_ONOFF, false)
    Menu.Items.potion:addParam("health", "If My Health % is <", SCRIPT_PARAM_SLICE, 60, 0, 100, 0) 
    Menu.Items:addSubMenu("Remove CC", "cc")
    Menu.Items.cc:addParam("Key", "Use Only Press to", SCRIPT_PARAM_ONKEYDOWN, false, 32)
    Menu.Items.cc:addParam("Always", "Use Always", SCRIPT_PARAM_ONOFF, true) 
    if SummonerSlot then
    Menu.Items.cc:addParam("Summoner", "Use Cleanse", SCRIPT_PARAM_ONOFF, true) 
    end
    Menu.Items.cc:addParam("delay", "Remove Delay (ms)", SCRIPT_PARAM_SLICE, 0, 0, 400, 0)
    if ignite then
    Menu.Items:addSubMenu("Ignite", "ignite")
    Menu.Items.ignite:addParam("set", "Use Smart Ignite", SCRIPT_PARAM_LIST, 2, {"OFF", "Optimal", "Aggressive"})
    end
    if exhaust then 
    Menu.Items:addSubMenu("Exhaust", "exhaust")
    Menu.Items.exhaust:addParam("exh", "Exhaust Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey(exhaust.key))
    Menu.Items:addTS(TES)
    TES = TargetSelector(TARGET_PRIORITY, 600, DAMAGE_MAGIC) 
    TES.name = "Exhaust"
    end
    if heal then
    Menu.Items:addSubMenu("Heal/Barrier", "heal")
    Menu.Items.heal:addParam("enable", "Enable to use", SCRIPT_PARAM_ONOFF, true)
    Menu.Items.heal:addParam("health", "If My Health % is Less Than", SCRIPT_PARAM_SLICE, 10, 0, 100, 0)
    if realheals then
    Menu.Items.heal:addParam("ally", "Use for Ally", SCRIPT_PARAM_ONOFF, false)
    end
    end
    Menu.Items:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Items:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    
    Menu:addSubMenu("[Corki]: Automation", "Autom")
    Menu.Autom:addSubMenu("AutoLevelSpells Settings", "autolevel")
    Menu.Autom.autolevel:addParam("UseAutoLevelFirst", "Use AutoLevelSpells Level 1-3", SCRIPT_PARAM_ONOFF, false)
    Menu.Autom.autolevel:addParam("UseAutoLevelRest", "Use AutoLevelSpells Level 4-18", SCRIPT_PARAM_ONOFF, false)
    Menu.Autom.autolevel:addParam("First3Level", "Level 1-3", SCRIPT_PARAM_LIST, 1, {"Q-W-E", "Q-E-W", "W-Q-E", "W-E-Q", "E-Q-W", "E-W-Q"})
    Menu.Autom.autolevel:addParam("RestLevel", "Level 4-18", SCRIPT_PARAM_LIST, 1, {"Q-W-E", "Q-E-W", "W-Q-E", "W-E-Q", "E-Q-W", "E-W-Q"})
    Menu.Autom.autolevel:addParam("Blank", "", SCRIPT_PARAM_INFO, "","" )
    Menu.Autom.autolevel:addParam("Blank", "You can Click on the Q-W-E", SCRIPT_PARAM_INFO, "","" )
    Menu.Autom.autolevel:addParam("Blank", "to change the AutoLevelOrder", SCRIPT_PARAM_INFO, "","" )
    Menu.Autom:addSubMenu("Skin Changer", "ChgSki")
    Menu.Autom:addSubMenu("Auto Buy Item", "buyme")
    Menu.Autom.buyme:addParam("buydoran", "Doran's Blade", SCRIPT_PARAM_ONOFF, true)
    Menu.Autom.buyme:addParam("buypot", "Potion", SCRIPT_PARAM_ONOFF, true)
    Menu.Autom.buyme:addParam("taketrinket", "Green Trinket", SCRIPT_PARAM_ONOFF, true)
    Menu.Autom.buyme:addParam("changeblue", "Lvl 9 Blue Trinket", SCRIPT_PARAM_ONOFF, true)
    Menu.Autom:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Autom:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
  
    Menu:addSubMenu("[Corki]: Spell Priority Settings", "Spell")
    
    Menu.Spell:addTS(QTS)
    Menu.Spell:addParam("blank", "      ", SCRIPT_PARAM_INFO, "  ")
    Menu.Spell:addParam("blank", "   ----------------------------------------------------   ", SCRIPT_PARAM_INFO, "------------- ")
    Menu.Spell:addParam("blank", "      ", SCRIPT_PARAM_INFO, "  ")
    Menu.Spell:addParam("blank", "  [Recommenned LessCast]  ", SCRIPT_PARAM_INFO, " ")
    Menu.Spell:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Spell:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    
    Menu:addSubMenu("[Corki]: Prediction Settings", "Prediction")

    Menu.Prediction:addParam("blank", "      ", SCRIPT_PARAM_INFO, "  ")
    Menu.Prediction:addParam("Choice", "Prediction Method", SCRIPT_PARAM_LIST, 1, {"VPrediction", "HPrediction", "SPrediction", "FHPrediction", "KPrediction", "Divine Prediction"})
    Menu.Prediction:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Prediction:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
      
      Menu.Prediction:addSubMenu("VPrediction", "VPrediction")
      Menu.Prediction.VPrediction:addParam("Q", "Q Hitchance (2)", SCRIPT_PARAM_SLICE, 2, 1, 5, 1)  
      Menu.Prediction.VPrediction:addParam("R", "R Hitchance (1.5)", SCRIPT_PARAM_SLICE, 1.5, 1, 5, 1)
      Menu.Prediction:addSubMenu("HPrediction", "HPrediction")
      Menu.Prediction.HPrediction:addParam("Q", "Q Hitchance (1.5)", SCRIPT_PARAM_SLICE, 1.5, 1, 3, 1)  
      Menu.Prediction.HPrediction:addParam("R", "R Hitchance (1)", SCRIPT_PARAM_SLICE, 1, 1, 3, 1)
      Menu.Prediction:addSubMenu("SPrediction", "SPrediction")
      Menu.Prediction.SPrediction:addParam("Q", "Q Hitchance (1.50)", SCRIPT_PARAM_SLICE, 1.50, 1, 3, 1)  
      Menu.Prediction.SPrediction:addParam("R", "R Hitchance (1.33)", SCRIPT_PARAM_SLICE, 1.33, 1, 3, 1)
      Menu.Prediction:addSubMenu("KPrediction", "KPrediction")
      Menu.Prediction.KPrediction:addParam("Q", "Q Hitchance (1.5)", SCRIPT_PARAM_SLICE, 1.5, 1, 4, 1)  
      Menu.Prediction.KPrediction:addParam("R", "R Hitchance (1)", SCRIPT_PARAM_SLICE, 1, 1, 4, 1)
      Menu.Prediction:addSubMenu("Divine Prediction", "DPrediction")
      Menu.Prediction.DPrediction:addParam("Q", "Q Hitchance (%70)", SCRIPT_PARAM_SLICE, 70, 1, 100, 0)  
      Menu.Prediction.DPrediction:addParam("R", "R Hitchance (%50)", SCRIPT_PARAM_SLICE, 50, 1, 100, 0)
      Menu.Prediction:addSubMenu("FHPrediction", "FHPrediction")
      Menu.Prediction.FHPrediction:addParam("Q", "Q Hitchance (1.3)", SCRIPT_PARAM_SLICE, 1.3, 1, 2, 1)  
      Menu.Prediction.FHPrediction:addParam("R", "R Hitchance (1.1)", SCRIPT_PARAM_SLICE, 1.1, 1, 2, 1)
    LoadPrediction(Menu.Prediction.Choice)
    Menu.Prediction:setCallback("Choice", function(var) LoadPrediction(Menu.Prediction.Choice) end)

    Menu:addSubMenu("[Corki]: Orbwalker Settings", "Orbwalker")
    
    
    Menu.Spell:addTS(RTS)
    QTS.name = "Corki Q"
    RTS.name = "Corki R"
    
    Menu:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu:addParam("Info", "http://botoflegends.com", SCRIPT_PARAM_INFO, "")
    Menu:addParam("SVersion", "Script Version ", SCRIPT_PARAM_LIST, 1, {"" .. Version})
    Menu:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu:addParam("popup", "Click For Latest Changelog", SCRIPT_PARAM_ONOFF, false)
    
    Menu.Control:permaShow("OnPT")
    Menu.Control:permaShow("OnJST")
    Menu.Combo:permaShow("Mode")
    Menu.Prediction:permaShow("Choice")

    Menu.Control.OnC = false
    Menu.Control.OnF = false
    Menu.Control.OnJF = false
    Menu.Control.OnP = false
    Menu.Control.OnL = false
    Menu.Control.OnJS = false
    Menu.Control.OnE = false
    Menu.Control.tmpdisable = false
  
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function LoadOrbwalk()

  if _G.AutoCarry and _G.Reborn_Initialised then
    SACLoaded = true
    Menu.Orbwalker:addParam("Info", "             ----->>> SAC Detected & Loaded <<<-----   ", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    ScriptMsg("Sida's Auto Carry Detected.")
  elseif _G.Reborn_Loaded then
    DelayAction(function() LoadOrbwalk() end, 1)
  elseif _G.MMA_IsLoaded then
    MMALoaded = true
    Menu.Orbwalker:addParam("Info", "             ----->>> MMA Detected & Loaded <<<-----   ", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    ScriptMsg("Marksman's Mighty Assistant Detected.")
  elseif _G._Pewalk then
    PEWLoaded = true
    Menu.Orbwalker:addParam("Info", "             ----->>> Pewalk Detected & Loaded <<<-----   ", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    ScriptMsg("Pewalk Detected.")
  elseif FileExist(LIB_PATH .. "SxOrbWalk.lua") then
    require 'SxOrbWalk'
    SxOrb = SxOrbWalk()
    SxOrb:LoadToMenu(Menu.Orbwalker)
    Menu.Orbwalker:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    SxOrbLoaded = true
    ScriptMsg("Sxorbwalk Detected.")
  else
    ErrorMsg("WARNING:Orbwalker Not Found!")
  end
  
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

--[[function LoadOrbwalker(choice)

  if choice == 1 then

    --[[if _G.NebelwolfisOrbWalkerInit or _G.NebelwolfisOrbWalkerLoaded then
      NOWLoaded = true
      ScriptMsg(" ")
      return
    end

    if _Pewalk then
      PEWLoaded = true
      ErrorMsg("Pewalk is enabled, you have to disable Pewalk in BoL menu for using Sida's Auto Carry.")
      return
    end

    if _G.MMA_IsLoaded then
      MMALoaded = true
      ErrorMsg("Marksman's Mighty Assistant is enabled, you have to disable Marksman's Mighty Assistant in BoL menu for using Sida's Auto Carry.")
      return
    end

    if _G.Reborn_Loaded then
      SACLoaded = true

      if _G.AutoCarry and _G.Reborn_Initialised then
        Menu.Orbwalker:addParam("Info", "             ----->>> SAC Detected & Loaded <<<-----   ", SCRIPT_PARAM_INFO, "")
      else
        DelayAction(function() LoadOrbwalker(1) end, 1)
      end

    else

      local function UpdateSAC()

        if FileExist(SCRIPT_PATH .. "Sida's Auto Carry.lua") then
          ErrorMsg("Error loading Sida's Auto Carry, try again or try to use another orbwalker else contact with developer.")
          Menu.Orbwalker:addParam("Info", "             ----->>> Loading Failed - SAC <<<-----   ", SCRIPT_PARAM_INFO, "")
        else
          DownloadFile("https://raw.githubusercontent.com/SidaBoL/Scripts/master/Misc/Sida's%20Auto%20Carry.lua", SCRIPT_PATH .. "Sida's Auto Carry.lua", function() UpdateSAC() end)
        end

      end

      UpdateSAC()
    end

  elseif choice == 2 then

    if _G.Reborn_Loaded then
      SACLoaded = true
      ErrorMsg("Sida's Auto Carry is enabled, you have to disable Sida's Auto Carry in BoL menu for using Pewalk.")
      return
    end

    if _G.MMA_IsLoaded then
      MMALoaded = true
      ErrorMsg("Marksman's Mighty Assistant is enabled, you have to disable Marksman's Mighty Assistant in BoL menu for using Pewalk.")
      return
    end

    --[[if _G.NebelwolfisOrbWalkerInit or _G.NebelwolfisOrbWalkerLoaded then
      NOWLoaded = true
      ScriptMsg(" ")
      return
    end

    if _Pewalk then
      PEWLoaded = true
      Menu.Orbwalker:addParam("Info", "             ----->>> Pewalk Detected & Loaded <<<-----   ", SCRIPT_PARAM_INFO, "")

      local function Disable()

        if _Pewalk.DisableSkillFarm then
          _Pewalk.DisableSkillFarm(_Q) _Pewalk.DisableSkillFarm(_W) _Pewalk.DisableSkillFarm(_E) _Pewalk.DisableSkillFarm(_R)
        else
          DelayAction(function() Disable() end, 1)
        end

      end

      Disable()
    else

      local function UpdatePEW()

        if FileExist(SCRIPT_PATH .. "Pewalk.lua") then
          ErrorMsg("Error loading Pewalk, try again or try to use another orbwalker else contact with developer.")
          Menu.Orbwalker:addParam("Info", "             ----->>> Loading Failed - Pewalk <<<-----   ", SCRIPT_PARAM_INFO, "")
        else
          DownloadFile("https://raw.githubusercontent.com/PewPewPew2/BoL/master/Pewalk.lua", SCRIPT_PATH .. "Pewalk.lua", function() UpdatePEW() end)
        end

      end

      UpdatePEW()
    end

  elseif choice == 3 then

    if _G.Reborn_Loaded then
      SACLoaded = true
      ErrorMsg("Sida's Auto Carry is enabled, you have to disable Sida's Auto Carry in BoL menu for using Marksman's Mighty Assistant.")
      return
    end

    if _Pewalk then
      PEWLoaded = true
      ErrorMsg("Pewalk is enabled, you have to disable Pewalk in BoL menu for using Marksman's Mighty Assistant. ")
      return
    end

    if _G.MMA_IsLoaded then
      MMALoaded = true
      Menu.Orbwalker:addParam("Info", "             ----->>> MMA Detected & Loaded <<<-----   ", SCRIPT_PARAM_INFO, "")
    else

      local function UpdateMMA()

        if FileExist(SCRIPT_PATH .. "MarksmanMightyAssistant.lua") then
          ErrorMsg("Error loading Marksman's Mighty Assistant, try again or try to use another orbwalker else contact with developer.")
          Menu.Orbwalker:addParam("Info", "             ----->>> Loading Failed - MMA <<<-----   ", SCRIPT_PARAM_INFO, "")
        else
          DownloadFile("http://manciuszz.net/mma2.0/MarksmanMightyAssistant.lua", SCRIPT_PATH .. "MarksmanMightyAssistant.lua", function() UpdateMMA() end)
        end

      end

      UpdateMMA()
      
    end
  end
end

function UnloadOrbwalker()

  if SACLoaded or PEWLoaded or MMALoaded then
    ScriptMsg("Press F9 x2 to disable orbwalker.")
  end
end]]--

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function LoadPrediction(choice)

  if choice == 1 and not VPred then

    if _G.VPrediction_Init then
      VPred = VPrediction()  
    else

      local function UpdateVPred()

        if FileExist(LIB_PATH .. "VPrediction.lua") then
          require("VPrediction")
          VPred = VPrediction()    
        else
          DownloadFile("https://raw.githubusercontent.com/SidaBoL/Scripts/master/Common/VPrediction.lua", LIB_PATH .. "VPrediction.lua", function() UpdateVPred() end)
        end

      end

      UpdateVPred()
    end
    
  

  elseif choice == 2 and not HPred then

    if _G.HPrediction_Init then
      HPred = HPrediction()  
    else

      local function UpdateHPred()

        if FileExist(LIB_PATH .. "HPrediction.lua") then
          require("HPrediction")
          HPred = HPrediction()    
        else
          DownloadFile("https://raw.githubusercontent.com/Jaikor/BoL-1/master/HTTF/Common/HPrediction.lua", LIB_PATH .. "HPrediction.lua", function() UpdateHPred() end)
        end

      end

      UpdateHPred()
    end
    
    elseif choice == 3 and not SPred then

    if _G.SPrediction_Init then
      SPred = SPrediction()  
    else

      local function UpdateSPred()

        if FileExist(LIB_PATH .. "SPrediction.lua") then
          require("SPrediction")
          SPred = SPrediction()    
        else
          DownloadFile("https://raw.githubusercontent.com/nebelwolfi/BoL/master/Common/SPrediction.lua", LIB_PATH .. "SPrediction.lua", function() UpdateSPred() end)
        end

      end

      UpdateSPred()
    end

  elseif choice == 4 and not FHPred then

    if FileExist(LIB_PATH .. "FHPrediction.lua") then
          require("FHPrediction")
          FHPred = FHPrediction
    else  
      ErrorMsg("FHPrediction not found , please download manually from the forums , loaded VPrediction for now.")
      LoadPrediction(1)
    end
  
  elseif choice == 5 and not KPred then

    if _G.KPrediction_Init then
      KPred = KPrediction()  
    else

      local function UpdateKPred()

        if FileExist(LIB_PATH .. "KPrediction.lua") then
          require("KPrediction")
          KPred = KPrediction()    
        else
          DownloadFile("https://raw.githubusercontent.com/Jaikor/BoL-1/master/HTTF/Common/KPrediction.lua", LIB_PATH .. "KPrediction.lua", function() UpdateKPred() end)
        end

      end

      UpdateKPred()
    end

 elseif choice == 6 and not DPred then
    if DPExist then
      require("DivinePred")
      DPred = DivinePred()
      DPred:bindSS("Q",50)
      DPred:bindSS("R",50)
      DelayAction(function()
        if not DivinePred.isAuthed() then
          ErrorMsg("You have no access to Divine Pred, loaded VPrediction for now.")
          LoadPrediction(1)
        end
      end,3)
    else
      ErrorMsg("Divine Prediction not found , please download manually from the forums , loaded VPrediction for now.")
      LoadPrediction(1)
    end
  end

end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function OnTick()
  if not Loaded then
    return
  end

  if myHero.dead then
    return
  end
  
  Checks()

  if Menu.Combo.Mode == 1 then
    TargetsInsane()
  elseif Menu.Combo.Mode == 2 then
    TargetsHumanoid()
  end
  
  if Menu.Control.OnC then
    Combo()
  end
  
  if Menu.Control.OnC and Menu.Combo.vision then
    Bushfind()
  end

  if Menu.popup then
    Menu.popup = false
    PopUp = true
  end
  
  if Menu.Control.OnF then
    Farm()
  end
  
  if Menu.Control.OnJF then
    JFarm()
  end
  
  if Menu.Autom.autolevel.UseAutoLevelFirst or Menu.Autom.autolevel.UseAutoLevelRest then
    CheckLevelChange()
    LevelUpSpell()
  end
  
  if Menu.Control.OnP or Menu.Control.OnPT then
    Harass()
  end
  
  if Menu.Control.OnPT then
    HarassAlways()
  end
  
  if Menu.Control.OnL then
    LastHit()
  end
  
  if Menu.Control.OnJS then
    JSteal()
  end
  
  if Menu.Control.OnJST then
    JstealAlways()
  end
  
  if Menu.KillSteal.On then
    KillSteal()
  end
  
  if Menu.Control.OnE then
    Flee()
  end

  if Menu.Draw.stream and not ChatOff then
    dChat()
  elseif not Menu.Draw.stream and ChatOff then
    eChat()
  end
  
  if Menu.Items.BotRK.bork then
    if myHero.health / myHero.maxHealth <=  Menu.Items.BotRK.maxownhealth / 100 then
      local unit = TargetsInsane() or TargetsHumanoid()
      if ValidTarget(unit, 1000) then
        if unit.health / unit.maxHealth <=  Menu.Items.BotRK.minenemyhealth  / 100 then
          BotRK(unit)
        end
      end
    end 
  end 
     
    if Menu.Items.Bilgewater.bilg then
    if myHero.health / myHero.maxHealth <=  Menu.Items.Bilgewater.maxownhealth / 100 then
      local unit = TargetsInsane() or TargetsHumanoid()
      if ValidTarget(unit, 1000) then
        if unit.health / unit.maxHealth <=  Menu.Items.Bilgewater.minenemyhealth / 100 then
          Bilgewater(unit)
        end
      end
    end 
  end 
    
    if exhaust and Menu.Items.exhaust.exh then 
    if myHero:CanUseSpell(exhaust.slot) == 0 then
      TES:update()
      if ValidTarget(TES.target) and TES.target.type == myHero.type then
        exhFunction(TES.target) 
      end
    end
  end

  if heal then
    if ValidTarget(TargetsInsane() or TargetsHumanoid(), 1000) then
      if Menu.Items.heal.enable and myHero:CanUseSpell(heal) == 0 then
        if myHero.level > 5 and myHero.health/myHero.maxHealth < Menu.Items.heal.health/100 then
          CastSpell(heal)
        elseif  myHero.level < 6 and myHero.health/myHero.maxHealth < (Menu.Items.heal.health/100)*.75 then
          CastSpell(heal)
        end
        
        if realheals and Menu.Items.heal.ally then
          local ally = findClosestAlly(myHero)
          if ally and not ally.dead and GetDistance(ally) < 850 then
            if  ally.health/ally.maxHealth < Menu.Items.heal.health/100 then
              CastSpell(heal)
            end
          end
        end
      end
    end
  end

  if not myHero.dead then
    if (Menu.Items.potion.Key or Menu.Items.potion.Always) and not potionOn and not InFountain() and (myHero.health/myHero.maxHealth)*100 < Menu.Items.potion.health then
      UsePotion()
    end
  end
  
  if ignite and Menu.Items.ignite.set > 1 and (myHero:CanUseSpell(ignite) == READY) then 
    AutoIgnite()
  end

end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function AlliesAround(Unit, range)
    local c=0
    if Unit == nil then return 0 end
    for i=1,heroManager.iCount do hero = heroManager:GetHero(i) if hero.team == myHero.team and hero.x and hero.y and hero.z and GetDistance(hero, Unit) < range then c=c+1 end end return c
end

function EnemiesAround(Unit, range)
    local c=0
    if Unit == nil then return 0 end
    for i=1,heroManager.iCount do hero = heroManager:GetHero(i) if hero ~= nil and hero.team ~= myHero.team and hero.x and hero.y and hero.z and GetDistance(hero, Unit) < range then c=c+1 end end return c
  end

function findClosestAlly(obj)
    local closestAlly = nil
    local currentAlly = nil
  for i, currentAlly in pairs(GetAllyHeroes()) do
        if currentAlly and not currentAlly.dead then
            if closestAlly == nil then
                closestAlly = currentAlly
      end
            if GetDistanceSqr(currentAlly.pos, obj) < GetDistanceSqr(closestAlly.pos, obj) then
        closestAlly = currentAlly
            end
        end
    end
  return closestAlly
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function CheckItem(ItemName)
  for i = 6, 12 do
    local item = myHero:GetSpellData(i).name
    if item and item:lower() == ItemName then
      return i
    end
  end
end

function checkSpecific(unit, buffname)
  if unit.buffCount then
    for i = 1, unit.buffCount do
      local buff = unit:getBuff(i)
      if buff and buff.valid and buff.name then
        if buff.name:lower():find(buffname) then
          return true
        end
      end
    end
  end
end

function exhFunction(unit)
  moveToCursor()
  CastSpell(exhaust.slot, unit)
end

function moveToCursor()
  local MouseMove = Vector(myHero) + (Vector(mousePos) - Vector(myHero)):normalized() * 500
  myHero:MoveTo(MouseMove.x, MouseMove.z) 
end

function OnUpdateBuff(unit, buff, stacks)
  if not unit or not buff then return end
  if unit.isMe then
    if buff.name:lower():find("regenerationpotion") or buff.name:lower():find("itemminiregenpotion") or buff.name:lower():find("crystalflask") then
      potionOn = true
    end
  end
end

function OnRemoveBuff(unit, buff)
  if not unit or not buff then return end
  if unit.isMe then
    if buff.name:lower():find("regenerationpotion") or buff.name:lower():find("itemminiregenpotion") or buff.name:lower():find("crystalflask") then
      potionOn = false
    end
  end
end
local lastPotion = 0

function UsePotion()
  if os.clock() - lastPotion < 8 then return end
  if not Menu.Items.potion.enemy then
    if CountEnemiesNearUnitReg(myHero, 750) == 0 then return end
  end
  
  local slot = GetSlotItemFromName("crystalflask")
  if not slot then
    slot = GetSlotItemFromName("RegenerationPotion")
  end
  if not slot then
    slot = GetSlotItemFromName("itemminiregenpotion")
  end
  if slot then
    CastSpell(slot)
    lastPotion = os.clock()
  end
end
local lastPotionMana = 0

function UsePotionMana()
  if CountEnemiesNearUnitReg(myHero, 1000) == 0 then return end
  if os.clock() - lastPotionMana < 8 then return end
  local slot = GetSlotItemFromName("crystalflask")
  if not slot then
    slot = GetSlotItemFromName("flaskofcrystalwater")
  end
  if slot then
    CastSpell(slot)
    lastPotionMana = os.clock()
  end
end

function GetSlotItemFromName(itemname)
  local slot
  for i = 6, 12 do
    local item = myHero:GetSpellData(i).name
    if item and item:lower():find(itemname:lower()) and myHero:CanUseSpell(i) == READY then
      slot = i
    end
  end
  return slot
end

function GetSlotItem(id, unit)
  unit = unit or myHero

  if (not ItemNames[id]) then
    return ___GetInventorySlotItem(id, unit)
  end

  local name  = ItemNames[id]
  
  for slot = ITEM_1, ITEM_7 do
    local item = unit:GetSpellData(slot).name
    if item and item:lower() == name:lower() and myHero:CanUseSpell(slot) == READY then
      return slot
    end
  end
end

local lastTAttack = 0
local tDamage = 1
if AddProcessAttackCallback and heal and Menu.Items.heal.enable then
  AddProcessAttackCallback(function(unit, spell) AProc(unit, spell) end)
end

function AProc(unit, spell)
  if not unit or not unit.valid or not spell then return end

  if spell.target and spell.target.type == myHero.type and spell.target.team == myHero.team and (spell.name:lower():find("_turret_chaos") or spell.name:lower():find("_turret_order")) and not (spell.name:lower():find("4") or spell.name:lower():find("3")) then
    if GetDistance(unit) < 2000 then
      if clock() - lastTAttack < 1.75 then
        if tDamage < 1.75 then
          tDamage = tDamage + 0.375
        else
          tDamage = tDamage + 0.250
          tDamage = tDamage > 2.25 and 2.25 or tDamage
        end
      else
        tDamage = 1
      end
      lastTAttack = clock()
      
      if myHero:CanUseSpell(heal) == 0 and spell.target.isMe then
        local realDamage = unit.totalDamage / (((myHero.armor * 0.7) / 100) + 1)

        if VPred:GetPredictedHealth(myHero, 0.5) + myHero.shield <= realDamage * tDamage then
          DelayAction(function()
            CastSpell(heal)
            ScriptMsg("Saving from tower")
          end, 0.5)
        end
      end
    end
  end
end

function OnProcessSpell(unit, spell)
if not unit or not unit.valid or not spell then return end

  if heal and Menu.Items.heal.enable and myHero:CanUseSpell(heal) == 0 and spell.target and spell.target.isMe and unit.team ~= myHero.team and unit.type == myHero.type then
    if myHero.health/myHero.maxHealth <= (Menu.Items.heal.health/100)*1.5 then
      CastSpell(heal)
    end
  end
  if spell.name:lower():find("zedr") and spell.target == myHero then
    DelayAction(function()
    end, 1.7)
  end
end

function OnApplyBuff(source, unit, buff)
if not buff or not source or not source.valid or not unit or not unit.valid then return end
  if unit.isMe and (Menu.Items.cc.Always or Menu.Items.cc.Key) then
    if (source.charName == "Rammus" and buff.type ~= 8) or source.charName == "Alistar" or source.charName:lower():find("baron") or source.charName:lower():find("spiderboss") or source.charName == "LeeSin" or (source.charName == "Hecarim" and not buff.name:lower():find("fleeslow")) then return end  
    if buff.name and ((not cleanse and buff.type == 24) or buff.type == 5 or buff.type == 11 or buff.type == 22 or buff.type == 21 or buff.type == 8)
    or (buff.type == 10 and buff.name and buff.name:lower():find("fleeslow")) then
      if buff.name and buff.name:lower():find("caitlynyor") and CountEnemiesNearUnitReg(myHero, 700) == 0   then
        return false
      elseif not source.charName:lower():find("blitzcrank") then
        UseItemsCC(myHero, true)
      end          
    end           
  end  
end

function CountEnemiesNearUnitReg(unit, range)
  local count = 0
  for i, enemy in pairs(GetEnemyHeroes()) do
    if not enemy.dead and enemy.visible then
      if  GetDistanceSqr(unit, enemy) < range * range  then 
        count = count + 1 
      end
    end
  end
  return count
end

function UseItemsCC(unit, scary)
  if os.clock() - lastRemove < 1 then return end
  for i, Item in pairs(Items) do
    local Item = Items[i]
    if GetInventoryItemIsCastable(Item.id) and GetDistanceSqr(unit) <= Item.range * Item.range then
      if Item.id == 3139 or Item.id ==  3140 then
        if scary then
          DelayAction(function()
            CastItem(Item.id)
          end, Menu.Items.cc.delay/1000)  
          lastRemove = os.clock()
          return true
        end
      end
    end
  end
  if Menu.Items.cc.Summoner and SummonerSlot and myHero:CanUseSpell(SummonerSlot) == 0 then
    DelayAction(function()
      CastSpell(SummonerSlot)
    end, Menu.Items.cc.delay/1000)
    lastRemove = os.clock()
  end
end

function findClosestEnemy(obj)
    local closestEnemy = nil
    local currentEnemy = nil
  for i, currentEnemy in pairs(GetEnemyHeroes()) do
        if ValidTarget(currentEnemy) then
            if closestEnemy == nil then
                closestEnemy = currentEnemy
      end
            if GetDistanceSqr(currentEnemy.pos, obj) < GetDistanceSqr(closestEnemy.pos, obj) then
        closestEnemy = currentEnemy
            end
        end
    end
  return closestEnemy
end

function HealSlot()
  if myHero:GetSpellData(SUMMONER_1).name:lower():find("summonerheal") or myHero:GetSpellData(SUMMONER_2).name:lower():find("summonerheal") then
    realheals = true
  end
  if myHero:GetSpellData(SUMMONER_1).name:lower():find("summonerheal")  or myHero:GetSpellData(SUMMONER_1).name:lower():find("summonerbar") then
    return SUMMONER_1
  elseif myHero:GetSpellData(SUMMONER_2).name:lower():find("summonerheal") or myHero:GetSpellData(SUMMONER_2).name:lower():find("summonerbar") then
    return SUMMONER_2
  end
end

function BotrK(unit, scary)
  for i, Item in pairs(Items) do
    local Item = Items[i]
    if Item.id ~= 3140 and Item.id ~= 3139 then
      if GetInventoryItemIsCastable(Item.id) and GetDistanceSqr(unit) <= Item.range * Item.range then
        if Item.id == 3153 then
          CastItem(Item.id)
        else
          CastItem(Item.id, unit) return true
        end
      end
    end
  end
end

function Bilgewater(unit, scary)
  for i, Item in pairs(Items) do
    local Item = Items[i]
    if Item.id ~= 3140 and Item.id ~= 3139 then
      if GetInventoryItemIsCastable(Item.id) and GetDistanceSqr(unit) <= Item.range * Item.range then
        if Item.id == 3144 then
          CastItem(Item.id)
        else
          CastItem(Item.id, unit) return true
        end
      end
    end
  end
end

--[[function Youmuu()
  if Menu.Items.Youmuu.yomu then
  local slot = GetInventorySlotItem(3142)
  if Target ~= nil and ValidTarget(Target) and not Target.dead and slot ~= nil and myHero:CanUseSpell(slot) == READY then
  CastSpell(slot)
  end
end
end]]--

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function AutoIgnite()
  local IgniteDmg = 50 + (20 * myHero.level)
  local aggro = Menu.Items.ignite.set == 3 and 0.05 or 0
  for i, enemy in pairs(GetEnemyHeroes()) do
    if ValidTarget(enemy, 600) then
      local spellDamage = 0
      local adDamage = myHero:CalcDamage(enemy, myHero.totalDamage)
      spellDamage = spellDamage + adDamage
      if myHero.health < myHero.maxHealth*(0.35+aggro) and enemy.health < enemy.maxHealth*(0.34+aggro) and GetDistanceSqr(enemy) < 420 * 420 then
        CastSpell(ignite, enemy)
      end
      local r = myHero.range+65
      local trange = r < 575 and r or 575
      if isFleeingFromMe(enemy, trange) then
        if enemy.health < IgniteDmg + spellDamage  + 10 then    
          if myHero.ms < enemy.ms then
            CastSpell(ignite, enemy)  
            if Debug then
              ScriptMsg("+++++++!")
            end 
          else
            if Debug then
              ScriptMsg("-------!")
            end
          end
        end 
      end
      if (GetDistanceSqr(enemy) > 160000 and (myHero.health+myHero.shield) < myHero.maxHealth*0.3) then 
        if enemy.health > spellDamage-(500*aggro) and enemy.health < IgniteDmg + spellDamage-(500*aggro)  then
          CastSpell(ignite, enemy)              
          if Debug then
            ScriptMsg("ignite Q")
          end
        end
      end
    end
  end
end

function CountAlliesNearUnit(unit, range)
  local count = 0
  for i, ally in pairs(GetAllyHeroes()) do
    if GetDistanceSqr(ally, unit) <= range * range and not ally.dead then count = count + 1 end
  end
  return count
end

function isFleeingFromMe(target, range)
  local pos = VPred:GetPredictedPos(target, 0.26)
  
  if pos and GetDistanceSqr(pos) > range*range then
    return true
  end
  return false
end

function amIFleeing(target, range)
  local pos = VPred:GetPredictedPos(myHero, 0.26)
  
  if pos and GetDistanceSqr(pos, target) > range*range then
    return true
  end
  return false
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function Checks()

  Q.ready = myHero:CanUseSpell(_Q) == READY
  W.ready = myHero:CanUseSpell(_W) == READY
  E.ready = myHero:CanUseSpell(_E) == READY
  R.ready = myHero:CanUseSpell(_R) == READY
  I.ready = Ignite ~= nil and myHero:CanUseSpell(Ignite) == READY
  
  Q.level = myHero:GetSpellData(_Q).level
  W.level = myHero:GetSpellData(_W).level
  E.level = myHero:GetSpellData(_E).level
  R.level = myHero:GetSpellData(_R).level
  
  EnemyMinions:update()
  JungleMobs:update()
  
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function TargetsHumanoid()
  
  local Target = nil
  
  if ValidTarget(SelectedTarget) then
    Target = SelectedTarget
  elseif _G.MMA_IsLoaded then 
    Target = _G.MMA_Target()
  elseif _G.AutoCarry and _G.Reborn_Initialised then
    Target = _G.AutoCarry.Crosshair:GetTarget()
  elseif _G._Pewalk then 
    Target = _G._Pewalk.GetTarget()
  elseif SxOrbLoaded then
    Target = SxOrb:GetTarget()
  end

  if Target and Target.type == myHero.type and ValidTarget(Target, TrueRange(Target)) then
    QTarget = Target
    RTarget = Target
  else
    QTS:update()
    RTS:update()
    QTarget = QTS.target
    RTarget = RTS.target
  end
end

function TargetsInsane()

local Target = nil

  if ValidTarget(SelectedTarget) then

    QTarget = SelectedTarget
    RTarget = SelectedTarget 

  elseif Target and Target.type == myHero.type and ValidTarget(Target, TrueRange(Target)) then
    QTarget = Target
    RTarget = Target
  else
    QTS:update()
    RTS:update()
    QTarget = QTS.target
    RTarget = RTS.target
  end
end

function OnWndMsg(Msg, Key)
  if Msg == WM_LBUTTONDOWN then
if PopUp then
PopUp = false
end
end
  if Msg == WM_LBUTTONDOWN and Menu.Combo.focus then
    local minDis = 0
    local starget = nil
    for i, enemy in ipairs(GetEnemyHeroes()) do
      if ValidTarget(enemy) then
        if GetDistance(enemy, mousePos) <= minDis or starget == nil then
          minDis = GetDistance(enemy, mousePos)
          starget = enemy
        end
      end
    end

    if starget and minDis < starget.boundingRadius*2 then
      if SelectedTarget and starget.charName == SelectedTarget.charName then
        SelectedTarget = nil
        ScriptMsg("Target Unlocked", true)
      else
        SelectedTarget = starget
        ScriptMsg("Target Locked  - "..starget.charName.."", true)
      end
      elseif SelectedTarget ~= nil then
        SelectedTarget = nil
        ScriptMsg("Target Unlocked", true)
      end
    end
  end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function OrbwalkCanMove()

  if SACLoaded then
    return _G.AutoCarry.Orbwalker:CanMove()
  elseif PEWLoaded then
    return _Pewalk.CanMove()
  elseif MMALoaded then
    return _G.MMA_CanMove()
  end
  
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function Combo()

  if QTarget ~= nil then
  
    local ComboQ = Menu.Combo.Q
    local ComboQ2 = Menu.Combo.Q2
    
    if Q.ready and ComboQ and ComboQ2 <= ManaPercent() and ValidTarget(QTarget, Q.range+Q.radius+QTarget.boundingRadius) then
      CastQ(QTarget, "Combo")
    end
    
  end
  
  if RTarget ~= nil then
  
    local ComboR = Menu.Combo.R
    local ComboR2 = Menu.Combo.R2
  
    if R.ready and ComboR and ComboR2 <= ManaPercent() then
    
      if ValidTarget(RTarget, R.range+RTarget.boundingRadius) then
        CastR(RTarget, "Combo")
      end
      
      for i, enemy in ipairs(EnemyHeroes) do
      
        if ValidTarget(enemy, R.range+100) then
          CastR(enemy, "Combo")
        end
        
      end
      
    end
    
  end

end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function Farm()

  local FarmQ = Menu.Farm.Q
  local FarmQ2 = Menu.Farm.Q2
  local FarmR = Menu.Farm.R
  local FarmR2 = Menu.Farm.R2
  
  if Q.ready and FarmQ and FarmQ2 <= ManaPercent() then
    
    for i, minion in pairs(EnemyMinions.objects) do
    
      local QMinionDmg = GetDmg("Q", minion)
      
      if QMinionDmg >= minion.health and ValidTarget(minion, Q.range+Q.radius+100) then
        CastQ(minion)
      end
      
    end
    
    for i, minion in pairs(EnemyMinions.objects) do
    
      local AAMinionDmg = GetDmg("AA", minion)
      local QMinionDmg = GetDmg("Q", minion)
      
      if QMinionDmg+2.5*AAMinionDmg <= minion.health and ValidTarget(minion, Q.range+Q.radius+100) then
        CastQ(minion)
      end
      
    end
    
  end
  
  if R.ready and FarmR and FarmR2 <= ManaPercent() then
    
    for i, minion in pairs(EnemyMinions.objects) do
    
      local RMinionDmg = GetDmg("R", minion)
      
      if RMinionDmg >= minion.health and ValidTarget(minion, R.range+100) then
        CastR(minion)
      end
      
    end
    
    for i, minion in pairs(EnemyMinions.objects) do
    
      local AAMinionDmg = GetDmg("AA", minion)
      local RMinionDmg = GetDmg("R", minion)
      
      if RMinionDmg+2.5*AAMinionDmg <= minion.health and ValidTarget(minion, R.range+100) then
        CastR(minion)
      end
      
    end
    
  end
  
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function JFarm()

  local JFarmQ = Menu.JFarm.Q
  local JFarmQ2 = Menu.JFarm.Q2
  local JFarmR = Menu.JFarm.R
  local JFarmR2 = Menu.JFarm.R2
  
  if Q.ready and JFarmQ and JFarmQ2 <= ManaPercent() then
  
    for i, junglemob in pairs(JungleMobs.objects) do
          
      local LargeJunglemob = nil
      
      for j = 1, #FocusJungleNames do
        if junglemob.name == FocusJungleNames[j] then
          LargeJunglemob = junglemob
          break
        end
        
      end
      
      if LargeJunglemob ~= nil and GetDistance(LargeJunglemob, mousePos) <= Q.range+Q.radius and ValidTarget(LargeJunglemob, Q.range+Q.radius+100) then
        CastQ(LargeJunglemob)
        return
      end
      
    end
    
    for i, junglemob in pairs(JungleMobs.objects) do
    
      if ValidTarget(junglemob, Q.range+Q.radius+100) then
        CastQ(junglemob)
      end
      
    end
    
  end
  
  if R.ready and JFarmR and JFarmR2 <= ManaPercent() then
  
    for i, junglemob in pairs(JungleMobs.objects) do
    
      local LargeJunglemob = nil
      
      for j = 1, #FocusJungleNames do
        if junglemob.name == FocusJungleNames[j] then
          LargeJunglemob = junglemob
          break
        end
        
      end
      
      if LargeJunglemob ~= nil and GetDistance(LargeJunglemob, mousePos) <= R.range and ValidTarget(LargeJunglemob, R.range+100) then
        CastR(LargeJunglemob)
        return
      end
      
    end
    
    for i, junglemob in pairs(JungleMobs.objects) do
    
      if ValidTarget(junglemob, R.range+100) then
        CastR(junglemob)
      end
      
    end
    
  end
  
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function Harass()
  
  if QTarget ~= nil then
  
    local HarassQ = Menu.Harass.Q
    local HarassQ2 = Menu.Harass.Q2
    
    if Q.ready and HarassQ and HarassQ2 <= ManaPercent() and ValidTarget(QTarget, Q.range+Q.radius+QTarget.boundingRadius) then
      CastQ(QTarget, "Harass")
    end
    
  end

  if RTarget ~= nil then
  
    local HarassR = Menu.Harass.R
    local HarassR2 = Menu.Harass.R2
    
    if R.ready and HarassR and HarassR2 <= ManaPercent() then
      RHitChance = nil
      
      if ValidTarget(RTarget, R.range+RTarget.boundingRadius) then
        CastR(RTarget, "Harass")
      end
      
      if RHitChance ~= nil and RHitChance >= 0 and RHitChance < 1 then
      
        for i, enemy in ipairs(EnemyHeroes) do
        
          if ValidTarget(enemy, R.range+RTarget.boundingRadius) then
            CastR(enemy, "Harass")
          end
          
        end
        
      end
      
    end
    
  end
  
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function HarassAlways()

if IsRecall then
  return
else
  
  if QTarget ~= nil then
  
    local HarassQ = Menu.Harass.Q
    local HarassQ2 = Menu.Harass.Q2
    
    if Q.ready and HarassQ and HarassQ2 <= ManaPercent() and ValidTarget(QTarget, Q.range+Q.radius+QTarget.boundingRadius) then
      CastQ(QTarget, "Harass")
    end
    
  end

  if RTarget ~= nil then
  
    local HarassR = Menu.Harass.R
    local HarassR2 = Menu.Harass.R2
    
    if R.ready and HarassR and HarassR2 <= ManaPercent() then
      RHitChance = nil
      
      if ValidTarget(RTarget, R.range+RTarget.boundingRadius) then
        CastR(RTarget, "Harass")
      end
      
      if RHitChance ~= nil and RHitChance >= 0 and RHitChance < 1 then
      
        for i, enemy in ipairs(EnemyHeroes) do
        
          if ValidTarget(enemy, R.range+RTarget.boundingRadius) then
            CastR(enemy, "Harass")
          end
          
        end
        
      end
      
    end
    
  end
  
end

end
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function LastHit()

  local LastHitQ = Menu.LastHit.Q
  local LastHitQ2 = Menu.LastHit.Q2
  local LastHitR = Menu.LastHit.R
  local LastHitR2 = Menu.LastHit.R2
  
  if Q.ready and LastHitQ and LastHitQ2 <= ManaPercent() then
  
    for i, minion in pairs(EnemyMinions.objects) do
    
      local QMinionDmg = GetDmg("Q", minion)
      
      if QMinionDmg >= minion.health and ValidTarget(minion, Q.range+Q.radius+100) then
        CastQ(minion, "LastHit")
      end
      
    end
    
  end
  
  if R.ready and LastHitR and LastHitR2 <= ManaPercent() then
  
    for i, minion in pairs(EnemyMinions.objects) do
    
      local RMinionDmg = GetDmg("R", minion)
      
      if RMinionDmg >= minion.health and ValidTarget(minion, R.range+100) then
        CastR(minion, "LastHit")
      end
      
    end
    
  end
  
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function JSteal()

  local JStealQ = Menu.JSteal.Q
  local JStealR = Menu.JSteal.R
  
  if Q.ready and JStealQ then
  
    for i, junglemob in pairs(JungleMobs.objects) do
    
      local QJunglemobDmg = GetDmg("Q", junglemob)
      
      for j = 1, #FocusJungleNames do
      
        if junglemob.name == FocusJungleNames[j] and QJunglemobDmg >= junglemob.health and ValidTarget(junglemob, Q.range+Q.radius+junglemob.boundingRadius) or junglemob.charName:lower():find("dragon") and QJunglemobDmg >= junglemob.health and ValidTarget(junglemob, Q.range+junglemob.boundingRadius) then
          CastQ(junglemob, "JSteal")
        end
        
      end
      
    end
    
  end
  
  if R.ready and JStealR then
  
    for i, junglemob in pairs(JungleMobs.objects) do
    
      local RJunglemobDmg = GetDmg("R", junglemob)
      
      for j = 1, #FocusJungleNames do
      
        if junglemob.name == FocusJungleNames[j] and RJunglemobDmg >= junglemob.health and ValidTarget(junglemob, R.range+junglemob.boundingRadius) or junglemob.charName:lower():find("dragon") and RJunglemobDmg >= junglemob.health and ValidTarget(junglemob, R.range+junglemob.boundingRadius) then
          CastR(junglemob, "JSteal")
        end
        
      end
      
    end
    
  end
  
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function JstealAlways()

if Menu.Control.tmpdisable then return
end

  if Q.ready and Menu.JSteal.Q then
  
    for i, junglemob in pairs(JungleMobs.objects) do
    
      local QJunglemobDmg = GetDmg("Q", junglemob)

      for j = 1, #FocusJungleNames do
      
        if junglemob.name == FocusJungleNames[j] and  QJunglemobDmg >= junglemob.health and ValidTarget(junglemob, Q.range+Q.radius+junglemob.boundingRadius) or junglemob.charName:lower():find("dragon") and QJunglemobDmg >= junglemob.health and ValidTarget(junglemob, Q.range+junglemob.boundingRadius) then

        CastQ(junglemob, "JstealAlways")
        end
        
      end
      
    end
    
  end
  
  if R.ready and Menu.JSteal.R then
  
    for i, junglemob in pairs(JungleMobs.objects) do
    
      local RJunglemobDmg = GetDmg("R", junglemob)
      
      for j = 1, #FocusJungleNames do
      
        if junglemob.name == FocusJungleNames[j] and RJunglemobDmg >= junglemob.health and ValidTarget(junglemob, R.range+junglemob.boundingRadius) or junglemob.charName:lower():find("dragon") and RJunglemobDmg >= junglemob.health and ValidTarget(junglemob, R.range+junglemob.boundingRadius) then
          CastR(junglemob, "JstealAlways")
        end
        
      end
      
    end
    
  end
  
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function KillSteal()

  local KillStealQ = Menu.KillSteal.Q
  local KillStealR = Menu.KillSteal.R
  
  for i, enemy in ipairs(EnemyHeroes) do
  
    local QTargetDmg = GetDmg("Q", enemy)
    local RTargetDmg = GetDmg("R", enemy)
    
    
    if Q.ready and KillStealQ and QTargetDmg >= enemy.health and ValidTarget(enemy, Q.range+Q.radius+enemy.boundingRadius) then
      CastQ(enemy, "KillSteal")
    end
    
    if R.ready and KillStealR and RTargetDmg >= enemy.health and ValidTarget(enemy, R.range+enemy.boundingRadius) then
      CastR(enemy, "KillSteal")
    end
  end
end
  

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function Flee()
  MoveToMouse()
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function HealthPercent(unit)
  return (unit.health/unit.maxHealth)*100
end

function ManaPercent()
  return (myHero.mana/myHero.maxMana)*100
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function AddRange(unit)
  return unit.boundingRadius
end

function TrueRange(enemy)
  return myHero.range+AddRange(myHero)+AddRange(enemy)
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function GetDmg(spell, enemy)

  if enemy.health == 0 then
    return 0
  end
  
  local ADDmg = 0
  local APDmg = 0
  
  local Level = myHero.level
  local TotalDmg = myHero.totalDamage
  local AddDmg = myHero.addDamage
  local AP = myHero.ap
  local ArmorPen = myHero.armorPen
  local ArmorPenPercent = myHero.armorPenPercent
  local MagicPen = myHero.magicPen
  local MagicPenPercent = myHero.magicPenPercent
  
  local Armor = math.max(0, enemy.armor*ArmorPenPercent-ArmorPen)
  local ArmorPercent = Armor/(100+Armor)
  local MagicArmor = math.max(0, enemy.magicArmor*MagicPenPercent-MagicPen)
  local MagicArmorPercent = MagicArmor/(100+MagicArmor)
    
    if spell == "AA" then
    ADDmg = TotalDmg
    elseif spell == "Q" then
  
    if Q.ready then
      APDmg = 45*Q.level+25+.5*AddDmg+.5*AP
    end
    
    elseif spell == "W" then
  
    if W.ready then
      APDmg = 75*W.level+75+AP
    end
    
    elseif spell == "E" then
  
    if E.ready then
      ADDmg = 48*E.level+32+1.6*AddDmg
    end
    
    elseif spell == "R" then
  
    if R.ready then
      APDmg = 30*R.level+70+(0.3*R.level-0.1)*TotalDmg+.3*AP
    end
    
  end
  
  local TrueDmg = ADDmg*(1-ArmorPercent)+APDmg*(1-MagicArmorPercent)
  
  return TrueDmg
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function CastQ(unit, mode)
  
if unit.dead then return end  

if Menu.Prediction.Choice == 1 and VPred then
    local CastPosition, HitChance, Position = VPred:GetCircularCastPosition(unit, Q.delay, Q.radius, Q.range, Q.speed)
    
    if HitChance >= (mode == nil and 1 or Menu.Prediction.VPrediction.Q) then
      CastSpell(_Q, CastPosition.x, CastPosition.z)
    end
  
  elseif Menu.Prediction.Choice == 2 and HPred then
    local Pos, HitChance = HPred:GetPredict(HPred.Presets["Corki"]["Q"], unit, myHero)

    if HitChance >= (mode == nil and 1 or Menu.Prediction.HPrediction.Q) then
      CastSpell(_Q, Pos.x, Pos.z)
    end
  
  elseif Menu.Prediction.Choice == 3 and SPred then
    local CastPosition, HitChance, PredPos = SPred:Predict(unit, Q.range, Q.speed, Q.delay, Q.radius, false, myHero)
    if HitChance >= (mode == nil and 1 or Menu.Prediction.SPrediction.Q) then
      CastSpell(_Q, CastPosition.x, CastPosition.z)
    end
    
  elseif Menu.Prediction.Choice == 4 and FHPred then
   local CastPosition, hc, info = FHPrediction.GetPrediction("Q", unit)
    if hc > (mode == nil and 1 or Menu.Prediction.FHPrediction.Q) and CastPosition ~= nil then
      CastSpell(_Q, CastPosition.x, CastPosition.z)
    end
  
  elseif Menu.Prediction.Choice == 5 and KPred then
    local Pos, HitChance = KPred:GetPrediction(KPred.Presets["Corki"]["Q"], unit, myHero)
    if HitChance >= (mode == nil and 1 or Menu.Prediction.KPrediction.Q) then
      CastSpell(_Q, Pos.x, Pos.z)
    end

  elseif Menu.Prediction.Choice == 6 and DPred then
    local state,hitPos,perc = DPred:predict("Q",unit,myHero,SkillShot.TYPE.CIRCLE,Q.speed,Q.range,Q.radius,Q.delay*1000,math.huge)
    if perc >= (mode == nil and 50 or Menu.Prediction.DPrediction.Q) then
      CastSpell(_Q, hitPos.x, hitPos.z)
    end
    
end

end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function CastR(unit, mode)

if unit.dead then return end  

if Menu.Prediction.Choice == 1 and VPred then
    local CastPosition, HitChance, Position = VPred:GetLineCastPosition(unit, R.delay, R.width, R.range, R.speed, myHero, true)
    
    if HitChance >= (mode == nil and 1 or Menu.Prediction.VPrediction.R) then
      CastSpell(_R, CastPosition.x, CastPosition.z)
    end
  
  elseif Menu.Prediction.Choice == 2 and HPred then
    local Pos, HitChance = HPred:GetPredict(HPred.Presets["Corki"]["R"], unit, myHero)

    if HitChance >= (mode == nil and 1 or Menu.Prediction.HPrediction.R) then
      CastSpell(_R, Pos.x, Pos.z)
    end
  
  elseif Menu.Prediction.Choice == 3 and SPred then
    local CastPosition, HitChance, PredPos = SPred:Predict(unit, R.range, R.speed, R.delay, R.width, true, myHero)
    if HitChance >= (mode == nil and 1 or Menu.Prediction.SPrediction.R) then
      CastSpell(_R, CastPosition.x, CastPosition.z)
    end
    
  elseif Menu.Prediction.Choice == 4 and FHPred then
   local CastPosition, hc, info = FHPrediction.GetPrediction("R", unit)
    if hc > (mode == nil and 1 or Menu.Prediction.FHPrediction.R) and CastPosition ~= nil and not info.collision then
      CastSpell(_R, CastPosition.x, CastPosition.z)
    end
  
  elseif Menu.Prediction.Choice == 5 and KPred then
    local Pos, HitChance = KPred:GetPrediction(KPred.Presets["Corki"]["R"], unit, myHero)
    if HitChance >= (mode == nil and 1 or Menu.Prediction.KPrediction.R) then
      CastSpell(_R, Pos.x, Pos.z)
    end

  elseif Menu.Prediction.Choice == 6 and DPred then
    local state,hitPos,perc = DPred:predict("R",unit,myHero,SkillShot.TYPE.LINE,R.speed,R.range,R.width,R.delay*1000,0,{Minions = true,Champions = true})
    if perc >= (mode == nil and 50 or Menu.Prediction.DPrediction.R) then
      CastSpell(_R, hitPos.x, hitPos.z)
    end
    
end

end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function MoveToMouse()

  if mousePos and GetDistance(mousePos) <= 100 then
    MousePos = myHero+(Vector(mousePos)-myHero):normalized()*300
  else
    MousePos = mousePos
  end
  
  myHero:MoveTo(MousePos.x, MousePos.z)
  CastSpell(_W, MousePos.x, MousePos.z)
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

--[[function DebugDraw()
if myHero.dead then
  return
end

if Menu.Draw.On then

if QTarget ~= nil then
    DrawCircle(QTarget.x, QTarget.y, QTarget.z, Q.radius, ARGB(0xFF, 0xFF, 0xFF, 0xFF))
  end
  
  if RTarget ~= nil then
    DrawCircle(RTarget.x, RTarget.y, RTarget.z, R.width/2, ARGB(0xFF, 0xFF, 0xFF, 0xFF))
  end
  
  if QHitChance ~= nil then
  
    if QHitChance < 1 then
      Qcolor = ARGB(0xFF, 0xFF, 0x00, 0x00)
    elseif QHitChance == 3 then
      Qcolor = ARGB(0xFF, 0x00, 0x54, 0xFF)
    elseif QHitChance >= 2 then
      Qcolor = ARGB(0xFF, 0x1D, 0xDB, 0x16)
    elseif QHitChance >= 1 then
      Qcolor = ARGB(0xFF, 0xFF, 0xE4, 0x00)
    end
  
  end
  end
  if RHitChance ~= nil then
  
    if RHitChance == -1 then
      Rcolor = ARGB(0xFF, 0x00, 0x00, 0x00)
    elseif RHitChance < 1 then
      Rcolor = ARGB(0xFF, 0xFF, 0x00, 0x00)
    elseif RHitChance == 3 then
      Rcolor = ARGB(0xFF, 0x00, 0x54, 0xFF)
    elseif RHitChance >= 2 then
      Rcolor = ARGB(0xFF, 0x1D, 0xDB, 0x16)
    elseif RHitChance >= 1 then
      Rcolor = ARGB(0xFF, 0xFF, 0xE4, 0x00)
    end
    
  end
  
  if Menu.Draw.Prd then
    
  if QPos ~= nil then
  
    DrawCircle(QPos.x, QPos.y, QPos.z, Q.radius, Qcolor)
    DrawLine3D(myHero.x, myHero.y, myHero.z, QPos.x, QPos.y, QPos.z, 2, Qcolor)
    QPos = nil
  
  elseif RPos ~= nil then
    DrawCircle(RPos.x, RPos.y, RPos.z, R.width/2, Rcolor)
    DrawLine3D(myHero.x, myHero.y, myHero.z, RPos.x, RPos.y, RPos.z, 2, Rcolor)
    RPos = nil
  end
  end
  
    if QHitChance ~= nil then
      DrawText("Q HitChance: "..QHitChance, 20, 1250, 550, Qcolor)
      QHitChance = nil
    end
    
    if RHitChance ~= nil then
      DrawText("R HitChance: "..RHitChance, 20, 1250, 600, Rcolor)
      RHitChance = nil
    end
    
    if Menu.Draw.ownp then
    
    if myHero.hasMovePath and myHero.pathCount >= 2 then
    
      local IndexPath = myHero:GetPath(myHero.pathIndex)
      
      if IndexPath then
        DrawLine3D(myHero.x, myHero.y, myHero.z, IndexPath.x, IndexPath.y, IndexPath.z, 1, ARGB(114, 114, 4, 34))
      end
      
      for i=myHero.pathIndex, myHero.pathCount-1 do
      
        local Path = myHero:GetPath(i)
        local Path2 = myHero:GetPath(i+1)
        
        DrawLine3D(Path.x, Path.y, Path.z, Path2.x, Path2.y, Path2.z, 1, ARGB(114, 114, 4, 34))
      end
      
    end
    
    if Menu.Draw.opp then
    
    for i, enemy in ipairs(EnemyHeroes) do
    
      if enemy == nil then
        return
      end
      
      if enemy.hasMovePath and enemy.pathCount >= 2 then
      
        local IndexPath = enemy:GetPath(enemy.pathIndex)
        
        if IndexPath then
          DrawLine3D(enemy.x, enemy.y, enemy.z, IndexPath.x, IndexPath.y, IndexPath.z, 1, ARGB(255, 255, 255, 255))
        end
        
        for i=enemy.pathIndex, enemy.pathCount-1 do
        
          local Path = enemy:GetPath(i)
          local Path2 = enemy:GetPath(i+1)
          
          DrawLine3D(Path.x, Path.y, Path.z, Path2.x, Path2.y, Path2.z, 1, ARGB(255, 255, 255, 255))
          
          print(FocusJungleNames)
          print(Q.range)
          print(R.range)
        end
        
      end
      
    end
    
  end
  
end

end]]--

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function OnAnimation(unit, animation)

  if not unit.isMe then
    return
  end
  
  if animation == "recall" then
    IsRecall = true
  elseif animation == "recall_winddown" or animation == "Run" or animation == "Spell1" or animation == "Spell2" or animation == "Spell3" or animation == "Spell4" then
    IsRecall = false
  end
  
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function DrawDamage(unit)

  local SPos, EPos = GetHealthPos(unit)
  local PercentDamage = math.min(unit.health/unit.maxHealth, ComboDamage(unit)/unit.maxHealth)
  local DPos = Point(EPos.x-104*PercentDamage, SPos.y)
  
  if (ComboDamage(unit) > unit.health) then
    DrawText("OverKill: " .. math.floor(ComboDamage(unit)-unit.health), 20, SPos.x, SPos.y-55, ARGB(0xFF, 0xFF, 0xFF, 0xFF))
  end
  
  if R.ready then
   
    local RUnitDmg = GetDmg("R", unit) or 0
    local RPercentDamage = math.min(unit.health/unit.maxHealth, RUnitDmg/unit.maxHealth)
    local RPos = Point(DPos.x+104*RPercentDamage, EPos.y)
    
    DrawLine(RPos.x, RPos.y, EPos.x, EPos.y, 11, 0x78FF7D00 or 0x78FFFFFF)
    DrawLine(DPos.x, DPos.y, RPos.x, RPos.y, 11, 0x78FF7D00 or 0x78FFFFFF)
  else
    DrawLine(DPos.x, DPos.y, EPos.x, EPos.y, 11, 0x78FF7D00 or 0x78FFFFFF)
  end
  
end

function GetHealthPos(unit)

  local Pos = GetUnitHPBarPos(unit)
  local PosOffset = GetUnitHPBarOffset(unit)
  
  Pos.x = Pos.x-66
  
  if unit.charName == "Darius" then
    Pos.x = Pos.x-7
  end
  
  Pos.y = Pos.y+61*PosOffset.y+6
  
  return Point(Pos.x, Pos.y), Point(Pos.x+104*(unit.health/unit.maxHealth), Pos.y)
end

function ComboDamage(unit)

  local AA_UnitDmg = GetDmg("AA", unit) or 0
  local Q_UnitDmg = Q.ready and GetDmg("Q", unit) or 0
  local R_UnitDmg = R.ready and GetDmg("R", unit) or 0
  
  return AA_UnitDmg+Q_UnitDmg+R_UnitDmg
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function DrawRectangleButton(x, y, w, h, color)
local floor = math.floor
local points = {}
points[1] = D3DXVECTOR2(floor(x), floor(y))
points[2] = D3DXVECTOR2(floor(x + w), floor(y))
local points2 = {}
points2[1] = D3DXVECTOR2(floor(x), floor(y - h/2))
points2[2] = D3DXVECTOR2(floor(x + w), floor(y - h/2))
points2[3] = D3DXVECTOR2(floor(x + w), floor(y + h/2))
points2[4] = D3DXVECTOR2(floor(x), floor(y + h/2))
local t = GetCursorPos()
polygon = Polygon(Point(points2[1].x, points2[1].y), Point(points2[2].x, points2[2].y), Point(points2[3].x, points2[3].y), Point(points2[4].x, points2[4].y))
if polygon:contains(Point(t.x, t.y)) then
DrawLines2(points, floor(h), color)
else
DrawLines2(points, floor(h), ARGB(255, 49, 112, 131))
end
end

function OnDraw()
  if not Loaded then
    return
  end

  if Menu.Draw.CLFPS then return
    OnDrawFPS()
  end

  if not Menu.Draw.On or myHero.dead then
    return
  end
  
  if Menu.Draw.ComboDamage then
    for i, hero in ipairs(GetEnemyHeroes()) do
      if ValidTarget(hero, 2000) then
      DrawDamage(hero)
      end
    end
  end

  if PopUp then
              local w, h1, h2 = (WINDOW_W*0.50), (WINDOW_H*.15), (WINDOW_H*.9)
              DrawLine(w, h1/1.05, w, h2/1.97, w/1.75, ARGB(80, 0, 0, 0)) -- border & aero
              DrawLine(w, h1, w, h2/2, w/1.8, ARGB(255, 22, 12, 0)) -- background
              DrawTextA(tostring("Welcome to Uneeesh Series - Corki"), WINDOW_H*.028, (WINDOW_W/2), (WINDOW_H*.18), ARGB(255, 0, 222, 225),"center","center")
              DrawTextA(tostring("Latest Changelog (" .. Version .. ") ;"), WINDOW_H*.015, (WINDOW_W/2.65), (WINDOW_H*.210), ARGB(255, 0, 222, 225))
              DrawTextA(tostring(" "), WINDOW_H*.015, (WINDOW_W/2.65), (WINDOW_H*.210), ARGB(255, 255, 255, 255))
              DrawTextA(tostring(" "), WINDOW_H*.015, (WINDOW_W/2.65), (WINDOW_H*.225), ARGB(255, 255, 255, 255))
              DrawTextA(tostring("- Re-Enabled SAC:Reborn."), WINDOW_H*.015, (WINDOW_W/2.70), (WINDOW_H*.240), ARGB(255, 0, 222, 225))
              DrawTextA(tostring(""), WINDOW_H*.015, (WINDOW_W/2.70), (WINDOW_H*.260), ARGB(255, 0, 222, 225))
              DrawTextA(tostring(""), WINDOW_H*.015, (WINDOW_W/2.70), (WINDOW_H*.280), ARGB(255, 0, 222, 225))
              local w, h1, h2 = (WINDOW_W*0.49), (WINDOW_H*.70), (WINDOW_H*.75)
              DrawLine(w, h1/1.775, w, h2/1.68, w*.11, ARGB(255, 0, 0, 0))
              DrawRectangleButton(WINDOW_W*0.467, WINDOW_H/2.375, WINDOW_W*.047, WINDOW_H*.041, ARGB(255, 255, 0, 0))
              DrawTextA(tostring("OK"), WINDOW_H*.02, (WINDOW_W/2)*.98, (WINDOW_H/2.375), ARGB(255, 0, 222, 225),"center","center")
              DrawTextA(tostring("                                                                                                      IZSHA"), WINDOW_H*.015, (WINDOW_W/2.65), (WINDOW_H*.355), ARGB(255, 0, 222, 225))
  end

  if Menu.Control.OnJST and Menu.Control.tmpdisable and Q.ready or R.ready then
    local myPos = WorldToScreen(D3DXVECTOR3(myHero.x, myHero.y, myHero.z))
    DrawText("Junglesteal Toggle Disabled!", 30, myPos.x, myPos.y, ARGB(0xFF, 0xFF, 0xFF, 0xFF))
  end

  if Menu.Draw.ownp then
    
    if myHero.hasMovePath and myHero.pathCount >= 1 then
    
      local IndexPath = myHero:GetPath(myHero.pathIndex)
      
      if IndexPath then
        DrawLine3D(myHero.x, myHero.y, myHero.z, IndexPath.x, IndexPath.y, IndexPath.z, 1, ARGB(255, 152, 130, 147))
      end
      
      for i=myHero.pathIndex, myHero.pathCount-1 do
      
        local Path = myHero:GetPath(i)
        local Path2 = myHero:GetPath(i+1)
        
        DrawLine3D(Path.x, Path.y, Path.z, Path2.x, Path2.y, Path2.z, 1, ARGB(255, 152, 130, 147))
      end
      
    end
  
  if Menu.Draw.opp then
    
    for i, enemy in ipairs(EnemyHeroes) do
    
      if enemy == nil then
        return
      end
      
      if enemy.hasMovePath and enemy.pathCount >= 1 then
      
        local IndexPath = enemy:GetPath(enemy.pathIndex)
        
        if IndexPath then
          DrawLine3D(enemy.x, enemy.y, enemy.z, IndexPath.x, IndexPath.y, IndexPath.z, 1, ARGB(255, 255, 255, 255))
        end
        
        for i=enemy.pathIndex, enemy.pathCount-1 do
        
          local Path = enemy:GetPath(i)
          local Path2 = enemy:GetPath(i+1)
          
          DrawLine3D(Path.x, Path.y, Path.z, Path2.x, Path2.y, Path2.z, 1, ARGB(255, 255, 255, 255))
          
        end
        
      end
      
    end
    
  end
  
  end
  
  if Menu.Draw.Trg then
    if QTarget ~= nil then
    DrawCircle(QTarget.x, QTarget.y, QTarget.z, Q.radius/2, 0x78FF7D00 or 0x78FFFFFF)
  elseif RTarget ~= nil then
    DrawCircle(RTarget.x, RTarget.y, RTarget.z, R.width-30, 0x78FF7D00 or 0x78FFFFFF)
    end
  end
  
  --[[if Menu.Draw.Prd and Menu.Predictions.Prediction == 2 then
  if QPos ~= nil then
    DrawCircle(QPos.x, QPos.y, QPos.z, Q.radius, ARGB(0xFF, 0x1D, 0xDB, 0x16))
    DrawLine3D(myHero.x, myHero.y, myHero.z, QPos.x, QPos.y, QPos.z, 2, ARGB(0xFF, 0x1D, 0xDB, 0x16))
    QPos = nil
  elseif RPos ~= nil then
    DrawCircle(RPos.x, RPos.y, RPos.z, R.width/2, 0xFF, 0x1D, 0xDB, 0x16)
    DrawLine3D(myHero.x, myHero.y, myHero.z, RPos.x, RPos.y, RPos.z, 2, ARGB(0xFF, 0x1D, 0xDB, 0x16))
    RPos = nil
  end
end]]--

  if Menu.Draw.AA then
    DrawCircle(myHero.x, myHero.y, myHero.z, myHero.range+myHero.boundingRadius, RGB(Menu.Draw.CLA[2], Menu.Draw.CLA[3], Menu.Draw.CLA[4]))
  end
  
  if Menu.Draw.Q and Q.ready then
    DrawCircle(myHero.x, myHero.y, myHero.z, Q.range, RGB(Menu.Draw.CLQ[2], Menu.Draw.CLQ[3], Menu.Draw.CLQ[4]))
  end
    
  if Menu.Draw.R and R.ready then
    DrawCircle(myHero.x, myHero.y, myHero.z, R.range-60, RGB(Menu.Draw.CLR[2], Menu.Draw.CLR[3], Menu.Draw.CLR[4]))
  end
  
  if Menu.Draw.I and I.ready then
    DrawCircle(myHero.x, myHero.y, myHero.z, I.range, RGB(Menu.Draw.CLI[2], Menu.Draw.CLI[3], Menu.Draw.CLI[4]))
  end
end

---------------------------------------------------------------------------------

function OnDrawFPS()
  if not Loaded then
    return
  end

  if not Menu.Draw.On or myHero.dead then
    return
  end
  
  if Menu.Draw.ComboDamage then
    for i, hero in ipairs(GetEnemyHeroes()) do
      if ValidTarget(hero, 2000) then
      DrawDamage(hero)
      end
    end
  end

  if Menu.Draw.ownp then
    
    if myHero.hasMovePath and myHero.pathCount >= 2 then
    
      local IndexPath = myHero:GetPath(myHero.pathIndex)
      
      if IndexPath then
        DrawLine3D(myHero.x, myHero.y, myHero.z, IndexPath.x, IndexPath.y, IndexPath.z, 1, ARGB(255, 152, 130, 147))
      end
      
      for i=myHero.pathIndex, myHero.pathCount-1 do
      
        local Path = myHero:GetPath(i)
        local Path2 = myHero:GetPath(i+1)
        
        DrawLine3D(Path.x, Path.y, Path.z, Path2.x, Path2.y, Path2.z, 1, ARGB(255, 152, 130, 147))
      end
      
    end

    if PopUp then
              local w, h1, h2 = (WINDOW_W*0.50), (WINDOW_H*.15), (WINDOW_H*.9)
              DrawLine(w, h1/1.05, w, h2/1.97, w/1.75, ARGB(80, 0, 0, 0)) -- border & aero
              DrawLine(w, h1, w, h2/2, w/1.8, ARGB(255, 22, 12, 0)) -- background
              DrawTextA(tostring("Welcome to Uneeesh Series - Corki"), WINDOW_H*.028, (WINDOW_W/2), (WINDOW_H*.18), ARGB(255, 0, 222, 225),"center","center")
              DrawTextA(tostring("Latest Changelog (" .. Version .. ") ;"), WINDOW_H*.015, (WINDOW_W/2.65), (WINDOW_H*.210), ARGB(255, 0, 222, 225))
              DrawTextA(tostring(" "), WINDOW_H*.015, (WINDOW_W/2.65), (WINDOW_H*.210), ARGB(255, 255, 255, 255))
              DrawTextA(tostring(" "), WINDOW_H*.015, (WINDOW_W/2.65), (WINDOW_H*.225), ARGB(255, 255, 255, 255))
              DrawTextA(tostring("- Re-Enabled SAC:Reborn."), WINDOW_H*.015, (WINDOW_W/2.70), (WINDOW_H*.240), ARGB(255, 0, 222, 225))
              DrawTextA(tostring(""), WINDOW_H*.015, (WINDOW_W/2.70), (WINDOW_H*.260), ARGB(255, 0, 222, 225))
              DrawTextA(tostring(""), WINDOW_H*.015, (WINDOW_W/2.70), (WINDOW_H*.280), ARGB(255, 0, 222, 225))
              local w, h1, h2 = (WINDOW_W*0.49), (WINDOW_H*.70), (WINDOW_H*.75)
              DrawLine(w, h1/1.775, w, h2/1.68, w*.11, ARGB(255, 0, 0, 0))
              DrawRectangleButton(WINDOW_W*0.467, WINDOW_H/2.375, WINDOW_W*.047, WINDOW_H*.041, ARGB(255, 255, 0, 0))
              DrawTextA(tostring("OK"), WINDOW_H*.02, (WINDOW_W/2)*.98, (WINDOW_H/2.375), ARGB(255, 0, 222, 225),"center","center")
              DrawTextA(tostring("                                                                                                      IZSHA"), WINDOW_H*.015, (WINDOW_W/2.65), (WINDOW_H*.355), ARGB(255, 0, 222, 225))
  end

  if Menu.Control.OnJST and Menu.Control.tmpdisable and Q.ready or R.ready then
    local myPos = WorldToScreen(D3DXVECTOR3(myHero.x, myHero.y, myHero.z))
    DrawText("Junglesteal Toggle Disabled!", 30, myPos.x, myPos.y, ARGB(0xFF, 0xFF, 0xFF, 0xFF))
  end
  
  if Menu.Draw.opp then
    
    for i, enemy in ipairs(EnemyHeroes) do
    
      if enemy == nil then
        return
      end
      
      if enemy.hasMovePath and enemy.pathCount >= 2 then
      
        local IndexPath = enemy:GetPath(enemy.pathIndex)
        
        if IndexPath then
          DrawLine3D(enemy.x, enemy.y, enemy.z, IndexPath.x, IndexPath.y, IndexPath.z, 1, ARGB(255, 255, 255, 255))
        end
        
        for i=enemy.pathIndex, enemy.pathCount-1 do
        
          local Path = enemy:GetPath(i)
          local Path2 = enemy:GetPath(i+1)
          
          DrawLine3D(Path.x, Path.y, Path.z, Path2.x, Path2.y, Path2.z, 1, ARGB(255, 255, 255, 255))
          
        end
        
      end
      
    end
    
  end
  
  end
  
  if Menu.Draw.Trg then
    if QTarget ~= nil then
    CircleDraw(QTarget.x, QTarget.y, QTarget.z, Q.radius/2, 0x78FF7D00 or 0x78FFFFFF)
  elseif RTarget ~= nil then
    CircleDraw(RTarget.x, RTarget.y, RTarget.z, R.width-30, 0x78FF7D00 or 0x78FFFFFF)
    end
  end
  
  --[[if Menu.Draw.Prd and Menu.Predictions.Prediction == 2 then
  if QPos ~= nil then
    CircleDraw(QPos.x, QPos.y, QPos.z, Q.radius, ARGB(0xFF, 0x1D, 0xDB, 0x16))
    DrawLine3D(myHero.x, myHero.y, myHero.z, QPos.x, QPos.y, QPos.z, 2, ARGB(0xFF, 0x1D, 0xDB, 0x16))
    QPos = nil
  elseif RPos ~= nil then
    CircleDraw(RPos.x, RPos.y, RPos.z, R.width/2, 0xFF, 0x1D, 0xDB, 0x16)
    DrawLine3D(myHero.x, myHero.y, myHero.z, RPos.x, RPos.y, RPos.z, 2, ARGB(0xFF, 0x1D, 0xDB, 0x16))
    RPos = nil
  end
end]]--
  
  if Menu.Draw.AA then
      CircleDraw(myHero.x, myHero.y, myHero.z, myHero.range+60+myHero.boundingRadius, ARGB(Menu.Draw.CLA[1], Menu.Draw.CLA[2],Menu.Draw.CLA[3],Menu.Draw.CLA[4]))
    end
  
  if Menu.Draw.CLFPS and Menu.Draw.Q and Q.ready then
      CircleDraw(myHero.x, myHero.y, myHero.z, Q.range+70, ARGB(Menu.Draw.CLQ[1], Menu.Draw.CLQ[2],Menu.Draw.CLQ[3],Menu.Draw.CLQ[4]))
    end
  
  if Menu.Draw.CLFPS and Menu.Draw.R and R.ready then
      CircleDraw(myHero.x, myHero.y, myHero.z, R.range+40, ARGB(Menu.Draw.CLR[1], Menu.Draw.CLR[2],Menu.Draw.CLR[3],Menu.Draw.CLR[4]))
    end
  
  if Menu.Draw.I and I.ready then
    CircleDraw(myHero.x, myHero.y, myHero.z, I.range, ARGB(Menu.Draw.CLI[1], Menu.Draw.CLI[2],Menu.Draw.CLI[3],Menu.Draw.CLI[4]))
   end
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
    radius = radius or 300
    quality = math.max(8,math.floor(180/math.deg((math.asin((chordlength/(2*radius)))))))
    quality = 2 * math.pi / quality
    radius = radius*.92
    local points = {}
    for theta = 0, 2 * math.pi + quality, quality do
        local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
        points[#points + 1] = D3DXVECTOR2(c.x, c.y)
    end
    DrawLines2(points, width or 1, color or 4294967295)
end

function DrawCircle2(x, y, z, radius, color)
    local vPos1 = Vector(x, y, z)
    local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
    local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
    local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
    if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y })  then
    DrawCircleNextLvl(x, y, z, radius, 1, color, Menu.Draw.Quality)
    end
end

function CircleDraw(x,y,z,radius, color)
  DrawCircle2(x, y, z, radius, color)
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
  
function SkinLoad()
    Menu.Autom.ChgSki:addParam("upski", "Change Skin", SCRIPT_PARAM_ONOFF, false);
    Menu.Autom.ChgSki:setCallback("upski", function(nV)
        if (nV) then
            SetSkin(myHero, Menu.Autom.ChgSki.skinID)
        else
            SetSkin(myHero, -1)
        end
    end)
    Menu.Autom.ChgSki:addParam('skinID', 'Skin', SCRIPT_PARAM_LIST, 1, {"Ufo", "Ice Toboggan", "Red Baron", "Hot Rod", "Urfrider", "Dragonwing", "Fnatic", "Classic"})
    Menu.Autom.ChgSki:setCallback('skinID', function(nV)
        if (Menu.Autom.ChgSki.upski) then
            SetSkin(myHero, nV)
        end
    end)
    
    if (Menu.Autom.ChgSki.upski) then
        SetSkin(myHero, Menu.Autom.ChgSki.skinID)
    end
end

function AutoBuy()
  
  if GetGameTimer() < 60 then
    if Menu.Autom.buyme.buydoran then
      BuyItem(1055)
    end
    if Menu.Autom.buyme.buypot then
      BuyItem(2003)
    end
    if Menu.Autom.buyme.taketrinket then
      BuyItem(3340)
    end
  end
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function CheckLevelChange()
    if LastLevelCheck + 250 < GetTickCount() and myHero.level < 19 then
        if GetGame().map.index == 8 and myHero.level < 4 and Menu.Autom.autolevel.UseAutoLevelFirst then
            LevelSpell(_Q)
            LevelSpell(_W)
            LevelSpell(_E)
        end

        LastLevelCheck = GetTickCount()
        if myHero.level ~= LastHeroLevel then
            DelayAction(function() LevelUpSpell() end, 0.25)
            LastHeroLevel = myHero.level
        end
    end
end

function LevelUpSpell()
    if Menu.Autom.autolevel.UseAutoLevelFirst and myHero.level < 4 then
        LevelSpell(AutoLevelSpellTable[AutoLevelSpellTable["SpellOrder"][Menu.Autom.autolevel.First3Level]][myHero.level])
    end

    if Menu.Autom.autolevel.UseAutoLevelRest and myHero.level > 3 then
        LevelSpell(AutoLevelSpellTable[AutoLevelSpellTable["SpellOrder"][Menu.Autom.autolevel.RestLevel]][myHero.level])
    end
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function OnBush()

local WardSlot = nil
  if GetInventorySlotItem(2045) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(2045)) == READY then
    WardSlot = GetInventorySlotItem(2045)
  elseif GetInventorySlotItem(2049) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(2049)) == READY then
    WardSlot = GetInventorySlotItem(2049)
  elseif GetInventorySlotItem(3340) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(3340)) == READY or 
  GetInventorySlotItem(3350) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(3350)) == READY or 
  GetInventorySlotItem(3361) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(3361)) == READY or 
  GetInventorySlotItem(3363) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(3363)) == READY or
  GetInventorySlotItem(3411) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(3411)) == READY or
  GetInventorySlotItem(3342) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(3342)) == READY or
  GetInventorySlotItem(3362) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(3362)) == READY  then
    WardSlot = 12
  elseif GetInventorySlotItem(2044) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(2044)) == READY then
    WardSlot = GetInventorySlotItem(2044)
  elseif GetInventorySlotItem(2043) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(2043)) == READY then
    WardSlot = GetInventorySlotItem(2043)
  end

  return WardSlot
end

function FindBush(x0, y0, z0, maxRadius, precision)

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

function Bushfind()
  if lastTime +15 > os.clock() then return end
  for _,c in pairs(GetEnemyHeroes()) do   
    if not c.dead and not c.visible then
      local time=lasttime[ c.networkID ]  --last seen time
      local pos=lastpos [ c.networkID ]   --last seen pos
      local clock=os.clock()
      
      if time and pos and clock-time < 5 and GetDistanceSqr(pos)< 1005000 then
        local FoundBush = FindBush(pos.x,pos.y,pos.z,100)
    
        if FoundBush and GetDistanceSqr(FoundBush)<600*600 then
          local WardSlot = OnBush()
          
          if WardSlot then
            CastSpell(WardSlot,FoundBush.x,FoundBush.z)
            lastTime = os.clock()
            return
          end
        end
      end
    end
  end
end
end

---------------------------------------------------------------------------------==============================================================================================================================
---------------------------------------------------------------------------------==============================================================================================================================
---------------------------------------------------------------------------------==============================================================================================================================

if myHero.charName == Hero[3] then

function ScriptMsg(msg)
  print("<font color=\"#FF1493\">[Uneeesh Series - Ezreal]</b></font>  <font color=\"#FFFF00\">".. msg .."</font>")
end

function ErrorMsg(msg)
  print("<font color=\"#FF1493\">[Uneeesh Series - Ezreal]</b></font>  <font color=\"#FF0000\">".. msg .."</font>")
end

local Q, W, E, R, I = {}, {}, {}, {}, {}
local Loaded = false
local DPExist = FileExist(LIB_PATH.."DivinePred.lua") and FileExist(LIB_PATH.."DivinePred.luac")
local lasttime = {}
local lastTime = 0
local LastLevelCheck = 0
local lastpos = {}
local lastRemove = 0
local function Slot(name)
  if myHero:GetSpellData(SUMMONER_1).name:lower():find(name) then
    return SUMMONER_1
  elseif myHero:GetSpellData(SUMMONER_2).name:lower():find(name) then
    return SUMMONER_2
  end
end
local function dChat()
  chat1B = _G.print
  chat2B = _G.PrintChat
  _G.print = function() end
  _G.PrintChat = function() end
  DisableOverlay()
  ChatOff = true
end
local function eChat()
  _G.print = chat1B
  _G.PrintChat = chat2B
  EnableOverlay()
  ChatOff = false
end

if FileExist(LIB_PATH .. "VPrediction.lua") then
  require("VPrediction")
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function OnLoad()
  
  ItemNames       = {
    [3303]        = "ArchAngelsDummySpell",
    [3007]        = "ArchAngelsDummySpell",
    [3144]        = "BilgewaterCutlass",
    [3188]        = "ItemBlackfireTorch",
    [3153]        = "ItemSwordOfFeastAndFamine",
    [3405]        = "TrinketSweeperLvl1",
    [3411]        = "TrinketOrbLvl1",
    [3166]        = "TrinketTotemLvl1",
    [3450]        = "OdinTrinketRevive",
    [2054]        = "ItemKingPoroSnack",
    [2138]        = "ElixirOfIron",
    [2137]        = "ElixirOfRuin",
    [2139]        = "ElixirOfSorcery",
    [2140]        = "ElixirOfWrath",
    [3184]        = "OdinEntropicClaymore",
    [2050]        = "ItemMiniWard",
    [3401]        = "HealthBomb",
    [3363]        = "TrinketOrbLvl3",
    [3092]        = "ItemGlacialSpikeCast",
    [3460]        = "AscWarp",
    [3361]        = "TrinketTotemLvl3",
    [3362]        = "TrinketTotemLvl4",
    [3159]        = "HextechSweeper",
    [2051]        = "ItemHorn",
    [3146]        = "HextechGunblade",
    [3187]        = "HextechSweeper",
    [3190]        = "IronStylus",
    [3139]        = "ItemMercurial",
    [3222]        = "ItemMorellosBane",
    [3042]        = "Muramana",
    [3043]        = "Muramana",
    [3180]        = "OdynsVeil",
    [3056]        = "ItemFaithShaker",
    [2047]        = "OracleExtractSight",
    [3364]        = "TrinketSweeperLvl3",
    [2052]        = "ItemPoroSnack",
    [3140]        = "QuicksilverSash",
    [3143]        = "RanduinsOmen",
    [3074]        = "ItemTiamatCleave",
    [5000]        = "ItemTitanicHydraCleave",
    [3800]        = "ItemRighteousGlory",
    [2045]        = "ItemGhostWard",
    [3342]        = "TrinketOrbLvl1",
    [3040]        = "ItemSeraphsEmbrace",
    [3048]        = "ItemSeraphsEmbrace",
    [2049]        = "ItemGhostWard",
    [3345]        = "OdinTrinketRevive",
    [2044]        = "SightWard",
    [3341]        = "TrinketSweeperLvl1",
    [3069]        = "shurelyascrest",
    [3599]        = "KalistaPSpellCast",
    [3185]        = "HextechSweeper",
    [3077]        = "ItemTiamatCleave",
    [2009]        = "ItemMiniRegenPotion",
    [2010]        = "ItemMiniRegenPotion",
    [3023]        = "ItemWraithCollar",
    [3290]        = "ItemWraithCollar",
    [2043]        = "VisionWard",
    [3340]        = "TrinketTotemLvl1",
    [3090]        = "ZhonyasHourglass",
    [3154]        = "wrigglelantern",
    [3142]        = "YoumusBlade",
    [3157]        = "ZhonyasHourglass",
    [3512]        = "ItemVoidGate",
    [3131]        = "ItemSoTD",
    [3137]        = "ItemDervishBlade",
    [3352]        = "RelicSpotter",
    [3350]        = "TrinketTotemLvl2",
    [3085]        = "AtmasImpalerDummySpell",
  }

  Items = {
    ["ELIXIR"]      = { id = 2140, range = 2140, target = false},
    ["QSS"]         = { id = 3140, range = 2500, target = false},
    ["MercScim"]  = { id = 3139, range = 2500, target = false},
    ["BRK"]     = { id = 3153, range = 550, target = true},
    ["BWC"]     = { id = 3144, range = 550, target = true},
    ["HXG"]     = { id = 3146, range = 700, target = false},
    ["ODYNVEIL"]  = { id = 3180, range = 525, target = false},
    ["DVN"]     = { id = 3131, range = 200, target = false},
    ["ENT"]     = { id = 3184, range = 350, target = false},
    ["HYDRA"]   = { id = 3074, range = 350, target = false},
    ["TIAMAT"]    = { id = 3077, range = 350, target = false},
    ["TITANIC"]   = { id = 5000, range = 350, target = false},
    ["RanduinsOmen"]  = { id = 3143, range = 500, target = false},
    ["YGB"]     = { id = 3142, range = 600, target = false},
    ["HEX"]     = { id = 5555, range = 600, target = false},
  }

  AutoLevelSpellTable = {
        ['SpellOrder']  = {'QWE', 'QEW', 'WQE', 'WEQ', 'EQW', 'EWQ'},
        ['QWE'] = {_Q,_W,_E,_Q,_Q,_R,_Q,_W,_Q,_W,_R,_W,_W,_E,_E,_R,_E,_E},
        ['QEW'] = {_Q,_E,_W,_Q,_Q,_R,_Q,_E,_Q,_E,_R,_E,_E,_W,_W,_R,_W,_W},
        ['WQE'] = {_W,_Q,_E,_W,_W,_R,_W,_Q,_W,_Q,_R,_Q,_Q,_E,_E,_R,_E,_E},
        ['WEQ'] = {_W,_E,_Q,_W,_W,_R,_W,_E,_W,_E,_R,_E,_E,_Q,_Q,_R,_Q,_Q},
        ['EQW'] = {_E,_Q,_W,_E,_E,_R,_E,_Q,_E,_Q,_R,_Q,_Q,_W,_W,_R,_W,_W},
        ['EWQ'] = {_E,_W,_Q,_E,_E,_R,_E,_W,_E,_W,_R,_W,_W,_Q,_Q,_R,_Q,_Q}
    }

  ___GetInventorySlotItem = rawget(_G, "GetInventorySlotItem")
  _G.GetInventorySlotItem = GetSlotItem
  if myHero:GetSpellData(4).name:lower():find("exhaust") then
    exhaust = { slot = 4, key = "D", range =  650, ready = false }
  elseif myHero:GetSpellData(5).name:lower():find("exhaust") then
    exhaust = { slot = 5, key = "F", range =  650, ready = false }
  end
  SummonerSlot = Slot("summonerboost")
  ignite = Slot("summonerdot")
  heal = HealSlot()
  Update()
  Variables()
  EzrealMenu()
  SkinLoad()
  DelayAction(function()LoadOrbwalk() end, 1)
  DelayAction(function()AutoBuy()end, 3)
  Loaded = true
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function Variables()

  SACLoaded, PEWLoaded, MMALoaded, SxOrbLoaded = false, false, false, false
  
  Q = {range = 1200, radius = 65, speed = 2000, delay = 0.25}
  W = {range = 900, radius = 90, speed = 1200, delay = 0.25}
  E = {range = 450}
  R = {range = 3000, width = 180, speed = 2000, delay = 1}
  I = {range = 600}
  
  QTargetRange = Q.range+100
  WTargetRange = W.range+100
  RTargetRange = R.range+100
  
  QMinionRange = Q.range+100
  QJunglemobRange = Q.range+100
  
  S5SR = false
  TT = false
  
  if GetGame().map.index == 15 then
    S5SR = true
  elseif GetGame().map.index == 4 then
    TT = true
  end
  
  if S5SR then
    FocusJungleNames =
    {
    "SRU_Baron12.1.1",
    "SRU_RiftHerald17.1.1",
    "SRU_Blue1.1.1",
    "SRU_Blue7.1.1",
    "Sru_Crab15.1.1",
    "Sru_Crab16.1.1",
    "SRU_Dragon_Air",
    "SRU_Dragon_Fire",
    "SRU_Dragon_Water",
    "SRU_Dragon_Earth",
    "SRU_Dragon_Elder",
    "SRU_Gromp13.1.1",
    "SRU_Gromp14.1.1",
    "SRU_Krug5.1.2",
    "SRU_Krug11.1.2",
    "SRU_Murkwolf2.1.1",
    "SRU_Murkwolf8.1.1",
    "SRU_Razorbeak3.1.1",
    "SRU_Razorbeak9.1.1",
    "SRU_Red4.1.1",
    "SRU_Red10.1.1"
    }
  JungleMobNames =
    {
    "SRU_BlueMini1.1.2",
    "SRU_BlueMini7.1.2",
    "SRU_BlueMini21.1.3",
    "SRU_BlueMini27.1.3",
    "SRU_KrugMini5.1.1",
    "SRU_KrugMini11.1.1",
    "SRU_MurkwolfMini2.1.2",
    "SRU_MurkwolfMini2.1.3",
    "SRU_MurkwolfMini8.1.2",
    "SRU_MurkwolfMini8.1.3",
    "SRU_RazorbeakMini3.1.2",
    "SRU_RazorbeakMini3.1.3",
    "SRU_RazorbeakMini3.1.4",
    "SRU_RazorbeakMini9.1.2",
    "SRU_RazorbeakMini9.1.3",
    "SRU_RazorbeakMini9.1.4",
    "SRU_RedMini4.1.2",
    "SRU_RedMini4.1.3",
    "SRU_RedMini10.1.2",
    "SRU_RedMini10.1.3"
    }
  elseif TT then
    FocusJungleNames =
    {
    "TT_NWraith1.1.1",
    "TT_NGolem2.1.1",
    "TT_NWolf3.1.1",
    "TT_NWraith4.1.1",
    "TT_NGolem5.1.1",
    "TT_NWolf6.1.1",
    "TT_Spiderboss8.1.1"
    }   
    JungleMobNames =
    {
    "TT_NWraith21.1.2",
    "TT_NWraith21.1.3",
    "TT_NGolem22.1.2",
    "TT_NWolf23.1.2",
    "TT_NWolf23.1.3",
    "TT_NWraith24.1.2",
    "TT_NWraith24.1.3",
    "TT_NGolem25.1.1",
    "TT_NWolf26.1.2",
    "TT_NWolf26.1.3"
    }
  else
    FocusJungleNames =
    {
    }   
    JungleMobNames =
    {
    }
  end
  
  QTS = TargetSelector(TARGET_LESS_CAST, QTargetRange, DAMAGE_PHYSICAL, false)
  WTS = TargetSelector(TARGET_LESS_CAST, WTargetRange, DAMAGE_MAGIC, false)
  RTS = TargetSelector(TARGET_LESS_CAST, RTargetRange, DAMAGE_MAGIC, false)
  TES = TargetSelector(TARGET_PRIORITY, 600, DAMAGE_MAGIC)
  
  EnemyHeroes = GetEnemyHeroes()
  EnemyMinions = minionManager(MINION_ENEMY, QMinionRange, myHero, MINION_SORT_MAXHEALTH_DEC)
  JungleMobs = minionManager(MINION_JUNGLE, QJunglemobRange, myHero, MINION_SORT_MAXHEALTH_DEC)
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function EzrealMenu()

    Menu = scriptConfig("Uneeesh Ezreal", "UC_MAIN")
    
    Menu:addSubMenu("[Ezreal]: Control Settings", "Control")
    Menu.Control:addParam("OnC", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
    Menu.Control:addParam("OnF", "Laneclear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('V'))
    Menu.Control:addParam("OnJF", "Jungleclear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('V'))
    Menu.Control:addParam("OnP", "Poke Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('C'))
    Menu.Control:addParam("OnL", "Lasthit Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('X'))
    Menu.Control:addParam("OnJS", "Junglesteal Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('X'))
    Menu.Control:addParam("OnE", "Flee Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('L'))
    Menu.Control:addParam("OnLT", "Lasthit(Q) Toggle", SCRIPT_PARAM_ONKEYTOGGLE, true, GetKey('N'))
    Menu.Control:addParam("OnPT", "Poke Toggle", SCRIPT_PARAM_ONKEYTOGGLE, true, GetKey('N'))
    Menu.Control:addParam("OnJST", "Junglesteal(Q) Toggle", SCRIPT_PARAM_ONKEYTOGGLE, true, GetKey('J'))
    Menu.Control:addParam("tmpdisable", "Stop Junglesteal Toggle", SCRIPT_PARAM_ONKEYDOWN, false, 17)
    Menu.Control:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Control:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
   
    Menu:addSubMenu("[Ezreal]: Combo Settings", "Combo")
    Menu.Combo:addParam("Mode", "Casting Mode", SCRIPT_PARAM_LIST, 1, {"Insane", "Humanoid"})
    Menu.Combo:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addParam("Q2", "Use if Mana Percent > % >", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
    Menu.Combo:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addParam("W2", "Use if Mana Percent > % >", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
    Menu.Combo:addParam("R", "Use R", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addParam("saveR", "Save R For Finisher", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addParam("R2", "Use if Mana Percent > % >", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
    Menu.Combo:addParam("focus", "Left Click Focus Target", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addParam("vision", "Auto vision on Bush", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    
    Menu:addSubMenu("[Ezreal]: Laneclear Settings", "Farm")
    Menu.Farm:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
    Menu.Farm:addParam("Q2", "Use if Mana Percent > % >", SCRIPT_PARAM_SLICE, 70, 0, 100, 0)
    Menu.Farm:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Farm:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
        
    Menu:addSubMenu("[Ezreal]: Jungleclear Settings", "JFarm")
    Menu.JFarm:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
    Menu.JFarm:addParam("Q2", "Use if Mana Percent > % >", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
    Menu.JFarm:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.JFarm:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")

    Menu:addSubMenu("[Ezreal]: Poke Settings", "Harass")
    Menu.Harass:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
    Menu.Harass:addParam("Q2", "Use if Mana Percent > % >", SCRIPT_PARAM_SLICE, 70, 0, 100, 0)
    Menu.Harass:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, false)
    Menu.Harass:addParam("W2", "Use if Mana Percent > % >", SCRIPT_PARAM_SLICE, 70, 0, 100, 0)
    Menu.Harass:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Harass:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    
    Menu:addSubMenu("[Ezreal]: LastHit Settings", "LastHit")
    Menu.LastHit:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, false)
    Menu.LastHit:addParam("disable", "Disable LastHitQ Toggle while Combo", SCRIPT_PARAM_ONOFF, true)
    Menu.LastHit:addParam("Q2", "Use if Mana Percent > % >", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
    Menu.LastHit:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.LastHit:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    
    Menu:addSubMenu("[Ezreal]: Junglesteal Settings", "JSteal")
    Menu.JSteal:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
    Menu.JSteal:addParam("R", "Use R", SCRIPT_PARAM_ONOFF, true)
    Menu.JSteal:addParam("range", "Max. R Range to Junglesteal", SCRIPT_PARAM_SLICE, 3000, 600, 5000, 0)
    Menu.JSteal:addParam("blank", "   ----------------------------------------------------   ", SCRIPT_PARAM_INFO, "------------- ")
    Menu.JSteal:addParam("blank", "  R is working only if you press Junglesteal", SCRIPT_PARAM_INFO, " ")
    Menu.JSteal:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.JSteal:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    
    Menu:addSubMenu("[Ezreal]: Killsteal Settings", "KillSteal")
    Menu.KillSteal:addParam("On", "Enable Killsteal", SCRIPT_PARAM_ONOFF, true)
    Menu.KillSteal:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
    Menu.KillSteal:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
    Menu.KillSteal:addParam("R", "Use R", SCRIPT_PARAM_ONOFF, true)
    Menu.KillSteal:addParam("minrange", "Block R if enemy in AA", SCRIPT_PARAM_SLICE, 1, 0, 5, 0)
    Menu.KillSteal:addParam("range", "Max. R range to Killsteal", SCRIPT_PARAM_SLICE, 2000, 600, 4000, 0)
    Menu.KillSteal:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.KillSteal:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    
    Menu:addSubMenu("[Ezreal]: Display Settings", "Draw")
    Menu.Draw:addParam("On", "Enable Draws", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("AA", "Draw AA range", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("CLA", "Color AA range", SCRIPT_PARAM_COLOR, {144, 144, 40, 164})
    Menu.Draw:addParam("Q", "Draw Q range", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("CLQ", "Color Q range", SCRIPT_PARAM_COLOR, {141, 23, 123, 22})
    Menu.Draw:addParam("W", "Draw W range", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("CLW", "Color W range", SCRIPT_PARAM_COLOR, {141, 32, 52, 31})
    Menu.Draw:addParam("E", "Draw E range", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("CLE", "Color E range", SCRIPT_PARAM_COLOR, {141, 31, 69, 123})
    if ignite then
    Menu.Draw:addParam("I", "Draw Ignite range", SCRIPT_PARAM_ONOFF, false)
    Menu.Draw:addParam("CLI", "Color Ignite range", SCRIPT_PARAM_COLOR, {141, 124, 114, 114})
    end
    Menu.Draw:addParam("CLFPS", "Enable FPS Friendly Draws", SCRIPT_PARAM_ONOFF, false)
    Menu.Draw:addParam("Quality", "FPS Draws Quality(High=Better FPS)", SCRIPT_PARAM_SLICE, 176, 75, 2000, 0)
    Menu.Draw:addParam("Trg", "Draw Current Target", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("ownp", "Enable Pathway Draw", SCRIPT_PARAM_ONOFF, false)
    Menu.Draw:addParam("opp", "Draw Enemy Pathway", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("ComboDamage", "Draw Predicted Damage", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("Info","", SCRIPT_PARAM_INFO, "")
    Menu.Draw:addParam("stream", "Enable Streaming Mode", SCRIPT_PARAM_ONKEYTOGGLE, false, 118)
    Menu.Draw:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Draw:addParam("Info1", "Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    
    Menu:addSubMenu("[Ezreal]: Item&Summoner Settings", "Items")
    Menu.Items:addSubMenu("BotRK", "BotRK")
    Menu.Items.BotRK:addParam("bork", "Use BotRK", SCRIPT_PARAM_ONOFF, true)
    Menu.Items.BotRK:addParam('maxownhealth', 'Max. own % Health to use', SCRIPT_PARAM_SLICE, 50, 1, 100, 0)
    Menu.Items.BotRK:addParam('minenemyhealth', 'Min. enemy % Health to use', SCRIPT_PARAM_SLICE, 20, 1, 100, 0)
    Menu.Items:addSubMenu("Bilgewater", "Bilgewater")
    Menu.Items.Bilgewater:addParam("bilg", "Use Bilgewater", SCRIPT_PARAM_ONOFF, true)
    Menu.Items.Bilgewater:addParam("maxownhealth", "Max. own % Health to use", SCRIPT_PARAM_SLICE, 50, 1, 100, 0)
    Menu.Items.Bilgewater:addParam("minenemyhealth", "Min. enemy % Health to use", SCRIPT_PARAM_SLICE, 20, 1, 100, 0)
    --Menu.Items:addSubMenu("Youmuu", "Youmuu")
    --Menu.Items.Youmuu:addParam("yomu", "Use Youmuu", SCRIPT_PARAM_ONOFF, true)

    Menu.Items:addSubMenu("Health Potions", "potion")
    Menu.Items.potion:addParam("Key", "Use Only Press to", SCRIPT_PARAM_ONKEYDOWN, false, 32)
    Menu.Items.potion:addParam("Always", "Use Always", SCRIPT_PARAM_ONOFF, false)
    Menu.Items.potion:addParam("enemy", "Use if not enemies", SCRIPT_PARAM_ONOFF, false)
    Menu.Items.potion:addParam("health", "If My Health % is <", SCRIPT_PARAM_SLICE, 60, 0, 100, 0) 
    Menu.Items:addSubMenu("Remove CC", "cc")
    Menu.Items.cc:addParam("Key", "Use Only Press to", SCRIPT_PARAM_ONKEYDOWN, false, 32)
    Menu.Items.cc:addParam("Always", "Use Always", SCRIPT_PARAM_ONOFF, true)  
    if SummonerSlot then
    Menu.Items.cc:addParam("Summoner", "Use Cleanse", SCRIPT_PARAM_ONOFF, true) 
    end
    Menu.Items.cc:addParam("delay", "Remove Delay (ms)", SCRIPT_PARAM_SLICE, 0, 0, 400, 0)
    if ignite then
    Menu.Items:addSubMenu("Ignite", "ignite")
    Menu.Items.ignite:addParam("set", "Use Smart Ignite", SCRIPT_PARAM_LIST, 2, {"OFF", "Optimal", "Aggressive"})
    end
    if exhaust then 
    Menu.Items:addSubMenu("Exhaust", "exhaust")
    Menu.Items.exhaust:addParam("exh", "Exhaust Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey(exhaust.key))
    Menu.Items:addTS(TES)
    TES = TargetSelector(TARGET_PRIORITY, 600, DAMAGE_MAGIC) 
    TES.name = "Exhaust"
    end
    if heal then
    Menu.Items:addSubMenu("Heal/Barrier", "heal")
    Menu.Items.heal:addParam("enable", "Enable to use", SCRIPT_PARAM_ONOFF, true)
    Menu.Items.heal:addParam("health", "If My Health % is Less Than", SCRIPT_PARAM_SLICE, 10, 0, 100, 0)
    if realheals then
    Menu.Items.heal:addParam("ally", "Use for Ally", SCRIPT_PARAM_ONOFF, false)
    end
    end
    Menu.Items:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Items:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    
    Menu:addSubMenu("[Ezreal]: Automation", "Autom")
    Menu.Autom:addSubMenu("AutoLevelSpells Settings", "autolevel")
    Menu.Autom.autolevel:addParam("UseAutoLevelFirst", "Use AutoLevelSpells Level 1-3", SCRIPT_PARAM_ONOFF, false)
    Menu.Autom.autolevel:addParam("UseAutoLevelRest", "Use AutoLevelSpells Level 4-18", SCRIPT_PARAM_ONOFF, false)
    Menu.Autom.autolevel:addParam("First3Level", "Level 1-3", SCRIPT_PARAM_LIST, 1, {"Q-W-E", "Q-E-W", "W-Q-E", "W-E-Q", "E-Q-W", "E-W-Q"})
    Menu.Autom.autolevel:addParam("RestLevel", "Level 4-18", SCRIPT_PARAM_LIST, 1, {"Q-W-E", "Q-E-W", "W-Q-E", "W-E-Q", "E-Q-W", "E-W-Q"})
    Menu.Autom.autolevel:addParam("Blank", "", SCRIPT_PARAM_INFO, "","" )
    Menu.Autom.autolevel:addParam("Blank", "You can Click on the Q-W-E", SCRIPT_PARAM_INFO, "","" )
    Menu.Autom.autolevel:addParam("Blank", "to change the AutoLevelOrder", SCRIPT_PARAM_INFO, "","" )
    Menu.Autom:addSubMenu("Skin Changer", "ChgSki")
    Menu.Autom:addSubMenu("Auto Buy Item", "buyme")
    Menu.Autom.buyme:addParam("buydoran", "Doran's Blade", SCRIPT_PARAM_ONOFF, true)
    Menu.Autom.buyme:addParam("buypot", "Potion", SCRIPT_PARAM_ONOFF, true)
    Menu.Autom.buyme:addParam("taketrinket", "Green Trinket", SCRIPT_PARAM_ONOFF, true)
    Menu.Autom.buyme:addParam("changeblue", "Lvl 9 Blue Trinket", SCRIPT_PARAM_ONOFF, true)
    Menu.Autom:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Autom:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
  
    Menu:addSubMenu("[Ezreal]: Spell Priority Settings", "Spell")
    
    Menu.Spell:addTS(QTS)
    Menu.Spell:addParam("blank", "      ", SCRIPT_PARAM_INFO, "  ")
    Menu.Spell:addParam("blank", "   ----------------------------------------------------   ", SCRIPT_PARAM_INFO, "------------- ")
    Menu.Spell:addParam("blank", "      ", SCRIPT_PARAM_INFO, "  ")
    Menu.Spell:addParam("blank", "  [Recommenned LessCast]  ", SCRIPT_PARAM_INFO, " ")
    Menu.Spell:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Spell:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    
    Menu:addSubMenu("[Ezreal]: Prediction Settings", "Prediction")

    Menu.Prediction:addParam("blank", "      ", SCRIPT_PARAM_INFO, "  ")
    Menu.Prediction:addParam("Choice", "Prediction Method", SCRIPT_PARAM_LIST, 1, {"VPrediction", "HPrediction", "SPrediction", "FHPrediction", "KPrediction", "Divine Prediction"})
    Menu.Prediction:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Prediction:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
      
      Menu.Prediction:addSubMenu("VPrediction", "VPrediction")
      Menu.Prediction.VPrediction:addParam("Q", "Q Hitchance (1.5)", SCRIPT_PARAM_SLICE, 1.5, 1, 5, 1)
      Menu.Prediction.VPrediction:addParam("W", "W Hitchance (1.5)", SCRIPT_PARAM_SLICE, 1.8, 1, 5, 1) 
      Menu.Prediction.VPrediction:addParam("R", "R Hitchance (3)", SCRIPT_PARAM_SLICE, 3, 1, 5, 1)
      Menu.Prediction:addSubMenu("HPrediction", "HPrediction")
      Menu.Prediction.HPrediction:addParam("Q", "Q Hitchance (1.1)", SCRIPT_PARAM_SLICE, 1.1, 1, 3, 1)
      Menu.Prediction.HPrediction:addParam("W", "W Hitchance (1.3)", SCRIPT_PARAM_SLICE, 1.3, 1, 3, 1)
      Menu.Prediction.HPrediction:addParam("R", "R Hitchance (1.8)", SCRIPT_PARAM_SLICE, 1.8, 1, 3, 1)
      Menu.Prediction:addSubMenu("SPrediction", "SPrediction")
      Menu.Prediction.SPrediction:addParam("Q", "Q Hitchance (1.5)", SCRIPT_PARAM_SLICE, 1.5, 1, 3, 1) 
      Menu.Prediction.SPrediction:addParam("W", "W Hitchance (1.8)", SCRIPT_PARAM_SLICE, 1.8, 1, 3, 1)
      Menu.Prediction.SPrediction:addParam("R", "R Hitchance (2)", SCRIPT_PARAM_SLICE, 2, 1, 3, 1)
      Menu.Prediction:addSubMenu("KPrediction", "KPrediction")
      Menu.Prediction.KPrediction:addParam("Q", "Q Hitchance (1.3)", SCRIPT_PARAM_SLICE, 1.3, 1, 4, 1)
      Menu.Prediction.KPrediction:addParam("W", "W Hitchance (1.5)", SCRIPT_PARAM_SLICE, 1.5, 1, 4, 1)
      Menu.Prediction.KPrediction:addParam("R", "R Hitchance (1.8)", SCRIPT_PARAM_SLICE, 1.8, 1, 4, 1)
      Menu.Prediction:addSubMenu("Divine Prediction", "DPrediction")
      Menu.Prediction.DPrediction:addParam("Q", "Q Hitchance (%50)", SCRIPT_PARAM_SLICE, 50, 1, 100, 0)
      Menu.Prediction.DPrediction:addParam("W", "W Hitchance (%60)", SCRIPT_PARAM_SLICE, 60, 1, 100, 1)
      Menu.Prediction.DPrediction:addParam("R", "R Hitchance (%70)", SCRIPT_PARAM_SLICE, 70, 1, 100, 0)
      Menu.Prediction:addSubMenu("FHPrediction", "FHPrediction")
      Menu.Prediction.FHPrediction:addParam("Q", "Q Hitchance (1.1)", SCRIPT_PARAM_SLICE, 1.1, 1, 2, 1)
      Menu.Prediction.FHPrediction:addParam("W", "W Hitchance (1.2)", SCRIPT_PARAM_SLICE, 1.2, 1, 2, 1)
      Menu.Prediction.FHPrediction:addParam("R", "R Hitchance (1.3)", SCRIPT_PARAM_SLICE, 1.3, 1, 2, 1)
    LoadPrediction(Menu.Prediction.Choice)
    Menu.Prediction:setCallback("Choice", function(var) LoadPrediction(Menu.Prediction.Choice) end)

    Menu:addSubMenu("[Ezreal]: Orbwalker Settings", "Orbwalker")
    
    Menu.Spell:addTS(WTS)
    Menu.Spell:addTS(RTS)
    QTS.name = "Ezreal Q"
    WTS.name = "Ezreal W"
    RTS.name = "Ezreal R"
    
  Menu:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
  Menu:addParam("Info", "http://botoflegends.com", SCRIPT_PARAM_INFO, "")
  Menu:addParam("SVersion", "Script Version ", SCRIPT_PARAM_LIST, 1, {"" .. Version})
  Menu:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
  Menu:addParam("popup", "Click For Latest Changelog", SCRIPT_PARAM_ONOFF, false)
    
    
    
    Menu.Control:permaShow("OnLT")
    Menu.Control:permaShow("OnPT")
    Menu.Control:permaShow("OnJST")
    Menu.Combo:permaShow("Mode")
    Menu.Prediction:permaShow("Choice")

    Menu.Control.OnC = false
    Menu.Control.OnF = false
    Menu.Control.OnJF = false
    Menu.Control.OnP = false
    Menu.Control.OnL = false
    Menu.Control.OnJS = false
    Menu.Control.OnE = false
    Menu.Control.tmpdisable = false
  
end

---------------------------------------------------------------------------------
function LoadOrbwalk()

  if _G.AutoCarry and _G.Reborn_Initialised then
    SACLoaded = true
    Menu.Orbwalker:addParam("Info", "             ----->>> SAC Detected & Loaded <<<-----   ", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    ScriptMsg("Sida's Auto Carry Detected.")
  elseif _G.Reborn_Loaded then
    DelayAction(function() LoadOrbwalk() end, 1)
  elseif _G.MMA_IsLoaded then
    MMALoaded = true
    Menu.Orbwalker:addParam("Info", "             ----->>> MMA Detected & Loaded <<<-----   ", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    ScriptMsg("Marksman's Mighty Assistant Detected.")
  elseif _G._Pewalk then
    PEWLoaded = true
    Menu.Orbwalker:addParam("Info", "             ----->>> Pewalk Detected & Loaded <<<-----   ", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    ScriptMsg("Pewalk Detected.")
  elseif FileExist(LIB_PATH .. "SxOrbWalk.lua") then
    require 'SxOrbWalk'
    SxOrb = SxOrbWalk()
    SxOrb:LoadToMenu(Menu.Orbwalker)
    Menu.Orbwalker:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    SxOrbLoaded = true
    ScriptMsg("Sxorbwalk Detected.")
  else
    ErrorMsg("WARNING:Orbwalker Not Found!")
  end
  
end
---------------------------------------------------------------------------------

--[[function LoadOrbwalker(choice)

  if choice == 1 then

    --[[if _G.NebelwolfisOrbWalkerInit or _G.NebelwolfisOrbWalkerLoaded then
      NOWLoaded = true
      ScriptMsg(" ")
      return
    end

    if _Pewalk then
      PEWLoaded = true
      ErrorMsg("Pewalk is enabled, you have to disable Pewalk in BoL menu for using Sida's Auto Carry.")
      return
    end

    if _G.MMA_IsLoaded then
      MMALoaded = true
      ErrorMsg("Marksman's Mighty Assistant is enabled, you have to disable Marksman's Mighty Assistant in BoL menu for using Sida's Auto Carry.")
      return
    end

    if _G.Reborn_Loaded then
      SACLoaded = true

      if _G.AutoCarry and _G.Reborn_Initialised then
        Menu.Orbwalker:addParam("Info", "             ----->>> SAC Detected & Loaded <<<-----   ", SCRIPT_PARAM_INFO, "")
      else
        DelayAction(function() LoadOrbwalker(1) end, 1)
      end

    else

      local function UpdateSAC()

        if FileExist(SCRIPT_PATH .. "Sida's Auto Carry.lua") then
          ErrorMsg("Error loading Sida's Auto Carry, try again or try to use another orbwalker else contact with developer.")
          Menu.Orbwalker:addParam("Info", "             ----->>> Loading Failed - SAC <<<-----   ", SCRIPT_PARAM_INFO, "")
        else
          DownloadFile("https://raw.githubusercontent.com/SidaBoL/Scripts/master/Misc/Sida's%20Auto%20Carry.lua", SCRIPT_PATH .. "Sida's Auto Carry.lua", function() UpdateSAC() end)
        end

      end

      UpdateSAC()
    end

  elseif choice == 2 then

    if _G.Reborn_Loaded then
      SACLoaded = true
      ErrorMsg("Sida's Auto Carry is enabled, you have to disable Sida's Auto Carry in BoL menu for using Pewalk.")
      return
    end

    if _G.MMA_IsLoaded then
      MMALoaded = true
      ErrorMsg("Marksman's Mighty Assistant is enabled, you have to disable Marksman's Mighty Assistant in BoL menu for using Pewalk.")
      return
    end

    --[[if _G.NebelwolfisOrbWalkerInit or _G.NebelwolfisOrbWalkerLoaded then
      NOWLoaded = true
      ScriptMsg(" ")
      return
    end

    if _Pewalk then
      PEWLoaded = true
      Menu.Orbwalker:addParam("Info", "             ----->>> Pewalk Detected & Loaded <<<-----   ", SCRIPT_PARAM_INFO, "")

      local function Disable()

        if _Pewalk.DisableSkillFarm then
          _Pewalk.DisableSkillFarm(_Q) _Pewalk.DisableSkillFarm(_W) _Pewalk.DisableSkillFarm(_E) _Pewalk.DisableSkillFarm(_R)
        else
          DelayAction(function() Disable() end, 1)
        end

      end

      Disable()
    else

      local function UpdatePEW()

        if FileExist(SCRIPT_PATH .. "Pewalk.lua") then
          ErrorMsg("Error loading Pewalk, try again or try to use another orbwalker else contact with developer.")
          Menu.Orbwalker:addParam("Info", "             ----->>> Loading Failed - Pewalk <<<-----   ", SCRIPT_PARAM_INFO, "")
        else
          DownloadFile("https://raw.githubusercontent.com/PewPewPew2/BoL/master/Pewalk.lua", SCRIPT_PATH .. "Pewalk.lua", function() UpdatePEW() end)
        end

      end

      UpdatePEW()
    end

  elseif choice == 3 then

    if _G.Reborn_Loaded then
      SACLoaded = true
      ErrorMsg("Sida's Auto Carry is enabled, you have to disable Sida's Auto Carry in BoL menu for using Marksman's Mighty Assistant.")
      return
    end

    if _Pewalk then
      PEWLoaded = true
      ErrorMsg("Pewalk is enabled, you have to disable Pewalk in BoL menu for using Marksman's Mighty Assistant. ")
      return
    end

    if _G.MMA_IsLoaded then
      MMALoaded = true
      Menu.Orbwalker:addParam("Info", "             ----->>> MMA Detected & Loaded <<<-----   ", SCRIPT_PARAM_INFO, "")
    else

      local function UpdateMMA()

        if FileExist(SCRIPT_PATH .. "MarksmanMightyAssistant.lua") then
          ErrorMsg("Error loading Marksman's Mighty Assistant, try again or try to use another orbwalker else contact with developer.")
          Menu.Orbwalker:addParam("Info", "             ----->>> Loading Failed - MMA <<<-----   ", SCRIPT_PARAM_INFO, "")
        else
          DownloadFile("http://manciuszz.net/mma2.0/MarksmanMightyAssistant.lua", SCRIPT_PATH .. "MarksmanMightyAssistant.lua", function() UpdateMMA() end)
        end

      end

      UpdateMMA()
      
    end
  end
end]]--

--[[function UnloadOrbwalker()

  if SACLoaded or PEWLoaded or MMALoaded then
    ScriptMsg("Press F9 x2 to disable orbwalker.")
  end
end]]--

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function LoadPrediction(choice)

  if choice == 1 and not VPred then

    if _G.VPrediction_Init then
      VPred = VPrediction()  
    else

      local function UpdateVPred()

        if FileExist(LIB_PATH .. "VPrediction.lua") then
          require("VPrediction")
          VPred = VPrediction()    
        else
          DownloadFile("https://raw.githubusercontent.com/SidaBoL/Scripts/master/Common/VPrediction.lua", LIB_PATH .. "VPrediction.lua", function() UpdateVPred() end)
        end

      end

      UpdateVPred()
    end
    
  

  elseif choice == 2 and not HPred then

    if _G.HPrediction_Init then
      HPred = HPrediction()  
    else

      local function UpdateHPred()

        if FileExist(LIB_PATH .. "HPrediction.lua") then
          require("HPrediction")
          HPred = HPrediction()    
        else
          DownloadFile("https://raw.githubusercontent.com/Jaikor/BoL-1/master/HTTF/Common/HPrediction.lua", LIB_PATH .. "HPrediction.lua", function() UpdateHPred() end)
        end

      end

      UpdateHPred()
    end
    
    elseif choice == 3 and not SPred then

    if _G.SPrediction_Init then
      SPred = SPrediction()  
    else

      local function UpdateSPred()

        if FileExist(LIB_PATH .. "SPrediction.lua") then
          require("SPrediction")
          SPred = SPrediction()    
        else
          DownloadFile("https://raw.githubusercontent.com/nebelwolfi/BoL/master/Common/SPrediction.lua", LIB_PATH .. "SPrediction.lua", function() UpdateSPred() end)
        end

      end

      UpdateSPred()
    end

  elseif choice == 4 and not FHPred then

    if FileExist(LIB_PATH .. "FHPrediction.lua") then
          require("FHPrediction")
          FHPred = FHPrediction
    else  
      ErrorMsg("FHPrediction not found , please download manually from the forums , loaded VPrediction for now.")
      LoadPrediction(1)
    end
  
  elseif choice == 5 and not KPred then

    if _G.KPrediction_Init then
      KPred = KPrediction()  
    else

      local function UpdateKPred()

        if FileExist(LIB_PATH .. "KPrediction.lua") then
          require("KPrediction")
          KPred = KPrediction()    
        else
          DownloadFile("https://raw.githubusercontent.com/Jaikor/BoL-1/master/HTTF/Common/KPrediction.lua", LIB_PATH .. "KPrediction.lua", function() UpdateKPred() end)
        end

      end

      UpdateKPred()
    end

 elseif choice == 6 and not DPred then
    if DPExist then
      require("DivinePred")
      DPred = DivinePred()
      DPred:bindSS("Q",50)
      DPred:bindSS("R",50)
      DelayAction(function()
        if not DivinePred.isAuthed() then
          ErrorMsg("You have no access to Divine Pred, loaded VPrediction for now.")
          LoadPrediction(1)
        end
      end,3)
    else
      ErrorMsg("Divine Prediction not found , please download manually from the forums , loaded VPrediction for now.")
      LoadPrediction(1)
    end
  end

end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function OnTick()
  if not Loaded then
    return
  end

  if myHero.dead then
    return
  end
  
  Checks()

  if Menu.Combo.Mode == 1 then
    TargetsInsane()
  elseif Menu.Combo.Mode == 2 then
    TargetsHumanoid()
  end
  
  if Menu.Control.OnC then
    Combo()
  end

  if Menu.popup then
    Menu.popup = false
    PopUp = true
  end
  
  if Menu.Control.OnC and Menu.Combo.vision then
    Bushfind()
  end
  
  if Menu.Control.OnF then
    Farm()
  end
  
  if Menu.Control.OnJF then
    JFarm()
  end
  
  if Menu.Autom.autolevel.UseAutoLevelFirst or Menu.Autom.autolevel.UseAutoLevelRest then
    CheckLevelChange()
    LevelUpSpell()
  end
  
  if Menu.Control.OnP then
    Harass()
  end
  
  if Menu.Control.OnPT then
    HarassAlways()
  end
  
  if Menu.Control.OnL then
    LastHit()
  end

  if Menu.Control.OnLT then
    LastHitAlways()
  end
  
  if Menu.Control.OnJS then
    JSteal()
  end
  
  if Menu.Control.OnJST then
    JstealAlways()
  end
  
  if Menu.KillSteal.On then
    KillSteal()
    KillStealR()
  end
  
  if Menu.Control.OnE then
    Flee()
  end
  
  if Menu.Draw.stream and not ChatOff then
    dChat()
  elseif not Menu.Draw.stream and ChatOff then
    eChat()
  end

  if Menu.Items.BotRK.bork then
    if myHero.health / myHero.maxHealth <=  Menu.Items.BotRK.maxownhealth / 100 then
      local unit = TargetsInsane() or TargetsHumanoid()
      if ValidTarget(unit, 1000) then
        if unit.health / unit.maxHealth <=  Menu.Items.BotRK.minenemyhealth  / 100 then
          BotRK(unit)
        end
      end
    end 
  end 
     
    if Menu.Items.Bilgewater.bilg then
    if myHero.health / myHero.maxHealth <=  Menu.Items.Bilgewater.maxownhealth / 100 then
      local unit = TargetsInsane() or TargetsHumanoid()
      if ValidTarget(unit, 1000) then
        if unit.health / unit.maxHealth <=  Menu.Items.Bilgewater.minenemyhealth / 100 then
          Bilgewater(unit)
        end
      end
    end 
  end 
    
    if exhaust and Menu.Items.exhaust.exh then 
    if myHero:CanUseSpell(exhaust.slot) == 0 then
      TES:update()
      if ValidTarget(TES.target) and TES.target.type == myHero.type then
        exhFunction(TES.target) 
      end
    end
  end

  if heal then
    if ValidTarget(TargetsInsane() or TargetsHumanoid(), 1000) then
      if Menu.Items.heal.enable and myHero:CanUseSpell(heal) == 0 then
        if myHero.level > 5 and myHero.health/myHero.maxHealth < Menu.Items.heal.health/100 then
          CastSpell(heal)
        elseif  myHero.level < 6 and myHero.health/myHero.maxHealth < (Menu.Items.heal.health/100)*.75 then
          CastSpell(heal)
        end
        
        if realheals and Menu.Items.heal.ally then
          local ally = findClosestAlly(myHero)
          if ally and not ally.dead and GetDistance(ally) < 850 then
            if  ally.health/ally.maxHealth < Menu.Items.heal.health/100 then
              CastSpell(heal)
            end
          end
        end
      end
    end
  end

  if not myHero.dead then
    if (Menu.Items.potion.Key or Menu.Items.potion.Always) and not potionOn and not InFountain() and (myHero.health/myHero.maxHealth)*100 < Menu.Items.potion.health then
      UsePotion()
    end
  end
  
  if ignite and Menu.Items.ignite.set > 1 and (myHero:CanUseSpell(ignite) == READY) then 
    AutoIgnite()
  end

end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function AlliesAround(Unit, range)
    local c=0
    if Unit == nil then return 0 end
    for i=1,heroManager.iCount do hero = heroManager:GetHero(i) if hero.team == myHero.team and hero.x and hero.y and hero.z and GetDistance(hero, Unit) < range then c=c+1 end end return c
end

function EnemiesAround(Unit, range)
    local c=0
    if Unit == nil then return 0 end
    for i=1,heroManager.iCount do hero = heroManager:GetHero(i) if hero ~= nil and hero.team ~= myHero.team and hero.x and hero.y and hero.z and GetDistance(hero, Unit) < range then c=c+1 end end return c
  end

function findClosestAlly(obj)
    local closestAlly = nil
    local currentAlly = nil
  for i, currentAlly in pairs(GetAllyHeroes()) do
        if currentAlly and not currentAlly.dead then
            if closestAlly == nil then
                closestAlly = currentAlly
      end
            if GetDistanceSqr(currentAlly.pos, obj) < GetDistanceSqr(closestAlly.pos, obj) then
        closestAlly = currentAlly
            end
        end
    end
  return closestAlly
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function CheckItem(ItemName)
  for i = 6, 12 do
    local item = myHero:GetSpellData(i).name
    if item and item:lower() == ItemName then
      return i
    end
  end
end

function checkSpecific(unit, buffname)
  if unit.buffCount then
    for i = 1, unit.buffCount do
      local buff = unit:getBuff(i)
      if buff and buff.valid and buff.name then
        if buff.name:lower():find(buffname) then
          return true
        end
      end
    end
  end
end

function exhFunction(unit)
  moveToCursor()
  CastSpell(exhaust.slot, unit)
end

function moveToCursor()
  local MouseMove = Vector(myHero) + (Vector(mousePos) - Vector(myHero)):normalized() * 500
  myHero:MoveTo(MouseMove.x, MouseMove.z) 
end

function OnUpdateBuff(unit, buff, stacks)
  if not unit or not buff then return end
  if unit.isMe then
    if buff.name:lower():find("regenerationpotion") or buff.name:lower():find("itemminiregenpotion") or buff.name:lower():find("crystalflask") then
      potionOn = true
    end
  end
end

function OnRemoveBuff(unit, buff)
  if not unit or not buff then return end
  if unit.isMe then
    if buff.name:lower():find("regenerationpotion") or buff.name:lower():find("itemminiregenpotion") or buff.name:lower():find("crystalflask") then
      potionOn = false
    end
  end
end
local lastPotion = 0

function UsePotion()
  if os.clock() - lastPotion < 8 then return end
  if not Menu.Items.potion.enemy then
    if CountEnemiesNearUnitReg(myHero, 750) == 0 then return end
  end
  
  local slot = GetSlotItemFromName("crystalflask")
  if not slot then
    slot = GetSlotItemFromName("RegenerationPotion")
  end
  if not slot then
    slot = GetSlotItemFromName("itemminiregenpotion")
  end
  if slot then
    CastSpell(slot)
    lastPotion = os.clock()
  end
end
local lastPotionMana = 0

function UsePotionMana()
  if CountEnemiesNearUnitReg(myHero, 1000) == 0 then return end
  if os.clock() - lastPotionMana < 8 then return end
  local slot = GetSlotItemFromName("crystalflask")
  if not slot then
    slot = GetSlotItemFromName("flaskofcrystalwater")
  end
  if slot then
    CastSpell(slot)
    lastPotionMana = os.clock()
  end
end

function GetSlotItemFromName(itemname)
  local slot
  for i = 6, 12 do
    local item = myHero:GetSpellData(i).name
    if item and item:lower():find(itemname:lower()) and myHero:CanUseSpell(i) == READY then
      slot = i
    end
  end
  return slot
end

function GetSlotItem(id, unit)
  unit = unit or myHero

  if (not ItemNames[id]) then
    return ___GetInventorySlotItem(id, unit)
  end

  local name  = ItemNames[id]
  
  for slot = ITEM_1, ITEM_7 do
    local item = unit:GetSpellData(slot).name
    if item and item:lower() == name:lower() and myHero:CanUseSpell(slot) == READY then
      return slot
    end
  end
end

local lastTAttack = 0
local tDamage = 1
if AddProcessAttackCallback and heal and Menu.Items.heal.enable then
  AddProcessAttackCallback(function(unit, spell) AProc(unit, spell) end)
end

function AProc(unit, spell)
  if not unit or not unit.valid or not spell then return end

  if spell.target and spell.target.type == myHero.type and spell.target.team == myHero.team and (spell.name:lower():find("_turret_chaos") or spell.name:lower():find("_turret_order")) and not (spell.name:lower():find("4") or spell.name:lower():find("3")) then
    if GetDistance(unit) < 2000 then
      if clock() - lastTAttack < 1.75 then
        if tDamage < 1.75 then
          tDamage = tDamage + 0.375
        else
          tDamage = tDamage + 0.250
          tDamage = tDamage > 2.25 and 2.25 or tDamage
        end
      else
        tDamage = 1
      end
      lastTAttack = clock()
      
      if myHero:CanUseSpell(heal) == 0 and spell.target.isMe then
        local realDamage = unit.totalDamage / (((myHero.armor * 0.7) / 100) + 1)

        if VPred:GetPredictedHealth(myHero, 0.5) + myHero.shield <= realDamage * tDamage then
          DelayAction(function()
            CastSpell(heal)
            ScriptMsg("Saving from tower")
          end, 0.5)
        end
      end
    end
  end
end

function OnProcessSpell(unit, spell)
if not unit or not unit.valid or not spell then return end

  if heal and Menu.Items.heal.enable and myHero:CanUseSpell(heal) == 0 and spell.target and spell.target.isMe and unit.team ~= myHero.team and unit.type == myHero.type then
    if myHero.health/myHero.maxHealth <= (Menu.Items.heal.health/100)*1.5 then
      CastSpell(heal)
    end
  end
  if spell.name:lower():find("zedr") and spell.target == myHero then
    DelayAction(function()
    end, 1.7)
  end
end

function OnApplyBuff(source, unit, buff)
if not buff or not source or not source.valid or not unit or not unit.valid then return end
  if unit.isMe and (Menu.Items.cc.Always or Menu.Items.cc.Key) then
    if (source.charName == "Rammus" and buff.type ~= 8) or source.charName == "Alistar" or source.charName:lower():find("baron") or source.charName:lower():find("spiderboss") or source.charName == "LeeSin" or (source.charName == "Hecarim" and not buff.name:lower():find("fleeslow")) then return end  
    if buff.name and ((not cleanse and buff.type == 24) or buff.type == 5 or buff.type == 11 or buff.type == 22 or buff.type == 21 or buff.type == 8)
    or (buff.type == 10 and buff.name and buff.name:lower():find("fleeslow")) then
      if buff.name and buff.name:lower():find("caitlynyor") and CountEnemiesNearUnitReg(myHero, 700) == 0   then
        return false
      elseif not source.charName:lower():find("blitzcrank") then
        UseItemsCC(myHero, true)
      end          
    end           
  end  
end

function CountEnemiesNearUnitReg(unit, range)
  local count = 0
  for i, enemy in pairs(GetEnemyHeroes()) do
    if not enemy.dead and enemy.visible then
      if  GetDistanceSqr(unit, enemy) < range * range  then 
        count = count + 1 
      end
    end
  end
  return count
end

function UseItemsCC(unit, scary)
  if os.clock() - lastRemove < 1 then return end
  for i, Item in pairs(Items) do
    local Item = Items[i]
    if GetInventoryItemIsCastable(Item.id) and GetDistanceSqr(unit) <= Item.range * Item.range then
      if Item.id == 3139 or Item.id ==  3140 then
        if scary then
          DelayAction(function()
            CastItem(Item.id)
          end, Menu.Items.cc.delay/1000)  
          lastRemove = os.clock()
          return true
        end
      end
    end
  end
  if Menu.Items.cc.Summoner and SummonerSlot and myHero:CanUseSpell(SummonerSlot) == 0 then
    DelayAction(function()
      CastSpell(SummonerSlot)
    end, Menu.Items.cc.delay/1000)
    lastRemove = os.clock()
  end
end

function findClosestEnemy(obj)
    local closestEnemy = nil
    local currentEnemy = nil
  for i, currentEnemy in pairs(GetEnemyHeroes()) do
        if ValidTarget(currentEnemy) then
            if closestEnemy == nil then
                closestEnemy = currentEnemy
      end
            if GetDistanceSqr(currentEnemy.pos, obj) < GetDistanceSqr(closestEnemy.pos, obj) then
        closestEnemy = currentEnemy
            end
        end
    end
  return closestEnemy
end

function HealSlot()
  if myHero:GetSpellData(SUMMONER_1).name:lower():find("summonerheal") or myHero:GetSpellData(SUMMONER_2).name:lower():find("summonerheal") then
    realheals = true
  end
  if myHero:GetSpellData(SUMMONER_1).name:lower():find("summonerheal")  or myHero:GetSpellData(SUMMONER_1).name:lower():find("summonerbar") then
    return SUMMONER_1
  elseif myHero:GetSpellData(SUMMONER_2).name:lower():find("summonerheal") or myHero:GetSpellData(SUMMONER_2).name:lower():find("summonerbar") then
    return SUMMONER_2
  end
end

function BotrK(unit, scary)
  for i, Item in pairs(Items) do
    local Item = Items[i]
    if Item.id ~= 3140 and Item.id ~= 3139 then
      if GetInventoryItemIsCastable(Item.id) and GetDistanceSqr(unit) <= Item.range * Item.range then
        if Item.id == 3153 then
          CastItem(Item.id)
        else
          CastItem(Item.id, unit) return true
        end
      end
    end
  end
end

function Bilgewater(unit, scary)
  for i, Item in pairs(Items) do
    local Item = Items[i]
    if Item.id ~= 3140 and Item.id ~= 3139 then
      if GetInventoryItemIsCastable(Item.id) and GetDistanceSqr(unit) <= Item.range * Item.range then
        if Item.id == 3144 then
          CastItem(Item.id)
        else
          CastItem(Item.id, unit) return true
        end
      end
    end
  end
end

--[[function Youmuu()
  if Menu.Items.Youmuu.yomu then
  local slot = GetInventorySlotItem(3142)
  if Target ~= nil and ValidTarget(Target) and not Target.dead and slot ~= nil and myHero:CanUseSpell(slot) == READY then
  CastSpell(slot)
  end
end
end]]--

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function AutoIgnite()
  local IgniteDmg = 50 + (20 * myHero.level)
  local aggro = Menu.Items.ignite.set == 3 and 0.05 or 0
  for i, enemy in pairs(GetEnemyHeroes()) do
    if ValidTarget(enemy, 600) then
      local spellDamage = 0
      local adDamage = myHero:CalcDamage(enemy, myHero.totalDamage)
      spellDamage = spellDamage + adDamage
      if myHero.health < myHero.maxHealth*(0.35+aggro) and enemy.health < enemy.maxHealth*(0.34+aggro) and GetDistanceSqr(enemy) < 420 * 420 then
        CastSpell(ignite, enemy)
      end
      local r = myHero.range+65
      local trange = r < 575 and r or 575
      if isFleeingFromMe(enemy, trange) then
        if enemy.health < IgniteDmg + spellDamage  + 10 then    
          if myHero.ms < enemy.ms then
            CastSpell(ignite, enemy)  
            if Debug then
              ScriptMsg("+++++++!")
            end 
          else
            if Debug then
              ScriptMsg("-------!")
            end
          end
        end 
      end
      if (GetDistanceSqr(enemy) > 160000 and (myHero.health+myHero.shield) < myHero.maxHealth*0.3) then 
        if enemy.health > spellDamage-(500*aggro) and enemy.health < IgniteDmg + spellDamage-(500*aggro)  then
          CastSpell(ignite, enemy)              
          if Debug then
            ScriptMsg("ignite Q")
          end
        end
      end
    end
  end
end

function CountAlliesNearUnit(unit, range)
  local count = 0
  for i, ally in pairs(GetAllyHeroes()) do
    if GetDistanceSqr(ally, unit) <= range * range and not ally.dead then count = count + 1 end
  end
  return count
end

function isFleeingFromMe(target, range)
  local pos = VPred:GetPredictedPos(target, 0.26)
  
  if pos and GetDistanceSqr(pos) > range*range then
    return true
  end
  return false
end

function amIFleeing(target, range)
  local pos = VPred:GetPredictedPos(myHero, 0.26)
  
  if pos and GetDistanceSqr(pos, target) > range*range then
    return true
  end
  return false
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function Checks()

  Q.ready = myHero:CanUseSpell(_Q) == READY
  W.ready = myHero:CanUseSpell(_W) == READY
  E.ready = myHero:CanUseSpell(_E) == READY
  R.ready = myHero:CanUseSpell(_R) == READY
  I.ready = Ignite ~= nil and myHero:CanUseSpell(Ignite) == READY
  
  Q.level = myHero:GetSpellData(_Q).level
  W.level = myHero:GetSpellData(_W).level
  E.level = myHero:GetSpellData(_E).level
  R.level = myHero:GetSpellData(_R).level
  
  EnemyMinions:update()
  JungleMobs:update()
  
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function TargetsHumanoid()
  
  local Target = nil
  
  if ValidTarget(SelectedTarget) then
    Target = SelectedTarget
  elseif _G.MMA_IsLoaded then 
    Target = _G.MMA_Target()
  elseif _G.AutoCarry and _G.Reborn_Initialised then 
    Target = _G.AutoCarry.Crosshair:GetTarget()
  elseif _G._Pewalk then 
    Target = _G._Pewalk.GetTarget()
  elseif SxOrbLoaded then
    Target = SxOrb:GetTarget()
  end

  if Target and Target.type == myHero.type and ValidTarget(Target, TrueRange(Target)) then
    QTarget = Target
    WTarget = Target
    RTarget = Target
  else
    QTS:update()
    WTS:update()
    RTS:update()
    QTarget = QTS.target
    WTarget = WTS.target
    RTarget = RTS.target
  end
end

function TargetsInsane()

local Target = nil

  if ValidTarget(SelectedTarget) then

    QTarget = SelectedTarget
    WTarget = SelectedTarget
    RTarget = SelectedTarget 

  elseif Target and Target.type == myHero.type and ValidTarget(Target, TrueRange(Target)) then
    QTarget = Target
    WTarget = Target
    RTarget = Target
  else
    QTS:update()
    WTS:update()
    RTS:update()
    QTarget = QTS.target
    WTarget = WTS.target
    RTarget = RTS.target
  end
end

function OnWndMsg(Msg, Key)
  if Msg == WM_LBUTTONDOWN then
if PopUp then
PopUp = false
end
end
  if Msg == WM_LBUTTONDOWN and Menu.Combo.focus then
    local minDis = 0
    local starget = nil
    for i, enemy in ipairs(GetEnemyHeroes()) do
      if ValidTarget(enemy) then
        if GetDistance(enemy, mousePos) <= minDis or starget == nil then
          minDis = GetDistance(enemy, mousePos)
          starget = enemy
        end
      end
    end

    if starget and minDis < starget.boundingRadius*2 then
      if SelectedTarget and starget.charName == SelectedTarget.charName then
        SelectedTarget = nil
        ScriptMsg("Target Unlocked", true)
      else
        SelectedTarget = starget
        ScriptMsg("Target Locked  - "..starget.charName.."", true)
      end
      elseif SelectedTarget ~= nil then
        SelectedTarget = nil
        ScriptMsg("Target Unlocked", true)
      end
    end
  end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function OrbwalkCanMove()

  if SACLoaded then
    return _G.AutoCarry.Orbwalker:CanMove()
  elseif PEWLoaded then
    return _Pewalk.CanMove()
  elseif MMALoaded then
    return _G.MMA_CanMove()
  end
  
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function Combo()

  if QTarget ~= nil then
  
    local ComboQ = Menu.Combo.Q
    local ComboQ2 = Menu.Combo.Q2
  
    if Q.ready and ComboQ and ComboQ2 <= ManaPercent() then
    
      if ValidTarget(QTarget, Q.range+QTarget.boundingRadius) then
        CastQ(QTarget, "Combo")
      end
      
      for i, enemy in ipairs(EnemyHeroes) do
      
        if ValidTarget(enemy, Q.range+100) then
          CastQ(enemy, "Combo")
        end
        
      end
      
    end
    
  end

  if WTarget ~= nil then
  
    local ComboW = Menu.Combo.W
    local ComboW2 = Menu.Combo.W2
  
    if W.ready and ComboW and ComboW2 <= ManaPercent() then
    
      if ValidTarget(WTarget, W.range+WTarget.boundingRadius) then
        CastW(WTarget, "Combo")
      end
      
      for i, enemy in ipairs(EnemyHeroes) do
      
        if ValidTarget(enemy, W.range+100) then
          CastW(enemy, "Combo")
        end
        
      end
      
    end
    
  end
  
  if RTarget ~= nil and not Menu.Combo.saveR then
  
    local ComboR = Menu.Combo.R
    local ComboR2 = Menu.Combo.R2
  
    if R.ready and ComboR and ComboR2 <= ManaPercent() then
    
      if ValidTarget(RTarget, R.range+RTarget.boundingRadius) then
        CastR(RTarget, "Combo")
      end
      
      for i, enemy in ipairs(EnemyHeroes) do
      
        if ValidTarget(enemy, R.range+100) then
          CastR(enemy, "Combo")
        end
        
      end
      
    end
    
  end

end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function Farm()

  local FarmQ = Menu.Farm.Q
  local FarmQ2 = Menu.Farm.Q2
  
  
  if Q.ready and FarmQ and FarmQ2 <= ManaPercent() then
    
    for i, minion in pairs(EnemyMinions.objects) do
    
      local QMinionDmg = GetDmg("Q", minion)
      
      if QMinionDmg >= minion.health and ValidTarget(minion, Q.range+100) then
        CastQ(minion)
      end
      
    end
    
    for i, minion in pairs(EnemyMinions.objects) do
    
      local AAMinionDmg = GetDmg("AA", minion)
      local QMinionDmg = GetDmg("Q", minion)
      
      if QMinionDmg+2.5*AAMinionDmg <= minion.health and ValidTarget(minion, Q.range+100) then
        CastQ(minion)
      end
      
    end
    
  end
  
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function JFarm()

  local JFarmQ = Menu.JFarm.Q
  local JFarmQ2 = Menu.JFarm.Q2
  
  if Q.ready and JFarmQ and JFarmQ2 <= ManaPercent() then
  
    for i, junglemob in pairs(JungleMobs.objects) do
    
      local LargeJunglemob = nil
      
      for j = 1, #FocusJungleNames do
        if junglemob.name == FocusJungleNames[j] then
          LargeJunglemob = junglemob
          break
        end
        
      end
      
      if LargeJunglemob ~= nil and GetDistance(LargeJunglemob, mousePos) <= Q.range and ValidTarget(LargeJunglemob, Q.range+100) then
        CastQ(LargeJunglemob)
        return
      end
      
    end
    
    for i, junglemob in pairs(JungleMobs.objects) do
    
      if ValidTarget(junglemob, Q.range+100) then
        CastQ(junglemob)
      end
      
    end
    
  end
  
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function Harass()
  
  if QTarget ~= nil then
  
    local HarassQ = Menu.Harass.Q
    local HarassQ2 = Menu.Harass.Q2
    
    if Q.ready and HarassQ and HarassQ2 <= ManaPercent() then
      QHitChance = nil
      
      if ValidTarget(QTarget, Q.range+QTarget.boundingRadius) then
        CastQ(QTarget, "Harass")
      end
      
      if QHitChance ~= nil and QHitChance >= 0 and QHitChance < 1 then
      
        for i, enemy in ipairs(EnemyHeroes) do
        
          if ValidTarget(enemy, Q.range+QTarget.boundingRadius) then
            CastQ(enemy, "Harass")
          end
          
        end
        
      end
      
    end
    
  end

  if WTarget ~= nil then
  
    local HarassW = Menu.Harass.W
    local HarassW2 = Menu.Harass.W2
    
    if W.ready and HarassW and HarassW2 <= ManaPercent() then
      WHitChance = nil
      
      if ValidTarget(WTarget, W.range+WTarget.boundingRadius) then
        CastW(WTarget, "Harass")
      end
      
      if WHitChance ~= nil and WHitChance >= 0 and WHitChance < 1 then
      
        for i, enemy in ipairs(EnemyHeroes) do
        
          if ValidTarget(enemy, W.range+WTarget.boundingRadius) then
            CastW(enemy, "Harass")
          end
          
        end
        
      end
      
    end
    
  end

end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function HarassAlways()

if IsRecall then
  return
else
  
  if QTarget ~= nil then
  
    local HarassQ = Menu.Harass.Q
    local HarassQ2 = Menu.Harass.Q2
    
    if Q.ready and HarassQ and HarassQ2 <= ManaPercent() then
      QHitChance = nil
      
      if ValidTarget(QTarget, Q.range+QTarget.boundingRadius) then
        CastQ(QTarget, "Harass")
      end
      
      if QHitChance ~= nil and QHitChance >= 0 and QHitChance < 1 then
      
        for i, enemy in ipairs(EnemyHeroes) do
        
          if ValidTarget(enemy, Q.range+QTarget.boundingRadius) then
            CastQ(enemy, "Harass")
          end
          
        end
        
      end
      
    end

  end

  if WTarget ~= nil then
  
    local HarassW = Menu.Harass.W
    local HarassW2 = Menu.Harass.W2
    
    if W.ready and HarassW and HarassW2 <= ManaPercent() then
      WHitChance = nil
      
      if ValidTarget(WTarget, W.range+WTarget.boundingRadius) then
        CastW(WTarget, "Harass")
      end
      
      if WHitChance ~= nil and WHitChance >= 0 and WHitChance < 1 then
      
        for i, enemy in ipairs(EnemyHeroes) do
        
          if ValidTarget(enemy, W.range+WTarget.boundingRadius) then
            CastW(enemy, "Harass")
          end
          
        end
        
      end
      
    end
    
  end

end

end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function LastHit()

  local LastHitQ = Menu.LastHit.Q
  local LastHitQ2 = Menu.LastHit.Q2
  
  if Q.ready and LastHitQ and LastHitQ2 <= ManaPercent() then
  
    for i, minion in pairs(EnemyMinions.objects) do
    
      local QMinionDmg = GetDmg("Q", minion)
      
      if QMinionDmg >= minion.health and ValidTarget(minion, Q.range+100) then
        CastQ(minion, "LastHit")
      end
      
    end
    
  end
  
end

function LastHitAlways()

if Menu.LastHit.disable and Menu.Control.OnC or IsRecall then
  return
else

  local LastHitQ = Menu.LastHit.Q
  local LastHitQ2 = Menu.LastHit.Q2
  
  if Q.ready and LastHitQ and LastHitQ2 <= ManaPercent() then
  
    for i, minion in pairs(EnemyMinions.objects) do
    
      local QMinionDmg = GetDmg("Q", minion)
      
      if QMinionDmg >= minion.health and ValidTarget(minion, Q.range+100) then
        CastQ(minion, "LastHit")
      end
    end 
  end
end
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function JSteal()

  local JStealR = Menu.JSteal.R
  
  if R.ready and JStealR then
  
    for i, junglemob in pairs(JungleMobs.objects) do
    
      local RJunglemobDmg = GetDmg("R", junglemob)
      
      for j = 1, #FocusJungleNames do
      
        if junglemob.name == FocusJungleNames[j] and RJunglemobDmg >= junglemob.health and ValidTarget(junglemob, Menu.JSteal.range) or junglemob.charName:lower():find("dragon") and RJunglemobDmg >= junglemob.health and ValidTarget(junglemob, Menu.JSteal.range) then
          CastR(junglemob, "JSteal")
        end
        
      end
      
    end
    
  end
  
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function JstealAlways()
  
if Menu.Control.tmpdisable then return
end

  if Q.ready and Menu.JSteal.Q then
  
    for i, junglemob in pairs(JungleMobs.objects) do
    
      local QJunglemobDmg = GetDmg("Q", junglemob)
      
      for j = 1, #FocusJungleNames do
      
        if junglemob.name == FocusJungleNames[j] and QJunglemobDmg >= junglemob.health and ValidTarget(junglemob, Q.range+junglemob.boundingRadius) or junglemob.charName:lower():find("dragon") and QJunglemobDmg >= junglemob.health and ValidTarget(junglemob, Q.range+junglemob.boundingRadius) then
          CastQ(junglemob, "JstealAlways")
        end
        
      end
      
    end
    
  end
  
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function KillSteal()

  local KillStealQ = Menu.KillSteal.Q
  local KillStealW = Menu.KillSteal.W
  
  for i, enemy in ipairs(EnemyHeroes) do
  
    local QTargetDmg = GetDmg("Q", enemy)
    local WTargetDmg = GetDmg("W", enemy)
    
    if Q.ready and KillStealQ and QTargetDmg >= enemy.health and ValidTarget(enemy, Q.range+enemy.boundingRadius) then
      CastQ(enemy, "KillSteal")
    end

    if W.ready and KillStealW and WTargetDmg >= enemy.health and ValidTarget(enemy, W.range+enemy.boundingRadius) then
      CastW(enemy, "KillSteal")
    end
  end
end
  

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function KillStealR()

  if EnemiesAround(myHero, 600) >= Menu.KillSteal.minrange then
    return
  else

  local KillStealR = Menu.KillSteal.R
  
  for i, enemy in ipairs(EnemyHeroes) do
  
    local RTargetDmg = GetDmg("R", enemy)
    
    
    if R.ready and KillStealR and RTargetDmg >= enemy.health and ValidTarget(enemy, Menu.KillSteal.range) then
      CastR(enemy, "KillStealR")
    end
  end
end
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function Flee()
  MoveToMouse()
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function HealthPercent(unit)
  return (unit.health/unit.maxHealth)*100
end

function ManaPercent()
  return (myHero.mana/myHero.maxMana)*100
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function AddRange(unit)
  return unit.boundingRadius
end

function TrueRange(enemy)
  return myHero.range+AddRange(myHero)+AddRange(enemy)
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function GetDmg(spell, enemy)

  if enemy.health == 0 then
    return 0
  end
  
  local ADDmg = 0
  local APDmg = 0
  
  local Level = myHero.level
  local TotalDmg = myHero.totalDamage
  local AddDmg = myHero.addDamage
  local AP = myHero.ap
  local ArmorPen = myHero.armorPen
  local ArmorPenPercent = myHero.armorPenPercent
  local MagicPen = myHero.magicPen
  local MagicPenPercent = myHero.magicPenPercent
  
  local Armor = math.max(0, enemy.armor*ArmorPenPercent-ArmorPen)
  local ArmorPercent = Armor/(100+Armor)
  local MagicArmor = math.max(0, enemy.magicArmor*MagicPenPercent-MagicPen)
  local MagicArmorPercent = MagicArmor/(100+MagicArmor)
    
    if spell == "AA" then
    ADDmg = TotalDmg
    elseif spell == "Q" then
  
    if Q.ready then
      ADDmg = 20*Q.level+15+1.1*TotalDmg+.4*AP
    end
    
    elseif spell == "W" then
  
    if W.ready then
      APDmg = 45*W.level+25+.8*AP
    end
    
    elseif spell == "E" then
  
    if E.ready then
      APDmg = 50*E.level+25+.75*AP
    end
    
    elseif spell == "R" then
  
    if R.ready then
      APDmg = 150*R.level+200+AddDmg+.9*AP
    end
    
  end
  
  local TrueDmg = ADDmg*(1-ArmorPercent)+APDmg*(1-MagicArmorPercent)
  
  return TrueDmg
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function CastQ(unit, mode)
  
if unit.dead then return end  

if Menu.Prediction.Choice == 1 and VPred then
    local CastPosition, HitChance, Position = VPred:GetLineCastPosition(unit, Q.delay, Q.radius, Q.range, Q.speed, myHero, true)
    
    if HitChance >= (mode == nil and 1 or Menu.Prediction.VPrediction.Q) then
      CastSpell(_Q, CastPosition.x, CastPosition.z)
    end
  
  elseif Menu.Prediction.Choice == 2 and HPred then
    local Pos, HitChance = HPred:GetPredict(HPred.Presets["Ezreal"]["Q"], unit, myHero)

    if HitChance >= (mode == nil and 1 or Menu.Prediction.HPrediction.Q) then
      CastSpell(_Q, Pos.x, Pos.z)
    end
  
  elseif Menu.Prediction.Choice == 3 and SPred then
    local CastPosition, HitChance, PredPos = SPred:Predict(unit, Q.range, Q.speed, Q.delay, Q.radius, true, myHero)
    if HitChance >= (mode == nil and 1 or Menu.Prediction.SPrediction.Q) then
      CastSpell(_Q, CastPosition.x, CastPosition.z)
    end
    
  elseif Menu.Prediction.Choice == 4 and FHPred then
   local CastPosition, hc, info = FHPrediction.GetPrediction("Q", unit)
    if hc > (mode == nil and 1 or Menu.Prediction.FHPrediction.Q) and CastPosition ~= nil and not info.collision then
      CastSpell(_Q, CastPosition.x, CastPosition.z)
    end
  
  elseif Menu.Prediction.Choice == 5 and KPred then
    local Pos, HitChance = KPred:GetPrediction(KPred.Presets["Ezreal"]["Q"], unit, myHero)
    if HitChance >= (mode == nil and 1 or Menu.Prediction.KPrediction.Q) then
      CastSpell(_Q, Pos.x, Pos.z)
    end

  elseif Menu.Prediction.Choice == 6 and DPred then
    local state,hitPos,perc = DPred:predict("Q",unit,myHero,SkillShot.TYPE.LINE,Q.speed,Q.range,Q.radius,Q.delay*1000,0,{Minions = true,Champions = true})
    if perc >= (mode == nil and 50 or Menu.Prediction.DPrediction.Q) then
      CastSpell(_Q, hitPos.x, hitPos.z)
    end
    
end

end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function CastW(unit, mode)

if unit.dead then return end  

if Menu.Prediction.Choice == 1 and VPred then
    local CastPosition, HitChance, Position = VPred:GetLineCastPosition(unit, W.delay, W.radius, W.range, W.speed, myHero, false)
    
    if HitChance >= (mode == nil and 1 or Menu.Prediction.VPrediction.W) then
      CastSpell(_W, CastPosition.x, CastPosition.z)
    end
  
  elseif Menu.Prediction.Choice == 2 and HPred then
    local Pos, HitChance = HPred:GetPredict(HPred.Presets["Ezreal"]["W"], unit, myHero)

    if HitChance >= (mode == nil and 1 or Menu.Prediction.HPrediction.W) then
      CastSpell(_W, Pos.x, Pos.z)
    end
  
  elseif Menu.Prediction.Choice == 3 and SPred then
    local CastPosition, HitChance, PredPos = SPred:Predict(unit, W.range, W.speed, W.delay, W.radius, false, myHero)
    if HitChance >= (mode == nil and 1 or Menu.Prediction.SPrediction.W) then
      CastSpell(_W, CastPosition.x, CastPosition.z)
    end
    
  elseif Menu.Prediction.Choice == 4 and FHPred then
   local CastPosition, hc, info = FHPrediction.GetPrediction("W", unit)
    if hc > (mode == nil and 1 or Menu.Prediction.FHPrediction.W) and CastPosition ~= nil then
      CastSpell(_W, CastPosition.x, CastPosition.z)
    end
  
  elseif Menu.Prediction.Choice == 5 and KPred then
    local Pos, HitChance = KPred:GetPrediction(KPred.Presets["Ezreal"]["W"], unit, myHero)
    if HitChance >= (mode == nil and 1 or Menu.Prediction.KPrediction.W) then
      CastSpell(_W, Pos.x, Pos.z)
    end

  elseif Menu.Prediction.Choice == 6 and DPred then
    local state,hitPos,perc = DPred:predict("W",unit,myHero,SkillShot.TYPE.LINE,W.speed,W.range,W.radius,W.delay*1000,0,{Minions = false,Champions = false})
    if perc >= (mode == nil and 50 or Menu.Prediction.DPrediction.W) then
      CastSpell(_W, hitPos.x, hitPos.z)
    end
    
end

end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function CastR(unit, mode)

if unit.dead then return end  

if Menu.Prediction.Choice == 1 and VPred then
    local CastPosition, HitChance, Position = VPred:GetLineCastPosition(unit, R.delay, R.width, R.range, R.speed, myHero, false)
    
    if HitChance >= (mode == nil and 1 or Menu.Prediction.VPrediction.R) then
      CastSpell(_R, CastPosition.x, CastPosition.z)
    end
  
  elseif Menu.Prediction.Choice == 2 and HPred then
    local Pos, HitChance = HPred:GetPredict(HPred.Presets["Ezreal"]["R"], unit, myHero)

    if HitChance >= (mode == nil and 1 or Menu.Prediction.HPrediction.R) then
      CastSpell(_R, Pos.x, Pos.z)
    end
  
  elseif Menu.Prediction.Choice == 3 and SPred then
    local CastPosition, HitChance, PredPos = SPred:Predict(unit, R.range, R.speed, R.delay, R.width, false, myHero)
    if HitChance >= (mode == nil and 1 or Menu.Prediction.SPrediction.R) then
      CastSpell(_R, CastPosition.x, CastPosition.z)
    end
    
  elseif Menu.Prediction.Choice == 4 and FHPred then
   local CastPosition, hc, info = FHPrediction.GetPrediction("R", unit)
    if hc > (mode == nil and 1 or Menu.Prediction.FHPrediction.R) and CastPosition ~= nil then
      CastSpell(_R, CastPosition.x, CastPosition.z)
    end
  
  elseif Menu.Prediction.Choice == 5 and KPred then
    local Pos, HitChance = KPred:GetPrediction(KPred.Presets["Ezreal"]["R"], unit, myHero)
    if HitChance >= (mode == nil and 1 or Menu.Prediction.KPrediction.R) then
      CastSpell(_R, Pos.x, Pos.z)
    end

  elseif Menu.Prediction.Choice == 6 and DPred then
    local state,hitPos,perc = DPred:predict("R",unit,myHero,SkillShot.TYPE.LINE,R.speed,R.range,R.width,R.delay*1000,0,{Minions = true,Champions = true})
    if perc >= (mode == nil and 50 or Menu.Prediction.DPrediction.R) then
      CastSpell(_R, hitPos.x, hitPos.z)
    end
    
end

end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function MoveToMouse()

  if mousePos and GetDistance(mousePos) <= 100 then
    MousePos = myHero+(Vector(mousePos)-myHero):normalized()*300
  else
    MousePos = mousePos
  end

  myHero:MoveTo(MousePos.x, MousePos.z)
  CastSpell(_E, MousePos.x, MousePos.z)

  for i, enemy in ipairs(EnemyHeroes) do
  
  if ValidTarget(enemy, Q.range+100) then
  CastQ(enemy, "MoveToMouse")
end
end
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

--[[function DebugDraw()
if myHero.dead then
  return
end

if Menu.Draw.On then

if QTarget ~= nil then
    DrawCircle(QTarget.x, QTarget.y, QTarget.z, Q.radius, ARGB(0xFF, 0xFF, 0xFF, 0xFF))
  end
  
  if RTarget ~= nil then
    DrawCircle(RTarget.x, RTarget.y, RTarget.z, R.width/2, ARGB(0xFF, 0xFF, 0xFF, 0xFF))
  end
  
  if QHitChance ~= nil then
  
    if QHitChance < 1 then
      Qcolor = ARGB(0xFF, 0xFF, 0x00, 0x00)
    elseif QHitChance == 3 then
      Qcolor = ARGB(0xFF, 0x00, 0x54, 0xFF)
    elseif QHitChance >= 2 then
      Qcolor = ARGB(0xFF, 0x1D, 0xDB, 0x16)
    elseif QHitChance >= 1 then
      Qcolor = ARGB(0xFF, 0xFF, 0xE4, 0x00)
    end
  
  end
  end
  if RHitChance ~= nil then
  
    if RHitChance == -1 then
      Rcolor = ARGB(0xFF, 0x00, 0x00, 0x00)
    elseif RHitChance < 1 then
      Rcolor = ARGB(0xFF, 0xFF, 0x00, 0x00)
    elseif RHitChance == 3 then
      Rcolor = ARGB(0xFF, 0x00, 0x54, 0xFF)
    elseif RHitChance >= 2 then
      Rcolor = ARGB(0xFF, 0x1D, 0xDB, 0x16)
    elseif RHitChance >= 1 then
      Rcolor = ARGB(0xFF, 0xFF, 0xE4, 0x00)
    end
    
  end
  
  if Menu.Draw.Prd then
    
  if QPos ~= nil then
  
    DrawCircle(QPos.x, QPos.y, QPos.z, Q.radius, Qcolor)
    DrawLine3D(myHero.x, myHero.y, myHero.z, QPos.x, QPos.y, QPos.z, 2, Qcolor)
    QPos = nil
  
  elseif RPos ~= nil then
    DrawCircle(RPos.x, RPos.y, RPos.z, R.width/2, Rcolor)
    DrawLine3D(myHero.x, myHero.y, myHero.z, RPos.x, RPos.y, RPos.z, 2, Rcolor)
    RPos = nil
  end
  end
  
    if QHitChance ~= nil then
      DrawText("Q HitChance: "..QHitChance, 20, 1250, 550, Qcolor)
      QHitChance = nil
    end
    
    if RHitChance ~= nil then
      DrawText("R HitChance: "..RHitChance, 20, 1250, 600, Rcolor)
      RHitChance = nil
    end
    
    if Menu.Draw.ownp then
    
    if myHero.hasMovePath and myHero.pathCount >= 2 then
    
      local IndexPath = myHero:GetPath(myHero.pathIndex)
      
      if IndexPath then
        DrawLine3D(myHero.x, myHero.y, myHero.z, IndexPath.x, IndexPath.y, IndexPath.z, 1, ARGB(114, 114, 4, 34))
      end
      
      for i=myHero.pathIndex, myHero.pathCount-1 do
      
        local Path = myHero:GetPath(i)
        local Path2 = myHero:GetPath(i+1)
        
        DrawLine3D(Path.x, Path.y, Path.z, Path2.x, Path2.y, Path2.z, 1, ARGB(114, 114, 4, 34))
      end
      
    end
    
    if Menu.Draw.opp then
    
    for i, enemy in ipairs(EnemyHeroes) do
    
      if enemy == nil then
        return
      end
      
      if enemy.hasMovePath and enemy.pathCount >= 2 then
      
        local IndexPath = enemy:GetPath(enemy.pathIndex)
        
        if IndexPath then
          DrawLine3D(enemy.x, enemy.y, enemy.z, IndexPath.x, IndexPath.y, IndexPath.z, 1, ARGB(255, 255, 255, 255))
        end
        
        for i=enemy.pathIndex, enemy.pathCount-1 do
        
          local Path = enemy:GetPath(i)
          local Path2 = enemy:GetPath(i+1)
          
          DrawLine3D(Path.x, Path.y, Path.z, Path2.x, Path2.y, Path2.z, 1, ARGB(255, 255, 255, 255))
          
          print(FocusJungleNames)
          print(Q.range)
          print(R.range)
        end
        
      end
      
    end
    
  end
  
end

end]]--

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function OnAnimation(unit, animation)

  if not unit.isMe then
    return
  end
  
  if animation == "recall" then
    IsRecall = true
  elseif animation == "recall_winddown" or animation == "Run" or animation == "Spell1" or animation == "Spell2" or animation == "Spell3" or animation == "Spell4" then
    IsRecall = false
  end
  
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function DrawDamage(unit)

  local SPos, EPos = GetHealthPos(unit)
  local PercentDamage = math.min(unit.health/unit.maxHealth, ComboDamage(unit)/unit.maxHealth)
  local DPos = Point(EPos.x-104*PercentDamage, SPos.y)
  
  if (ComboDamage(unit) > unit.health) then
    DrawText("OverKill: " .. math.floor(ComboDamage(unit)-unit.health), 20, SPos.x, SPos.y-55, ARGB(0xFF, 0xFF, 0xFF, 0xFF))
  end
  
  if R.ready then
   
    local RUnitDmg = GetDmg("R", unit) or 0
    local RPercentDamage = math.min(unit.health/unit.maxHealth, RUnitDmg/unit.maxHealth)
    local RPos = Point(DPos.x+104*RPercentDamage, EPos.y)
    
    DrawLine(RPos.x, RPos.y, EPos.x, EPos.y, 11, 0x78FF7D00 or 0x78FFFFFF)
    DrawLine(DPos.x, DPos.y, RPos.x, RPos.y, 11, 0x78FF7D00 or 0x78FFFFFF)
  else
    DrawLine(DPos.x, DPos.y, EPos.x, EPos.y, 11, 0x78FF7D00 or 0x78FFFFFF)
  end
  
end

function GetHealthPos(unit)

  local Pos = GetUnitHPBarPos(unit)
  local PosOffset = GetUnitHPBarOffset(unit)
  
  Pos.x = Pos.x-66
  
  if unit.charName == "Darius" then
    Pos.x = Pos.x-7
  end
  
  Pos.y = Pos.y+61*PosOffset.y+6
  
  return Point(Pos.x, Pos.y), Point(Pos.x+104*(unit.health/unit.maxHealth), Pos.y)
end

function ComboDamage(unit)

  local AA_UnitDmg = GetDmg("AA", unit) or 0
  local Q_UnitDmg = Q.ready and GetDmg("Q", unit) or 0
  local W_UnitDmg = W.ready and GetDmg("W", unit) or 0
  local R_UnitDmg = R.ready and GetDmg("R", unit) or 0
  
  return AA_UnitDmg+Q_UnitDmg+W_UnitDmg+R_UnitDmg
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
function DrawRectangleButton(x, y, w, h, color)
local floor = math.floor
local points = {}
points[1] = D3DXVECTOR2(floor(x), floor(y))
points[2] = D3DXVECTOR2(floor(x + w), floor(y))
local points2 = {}
points2[1] = D3DXVECTOR2(floor(x), floor(y - h/2))
points2[2] = D3DXVECTOR2(floor(x + w), floor(y - h/2))
points2[3] = D3DXVECTOR2(floor(x + w), floor(y + h/2))
points2[4] = D3DXVECTOR2(floor(x), floor(y + h/2))
local t = GetCursorPos()
polygon = Polygon(Point(points2[1].x, points2[1].y), Point(points2[2].x, points2[2].y), Point(points2[3].x, points2[3].y), Point(points2[4].x, points2[4].y))
if polygon:contains(Point(t.x, t.y)) then
DrawLines2(points, floor(h), color)
else
DrawLines2(points, floor(h), ARGB(255, 49, 112, 131))
end
end

function OnDraw()
  if not Loaded then
    return
  end

  if Menu.Draw.CLFPS then return
    OnDrawFPS()
  end

  if not Menu.Draw.On or myHero.dead then
    return
  end
  
  if Menu.Draw.ComboDamage then
    for i, hero in ipairs(GetEnemyHeroes()) do
      if ValidTarget(hero, 2000) then
      DrawDamage(hero)
      end
    end
  end

   if Menu.Control.OnJS and R.ready and not Menu.Control.tmpdisable then
    local myPos = WorldToScreen(D3DXVECTOR3(myHero.x, myHero.y, myHero.z))
    DrawText("Junglesteal R is Enabled!", 30, myPos.x, myPos.y, ARGB(0xFF, 0xFF, 0xFF, 0xFF))
  end

   if Menu.Control.OnJST and Menu.Control.tmpdisable and Q.ready then
    local myPos = WorldToScreen(D3DXVECTOR3(myHero.x, myHero.y, myHero.z))
    DrawText("Junglesteal Toggle Disabled!", 30, myPos.x, myPos.y, ARGB(0xFF, 0xFF, 0xFF, 0xFF))
  end

  if Menu.Draw.ownp then
    
    if myHero.hasMovePath and myHero.pathCount >= 1 then
    
      local IndexPath = myHero:GetPath(myHero.pathIndex)
      
      if IndexPath then
        DrawLine3D(myHero.x, myHero.y, myHero.z, IndexPath.x, IndexPath.y, IndexPath.z, 1, ARGB(255, 152, 130, 147))
      end
      
      for i=myHero.pathIndex, myHero.pathCount-1 do
      
        local Path = myHero:GetPath(i)
        local Path2 = myHero:GetPath(i+1)
        
        DrawLine3D(Path.x, Path.y, Path.z, Path2.x, Path2.y, Path2.z, 1, ARGB(255, 152, 130, 147))
      end
      
    end
  
  if Menu.Draw.opp then
    
    for i, enemy in ipairs(EnemyHeroes) do
    
      if enemy == nil then
        return
      end
      
      if enemy.hasMovePath and enemy.pathCount >= 1 then
      
        local IndexPath = enemy:GetPath(enemy.pathIndex)
        
        if IndexPath then
          DrawLine3D(enemy.x, enemy.y, enemy.z, IndexPath.x, IndexPath.y, IndexPath.z, 1, ARGB(255, 255, 255, 255))
        end
        
        for i=enemy.pathIndex, enemy.pathCount-1 do
        
          local Path = enemy:GetPath(i)
          local Path2 = enemy:GetPath(i+1)
          
          DrawLine3D(Path.x, Path.y, Path.z, Path2.x, Path2.y, Path2.z, 1, ARGB(255, 255, 255, 255))
          
        end
        
      end
      
    end
    
  end
  
  end

  if PopUp then
              local w, h1, h2 = (WINDOW_W*0.50), (WINDOW_H*.15), (WINDOW_H*.9)
              DrawLine(w, h1/1.05, w, h2/1.97, w/1.75, ARGB(80, 0, 0, 0)) -- border & aero
              DrawLine(w, h1, w, h2/2, w/1.8, ARGB(255, 22, 12, 0)) -- background
              DrawTextA(tostring("Welcome to Uneeesh Series - Ezreal"), WINDOW_H*.028, (WINDOW_W/2), (WINDOW_H*.18), ARGB(255, 0, 222, 225),"center","center")
              DrawTextA(tostring("Latest Changelog (" .. Version .. ") ;"), WINDOW_H*.015, (WINDOW_W/2.65), (WINDOW_H*.210), ARGB(255, 0, 222, 225))
              DrawTextA(tostring(" "), WINDOW_H*.015, (WINDOW_W/2.65), (WINDOW_H*.210), ARGB(255, 255, 255, 255))
              DrawTextA(tostring(" "), WINDOW_H*.015, (WINDOW_W/2.65), (WINDOW_H*.225), ARGB(255, 255, 255, 255))
              DrawTextA(tostring("- Re-Enabled SAC:Reborn."), WINDOW_H*.015, (WINDOW_W/2.70), (WINDOW_H*.240), ARGB(255, 0, 222, 225))
              DrawTextA(tostring(""), WINDOW_H*.015, (WINDOW_W/2.70), (WINDOW_H*.260), ARGB(255, 0, 222, 225))
              DrawTextA(tostring(""), WINDOW_H*.015, (WINDOW_W/2.70), (WINDOW_H*.280), ARGB(255, 0, 222, 225))
              local w, h1, h2 = (WINDOW_W*0.49), (WINDOW_H*.70), (WINDOW_H*.75)
              DrawLine(w, h1/1.775, w, h2/1.68, w*.11, ARGB(255, 0, 0, 0))
              DrawRectangleButton(WINDOW_W*0.467, WINDOW_H/2.375, WINDOW_W*.047, WINDOW_H*.041, ARGB(255, 255, 0, 0))
              DrawTextA(tostring("OK"), WINDOW_H*.02, (WINDOW_W/2)*.98, (WINDOW_H/2.375), ARGB(255, 0, 222, 225),"center","center")
              DrawTextA(tostring("                                                                                                      IZSHA"), WINDOW_H*.015, (WINDOW_W/2.65), (WINDOW_H*.355), ARGB(255, 0, 222, 225))
  end
  
  if Menu.Draw.Trg then
    if QTarget ~= nil then
    DrawCircle(QTarget.x, QTarget.y, QTarget.z, Q.radius, 0x78FF7D00 or 0x78FFFFFF)
  elseif RTarget ~= nil then
    DrawCircle(RTarget.x, RTarget.y, RTarget.z, R.width, 0x78FF7D00 or 0x78FFFFFF)
    end
  end
  
  --[[if Menu.Draw.Prd and Menu.Predictions.Prediction == 2 then
  if QPos ~= nil then
    DrawCircle(QPos.x, QPos.y, QPos.z, Q.radius, ARGB(0xFF, 0x1D, 0xDB, 0x16))
    DrawLine3D(myHero.x, myHero.y, myHero.z, QPos.x, QPos.y, QPos.z, 2, ARGB(0xFF, 0x1D, 0xDB, 0x16))
    QPos = nil
  elseif RPos ~= nil then
    DrawCircle(RPos.x, RPos.y, RPos.z, R.width/2, 0xFF, 0x1D, 0xDB, 0x16)
    DrawLine3D(myHero.x, myHero.y, myHero.z, RPos.x, RPos.y, RPos.z, 2, ARGB(0xFF, 0x1D, 0xDB, 0x16))
    RPos = nil
  end
end]]--

  if Menu.Draw.AA then
    DrawCircle(myHero.x, myHero.y, myHero.z, myHero.range+myHero.boundingRadius+10, RGB(Menu.Draw.CLA[2], Menu.Draw.CLA[3], Menu.Draw.CLA[4]))
  end
  
  if Menu.Draw.Q and Q.ready then
    DrawCircle(myHero.x, myHero.y, myHero.z, Q.range-30, RGB(Menu.Draw.CLQ[2], Menu.Draw.CLQ[3], Menu.Draw.CLQ[4]))
  end
  
  if Menu.Draw.W and W.ready then
    DrawCircle(myHero.x, myHero.y, myHero.z, W.range+120, RGB(Menu.Draw.CLW[2], Menu.Draw.CLW[3], Menu.Draw.CLW[4]))
  end

  if Menu.Draw.E and E.ready then
    DrawCircle(myHero.x, myHero.y, myHero.z, E.range+20, RGB(Menu.Draw.CLE[2], Menu.Draw.CLE[3], Menu.Draw.CLE[4]))
  end
  
  if ignite and Menu.Draw.I and I.ready then
    DrawCircle(myHero.x, myHero.y, myHero.z, I.range, RGB(Menu.Draw.CLI[2], Menu.Draw.CLI[3], Menu.Draw.CLI[4]))
  end
end

---------------------------------------------------------------------------------

function OnDrawFPS()
  if not Loaded then
    return
  end

  if not Menu.Draw.On or myHero.dead then
    return
  end
  
  if Menu.Draw.ComboDamage then
    for i, hero in ipairs(GetEnemyHeroes()) do
      if ValidTarget(hero, 2000) then
      DrawDamage(hero)
      end
    end
  end

  if Menu.Control.OnJS and R.ready then
    local myPos = WorldToScreen(D3DXVECTOR3(myHero.x, myHero.y, myHero.z))
    DrawText("Junglesteal R is Enabled", 30, myPos.x, myPos.y, ARGB(0xFF, 0xFF, 0xFF, 0xFF))
  end

  if Menu.Control.OnJST and Menu.Control.tmpdisable and Q.ready then
    local myPos = WorldToScreen(D3DXVECTOR3(myHero.x, myHero.y, myHero.z))
    DrawText("Junglesteal Toggle Disabled!", 30, myPos.x, myPos.y, ARGB(0xFF, 0xFF, 0xFF, 0xFF))
  end

  if PopUp then
              local w, h1, h2 = (WINDOW_W*0.50), (WINDOW_H*.15), (WINDOW_H*.9)
              DrawLine(w, h1/1.05, w, h2/1.97, w/1.75, ARGB(80, 0, 0, 0)) -- border & aero
              DrawLine(w, h1, w, h2/2, w/1.8, ARGB(255, 22, 12, 0)) -- background
              DrawTextA(tostring("Welcome to Uneeesh Series - Ezreal"), WINDOW_H*.028, (WINDOW_W/2), (WINDOW_H*.18), ARGB(255, 0, 222, 225),"center","center")
              DrawTextA(tostring("Latest Changelog (" .. Version .. ") ;"), WINDOW_H*.015, (WINDOW_W/2.65), (WINDOW_H*.210), ARGB(255, 0, 222, 225))
              DrawTextA(tostring(" "), WINDOW_H*.015, (WINDOW_W/2.65), (WINDOW_H*.210), ARGB(255, 255, 255, 255))
              DrawTextA(tostring(" "), WINDOW_H*.015, (WINDOW_W/2.65), (WINDOW_H*.225), ARGB(255, 255, 255, 255))
              DrawTextA(tostring("- Re-Enabled SAC:Reborn."), WINDOW_H*.015, (WINDOW_W/2.70), (WINDOW_H*.240), ARGB(255, 0, 222, 225))
              DrawTextA(tostring(""), WINDOW_H*.015, (WINDOW_W/2.70), (WINDOW_H*.260), ARGB(255, 0, 222, 225))
              DrawTextA(tostring(""), WINDOW_H*.015, (WINDOW_W/2.70), (WINDOW_H*.280), ARGB(255, 0, 222, 225))
              local w, h1, h2 = (WINDOW_W*0.49), (WINDOW_H*.70), (WINDOW_H*.75)
              DrawLine(w, h1/1.775, w, h2/1.68, w*.11, ARGB(255, 0, 0, 0))
              DrawRectangleButton(WINDOW_W*0.467, WINDOW_H/2.375, WINDOW_W*.047, WINDOW_H*.041, ARGB(255, 255, 0, 0))
              DrawTextA(tostring("OK"), WINDOW_H*.02, (WINDOW_W/2)*.98, (WINDOW_H/2.375), ARGB(255, 0, 222, 225),"center","center")
              DrawTextA(tostring("                                                                                                      IZSHA"), WINDOW_H*.015, (WINDOW_W/2.65), (WINDOW_H*.355), ARGB(255, 0, 222, 225))
  end

  if Menu.Draw.ownp then
    
    if myHero.hasMovePath and myHero.pathCount >= 2 then
    
      local IndexPath = myHero:GetPath(myHero.pathIndex)
      
      if IndexPath then
        DrawLine3D(myHero.x, myHero.y, myHero.z, IndexPath.x, IndexPath.y, IndexPath.z, 1, ARGB(255, 152, 130, 147))
      end
      
      for i=myHero.pathIndex, myHero.pathCount-1 do
      
        local Path = myHero:GetPath(i)
        local Path2 = myHero:GetPath(i+1)
        
        DrawLine3D(Path.x, Path.y, Path.z, Path2.x, Path2.y, Path2.z, 1, ARGB(255, 152, 130, 147))
      end
      
    end
  
  if Menu.Draw.opp then
    
    for i, enemy in ipairs(EnemyHeroes) do
    
      if enemy == nil then
        return
      end
      
      if enemy.hasMovePath and enemy.pathCount >= 2 then
      
        local IndexPath = enemy:GetPath(enemy.pathIndex)
        
        if IndexPath then
          DrawLine3D(enemy.x, enemy.y, enemy.z, IndexPath.x, IndexPath.y, IndexPath.z, 1, ARGB(255, 255, 255, 255))
        end
        
        for i=enemy.pathIndex, enemy.pathCount-1 do
        
          local Path = enemy:GetPath(i)
          local Path2 = enemy:GetPath(i+1)
          
          DrawLine3D(Path.x, Path.y, Path.z, Path2.x, Path2.y, Path2.z, 1, ARGB(255, 255, 255, 255))
          
        end
        
      end
      
    end
    
  end
  
  end
  
  if Menu.Draw.Trg then
    if QTarget ~= nil then
    CircleDraw(QTarget.x, QTarget.y, QTarget.z, Q.radius, 0x78FF7D00 or 0x78FFFFFF)
  elseif RTarget ~= nil then
    CircleDraw(RTarget.x, RTarget.y, RTarget.z, R.width, 0x78FF7D00 or 0x78FFFFFF)
    end
  end
  
  --[[if Menu.Draw.Prd and Menu.Predictions.Prediction == 2 then
  if QPos ~= nil then
    CircleDraw(QPos.x, QPos.y, QPos.z, Q.radius, ARGB(0xFF, 0x1D, 0xDB, 0x16))
    DrawLine3D(myHero.x, myHero.y, myHero.z, QPos.x, QPos.y, QPos.z, 2, ARGB(0xFF, 0x1D, 0xDB, 0x16))
    QPos = nil
  elseif RPos ~= nil then
    CircleDraw(RPos.x, RPos.y, RPos.z, R.width/2, 0xFF, 0x1D, 0xDB, 0x16)
    DrawLine3D(myHero.x, myHero.y, myHero.z, RPos.x, RPos.y, RPos.z, 2, ARGB(0xFF, 0x1D, 0xDB, 0x16))
    RPos = nil
  end
end]]--
  
  if Menu.Draw.AA then
      CircleDraw(myHero.x, myHero.y, myHero.z, myHero.range+60+myHero.boundingRadius, ARGB(Menu.Draw.CLA[1], Menu.Draw.CLA[2],Menu.Draw.CLA[3],Menu.Draw.CLA[4]))
    end
  
  if Menu.Draw.CLFPS and Menu.Draw.Q and Q.ready then
      CircleDraw(myHero.x, myHero.y, myHero.z, Q.range+60, ARGB(Menu.Draw.CLQ[1], Menu.Draw.CLQ[2],Menu.Draw.CLQ[3],Menu.Draw.CLQ[4]))
    end

  if Menu.Draw.CLFPS and Menu.Draw.W and W.ready then
      CircleDraw(myHero.x, myHero.y, myHero.z, W.range+190, ARGB(Menu.Draw.CLW[1], Menu.Draw.CLW[2],Menu.Draw.CLW[3],Menu.Draw.CLW[4]))
    end

  if Menu.Draw.CLFPS and Menu.Draw.E and E.ready then
      CircleDraw(myHero.x, myHero.y, myHero.z, E.range+70, ARGB(Menu.Draw.CLE[1], Menu.Draw.CLE[2],Menu.Draw.CLE[3],Menu.Draw.CLE[4]))
    end
  
  if ignite and Menu.Draw.I and I.ready then
    CircleDraw(myHero.x, myHero.y, myHero.z, I.range, ARGB(Menu.Draw.CLI[1], Menu.Draw.CLI[2],Menu.Draw.CLI[3],Menu.Draw.CLI[4]))
   end
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
    radius = radius or 300
    quality = math.max(8,math.floor(180/math.deg((math.asin((chordlength/(2*radius)))))))
    quality = 2 * math.pi / quality
    radius = radius*.92
    local points = {}
    for theta = 0, 2 * math.pi + quality, quality do
        local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
        points[#points + 1] = D3DXVECTOR2(c.x, c.y)
    end
    DrawLines2(points, width or 1, color or 4294967295)
end

function DrawCircle2(x, y, z, radius, color)
    local vPos1 = Vector(x, y, z)
    local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
    local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
    local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
    if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y })  then
    DrawCircleNextLvl(x, y, z, radius, 2, color, Menu.Draw.Quality)
    end
end

function CircleDraw(x,y,z,radius, color)
  DrawCircle2(x, y, z, radius, color)
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
  
function SkinLoad()
    Menu.Autom.ChgSki:addParam("upski", "Change Skin", SCRIPT_PARAM_ONOFF, false);
    Menu.Autom.ChgSki:setCallback("upski", function(nV)
        if (nV) then
            SetSkin(myHero, Menu.Autom.ChgSki.skinID)
        else
            SetSkin(myHero, -1)
        end
    end)
    Menu.Autom.ChgSki:addParam('skinID', 'Skin', SCRIPT_PARAM_LIST, 1, {"Nottingham", "Striker", "Frosted", "Explorer", "Pulsefire", "TPA", "Debonair", "Ace of Spades", "Classic"})
    Menu.Autom.ChgSki:setCallback('skinID', function(nV)
        if (Menu.Autom.ChgSki.upski) then
            SetSkin(myHero, nV)
        end
    end)
    
    if (Menu.Autom.ChgSki.upski) then
        SetSkin(myHero, Menu.Autom.ChgSki.skinID)
    end
end

function AutoBuy()
  
  if GetGameTimer() < 60 then
    if Menu.Autom.buyme.buydoran then
      BuyItem(1055)
    end
    if Menu.Autom.buyme.buypot then
      BuyItem(2003)
    end
    if Menu.Autom.buyme.taketrinket then
      BuyItem(3340)
    end
  end
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function CheckLevelChange()
    if LastLevelCheck + 250 < GetTickCount() and myHero.level < 19 then
        if GetGame().map.index == 8 and myHero.level < 4 and Menu.Autom.autolevel.UseAutoLevelFirst then
            LevelSpell(_Q)
            LevelSpell(_W)
            LevelSpell(_E)
        end

        LastLevelCheck = GetTickCount()
        if myHero.level ~= LastHeroLevel then
            DelayAction(function() LevelUpSpell() end, 0.25)
            LastHeroLevel = myHero.level
        end
    end
end

function LevelUpSpell()
    if Menu.Autom.autolevel.UseAutoLevelFirst and myHero.level < 4 then
        LevelSpell(AutoLevelSpellTable[AutoLevelSpellTable["SpellOrder"][Menu.Autom.autolevel.First3Level]][myHero.level])
    end

    if Menu.Autom.autolevel.UseAutoLevelRest and myHero.level > 3 then
        LevelSpell(AutoLevelSpellTable[AutoLevelSpellTable["SpellOrder"][Menu.Autom.autolevel.RestLevel]][myHero.level])
    end
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function OnBush()

local WardSlot = nil
  if GetInventorySlotItem(2045) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(2045)) == READY then
    WardSlot = GetInventorySlotItem(2045)
  elseif GetInventorySlotItem(2049) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(2049)) == READY then
    WardSlot = GetInventorySlotItem(2049)
  elseif GetInventorySlotItem(3340) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(3340)) == READY or 
  GetInventorySlotItem(3350) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(3350)) == READY or 
  GetInventorySlotItem(3361) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(3361)) == READY or 
  GetInventorySlotItem(3363) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(3363)) == READY or
  GetInventorySlotItem(3411) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(3411)) == READY or
  GetInventorySlotItem(3342) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(3342)) == READY or
  GetInventorySlotItem(3362) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(3362)) == READY  then
    WardSlot = 12
  elseif GetInventorySlotItem(2044) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(2044)) == READY then
    WardSlot = GetInventorySlotItem(2044)
  elseif GetInventorySlotItem(2043) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(2043)) == READY then
    WardSlot = GetInventorySlotItem(2043)
  end

  return WardSlot
end

function FindBush(x0, y0, z0, maxRadius, precision)

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

function Bushfind()
  if lastTime +15 > os.clock() then return end
  for _,c in pairs(GetEnemyHeroes()) do   
    if not c.dead and not c.visible then
      local time=lasttime[ c.networkID ]  --last seen time
      local pos=lastpos [ c.networkID ]   --last seen pos
      local clock=os.clock()
      
      if time and pos and clock-time < 5 and GetDistanceSqr(pos)< 1005000 then
        local FoundBush = FindBush(pos.x,pos.y,pos.z,100)
    
        if FoundBush and GetDistanceSqr(FoundBush)<600*600 then
          local WardSlot = OnBush()
          
          if WardSlot then
            CastSpell(WardSlot,FoundBush.x,FoundBush.z)
            lastTime = os.clock()
            return
          end
        end
      end
    end
  end
end
end


---------------------------------------------------------------------------------==============================================================================================================================
---------------------------------------------------------------------------------==============================================================================================================================
---------------------------------------------------------------------------------==============================================================================================================================


if myHero.charName == Hero[4] then

function ScriptMsg(msg)
  print("<font color=\"#FF1493\">[Uneeesh Series - Caitlyn]</b></font>  <font color=\"#FFFF00\">".. msg .."</font>")
end

function ErrorMsg(msg)
  print("<font color=\"#FF1493\">[Uneeesh Series - Caitlyn]</b></font>  <font color=\"#FF0000\">".. msg .."</font>")
end

local Q, W, E, R, I = {}, {}, {}, {}, {}
local Loaded = false
local DPExist = FileExist(LIB_PATH.."DivinePred.lua") and FileExist(LIB_PATH.."DivinePred.luac")
local lasttime = {}
local lastTime = 0
local LastLevelCheck = 0
local lastpos = {}
local lastRemove = 0
local Aim
local function Slot(name)
  if myHero:GetSpellData(SUMMONER_1).name:lower():find(name) then
    return SUMMONER_1
  elseif myHero:GetSpellData(SUMMONER_2).name:lower():find(name) then
    return SUMMONER_2
  end
end
local function dChat()
  chat1B = _G.print
  chat2B = _G.PrintChat
  _G.print = function() end
  _G.PrintChat = function() end
  DisableOverlay()
  ChatOff = true
end
local function eChat()
  _G.print = chat1B
  _G.PrintChat = chat2B
  EnableOverlay()
  ChatOff = false
end

if FileExist(LIB_PATH .. "VPrediction.lua") then
  require("VPrediction")
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function OnLoad()
  
  ItemNames       = {
    [3303]        = "ArchAngelsDummySpell",
    [3007]        = "ArchAngelsDummySpell",
    [3144]        = "BilgewaterCutlass",
    [3188]        = "ItemBlackfireTorch",
    [3153]        = "ItemSwordOfFeastAndFamine",
    [3405]        = "TrinketSweeperLvl1",
    [3411]        = "TrinketOrbLvl1",
    [3166]        = "TrinketTotemLvl1",
    [3450]        = "OdinTrinketRevive",
    [2054]        = "ItemKingPoroSnack",
    [2138]        = "ElixirOfIron",
    [2137]        = "ElixirOfRuin",
    [2139]        = "ElixirOfSorcery",
    [2140]        = "ElixirOfWrath",
    [3184]        = "OdinEntropicClaymore",
    [2050]        = "ItemMiniWard",
    [3401]        = "HealthBomb",
    [3363]        = "TrinketOrbLvl3",
    [3092]        = "ItemGlacialSpikeCast",
    [3460]        = "AscWarp",
    [3361]        = "TrinketTotemLvl3",
    [3362]        = "TrinketTotemLvl4",
    [3159]        = "HextechSweeper",
    [2051]        = "ItemHorn",
    [3146]        = "HextechGunblade",
    [3187]        = "HextechSweeper",
    [3190]        = "IronStylus",
    [3139]        = "ItemMercurial",
    [3222]        = "ItemMorellosBane",
    [3042]        = "Muramana",
    [3043]        = "Muramana",
    [3180]        = "OdynsVeil",
    [3056]        = "ItemFaithShaker",
    [2047]        = "OracleExtractSight",
    [3364]        = "TrinketSweeperLvl3",
    [2052]        = "ItemPoroSnack",
    [3140]        = "QuicksilverSash",
    [3143]        = "RanduinsOmen",
    [3074]        = "ItemTiamatCleave",
    [5000]        = "ItemTitanicHydraCleave",
    [3800]        = "ItemRighteousGlory",
    [2045]        = "ItemGhostWard",
    [3342]        = "TrinketOrbLvl1",
    [3040]        = "ItemSeraphsEmbrace",
    [3048]        = "ItemSeraphsEmbrace",
    [2049]        = "ItemGhostWard",
    [3345]        = "OdinTrinketRevive",
    [2044]        = "SightWard",
    [3341]        = "TrinketSweeperLvl1",
    [3069]        = "shurelyascrest",
    [3599]        = "KalistaPSpellCast",
    [3185]        = "HextechSweeper",
    [3077]        = "ItemTiamatCleave",
    [2009]        = "ItemMiniRegenPotion",
    [2010]        = "ItemMiniRegenPotion",
    [3023]        = "ItemWraithCollar",
    [3290]        = "ItemWraithCollar",
    [2043]        = "VisionWard",
    [3340]        = "TrinketTotemLvl1",
    [3090]        = "ZhonyasHourglass",
    [3154]        = "wrigglelantern",
    [3142]        = "YoumusBlade",
    [3157]        = "ZhonyasHourglass",
    [3512]        = "ItemVoidGate",
    [3131]        = "ItemSoTD",
    [3137]        = "ItemDervishBlade",
    [3352]        = "RelicSpotter",
    [3350]        = "TrinketTotemLvl2",
    [3085]        = "AtmasImpalerDummySpell",
  }

  Items = {
    ["ELIXIR"]      = { id = 2140, range = 2140, target = false},
    ["QSS"]         = { id = 3140, range = 2500, target = false},
    ["MercScim"]  = { id = 3139, range = 2500, target = false},
    ["BRK"]     = { id = 3153, range = 550, target = true},
    ["BWC"]     = { id = 3144, range = 550, target = true},
    ["HXG"]     = { id = 3146, range = 700, target = false},
    ["ODYNVEIL"]  = { id = 3180, range = 525, target = false},
    ["DVN"]     = { id = 3131, range = 200, target = false},
    ["ENT"]     = { id = 3184, range = 350, target = false},
    ["HYDRA"]   = { id = 3074, range = 350, target = false},
    ["TIAMAT"]    = { id = 3077, range = 350, target = false},
    ["TITANIC"]   = { id = 5000, range = 350, target = false},
    ["RanduinsOmen"]  = { id = 3143, range = 500, target = false},
    ["YGB"]     = { id = 3142, range = 600, target = false},
    ["HEX"]     = { id = 5555, range = 600, target = false},
  }

  AutoLevelSpellTable = {
        ['SpellOrder']  = {'QWE', 'QEW', 'WQE', 'WEQ', 'EQW', 'EWQ'},
        ['QWE'] = {_Q,_W,_E,_Q,_Q,_R,_Q,_W,_Q,_W,_R,_W,_W,_E,_E,_R,_E,_E},
        ['QEW'] = {_Q,_E,_W,_Q,_Q,_R,_Q,_E,_Q,_E,_R,_E,_E,_W,_W,_R,_W,_W},
        ['WQE'] = {_W,_Q,_E,_W,_W,_R,_W,_Q,_W,_Q,_R,_Q,_Q,_E,_E,_R,_E,_E},
        ['WEQ'] = {_W,_E,_Q,_W,_W,_R,_W,_E,_W,_E,_R,_E,_E,_Q,_Q,_R,_Q,_Q},
        ['EQW'] = {_E,_Q,_W,_E,_E,_R,_E,_Q,_E,_Q,_R,_Q,_Q,_W,_W,_R,_W,_W},
        ['EWQ'] = {_E,_W,_Q,_E,_E,_R,_E,_W,_E,_W,_R,_W,_W,_Q,_Q,_R,_Q,_Q}
    }

  ___GetInventorySlotItem = rawget(_G, "GetInventorySlotItem")
  _G.GetInventorySlotItem = GetSlotItem
  if myHero:GetSpellData(4).name:lower():find("exhaust") then
    exhaust = { slot = 4, key = "D", range =  650, ready = false }
  elseif myHero:GetSpellData(5).name:lower():find("exhaust") then
    exhaust = { slot = 5, key = "F", range =  650, ready = false }
  end
  SummonerSlot = Slot("summonerboost")
  ignite = Slot("summonerdot")
  heal = HealSlot()
  Update()
  Variables()
  CaitlynMenu()
  SkinLoad()
  DelayAction(function()LoadOrbwalk() end, 1)
  DelayAction(function()AutoBuy()end, 3)
  Loaded = true
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function Variables()

  SACLoaded, PEWLoaded, MMALoaded, SxOrbLoaded = false, false, false, false
  
  Q = {range = 1199, radius = 0, speed = 2200, delay = 0.625}
  W = {range = 999, width = 30, speed = 2000, delay = 0.600}
  E = {range = 900, width = 80, speed = 2000, delay = 0.400}
  R = {range = 2000}
  I = {range = 600}
  
  QTargetRange = Q.range+100
  WTargetRange = W.range+100
  ETargetRange = E.range+100
  RTargetRange = R.range
  
  QMinionRange = Q.range+100
  QJunglemobRange = Q.range+100
  
  S5SR = false
  TT = false
  
  if GetGame().map.index == 15 then
    S5SR = true
  elseif GetGame().map.index == 4 then
    TT = true
  end
  
  if S5SR then
    FocusJungleNames =
    {
    "SRU_Baron12.1.1",
    "SRU_RiftHerald17.1.1",
    "SRU_Blue1.1.1",
    "SRU_Blue7.1.1",
    "Sru_Crab15.1.1",
    "Sru_Crab16.1.1",
    "SRU_Dragon_Air",
    "SRU_Dragon_Fire",
    "SRU_Dragon_Water",
    "SRU_Dragon_Earth",
    "SRU_Dragon_Elder",
    "SRU_Gromp13.1.1",
    "SRU_Gromp14.1.1",
    "SRU_Krug5.1.2",
    "SRU_Krug11.1.2",
    "SRU_Murkwolf2.1.1",
    "SRU_Murkwolf8.1.1",
    "SRU_Razorbeak3.1.1",
    "SRU_Razorbeak9.1.1",
    "SRU_Red4.1.1",
    "SRU_Red10.1.1"
    }
  JungleMobNames =
    {
    "SRU_BlueMini1.1.2",
    "SRU_BlueMini7.1.2",
    "SRU_BlueMini21.1.3",
    "SRU_BlueMini27.1.3",
    "SRU_KrugMini5.1.1",
    "SRU_KrugMini11.1.1",
    "SRU_MurkwolfMini2.1.2",
    "SRU_MurkwolfMini2.1.3",
    "SRU_MurkwolfMini8.1.2",
    "SRU_MurkwolfMini8.1.3",
    "SRU_RazorbeakMini3.1.2",
    "SRU_RazorbeakMini3.1.3",
    "SRU_RazorbeakMini3.1.4",
    "SRU_RazorbeakMini9.1.2",
    "SRU_RazorbeakMini9.1.3",
    "SRU_RazorbeakMini9.1.4",
    "SRU_RedMini4.1.2",
    "SRU_RedMini4.1.3",
    "SRU_RedMini10.1.2",
    "SRU_RedMini10.1.3"
    }
  elseif TT then
    FocusJungleNames =
    {
    "TT_NWraith1.1.1",
    "TT_NGolem2.1.1",
    "TT_NWolf3.1.1",
    "TT_NWraith4.1.1",
    "TT_NGolem5.1.1",
    "TT_NWolf6.1.1",
    "TT_Spiderboss8.1.1"
    }   
    JungleMobNames =
    {
    "TT_NWraith21.1.2",
    "TT_NWraith21.1.3",
    "TT_NGolem22.1.2",
    "TT_NWolf23.1.2",
    "TT_NWolf23.1.3",
    "TT_NWraith24.1.2",
    "TT_NWraith24.1.3",
    "TT_NGolem25.1.1",
    "TT_NWolf26.1.2",
    "TT_NWolf26.1.3"
    }
  else
    FocusJungleNames =
    {
    }   
    JungleMobNames =
    {
    }
  end
  
  QTS = TargetSelector(TARGET_LESS_CAST, QTargetRange, DAMAGE_PHYSICAL, false)
  WTS = TargetSelector(TARGET_LESS_CAST, WTargetRange, DAMAGE_PHYSICAL, false)
  ETS = TargetSelector(TARGET_LESS_CAST, ETargetRange, DAMAGE_MAGIC, false)
  RTS = TargetSelector(TARGET_LESS_CAST, RTargetRange, DAMAGE_PHYSICAL, false)
  TES = TargetSelector(TARGET_PRIORITY, 600, DAMAGE_MAGIC)
  
  VPred = VPrediction()
  EnemyHeroes = GetEnemyHeroes()
  EnemyMinions = minionManager(MINION_ENEMY, QMinionRange, myHero, MINION_SORT_MAXHEALTH_DEC)
  JungleMobs = minionManager(MINION_JUNGLE, QJunglemobRange, myHero, MINION_SORT_MAXHEALTH_DEC)
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function CaitlynMenu()

    Menu = scriptConfig("Uneeesh Caitlyn", "UC_MAIN")
    
    Menu:addSubMenu("[Caitlyn]: Control Settings", "Control")
    Menu.Control:addParam("OnC", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
    Menu.Control:addParam("OnF", "Laneclear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('V'))
    Menu.Control:addParam("OnJF", "Jungleclear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('V'))
    Menu.Control:addParam("OnP", "Poke Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('C'))
    Menu.Control:addParam("OnL", "Lasthit Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('X'))
    Menu.Control:addParam("OnJS", "Junglesteal Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('X'))
    Menu.Control:addParam("OnE", "Flee Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('L'))
    Menu.Control:addParam("OnPT", "Poke Toggle", SCRIPT_PARAM_ONKEYTOGGLE, true, GetKey('N'))
    Menu.Control:addParam("OnJST", "Junglesteal Toggle", SCRIPT_PARAM_ONKEYTOGGLE, true, GetKey('J'))
    Menu.Control:addParam("asist", "Easy Ult Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('T'))
    Menu.Control:addParam("tmpdisable", "Stop Junglesteal Toggle", SCRIPT_PARAM_ONKEYDOWN, false, 17)
    Menu.Control:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Control:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
   
    Menu:addSubMenu("[Caitlyn]: Combo Settings", "Combo")
    Menu.Combo:addParam("Mode", "Casting Mode", SCRIPT_PARAM_LIST, 1, {"Insane", "Humanoid"})
    Menu.Combo:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addParam("Q2", "Use if Mana Percent > % >", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
    Menu.Combo:addParam("Q3", "Check Collision for Q", SCRIPT_PARAM_ONOFF, false)
    Menu.Combo:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addParam("W2", "Use if Mana Percent > % >", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
    Menu.Combo:addParam("W3", "Snap Trap Throwing Mode", SCRIPT_PARAM_LIST, 1, {"Advanced", "Standart"})
    Menu.Combo:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addParam("range", "Use E when in X range", SCRIPT_PARAM_SLICE, 600, 300, 1000, 0)

    Menu.Combo:addParam("E2", "Use if Mana Percent > % >", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
    Menu.Combo:addParam("focus", "Left Click Focus Target", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addParam("vision", "Auto vision on Bush", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    
    Menu:addSubMenu("[Caitlyn]: Laneclear Settings", "Farm")
    Menu.Farm:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
    Menu.Farm:addParam("Q2", "Use if Mana Percent > % >", SCRIPT_PARAM_SLICE, 70, 0, 100, 0)
    Menu.Farm:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Farm:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
        
    Menu:addSubMenu("[Caitlyn]: Jungleclear Settings", "JFarm")
    Menu.JFarm:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
    Menu.JFarm:addParam("Q2", "Use if Mana Percent > % >", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
    Menu.JFarm:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.JFarm:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
      
    Menu:addSubMenu("[Caitlyn]: Poke Settings", "Harass")
    Menu.Harass:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
    Menu.Harass:addParam("Q2", "Use if Mana Percent > % >", SCRIPT_PARAM_SLICE, 70, 0, 100, 0)
    Menu.Harass:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
    Menu.Harass:addParam("W2", "Use if Mana Percent > % >", SCRIPT_PARAM_SLICE, 70, 0, 100, 0)
    Menu.Harass:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Harass:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    
    Menu:addSubMenu("[Caitlyn]: LastHit Settings", "LastHit")
    Menu.LastHit:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, false)
    Menu.LastHit:addParam("Q2", "Use if Mana Percent > % >", SCRIPT_PARAM_SLICE, 80, 0, 100, 0)
    Menu.LastHit:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.LastHit:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")

    
    Menu:addSubMenu("[Caitlyn]: Junglesteal Settings", "JSteal")
    Menu.JSteal:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
    Menu.JSteal:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.JSteal:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    
    Menu:addSubMenu("[Caitlyn]: Killsteal Settings", "KillSteal")
    Menu.KillSteal:addParam("On", "Enable Killsteal", SCRIPT_PARAM_ONOFF, true)
    Menu.KillSteal:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
    Menu.KillSteal:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
    Menu.KillSteal:addParam("erange", "Max. E range to Killsteal", SCRIPT_PARAM_SLICE, 600, 1000, 300, 0)
    Menu.KillSteal:addParam("R", "Use R", SCRIPT_PARAM_ONOFF, true)
    Menu.KillSteal:addParam("minrange", "Block R if enemy in close", SCRIPT_PARAM_SLICE, 1, 0, 5, 0)
    Menu.KillSteal:addParam("range", "Max. R range to Killsteal", SCRIPT_PARAM_SLICE, 2000, 1000, 3000, 0)
    Menu.KillSteal:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.KillSteal:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    
    Menu:addSubMenu("[Caitlyn]: Display Settings", "Draw")
    Menu.Draw:addParam("On", "Enable Draws", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("AA", "Draw AA range", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("CLA", "Color AA range", SCRIPT_PARAM_COLOR, {144, 144, 40, 164})
    Menu.Draw:addParam("Q", "Draw Q range", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("CLQ", "Color Q range", SCRIPT_PARAM_COLOR, {141, 124, 4, 4})
    Menu.Draw:addParam("W", "Draw W range", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("CLW", "Color W range", SCRIPT_PARAM_COLOR, {141, 124, 65, 4})
    Menu.Draw:addParam("E", "Draw E range", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("CLE", "Color E range", SCRIPT_PARAM_COLOR, {255, 255, 40, 164})
    if ignite then
    Menu.Draw:addParam("I", "Draw Ignite range", SCRIPT_PARAM_ONOFF, false)
    Menu.Draw:addParam("CLI", "Color Ignite range", SCRIPT_PARAM_COLOR, {141, 124, 114, 114})
    end
    Menu.Draw:addParam("CLFPS", "Enable FPS Friendly Draws", SCRIPT_PARAM_ONOFF, false)
    Menu.Draw:addParam("Quality", "FPS Draws Quality(High=Better FPS)", SCRIPT_PARAM_SLICE, 176, 75, 2000, 0)
    Menu.Draw:addParam("Trg", "Draw Current Target", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("ownp", "Enable Pathway Draw", SCRIPT_PARAM_ONOFF, false)
    Menu.Draw:addParam("opp", "Draw Enemy Pathway", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("ComboDamage", "Draw Predicted Damage", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("Info","", SCRIPT_PARAM_INFO, "")
    Menu.Draw:addParam("stream", "Enable Streaming Mode", SCRIPT_PARAM_ONKEYTOGGLE, false, 118)
    Menu.Draw:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Draw:addParam("Info1", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    
    Menu:addSubMenu("[Caitlyn]: Item&Summoner Settings", "Items")
    Menu.Items:addSubMenu("BotRK", "BotRK")
    Menu.Items.BotRK:addParam("bork", "Use BotRK", SCRIPT_PARAM_ONOFF, true)
    Menu.Items.BotRK:addParam('maxownhealth', 'Max. own % Health to use', SCRIPT_PARAM_SLICE, 50, 1, 100, 0)
    Menu.Items.BotRK:addParam('minenemyhealth', 'Min. enemy % Health to use', SCRIPT_PARAM_SLICE, 20, 1, 100, 0)
    Menu.Items:addSubMenu("Bilgewater", "Bilgewater")
    Menu.Items.Bilgewater:addParam("bilg", "Use Bilgewater", SCRIPT_PARAM_ONOFF, true)
    Menu.Items.Bilgewater:addParam("maxownhealth", "Max. own % Health to use", SCRIPT_PARAM_SLICE, 50, 1, 100, 0)
    Menu.Items.Bilgewater:addParam("minenemyhealth", "Min. enemy % Health to use", SCRIPT_PARAM_SLICE, 20, 1, 100, 0)
    --Menu.Items:addSubMenu("Youmuu", "Youmuu")
    --Menu.Items.Youmuu:addParam("yomu", "Use Youmuu", SCRIPT_PARAM_ONOFF, true)

    Menu.Items:addSubMenu("Health Potions", "potion")
    Menu.Items.potion:addParam("Key", "Use Only Press to", SCRIPT_PARAM_ONKEYDOWN, false, 32)
    Menu.Items.potion:addParam("Always", "Use Always", SCRIPT_PARAM_ONOFF, false)
    Menu.Items.potion:addParam("enemy", "Use if not enemies", SCRIPT_PARAM_ONOFF, false)
    Menu.Items.potion:addParam("health", "If My Health % is <", SCRIPT_PARAM_SLICE, 60, 0, 100, 0) 
    Menu.Items:addSubMenu("Remove CC", "cc")
    Menu.Items.cc:addParam("Key", "Use Only Press to", SCRIPT_PARAM_ONKEYDOWN, false, 32)
    Menu.Items.cc:addParam("Always", "Use Always", SCRIPT_PARAM_ONOFF, true) 
    if SummonerSlot then
    Menu.Items.cc:addParam("Summoner", "Use Cleanse", SCRIPT_PARAM_ONOFF, true) 
    end
    Menu.Items.cc:addParam("delay", "Remove Delay (ms)", SCRIPT_PARAM_SLICE, 0, 0, 400, 0)
    if ignite then
    Menu.Items:addSubMenu("Ignite", "ignite")
    Menu.Items.ignite:addParam("set", "Use Smart Ignite", SCRIPT_PARAM_LIST, 2, {"OFF", "Optimal", "Aggressive"})
    end
    if exhaust then 
    Menu.Items:addSubMenu("Exhaust", "exhaust")
    Menu.Items.exhaust:addParam("exh", "Exhaust Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey(exhaust.key))
    Menu.Items:addTS(TES)
    TES = TargetSelector(TARGET_PRIORITY, 600, DAMAGE_MAGIC) 
    TES.name = "Exhaust"
    end
    if heal then
    Menu.Items:addSubMenu("Heal/Barrier", "heal")
    Menu.Items.heal:addParam("enable", "Enable to use", SCRIPT_PARAM_ONOFF, true)
    Menu.Items.heal:addParam("health", "If My Health % is Less Than", SCRIPT_PARAM_SLICE, 10, 0, 100, 0)
    if realheals then
    Menu.Items.heal:addParam("ally", "Use for Ally", SCRIPT_PARAM_ONOFF, false)
    end
    end
    Menu.Items:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Items:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    
    Menu:addSubMenu("[Caitlyn]: Automation", "Autom")
    Menu.Autom:addSubMenu("AutoLevelSpells Settings", "autolevel")
    Menu.Autom.autolevel:addParam("UseAutoLevelFirst", "Use AutoLevelSpells Level 1-3", SCRIPT_PARAM_ONOFF, false)
    Menu.Autom.autolevel:addParam("UseAutoLevelRest", "Use AutoLevelSpells Level 4-18", SCRIPT_PARAM_ONOFF, false)
    Menu.Autom.autolevel:addParam("First3Level", "Level 1-3", SCRIPT_PARAM_LIST, 1, {"Q-W-E", "Q-E-W", "W-Q-E", "W-E-Q", "E-Q-W", "E-W-Q"})
    Menu.Autom.autolevel:addParam("RestLevel", "Level 4-18", SCRIPT_PARAM_LIST, 1, {"Q-W-E", "Q-E-W", "W-Q-E", "W-E-Q", "E-Q-W", "E-W-Q"})
    Menu.Autom.autolevel:addParam("Blank", "", SCRIPT_PARAM_INFO, "","" )
    Menu.Autom.autolevel:addParam("Blank", "You can Click on the Q-W-E", SCRIPT_PARAM_INFO, "","" )
    Menu.Autom.autolevel:addParam("Blank", "to change the AutoLevelOrder", SCRIPT_PARAM_INFO, "","" )
    Menu.Autom:addSubMenu("Skin Changer", "ChgSki")
    Menu.Autom:addSubMenu("Auto Buy Item", "buyme")
    Menu.Autom.buyme:addParam("buydoran", "Doran's Blade", SCRIPT_PARAM_ONOFF, true)
    Menu.Autom.buyme:addParam("buypot", "Potion", SCRIPT_PARAM_ONOFF, true)
    Menu.Autom.buyme:addParam("taketrinket", "Green Trinket", SCRIPT_PARAM_ONOFF, true)
    Menu.Autom.buyme:addParam("changeblue", "Lvl 9 Blue Trinket", SCRIPT_PARAM_ONOFF, true)
    Menu.Autom:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Autom:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
  
    Menu:addSubMenu("[Caitlyn]: Spell Priority Settings", "Spell")
    
    Menu.Spell:addTS(QTS)
    Menu.Spell:addParam("blank", "      ", SCRIPT_PARAM_INFO, "  ")
    Menu.Spell:addParam("blank", "   ----------------------------------------------------   ", SCRIPT_PARAM_INFO, "------------- ")
    Menu.Spell:addParam("blank", "      ", SCRIPT_PARAM_INFO, "  ")
    Menu.Spell:addParam("blank", "  [Recommenned LessCast]  ", SCRIPT_PARAM_INFO, " ")
    Menu.Spell:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Spell:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    
    Menu:addSubMenu("[Caitlyn]: Prediction Settings", "Prediction")

    Menu.Prediction:addParam("blank", "      ", SCRIPT_PARAM_INFO, "  ")
    Menu.Prediction:addParam("Choice", "Prediction Method", SCRIPT_PARAM_LIST, 1, {"VPrediction", "HPrediction", "SPrediction", "FHPrediction", "KPrediction", "Divine Prediction"})
    Menu.Prediction:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Prediction:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
      
      Menu.Prediction:addSubMenu("VPrediction", "VPrediction")
      Menu.Prediction.VPrediction:addParam("Q", "Q Hitchance (2)", SCRIPT_PARAM_SLICE, 2, 1, 5, 1)
      Menu.Prediction.VPrediction:addParam("W", "W Hitchance (2)", SCRIPT_PARAM_SLICE, 2, 1, 5, 1)
      Menu.Prediction.VPrediction:addParam("E", "E Hitchance (1.5)", SCRIPT_PARAM_SLICE, 1.5, 1, 5, 1)
      Menu.Prediction:addSubMenu("HPrediction", "HPrediction")
      Menu.Prediction.HPrediction:addParam("Q", "Q Hitchance (1.5)", SCRIPT_PARAM_SLICE, 1.5, 1, 3, 1)
      Menu.Prediction.HPrediction:addParam("W", "W Hitchance (1.5)", SCRIPT_PARAM_SLICE, 1.5, 1, 3, 1) 
      Menu.Prediction.HPrediction:addParam("E", "E Hitchance (1)", SCRIPT_PARAM_SLICE, 1, 1, 3, 1)
      Menu.Prediction:addSubMenu("SPrediction", "SPrediction")
      Menu.Prediction.SPrediction:addParam("Q", "Q Hitchance (1.50)", SCRIPT_PARAM_SLICE, 1.50, 1, 3, 1)
      Menu.Prediction.SPrediction:addParam("W", "W Hitchance (1.50)", SCRIPT_PARAM_SLICE, 1.50, 1, 3, 1)
      Menu.Prediction.SPrediction:addParam("E", "E Hitchance (1.33)", SCRIPT_PARAM_SLICE, 1.33, 1, 3, 1)
      Menu.Prediction:addSubMenu("KPrediction", "KPrediction")
      Menu.Prediction.KPrediction:addParam("Q", "Q Hitchance (2)", SCRIPT_PARAM_SLICE, 2, 1, 4, 1)
      Menu.Prediction.KPrediction:addParam("W", "W Hitchance (2)", SCRIPT_PARAM_SLICE, 2, 1, 4, 1)  
      Menu.Prediction.KPrediction:addParam("E", "E Hitchance (1.5)", SCRIPT_PARAM_SLICE, 1.5, 1, 4, 1)
      Menu.Prediction:addSubMenu("Divine Prediction", "DPrediction")
      Menu.Prediction.DPrediction:addParam("Q", "Q Hitchance (%65)", SCRIPT_PARAM_SLICE, 65, 1, 100, 0)
      Menu.Prediction.DPrediction:addParam("W", "W Hitchance (%60)", SCRIPT_PARAM_SLICE, 60, 1, 100, 0)
      Menu.Prediction.DPrediction:addParam("E", "E Hitchance (%50)", SCRIPT_PARAM_SLICE, 50, 1, 100, 0)
      Menu.Prediction:addSubMenu("FHPrediction", "FHPrediction")
      Menu.Prediction.FHPrediction:addParam("Q", "Q Hitchance (1.3)", SCRIPT_PARAM_SLICE, 1.3, 1, 2, 1)
      Menu.Prediction.FHPrediction:addParam("W", "W Hitchance (1.3)", SCRIPT_PARAM_SLICE, 1.3, 1, 2, 1)
      Menu.Prediction.FHPrediction:addParam("E", "E Hitchance (1.1)", SCRIPT_PARAM_SLICE, 1.1, 1, 2, 1)
    LoadPrediction(Menu.Prediction.Choice)
    Menu.Prediction:setCallback("Choice", function(var) LoadPrediction(Menu.Prediction.Choice) end)

    Menu:addSubMenu("[Caitlyn]: Orbwalker Settings", "Orbwalker")
    
    Menu.Spell:addTS(WTS)
    Menu.Spell:addTS(ETS)
    Menu.Spell:addTS(RTS)
    QTS.name = "Caitlyn Q"
    WTS.name = "Caitlyn W"
    ETS.name = "Caitlyn E"
    RTS.name = "Caitlyn R"
    
    Menu:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu:addParam("Info", "http://botoflegends.com", SCRIPT_PARAM_INFO, "")
    Menu:addParam("SVersion", "Script Version ", SCRIPT_PARAM_LIST, 1, {"" .. Version})
    Menu:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu:addParam("popup", "Click For Latest Changelog", SCRIPT_PARAM_ONOFF, false)
    
    Menu.Control:permaShow("OnPT")
    Menu.Control:permaShow("OnJST")
    Menu.Combo:permaShow("Mode")
    Menu.Prediction:permaShow("Choice")
    Menu.Combo:permaShow("W3")

    Menu.Control.OnC = false
    Menu.Control.OnF = false
    Menu.Control.OnJF = false
    Menu.Control.OnP = false
    Menu.Control.OnL = false
    Menu.Control.OnJS = false
    Menu.Control.OnE = false
    Menu.Control.tmpdisable = false
    Menu.Control.asist = false
  
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function LoadOrbwalk()

  if _G.AutoCarry and _G.Reborn_Initialised then
    SACLoaded = true
    Menu.Orbwalker:addParam("Info", "             ----->>> SAC Detected & Loaded <<<-----   ", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    ScriptMsg("Sida's Auto Carry Detected.")
  elseif _G.Reborn_Loaded then
    DelayAction(function() LoadOrbwalk() end, 1)
  elseif _G.MMA_IsLoaded then
    MMALoaded = true
    Menu.Orbwalker:addParam("Info", "             ----->>> MMA Detected & Loaded <<<-----   ", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    ScriptMsg("Marksman's Mighty Assistant Detected.")
  elseif _G._Pewalk then
    PEWLoaded = true
    Menu.Orbwalker:addParam("Info", "             ----->>> Pewalk Detected & Loaded <<<-----   ", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    ScriptMsg("Pewalk Detected.")
  elseif FileExist(LIB_PATH .. "SxOrbWalk.lua") then
    require 'SxOrbWalk'
    SxOrb = SxOrbWalk()
    SxOrb:LoadToMenu(Menu.Orbwalker)
    Menu.Orbwalker:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Info", " Izsha & HTTF", SCRIPT_PARAM_INFO, "")
    SxOrbLoaded = true
    ScriptMsg("Sxorbwalk Detected.")
  else
    ErrorMsg("WARNING:Orbwalker Not Found!")
  end
  
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

--[[function LoadOrbwalker(choice)

  if choice == 1 then

    --[[if _G.NebelwolfisOrbWalkerInit or _G.NebelwolfisOrbWalkerLoaded then
      NOWLoaded = true
      ScriptMsg(" ")
      return
    end

    if _Pewalk then
      PEWLoaded = true
      ErrorMsg("Pewalk is enabled, you have to disable Pewalk in BoL menu for using Sida's Auto Carry.")
      return
    end

    if _G.MMA_IsLoaded then
      MMALoaded = true
      ErrorMsg("Marksman's Mighty Assistant is enabled, you have to disable Marksman's Mighty Assistant in BoL menu for using Sida's Auto Carry.")
      return
    end

    if _G.Reborn_Loaded then
      SACLoaded = true

      if _G.AutoCarry and _G.Reborn_Initialised then
        Menu.Orbwalker:addParam("Info", "             ----->>> SAC Detected & Loaded <<<-----   ", SCRIPT_PARAM_INFO, "")
      else
        DelayAction(function() LoadOrbwalker(1) end, 1)
      end

    else

      local function UpdateSAC()

        if FileExist(SCRIPT_PATH .. "Sida's Auto Carry.lua") then
          ErrorMsg("Error loading Sida's Auto Carry, try again or try to use another orbwalker else contact with developer.")
          Menu.Orbwalker:addParam("Info", "             ----->>> Loading Failed - SAC <<<-----   ", SCRIPT_PARAM_INFO, "")
        else
          DownloadFile("https://raw.githubusercontent.com/SidaBoL/Scripts/master/Misc/Sida's%20Auto%20Carry.lua", SCRIPT_PATH .. "Sida's Auto Carry.lua", function() UpdateSAC() end)
        end

      end

      UpdateSAC()
    end

  elseif choice == 2 then

    if _G.Reborn_Loaded then
      SACLoaded = true
      ErrorMsg("Sida's Auto Carry is enabled, you have to disable Sida's Auto Carry in BoL menu for using Pewalk.")
      return
    end

    if _G.MMA_IsLoaded then
      MMALoaded = true
      ErrorMsg("Marksman's Mighty Assistant is enabled, you have to disable Marksman's Mighty Assistant in BoL menu for using Pewalk.")
      return
    end

    --[[if _G.NebelwolfisOrbWalkerInit or _G.NebelwolfisOrbWalkerLoaded then
      NOWLoaded = true
      ScriptMsg(" ")
      return
    end

    if _Pewalk then
      PEWLoaded = true
      Menu.Orbwalker:addParam("Info", "             ----->>> Pewalk Detected & Loaded <<<-----   ", SCRIPT_PARAM_INFO, "")

      local function Disable()

        if _Pewalk.DisableSkillFarm then
          _Pewalk.DisableSkillFarm(_Q) _Pewalk.DisableSkillFarm(_W) _Pewalk.DisableSkillFarm(_E) _Pewalk.DisableSkillFarm(_R)
        else
          DelayAction(function() Disable() end, 1)
        end

      end

      Disable()
    else

      local function UpdatePEW()

        if FileExist(SCRIPT_PATH .. "Pewalk.lua") then
          ErrorMsg("Error loading Pewalk, try again or try to use another orbwalker else contact with developer.")
          Menu.Orbwalker:addParam("Info", "             ----->>> Loading Failed - Pewalk <<<-----   ", SCRIPT_PARAM_INFO, "")
        else
          DownloadFile("https://raw.githubusercontent.com/PewPewPew2/BoL/master/Pewalk.lua", SCRIPT_PATH .. "Pewalk.lua", function() UpdatePEW() end)
        end

      end

      UpdatePEW()
    end

  elseif choice == 3 then

    if _G.Reborn_Loaded then
      SACLoaded = true
      ErrorMsg("Sida's Auto Carry is enabled, you have to disable Sida's Auto Carry in BoL menu for using Marksman's Mighty Assistant.")
      return
    end

    if _Pewalk then
      PEWLoaded = true
      ErrorMsg("Pewalk is enabled, you have to disable Pewalk in BoL menu for using Marksman's Mighty Assistant. ")
      return
    end

    if _G.MMA_IsLoaded then
      MMALoaded = true
      Menu.Orbwalker:addParam("Info", "             ----->>> MMA Detected & Loaded <<<-----   ", SCRIPT_PARAM_INFO, "")
    else

      local function UpdateMMA()

        if FileExist(SCRIPT_PATH .. "MarksmanMightyAssistant.lua") then
          ErrorMsg("Error loading Marksman's Mighty Assistant, try again or try to use another orbwalker else contact with developer.")
          Menu.Orbwalker:addParam("Info", "             ----->>> Loading Failed - MMA <<<-----   ", SCRIPT_PARAM_INFO, "")
        else
          DownloadFile("http://manciuszz.net/mma2.0/MarksmanMightyAssistant.lua", SCRIPT_PATH .. "MarksmanMightyAssistant.lua", function() UpdateMMA() end)
        end

      end

      UpdateMMA()
      
    end
  end
end

function UnloadOrbwalker()

  if SACLoaded or PEWLoaded or MMALoaded then
    ScriptMsg("Press F9 x2 to disable orbwalker.")
  end
end]]--

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function LoadPrediction(choice)

  if choice == 1 and not VPred then

    if _G.VPrediction_Init then
      VPred = VPrediction()  
    else

      local function UpdateVPred()

        if FileExist(LIB_PATH .. "VPrediction.lua") then
          require("VPrediction")
          VPred = VPrediction()    
        else
          DownloadFile("https://raw.githubusercontent.com/SidaBoL/Scripts/master/Common/VPrediction.lua", LIB_PATH .. "VPrediction.lua", function() UpdateVPred() end)
        end

      end

      UpdateVPred()
    end
    
  

  elseif choice == 2 and not HPred then

    if _G.HPrediction_Init then
      HPred = HPrediction()  
    else

      local function UpdateHPred()

        if FileExist(LIB_PATH .. "HPrediction.lua") then
          require("HPrediction")
          HPred = HPrediction()    
        else
          DownloadFile("https://raw.githubusercontent.com/Jaikor/BoL-1/master/HTTF/Common/HPrediction.lua", LIB_PATH .. "HPrediction.lua", function() UpdateHPred() end)
        end

      end

      UpdateHPred()
    end
    
    elseif choice == 3 and not SPred then

    if _G.SPrediction_Init then
      SPred = SPrediction()  
    else

      local function UpdateSPred()

        if FileExist(LIB_PATH .. "SPrediction.lua") then
          require("SPrediction")
          SPred = SPrediction()    
        else
          DownloadFile("https://raw.githubusercontent.com/nebelwolfi/BoL/master/Common/SPrediction.lua", LIB_PATH .. "SPrediction.lua", function() UpdateSPred() end)
        end

      end

      UpdateSPred()
    end

  elseif choice == 4 and not FHPred then

    if FileExist(LIB_PATH .. "FHPrediction.lua") then
          require("FHPrediction")
          FHPred = FHPrediction
    else  
      ErrorMsg("FHPrediction not found , please download manually from the forums , loaded VPrediction for now.")
      LoadPrediction(1)
    end
  
  elseif choice == 5 and not KPred then

    if _G.KPrediction_Init then
      KPred = KPrediction()  
    else

      local function UpdateKPred()

        if FileExist(LIB_PATH .. "KPrediction.lua") then
          require("KPrediction")
          KPred = KPrediction()    
        else
          DownloadFile("https://raw.githubusercontent.com/Jaikor/BoL-1/master/HTTF/Common/KPrediction.lua", LIB_PATH .. "KPrediction.lua", function() UpdateKPred() end)
        end

      end

      UpdateKPred()
    end

 elseif choice == 6 and not DPred then
    if DPExist then
      require("DivinePred")
      DPred = DivinePred()
      DPred:bindSS("Q",50)
      DPred:bindSS("R",50)
      DelayAction(function()
        if not DivinePred.isAuthed() then
          ErrorMsg("You have no access to Divine Pred, loaded VPrediction for now.")
          LoadPrediction(1)
        end
      end,3)
    else
      ErrorMsg("Divine Prediction not found , please download manually from the forums , loaded VPrediction for now.")
      LoadPrediction(1)
    end
  end

end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function OnTick()
  if not Loaded then
    return
  end

  if myHero.dead then
    return
  end
  
  Checks()

  if Menu.Combo.Mode == 1 then
    TargetsInsane()
  elseif Menu.Combo.Mode == 2 then
    TargetsHumanoid()
  end
  
  if Menu.Control.OnC then
    Combo()
  end
  
  if Menu.Control.OnC and Menu.Combo.vision then
    Bushfind()
  end

  if Menu.popup then
    Menu.popup = false
    PopUp = true
  end
  
  if Menu.Control.OnF then
    Farm()
  end
  
  if Menu.Control.OnJF then
    JFarm()
  end
  
  if Menu.Autom.autolevel.UseAutoLevelFirst or Menu.Autom.autolevel.UseAutoLevelRest then
    CheckLevelChange()
    LevelUpSpell()
  end
  
  if Menu.Control.OnP or Menu.Control.OnPT then
    Harass()
  end
  
  if Menu.Control.OnPT then
    HarassAlways()
  end
  
  if Menu.Control.OnL then
    LastHit()
  end
  
  if Menu.Control.OnJS then
    JSteal()
  end
  
  if Menu.Control.OnJST then
    JstealAlways()
  end
  
  if Menu.KillSteal.On then
    KillSteal()
    KillStealR()
  end

  if Menu.Control.asist then
    KillStealR()
  end
  
  if Menu.Control.OnE then
    Flee()
  end

  if Menu.Draw.stream and not ChatOff then
    dChat()
  elseif not Menu.Draw.stream and ChatOff then
    eChat()
  end
  
  if Menu.Items.BotRK.bork then
    if myHero.health / myHero.maxHealth <=  Menu.Items.BotRK.maxownhealth / 100 then
      local unit = TargetsInsane() or TargetsHumanoid()
      if ValidTarget(unit, 1000) then
        if unit.health / unit.maxHealth <=  Menu.Items.BotRK.minenemyhealth  / 100 then
          BotRK(unit)
        end
      end
    end 
  end 
     
    if Menu.Items.Bilgewater.bilg then
    if myHero.health / myHero.maxHealth <=  Menu.Items.Bilgewater.maxownhealth / 100 then
      local unit = TargetsInsane() or TargetsHumanoid()
      if ValidTarget(unit, 1000) then
        if unit.health / unit.maxHealth <=  Menu.Items.Bilgewater.minenemyhealth / 100 then
          Bilgewater(unit)
        end
      end
    end 
  end 
    
    if exhaust and Menu.Items.exhaust.exh then 
    if myHero:CanUseSpell(exhaust.slot) == 0 then
      TES:update()
      if ValidTarget(TES.target) and TES.target.type == myHero.type then
        exhFunction(TES.target) 
      end
    end
  end

  if heal then
    if ValidTarget(TargetsInsane() or TargetsHumanoid(), 1000) then
      if Menu.Items.heal.enable and myHero:CanUseSpell(heal) == 0 then
        if myHero.level > 5 and myHero.health/myHero.maxHealth < Menu.Items.heal.health/100 then
          CastSpell(heal)
        elseif  myHero.level < 6 and myHero.health/myHero.maxHealth < (Menu.Items.heal.health/100)*.75 then
          CastSpell(heal)
        end
        
        if realheals and Menu.Items.heal.ally then
          local ally = findClosestAlly(myHero)
          if ally and not ally.dead and GetDistance(ally) < 850 then
            if  ally.health/ally.maxHealth < Menu.Items.heal.health/100 then
              CastSpell(heal)
            end
          end
        end
      end
    end
  end

  if not myHero.dead then
    if (Menu.Items.potion.Key or Menu.Items.potion.Always) and not potionOn and not InFountain() and (myHero.health/myHero.maxHealth)*100 < Menu.Items.potion.health then
      UsePotion()
    end
  end
  
  if ignite and Menu.Items.ignite.set > 1 and (myHero:CanUseSpell(ignite) == READY) then 
    AutoIgnite()
  end

end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function AlliesAround(Unit, range)
    local c=0
    if Unit == nil then return 0 end
    for i=1,heroManager.iCount do hero = heroManager:GetHero(i) if hero.team == myHero.team and hero.x and hero.y and hero.z and GetDistance(hero, Unit) < range then c=c+1 end end return c
end

function EnemiesAround(Unit, range)
    local c=0
    if Unit == nil then return 0 end
    for i=1,heroManager.iCount do hero = heroManager:GetHero(i) if hero ~= nil and hero.team ~= myHero.team and hero.x and hero.y and hero.z and GetDistance(hero, Unit) < range then c=c+1 end end return c
  end

function findClosestAlly(obj)
    local closestAlly = nil
    local currentAlly = nil
  for i, currentAlly in pairs(GetAllyHeroes()) do
        if currentAlly and not currentAlly.dead then
            if closestAlly == nil then
                closestAlly = currentAlly
      end
            if GetDistanceSqr(currentAlly.pos, obj) < GetDistanceSqr(closestAlly.pos, obj) then
        closestAlly = currentAlly
            end
        end
    end
  return closestAlly
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function CheckItem(ItemName)
  for i = 6, 12 do
    local item = myHero:GetSpellData(i).name
    if item and item:lower() == ItemName then
      return i
    end
  end
end

function checkSpecific(unit, buffname)
  if unit.buffCount then
    for i = 1, unit.buffCount do
      local buff = unit:getBuff(i)
      if buff and buff.valid and buff.name then
        if buff.name:lower():find(buffname) then
          return true
        end
      end
    end
  end
end

function exhFunction(unit)
  moveToCursor()
  CastSpell(exhaust.slot, unit)
end

function moveToCursor()
  local MouseMove = Vector(myHero) + (Vector(mousePos) - Vector(myHero)):normalized() * 500
  myHero:MoveTo(MouseMove.x, MouseMove.z) 
end

function OnUpdateBuff(unit, buff, stacks)
  if not unit or not buff then return end
  if unit.isMe then
    if buff.name:lower():find("regenerationpotion") or buff.name:lower():find("itemminiregenpotion") or buff.name:lower():find("crystalflask") then
      potionOn = true
    end
  end
end

function OnRemoveBuff(unit, buff)
  if not unit or not buff then return end
  if unit.isMe then
    if buff.name:lower():find("regenerationpotion") or buff.name:lower():find("itemminiregenpotion") or buff.name:lower():find("crystalflask") then
      potionOn = false
    end
  end
end
local lastPotion = 0

function UsePotion()
  if os.clock() - lastPotion < 8 then return end
  if not Menu.Items.potion.enemy then
    if CountEnemiesNearUnitReg(myHero, 750) == 0 then return end
  end
  
  local slot = GetSlotItemFromName("crystalflask")
  if not slot then
    slot = GetSlotItemFromName("RegenerationPotion")
  end
  if not slot then
    slot = GetSlotItemFromName("itemminiregenpotion")
  end
  if slot then
    CastSpell(slot)
    lastPotion = os.clock()
  end
end
local lastPotionMana = 0

function UsePotionMana()
  if CountEnemiesNearUnitReg(myHero, 1000) == 0 then return end
  if os.clock() - lastPotionMana < 8 then return end
  local slot = GetSlotItemFromName("crystalflask")
  if not slot then
    slot = GetSlotItemFromName("flaskofcrystalwater")
  end
  if slot then
    CastSpell(slot)
    lastPotionMana = os.clock()
  end
end

function GetSlotItemFromName(itemname)
  local slot
  for i = 6, 12 do
    local item = myHero:GetSpellData(i).name
    if item and item:lower():find(itemname:lower()) and myHero:CanUseSpell(i) == READY then
      slot = i
    end
  end
  return slot
end

function GetSlotItem(id, unit)
  unit = unit or myHero

  if (not ItemNames[id]) then
    return ___GetInventorySlotItem(id, unit)
  end

  local name  = ItemNames[id]
  
  for slot = ITEM_1, ITEM_7 do
    local item = unit:GetSpellData(slot).name
    if item and item:lower() == name:lower() and myHero:CanUseSpell(slot) == READY then
      return slot
    end
  end
end

local lastTAttack = 0
local tDamage = 1
if AddProcessAttackCallback and heal and Menu.Items.heal.enable then
  AddProcessAttackCallback(function(unit, spell) AProc(unit, spell) end)
end

function AProc(unit, spell)
  if not unit or not unit.valid or not spell then return end

  if spell.target and spell.target.type == myHero.type and spell.target.team == myHero.team and (spell.name:lower():find("_turret_chaos") or spell.name:lower():find("_turret_order")) and not (spell.name:lower():find("4") or spell.name:lower():find("3")) then
    if GetDistance(unit) < 2000 then
      if clock() - lastTAttack < 1.75 then
        if tDamage < 1.75 then
          tDamage = tDamage + 0.375
        else
          tDamage = tDamage + 0.250
          tDamage = tDamage > 2.25 and 2.25 or tDamage
        end
      else
        tDamage = 1
      end
      lastTAttack = clock()
      
      if myHero:CanUseSpell(heal) == 0 and spell.target.isMe then
        local realDamage = unit.totalDamage / (((myHero.armor * 0.7) / 100) + 1)

        if VPred:GetPredictedHealth(myHero, 0.5) + myHero.shield <= realDamage * tDamage then
          DelayAction(function()
            CastSpell(heal)
            ScriptMsg("Saving from tower")
          end, 0.5)
        end
      end
    end
  end
end

function OnProcessSpell(unit, spell)
if not unit or not unit.valid or not spell then return end

  if heal and Menu.Items.heal.enable and myHero:CanUseSpell(heal) == 0 and spell.target and spell.target.isMe and unit.team ~= myHero.team and unit.type == myHero.type then
    if myHero.health/myHero.maxHealth <= (Menu.Items.heal.health/100)*1.5 then
      CastSpell(heal)
    end
  end
  if spell.name:lower():find("zedr") and spell.target == myHero then
    DelayAction(function()
    end, 1.7)
  end
end

function OnApplyBuff(source, unit, buff)
if not buff or not source or not source.valid or not unit or not unit.valid then return end
  --if unit.isMe then print(buff.name) end
  if unit.isMe and (Menu.Items.cc.Always or Menu.Items.cc.Key) then
    if (source.charName == "Rammus" and buff.type ~= 8) or source.charName == "Alistar" or source.charName:lower():find("baron") or source.charName:lower():find("spiderboss") or source.charName == "LeeSin" or (source.charName == "Hecarim" and not buff.name:lower():find("fleeslow")) then return end  
    if buff.name and ((not cleanse and buff.type == 24) or buff.type == 5 or buff.type == 11 or buff.type == 22 or buff.type == 21 or buff.type == 8)
    or (buff.type == 10 and buff.name and buff.name:lower():find("fleeslow")) then
      if buff.name and buff.name:lower():find("caitlynyor") and CountEnemiesNearUnitReg(myHero, 700) == 0   then
        return false
      elseif not source.charName:lower():find("blitzcrank") then
        UseItemsCC(myHero, true)
      end          
    end           
  end
  if unit and unit.isMe and buff.name == "caitlynheadshot" then
  Aim = true
  else
  Aim = false
end
end

function CountEnemiesNearUnitReg(unit, range)
  local count = 0
  for i, enemy in pairs(GetEnemyHeroes()) do
    if not enemy.dead and enemy.visible then
      if  GetDistanceSqr(unit, enemy) < range * range  then 
        count = count + 1 
      end
    end
  end
  return count
end

function UseItemsCC(unit, scary)
  if os.clock() - lastRemove < 1 then return end
  for i, Item in pairs(Items) do
    local Item = Items[i]
    if GetInventoryItemIsCastable(Item.id) and GetDistanceSqr(unit) <= Item.range * Item.range then
      if Item.id == 3139 or Item.id ==  3140 then
        if scary then
          DelayAction(function()
            CastItem(Item.id)
          end, Menu.Items.cc.delay/1000)  
          lastRemove = os.clock()
          return true
        end
      end
    end
  end
  if Menu.Items.cc.Summoner and SummonerSlot and myHero:CanUseSpell(SummonerSlot) == 0 then
    DelayAction(function()
      CastSpell(SummonerSlot)
    end, Menu.Items.cc.delay/1000)
    lastRemove = os.clock()
  end
end

function findClosestEnemy(obj)
    local closestEnemy = nil
    local currentEnemy = nil
  for i, currentEnemy in pairs(GetEnemyHeroes()) do
        if ValidTarget(currentEnemy) then
            if closestEnemy == nil then
                closestEnemy = currentEnemy
      end
            if GetDistanceSqr(currentEnemy.pos, obj) < GetDistanceSqr(closestEnemy.pos, obj) then
        closestEnemy = currentEnemy
            end
        end
    end
  return closestEnemy
end

function HealSlot()
  if myHero:GetSpellData(SUMMONER_1).name:lower():find("summonerheal") or myHero:GetSpellData(SUMMONER_2).name:lower():find("summonerheal") then
    realheals = true
  end
  if myHero:GetSpellData(SUMMONER_1).name:lower():find("summonerheal")  or myHero:GetSpellData(SUMMONER_1).name:lower():find("summonerbar") then
    return SUMMONER_1
  elseif myHero:GetSpellData(SUMMONER_2).name:lower():find("summonerheal") or myHero:GetSpellData(SUMMONER_2).name:lower():find("summonerbar") then
    return SUMMONER_2
  end
end

function BotrK(unit, scary)
  for i, Item in pairs(Items) do
    local Item = Items[i]
    if Item.id ~= 3140 and Item.id ~= 3139 then
      if GetInventoryItemIsCastable(Item.id) and GetDistanceSqr(unit) <= Item.range * Item.range then
        if Item.id == 3153 then
          CastItem(Item.id)
        else
          CastItem(Item.id, unit) return true
        end
      end
    end
  end
end

function Bilgewater(unit, scary)
  for i, Item in pairs(Items) do
    local Item = Items[i]
    if Item.id ~= 3140 and Item.id ~= 3139 then
      if GetInventoryItemIsCastable(Item.id) and GetDistanceSqr(unit) <= Item.range * Item.range then
        if Item.id == 3144 then
          CastItem(Item.id)
        else
          CastItem(Item.id, unit) return true
        end
      end
    end
  end
end

--[[function Youmuu()
  if Menu.Items.Youmuu.yomu then
  local slot = GetInventorySlotItem(3142)
  if Target ~= nil and ValidTarget(Target) and not Target.dead and slot ~= nil and myHero:CanUseSpell(slot) == READY then
  CastSpell(slot)
  end
end
end]]--

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function AutoIgnite()
  local IgniteDmg = 50 + (20 * myHero.level)
  local aggro = Menu.Items.ignite.set == 3 and 0.05 or 0
  for i, enemy in pairs(GetEnemyHeroes()) do
    if ValidTarget(enemy, 600) then
      local spellDamage = 0
      local adDamage = myHero:CalcDamage(enemy, myHero.totalDamage)
      spellDamage = spellDamage + adDamage
      if myHero.health < myHero.maxHealth*(0.35+aggro) and enemy.health < enemy.maxHealth*(0.34+aggro) and GetDistanceSqr(enemy) < 420 * 420 then
        CastSpell(ignite, enemy)
      end
      local r = myHero.range+65
      local trange = r < 575 and r or 575
      if isFleeingFromMe(enemy, trange) then
        if enemy.health < IgniteDmg + spellDamage  + 10 then    
          if myHero.ms < enemy.ms then
            CastSpell(ignite, enemy)  
            if Debug then
              ScriptMsg("+++++++!")
            end 
          else
            if Debug then
              ScriptMsg("-------!")
            end
          end
        end 
      end
      if (GetDistanceSqr(enemy) > 160000 and (myHero.health+myHero.shield) < myHero.maxHealth*0.3) then 
        if enemy.health > spellDamage-(500*aggro) and enemy.health < IgniteDmg + spellDamage-(500*aggro)  then
          CastSpell(ignite, enemy)              
          if Debug then
            ScriptMsg("ignite Q")
          end
        end
      end
    end
  end
end

function CountAlliesNearUnit(unit, range)
  local count = 0
  for i, ally in pairs(GetAllyHeroes()) do
    if GetDistanceSqr(ally, unit) <= range * range and not ally.dead then count = count + 1 end
  end
  return count
end

function isFleeingFromMe(target, range)
  local pos = VPred:GetPredictedPos(target, 0.26)
  
  if pos and GetDistanceSqr(pos) > range*range then
    return true
  end
  return false
end

function amIFleeing(target, range)
  local pos = VPred:GetPredictedPos(myHero, 0.26)
  
  if pos and GetDistanceSqr(pos, target) > range*range then
    return true
  end
  return false
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function Checks()

  Q.ready = myHero:CanUseSpell(_Q) == READY
  W.ready = myHero:CanUseSpell(_W) == READY
  E.ready = myHero:CanUseSpell(_E) == READY
  R.ready = myHero:CanUseSpell(_R) == READY
  I.ready = Ignite ~= nil and myHero:CanUseSpell(Ignite) == READY
  
  Q.level = myHero:GetSpellData(_Q).level
  W.level = myHero:GetSpellData(_W).level
  E.level = myHero:GetSpellData(_E).level
  R.level = myHero:GetSpellData(_R).level
  
  EnemyMinions:update()
  JungleMobs:update()
  
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function TargetsHumanoid()
  
  local Target = nil
  
  if ValidTarget(SelectedTarget) then
    Target = SelectedTarget
  elseif _G.MMA_IsLoaded then 
    Target = _G.MMA_Target()
  elseif _G.AutoCarry and _G.Reborn_Initialised then
    Target = _G.AutoCarry.Crosshair:GetTarget()
  elseif _G._Pewalk then 
    Target = _G._Pewalk.GetTarget()
  elseif SxOrbLoaded then
    Target = SxOrb:GetTarget()
  end

  if Target and Target.type == myHero.type and ValidTarget(Target, TrueRange(Target)) then
    QTarget = Target
    WTarget = Target
    ETarget = Target
    RTarget = Target
  else
    QTS:update()
    WTS:update()
    ETS:update()
    RTS:update()
    QTarget = QTS.target
    WTarget = WTS.target
    ETarget = ETS.target
    RTarget = RTS.target
  end
end

function TargetsInsane()

local Target = nil

  if ValidTarget(SelectedTarget) then

    QTarget = SelectedTarget
    WTarget = SelectedTarget
    ETarget = SelectedTarget 
    RTarget = SelectedTarget

  elseif Target and Target.type == myHero.type and ValidTarget(Target, TrueRange(Target)) then
    QTarget = Target
    WTarget = Target
    ETarget = Target
    RTarget = Target
  else
    QTS:update()
    WTS:update()
    ETS:update()
    RTS:update()
    QTarget = QTS.target
    WTarget = WTS.target
    ETarget = ETS.target
    RTarget = RTS.target
  end
end

function OnWndMsg(Msg, Key)
  if Msg == WM_LBUTTONDOWN then
if PopUp then
PopUp = false
end
end
  if Msg == WM_LBUTTONDOWN and Menu.Combo.focus then
    local minDis = 0
    local starget = nil
    for i, enemy in ipairs(GetEnemyHeroes()) do
      if ValidTarget(enemy) then
        if GetDistance(enemy, mousePos) <= minDis or starget == nil then
          minDis = GetDistance(enemy, mousePos)
          starget = enemy
        end
      end
    end

    if starget and minDis < starget.boundingRadius*2 then
      if SelectedTarget and starget.charName == SelectedTarget.charName then
        SelectedTarget = nil
        ScriptMsg("Target Unlocked", true)
      else
        SelectedTarget = starget
        ScriptMsg("Target Locked  - "..starget.charName.."", true)
      end
      elseif SelectedTarget ~= nil then
        SelectedTarget = nil
        ScriptMsg("Target Unlocked", true)
      end
    end
  end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function OrbwalkCanMove()

  if SACLoaded then
    return _G.AutoCarry.Orbwalker:CanMove()
  elseif PEWLoaded then
    return _Pewalk.CanMove()
  elseif MMALoaded then
    return _G.MMA_CanMove()
  end
  
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function Combo()

  if QTarget ~= nil then
    if Menu.Combo.Q3 then
  
    local ComboQ = Menu.Combo.Q
    local ComboQ2 = Menu.Combo.Q2
    
    if Q.ready and ComboQ and ComboQ2 <= ManaPercent() and ValidTarget(QTarget, Q.range+QTarget.boundingRadius) then
      CastQCollision(QTarget, "Combo")
    end
  end
  end

  if QTarget ~= nil then
    if not Menu.Combo.Q3 then
  
    local ComboQ = Menu.Combo.Q
    local ComboQ2 = Menu.Combo.Q2
    
    if Q.ready and ComboQ and ComboQ2 <= ManaPercent() and ValidTarget(QTarget, Q.range+QTarget.boundingRadius) then
      CastQwoCollision(QTarget, "Combo")
    end
  end
  end

  if WTarget ~= nil and Menu.Combo.W3 == 1 then
  
    local ComboW = Menu.Combo.W
    local ComboW2 = Menu.Combo.W2
    
    if W.ready and ComboW and ComboW2 <= ManaPercent() and ValidTarget(WTarget, W.range+WTarget.boundingRadius) then
      CastWAdv(WTarget, "Combo")
    end

  end

  if WTarget ~= nil and Menu.Combo.W3 == 2 then
  
    local ComboW = Menu.Combo.W
    local ComboW2 = Menu.Combo.W2
    
    if W.ready and ComboW and ComboW2 <= ManaPercent() and ValidTarget(WTarget, W.range+WTarget.boundingRadius) then
      CastWStn(WTarget, "Combo")
    end
    
  end
  
  if ETarget ~= nil then
  
    local ComboE = Menu.Combo.E
    local ComboE2 = Menu.Combo.E2
  
    if E.ready and ComboE and ComboE2 <= ManaPercent() then
    
      if ValidTarget(ETarget, Menu.Combo.range+ETarget.boundingRadius) then
        CastE(ETarget, "Combo")
      end
      
      for i, enemy in ipairs(EnemyHeroes) do
      
        if ValidTarget(enemy, Menu.Combo.range+100) then
          CastE(enemy, "Combo")
        end
        
      end
      
    end
    
  end

end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function Farm()

  local FarmQ = Menu.Farm.Q
  local FarmQ2 = Menu.Farm.Q2
  
  if Q.ready and FarmQ and FarmQ2 <= ManaPercent() then
    
    for i, minion in pairs(EnemyMinions.objects) do
    
      local QMinionDmg = GetDmg("Q", minion)
      
      if QMinionDmg >= minion.health and ValidTarget(minion, Q.range) then
        CastQwoCollision(minion)
      end
    end
    
    for i, minion in pairs(EnemyMinions.objects) do
    
      local AAMinionDmg = GetDmg("AA", minion)
      local QMinionDmg = GetDmg("Q", minion)
      
      if QMinionDmg+2.5*AAMinionDmg <= minion.health and ValidTarget(minion, Q.range) then
        CastQwoCollision(minion)
      end
      
    end
    
  end
  
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function JFarm()

  local JFarmQ = Menu.JFarm.Q
  local JFarmQ2 = Menu.JFarm.Q2
  local JFarmR = Menu.JFarm.R
  local JFarmR2 = Menu.JFarm.R2
  
  if Q.ready and JFarmQ and JFarmQ2 <= ManaPercent() then
  
    for i, junglemob in pairs(JungleMobs.objects) do
          
      local LargeJunglemob = nil
      
      for j = 1, #FocusJungleNames do
        if junglemob.name == FocusJungleNames[j] then
          LargeJunglemob = junglemob
          break
        end
        
      end
      
      if LargeJunglemob ~= nil and GetDistance(LargeJunglemob, mousePos) <= Q.range and ValidTarget(LargeJunglemob, Q.range) then
        CastQwoCollision(LargeJunglemob)
        return
      end
      
    end
    
    for i, junglemob in pairs(JungleMobs.objects) do
    
      if ValidTarget(junglemob, Q.range) then
        CastQwoCollision(junglemob)
      end
      
    end
    
  end
  
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function Harass()
  
  if QTarget ~= nil then
  
    local HarassQ = Menu.Harass.Q
    local HarassQ2 = Menu.Harass.Q2
    
    if Q.ready and HarassQ and HarassQ2 <= ManaPercent() and ValidTarget(QTarget, Q.range+QTarget.boundingRadius) then
      CastQwoCollision(QTarget, "Harass")
    end
    
  end
  
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function HarassAlways()

if IsRecall then
  return
else
  
  if QTarget ~= nil then
  
    local HarassQ = Menu.Harass.Q
    local HarassQ2 = Menu.Harass.Q2
    
    if Q.ready and HarassQ and HarassQ2 <= ManaPercent() and ValidTarget(QTarget, Q.range+QTarget.boundingRadius) then
      CastQwoCollision(QTarget, "Harass")
    end
  end

  if WTarget ~= nil then
  
    local HarassW = Menu.Harass.W
    local HarassW2 = Menu.Harass.W2
    
    if W.ready and HarassW and HarassW2 <= ManaPercent() and ValidTarget(WTarget, W.range+W.width+WTarget.boundingRadius) then
      CastWStn(WTarget, "Harass")
    end
  end

end
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function LastHit()

  local LastHitQ = Menu.LastHit.Q
  local LastHitQ2 = Menu.LastHit.Q2
  
  if Q.ready and LastHitQ and LastHitQ2 <= ManaPercent() then
  
    for i, minion in pairs(EnemyMinions.objects) do
    
      local QMinionDmg = GetDmg("Q", minion)
      
      if QMinionDmg >= minion.health and ValidTarget(minion, Q.range+Q.radius+100) then
        CastQwoCollision(minion, "LastHit")
      end
      
    end
    
  end
  
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function JSteal()

  local JStealQ = Menu.JSteal.Q
  
  if Q.ready and JStealQ then
  
    for i, junglemob in pairs(JungleMobs.objects) do
    
      local QJunglemobDmg = GetDmg("Q", junglemob)
      
      for j = 1, #FocusJungleNames do
      
        if junglemob.name == FocusJungleNames[j] and QJunglemobDmg >= junglemob.health and ValidTarget(junglemob, Q.range+Q.radius+junglemob.boundingRadius) or junglemob.charName:lower():find("dragon") and QJunglemobDmg >= junglemob.health and ValidTarget(junglemob, Q.range+Q.radius+junglemob.boundingRadius) then
          CastQwoCollision(junglemob, "JSteal")
        end
        
      end
      
    end
    
  end
  
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function JstealAlways()

if Menu.Control.tmpdisable then return
end

  if Q.ready and Menu.JSteal.Q then
  
    for i, junglemob in pairs(JungleMobs.objects) do
    
      local QJunglemobDmg = GetDmg("Q", junglemob)

      for j = 1, #FocusJungleNames do
      
        if junglemob.name == FocusJungleNames[j] and QJunglemobDmg >= junglemob.health and ValidTarget(junglemob, Q.range+Q.radius+junglemob.boundingRadius) or junglemob.charName:lower():find("dragon") and QJunglemobDmg >= junglemob.health and ValidTarget(junglemob, Q.range+Q.radius+junglemob.boundingRadius) then

        CastQwoCollision(junglemob, "JstealAlways")
        end
        
      end
      
    end
    
  end
  
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function KillSteal()

  local KillStealQ = Menu.KillSteal.Q
  local KillStealE = Menu.KillSteal.E
  
  for i, enemy in ipairs(EnemyHeroes) do
  
    local QTargetDmg = GetDmg("Q", enemy)
    local ETargetDmg = GetDmg("E", enemy)
    
    if Q.ready and KillStealQ and QTargetDmg >= enemy.health and ValidTarget(enemy, Q.range+enemy.boundingRadius) then
      CastQwoCollision(enemy, "KillSteal")
    end
    
    if E.ready and KillStealE and ETargetDmg >= enemy.health and ValidTarget(enemy, Menu.KillSteal.erange+enemy.boundingRadius) then
      CastE(enemy, "KillSteal")
    end
  end
end

function KillStealR()

  if EnemiesAround(myHero, 1000) >= Menu.KillSteal.minrange then
    return
  else

  local KillStealR = Menu.KillSteal.R
  
  for i, enemy in ipairs(EnemyHeroes) do
  
    local RTargetDmg = GetDmg("R", enemy)
    
    
    if R.ready and KillStealR and RTargetDmg >= enemy.health and ValidTarget(enemy, Menu.KillSteal.range) then
      CastSpell(_R, enemy)
    end
  end
end
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function Flee()
  MoveToMouse()
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function HealthPercent(unit)
  return (unit.health/unit.maxHealth)*100
end

function ManaPercent()
  return (myHero.mana/myHero.maxMana)*100
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function AddRange(unit)
  return unit.boundingRadius
end

function TrueRange(enemy)
  return myHero.range+AddRange(myHero)+AddRange(enemy)
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function GetDmg(spell, enemy)

  if enemy.health == 0 then
    return 0
  end
  
  local ADDmg = 0
  local APDmg = 0
  
  local Level = myHero.level
  local TotalDmg = myHero.totalDamage
  local AddDmg = myHero.addDamage
  local AP = myHero.ap
  local ArmorPen = myHero.armorPen
  local ArmorPenPercent = myHero.armorPenPercent
  local MagicPen = myHero.magicPen
  local MagicPenPercent = myHero.magicPenPercent
  
  local Armor = math.max(0, enemy.armor*ArmorPenPercent-ArmorPen)
  local ArmorPercent = Armor/(100+Armor)
  local MagicArmor = math.max(0, enemy.magicArmor*MagicPenPercent-MagicPen)
  local MagicArmorPercent = MagicArmor/(100+MagicArmor)
    
    if spell == "AA" and not Aim then
    ADDmg = TotalDmg
    elseif spell == "AA" and Aim then
    ADDmg = TotalDmg+TotalDmg*.5 
    elseif spell == "Q" then
    if Q.ready then
      ADDmg = 40*Q.level-10+(.1*Q.level+1.2)*TotalDmg
    end
    
    elseif spell == "E" then
  
    if E.ready then
      APDmg = 40*W.level+30+.8*AP
    end
    
    elseif spell == "R" then
  
    if R.ready then
      ADDmg = 225*R.level+25+.8*TotalDmg
    end
    
  end
  
  local TrueDmg = ADDmg*(1-ArmorPercent)+APDmg*(1-MagicArmorPercent)
  
  return TrueDmg
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function CastQCollision(unit, mode)
  
if unit.dead then return end  

if Menu.Prediction.Choice == 1 and VPred then
    local CastPosition, HitChance, Position = VPred:GetLineCastPosition(unit, Q.delay, Q.radius, Q.range, Q.speed, true)
    
    if HitChance >= (mode == nil and 1 or Menu.Prediction.VPrediction.Q) then
      CastSpell(_Q, CastPosition.x, CastPosition.z)
    end
  
  elseif Menu.Prediction.Choice == 2 and HPred then
    local CastPos, HitChance = HPred:GetPredict(HPSkillshot({type = "DelayLine", delay = Q.delay, range = Q.range, width = Q.radius, speed = Q.speed, collisionM = true, collisionH = true}), unit, myHero)
    if HitChance >= (mode == nil and 1 or Menu.Prediction.HPrediction.Q) then
      CastSpell(_Q, CastPos.x, CastPos.z)
    end
  
  elseif Menu.Prediction.Choice == 3 and SPred then
    local CastPosition, HitChance, PredPos = SPred:Predict(unit, Q.range, Q.speed, Q.delay, Q.radius, true, myHero)
    if HitChance >= (mode == nil and 1 or Menu.Prediction.SPrediction.Q) then
      CastSpell(_Q, CastPosition.x, CastPosition.z)
    end
    
  elseif Menu.Prediction.Choice == 4 and FHPred then
   local CastPosition, hc, info = FHPrediction.GetPrediction({range = Q.range, speed = Q.speed, delay = Q.delay, radius = Q.radius, type = SkillShotType.SkillshotMissileLine}, unit)
    if hc > (mode == nil and 1 or Menu.Prediction.FHPrediction.Q) and CastPosition ~= nil and not info.collision then
      CastSpell(_Q, CastPosition.x, CastPosition.z)
    end
  
  elseif Menu.Prediction.Choice == 5 and KPred then
    local CastPos, HitChance = KPred:GetPrediction(KPSkillshot({type = "DelayLine", delay = Q.delay, range = Q.range, width = Q.radius, speed = Q.speed}), unit, myHero, true)
    if HitChance >= (mode == nil and 1 or Menu.Prediction.KPrediction.Q) then
      CastSpell(_Q, CastPos.x, CastPos.z)
    end

  elseif Menu.Prediction.Choice == 6 and DPred then
    local state, hitPos, perc = DPred:predict("Q", unit, myHero, SkillShot.TYPE.LINE, Q.speed, Q.range, Q.width, Q.delay*1000, 0, {Minions = true, Champions = true})
    if perc >= (mode == nil and 50 or Menu.Prediction.DPrediction.Q) then
      CastSpell(_Q, hitPos.x, hitPos.z)
    end
    
end

end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function CastQwoCollision(unit, mode)
  
if unit.dead then return end

if Menu.Prediction.Choice == 1 and VPred then
    local CastPosition, HitChance, Position = VPred:GetLineCastPosition(unit, Q.delay, Q.radius, Q.range, Q.speed, false)
    
    if HitChance >= (mode == nil and 1 or Menu.Prediction.VPrediction.Q) then
      CastSpell(_Q, CastPosition.x, CastPosition.z)
    end
  
  elseif Menu.Prediction.Choice == 2 and HPred then
    local Pos, HitChance = HPred:GetPredict(HPSkillshot({type = "DelayLine", delay = Q.delay, range = Q.range, width = Q.radius, speed = Q.speed}), unit, myHero)
    if HitChance >= (mode == nil and 1 or Menu.Prediction.HPrediction.Q) then
      CastSpell(_Q, Pos.x, Pos.z)
    end
  
  elseif Menu.Prediction.Choice == 3 and SPred then
    local CastPosition, HitChance, PredPos = SPred:Predict(unit, Q.range, Q.speed, Q.delay, Q.radius, false, myHero)
    if HitChance >= (mode == nil and 1 or Menu.Prediction.SPrediction.Q) then
      CastSpell(_Q, CastPosition.x, CastPosition.z)
    end
    
  elseif Menu.Prediction.Choice == 4 and FHPred then
   local CastPosition, hc, info = FHPrediction.GetPrediction({range = Q.range, speed = Q.speed, delay = Q.delay, radius = Q.radius, type = SkillShotType.SkillshotMissileLine}, unit)
    if hc > (mode == nil and 1 or Menu.Prediction.FHPrediction.Q) and CastPosition ~= nil then
      CastSpell(_Q, CastPosition.x, CastPosition.z)
    end
  
  elseif Menu.Prediction.Choice == 5 and KPred then
    local Pos, HitChance = KPred:GetPrediction(KPSkillshot({type = "DelayLine", delay = Q.delay, range = Q.range, width = Q.radius, speed = Q.speed}), unit, myHero)
    if HitChance >= (mode == nil and 1 or Menu.Prediction.KPrediction.Q) then
      CastSpell(_Q, Pos.x, Pos.z)
    end

  elseif Menu.Prediction.Choice == 6 and DPred then
    local state, hitPos, perc = DPred:predict("Q", unit, myHero, SkillShot.TYPE.LINE, Q.speed, Q.range, Q.width, Q.delay*1000, 0, {Minions = false, Champions = false})
    if perc >= (mode == nil and 50 or Menu.Prediction.DPrediction.Q) then
      CastSpell(_Q, hitPos.x, hitPos.z)
    end
    
end

end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function CastWStn(unit, mode)
  
if unit.dead then return end
if GetDmg("AA", WTarget) >= WTarget.health then return end  

if Menu.Prediction.Choice == 1 and VPred then
    local CastPosition, HitChance, Position = VPred:GetCircularCastPosition(unit, W.delay, W.width, W.range, W.speed)
    
    if HitChance >= (mode == nil and 1 or Menu.Prediction.VPrediction.W) then
      CastSpell(_W, CastPosition.x, CastPosition.z)
    end
  
  elseif Menu.Prediction.Choice == 2 and HPred then
    local Pos, HitChance = HPred:GetPredict(HPSkillshot({type = "DelayCircle", delay = W.delay, range = W.range, radius = W.width, speed = W.speed}), unit, myHero)
    if HitChance >= (mode == nil and 1 or Menu.Prediction.HPrediction.W) then
      CastSpell(_W, Pos.x, Pos.z)
    end
  
  elseif Menu.Prediction.Choice == 3 and SPred then
    local CastPosition, HitChance, PredPos = SPred:Predict(unit, W.range, W.speed, W.delay, W.width, false, myHero)
    if HitChance >= (mode == nil and 1 or Menu.Prediction.SPrediction.W) then
      CastSpell(_W, CastPosition.x, CastPosition.z)
    end
    
  elseif Menu.Prediction.Choice == 4 and FHPred then
   local CastPosition, hc, info = FHPrediction.GetPrediction({range = W.range, speed = W.speed, delay = W.delay, radius = W.width, type = SkillShotType.SkillshotCircle}, unit)
    if hc > (mode == nil and 1 or Menu.Prediction.FHPrediction.W) and CastPosition ~= nil then
      CastSpell(_W, CastPosition.x, CastPosition.z)
    end
  
  elseif Menu.Prediction.Choice == 5 and KPred then
    local Pos, HitChance = KPred:GetPrediction(KPSkillshot({type = "DelayCircle", delay = W.delay, range = W.range, radius = W.width, speed = W.speed}), unit, myHero)
    if HitChance >= (mode == nil and 1 or Menu.Prediction.KPrediction.W) then
      CastSpell(_W, Pos.x, Pos.z)
    end

  elseif Menu.Prediction.Choice == 6 and DPred then
    local state, hitPos, perc = DPred:predict("W", unit, myHero, SkillShot.TYPE.CIRCLE, W.speed, W.range, W.width, W.delay*1000, math.huge)
    if perc >= (mode == nil and 50 or Menu.Prediction.DPrediction.W) then
      CastSpell(_W, hitPos.x, hitPos.z)
    end
    
end

end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function CastWAdv(unit, mode)
  
if unit.dead then return end  
if GetDmg("AA", WTarget) >= WTarget.health then return end 

local r = myHero.range
local trange = r < 700 and r or 700

if Menu.Prediction.Choice == 1 and VPred and not isFleeingFromMe(unit, trange) or not amIFleeing(unit, trange) then
    local CastPosition, HitChance, Position = VPred:GetCircularCastPosition(unit, W.delay, W.width, W.range, W.speed)
    
    if HitChance >= (mode == nil and 1 or Menu.Prediction.VPrediction.W) then
      CastSpell(_W, CastPosition.x, CastPosition.z)
    end
  
  elseif Menu.Prediction.Choice == 2 and HPred and not isFleeingFromMe(unit, trange) or not amIFleeing(unit, trange) then
    local Pos, HitChance = HPred:GetPredict(HPSkillshot({type = "DelayCircle", delay = W.delay, range = W.range, radius = W.width, speed = W.speed}), unit, myHero)
    if HitChance >= (mode == nil and 1 or Menu.Prediction.HPrediction.W) then
      CastSpell(_W, Pos.x, Pos.z)
    end
  
  elseif Menu.Prediction.Choice == 3 and SPred and not isFleeingFromMe(unit, trange) or not amIFleeing(unit, trange) then
    local CastPosition, HitChance, PredPos = SPred:Predict(unit, W.range, W.speed, W.delay, W.width, false, myHero)
    if HitChance >= (mode == nil and 1 or Menu.Prediction.SPrediction.W) then
      CastSpell(_W, CastPosition.x, CastPosition.z)
    end
    
  elseif Menu.Prediction.Choice == 4 and FHPred and not isFleeingFromMe(unit, trange) or not amIFleeing(unit, trange) then
   local CastPosition, hc, info = FHPrediction.GetPrediction({range = W.range, speed = W.speed, delay = W.delay, radius = W.width, type = SkillShotType.SkillshotCircle}, unit)
    if hc > (mode == nil and 1 or Menu.Prediction.FHPrediction.W) and CastPosition ~= nil then
      CastSpell(_W, CastPosition.x, CastPosition.z)
    end
  
  elseif Menu.Prediction.Choice == 5 and KPred and not isFleeingFromMe(unit, trange) or not amIFleeing(unit, trange) then
    local Pos, HitChance = KPred:GetPrediction(KPSkillshot({type = "DelayCircle", delay = W.delay, range = W.range, radius = W.width, speed = W.speed}), unit, myHero)
    if HitChance >= (mode == nil and 1 or Menu.Prediction.KPrediction.W) then
      CastSpell(_W, Pos.x, Pos.z)
    end

  elseif Menu.Prediction.Choice == 6 and DPred and not isFleeingFromMe(unit, trange) or not amIFleeing(unit, trange) then
    local state,hitPos,perc = DPred:predict("W",unit,myHero,SkillShot.TYPE.CIRCLE,W.speed,W.range,W.width,W.delay*1000,math.huge)
    if perc >= (mode == nil and 50 or Menu.Prediction.DPrediction.W) then
      CastSpell(_W, hitPos.x, hitPos.z)
    end
    
end

end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function CastE(unit, mode)

if unit.dead then return end  

if Menu.Prediction.Choice == 1 and VPred then
    local CastPosition, HitChance, Position = VPred:GetLineCastPosition(unit, E.delay, E.width, E.range, E.speed, myHero, true)
    
    if HitChance >= (mode == nil and 1 or Menu.Prediction.VPrediction.E) then
      CastSpell(_E, CastPosition.x, CastPosition.z)
    end
  
  elseif Menu.Prediction.Choice == 2 and HPred then
    local Pos, HitChance = HPred:GetPredict(HPSkillshot({type = "DelayLine", delay = E.delay, range = E.range, width = E.width, speed = E.speed, collisionM = true, collisionH = true}), unit, myHero)
    if HitChance >= (mode == nil and 1 or Menu.Prediction.HPrediction.E) then
      CastSpell(_E, Pos.x, Pos.z)
    end
  
  elseif Menu.Prediction.Choice == 3 and SPred then
    local CastPosition, HitChance, PredPos = SPred:Predict(unit, E.range, E.speed, E.delay, E.width, true, myHero)
    if HitChance >= (mode == nil and 1 or Menu.Prediction.SPrediction.E) then
      CastSpell(_E, CastPosition.x, CastPosition.z)
    end
    
  elseif Menu.Prediction.Choice == 4 and FHPred then
   local CastPosition, hc, info = FHPrediction.GetPrediction({range = E.range, speed = E.speed, delay = E.delay, radius = E.width, type = SkillShotType.SkillshotMissileLine}, unit)
    if hc > (mode == nil and 1 or Menu.Prediction.FHPrediction.E) and CastPosition ~= nil and not info.collision then
      CastSpell(_E, CastPosition.x, CastPosition.z)
    end
  
  elseif Menu.Prediction.Choice == 5 and KPred then
    local Pos, HitChance = KPred:GetPrediction(KPSkillshot({type = "DelayLine", delay = E.delay, range = E.range, width = E.width, speed = E.speed}), unit, myHero, true)
    if HitChance >= (mode == nil and 1 or Menu.Prediction.KPrediction.E) then
      CastSpell(_E, Pos.x, Pos.z)
    end

  elseif Menu.Prediction.Choice == 6 and DPred then
    local state, hitPos, perc = DPred:predict("E", unit, myHero, SkillShot.TYPE.LINE, E.speed, E.range, E.width, E.delay*1000, 0, {Minions = true, Champions = true})
    if perc >= (mode == nil and 50 or Menu.Prediction.DPrediction.E) then
      CastSpell(_E, hitPos.x, hitPos.z)
    end
    
end

end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function MoveToMouse()

  MPos = Vector(mousePos.x, mousePos.y, mousePos.z)
  HeroPos = Vector(myHero.x, myHero.y, myHero.z)
  DashPos = HeroPos + ( HeroPos - MPos )*(500/GetDistance(mousePos))
  myHero:MoveTo(mousePos.x, mousePos.z)
  CastSpell(_E, DashPos.x, DashPos.z)
  myHero:MoveTo(mousePos.x, mousePos.z)

end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

--[[function DebugDraw()
if myHero.dead then
  return
end

if Menu.Draw.On then

if QTarget ~= nil then
    DrawCircle(QTarget.x, QTarget.y, QTarget.z, Q.radius, ARGB(0xFF, 0xFF, 0xFF, 0xFF))
  end
  
  if RTarget ~= nil then
    DrawCircle(RTarget.x, RTarget.y, RTarget.z, R.width/2, ARGB(0xFF, 0xFF, 0xFF, 0xFF))
  end
  
  if QHitChance ~= nil then
  
    if QHitChance < 1 then
      Qcolor = ARGB(0xFF, 0xFF, 0x00, 0x00)
    elseif QHitChance == 3 then
      Qcolor = ARGB(0xFF, 0x00, 0x54, 0xFF)
    elseif QHitChance >= 2 then
      Qcolor = ARGB(0xFF, 0x1D, 0xDB, 0x16)
    elseif QHitChance >= 1 then
      Qcolor = ARGB(0xFF, 0xFF, 0xE4, 0x00)
    end
  
  end
  end
  if RHitChance ~= nil then
  
    if RHitChance == -1 then
      Rcolor = ARGB(0xFF, 0x00, 0x00, 0x00)
    elseif RHitChance < 1 then
      Rcolor = ARGB(0xFF, 0xFF, 0x00, 0x00)
    elseif RHitChance == 3 then
      Rcolor = ARGB(0xFF, 0x00, 0x54, 0xFF)
    elseif RHitChance >= 2 then
      Rcolor = ARGB(0xFF, 0x1D, 0xDB, 0x16)
    elseif RHitChance >= 1 then
      Rcolor = ARGB(0xFF, 0xFF, 0xE4, 0x00)
    end
    
  end
  
  if Menu.Draw.Prd then
    
  if QPos ~= nil then
  
    DrawCircle(QPos.x, QPos.y, QPos.z, Q.radius, Qcolor)
    DrawLine3D(myHero.x, myHero.y, myHero.z, QPos.x, QPos.y, QPos.z, 2, Qcolor)
    QPos = nil
  
  elseif RPos ~= nil then
    DrawCircle(RPos.x, RPos.y, RPos.z, R.width/2, Rcolor)
    DrawLine3D(myHero.x, myHero.y, myHero.z, RPos.x, RPos.y, RPos.z, 2, Rcolor)
    RPos = nil
  end
  end
  
    if QHitChance ~= nil then
      DrawText("Q HitChance: "..QHitChance, 20, 1250, 550, Qcolor)
      QHitChance = nil
    end
    
    if RHitChance ~= nil then
      DrawText("R HitChance: "..RHitChance, 20, 1250, 600, Rcolor)
      RHitChance = nil
    end
    
    if Menu.Draw.ownp then
    
    if myHero.hasMovePath and myHero.pathCount >= 2 then
    
      local IndexPath = myHero:GetPath(myHero.pathIndex)
      
      if IndexPath then
        DrawLine3D(myHero.x, myHero.y, myHero.z, IndexPath.x, IndexPath.y, IndexPath.z, 1, ARGB(114, 114, 4, 34))
      end
      
      for i=myHero.pathIndex, myHero.pathCount-1 do
      
        local Path = myHero:GetPath(i)
        local Path2 = myHero:GetPath(i+1)
        
        DrawLine3D(Path.x, Path.y, Path.z, Path2.x, Path2.y, Path2.z, 1, ARGB(114, 114, 4, 34))
      end
      
    end
    
    if Menu.Draw.opp then
    
    for i, enemy in ipairs(EnemyHeroes) do
    
      if enemy == nil then
        return
      end
      
      if enemy.hasMovePath and enemy.pathCount >= 2 then
      
        local IndexPath = enemy:GetPath(enemy.pathIndex)
        
        if IndexPath then
          DrawLine3D(enemy.x, enemy.y, enemy.z, IndexPath.x, IndexPath.y, IndexPath.z, 1, ARGB(255, 255, 255, 255))
        end
        
        for i=enemy.pathIndex, enemy.pathCount-1 do
        
          local Path = enemy:GetPath(i)
          local Path2 = enemy:GetPath(i+1)
          
          DrawLine3D(Path.x, Path.y, Path.z, Path2.x, Path2.y, Path2.z, 1, ARGB(255, 255, 255, 255))
          
          print(FocusJungleNames)
          print(Q.range)
          print(R.range)
        end
        
      end
      
    end
    
  end
  
end

end]]--

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function OnAnimation(unit, animation)

  if not unit.isMe then
    return
  end
  
  if animation == "recall" then
    IsRecall = true
  elseif animation == "recall_winddown" or animation == "Run" or animation == "Spell1" or animation == "Spell2" or animation == "Spell3" or animation == "Spell4" then
    IsRecall = false
  end
  
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function DrawDamage(unit)

  local SPos, EPos = GetHealthPos(unit)
  local PercentDamage = math.min(unit.health/unit.maxHealth, ComboDamage(unit)/unit.maxHealth)
  local DPos = Point(EPos.x-104*PercentDamage, SPos.y)
  
  if (GetDmg("R", unit) > unit.health) then
    DrawText("Possible Kill with R: " .. math.floor(GetDmg("R", unit)-unit.health), 25, SPos.x, SPos.y-85, ARGB(0xFF, 0xFF, 0xFF, 0xFF))
  end

  if (ComboDamage(unit) > unit.health) then
    DrawText("OverKill: " .. math.floor(ComboDamage(unit)-unit.health), 20, SPos.x, SPos.y-55, ARGB(0xFF, 0xFF, 0xFF, 0xFF))
  end
  
  if R.ready then
   
    local RUnitDmg = GetDmg("R", unit) or 0
    local RPercentDamage = math.min(unit.health/unit.maxHealth, RUnitDmg/unit.maxHealth)
    local RPos = Point(DPos.x+104*RPercentDamage, EPos.y)
    
    DrawLine(RPos.x, RPos.y, EPos.x, EPos.y, 11, 0x78FF7D00 or 0x78FFFFFF)
    DrawLine(DPos.x, DPos.y, RPos.x, RPos.y, 11, 0x78FF7D00 or 0x78FFFFFF)
  else
    DrawLine(DPos.x, DPos.y, EPos.x, EPos.y, 11, 0x78FF7D00 or 0x78FFFFFF)
  end
  
end

function GetHealthPos(unit)

  local Pos = GetUnitHPBarPos(unit)
  local PosOffset = GetUnitHPBarOffset(unit)
  
  Pos.x = Pos.x-66
  
  if unit.charName == "Darius" then
    Pos.x = Pos.x-7
  end
  
  Pos.y = Pos.y+61*PosOffset.y+6
  
  return Point(Pos.x, Pos.y), Point(Pos.x+104*(unit.health/unit.maxHealth), Pos.y)
end

function ComboDamage(unit)

  local AA_UnitDmg = GetDmg("AA", unit) or 0
  local Q_UnitDmg = Q.ready and GetDmg("Q", unit) or 0
  local E_UnitDmg = E.ready and GetDmg("E", unit) or 0
  local R_UnitDmg = R.ready and GetDmg("R", unit) or 0
  
  return AA_UnitDmg+Q_UnitDmg+E_UnitDmg+R_UnitDmg
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function DrawRectangleButton(x, y, w, h, color)
local floor = math.floor
local points = {}
points[1] = D3DXVECTOR2(floor(x), floor(y))
points[2] = D3DXVECTOR2(floor(x + w), floor(y))
local points2 = {}
points2[1] = D3DXVECTOR2(floor(x), floor(y - h/2))
points2[2] = D3DXVECTOR2(floor(x + w), floor(y - h/2))
points2[3] = D3DXVECTOR2(floor(x + w), floor(y + h/2))
points2[4] = D3DXVECTOR2(floor(x), floor(y + h/2))
local t = GetCursorPos()
polygon = Polygon(Point(points2[1].x, points2[1].y), Point(points2[2].x, points2[2].y), Point(points2[3].x, points2[3].y), Point(points2[4].x, points2[4].y))
if polygon:contains(Point(t.x, t.y)) then
DrawLines2(points, floor(h), color)
else
DrawLines2(points, floor(h), ARGB(255, 49, 112, 131))
end
end

function OnDraw()
  if not Loaded then
    return
  end

  if Menu.Draw.CLFPS then return
    OnDrawFPS()
  end

  if not Menu.Draw.On or myHero.dead then
    return
  end
  
  if Menu.Draw.ComboDamage then
    for i, hero in ipairs(GetEnemyHeroes()) do
      if ValidTarget(hero, 3000) then
      DrawDamage(hero)
      end
    end
  end

  if Menu.Control.OnJST and Menu.Control.tmpdisable and Q.ready then
    local myPos = WorldToScreen(D3DXVECTOR3(myHero.x, myHero.y, myHero.z))
    DrawText("Junglesteal Toggle Disabled!", 30, myPos.x, myPos.y, ARGB(0xFF, 0xFF, 0xFF, 0xFF))
  end

  if Menu.Draw.ownp then
    
    if myHero.hasMovePath and myHero.pathCount >= 1 then
    
      local IndexPath = myHero:GetPath(myHero.pathIndex)
      
      if IndexPath then
        DrawLine3D(myHero.x, myHero.y, myHero.z, IndexPath.x, IndexPath.y, IndexPath.z, 1, ARGB(255, 152, 130, 147))
      end
      
      for i=myHero.pathIndex, myHero.pathCount-1 do
      
        local Path = myHero:GetPath(i)
        local Path2 = myHero:GetPath(i+1)
        
        DrawLine3D(Path.x, Path.y, Path.z, Path2.x, Path2.y, Path2.z, 1, ARGB(255, 152, 130, 147))
      end
      
    end
  
  if Menu.Draw.opp then
    
    for i, enemy in ipairs(EnemyHeroes) do
    
      if enemy == nil then
        return
      end
      
      if enemy.hasMovePath and enemy.pathCount >= 1 then
      
        local IndexPath = enemy:GetPath(enemy.pathIndex)
        
        if IndexPath then
          DrawLine3D(enemy.x, enemy.y, enemy.z, IndexPath.x, IndexPath.y, IndexPath.z, 1, ARGB(255, 255, 255, 255))
        end
        
        for i=enemy.pathIndex, enemy.pathCount-1 do
        
          local Path = enemy:GetPath(i)
          local Path2 = enemy:GetPath(i+1)
          
          DrawLine3D(Path.x, Path.y, Path.z, Path2.x, Path2.y, Path2.z, 1, ARGB(255, 255, 255, 255))
          
        end
        
      end
      
    end
    
  end
  
  end
  
  if PopUp then
              local w, h1, h2 = (WINDOW_W*0.50), (WINDOW_H*.15), (WINDOW_H*.9)
              DrawLine(w, h1/1.05, w, h2/1.97, w/1.75, ARGB(80, 0, 0, 0)) -- border & aero
              DrawLine(w, h1, w, h2/2, w/1.8, ARGB(255, 22, 12, 0)) -- background
              DrawTextA(tostring("Welcome to Uneeesh Series - Caitlyn"), WINDOW_H*.028, (WINDOW_W/2), (WINDOW_H*.18), ARGB(255, 0, 222, 225),"center","center")
              DrawTextA(tostring("Latest Changelog (" .. Version .. ") ;"), WINDOW_H*.015, (WINDOW_W/2.65), (WINDOW_H*.210), ARGB(255, 0, 222, 225))
              DrawTextA(tostring(" "), WINDOW_H*.015, (WINDOW_W/2.65), (WINDOW_H*.210), ARGB(255, 255, 255, 255))
              DrawTextA(tostring(" "), WINDOW_H*.015, (WINDOW_W/2.65), (WINDOW_H*.225), ARGB(255, 255, 255, 255))
              DrawTextA(tostring("- Re-Enabled SAC:Reborn."), WINDOW_H*.015, (WINDOW_W/2.70), (WINDOW_H*.240), ARGB(255, 0, 222, 225))
              DrawTextA(tostring(" "), WINDOW_H*.015, (WINDOW_W/2.70), (WINDOW_H*.260), ARGB(255, 0, 222, 225))
              DrawTextA(tostring(" "), WINDOW_H*.015, (WINDOW_W/2.70), (WINDOW_H*.280), ARGB(255, 0, 222, 225))
              local w, h1, h2 = (WINDOW_W*0.49), (WINDOW_H*.70), (WINDOW_H*.75)
              DrawLine(w, h1/1.775, w, h2/1.68, w*.11, ARGB(255, 0, 0, 0))
              DrawRectangleButton(WINDOW_W*0.467, WINDOW_H/2.375, WINDOW_W*.047, WINDOW_H*.041, ARGB(255, 255, 0, 0))
              DrawTextA(tostring("OK"), WINDOW_H*.02, (WINDOW_W/2)*.98, (WINDOW_H/2.375), ARGB(255, 0, 222, 225),"center","center")
              DrawTextA(tostring("                                                                                                      IZSHA"), WINDOW_H*.015, (WINDOW_W/2.65), (WINDOW_H*.355), ARGB(255, 0, 222, 225))
  end

  if Menu.Draw.Trg then
    if QTarget ~= nil then
    DrawCircle(QTarget.x, QTarget.y, QTarget.z, 80, 0x78FF7D00 or 0x78FFFFFF)
  elseif ETarget ~= nil then
    DrawCircle(ETarget.x, ETarget.y, ETarget.z, 50, 0x78FF7D00 or 0x78FFFFFF)
    end
  end
  
  --[[if Menu.Draw.Prd and Menu.Predictions.Prediction == 2 then
  if QPos ~= nil then
    DrawCircle(QPos.x, QPos.y, QPos.z, Q.radius, ARGB(0xFF, 0x1D, 0xDB, 0x16))
    DrawLine3D(myHero.x, myHero.y, myHero.z, QPos.x, QPos.y, QPos.z, 2, ARGB(0xFF, 0x1D, 0xDB, 0x16))
    QPos = nil
  elseif RPos ~= nil then
    DrawCircle(RPos.x, RPos.y, RPos.z, R.width/2, 0xFF, 0x1D, 0xDB, 0x16)
    DrawLine3D(myHero.x, myHero.y, myHero.z, RPos.x, RPos.y, RPos.z, 2, ARGB(0xFF, 0x1D, 0xDB, 0x16))
    RPos = nil
  end
end]]--

  if Menu.Draw.AA then
    DrawCircle(myHero.x, myHero.y, myHero.z, myHero.range+myHero.boundingRadius, RGB(Menu.Draw.CLA[2], Menu.Draw.CLA[3], Menu.Draw.CLA[4]))
  end
  
  if Menu.Draw.Q and Q.ready then
    DrawCircle(myHero.x, myHero.y, myHero.z, Q.range-75, RGB(Menu.Draw.CLQ[2], Menu.Draw.CLQ[3], Menu.Draw.CLQ[4]))
  end

  if Menu.Draw.W and W.ready then
    DrawCircle(myHero.x, myHero.y, myHero.z, W.range-300, RGB(Menu.Draw.CLW[2], Menu.Draw.CLW[3], Menu.Draw.CLW[4]))
  end
    
  if Menu.Draw.E and E.ready then
    DrawCircle(myHero.x, myHero.y, myHero.z, E.range-60, RGB(Menu.Draw.CLE[2], Menu.Draw.CLE[3], Menu.Draw.CLE[4]))
  end
  
  if Menu.Draw.I and I.ready then
    DrawCircle(myHero.x, myHero.y, myHero.z, I.range, RGB(Menu.Draw.CLI[2], Menu.Draw.CLI[3], Menu.Draw.CLI[4]))
  end
end

function Anouncer()
  if Menu.Combo.Q3 then
    ScriptMsg("Warning:Collision check for Q Enabled, it won't cast Q if object detected between target and Caitlyn.")
    return
  end

end

---------------------------------------------------------------------------------

function OnDrawFPS()
  if not Loaded then
    return
  end

  if not Menu.Draw.On or myHero.dead then
    return
  end
  
  if Menu.Draw.ComboDamage then
    for i, hero in ipairs(GetEnemyHeroes()) do
      if ValidTarget(hero, 3000) then
      DrawDamage(hero)
      end
    end
  end

  if Menu.Control.OnJST and Menu.Control.tmpdisable and Q.ready then
    local myPos = WorldToScreen(D3DXVECTOR3(myHero.x, myHero.y, myHero.z))
    DrawText("Junglesteal Toggle Disabled!", 30, myPos.x, myPos.y, ARGB(0xFF, 0xFF, 0xFF, 0xFF))
  end

  if Menu.Draw.ownp then
    
    if myHero.hasMovePath and myHero.pathCount >= 2 then
    
      local IndexPath = myHero:GetPath(myHero.pathIndex)
      
      if IndexPath then
        DrawLine3D(myHero.x, myHero.y, myHero.z, IndexPath.x, IndexPath.y, IndexPath.z, 1, ARGB(255, 152, 130, 147))
      end
      
      for i=myHero.pathIndex, myHero.pathCount-1 do
      
        local Path = myHero:GetPath(i)
        local Path2 = myHero:GetPath(i+1)
        
        DrawLine3D(Path.x, Path.y, Path.z, Path2.x, Path2.y, Path2.z, 1, ARGB(255, 152, 130, 147))
      end
      
    end
  
  if Menu.Draw.opp then
    
    for i, enemy in ipairs(EnemyHeroes) do
    
      if enemy == nil then
        return
      end
      
      if enemy.hasMovePath and enemy.pathCount >= 2 then
      
        local IndexPath = enemy:GetPath(enemy.pathIndex)
        
        if IndexPath then
          DrawLine3D(enemy.x, enemy.y, enemy.z, IndexPath.x, IndexPath.y, IndexPath.z, 1, ARGB(255, 255, 255, 255))
        end
        
        for i=enemy.pathIndex, enemy.pathCount-1 do
        
          local Path = enemy:GetPath(i)
          local Path2 = enemy:GetPath(i+1)
          
          DrawLine3D(Path.x, Path.y, Path.z, Path2.x, Path2.y, Path2.z, 1, ARGB(255, 255, 255, 255))
          
        end
        
      end
      
    end
    
  end
  
  end

  if PopUp then
              local w, h1, h2 = (WINDOW_W*0.50), (WINDOW_H*.15), (WINDOW_H*.9)
              DrawLine(w, h1/1.05, w, h2/1.97, w/1.75, ARGB(80, 0, 0, 0)) -- border & aero
              DrawLine(w, h1, w, h2/2, w/1.8, ARGB(255, 22, 12, 0)) -- background
              DrawTextA(tostring("Welcome to Uneeesh Series - Caitlyn"), WINDOW_H*.028, (WINDOW_W/2), (WINDOW_H*.18), ARGB(255, 0, 222, 225),"center","center")
              DrawTextA(tostring("Latest Changelog (" .. Version .. ") ;"), WINDOW_H*.015, (WINDOW_W/2.65), (WINDOW_H*.210), ARGB(255, 0, 222, 225))
              DrawTextA(tostring(" "), WINDOW_H*.015, (WINDOW_W/2.65), (WINDOW_H*.210), ARGB(255, 255, 255, 255))
              DrawTextA(tostring(" "), WINDOW_H*.015, (WINDOW_W/2.65), (WINDOW_H*.225), ARGB(255, 255, 255, 255))
              DrawTextA(tostring("- Re-Enabled SAC:Reborn."), WINDOW_H*.015, (WINDOW_W/2.70), (WINDOW_H*.240), ARGB(255, 0, 222, 225))
              DrawTextA(tostring(" "), WINDOW_H*.015, (WINDOW_W/2.70), (WINDOW_H*.260), ARGB(255, 0, 222, 225))
              DrawTextA(tostring(" "), WINDOW_H*.015, (WINDOW_W/2.70), (WINDOW_H*.280), ARGB(255, 0, 222, 225))
              local w, h1, h2 = (WINDOW_W*0.49), (WINDOW_H*.70), (WINDOW_H*.75)
              DrawLine(w, h1/1.775, w, h2/1.68, w*.11, ARGB(255, 0, 0, 0))
              DrawRectangleButton(WINDOW_W*0.467, WINDOW_H/2.375, WINDOW_W*.047, WINDOW_H*.041, ARGB(255, 255, 0, 0))
              DrawTextA(tostring("OK"), WINDOW_H*.02, (WINDOW_W/2)*.98, (WINDOW_H/2.375), ARGB(255, 0, 222, 225),"center","center")
              DrawTextA(tostring("                                                                                                      IZSHA"), WINDOW_H*.015, (WINDOW_W/2.65), (WINDOW_H*.355), ARGB(255, 0, 222, 225))
  end
  
  if Menu.Draw.Trg then
    if QTarget ~= nil then
    CircleDraw(QTarget.x, QTarget.y, QTarget.z, 80, 0x78FF7D00 or 0x78FFFFFF)
  elseif ETarget ~= nil then
    CircleDraw(ETarget.x, ETarget.y, ETarget.z, 50, 0x78FF7D00 or 0x78FFFFFF)
    end
  end
  
  --[[if Menu.Draw.Prd and Menu.Predictions.Prediction == 2 then
  if QPos ~= nil then
    CircleDraw(QPos.x, QPos.y, QPos.z, Q.radius, ARGB(0xFF, 0x1D, 0xDB, 0x16))
    DrawLine3D(myHero.x, myHero.y, myHero.z, QPos.x, QPos.y, QPos.z, 2, ARGB(0xFF, 0x1D, 0xDB, 0x16))
    QPos = nil
  elseif RPos ~= nil then
    CircleDraw(RPos.x, RPos.y, RPos.z, R.width/2, 0xFF, 0x1D, 0xDB, 0x16)
    DrawLine3D(myHero.x, myHero.y, myHero.z, RPos.x, RPos.y, RPos.z, 2, ARGB(0xFF, 0x1D, 0xDB, 0x16))
    RPos = nil
  end
end]]--
  
  if Menu.Draw.AA then
      CircleDraw(myHero.x, myHero.y, myHero.z, myHero.range+60+myHero.boundingRadius, ARGB(Menu.Draw.CLA[1], Menu.Draw.CLA[2],Menu.Draw.CLA[3],Menu.Draw.CLA[4]))
    end
  
  if Menu.Draw.CLFPS and Menu.Draw.Q and Q.ready then
      CircleDraw(myHero.x, myHero.y, myHero.z, Q.range+15, ARGB(Menu.Draw.CLQ[1], Menu.Draw.CLQ[2],Menu.Draw.CLQ[3],Menu.Draw.CLQ[4]))
    end

  if Menu.Draw.CLFPS and Menu.Draw.W and W.ready then
      CircleDraw(myHero.x, myHero.y, myHero.z, W.range-245, ARGB(Menu.Draw.CLW[1], Menu.Draw.CLW[2],Menu.Draw.CLW[3],Menu.Draw.CLW[4]))
    end
  
  if Menu.Draw.CLFPS and Menu.Draw.E and E.ready then
      CircleDraw(myHero.x, myHero.y, myHero.z, E.range+40, ARGB(Menu.Draw.CLE[1], Menu.Draw.CLE[2],Menu.Draw.CLE[3],Menu.Draw.CLE[4]))
    end
  
  if Menu.Draw.I and I.ready then
    CircleDraw(myHero.x, myHero.y, myHero.z, I.range, ARGB(Menu.Draw.CLI[1], Menu.Draw.CLI[2],Menu.Draw.CLI[3],Menu.Draw.CLI[4]))
   end
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
    radius = radius or 300
    quality = math.max(8,math.floor(180/math.deg((math.asin((chordlength/(2*radius)))))))
    quality = 2 * math.pi / quality
    radius = radius*.92
    local points = {}
    for theta = 0, 2 * math.pi + quality, quality do
        local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
        points[#points + 1] = D3DXVECTOR2(c.x, c.y)
    end
    DrawLines2(points, width or 1, color or 4294967295)
end

function DrawCircle2(x, y, z, radius, color)
    local vPos1 = Vector(x, y, z)
    local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
    local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
    local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
    if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y })  then
    DrawCircleNextLvl(x, y, z, radius, 1, color, Menu.Draw.Quality)
    end
end

function CircleDraw(x,y,z,radius, color)
  DrawCircle2(x, y, z, radius, color)
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
  
function SkinLoad()
    Menu.Autom.ChgSki:addParam("upski", "Change Skin", SCRIPT_PARAM_ONOFF, false);
    Menu.Autom.ChgSki:setCallback("upski", function(nV)
        if (nV) then
            SetSkin(myHero, Menu.Autom.ChgSki.skinID)
        else
            SetSkin(myHero, -1)
        end
    end)
    Menu.Autom.ChgSki:addParam('skinID', 'Skin', SCRIPT_PARAM_LIST, 1, {"Resistance", "Sheriff", "Safari", "Arctic Warfare", "Officer", "Headhunter", "Chroma Pack: Pink", "Chroma Pack: Green", "Chroma Pack: Blue", "Lunar Wraith", "Classic"})
    Menu.Autom.ChgSki:setCallback('skinID', function(nV)
        if (Menu.Autom.ChgSki.upski) then
            SetSkin(myHero, nV)
        end
    end)
    
    if (Menu.Autom.ChgSki.upski) then
        SetSkin(myHero, Menu.Autom.ChgSki.skinID)
    end
end

function AutoBuy()
  
  if GetGameTimer() < 60 then
    if Menu.Autom.buyme.buydoran then
      BuyItem(1055)
    end
    if Menu.Autom.buyme.buypot then
      BuyItem(2003)
    end
    if Menu.Autom.buyme.taketrinket then
      BuyItem(3340)
    end
  end
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function CheckLevelChange()
    if LastLevelCheck + 250 < GetTickCount() and myHero.level < 19 then
        if GetGame().map.index == 8 and myHero.level < 4 and Menu.Autom.autolevel.UseAutoLevelFirst then
            LevelSpell(_Q)
            LevelSpell(_W)
            LevelSpell(_E)
        end

        LastLevelCheck = GetTickCount()
        if myHero.level ~= LastHeroLevel then
            DelayAction(function() LevelUpSpell() end, 0.25)
            LastHeroLevel = myHero.level
        end
    end
end

function LevelUpSpell()
    if Menu.Autom.autolevel.UseAutoLevelFirst and myHero.level < 4 then
        LevelSpell(AutoLevelSpellTable[AutoLevelSpellTable["SpellOrder"][Menu.Autom.autolevel.First3Level]][myHero.level])
    end

    if Menu.Autom.autolevel.UseAutoLevelRest and myHero.level > 3 then
        LevelSpell(AutoLevelSpellTable[AutoLevelSpellTable["SpellOrder"][Menu.Autom.autolevel.RestLevel]][myHero.level])
    end
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function OnBush()

local WardSlot = nil
  if GetInventorySlotItem(2045) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(2045)) == READY then
    WardSlot = GetInventorySlotItem(2045)
  elseif GetInventorySlotItem(2049) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(2049)) == READY then
    WardSlot = GetInventorySlotItem(2049)
  elseif GetInventorySlotItem(3340) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(3340)) == READY or 
  GetInventorySlotItem(3350) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(3350)) == READY or 
  GetInventorySlotItem(3361) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(3361)) == READY or 
  GetInventorySlotItem(3363) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(3363)) == READY or
  GetInventorySlotItem(3411) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(3411)) == READY or
  GetInventorySlotItem(3342) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(3342)) == READY or
  GetInventorySlotItem(3362) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(3362)) == READY  then
    WardSlot = 12
  elseif GetInventorySlotItem(2044) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(2044)) == READY then
    WardSlot = GetInventorySlotItem(2044)
  elseif GetInventorySlotItem(2043) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(2043)) == READY then
    WardSlot = GetInventorySlotItem(2043)
  end

  return WardSlot
end

function FindBush(x0, y0, z0, maxRadius, precision)

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

function Bushfind()
  if lastTime +15 > os.clock() then return end
  for _,c in pairs(GetEnemyHeroes()) do   
    if not c.dead and not c.visible then
      local time=lasttime[ c.networkID ]  --last seen time
      local pos=lastpos [ c.networkID ]   --last seen pos
      local clock=os.clock()
      
      if time and pos and clock-time < 5 and GetDistanceSqr(pos)< 1005000 then
        local FoundBush = FindBush(pos.x,pos.y,pos.z,100)
    
        if FoundBush and GetDistanceSqr(FoundBush)<600*600 then
          local WardSlot = OnBush()
          
          if WardSlot then
            CastSpell(WardSlot,FoundBush.x,FoundBush.z)
            lastTime = os.clock()
            return
          end
        end
      end
    end
  end
end
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
