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

    {spells.blessedHammer }, -- cd 4 sec
    {spells.judgment },
    {spells.avengersShield },
    {spells.consecration }, -- cd 8sec
    {spells.eyeOfTyr, 'spells.shieldOfTheRighteous.cooldown > 0' },

    -- "Shield of the Righteous" -- causing (360% of Attack power) Holy damage, and reducing damage you take
    {spells.shieldOfTheRighteous }, -- cd 14 sec
    
    -- "Hand of Reckoning" -- taunt
    {spells.handOfReckoning, 'not player.isTarget' , "target" , "taunt" },
    {spells.seraphim},

    {spells.bulwarkOfOrder },
    -- "Guardian of Ancient Kings" -- Damage taken reduced by 50% 8 seconds remaining
    {spells.guardianOfAncientKings, 'not player.hasBuff(spells.holyAvenger) and not player.hasBuff(spells.shieldOfTheRighteous) and not player.hasBuff(spells.divineProtection)'},    
    -- "Divine Shield" -- Protects you from all damage and spells for 8 sec. 
    {spells.divineShield, 'player.hp < 0.30' },
    -- "Ardent Defender" -- Damage taken reduced by 20%. The next attack that would otherwise kill you will instead bring you to 12% of your maximum health.
    {spells.ardentDefender, 'player.incomingDamage > player.incomingHeal and player.hp < 0.30' },
    {spells.ardentDefender, 'not player.hasBuff(spells.guardianOfAncientKings) not player.hasBuff(spells.shieldOfTheRighteous) and not player.hasBuff(spells.divineProtection)'},
    -- "Avenging Wrath" -- Increases all damage done by 35% and all healing done by 35% for 20 sec.
    {spells.avengingWrath, 'player.incomingDamage > player.incomingHeal' },

    {spells.lightOfTheProtector, 'player.hp < 0.82' },
    {spells.layOnHands, 'player.hp < 0.40' },
    {spells.handOfTheProtector },


 
 }
,"paladin_protection.simc")
