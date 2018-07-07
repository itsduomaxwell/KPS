--[[[
@module Mage Fire Rotation
@author SwollNMember. Original, fourdots
@version 7.3.5
]]--
local spells = kps.spells.mage
local env = kps.env.mage

local Meteor = spells.meteor.name

kps.rotations.register("MAGE","FIRE",
{

    {{"macro"}, 'keys.shift', "/cast [@cursor] "..Meteor },
    {{"macro"}, 'target.distance <=5', "/cast [@cursor] "..Meteor },
    --{spells.shimmer, 'target.distance > 20 and target.distance < 40'},
   -- interrupts
    {{"nested"}, 'kps.interrupt',{
        {spells.counterspell, 'target.isInterruptable' , "target" },
        {spells.counterspell, 'focus.isInterruptable' , "focus" },
    }},
   
    {{"nested"}, 'kps.defensive', {
       {spells.invisibility, 'target.isRaidBoss and player.isTarget'},
       {spells.blazingBarrier, 'player.isTarget'},
       {spells.frostNova, 'target.distance < 15 and not target.isRaidBoss and not target.isElite and not target.hasDebuff(spells.dragonsBreath)'},
       {{"macro"}, 'player.useItem(5512) and player.hp < 0.70', "/use item:5512" },
       {spells.iceBlock, 'player.hp < 0.15 or player.hpIncoming < 0.25'},
     }},
   
    {spells.flamestrike, 'keys.shift and player.hasBuff(spells.hotStreak)'},
    {{"macro"}, 'target.distance <=5 and player.hasBuff(spells.hotStreak)', "/cast [@player] Flamestrike"},
   
    {spells.runeOfPower, 'kps.cooldowns and not player.isMoving and spells.combustion.cooldown < 1.5 and player.hasBuff(spells.hotStreak)'},
   
    {{"nested"}, 'kps.cooldowns and not player.isMoving and spells.combustion.cooldown < 1.5 and spells.runeOfPower.lastCasted(2)', {
        {{"macro"}, 'kps.useBagItem', "/use 13" },
        {{"macro"}, 'kps.useBagItem', "/use 14" },
        {spells.combustion},
    }},

    {spells.runeOfPower, 'spells.runeOfPower.charges >= 2 and not player.hasBuff(spells.combustion) and not player.isMoving'},
    {spells.blazingBarrier},
    {spells.pyroblast, 'player.hasBuff(spells.hotStreak)'},

    {spells.flameOn, 'spells.fireBlast.charges < 1'},
    {spells.blastWave, 'not player.hasBuff(spells.combustion)  and target.distanceMax < 6'},
    {spells.blastWave, 'player.hasBuff(spells.combustion) and spells.fireBlast.charges < 1 and target.distanceMax < 6'},
    {spells.cinderstorm, 'not player.hasBuff(spells.combustion)'},
    {spells.fireBlast, 'not spells.fireBlast.isRecastAt("target")'},
    {spells.dragonsBreath, 'target.distanceMax < 10 and not target.hasDebuff(spells.frostNova)'},
    {spells.fireBlast, 'player.hasBuff(spells.heatingUp)'},

    {{"nested"}, 'player.isMoving and spells.iceFloes.charges < 1', {
        {spells.iceBarrier, 'player.hp < 1'},
        {spells.scorch},
    }},

    {spells.phoenixsFlames},
    {spells.fireball},

}
,"Fire Mage 7.3.2")