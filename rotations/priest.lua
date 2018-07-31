--[[[
@module Priest Environment Functions and Variables
@description
Priest Environment Functions and Variables.
]]--

kps.env.priest = {}

local UnitIsUnit = UnitIsUnit
local UnitExists = UnitExists
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitDebuff = UnitDebuff
local UnitBuff = UnitBuff
local UnitChannelInfo = UnitChannelInfo

--------------------------------------------------------------------------------------------
------------------------------- TEST FUNCTIONS
--------------------------------------------------------------------------------------------

function kps.env.priest.booltest()
    if kps.multiTarget then return true end
    return false
end
function kps.env.priest.boolval(arg)
    if arg == true then return true end
    return false
end
function kps.env.priest.strtest()
    if kps.multiTarget then return "a" end
    return "b"
end
function kps.env.priest.strval(arg)
    if arg == true then return "a" end
    return "b"
end

--kps.rotations.register("PRIEST","SHADOW",{

--{spells.mindFlay, env.booltest }, -- true/false
--{spells.mindFlay, env.booltest() }, -- always false
--{spells.mindFlay, 'env.booltest' }, -- nil value
--{spells.mindFlay, 'env.booltest()' }, -- nil value
--{spells.mindFlay, 'booltest()' }, -- true/false
--{spells.mindFlay, 'booltest' }, -- always true

--{spells.mindFlay, env.boolval(kps.multiTarget) }, -- always false
--{spells.mindFlay, 'env.boolval(kps.multiTarget)' }, -- nil value
--{spells.mindFlay, 'boolval(kps.multiTarget)' }, -- always true

--{spells.mindFlay, env.strtest == "a" }, -- always false
--{spells.mindFlay, env.strtest() == "a" }, -- always false
--{spells.mindFlay, 'env.strtest == "a"' }, -- nil value
--{spells.mindFlay, 'env.strtest() == "a"' }, -- nil value
--{spells.mindFlay, 'strtest() == "a"' }, -- true/false
--{spells.mindFlay, 'strtest == "a"' }, -- always false

--{spells.mindFlay, env.strval(kps.multiTarget) == "a" }, -- always false
--{spells.mindFlay, 'env.strval(kps.multiTarget) == "a"' }, -- nil value
--{spells.mindFlay, strval(kps.multiTarget) == "a" }, -- nil value
--{spells.mindFlay, 'strval(kps.multiTarget) == "a"' }, -- true/false

--},"TEST Priest")

--------------------------------------------------------------------------------------------
------------------------------- LOCAL FUNCTIONS
--------------------------------------------------------------------------------------------

local UnitDebuffDuration = function(spell,unit)
    --if unit == nil then return "target" end
    local spellname = tostring(spell)
    local name,_,_,_,_,duration,endTime,caster,_,_ = UnitDebuff(unit,spellname)
    if caster ~= "player" then return 0 end
    if endTime == nil then return 0 end
    local timeLeft = endTime - GetTime()
    if timeLeft < 0 then return 0 end
    return timeLeft
end

local UnitHasBuff = function(spell,unit)
    --if unit == nil then unit = "player" end
    local spellname = tostring(spell)
    if spellname == nil then return false end
    if select(1,UnitBuff(unit,spellname)) then return true end
    return false
end

local UnitHasDebuff = function(spell,unit)
    --if unit == nil then unit = "player" end
    local spellname = tostring(spell)
    if spellname == nil then return false end
    if select(1,UnitDebuff(unit,spellname)) then return true end
    return false
end

local function UnitIsAttackable(unit)
    if UnitIsDeadOrGhost(unit) then return false end
    if not UnitExists(unit) then return false end
    if (string.match(GetUnitName(unit), kps.locale["Dummy"])) then return true end
    if UnitCanAttack("player",unit) == false then return false end
    --if UnitIsEnemy("player",unit) == false then return false end
    if not kps.env.harmSpell.inRange(unit) then return false end
    return true
end

local function PlayerHasTalent(row,talent)
    local _, talentRowSelected =  GetTalentTierInfo(row,1)
    if talent == talentRowSelected then return true end
    return false
end

--------------------------------------------------------------------------------------------
------------------------------- SHADOW PRIEST
--------------------------------------------------------------------------------------------

function kps.env.priest.countFriend()
    if not IsInRaid() then return 2 end
    return 3
end

local MindFlay = kps.spells.priest.mindFlay.name
local VoidForm = kps.spells.priest.voidform.name
local EnemyTable = {"mouseover", "focus", "target"}
local ShadowWordPain = kps.spells.priest.shadowWordPain.name
local VampiricTouch = kps.spells.priest.vampiricTouch.name

-- UnitHealthMax returns the maximum health of the specified unit, returns 0 if the specified unit does not exist (eg. "target" given but there is no target)
function kps.env.priest.DeathEnemyTarget()
    local DeathTarget = "target"
    local HealthTarget = 1
    for i=1,#EnemyTable do
        local enemy = EnemyTable[i]
        if UnitExists(enemy) then HealthTarget = UnitHealth(enemy) / UnitHealthMax(enemy) end
        if PlayerHasTalent(4,2) and HealthTarget < 0.35 and UnitIsAttackable(enemy) then
            DeathTarget = enemy
        elseif HealthTarget < 0.20 and UnitIsAttackable(enemy) then
            DeathTarget = enemy
        break end
    end
    return DeathTarget
end

-- Config FOCUS with MOUSEOVER
function kps.env.priest.FocusMouseover()
    if not UnitExists("focus") and not UnitIsUnit("target","mouseover") and UnitIsAttackable("mouseover") and UnitAffectingCombat("mouseover") then
        if not UnitHasBuff(VampiricTouch,"mouseover") then
            kps.runMacro("/focus mouseover")
        elseif not UnitHasBuff(ShadowWordPain,"mouseover") then
            kps.runMacro("/focus mouseover")
        else
            kps.runMacro("/focus mouseover")
        end
    end
    return nil, nil
end

--------------------------------------------------------------------------------------------
------------------------------- AVOID OVERHEALING
--------------------------------------------------------------------------------------------

local UnitCastingInfo = UnitCastingInfo
-- name, text, texture, startTimeMS, endTimeMS, isTradeSkill, castID, notInterruptible, spellId = UnitCastingInfo("unit")
-- name, text, texture, startTimeMS, endTimeMS, isTradeSkill, notInterruptible = UnitChannelInfo(self.unit)

function kps.env.priest.holyWordSerenityOnCD()
    if kps.spells.priest.holyWordSerenity.cooldown > kps.gcd then return true end
    return false
end

local overHealTableUpdate = function()
    -- kps.defensive in case I want to heal with mouseover (e.g. debuff absorb heal)
    local onCD = kps.env.priest.holyWordSerenityOnCD()
    if kps.defensive then onCD = true end
    local overHealTable = { {kps.spells.priest.flashHeal.name, 0.855 , onCD}, {kps.spells.priest.heal.name, 0.955 , onCD}, {kps.spells.priest.prayerOfHealing.name, 3 , kps.defensive} }
    return  overHealTable
end

local ShouldInterruptCasting = function (interruptTable, countLossInRange)
    if kps.lastTargetGUID == nil then return false end
    local spellCasting, _, _, _, endTime, _, _, _, _ = UnitCastingInfo("player")
    if spellCasting == nil then return false end
    if endTime == nil then return false end
    local targetHealth = UnitHealth(kps.lastTarget) / UnitHealthMax(kps.lastTarget)
    local target = kps.lastTarget

    for key, healSpellTable in pairs(interruptTable) do
        local breakpoint = healSpellTable[2]
        local spellName = healSpellTable[1]
        if spellName == spellCasting then
            if spellName == kps.spells.priest.prayerOfHealing.name and healSpellTable[3] == false and countLossInRange < breakpoint then
                SpellStopCasting()
                DEFAULT_CHAT_FRAME:AddMessage("STOPCASTING OverHeal "..spellName.."|".." countLossInRange: "..countLossInRange, 0, 0.5, 0.8)
            elseif spellName == kps.spells.priest.flashHeal.name and healSpellTable[3] == false and targetHealth > breakpoint  then
                SpellStopCasting()
                DEFAULT_CHAT_FRAME:AddMessage("STOPCASTING OverHeal "..spellName.."|"..target.." health: "..targetHealth, 0, 0.5, 0.8)
            elseif spellName == kps.spells.priest.heal.name and healSpellTable[3] == false and targetHealth > breakpoint then
                SpellStopCasting()
                DEFAULT_CHAT_FRAME:AddMessage("STOPCASTING OverHeal "..spellName.."|"..target.." health: "..targetHealth, 0, 0.5, 0.8)
            end
        end
    end
    return nil, nil
end

kps.env.priest.ShouldInterruptCasting = function()
    local countLossInRange = kps["env"].heal.countLossInRange(0.85)
    local interruptTable = overHealTableUpdate()
    return ShouldInterruptCasting(interruptTable, countLossInRange)
end

-- usage in Rotation -- env.FindUnitWithNoRenew,
local ArenaRBGFriends = { "player", "raid1", "raid2", "raid3", "raid4", "raid5", "raid6", "raid7", "raid8", "raid9", "raid10", "party1", "party2", "party3", "party4", "party5", "partypet1"}
kps.env.priest.FindUnitWithNoRenew = function()
    local renewUnit = nil
    local buff = kps.spells.priest.renew
    for i=1,#ArenaRBGFriends do
        local unit = ArenaRBGFriends[i]
        if UnitExists(unit) and not UnitBuff(unit,buff.name) then
            renewUnit = unit
        end
    end
    if renewUnit == nil then return nil, nil end
    return buff, renewUnit
end

--------------------------------------------------------------------------------------------
------------------------------- MESSAGE ON SCREEN
--------------------------------------------------------------------------------------------

local buffdivinity = kps.spells.priest.divinity.name
local function holyWordSanctifyOnScreen()
    if kps.spells.priest.holyWordSanctify.cooldown < kps.gcd and kps.timers.check("holyWordSanctify") == 0 and not UnitHasBuff(buffdivinity,"player") then
        kps.timers.create("holyWordSanctify", 10 )
        kps.utils.createMessage("holyWordSanctify Ready")
    end
end

kps.env.priest.ScreenMessage = function()
    return holyWordSanctifyOnScreen()
end


-- SendChatMessage("msg" [, "chatType" [, languageIndex [, "channel"]]])
-- Sends a chat message of the specified in 'msg' (ex. "Hey!"), to the system specified in 'chatType' ("SAY", "WHISPER", "EMOTE", "CHANNEL", "PARTY", "INSTANCE_CHAT", "GUILD", "OFFICER", "YELL", "RAID", "RAID_WARNING", "AFK", "DND"),
-- in the language specified in 'languageID', to the player or channel specified in 'channel'(ex. "1", "Bob").


--kps.events.register("UNIT_SPELLCAST_START", function(unitID,spellname,_,_,spellID)
--    if unitID == "player" and spellID ~= nil then
--    end
--end)

--kps.events.register("UNIT_SPELLCAST_CHANNEL_START", function(unitID,spellname,_,_,spellID)
--    if unitID == "player" and spellID ~= nil then
--        if spellID == 64843 then SendChatMessage("Casting DIVINE HYMN" , "RAID" ) end
--    end
--end)
