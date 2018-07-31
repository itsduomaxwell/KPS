--[[[
@module Mage Frost Rotation
@generated_from mage_frost
@version 7.3.5
]]--
local spells = kps.spells.mage
local env = kps.env.mage

local Blizzard = spells.blizzard.name
local RingOfFrost  = spells.ringOfFrost.name

--kps.runAtEnd(function()
--   kps.gui.addCustomToggle("MAGE","FROST", "pauseRotation", "Interface\\Icons\\Spell_frost_frost", "pauseRotation")
--end)


kps.rotations.register("MAGE","FROST",
{

    --{{"pause"}, 'kps.pauseRotation', 4},
    
    --{{"macro"}, 'not target.isAttackable and mouseover.isAttackable and mouseover.inCombat' , "/target mouseover" },
    --{{"macro"}, 'not target.exists and mouseover.isAttackable and mouseover.inCombat' , "/target mouseover" },

    {spells.iceBlock, 'player.hp < 0.20' },
    {spells.iceBarrier, 'not player.hasBuff(spells.iceBarrier)' },
    {{"macro"}, 'keys.shift', "/cast [@cursor] "..Blizzard },

    --Opening
    --{{spells.ebonbolt,spells.runeOfPower,spells.icyVeins,spells.flurry,spells.iceLance,spells.frozenOrb}, 'player.timeInCombat < 4' , "target" },
    {spells.frostNova, 'target.distanceMax < 10' , "target" },
    {spells.spellsteal, 'target.isStealable' , "target" },
   -- interrupts
    {{"nested"}, 'kps.interrupt',{
        {spells.counterspell, 'target.isInterruptable' , "target" },
        {spells.counterspell, 'focus.isInterruptable' , "focus" },
    }},

    {spells.iceLance, 'player.hasBuff(spells.fingersOfFrost)' , "target" , "fingersOfFrost" },
    {spells.iceFloes, 'player.isMoving and not player.hasBuff(spells.iceFloes)' },
    {{spells.frostbolt,spells.flurry,spells.iceLance}, 'player.hasBuff(spells.brainFreeze)' },
    {spells.icyVeins, 'spells.ebonbolt.cooldown < 20' },    
    {spells.ebonbolt },
    {spells.frozenOrb },

    {spells.runeOfPower, 'player.hasTalent(3,2) and spells.frozenOrb.cooldown < kps.gcd' },
    {spells.mirrorImage, 'player.hasTalent(3,1)' },

    --{spells.rayOfFrost, 'player.hasTalent(1,1)' , "target" , "rayOfFrost" }, 
    --{spells.freeze, 'not player.hasTalent(7,2) and target.distance < 10' }, -- familier
    --{spells.waterJet, 'not player.hasTalent(7,2)' }, -- familier

    {{"nested"}, 'kps.multiTarget or player.plateCount > 3', {
        {spells.iceLance, 'target.hasDebuff(spells.frostBomb)' },
        {spells.frostBomb, 'player.hasTalent(6,1) and player.hasBuff(spells.fingersOfFrost)' }, 
        {spells.cometStorm, 'player.hasTalent(7,3)' },
        {spells.iceNova, 'player.hasTalent(4,1)' },
    }},

    {spells.glacialSpike, 'player.hasTalent(7,2)' },
    {spells.cometStorm, 'player.hasTalent(7,3)' },
    {spells.iceNova, 'player.hasTalent(4,1)' },
    {spells.frostbolt },

}
,"mage_frost_basic")
