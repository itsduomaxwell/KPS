--[[
Unit Auras:
Functions which handle unit auras
]]--

local Unit = kps.Unit.prototype
local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff
local UnitCanAssist = UnitCanAssist

-- name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, isCastByPlayer, ... = UnitAura("unit", "name")
-- name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, ... = UnitBuff("unit", "name")
-- name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, ... = UnitDebuff("unit", "name")

--[[[
@function `<UNIT>.hasBuff(<SPELL>)` - return true if the unit has the given buff (`target.hasBuff(spells.renew)`)
]]--
local hasBuff = setmetatable({}, {
    __index = function(t, unit)
        local val = function (spell)
--            if select(1,AuraUtil.FindAuraByName(spell.name, unit, "HELPFUL")) then return true end
--            return false
           for i=1,40 do
               local name,_ = UnitBuff(unit,i)
               if name ~= nil and name == spell.name then return true end
           end
           return false
        end
        t[unit] = val
        return val
    end})
function Unit.hasBuff(self)
    return hasBuff[self.unit]
end

--[[[
@function `<UNIT>.hasDebuff(<SPELL>)` - returns true if the unit has the given debuff (`target.hasDebuff(spells.immolate)`)
]]--
local hasDebuff = setmetatable({}, {
    __index = function(t, unit)
        local val = function (spell)
--            if select(1,AuraUtil.FindAuraByName(spell.name, unit, "HARMFUL")) then return true end
--            return false
           for i=1,40 do
               local name,_ = UnitDebuff(unit,i)
               if name ~= nil and name == spell.name then return true end
           end
           return false
        end
        t[unit] = val
        return val
    end})
function Unit.hasDebuff(self)
    return hasDebuff[self.unit]
end

--[[[
@function `<UNIT>.hasMyDebuff(<SPELL>)` - returns true if the unit has the given debuff _AND_ the debuff was cast by the player (`target.hasMyDebuff(spells.immolate)`)
]]--
local hasMyDebuff = setmetatable({}, {
    __index = function(t, unit)
        local val = function (spell)
            for i=1,40 do
               local name,_,_,_,_,duration,endTime,caster,_,_ = UnitDebuff(unit,i)
               if name ~= nil and caster == "player" and name == spell.name then return true end
           end
            return false
        end
        t[unit] = val
        return val
    end})
function Unit.hasMyDebuff(self)
    return hasMyDebuff[self.unit]
end

--[[[
@function `<UNIT>.myBuffDuration(<SPELL>)` - returns the remaining duration of the buff on the given unit if the buff was cast by the player
]]--
local myBuffDuration = setmetatable({}, {
    __index = function(t, unit)
        local val = function (spell)
            for i=1,40 do
                local name,_,_,_,_,duration,endTime,caster,_,_ = UnitBuff(unit,i)
                if caster == "player" and name == spell.name then
                    if endTime==nil then return 0 end
                    local timeLeft = endTime-GetTime() -- lag?
                    if timeLeft < 0 then return 0 end
                    return timeLeft
                end
            end
            return 0
        end
        t[unit] = val
        return val
    end})
function Unit.myBuffDuration(self)
    return myBuffDuration[self.unit]
end

--[[[
@function `<UNIT>.myDebuffDuration(<SPELL>)` - returns the remaining duration of the debuff on the given unit if the debuff was cast by the player
]]--
local myDebuffDuration = setmetatable({}, {
    __index = function(t, unit)
        local val = function (spell)
            for i=1,40 do
                local name,_,_,_,_,duration,endTime,caster,_,_ = UnitDebuff(unit,i)
                if caster == "player" and name == spell.name then
                    if endTime==nil then return 0 end
                    local timeLeft = endTime-GetTime() -- lag?
                    if timeLeft < 0 then return 0 end
                    return timeLeft
                end
            end
            return 0
        end
        t[unit] = val
        return val
    end})
function Unit.myDebuffDuration(self)
    return myDebuffDuration[self.unit]
end

--[[[
@function `<UNIT>.myDebuffDurationMax(<SPELL>)` - returns the total duration of the given debuff if it was cast by the player
]]--
local myDebuffDurationMax = setmetatable({}, {
    __index = function(t, unit)
        local val = function (spell)
            for i=1,40 do
                local name,_,_,_,_,duration,endTime,caster,_,_ = UnitDebuff(unit,i)
                if caster == "player" and name == spell.name then
                    if endTime==nil then return 0 end
                    return duration
                end
            end
            return 0
        end
        t[unit] = val
        return val
    end})
function Unit.myDebuffDurationMax(self)
    return myDebuffDurationMax[self.unit]
end

--[[[
@function `<UNIT>.buffDuration(<SPELL>)` - returns the remaining duration of the given buff
]]--
local buffDuration = setmetatable({}, {
    __index = function(t, unit)
        local val = function (spell)
            local _,_,_,_,_,_,endTime,caster,_,_,_ = UnitBuff(unit,spell.name)
            if endTime == nil then return 0 end
            local duration = endTime-GetTime() -- lag?
            if duration < 0 then return 0 end
            return duration
        end
        t[unit] = val
        return val
    end})
function Unit.buffDuration(self)
    return buffDuration[self.unit]
end


--[[[
@function `<UNIT>.debuffDuration(<SPELL>)` - returns the remaining duration of the given debuff
]]--
local debuffDuration = setmetatable({}, {
    __index = function(t, unit)
        local val = function (spell)
            local _,_,_,_,_,_,duration,caster,_,_ = UnitDebuff(unit,spell.name)
            if duration==nil then return 0 end
            duration = duration-GetTime() -- jps.Lag
            if duration < 0 then return 0 end
            return duration
        end
        t[unit] = val
        return val
    end})
function Unit.debuffDuration(self)
    return debuffDuration[self.unit]
end


--[[[
@function `<UNIT>.debuffStacks(<SPELL>)` - returns the debuff stacks on for the given <SPELL> on this unit
]]--
local debuffStacks = setmetatable({}, {
    __index = function(t, unit)
        local val = function (spell)
            local _,_,_,count, _,_,_,_,_,_ = UnitDebuff(unit,spell.name)
            if count == nil then count = 0 end
            return count
        end
        t[unit] = val
        return val
    end})
function Unit.debuffStacks(self)
    return debuffStacks[self.unit]
end

--[[[
@function `<UNIT>.buffStacks(<SPELL>)` - returns the buff stacks on for the given <SPELL> on this unit
]]--
local buffStacks = setmetatable({}, {
    __index = function(t, unit)
        local val = function (spell)
            local _, _, _, count, _, _, _, _, _ = UnitBuff(unit,spell.name)
            if count == nil then count = 0 end
            return count
        end
        t[unit] = val
        return val
    end})
function Unit.buffStacks(self)
    return buffStacks[self.unit]
end


--[[[
@function `<UNIT>.debuffCount(<SPELL>)` - returns the number of different debuffs (not counting the stacks!) on for the given <SPELL> on this unit
]]--
local debuffCount = setmetatable({}, {
    __index = function(t, unit)
        local val = function (spell)
            local count = 0
            for i=1,40 do
                local name,_,_,_,_,duration,endTime,caster,_,_ = UnitDebuff(unit,i)
                if caster == "player" and name == spell.name then
                    count = count + 1
                end
            end
            return count
        end
        t[unit] = val
        return val
    end})
function Unit.debuffCount(self)
    return debuffCount[self.unit]
end

--[[[
@function `<UNIT>.buffCount(<SPELL>)` - returns the number of different buffs (not counting the stacks!) on for the given <SPELL> on this unit
]]--
local buffCount = setmetatable({}, {
    __index = function(t, unit)
        local val = function (spell)
            local count = 0
            for i=1,40 do
                local name,_,_,_,_,duration,endTime,caster,_,_ = UnitBuff(unit,i)
                if name == spell.name then
                    count = count + 1
                end
            end
            return count
        end
        t[unit] = val
        return val
    end})
function Unit.buffCount(self)
    return buffCount[self.unit]
end

--[[[
@function `<UNIT>.myDebuffCount(<SPELL>)` - returns the number of different debuffs (not counting the stacks!) on for the given <SPELL> on this unit if the spells were cast by the player
]]--
local myDebuffCount = setmetatable({}, {
    __index = function(t, unit)
        local val = function (spell)
            local count = 0
            for i=1,40 do
                local name,_,_,_,_,duration,endTime,caster,_,_ = UnitDebuff(unit,i)
                if name == spell.name then
                    count = count + 1
                end
            end
            return count
        end
        t[unit] = val
        return val
    end})
function Unit.myDebuffCount(self)
    return myDebuffCount[self.unit]
end

--[[[
@function `<UNIT>.myBuffCount(<SPELL>)` - returns the number of different buffs (not counting the stacks!) on for the given <SPELL> on this unit if the spells were cast by the player
]]--
local myBuffCount = setmetatable({}, {
    __index = function(t, unit)
        local val = function (spell)
            local count = 0
            for i=1,40 do
                local name,_,_,_,_,duration,endTime,caster,_,_ = UnitBuff(unit,i)
                if caster == "player" and name == spell.name then
                    count = count + 1
                end
            end
            return count
        end
        t[unit] = val
        return val
    end})
function Unit.myBuffCount(self)
    return myBuffCount[self.unit]
end

--[[[
@function `<UNIT>.buffValue(<BUFF>)` - returns the amount of a given <BUFF> on this unit e.g. player.buffValue(spells.masteryEchoOfLight)
]]--

local buffValue = setmetatable({}, {
    __index = function(t, unit)
        local val = function (spell)
            local value = 0
            local name = select(1,UnitBuff(unit,spell.name))
            if  name ~= nil then
                value = select(17,UnitBuff(unit,spell.name))
            end
            return value
        end
        t[unit] = val
        return val
    end})
function Unit.buffValue(self)
    return buffValue[self.unit]
end

--[[[
@function `<UNIT>.isDispellable(<DISPEL>)` - returns true if the FRIENDLY unit has a dispellable debuff. DISPEL TYPE "Magic", "Poison", "Disease", "Curse". e.g. player.isDispellable("Magic")
]]--
local UnitCanAssist = UnitCanAssist
local isDebuffDispellable = setmetatable({}, {
    __index = function(t, unit)
        local val = function (dispelType)
            if not UnitCanAssist("player", unit) then return false end
            local auraName, debuffType, expTime, spellId
            local i = 1
            auraName, _, _, _, debuffType, _, expTime, _, _, _, spellId = UnitDebuff(unit,i)
            if dispelType == nil then dispelType = "Magic" end
            while auraName do
                if debuffType ~= nil and debuffType == dispelType then
                    return true
                end
                i = i + 1
                auraName, _, _, _, debuffType, _, expTime, _, _, _, spellId = UnitDebuff(unit,i)
            end
            return false
        end
        t[unit] = val
        return val
    end})
function Unit.isDispellable(self)
    return isDebuffDispellable[self.unit]
end

--[[[
@function `<UNIT>.isBuffDispellable` - returns true if the ENEMY unit has a dispellable "Magic" buff. e.g. target.isBuffDispellable
]]--

function Unit.isBuffDispellable(self)
    if UnitCanAssist("player", self.unit) then return false end
    local auraName, debuffType, expTime, spellId
    local i = 1
    auraName, _, _, _, debuffType, _, expTime, _, _, _, spellId = UnitBuff(self.unit,i) 
        while auraName do
            if debuffType ~= nil and debuffType == "Magic" then
                return true
            end
            i = i + 1
            auraName, _, _, _, debuffType, _, expTime, _, _, _, spellId = UnitBuff(self.unit,i)
        end
    return false
end

--[[[
@function `<UNIT>.absorptionHeal` - returns true if the unit has an Absorption Healing Debuff
]]--
function Unit.absorptionHeal(self)
    for _,spell in pairs(kps.spells.absorptionHeal) do
        if self.hasDebuff(spell) then return true end
    end
    return false
end

--[[[
@function `<UNIT>.immuneHeal` - returns true if the unit has an Immune Healing Debuff
]]--
function Unit.immuneHeal(self)
    for _,spell in pairs(kps.spells.immuneHeal) do
        if self.hasDebuff(spell) then return true end
    end
    return false
end

--[[[
@function `<UNIT>.hasBossDebuff` - return true if the FRIENDLY unit has a boss debuff e.g. `target.hasBossDebuff`
]]--

function Unit.hasBossDebuff(self)
    if not UnitCanAssist("player", self.unit) then return false end
    local auraName, debuffType, spellId, isBossDebuff
    local i = 1
    auraName, _, _, _, debuffType, _, _, _, _, _, spellId, _, isBossDebuff = UnitDebuff(self.unit,i)
    while auraName do
        if debuffType ~= nil and isBossDebuff then
            return true
        end
        i = i + 1
        auraName, _, _, _, debuffType, _, _, _, _, _, spellId,_, isBossDebuff = UnitDebuff(self.unit,i)
    end
    return false
end

--[[[
@function `<UNIT>.isStealable` - return true if the ENEMY unit has a stealable buff e.g. `target.isStealable`
]]--

function Unit.isStealable(self)
    if UnitCanAssist("player", self.unit) then return false end
    local auraName, debuffType, spellId, isStealable
    local i = 1
    auraName, _, _, _, debuffType, _, _, _, isStealable, _, spellId = UnitBuff(self.unit,i)
    while auraName do
        if debuffType ~= nil and isStealable then
            return true
        end
        i = i + 1
         auraName, _, _, _, debuffType, _, _, _, isStealable, _, spellId = UnitBuff(self.unit,i)
    end
    return false
end