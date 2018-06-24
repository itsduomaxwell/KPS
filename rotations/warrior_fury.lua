--[[[
@module Warrior Fury Rotation
@author Kirk24788.xvir.subzrk
@version 7.0.3
]]--

local spells = kps.spells.warrior
local env = kps.env.warrior

local HeroicLeap = spells.heroicLeap.name

kps.runAtEnd(function()
   kps.gui.addCustomToggle("WARRIOR","FURY", "berserker", "Interface\\Icons\\spell_nature_ancestralguardian", "berserker")
end)

-- kps.defensive for charge
-- kps.interrupt for interrupts
-- kps.multiTarget for multiTarget
kps.rotations.register("WARRIOR","FURY",
{

    {{"macro"}, 'keys.shift and not player.hasBuff(spells.battleCry)', "/cast [@cursor] "..HeroicLeap },

    {{"macro"}, 'not target.isAttackable and mouseover.isAttackable and mouseover.inCombat and mouseover.distance < 10' , "/target mouseover" },
    {{"macro"}, 'not target.exists and mouseover.isAttackable and mouseover.inCombat and mouseover.distance < 10' , "/target mouseover" },
    env.FocusMouseover,
    {{"macro"}, 'focus.exists and target.isUnit("focus")' , "/clearfocus" },
    {{"macro"}, 'focus.exists and not focus.isAttackable' , "/clearfocus" },
    env.ScreenMessage,

    {spells.berserkerRage, 'not player.hasFullControl' },
    {spells.berserkerRage, 'kps.berserker and player.hasTalent(3,2) and not player.hasBuff(spells.enrage)' },
    -- Charge enemy
    {spells.heroicThrow, 'kps.defensive and target.isAttackable and target.distance > 10' },
    {spells.charge, 'kps.defensive and target.isAttackable and target.distance > 10' },

    -- interrupts
    {spells.pummel, 'kps.interrupt and target.distance < 10 and target.isInterruptable and target.castTimeLeft < 1' , "target" },
    {spells.pummel, 'kps.interrupt and focus.distance < 10 and focus.isInterruptable and focus.castTimeLeft < 1' , "focus" },

    -- "Pierre de soins" 5512
    {{"macro"}, 'player.useItem(5512) and player.hp < 0.90', "/use item:5512" },
    {spells.bloodthirst, 'player.hasBuff(spells.enragedRegeneration)' },
    {spells.enragedRegeneration, 'spells.bloodthirst.cooldown < kps.gcd and player.hp < 0.70' },
    {spells.commandingShout, 'player.hp < 0.60' },
    {spells.stoneform, 'player.isDispellable("Disease")' , "player" },
    {spells.stoneform, 'player.isDispellable("Poison")' , "player" },
    {spells.stoneform, 'player.isDispellable("Magic")' , "player" },
    {spells.stoneform, 'player.isDispellable("Curse")' , "player" },
    {spells.stoneform, 'player.incomingDamage > player.hpMax * 0.10' },

    {spells.intimidatingShout, 'not player.isInRaid and player.plateCount > 3' },
    {spells.intimidatingShout, 'not player.isInRaid and player.incomingDamage > player.hpMax * 0.10' },
    --{spells.piercingHowl, 'not player.isInRaid and player.plateCount > 3' },

    {spells.execute, 'player.hasBuff(spells.stoneHeart)' , "target" , "execute_stoneHeart" },
    {spells.avatar, 'spells.battleCry.cooldown < 4 and target.isAttackable and target.distance < 10' }, -- 90 sec cd
    {spells.bloodbath, 'spells.battleCry.cooldown < 4 and target.isAttackable and target.distance < 10' }, -- 30 sec cd
    {spells.battleCry, 'target.isAttackable and target.distance < 10' }, -- 50 sec cd -- generates 100 rage

    {{"nested"}, 'player.hasBuff(spells.battleCry)', {
        {spells.rampage , 'true', "target" , "rampage_battleCry" },
        {spells.odynsFury , 'player.hasBuff(spells.enrage)', "target" , "odynsFury_battleCry" }, -- 45 sec cd
        {spells.bloodthirst , 'true', "target" , "bloodthirst_battleCry" },
        {spells.whirlwind, 'kps.multiTarget and target.distance < 10' , "target" , "whirlwind_battleCry" },
        {spells.execute, 'target.hp < 0.20 and player.hasBuff(spells.enrage)' , "target" , "execute_battleCry" },
        {spells.ragingBlow , 'player.hasBuff(spells.enrage)', "target" , "ragingBlow_battleCry" },
        {spells.furiousSlash , 'true', "target" , "furiousSlash_battleCry" },
    }},
    
    -- TRINKETS
    -- "Souhait ardent de Kil'jaeden" 144259
    {{"macro"}, 'player.timeInCombat > 30 and player.useTrinket(0)' , "/use 13" },
    {{"macro"}, 'player.timeInCombat > 30 and player.useTrinket(1)' , "/use 14" },

    -- "Frothing Berserker" "Berserker écumant" -- player.hasTalent(5,2) -- Lorsque vous atteignez 100 point de rage, vos dégâts sont augmentés de 15% et votre vitesse de déplacement de 30% pendant 6 sec.
    -- "Rampage" can be used prior to Battle Cry even with less than 100 rage. You should not delay Battle Cry to ensure either Rampage is used first
    {spells.rampage, 'player.hasTalent(5,2) and player.rage == 100' , "target" , "rampage_dump_rage" },
    {spells.rampage, 'not player.hasTalent(5,2)' , "target" , "rampage_dump_rage" },
    {spells.rampage, 'spells.battleCry.cooldown < 4' , "target" , "rampage_battleCry_cooldown" },

    {{"nested"}, 'target.hp < 0.20', {
        {spells.execute, 'player.hasBuff(spells.enrage)' , "target" , "execute_enrage" },
        {spells.bloodthirst, 'player.hasBuff(spells.tasteForBlood)' },
        {spells.ragingBlow, 'player.hasBuff(spells.enrage)' },
        {spells.furiousSlash },
    }},

    -- Meat Cleaver -- Your next Bloodthirst or Rampage strikes up to 4 additional targets for 50% damage.
    {spells.whirlwind, 'not player.hasBuff(spells.meatCleaver) and focus.isAttackable and focus.distance < 10 and target.distance < 10' , "target" },
    {{"nested"}, 'kps.multiTarget', {
        {spells.whirlwind, 'not player.hasBuff(spells.meatCleaver) and target.distance < 10' , "target" },
        {spells.whirlwind, 'player.hasTalent(3,1) and player.hasBuff(spells.wreckingBall) and target.distance < 10' , "target" },
        {spells.odynsFury, 'player.hasBuff(spells.enrage)' , "target" },
        {spells.rampage, 'player.hasBuff(spells.meatCleaver) and player.hasTalent(5,2) and player.rage == 100' , "target" },
        {spells.rampage, 'player.hasBuff(spells.meatCleaver) and not player.hasTalent(5,2)' , "target" },
        {spells.bloodthirst, 'player.hasBuff(spells.meatCleaver)' },
        {spells.ragingBlow, 'player.hasBuff(spells.enrage)' },
        {spells.whirlwind, 'target.distance < 10' , "target" },
    }},

    {spells.ragingBlow, 'player.hasBuff(spells.enrage)' , "target", "ragingBlow_enrage" },
    {spells.bloodthirst, 'player.hasBuff(spells.tasteForBlood)' },
    {spells.ragingBlow, 'player.hasTalent(6,3)' },
    -- Buff Taste for Blood. Furious Slash increases the critical strike chance of Bloodthirst by 15%. Stacks up to 6 times 8 seconds remaining
    {spells.furiousSlash },
    
    --{{"macro"}, 'true' , "/startattack" },

}
,"Warrior Fury 7.3")
