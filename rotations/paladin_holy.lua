--[[[
@module Paladin Holy Rotation
@author kirk24788
@version 7.0.3
@untested
]]--
local spells = kps.spells.paladin
local env = kps.env.paladin


kps.rotations.register("PALADIN","HOLY",
{

    {spells.divineShield, 'player.hp < 0.30' , "player" },
    {spells.divineProtection, 'player.hp < 0.55 and player.incomingDamage > player.incomingHeal' , "player" },
    {spells.blessingOfProtection, 'heal.lowestInRaid.hp < 0.55 and not heal.lowestInRaid.isUnit(heal.lowestTankInRaid.unit)' , kps.heal.lowestInRaid },
    
    -- Interrupt
    {{"nested"}, 'kps.interrupt' ,{
        {spells.repentance, 'target.isCasting and target.distance < 30' , "target" },
    }},


    -- "Règne de la loi" -- Vous augmentez de 50% la portée de vos soins
    {spells.ruleOfLaw, 'heal.countLossInDistance(0.78,15) > 2' },

    --{spells.beaconOfLight, 'not player.hasBuff(spells.beaconOfLight)' , "player" },
    {spells.beaconOfLight, 'not heal.offTankInRaid.hasBuff(spells.beaconOfLight)' , kps.heal.offTankInRaid },

    -- Damage
    {spells.judgment, 'target.isAttackable' , "target" },
    {spells.consecration },
    {spells.holyShock, 'heal.lowestInRaid.hp < 0.85' , kps.heal.lowestInRaid },
    {spells.holyShock, 'heal.lowestInRaid.hp > 0.85 and target.isAttackable' , "target" },
    {spells.crusaderStrike, 'target.isAttackable' , "target" },
    
    {spells.lightOfTheMartyr , 'spells.holyShock.cooldown > 0 and heal.lowestTankInRaid.hp < 0.40 and player.hp > 0.80' , kps.heal.lowestTankInRaid },
    
    {spells.lightOfDawn, 'heal.countLossInDistance(0.78,15) > 2 and heal.lowestTankInRaid < 0.78' , kps.heal.lowestTankInRaid },
    {spells.holyPrism, 'heal.countLossInDistance(0.78,15) > 2 and heal.lowestTankInRaid < 0.78' , kps.heal.lowestTankInRaid },
        
    {spells.bestowFaith, 'not heal.lowestTankInRaid.hasBuff(spells.bestowFaith)' , kps.heal.lowestTankInRaid },
    {{spells.tyrsDeliverance,spells.flashOfLight}, 'heal.lowestInRaid.hp < 0.55' , kps.heal.lowestInRaid },
    
    
    -- "Imprégnation de lumière" -- "infusionOfLight" -- Réduit le temps d’incantation de votre prochain sort Lumière sacrée de 1.5 s ou augmente les soins prodigués par le prochain Éclair lumineux de 50%.
    {spells.flashOfLight, 'heal.lowestInRaid.hp < 0.55' , kps.heal.lowestInRaid },
    {spells.flashOfLight, 'player.hasBuff(spells.infusionOfLight) and heal.lowestInRaid.hp < 0.55' , kps.heal.lowestInRaid },
    {spells.holyLight, 'heal.lowestInRaid.hp < 0.85' , kps.heal.lowestInRaid },
    {spells.holyLight, 'player.hasBuff(spells.infusionOfLight) and heal.lowestInRaid.hp > 0.55 and heal.lowestInRaid.hp < 0.85' , kps.heal.lowestInRaid },
    
    
    -- Cooldown
    {spells.avengingWrath, 'heal.countLossInRange(0.78) > 2' },
    {spells.layOnHands, 'heal.lowestTankInRaid.hp < 0.30' , kps.heal.lowestTankInRaid},


}
,"Holy Paladin Basic")
