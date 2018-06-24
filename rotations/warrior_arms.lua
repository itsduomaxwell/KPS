--[[[
@module Warrior Arms Rotation
@author xvir.subzrk
@version 7.0.3
]]--
local spells = kps.spells.warrior
local env = kps.env.warrior

local HeroicLeap = spells.heroicLeap.name

kps.runAtEnd(function()
   kps.gui.addCustomToggle("WARRIOR","ARMS", "berserker", "Interface\\Icons\\spell_nature_ancestralguardian", "berserker")
end)

kps.rotations.register("WARRIOR","ARMS",
{

    {{"macro"}, 'not target.isAttackable and mouseover.isAttackable and mouseover.inCombat and mouseover.distance < 10' , "/target mouseover" },
    {{"macro"}, 'not target.exists and mouseover.isAttackable and mouseover.inCombat and mouseover.distance < 10' , "/target mouseover" },
    env.FocusMouseover,
    {{"macro"}, 'focus.exists and target.isUnit("focus")' , "/clearfocus" },
    {{"macro"}, 'focus.exists and not focus.isAttackable' , "/clearfocus" },
    env.ScreenMessage,

    -- interrupts
    {spells.pummel, 'kps.interrupt and target.distance < 10 and target.isInterruptable and target.castTimeLeft < 1' , "target" },
    {spells.pummel, 'kps.interrupt and focus.distance < 10 and focus.isInterruptable and focus.castTimeLeft < 1' , "focus" },

    -- Charge enemy
    {{"macro"}, 'keys.shift and not player.hasBuff(spells.battleCry)', "/cast [@cursor] "..HeroicLeap },
    {spells.heroicThrow, 'kps.defensive and target.isAttackable and target.distance > 10' },
    {spells.charge, 'kps.defensive and target.isAttackable and target.distance > 10' },

    -- "Pierre de soins" 5512
    {{"macro"}, 'player.useItem(5512) and player.hp < 0.70', "/use item:5512" },
    {spells.stoneform, 'player.isDispellable("Disease")' , "player" },
    {spells.stoneform, 'player.incomingDamage > player.hpMax * 0.10' },
    {spells.victoryRush, 'player.hp < 0.70' },
    {spells.commandingShout, 'player.hp < 0.60' },
    {spells.dieByTheSword, 'player.hp < 0.40'},

    {spells.intimidatingShout, 'not player.isInRaid and player.plateCount > 3' },
    {spells.intimidatingShout, 'not player.isInRaid and player.incomingDamage > player.hpMax * 0.10' },

    
    -- TRINKETS
    -- "Souhait ardent de Kil'jaeden" 144259
    {{"macro"}, 'player.timeInCombat > 30 and player.useTrinket(0)' , "/use 13" },
    {{"macro"}, 'player.timeInCombat > 30 and player.useTrinket(1)' , "/use 14" },
    
    {{"nested"}, 'player.hasBuff(spells.battleCry)', {
        {spells.mortalStrike, 'player.hasBuff(spells.shatteredDefenses)'},
        {spells.colossusSmash, 'not player.hasBuff(spells.shatteredDefenses)'},
        {spells.colossusSmash, 'not target.hasMyDebuff(spells.colossusSmash)'},
        {spells.cleave, 'kps.multiTarget'},
        {spells.whirlwind, 'kps.multiTarget'},
    }},
    {{"nested"}, 'spells.battleCry.cooldown < kps.gcd', {
        {spells.avatar, 'not player.isMoving and target.isAttackable and target.distance < 10' }, -- 90 sec cd
        {spells.warbreaker, 'not player.isMoving and target.isAttackable and target.distance < 10'},
    }},
    {{"nested"}, 'kps.cooldowns', {
        {spells.battleCry, 'target.myDebuffDuration(spells.colossusSmash) > 5 and player.myBuffDuration(spells.shatteredDefenses) > 5'},
    }},
    
    -- MultiTarget -- talent Sweeping Strikes is highly recommended. Mortal Strike and Execute hit 2 additional nearby targets.
    {{"nested"}, 'kps.multiTarget', {
        {spells.warbreaker},
        {spells.bladestorm},
        {spells.ravager},
        {spells.mortalStrike},
        {spells.colossusSmash, 'not player.hasBuff(spells.shatteredDefenses)'},
        {spells.cleave},
        {spells.whirlwind},
    }},

    -- Single Target
    {{"nested"}, 'target.hp < 0.20', {
        {spells.colossusSmash, 'not player.hasBuff(spells.shatteredDefenses)'},
        -- "Executioner's Precision" -- Execute causes the target to take 75% more damage from your next Mortal Strike, stacking up to 2 times
        {spells.mortalStrike, 'player.hasBuff(spells.shatteredDefenses) and player.buffStacks(spells.executionersPrecision) == 2'},
        -- "Weighted Blade" -- T21 Arms 4P Bonus -- Mortal Strike increases the damage and critical strike chance of your next Whirlwind or Slam by 12%, stacking up to 3 times
        {spells.whirlwind, 'target.hasMyDebuff(spells.colossusSmash) and player.buffStacks(weightedBlade) == 3'},
        {spells.execute},
    }},

    -- After using Colossus Smash, your next Mortal Strike or Execute gains 50% increased critical strike chance
    {spells.mortalStrike, 'player.hasBuff(spells.shatteredDefenses)'},
    {spells.colossusSmash, 'not player.hasBuff(spells.shatteredDefenses)'},
    {spells.colossusSmash, 'not target.hasMyDebuff(spells.colossusSmash)'},
    -- "Fervor of Battle" is talent -- replaces Slam Icon Slam at all times
    {spells.whirlwind, 'player.hasTalent(5,1)'},
    {spells.slam, 'not player.hasTalent(5,1)'},

}
,"Icy Veins")
