--[[[
@module Mage Frost Rotation
@generated_from mage_frost.simc
@version 7.0.3
]]--
local spells = kps.spells.mage
local env = kps.env.mage


kps.rotations.register("MAGE","FROST",
{

    {spells.timeWarp, 'target.hp < 0.30 or player.timeInCombat > 0'},
    {spells.icyVeins},
    {spells.iceLance, '( player.buffStacks(spells.fingersOfFrost) and ( player.buffDuration(spells.fingersOfFrost) < spells.frostbolt.castTime or player.buffDuration(spells.fingersOfFrost) < player.buffStacks(spells.fingersOfFrost) * player.gcd ) ) or spells.flurry.isRecastAt("target")'}, -- ice_lance,if=(buff.fingers_of_frost.react&(buff.fingers_of_frost.remains<action.frostbolt.execute_time|buff.fingers_of_frost.remains<buff.fingers_of_frost.react*gcd.max))|prev_gcd.flurry
    {spells.flurry, 'player.buffStacks(spells.brainFreeze) and ( player.buffDuration(spells.brainFreeze) < spells.frostbolt.castTime or ( player.buffStacks(spells.fingersOfFrost) == 0 and player.buffDuration(spells.waterJet) == 0 ) )'}, -- flurry,if=buff.brain_freeze.react&(buff.brain_freeze.remains<action.frostbolt.execute_time|(buff.fingers_of_frost.react=0&debuff.water_jet.remains=0))
    {spells.rayOfFrost, 'player.hasBuff(spells.runeOfPower) or not player.hasTalent(6, 2)'},
    {spells.iceNova},
    {spells.frozenTouch, 'player.buffStacks(spells.fingersOfFrost) == 0'},
    {spells.glacialSpike},
    {spells.cometStorm},
    {spells.iceLance, 'not player.hasTalent(5, 1) and player.buffStacks(spells.fingersOfFrost) and ( not player.hasTalent(7, 1) or spells.icyVeins.cooldown > 8 )'}, 
    {spells.frostbolt},

}
,"mage_frost.simc")
