--[[[
@module Mage Frost Rotation
@generated_from mage_frost
@version 7.0.3
]]--
local spells = kps.spells.mage
local env = kps.env.mage

local Blizzard = spells.blizzard.name
local RingOfFrost  = spells.ringOfFrost.name


kps.rotations.register("MAGE","FROST",
{

    {spells.iceBlock, 'player.hp < 0.20' },
    {spells.iceBarrier, 'not player.hasBuff(spells.iceBarrier)' },
    {{"macro"}, 'keys.shift', "/cast [@cursor] "..Blizzard },

    --Opening
    --{{spells.ebonbolt,spells.runeOfPower,spells.icyVeins,spells.flurry,spells.iceLance,spells.frozenOrb}, 'player.timeInCombat < 4' , "target" },

    {spells.icyVeins, 'player.hasBuff(spells.fingersOfFrost)' },    
    {spells.iceLance, 'player.buffStacks(spells.fingersOfFrost) == 3' , "target" , "fingersOfFrost" },

    {spells.ebonbolt, 'not player.hasBuff(spells.brainFreeze)' },
    {spells.runeOfPower, 'player.hasTalent(3,2) and spells.frozenOrb.cooldown < kps.gcd' },
    {spells.mirrorImage, 'player.hasTalent(3,1)' },
    {spells.iceFloes, 'player.isMoving and not player.hasBuff(spells.iceFloes)' },
    {spells.frozenOrb },

    --{spells.rayOfFrost, 'player.hasTalent(1,1)' , "target" , "rayOfFrost" }, 
    --{spells.freeze, 'not player.hasTalent(7,2) and target.distance < 10' }, -- familier
    --{spells.waterJet, 'not player.hasTalent(7,2)' }, -- familier

    {spells.iceLance, 'player.buffStacks(spells.fingersOfFrost) > 0' , "target" , "fingersOfFrost" },
    {spells.iceLance, 'player.hasBuff(spells.chainReaction)' , "target" , "chainReaction" },
    {{spells.frostbolt,spells.flurry,spells.iceLance}, 'player.hasBuff(spells.brainFreeze)' },
    
    {{"nested"}, 'kps.multiTarget or player.plateCount > 3', {
        --{spells.frostBomb, 'player.hasTalent(6,1) and player.buffStacks(spells.fingersOfFrost) > 0' }, 
        {spells.cometStorm, 'player.hasTalent(7,3)' },
        {spells.iceNova, 'player.hasTalent(4,1)' },
        {spells.iceLance, 'player.hasBuff(spells.frostBomb)' },
        {spells.freeze, 'target.distance < 10' },
    }},

    {spells.glacialSpike, 'player.hasTalent(7,2)' },
    {spells.cometStorm, 'player.hasTalent(7,3)' },
    {spells.iceNova, 'player.hasTalent(4,1)' },
    {spells.frostbolt },

}
,"mage_frost")
