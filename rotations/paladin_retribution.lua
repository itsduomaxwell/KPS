--[[[
@module Paladin Retribution Rotation
@author xvir.subzrk
@version 7.0.3
]]--

-- Talents:
-- Tier 1: Execution Sentence, Final Verdict
-- Tier 2: The Fires of Justice, Zeal
-- Tier 3: Blinding Light
-- Tier 4: Blade of Wrath
-- Tier 5: Justicar's Vengeance, Word of Glory (in more healing needed)
-- Tier 6: Divine Intervention, Divine Steed (whatever talent really, but c'mon Divine Steed is awesome!)
-- Tier 7: Divine Purpose, Crusade

local spells = kps.spells.paladin -- REMOVE LINE (or comment out) IF ADDING TO EXISTING ROTATION
local env = kps.env.paladin -- REMOVE LINE (or comment out) IF ADDING TO EXISTING ROTATION

kps.rotations.register("PALADIN","RETRIBUTION",
{

    {{"macro"}, 'not target.isAttackable and mouseover.isAttackable and mouseover.inCombat and mouseover.distance < 10' , "/target mouseover" },
    {{"macro"}, 'not target.exists and mouseover.isAttackable and mouseover.inCombat and mouseover.distance < 10' , "/target mouseover" },
    env.FocusMouseover,
    {{"macro"}, 'focus.exists and target.isUnit("focus")' , "/clearfocus" },
    {{"macro"}, 'focus.exists and not focus.isAttackable' , "/clearfocus" },

    -- Def CD's
    {{"nested"}, 'kps.defensive', {
        {spells.wordOfGlory, 'player.hasTalent(5,3) and player.hp < 0.80', 'player'},
        {spells.justicarsVengeance, 'player.hasTalent(5,1) and player.hp < 0.80 and player.hasBuff(spells.divinePurpose)' },
        {spells.shieldOfVengeance, 'player.hp < 0.80'},
        {spells.layOnHands, 'player.hp < 0.30', 'player'},
        {spells.divineShield, 'player.hp < 0.80', 'player'},
        --{spells.flashOfLight, 'player.hp < 0.55', 'player'},
    }},

     -- Cooldowns
    {spells.avengingWrath, 'not player.hasBuff(spells.avengingWrath) and target.hasMyDebuff(spells.judgment)'},
    {spells.wakeOfAshes, 'player.hasBuff(spells.avengingWrath) and player.holyPower < 1'}, -- Generates 5 Holy Power.

    -- Interrupt Target
    {{"nested"}, 'kps.interrupt and target.isInterruptable', {
        {spells.rebuke},
        {spells.hammerOfJustice, 'target.distance < 10'},
        {spells.blindingLight}, -- disorients all enemies within a 10 yard radius around you
    }},
    
    -- Multi Target Rotation
    {{"nested"}, 'player.plateCount > 3 or kps.multiTarget', {
        {spells.divineStorm, 'target.hasMyDebuff(spells.judgment)'},
        {spells.divineStorm, 'player.hasBuff(spells.divinePurpose)'},
        {spells.consecration},
        {spells.judgment},
        {spells.bladeOfWrath, 'player.holyPower < 4'},
        {spells.zeal, 'player.holyPower < 5'},
        {spells.crusaderStrike, 'player.holyPower < 5'},
    }},

    -- Single Target Rotation
    {spells.templarsVerdict, 'target.hasMyDebuff(spells.judgment)'}, -- need 3 holypower
    {spells.templarsVerdict, 'player.hasBuff(spells.divinePurpose)'},
    {spells.bladeOfJustice, 'player.holyPower < 5'}, -- Generates 2 Holy Power. 10 sec cd
    {spells.crusaderStrike, 'player.holyPower < 5'}, -- Generates 1 Holy Power.
    {spells.zeal, 'player.holyPower < 5'}, -- Generates 1 Holy Power.
    {spells.judgment},
    {spells.bladeOfWrath, 'player.holyPower < 4'}, -- Your auto attacks have a chance to reset the cooldown of Blade of Justice.


}
,"Icy Veins")


--kps.rotations.register("PALADIN","RETRIBUTION",
--{
--
--  {{"nested"}, 'target.isAttackable', {
--      {spells.zeal, 'target.distance <= 10'},
--      {spells.judgment, 'target.distance <= 30 and target.distance >= 10'},
--      {spells.templarsVerdict},
--      {spells.divineStorm},
--      {spells.bladeOfWrath},
--  }},
--}
--,"Spam Zeal")
