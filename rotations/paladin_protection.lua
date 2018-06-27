--[[[
@module Paladin Protection Rotation
@generated_from paladin_protection.simc
@version 7.2
]]--
local spells = kps.spells.paladin
local env = kps.env.paladin


kps.rotations.register("PALADIN","PROTECTION",
{

    {{"macro"}, 'not target.isAttackable and mouseover.isAttackable and mouseover.inCombat and mouseover.distance < 10' , "/target mouseover" },
    {{"macro"}, 'not target.exists and mouseover.isAttackable and mouseover.inCombat and mouseover.distance < 10' , "/target mouseover" },
    env.FocusMouseover,
    {{"macro"}, 'focus.exists and target.isUnit("focus")' , "/clearfocus" },
    {{"macro"}, 'focus.exists and not focus.isAttackable' , "/clearfocus" },

    {spells.judgment },
    {spells.avengersShield },
    {spells.avengersShield, 'player.buffStacks(spells.grandCrusader)'}, -- cd 13,4 sec
    {spells.consecration, 'not player.hasBuff(spells.consecration)' }, -- cd 8sec
    {spells.blessedHammer }, -- cd 4 sec
    {spells.bulwarkOfOrder },
    
    {spells.shieldOfTheRighteous }, -- cd 14 sec
    {spells.lightOfTheProtector, 'player.hp < 0.60' },
    {spells.layOnHands, 'player.hp < 0.30' },
    {spells.divineShield, 'player.hp < 0.30' },

    
    -- cooldown
    {spells.guardianOfAncientKings, 'not player.hasBuff(spells.holyAvenger) and not player.hasBuff(spells.shieldOfTheRighteous) and not player.hasBuff(spells.divineProtection)'},
    {spells.ardentDefender, 'not player.hasBuff(spells.guardianOfAncientKings) not player.hasBuff(spells.shieldOfTheRighteous) and not player.hasBuff(spells.divineProtection)'},
    {spells.eyeOfTyr, 'spells.shieldOfTheRighteous.cooldown > 0' },

    {spells.holyWrath},
    {spells.holyAvenger},
    {spells.seraphim},
    {spells.divineProtection, 'player.timeInCombat < 5 or not player.hasTalent(7, 2) or ( not player.hasBuff(spells.seraphim) and spells.seraphim.cooldown > 5 and spells.seraphim.cooldown < 9 )'},
    {spells.shieldOfTheRighteous, 'player.buffStacks(spells.divinePurpose)'},
    {spells.shieldOfTheRighteous, '( player.holyPower >= 5 or player.incomingDamage >= player.hpMax * 0.3 ) and ( not player.hasTalent(7, 2) or spells.seraphim.cooldown > 5 )'},
    {spells.shieldOfTheRighteous, 'player.buffDuration(spells.holyAvenger) > player.timeToNextHolyPower and ( not player.hasTalent(7, 2) or spells.seraphim.cooldown > player.timeToNextHolyPower )'},
    {spells.crusaderStrike},
    {spells.holyWrath, 'player.hasTalent(5, 2)'},
    {spells.lightsHammer, 'not player.hasTalent(7, 2) or player.buffDuration(spells.seraphim) > 10 or spells.seraphim.cooldown < 6'},
    {spells.holyPrism, 'not player.hasTalent(7, 2) or player.hasBuff(spells.seraphim) or spells.seraphim.cooldown > 5 or player.timeInCombat < 5'},
    {spells.executionSentence, 'not player.hasTalent(7, 2) or player.hasBuff(spells.seraphim) or player.timeInCombat < 12'},
 
 }
,"paladin_protection.simc")
