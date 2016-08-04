local Version = 1.457
local FileName = GetCurrentEnv().FILE_NAME
local Debug = false

---------------------------------------------------------------------------------

local Keys2={}

Keys2[8]="Back"
Keys2[9]="Tab"
Keys2[13]="Enter"
Keys2[16]="Shift"
Keys2[17]="Ctrl"
Keys2[18]="Alt"
Keys2[19]="Pause"
Keys2[20]="Capslock"
Keys2[21]="Mode1"
Keys2[23]="Mode2"
Keys2[24]="Mode3"
Keys2[25]="Mode4"
Keys2[27]="Esc"
Keys2[28]="IMEConvert"                                  
Keys2[29]="IMENonconvert"
Keys2[30]="IMEAceept"
Keys2[31]="IMEModeChange"
Keys2[32]="Space"
Keys2[33]="PageUp"
Keys2[34]="PageDown"
Keys2[35]="End"
Keys2[36]="Home"
Keys2[37]="Left"
Keys2[38]="Up"
Keys2[39]="Right"
Keys2[40]="Down"
Keys2[44]="PrintScreen"
Keys2[45]="Insert"
Keys2[46]="Delete"
Keys2[48]="0"
Keys2[49]="1"
Keys2[50]="2"
Keys2[51]="3"
Keys2[52]="4"
Keys2[53]="5"
Keys2[54]="6"
Keys2[55]="7"
Keys2[56]="8"
Keys2[57]="9"
Keys2[65]="A"
Keys2[66]="B"
Keys2[67]="C"
Keys2[68]="D"
Keys2[69]="E"
Keys2[70]="F"
Keys2[71]="G"
Keys2[72]="H"
Keys2[73]="I"
Keys2[74]="J"
Keys2[75]="K"
Keys2[76]="L"
Keys2[77]="M"
Keys2[78]="N"
Keys2[79]="O"
Keys2[80]="P"
Keys2[81]="Q"
Keys2[82]="R"
Keys2[83]="S"
Keys2[84]="T"
Keys2[85]="U"
Keys2[86]="V"
Keys2[87]="W"
Keys2[88]="X"
Keys2[89]="Y"
Keys2[90]="Z"
Keys2[91]="LWin"
Keys2[92]="RWin"
Keys2[93]="Apps"
Keys2[96]="NumPad0"
Keys2[97]="NumPad1"
Keys2[98]="NumPad2"
Keys2[99]="NumPad3"
Keys2[100]="NumPad4"
Keys2[101]="NumPad5"
Keys2[102]="NumPad6"
Keys2[103]="NumPad7"
Keys2[104]="NumPad8"
Keys2[105]="NumPad9"
Keys2[106]="Multiply"
Keys2[107]="Add"
Keys2[108]="Separator"
Keys2[109]="Subtract"
Keys2[110]="Decimal"
Keys2[111]="Divide"
Keys2[112]="F1"
Keys2[113]="F2"
Keys2[114]="F3"
Keys2[115]="F4"
Keys2[116]="F5"
Keys2[117]="F6"
Keys2[118]="F7"
Keys2[119]="F8"
Keys2[120]="F9"
Keys2[121]="F10"
Keys2[122]="F11"
Keys2[123]="F12"
Keys2[144]="NumLock"
Keys2[145]="ScrollLock"
Keys2[186]=";"
Keys2[187]="="
Keys2[188]=","
Keys2[189]="-"
Keys2[190]="."
Keys2[191]="/"
Keys2[192]="Oemtilde"
Keys2[219]="OemOpenBrackets"
Keys2[220]="Oem5"
Keys2[221]="Oem6"
Keys2[222]=""

org_txtKey= _G.scriptConfig._txtKey

_G.scriptConfig._txtKey =
function(self,key)
  return Keys2[key]
end

if not VIP_USER then
  print("<font color=\"#448DA6\"><b>[Vayne - Legacy of Shadow]</b></font> <font color=\"#F55F5F\"> Loading Failed. Required VIP.</font>")
  return
end

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
  self.DownloadStatus = 'Checking version...'
  AddTickCallback(function() self:GetOnlineVersion() end)
end

function ScriptUpdate:print(str)
  print('<font color="#FFFFFF">' .. os.clock() .. ': ' .. str)
end

function ScriptUpdate:OnDraw()

  if self.DownloadStatus ~= 'Updating... (100%)' and self.DownloadStatus ~= 'Checking version... (100%)' then
    DrawText((self.DownloadStatus or 'Unknown'), 40, 1040, 640, RGB(0xE0,0xE0,0xE0))
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
    self.DownloadStatus = 'Checking version... (0%)'
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

      self.DownloadStatus = 'Checking version... (' .. math.round(100/self.Size*DownloadedSize, 2) .. '%)'
    end

  end

  if self.File:find('</scr' .. 'ipt>') then
    self.DownloadStatus = 'Checking version... (100%)'

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
        self.DownloadStatus = 'Connecting to server...'
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
    self.DownloadStatus = 'Updating... (0%)'
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

      self.DownloadStatus = 'Updating... (' .. math.round(100/self.Size*DownloadedSize, 2) .. '%)'
    end

  end

  if self.File:find('</scr' .. 'ipt>') then
    self.DownloadStatus = 'Updating... (100%)'

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

function Update()

  local Script = {}

  Script.Host = "raw.githubusercontent.com"
  Script.VersionPath = "/Project4706/BoL/master/VLOS.version"
  Script.Path = "/Project4706/BoL/master/LegacyofShadow.lua"
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

if myHero.charName == "Vayne" then


function ScriptMsg(msg)
  print("<font color=\"#B1B8E3\">[Vayne - Legacy of Shadow]</b></font>  <font color=\"#FFB3B3\">".. msg .."</font>")
end

function ErrorMsg(msg)
  print("<font color=\"#448DA6\">[Vayne - Legacy of Shadow]</b></font>  <font color=\"#F55F5F\">".. msg .."</font>")
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
        ["KatarinaR"]         = {true, charName = "Katarina",  Spell = "R"},
        ["GalioIdolOfDurand"]     = {true, charName = "Galio",   Spell = "R"},
        ["Crowstorm"]         = {true, charName = "FiddleSticks", Spell = "R"},
        ["DrainChannel"]           = {true, charName = "FiddleSticks", Spell = "W"},
        ["AbsoluteZero"]        = {true, charName = "Nunu",    Spell = "R"},
        ["ShenStandUnited"]       = {true, charName = "Shen",    Spell = "R"},
        ["UrgotSwap2"]          = {true, charName = "Urgot",   Spell = "R"},
        ["AlZaharNetherGrasp"]      = {true, charName = "Malzahar",  Spell = "R"},
        ["FallenOne"]         = {true, charName = "Karthus",   Spell = "R"},
        ["Pantheon_GrandSkyfall_Jump"]  = {true, charName = "Pantheon",  Spell = "R"},
        ["VarusQ"]            = {true, charName = "Varus",   Spell = "Q"},
        ["CaitlynAceintheHole"]     = {true, charName = "Caitlyn",   Spell = "R"},
        ["MissFortuneBulletTime"]   = {true, charName = "MissFortune", Spell = "R"},
        ["InfiniteDuress"]        = {true, charName = "Warwick",   Spell = "R"},
        ["LucianR"]           = {true, charName = "Lucian",    Spell = "R"},
        ["VelkozR"]           = {true, charName = "Velkoz",    Spell = "R"},
        ["CaitlynAceintheHole"]           = {true, charName = "Caitlyn",    Spell = "R"}
    }

local GapCloserList = {
        ["AkaliShadowDance"]    = {true, charName = "Akali",     Spell = "R"},
        ["Headbutt"]          = {true, charName = "Alistar",   Spell = "W"},
        ["DianaTeleport"]         = {true, charName = "Diana",     Spell = "R"},
        ["IreliaGatotsu"]         = {true, charName = "Irelia",    Spell = "Q"},
        ["JaxLeapStrike"]           = {true, charName = "Jax",     Spell = "Q"},
        ["JayceToTheSkies"]         = {true, charName = "Jayce",   Spell = "Q"},
        ["MaokaiUnstableGrowth"]    = {true, charName = "Maokai",    Spell = "W"},
        ["MonkeyKingNimbus"]      = {true, charName = "MonkeyKing",  Spell = "E"},
        ["Pantheon_LeapBash"]     = {true, charName = "Pantheon",  Spell = "W"},
        ["PoppyHeroicCharge"]       = {true, charName = "Poppy",   Spell = "E"},
        ["QuinnE"]            = {true, charName = "Quinn",   Spell = "E"},
        ["XenZhaoSweep"]        = {true, charName = "XinZhao",   Spell = "E"},
        ["blindmonkqtwo"]       = {true, charName = "LeeSin",    Spell = "Q"},
        ["FizzPiercingStrike"]      = {true, charName = "Fizz",    Spell = "Q"},
        ["RengarLeap"]          = {true, charName = "Rengar",    Spell = "AA"},
        ["AatroxQ"]         = {true, charName = "Aatrox",    range = 1000,   projSpeed = 1200, Spell = "Q"},
        ["GragasE"]         = {true, charName = "Gragas",    range = 600,    projSpeed = 2000, Spell = "E"},
        ["GravesMove"]        = {true, charName = "Graves",    range = 425,    projSpeed = 2000, Spell = "E"},
        ["HecarimUlt"]        = {true, charName = "Hecarim",   range = 1000,   projSpeed = 1200, Spell = "R"},
        ["JarvanIVDragonStrike"]  = {true, charName = "JarvanIV",  range = 770,    projSpeed = 2000, Spell = "Q"},
        ["JarvanIVCataclysm"]   = {true, charName = "JarvanIV",  range = 650,    projSpeed = 2000, Spell = "R"},
        ["KhazixE"]         = {true, charName = "Khazix",    range = 900,    projSpeed = 2000, Spell = "E"},
        ["khazixelong"]       = {true, charName = "Khazix",    range = 900,    projSpeed = 2000, Spell = "E"},
        ["LeblancSlide"]      = {true, charName = "Leblanc",   range = 600,    projSpeed = 2000, Spell = "W"},
        ["LeblancSlideM"]     = {true, charName = "Leblanc",   range = 600,    projSpeed = 2000, Spell = "WMimic"},
        ["LeonaZenithBlade"]    = {true, charName = "Leona",     range = 900,    projSpeed = 2000, Spell = "E"},
        ["UFSlash"]         = {true, charName = "Malphite",  range = 1000,   projSpeed = 1800, Spell = "R"},
        ["RenektonSliceAndDice"]  = {true, charName = "Renekton",  range = 450,    projSpeed = 2000, Spell = "E"},
        ["SejuaniArcticAssault"]  = {true, charName = "Sejuani",   range = 650,    projSpeed = 2000, Spell = "Q"},
        ["ShenShadowDash"]      = {true, charName = "Shen",    range = 575,    projSpeed = 2000, Spell = "E"},
        ["RocketJump"]        = {true, charName = "Tristana",  range = 900,    projSpeed = 2000, Spell = "W"},
        ["slashCast"]       = {true, charName = "Tryndamere",  range = 650,    projSpeed = 1450, Spell = "E"}
    }


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
        ["SpellOrder"]  = {"QWE", "QEW", "WQE", "WEQ", "EQW", "EWQ"},
        ["QWE"] = {_Q,_W,_E,_Q,_Q,_R,_Q,_W,_Q,_W,_R,_W,_W,_E,_E,_R,_E,_E},
        ["QEW"] = {_Q,_E,_W,_Q,_Q,_R,_Q,_E,_Q,_E,_R,_E,_E,_W,_W,_R,_W,_W},
        ["WQE"] = {_W,_Q,_E,_W,_W,_R,_W,_Q,_W,_Q,_R,_Q,_Q,_E,_E,_R,_E,_E},
        ["WEQ"] = {_W,_E,_Q,_W,_W,_R,_W,_E,_W,_E,_R,_E,_E,_Q,_Q,_R,_Q,_Q},
        ["EQW"] = {_E,_Q,_W,_E,_E,_R,_E,_Q,_E,_Q,_R,_Q,_Q,_W,_W,_R,_W,_W},
        ["EWQ"] = {_E,_W,_Q,_E,_E,_R,_E,_W,_E,_W,_R,_W,_W,_Q,_Q,_R,_Q,_Q}
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
  DelayAction(function()LoadOrbwalk() end, 1)
  DelayAction(function()AutoBuy()end, 3)
  Loaded = true
end

---------------------------------------------------------------------------------

function Variables()

  SACLoaded, PEWLoaded, MMALoaded, SxOrbLoaded = false, false, false, false

  Foundinterrupt, FoundAGapCloser = false, false
  
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

  local function UpdateFHPred()

        if FileExist(LIB_PATH .. "FHPrediction.lua") then
          require("FHPrediction")   
        else
          DownloadFile("http://api.funhouse.me/download-lua.php", LIB_PATH .. "FHPrediction.lua", function() UpdateFHPred() end)
        end
      end
UpdateFHPred()

  for _, enemy in ipairs(GetEnemyHeroes()) do
    Wstacks[enemy.networkID] = 0
  end
  EnemyHeroes = GetEnemyHeroes()
  EnemyMinions = minionManager(MINION_ENEMY, 550, myHero, MINION_SORT_MAXHEALTH_DEC)
  JungleMobs = minionManager(MINION_JUNGLE, 750, myHero, MINION_SORT_MAXHEALTH_DEC)
end

---------------------------------------------------------------------------------

function VayneMenu()

    Menu = scriptConfig("Vayne - Legacy of Shadow", "VLOS_MAIN")
    
    Menu:addSubMenu("Key Binds", "Control")
    Menu.Control:addParam("OnC", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
    Menu.Control:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Control:addParam("OnF", "LaneClear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
    Menu.Control:addParam("OnJF", "JungleClear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
    Menu.Control:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Control:addParam("eafteraakey", "Condemn after Next AA", SCRIPT_PARAM_ONKEYTOGGLE, false, GetKey("E"))
    Menu.Control:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Control:addParam("Info", " Izsha", SCRIPT_PARAM_INFO, "")

    Menu:addSubMenu("Wall-Condemn Settings", "Condemn")
    Menu.Condemn:addParam("wcdmethod", "Wall-Condemn Method", SCRIPT_PARAM_LIST, 1, {"Accurate", "More often"})
    Menu.Condemn:addParam("Blank", "", SCRIPT_PARAM_INFO, "") 
    Menu.Condemn:addParam("Info", "Wall-Condemn Enabled For", SCRIPT_PARAM_INFO, "")
    for i, enemy in ipairs(EnemyHeroes) do
    Menu.Condemn:addParam("enableCondemn"..i, " >> "..enemy.charName, SCRIPT_PARAM_ONOFF, true)
    Menu.Condemn["enableCondemn"..i] = true
    end
    Menu.Condemn:addParam("Blank", "", SCRIPT_PARAM_INFO, "")   
    Menu.Condemn:addParam("MaxDistance", "Multi-Spot Prediction Distance", SCRIPT_PARAM_SLICE, 900, 250, 1000, 0)
    Menu.Condemn:addParam("CheckDistance", "Multi-spot check Distance", SCRIPT_PARAM_SLICE, 25, 1, 200, 0)
    Menu.Condemn:addParam("Checks", "Enemy check to Wall-Condemn", SCRIPT_PARAM_SLICE, 2, 0, 5, 0)
    Menu.Condemn:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Condemn:addParam("Info", " Izsha", SCRIPT_PARAM_INFO, "")

    Menu:addSubMenu("Anti-GapCloser Settings", "extraa")
    for index, data in pairs(GapCloserList) do
        for index2, enemy in ipairs(GetEnemyHeroes()) do
            if data["charName"] == enemy.charName then
                Menu.extraa:addSubMenu(enemy.charName.." "..data.Spell.." ", enemy.charName)
                Menu.extraa[enemy.charName]:addParam("Blank", "Save from "..enemy.charName.." "..data.Spell, SCRIPT_PARAM_INFO, "")
                Menu.extraa[enemy.charName]:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
                Menu.extraa[enemy.charName]:addParam("Key", "Press to be Enable", SCRIPT_PARAM_ONKEYDOWN, false, 32)
                Menu.extraa[enemy.charName]:addParam("Always", "Save Always", SCRIPT_PARAM_ONOFF, true)
                Menu.extraa[enemy.charName]:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
                Menu.extraa[enemy.charName]:addParam("hpm", "If My Health > %X", SCRIPT_PARAM_SLICE, 0, 1, 100, 0)
                Menu.extraa[enemy.charName]:addParam("hpe", "If Enemy Health > %X", SCRIPT_PARAM_SLICE, 0, 1, 100, 0)
                Menu.extraa[enemy.charName]:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
                Menu.extraa[enemy.charName]:addParam("delay", "Using Delay(ms)", SCRIPT_PARAM_SLICE, 0, 0, 400, 0)
                Menu.extraa[enemy.charName]:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
                Menu.extraa[enemy.charName]:addParam("Info", " Izsha", SCRIPT_PARAM_INFO, "")
                FoundAGapCloser = true
            end
        end
    end
    if not FoundAGapCloser then Menu.extraa:addParam("Blank", "Enemy Gap-Closers Not Found.", SCRIPT_PARAM_INFO, "") end
    Menu.extraa:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.extraa:addParam("Info", " Izsha", SCRIPT_PARAM_INFO, "")

    Menu:addSubMenu("Interrupt Settings", "extra")
    for index, data in pairs(InterruptList) do
        for index, enemy in ipairs(GetEnemyHeroes()) do
            if data["charName"] == enemy.charName then
                Menu.extra:addSubMenu(enemy.charName.." "..data.Spell.." ", enemy.charName)
                Menu.extra[enemy.charName]:addParam("Blank", "Interrupt "..enemy.charName.." "..data.Spell, SCRIPT_PARAM_INFO, "")
                Menu.extra[enemy.charName]:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
                Menu.extra[enemy.charName]:addParam("Key", "Press to Interrupt", SCRIPT_PARAM_ONKEYDOWN, false, 32)
                Menu.extra[enemy.charName]:addParam("Always", "Interrupt Always", SCRIPT_PARAM_ONOFF, true)
                Menu.extra[enemy.charName]:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
                Menu.extra[enemy.charName]:addParam("hpm", "If My Health > %X", SCRIPT_PARAM_SLICE, 0, 1, 100, 0)
                Menu.extra[enemy.charName]:addParam("hpe", "If Enemy Health > %X", SCRIPT_PARAM_SLICE, 0, 1, 100, 0)
                Menu.extra[enemy.charName]:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
                Menu.extra[enemy.charName]:addParam("delay", "Using Delay(ms)", SCRIPT_PARAM_SLICE, 0, 0, 400, 0)
                Menu.extra[enemy.charName]:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
                Menu.extra[enemy.charName]:addParam("Info", " Izsha", SCRIPT_PARAM_INFO, "")
                Foundinterrupt = true
            end
        end
    end
    if not Foundinterrupt then Menu.extra:addParam("Blank", "Spell-Enemy to Interrupt Not Found.", SCRIPT_PARAM_INFO, "") end
    Menu.extra:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.extra:addParam("Info", " Izsha", SCRIPT_PARAM_INFO, "")
   
    Menu:addSubMenu("Combo Settings", "Combo")
    Menu.Combo:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addParam("qforgap", "Use Q For Gapcloser", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addParam("qmethod", "Q Method", SCRIPT_PARAM_LIST, 1, {"AA Reset", "Passive Proc."})
    Menu.Combo:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("finishim", "Use E For Finisher", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addParam("fie", "Disable If X Enemy Around", SCRIPT_PARAM_SLICE, 2, 0, 5, 0)
    Menu.Combo:addParam("fimh", "Disable If My Health < %X", SCRIPT_PARAM_SLICE, 0, 1, 100, 0)
    Menu.Combo:addParam("fieh", "Disable If Enemy Health < %X", SCRIPT_PARAM_SLICE, 0, 1, 100, 0)
    Menu.Combo:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("R", "Use R", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("focus", "Left Click Focus Target", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addParam("vision", "Auto vision on Bush", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("bork", "Use BoTRK & Bilgewater", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addParam("maxownhealth", "Max. own % Health to use", SCRIPT_PARAM_SLICE, 50, 1, 100, 0)
    Menu.Combo:addParam("minenemyhealth", "Min. enemy % Health to use", SCRIPT_PARAM_SLICE, 20, 1, 100, 0)
    Menu.Combo:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    if ignite then
    Menu.Combo:addParam("set", "Use Ignite", SCRIPT_PARAM_LIST, 2, {"OFF", "Optimal", "Aggressive"})
    Menu.Combo:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    end
    if heal then
    Menu.Combo:addParam("enable", "Use Heal", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addParam("health", "Use if My Health < %X", SCRIPT_PARAM_SLICE, 10, 0, 100, 0)
    if realheals then
    Menu.Combo:addParam("ally", "Use for Ally", SCRIPT_PARAM_ONOFF, false)
    Menu.Combo:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    end
    end
    if exhaust then 
    Menu.Combo:addParam("exh", "Exhaust Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey(exhaust.key))
    Menu.Combo:addTS(TES)
    TES = TargetSelector(TARGET_PRIORITY, 600, DAMAGE_MAGIC) 
    TES.name = "Exhaust"
    end 
    Menu.Combo:addParam("Key", "Remove CC", SCRIPT_PARAM_ONKEYDOWN, false, 32)
    Menu.Combo:addParam("Always", "Remove Always", SCRIPT_PARAM_ONOFF, true) 
    if SummonerSlot then
    Menu.Combo:addParam("Summoner", "Use Cleanse", SCRIPT_PARAM_ONOFF, true)
    end
    Menu.Combo:addParam("delay", "Remove Delay(ms)", SCRIPT_PARAM_SLICE, 0, 0, 400, 0)
    Menu.Combo:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("Info", " Izsha", SCRIPT_PARAM_INFO, "")
    
    Menu:addSubMenu("Extra Ultimate Settings", "ultimate")
    Menu.ultimate:addParam("enemy", "Enemies in range for R", SCRIPT_PARAM_SLICE, 3, 1, 5, 0)
    Menu.ultimate:addParam("ally", "Allies in range for R", SCRIPT_PARAM_SLICE, 2, 0, 5, 0)
    Menu.ultimate:addParam("minblock", "Stay invis. if enemy around", SCRIPT_PARAM_SLICE, 3, 0, 5, 0)
    Menu.ultimate:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.ultimate:addParam("hp", "Min. own % Health to use", SCRIPT_PARAM_SLICE, 65, 1, 100, 0)
    Menu.ultimate:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.ultimate:addParam("Info", " Izsha", SCRIPT_PARAM_INFO, "")

    Menu:addSubMenu("Lane Clear", "Farm")
    Menu.Farm:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
    Menu.Farm:addParam("Q2", "Use if Mana Percent > %X", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
    Menu.Farm:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Farm:addParam("Q3", "Use Q if AA in Cooldown", SCRIPT_PARAM_ONOFF, false)
    Menu.Farm:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Farm:addParam("Info", " Izsha", SCRIPT_PARAM_INFO, "")

    Menu:addSubMenu("Jungle Clear", "JFarm")
    Menu.JFarm:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
    Menu.JFarm:addParam("Q2", "Use if Mana Percent > %X", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
    Menu.JFarm:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.JFarm:addParam("E", "Wall-Condemn on Large Junglemob", SCRIPT_PARAM_ONOFF, true)
    Menu.JFarm:addParam("E2", "Use if Mana Percent > %X", SCRIPT_PARAM_SLICE, 30, 0, 100, 0)
    Menu.JFarm:addParam("hpm", "Use if My Health > %X", SCRIPT_PARAM_SLICE, 0, 1, 100, 0)
    Menu.JFarm:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.JFarm:addParam("E3", "Disable E if my level > X", SCRIPT_PARAM_SLICE, 9, 4, 16, 0)
    Menu.JFarm:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.JFarm:addParam("Info", " Izsha", SCRIPT_PARAM_INFO, "")
    
    Menu:addSubMenu("Draw Settings", "Draw")
    Menu.Draw:addParam("On", "Enable Draws", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("Info", "", SCRIPT_PARAM_INFO, "")
    Menu.Draw:addParam("AA", "Draw AA range", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("CLA", "Color AA range", SCRIPT_PARAM_COLOR, {144, 144, 40, 164})
    Menu.Draw:addParam("Info", "", SCRIPT_PARAM_INFO, "")
    Menu.Draw:addParam("Q", "Draw Q range", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("CLQ", "Color Q range", SCRIPT_PARAM_COLOR, {141, 23, 123, 22})
    Menu.Draw:addParam("Info", "", SCRIPT_PARAM_INFO, "")
    Menu.Draw:addParam("E", "Draw E range", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("CLE", "Color E range", SCRIPT_PARAM_COLOR, {141, 31, 69, 123})
    Menu.Draw:addParam("Info", "", SCRIPT_PARAM_INFO, "")
    if ignite then
    Menu.Draw:addParam("I", "Draw Ignite range", SCRIPT_PARAM_ONOFF, false)
    Menu.Draw:addParam("CLI", "Color Ignite range", SCRIPT_PARAM_COLOR, {141, 124, 114, 114})
    Menu.Draw:addParam("Info", "", SCRIPT_PARAM_INFO, "")
    end
    Menu.Draw:addParam("Trg", "Draw Current Target", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("CondemnAssistant", "Wall-Condemn Assistance", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("ownp", "Enable Pathway Draw", SCRIPT_PARAM_ONOFF, false)
    Menu.Draw:addParam("opp", "Draw Enemy Pathway", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("Info","", SCRIPT_PARAM_INFO, "")
    Menu.Draw:addParam("stream", "Enable Streaming Mode", SCRIPT_PARAM_ONKEYTOGGLE, false, 118)
    Menu.Draw:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Draw:addParam("Info1", " Izsha", SCRIPT_PARAM_INFO, "")

    Menu:addSubMenu("Extra Settings", "extras")
    Menu.extras:addParam("buyme", "Auto Buy Starting Items", SCRIPT_PARAM_ONOFF, false)
    Menu.extras:addParam("Blank", "", SCRIPT_PARAM_INFO, "","" )
    Menu.extras:addParam("UseAutoLevelFirst", "Use AutoLevelSpells Level 1-3", SCRIPT_PARAM_ONOFF, false)
    Menu.extras:addParam("UseAutoLevelRest", "Use AutoLevelSpells Level 4-18", SCRIPT_PARAM_ONOFF, false)
    Menu.extras:addParam("First3Level", "Level 1-3", SCRIPT_PARAM_LIST, 1, {"Q-W-E", "Q-E-W", "W-Q-E", "W-E-Q", "E-Q-W", "E-W-Q"})
    Menu.extras:addParam("RestLevel", "Level 4-18", SCRIPT_PARAM_LIST, 1, {"Q-W-E", "Q-E-W", "W-Q-E", "W-E-Q", "E-Q-W", "E-W-Q"})
    Menu.extras:addParam("Blank", "", SCRIPT_PARAM_INFO, "","" )
    Menu.extras:addParam("upski", "Change Skin", SCRIPT_PARAM_ONOFF, false);
    Menu.extras:setCallback("upski", function(nV)
        if (nV) then
            SetSkin(myHero, Menu.extras.skinID)
        else
            SetSkin(myHero, -1)
        end
    end)
    Menu.extras:addParam("skinID", "Skin", SCRIPT_PARAM_LIST, 1, {"Vindicator", "Aristocrat", "Dragonslayer", "Heartseeker", "SKT T1", "Arclight", "Chroma Pack: Green", "Chroma Pack: Red", "Chroma Pack: Silver", "Soulstealer", "Classic"})
    Menu.extras:setCallback("skinID", function(nV)
        if (Menu.extras.upski) then
            SetSkin(myHero, nV)
        end
    end)
    if (Menu.extras.upski) then
        SetSkin(myHero, Menu.extras.skinID)
    end
    Menu.extras:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.extras:addParam("Info", " Izsha", SCRIPT_PARAM_INFO, "")
  
    Menu:addSubMenu("Orbwalker Settings", "Orbwalker")
    Menu:addTS(ts)
    ts.name = "Target"
    
    
  Menu:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
  Menu:addParam("Info", "http://botoflegends.com", SCRIPT_PARAM_INFO, "")
  Menu:addParam("SVersion", "Script Version ", SCRIPT_PARAM_LIST, 1, {"" .. Version})
  Menu:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
  Menu:addParam("popup", "Click For Latest Changelog", SCRIPT_PARAM_ONOFF, false)

  Menu.Condemn:permaShow("wcdmethod")
  Menu.Combo:permaShow("qmethod")

    Menu.Control.OnC = false
    Menu.Control.OnF = false
    Menu.Control.OnJF = false

end

---------------------------------------------------------------------------------

function LoadOrbwalk()

  if _G.AutoCarry and _G.Reborn_Initialised then
    SACLoaded = true
    Menu.Orbwalker:addParam("Info", "SAC Detected & Loaded", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Info", "Keys are not integrated with your", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Info", "orbwalker, please set in Key Binds menu.", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Info", " Izsha", SCRIPT_PARAM_INFO, "")
    ScriptMsg("Sida's Auto Carry Detected.")
  elseif _G.Reborn_Loaded then
    _G.DisableSACVayne = true
    DelayAction(function() LoadOrbwalk() end, 1)
  elseif _G.MMA_IsLoaded then
    MMALoaded = true
    Menu.Orbwalker:addParam("Info", "MMA Detected & Loaded", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Info", "Keys are not integrated with your", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Info", "orbwalker, please set in Key Binds menu.", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Info", " Izsha", SCRIPT_PARAM_INFO, "")
    ScriptMsg("Marksman's Mighty Assistant Detected.")
  elseif _G._Pewalk then
    PEWLoaded = true
    Menu.Orbwalker:addParam("Info", "Pewalk Detected & Loaded", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Info", "Keys are not integrated with your", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Info", "orbwalker, please set in Key Binds menu.", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Info", " Izsha", SCRIPT_PARAM_INFO, "")
    ScriptMsg("Pewalk Detected.")
  elseif FileExist(LIB_PATH .. "SxOrbWalk.lua") then
    require "SxOrbWalk"
    SxOrb = SxOrbWalk()
    SxOrb:LoadToMenu(Menu.Orbwalker)
    Menu.Orbwalker:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Orbwalker:addParam("Info", " Izsha", SCRIPT_PARAM_INFO, "")
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
  
  if Menu.extras.UseAutoLevelFirst or Menu.extras.UseAutoLevelRest then
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

  if Menu.Control.OnC and Menu.Condemn.wcdmethod == 1 then
    WallCondemnMultiPrediction()
  elseif Menu.Control.OnC and Menu.Condemn.wcdmethod == 2 then
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

  if Menu.Combo.bork then
    if myHero.health / myHero.maxHealth <=  Menu.Combo.maxownhealth / 100 then
      local unit = Targets()
      if ValidTarget(unit, 1000) then
        if unit.health / unit.maxHealth <=  Menu.Combo.minenemyhealth  / 100 then
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

    if Menu.Combo.bork then
    if myHero.health / myHero.maxHealth <=  Menu.Combo.maxownhealth / 100 then
      local unit = Targets()
      if ValidTarget(unit, 1000) then
        if unit.health / unit.maxHealth <=  Menu.Combo.minenemyhealth / 100 then
          Bilgewater(unit)
        end
      end
    end 
  end 
    
    if exhaust and Menu.Combo.exh then 
    if myHero:CanUseSpell(exhaust.slot) == 0 then
      TES:update()
      if ValidTarget(TES.target) and TES.target.type == myHero.type then
        exhFunction(TES.target) 
      end
    end
  end

  if heal then
    if ValidTarget(Targets(), 1000) then
      if Menu.Combo.enable and myHero:CanUseSpell(heal) == 0 then
        if myHero.level > 5 and myHero.health/myHero.maxHealth < Menu.Combo.health/100 then
          CastSpell(heal)
        elseif  myHero.level < 6 and myHero.health/myHero.maxHealth < (Menu.Combo.health/100)*.75 then
          CastSpell(heal)
        end
        
        if realheals and Menu.Combo.ally then
          local ally = findClosestAlly(myHero)
          if ally and not ally.dead and GetDistance(ally) < 850 then
            if  ally.health/ally.maxHealth < Menu.Combo.health/100 then
              CastSpell(heal)
            end
          end
        end
      end
    end
  end
  
  if ignite and Menu.Combo.set > 1 and (myHero:CanUseSpell(ignite) == READY) then 
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
  
end

---------------------------------------------------------------------------------

function Targets()

    if ValidTarget(SelectedTarget) then
        target_return = SelectedTarget
    elseif _G.MMA_IsLoaded then 
        target_return = _G.MMA_Target()
    elseif _G.AutoCarry and _G.Reborn_Initialised then 
        target_return = _G.AutoCarry.Crosshair:GetTarget()
    elseif _G._Pewalk then 
        target_return = _G._Pewalk.GetTarget()
    elseif SxOrbLoaded then
        target_return = SxOrb:GetTarget()
    end

    if ValidTarget(target_return) and target_return.type == myHero.type then
        return SelectedTarget
    else
        ts:update()
        if ValidTarget(ts.target) and ts.target.type == myHero.type then
          return ts.target
        end
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

function OrbwalkCanAttack()

  if SACLoaded then
    return _G.AutoCarry.Orbwalker:CanShoot()
  elseif MMALoaded then
    return true--_G.MMA_AttackAvailable
  elseif SxOrbLoaded then
    return SxOrb:CanAttack()
  elseif PEWLoaded then
    return _Pewalk.CanAttack()
  end
  
end

function IsShielding(enemy, time)

  if enemy and enemy.valid and enemy.team ~= myHero.team and not enemy.dead then
  
    for i=1, enemy.buffCount do
    
      local buff = enemy:getBuff(i)
      
      if buff and buff.name and (buff.name == "SivirE") and (GetGameTimer()+(time or 0) <= buff.endT) or buff and buff.name and (buff.name == "BlackShield") and (GetGameTimer()+(time or 0) <= buff.endT) then 
        return true
      end
      
    end
    
  end
  
  return false
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
if AddProcessAttackCallback and heal and Menu.Combo.enable then
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

  if unit.isMe and (Menu.Combo.Always or Menu.Combo.Key) then
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
  if Menu.Combo.Summoner and SummonerSlot and myHero:CanUseSpell(SummonerSlot) == 0 then
    DelayAction(function()
      CastSpell(SummonerSlot)
    end, Menu.Combo.delay/1000)
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

---------------------------------------------------------------------------------

function AutoIgnite()
  local IgniteDmg = 50 + (20 * myHero.level)
  local aggro = Menu.Combo.set == 3 and 0.05 or 0
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

  if heal and Menu.Combo.enable and myHero:CanUseSpell(heal) == 0 and spell.target and spell.target.isMe and unit.team ~= myHero.team and unit.type == myHero.type then
    if myHero.health/myHero.maxHealth <= (Menu.Combo.health/100)*1.5 then
      CastSpell(heal)
    end
  end
  if spell.name:lower():find("zedr") and spell.target == myHero then
    DelayAction(function()
    end, 1.7)
  end

for index, data in pairs(InterruptList) do
  for index, enemy in ipairs(GetEnemyHeroes()) do
    if data["charName"] == enemy.charName then
      if Menu.extra[enemy.charName].Key and E.ready or Menu.extra[enemy.charName].Always and E.ready then
        if InterruptList[spell.name] and GetDistanceSqr(unit) <= 715*715 then
          if (myHero.health/myHero.maxHealth)*100 >= Menu.extra[enemy.charName].hpm and (unit.health/unit.maxHealth)*100 >= Menu.extra[enemy.charName].hpe then
            if Menu.extra[unit.charName] and unit.team ~= myHero.team then
              if not IsShielding(enemy, eDelay) then
                DelayAction(function()
                  CastSpell(_E, unit)
                end, Menu.extra[enemy.charName].delay/1000)
              end
            end
          end
        end
      end
    end
  end
end

for index, data in pairs(GapCloserList) do
  for index, enemy in ipairs(GetEnemyHeroes()) do
    if data["charName"] == enemy.charName then
      if Menu.extraa[enemy.charName].Key and E.ready or Menu.extraa[enemy.charName].Always and E.ready then
        if GapCloserList[spell.name] then
          if spell.target and spell.target.networkID == myHero.networkID then
            if (myHero.health/myHero.maxHealth)*100 >= Menu.extraa[enemy.charName].hpm and (unit.health/unit.maxHealth)*100 >= Menu.extraa[enemy.charName].hpe then
              if Menu.extraa[unit.charName] and unit.team ~= myHero.team then
                if not IsShielding(enemy, eDelay) then
                  DelayAction(function()
                    CastSpell(_E, unit)
                  end, Menu.extraa[enemy.charName].delay/1000)
                end
              end
            end
          end
        end
      end
    end
  end
end

for index, data in pairs(GapCloserList) do
  for index, enemy in ipairs(GetEnemyHeroes()) do
    if data["charName"] == enemy.charName then
      if Menu.extraa[enemy.charName].Key and E.ready or Menu.extraa[enemy.charName].Always and E.ready then
        if GapCloserList[spell.name] and GetDistanceSqr(unit) <= 2000*2000 and (spell.target == nil or (spell.target and spell.target.isMe)) then
          if (myHero.health/myHero.maxHealth)*100 >= Menu.extraa[enemy.charName].hpm and (unit.health/unit.maxHealth)*100 >= Menu.extraa[enemy.charName].hpe then
            if Menu.extraa[unit.charName] and unit.team ~= myHero.team then
              if not IsShielding(enemy, eDelay) then
                SpellInfo = {
                  Source = unit,
                  CastTime = os.clock(),
                  StartPos = Point(unit.pos.x, unit.pos.z),
                  Range = GapCloserList[spell.name].range,
                  Speed = GapCloserList[spell.name].projSpeed,
                }
                DelayAction(function()
                CastSpell(_E, unit)
                  end, Menu.extraa[enemy.charName].delay/1000)
              end
            end
          end
        end
      end
    end
  end
end

end

--[[function OnUpdateBuff(unit, buff, stacks)

  if unit == myHero then
  
    if buff.name == "" then
    else
      print("Update: " .. unit.charName .. " " .. buff.name)
    end
    
  elseif unit and unit.team ~= myHero.team and (GetDistance(unit) < 2000) then
  
     print("Update: " .. unit.charName .. " " .. buff.name)
    
  end
  
end]]--

function GetDmg(spell, enemy)

  if enemy.health == 0 then
    return 0
  end
  
  local ADDmg = 0
  local PureDmg = 0
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
      ADDmg = (.05*Q.level+.25)*TotalDmg
    end
    
    elseif spell == "W" then
    if W.ready and Wstacks[spell.target.networkID] == 2 then
      PureDmg = (.015*W.level+.045)*enemyHero.maxHealth
    end
    
    elseif spell == "E" then
    if E.ready then
      ADDmg = 35*E.level+10+0.5*TotalDmg
    end
    
  end
  
  local TrueDmg = ADDmg*(1-ArmorPercent)+APDmg*(1-MagicArmorPercent)
  
  return TrueDmg
end

function OnProcessAttack(unit, spell)

  if unit.isMe and spell.name:lower():find("attack") and Menu.Control.OnC and Menu.Combo.Q and Q.ready and Menu.Combo.qmethod == 1 then
        SpellTarget = spell.target
        if SpellTarget.type == myHero.type then
            CastSpell(_Q, mousePos.x, mousePos.z)
        end
    end

  if Menu.Control.OnF and Q.ready then
      EnemyMinions:update()
        for i, minion in pairs(EnemyMinions.objects) do   
  if unit.isMe and spell.name:lower():find("attack") and Menu.Control.OnF and Menu.Farm.Q and ManaPercent() >= Menu.Farm.Q2 and not(Menu.Farm.Q3 and OrbwalkCanAttack()) then
        SpellTarget = spell.target
        CastSpell(_Q, mousePos.x, mousePos.z)
       end
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

if not (EnemiesAround(myHero, 650) >= Menu.Combo.fie and (math.floor(myHero.health / myHero.maxHealth * 100)) <= Menu.Combo.fimh and (math.floor(enemyHero.health / enemyHero.maxHealth * 100)) <= Menu.Combo.fieh) then
  if unit.isMe and spell.name:lower():find("attack") then
  if spell.target then SpellTarget = spell.target end
    if Menu.Control.OnC and Menu.Combo.finishim and SpellTarget.type == myHero.type and E.ready then
      for i, enemy in ipairs(EnemyHeroes) do
          if GetDmg("E", enemy) >= enemy.health then
            CastSpell(_E, SpellTarget)
          elseif Wstacks[SpellTarget.networkID] == 2 then
            if GetDmg("E", enemy)+GetDmg("W", enemy) >= enemy.health then
            CastSpell(_E, SpellTarget)
          else
            DelayAction(function() CastSpell(_Q, SpellTarget) end, spell.windUpTime + GetLatency()/2000)
          end
        end
      end
    end
  end
end

if unit.isMe and spell.name:lower():find("attack") then
        if spell.target then SpellTarget = spell.target end
        if Menu.Combo.qforgap and SpellTarget.type == myHero.type and Q.ready and GetDistance(SpellTarget) > 650 and Menu.Control.OnC then
        DelayAction(function() CastSpell(_Q, SpellTarget) end, spell.windUpTime + GetLatency()/2000)
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

        for i, enemyHero in ipairs(EnemyHeroes) do
        if Menu.Condemn["enableCondemn"..i] then
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
      if sumCheckDist/checkCount < Menu.Condemn.MaxDistance
        and GetDistance(enemyHero) < sumCheckDist/checkCount then
        if not IsShielding(enemyHero, eDelay) then
        CastSpell(_E, enemyHero)
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

    if E.ready then

            for i, enemyHero in ipairs(EnemyHeroes) do
                if Menu.Condemn["enableCondemn"..i] then 
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

                            if InsideTheWall then
                              if not IsShielding(enemyHero, eDelay) then
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

---------------------------------------------------------------------------------

function JungleWallCondemnMultiPrediction()

    if myHero.dead then return end
    if myHero.level > Menu.JFarm.E3 then return end
  
    if E.ready and Menu.Control.OnJF and Menu.JFarm.E and ManaPercent() >= Menu.JFarm.E2 then
      if (myHero.health/myHero.maxHealth)*100 >= Menu.JFarm.hpm then

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

    if not Menu.Draw.On or myHero.dead then
    return
  end

  if Menu.Draw.Trg then
    if target ~= nil then
    DrawCircle3D(target.x, target.y, target.z, 75, 2, ARGB(255, 0, 0, 255))
    end
  end

  if PopUp then
              local w, h1, h2 = (WINDOW_W*0.50), (WINDOW_H*.15), (WINDOW_H*.9)
              DrawLine(w, h1/1.05, w, h2/1.97, w/1.75, ARGB(80, 0, 0, 0)) -- border & aero
              DrawLine(w, h1, w, h2/2, w/1.8, ARGB(255, 22, 12, 0)) -- background
              DrawTextA(tostring("Vayne - Legacy of Shadow"), WINDOW_H*.032, (WINDOW_W/2), (WINDOW_H*.18), ARGB(255, 0, 222, 225),"center","center")
              DrawTextA(tostring("Equipped by FHPrediction"), WINDOW_H*.013, (WINDOW_W/1.79), (WINDOW_H*.199), ARGB(255, 0, 222, 225))
              DrawTextA(tostring("Latest Changelog (" .. Version .. ") ;"), WINDOW_H*.018, (WINDOW_W/2.65), (WINDOW_H*.229), ARGB(255, 0, 222, 225))
              DrawTextA(tostring(" "), WINDOW_H*.018, (WINDOW_W/2.65), (WINDOW_H*.210), ARGB(255, 255, 255, 255))
              DrawTextA(tostring(" "), WINDOW_H*.018, (WINDOW_W/2.65), (WINDOW_H*.225), ARGB(255, 255, 255, 255))
              DrawTextA(tostring("- SAC:R Vayne plugin will be disabled now if SAC:R loaded."), WINDOW_H*.016, (WINDOW_W/2.70), (WINDOW_H*.259), ARGB(255, 0, 222, 225))
              DrawTextA(tostring(""), WINDOW_H*.015, (WINDOW_W/2.70), (WINDOW_H*.260), ARGB(255, 0, 222, 225))
              DrawTextA(tostring(""), WINDOW_H*.015, (WINDOW_W/2.70), (WINDOW_H*.280), ARGB(255, 0, 222, 225))
              local w, h1, h2 = (WINDOW_W*0.49), (WINDOW_H*.70), (WINDOW_H*.75)
              DrawLine(w, h1/1.775, w, h2/1.68, w*.11, ARGB(255, 0, 0, 0))
              DrawRectangleButton(WINDOW_W*0.467, WINDOW_H/2.375, WINDOW_W*.047, WINDOW_H*.041, ARGB(255, 255, 0, 0))
              DrawTextA(tostring("OK"), WINDOW_H*.02, (WINDOW_W/2)*.98, (WINDOW_H/2.375), ARGB(255, 0, 222, 225),"center","center")
              DrawTextA(tostring(""), WINDOW_H*.015, (WINDOW_W/2.65), (WINDOW_H*.355), ARGB(255, 0, 222, 225))
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

  if Menu.Draw.CondemnAssistant and Menu.Control.OnC and E.ready and Menu.Condemn.wcdmethod == 1 then
    for i, enemyHero in ipairs(EnemyHeroes) do
        if Menu.Condemn["enableCondemn"..i] then
        if enemyHero ~= nil and enemyHero.valid and not enemyHero.dead and enemyHero.visible and GetDistance(enemyHero) <= 715 and GetDistance(enemyHero) > 0 then
        local predPosition = FHPrediction.PredictPosition(enemyHero, eDelay) --VPred:GetPredictedPos(enemyHero, eDelay, eSpeed)
      
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
        DrawLine3D(enemyHero.x, enemyHero.y, enemyHero.z, checksPos.x, checksPos.y, checksPos.z, 1, 0xFF00FF00)
        DrawCircle3D(checksPos.x, checksPos.y, checksPos.z, 20, 1, ARGB(0xFF, 0, 0xFF, 0))
        end
      else
        AllInsideWall = false
        
        if Menu.Draw.CondemnAssistant and Menu.Control.OnC and E.ready then
        DrawLine3D(enemyHero.x, enemyHero.y, enemyHero.z, checksPos.x, checksPos.y, checksPos.z, 2, 0xFF000000)
        DrawCircle3D(checksPos.x, checksPos.y, checksPos.z, 20, 1, ARGB(0xFF, 0x00, 0x00, 0x00))
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
                if Menu.Condemn["enableCondemn"..i] then 
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
                               DrawCircle3D(PushPos.x, PushPos.y, PushPos.z, 35, 2, ARGB(255, 0, 0, 255))
                            else
                            AllInsideWall = false
                            if PushPos.x > 0 and PushPos.z > 0 then
                               DrawCircle3D(PushPos.x, PushPos.y, PushPos.z, 35, 2, ARGB(255, 0, 0, 255))
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
    DrawText("Condemn After Next AA is Active!", 30, myPos.x, myPos.y, ARGB(0xFF, 0, 0, 0xFF))
  end


  local p1 = WorldToScreen(D3DXVECTOR3(myHero.x, myHero.y, myHero.z))

  if OnScreen(p1.x, p1.z) then

  if Menu.Draw.AA then
    DrawCircle3D(myHero.pos.x, myHero.pos.y, myHero.pos.z, myHero.range+myHero.boundingRadius, 2, RGB(Menu.Draw.CLA[2], Menu.Draw.CLA[3], Menu.Draw.CLA[4]))
  end
  
  if Menu.Draw.Q and Q.ready then
    DrawCircle3D(myHero.pos.x, myHero.pos.y, myHero.pos.z, Q.range, 2, RGB(Menu.Draw.CLQ[2], Menu.Draw.CLQ[3], Menu.Draw.CLQ[4]))
  end
    
  if Menu.Draw.E and E.ready then
    DrawCircle3D(myHero.pos.x, myHero.pos.y, myHero.pos.z, E.range-40, 2, RGB(Menu.Draw.CLE[2], Menu.Draw.CLE[3], Menu.Draw.CLE[4]))
  end
  
  if Menu.Draw.I and I.ready then
    DrawCircle3D(myHero.pos.x, myHero.pos.y, myHero.pos.z, I.range, 2, RGB(Menu.Draw.CLI[2], Menu.Draw.CLI[3], Menu.Draw.CLI[4]))
  end
end
end

---------------------------------------------------------------------------------

function AutoBuy()
  
  if GetGameTimer() < 60 then
    if Menu.extras.buyme then
      BuyItem(1055)
    end
    if Menu.extras.buyme then
      BuyItem(2003)
    end
    if Menu.extras.buyme then
      BuyItem(3340)
    end
  end
end

---------------------------------------------------------------------------------

function CheckLevelChange()
    if LastLevelCheck + 250 < GetTickCount() and myHero.level < 19 then
        if GetGame().map.index == 8 and myHero.level < 4 and Menu.extras.UseAutoLevelFirst then
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
    if Menu.extras.UseAutoLevelFirst and myHero.level < 4 then
        LevelSpell(AutoLevelSpellTable[AutoLevelSpellTable["SpellOrder"][Menu.extras.First3Level]][myHero.level])
    end

    if Menu.extras.UseAutoLevelRest and myHero.level > 3 then
        LevelSpell(AutoLevelSpellTable[AutoLevelSpellTable["SpellOrder"][Menu.extras.RestLevel]][myHero.level])
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

end

---------------------------------------------------------------------------------==============================================================================================================================
---------------------------------------------------------------------------------==============================================================================================================================
---------------------------------------------------------------------------------==============================================================================================================================
