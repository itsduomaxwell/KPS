--[[[
@module Mage Frost Rotation
@generated_from mage_frost.simc
@version 7.0.3
]]--
local spells = kps.spells.mage
local env = kps.env.mage

local Blizzard = spells.blizzard.name


kps.rotations.register("MAGE","FROST",
{

    {spells.iceBlock, 'player.hp < 0.20' },

    {{"macro"}, 'keys.shift', "/cast [@cursor] "..Blizzard },
    
    {spells.iceFloes, 'player.isMoving and not player.hasBuff(spells.iceFloes)' },

    {spells.iceBarrier, 'not player.hasBuff(spells.iceBarrier)' },
    {spells.runeOfPower, 'player.hasTalent(3,2)' },
    {spells.mirrorImage, 'player.hasTalent(3,1)' },
    --{spells.timeWarp, 'target.hp < 0.30 and player.timeInCombat > 0'},
    {spells.frozenOrb },
    {spells.icyVeins },

    {spells.ebonbolt, 'not player.hasBuff(spells.brainFreeze)' },
    {spells.flurry, 'player.hasBuff(spells.brainFreeze)' },
    {spells.iceLance, 'player.buffStacks(spells.fingersOfFrost) > 0', "target" , "fingersOfFrost" }, 

    {spells.glacialSpike, 'player.hasTalent(7,2)' },
    {spells.cometStorm, 'player.hasTalent(7,3)' },
    {spells.iceLance, 'player.hasBuff(spells.chainReaction)' , "target" , "chainReaction" },
    {spells.frostbolt },

}
,"mage_frost.simc")
