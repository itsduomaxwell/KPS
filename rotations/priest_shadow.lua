--[[[
@module Priest Shadow Rotation
@author htordeux
@version 7.2
]]--

local spells = kps.spells.priest
local env = kps.env.priest

local Dispersion = spells.dispersion.name
local MassDispel = spells.massDispel.name

kps.runAtEnd(function()
   kps.gui.addCustomToggle("PRIEST","SHADOW", "shadowWordPain", "Interface\\Icons\\Spell_shadow_shadowwordpain", "shadowWordPain")
end)

-- kps.cooldowns for dispel and powerInfusion
-- kps.interrupt for interrupts
-- kps.multiTarget for mindFlay multiTarget
kps.rotations.register("PRIEST","SHADOW",{

    {{"macro"}, 'not target.isAttackable and mouseover.isAttackable and mouseover.inCombat' , "/target mouseover" },
    {{"macro"}, 'not target.exists and mouseover.isAttackable and mouseover.inCombat' , "/target mouseover" },
    env.TargetMouseover,
    {{"macro"}, 'focus.exists and target.isUnit("focus")' , "/clearfocus" },
    {{"macro"}, 'focus.exists and not focus.isAttackable' , "/clearfocus" },
    env.FocusMouseover,

    -- "Dissipation de masse" 32375
    {{"macro"}, 'keys.ctrl', "/cast [@cursor] "..MassDispel },
    -- "Dispersion" 47585
    {spells.dispersion, 'player.hp < 0.40' },
    {{"macro"}, 'player.hasBuff(spells.dispersion) and player.hp == 1 and player.insanity == 100' , "/cancelaura "..Dispersion },
    --"Fade" 586
    {spells.fade, 'player.isTarget' },
    -- "Pierre de soins" 5512
    {{"macro"}, 'player.useItem(5512) and player.hp < 0.72', "/use item:5512" },
    -- "Don des naaru" 59544
    {spells.giftOfTheNaaru, 'player.hp < 0.72', "player" },
    -- "Power Word: Shield" 17
    {spells.powerWordShield, 'player.isMovingFor(1.2) and player.hasTalent(2,2) and not player.hasBuff(spells.bodyAndSoul)' , "player" , "SCHIELD_MOVING" },
    {spells.powerWordShield, 'player.isMovingFor(1.2) and spells.vampiricEmbrace.cooldown > kps.gcd and spells.dispersion.cooldown > kps.gcd and player.hp < 0.55 and not player.hasBuff(spells.powerWordShield)' , "player" , "SCHIELD_HEALTH" },
    -- "Etreinte vampirique" buff 15286 -- pendant 15 sec, vous permet de rendre à un allié proche, un montant de points de vie égal à 40% des dégâts d’Ombre que vous infligez avec des sorts à cible unique
    {spells.vampiricEmbrace, 'player.hasBuff(spells.voidform) and player.hp < 0.55' },
    {spells.vampiricEmbrace, 'player.hasBuff(spells.voidform) and heal.lowestTankInRaid.hp < 0.55' },
    -- "Guérison de l’ombre" 186263 -- debuff "Shadow Mend" 187464 10 sec
    {spells.shadowMend, 'not player.isMoving and not spells.shadowMend.lastCasted(4) and not player.hasBuff(spells.voidform) and player.hp < 0.40 and not player.hasBuff(spells.vampiricEmbrace)' , "player" },
     -- "Levitate" 1706
    {spells.levitate, 'player.isFallingFor(1.6) and not player.hasBuff(spells.levitate)' , "player" },
    {spells.levitate, 'player.isSwimming and not player.hasBuff(spells.levitate)' , "player" },

    -- interrupts
    {{"nested"}, 'kps.interrupt',{
        -- "Silence" 15487 -- debuff same ID
        {spells.silence, 'not target.hasDebuff(spells.mindBomb) and target.isInterruptable and target.distance < 30' , "target" },
        {spells.silence, 'not focus.hasDebuff(spells.mindBomb) and focus.isInterruptable and focus.distance < 30' , "focus" },
        -- "Mind Bomb" 205369 -- 30 yd range -- debuff "Explosion mentale" 226943
        {spells.mindBomb, 'target.isCasting and target.distance < 30' , "target" },
        {spells.mindBomb, 'focus.isCasting and focus.distance < 30' , "focus" },s
    }},
    {spells.mindBomb, 'not player.isInRaid and player.plateCount > 3 and target.distance < 10' , "target" },
    {spells.mindBomb, 'not player.isInRaid and player.isTarget and target.distance < 10' , "target" },
    
    -- TRINKETS "Trinket0Slot" est slotId  13 "Trinket1Slot" est slotId  14
    {{"macro"}, 'player.useTrinket(0) and player.hasBuff(spells.voidform)' , "/use 13"},
    {{"macro"}, 'player.useTrinket(1) and player.hasBuff(spells.voidform)' , "/use 14"},

    -- "Purify Disease" 213634
    {spells.purifyDisease, 'mouseover.isDispellable("Disease")' , "mouseover" },
    {{"nested"}, 'kps.cooldowns',{
        {spells.purifyDisease, 'player.isDispellable("Disease")' , "player" },
        {spells.purifyDisease, 'heal.isDiseaseDispellable ~= nil' , kps.heal.isDiseaseDispellable},
    }},
    
    -- "Ombrefiel" cd 3 min duration 12sec -- "Mindbender" cd 1 min duration 12 sec
    {spells.shadowfiend, 'not player.hasTalent(6,3) and player.hasBuff(spells.voidform) and player.haste > 50' , "target" },
    {spells.mindbender, 'player.hasTalent(6,3) and player.hasBuff(spells.voidform) and player.buffStacks(spells.voidform) > 25 and player.insanity < 80' , "target" },

    {{"macro"}, 'player.hasBuff(spells.voidform) and spells.voidEruption.cooldown == 0 and spells.mindFlay.castTimeLeft("player") > kps.gcd' , "/stopcasting" },
    {{"nested"}, 'player.hasBuff(spells.voidform)',{
        {spells.voidEruption, 'true' , "target" },
        {spells.voidEruption, 'true' , env.VoidBoltTarget },
        {spells.voidTorrent, 'not player.isMoving and spells.mindbender.cooldown < kps.gcd' },
        {spells.voidTorrent, 'not player.isMoving and player.buffStacks(spells.voidform) > 5 and player.insanity > 55' },
    }},
    
    -- "Shadow Word: Death" 32379
    {spells.shadowWordDeath, 'mouseover.isAttackable and mouseover.hp < 0.20' , "mouseover" },
    {spells.shadowWordDeath, 'target.hp < 0.20' , "target" },
    {spells.shadowWordDeath, 'focus.isAttackable and focus.hp < 0.20' , "focus" },
    
    {{spells.vampiricTouch,spells.shadowWordPain}, 'not player.isMoving and not target.hasMyDebuff(spells.vampiricTouch)' , 'target' },
    {{spells.vampiricTouch,spells.shadowWordPain}, 'focus.isAttackable and not player.isMoving and not focus.hasMyDebuff(spells.vampiricTouch)' , 'focus' },

    -- "Mindblast" is highest priority spell out of voidform
    {spells.mindBlast, 'not player.isMoving and not player.hasBuff(spells.voidform) and player.hasTalent(7,1) and player.insanity < 65' , "target" },
    {spells.mindBlast, 'not player.isMoving and not player.hasBuff(spells.voidform) and not player.hasTalent(7,1) and player.insanity < 100' , "target" },
    --{{"macro"}, 'not player.isMoving and player.hasBuff(spells.voidform) and spells.mindBlast.cooldown == 0 and spells.mindFlay.castTimeLeft("player") > kps.gcd' , "/stopcasting" },
    {spells.mindBlast, 'not player.isMoving and player.hasBuff(spells.voidform) and player.haste > 50' , "target" , "MINDBLAST" },
    {spells.mindBlast, 'not player.isMoving and player.hasBuff(spells.voidform) and not spells.mindBlast.isRecastAt("target")' , "target" },

    -- MultiTarget
    {{"nested"}, 'kps.multiTarget',{
        {spells.voidEruption, 'player.insanity == 100'},
        {spells.shadowWordPain, 'mouseover.isAttackable and mouseover.inCombat and not mouseover.hasMyDebuff(spells.shadowWordPain) and not spells.shadowWordPain.isRecastAt("mouseover")' , 'mouseover' },
        {spells.mindFlay, 'player.hasBuff(spells.voidform) and not player.isMoving and target.myDebuffDuration(spells.shadowWordPain) > 4' , "target" , "MULTITARGET" },
    }},    

     -- "Void Eruption" 228260
    {{"nested"}, 'not player.isMoving and not player.hasBuff(spells.voidform) and target.myDebuffDuration(spells.vampiricTouch) > 4 and target.myDebuffDuration(spells.shadowWordPain) > 4',{
        {spells.voidEruption, 'player.insanity == 100'},
        {spells.voidEruption, 'player.insanity > 64 and player.hasTalent(7,1)'},
    }},

    -- kps.shadowWordPain
    {{"nested"}, 'mouseover.isAttackable and kps.shadowWordPain',{
        {{spells.vampiricTouch,spells.shadowWordPain}, 'not player.isMoving and not mouseover.hasMyDebuff(spells.vampiricTouch)' , 'mouseover' },
        {spells.shadowWordPain, 'not mouseover.hasMyDebuff(spells.shadowWordPain) and not spells.shadowWordPain.isRecastAt("mouseover")' , 'mouseover' },
    }},

    {{"nested"}, 'not player.isMoving',{
        {spells.vampiricTouch, 'not target.hasMyDebuff(spells.vampiricTouch) and not spells.vampiricTouch.isRecastAt("target")' , 'target' },
        {spells.vampiricTouch, 'focus.isAttackable and not focus.hasMyDebuff(spells.vampiricTouch) and not spells.vampiricTouch.isRecastAt("focus")' , 'focus' },
        {spells.vampiricTouch, 'mouseover.isAttackable and mouseover.inCombat and not mouseover.hasMyDebuff(spells.vampiricTouch) and not spells.vampiricTouch.isRecastAt("mouseover")' , 'mouseover' },
    }},

    {spells.shadowWordPain, 'not target.hasMyDebuff(spells.shadowWordPain) and not spells.shadowWordPain.isRecastAt("target")' , 'target' },
    {spells.shadowWordPain, 'focus.isAttackable and not focus.hasMyDebuff(spells.shadowWordPain) and not spells.shadowWordPain.isRecastAt("focus")' , 'focus' },
    {spells.shadowWordPain, 'mouseover.isAttackable and mouseover.inCombat and not mouseover.hasMyDebuff(spells.shadowWordPain) and not spells.shadowWordPain.isRecastAt("mouseover")' , 'mouseover' },
    
    {spells.mindFlay, 'not player.isMoving' , "target" },
    {spells.mindFlay, 'not player.isMoving and focus.isAttackable' , "focus" },

},"Shadow Priest")

-- MACRO --
--[[

#showtooltip Mot de l’ombre : Douleur
/cast [@mouseover,exists,nodead,harm][@target] Mot de l’ombre : Douleur

––]]
