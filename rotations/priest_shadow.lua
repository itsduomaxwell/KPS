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

kps.rotations.register("PRIEST","SHADOW",{

    {{"macro"}, 'not target.isAttackable and mouseover.isAttackable and mouseover.inCombat' , "/target mouseover" },
    {{"macro"}, 'not target.exists and mouseover.isAttackable and mouseover.inCombat' , "/target mouseover" },
    env.FocusMouseover,
    {{"macro"}, 'focus.exists and target.isUnit("focus")' , "/clearfocus" },
    {{"macro"}, 'focus.exists and not focus.isAttackable' , "/clearfocus" },

    -- "Dissipation de masse" 32375
    {{"macro"}, 'keys.ctrl', "/cast [@cursor] "..MassDispel },
    -- "Dispersion" 47585
    {spells.dispersion, 'player.hp < 0.40' },
    {{"macro"}, 'player.hasBuff(spells.dispersion) and player.hp > 0.995' , "/cancelaura "..Dispersion },
    --"Fade" 586
    {spells.fade, 'player.isTarget' },
    -- "Pierre de soins" 5512
    {{"macro"}, 'player.useItem(5512) and player.hp < 0.72', "/use item:5512" },
    -- "Don des naaru" 59544
    {spells.giftOfTheNaaru, 'player.hp < 0.72', "player" },
     -- "Etreinte vampirique" buff 15286 -- pendant 15 sec, vous permet de rendre à un allié proche, un montant de points de vie égal à 40% des dégâts d’Ombre que vous infligez avec des sorts à cible unique
    {spells.vampiricEmbrace, 'player.hasBuff(spells.voidform) and player.hp < 0.55' },
    
    -- interrupts
    {{"nested"}, 'kps.interrupt',{
        -- "Silence" 15487 -- debuff same ID
        {spells.silence, 'not target.hasDebuff(spells.mindBomb) and target.isInterruptable and target.distance < 30' , "target" },
        {spells.silence, 'not focus.hasDebuff(spells.mindBomb) and focus.isInterruptable and focus.distance < 30' , "focus" },
        -- "Mind Bomb" 205369 -- 30 yd range -- debuff "Explosion mentale" 226943
        {spells.mindBomb, 'target.isCasting and target.distance < 30' , "target" },
        {spells.mindBomb, 'focus.isCasting and focus.distance < 30' , "focus" },
        {spells.mindBomb, 'not player.isInRaid and player.plateCount > 3 and target.distance < 10' , "target" },
        {spells.mindBomb, 'not player.isInRaid and player.isTarget and target.distance < 10' , "target" },
        -- "Secret de Sephuz" 132452
        {spells.mindBomb, 'IsEquippedItem(132452) and player.hasBuff(spells.voidform) and spells.voidTorrent.lastCasted(10)'},
        {spells.mindBomb, 'IsEquippedItem(132452) and player.hasBuff(spells.voidform) and spells.mindbender.lastCasted(15)'},
    }},
    -- "Dissipation de la magie" -- Dissipe la magie sur la cible ennemie, supprimant ainsi 1 effet magique bénéfique.
    {spells.dispelMagic, 'target.isAttackable and target.isBuffDispellable' , "target" },

    -- TRINKETS "Trinket0Slot" est slotId  13 "Trinket1Slot" est slotId  14
    {{"macro"}, 'player.useTrinket(0) and player.hasBuff(spells.voidform)' , "/use 13"},
    {{"macro"}, 'player.useTrinket(1) and player.hasBuff(spells.voidform)' , "/use 14"},

    -- "Shadow Word: Death" 32379
    {spells.shadowWordDeath, 'mouseover.isAttackable and mouseover.hp < 0.20' , "mouseover" },
    {spells.shadowWordDeath, 'target.hp < 0.20' , "target" },
    {spells.shadowWordDeath, 'focus.isAttackable and focus.hp < 0.20' , "focus" },
    
    {{"macro"}, 'not player.hasBuff(spells.voidform) and spells.voidEruption.isUsable and spells.mindFlay.castTimeLeft("player") > kps.gcd' , "/stopcasting" },
    {spells.voidEruption, 'not player.isMoving and spells.voidEruption.isUsable and not player.hasBuff(spells.voidform)'},
    {spells.voidEruption, 'not player.isMoving and player.insanity == 100 and not player.hasBuff(spells.voidform)'},
    
    -- Voidbolt extends the duration of Shadow Word: Pain and Vampiric Touch on all nearby targets by 3.0 sec For the duration of Voidform -- 
    {{"nested"}, 'player.hasBuff(spells.voidform)',{
        {spells.vampiricTouch, 'not player.isMoving and not target.hasMyDebuff(spells.vampiricTouch) and target.isAttackable and not spells.vampiricTouch.isRecastAt("target")' , 'target' },
        {spells.shadowWordPain, 'not target.hasMyDebuff(spells.shadowWordPain) and target.isAttackable and not spells.shadowWordPain.isRecastAt("target")' , 'target' },
        {{"macro"}, 'not kps.multiTarget and player.hasBuff(spells.voidform) and spells.voidBolt.cooldown == 0 and spells.mindFlay.castTimeLeft("player") > kps.gcd' , "/stopcasting" },
        {spells.voidBolt , "target.isAttackable" , "target" },
        {spells.voidTorrent, 'not player.isMoving and player.buffStacks(spells.voidform) < 15 and spells.mindbender.cooldown < 35' },
        {spells.mindBlast, 'not player.isMoving and target.isAttackable' , "target" },
        -- "Ombrefiel" cd 3 min duration 12 sec -- "Mindbender" cd 1 min duration 12 sec player.hasTalent(6,3)
        {spells.mindbender, 'spells.voidTorrent.lastCasted(30) and player.buffStacks(spells.voidform) > 25' , "target" },
    }},

    {{"nested"}, 'not player.isMoving',{
        {{spells.vampiricTouch,spells.shadowWordPain}, 'kps.shadowWordPain and not player.isMoving and mouseover.isAttackable and not mouseover.hasMyDebuff(spells.vampiricTouch)' , 'mouseover' },
        {{spells.vampiricTouch,spells.shadowWordPain}, 'not target.hasMyDebuff(spells.vampiricTouch) and target.isAttackable' , 'target' },
        {{spells.vampiricTouch,spells.shadowWordPain}, 'not focus.hasMyDebuff(spells.vampiricTouch) and focus.isAttackable' , 'focus' },
        {{spells.vampiricTouch,spells.shadowWordPain}, 'mouseover.inCombat and mouseover.isAttackable and not mouseover.hasMyDebuff(spells.vampiricTouch)' , 'mouseover' },
    }},
    {spells.shadowWordPain, 'kps.shadowWordPain and mouseover.isAttackable and not mouseover.hasMyDebuff(spells.shadowWordPain) and not spells.shadowWordPain.isRecastAt("mouseover")' , 'mouseover' },
    {spells.shadowWordPain, 'not target.hasMyDebuff(spells.shadowWordPain) and target.isAttackable and not spells.shadowWordPain.isRecastAt("target")' , 'target' },
    {spells.shadowWordPain, 'not focus.hasMyDebuff(spells.shadowWordPain) and focus.isAttackable and not spells.shadowWordPain.isRecastAt("focus")' , 'focus' },
    {spells.shadowWordPain, 'mouseover.inCombat and mouseover.isAttackable and not mouseover.hasMyDebuff(spells.shadowWordPain) and not spells.shadowWordPain.isRecastAt("mouseover")' , 'mouseover' },

     -- "Levitate" 1706
    {spells.levitate, 'player.isFallingFor(1.6) and not player.hasBuff(spells.levitate)' , "player" },
    {spells.levitate, 'player.isSwimming and not player.hasBuff(spells.levitate)' , "player" },
    -- "Power Word: Shield" 17 -- "Body and Soul"
    {spells.powerWordShield, 'player.isMovingFor(1.2) and player.hasTalent(2,2) and not player.hasBuff(spells.bodyAndSoul)' , "player" , "SCHIELD_MOVING" },
    {spells.powerWordShield, 'player.hp < 0.72 and not player.hasBuff(spells.voidform) and not player.hasBuff(spells.powerWordShield) and not player.hasBuff(spells.vampiricEmbrace)' , "player" , "SCHIELD_HEALTH" },
    -- "Guérison de l’ombre" 186263 -- debuff "Shadow Mend" 187464 10 sec
    {spells.shadowMend, 'not player.isMoving and not player.hasTalent(2,3) and not spells.shadowMend.lastCasted(4) and player.hp < 0.60 and not player.hasBuff(spells.vampiricEmbrace)' , "player" },
    {spells.shadowMend, 'not player.isMoving and player.hasTalent(2,3) and not spells.shadowMend.lastCasted(4) and player.hp < 0.90 and not player.hasBuff(spells.masochism) and not player.hasBuff(spells.vampiricEmbrace)' , "player" },

    -- "Purify Disease" 213634
    {{"nested"}, 'kps.cooldowns',{
        {spells.purifyDisease, 'mouseover.isDispellable("Disease")' , "mouseover" },
        {spells.purifyDisease, 'player.isDispellable("Disease")' , "player" },
        {spells.purifyDisease, 'heal.isDiseaseDispellable ~= nil' , kps.heal.isDiseaseDispellable},
    }},

    {spells.mindBlast, 'not player.isMoving and target.isAttackable' , 'target' },
    {spells.mindFlay, 'not player.isMoving' , "target" },
    {spells.mindFlay, 'not player.isMoving and focus.isAttackable' , "focus" },

},"Shadow Priest")


-- MACRO --
--[[

#showtooltip Mot de l’ombre : Douleur
/cast [@mouseover,exists,nodead,harm][@target] Mot de l’ombre : Douleur

––]]
