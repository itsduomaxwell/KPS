
local LOG=kps.Logger(kps.LogLevel.INFO)

local castSequenceIndex = 1
local castSequence = nil
local castSequenceStartTime = 0
local castSequenceTarget = 0
local prioritySpell = nil
local priorityAction = nil
local priorityMacro = nil

function _RunMacroText(macroText)
    macroText = macroText or ""
    secured = false
    while not secured do
        RunScript([[
        for index = 1, 100 do
            if not issecure() then return end
        end
        secured = true
        RunMacroText("]] .. macroText .. [[")
    ]])
   end
end

function kps.runMacro(macroText)
    _RunMacroText(macroText)
end

function _SpellStopCasting()
   secured = false
   while not secured do
      RunScript([[
         for index = 1, 100 do
            if not issecure() then
               return
            end
         end
         secured = true
         SpellStopCasting()
      ]])
   end
end

kps.stopCasting = function()
    _SpellStopCasting()
end

function kps.write(...)
    DEFAULT_CHAT_FRAME:AddMessage("|cffff8000KPS: " .. strjoin(" ", tostringall(...))); -- color orange
end

kps.useItem = function(bagItem)
    return function ()
    
    end
    -- TODO: Return a FUNCTION which uses Item!
end

local function handlePriorityActions(spell)
    if priorityMacro ~= nil then
        kps.runMacro(priorityMacro)
        priorityMacro = nil
    elseif priorityAction ~= nil then
        priorityAction()
        priorityAction = nil
    elseif prioritySpell ~= nil then
        if prioritySpell.canBeCastAt("target") then
            prioritySpell.cast()
            LOG.warn("Priority Spell %s was casted.", prioritySpell)
            prioritySpell = nil
        else
            if prioritySpell.cooldown > 3 then prioritySpell = nil end
            return false
        end
    else
        return false
    end
    return true
end

kps.combatStep = function ()
    -- Check for combat
    if not InCombatLockdown() and not kps.autoAttackEnabled then return end

    -- Check for rotation
    if not kps.rotations.getActive() then
        kps.write("KPS does not have a rotation for your class (", kps.classes.className() ,") or spec (", kps.classes.specName(), ")!")
        kps.enabled = false
    end

    local player = kps.env.player

    -- No combat if mounted (except if overriden by config), dead or drinking
    if (player.isMounted and not kps.config.dismountInCombat) or player.isDead or player.isDrinking then
        return
    end
    

    if castSequence ~= nil then
        if castSequence[castSequenceIndex] ~= nil and (castSequenceStartTime + kps.maxCastSequenceLength > GetTime()) then
            local spell = castSequence[castSequenceIndex]()
            if spell.canBeCastAt(castSequenceTarget) and not player.isCasting then
                kps.write("Cast-Sequence: |cffffffff"..spell)
                LOG.debug("Cast-Sequence: %s. %s", castSequenceIndex, spell)
                spell.cast(castSequenceTarget)
                castSequenceIndex = castSequenceIndex + 1
            end
        else
            castSequenceIndex = nil
            castSequence = nil
        end
    else
        local activeRotation = kps.rotations.getActive()
        if not activeRotation then return end
        activeRotation.checkTalents()
        local spell, target, message = nil, nil, nil
        local spell, target, message = activeRotation.getSpell()
        
        if player.pause then return end
            
        if spell ~= nil and not player.isCasting then
            if priorityMacro ~= nil then
                kps.runMacro(priorityMacro)
                priorityMacro = nil
            elseif priorityAction ~= nil then
                priorityAction()
                priorityAction = nil
            elseif prioritySpell ~= nil then
                if prioritySpell.canBeCastAt("target") then
                    prioritySpell.cast()
                    LOG.warn("Priority Spell %s was casted.", prioritySpell)
                    prioritySpell = nil
                else
                    if prioritySpell.cooldown > 2 then prioritySpell = nil end
                    spell.cast(target,message)
                end
            elseif spell.id == nil then
                LOG.debug("Starting Cast-Sequence...")
                castSequenceIndex = 1
                castSequence = spell
                castSequenceStartTime = GetTime()
                castSequenceTarget = target
            else
                LOG.debug("Casting %s for next cast.", spell.name)
                spell.cast(target, message)
            end
        end
    end
end

hooksecurefunc("UseAction", function(...)
    if kps.enabled and (select(3, ...) ~= nil) and InCombatLockdown() == true  then
        local stype,id,_ = GetActionInfo(select(1, ...))
        if stype == "spell" then
            local spell = kps.Spell.fromId(id)
            if (prioritySpell == nil or prioritySpell.name ~= spell.name) and spell.isPrioritySpell then
                prioritySpell = spell
                LOG.warn("Set %s for next cast.", spell.name)
            end
        end
        if stype == "item" then
            priorityAction = kps.useItem(id)
        end
        if stype == "macro" then
            macroText = select(3, GetMacroInfo(id))
            if string.find(macroText,"kps") == nil then
                priorityMacro = macroText
            end
        end
    end
end)
