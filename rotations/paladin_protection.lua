--[[[
@module Paladin Protection Rotation
@generated_from paladin_protection.simc
@version 7.2
]]--
local spells = kps.spells.paladin
local env = kps.env.paladin

kps.runAtEnd(function()
   kps.gui.addCustomToggle("PALADIN","PROTECTION", "taunt", "Interface\\Icons\\spell_nature_reincarnation", "taunt")
end)


kps.rotations.register("PALADIN","PROTECTION",
{

    {{"macro"}, 'not target.isAttackable and mouseover.isAttackable and mouseover.inCombat and mouseover.distance < 10' , "/target mouseover" },
    {{"macro"}, 'not target.exists and mouseover.isAttackable and mouseover.inCombat and mouseover.distance < 10' , "/target mouseover" },
    env.FocusMouseover,
    {{"macro"}, 'focus.exists and target.isUnit("focus")' , "/clearfocus" },
    {{"macro"}, 'focus.exists and not focus.isAttackable' , "/clearfocus" },
    
    {spells.everyManForHimself , 'player.isControlled' },
    {spells.cleanseToxins, 'player.isDispellable("Disease")' , "player" },
    {spells.cleanseToxins, 'player.isDispellable("Poison")' , "player" },
    
    -- "Pierre de soins" 5512
    {{"macro"}, 'player.useItem(5512) and player.hp < 0.70', "/use item:5512" },
    
        -- Interrupts
    {{"nested"}, 'kps.interrupt',{
        {spells.rebuke, 'target.isInterruptable' , "target" },
        {spells.rebuke, 'focus.isInterruptable' , "focus" },
    }},
    {spells.hammerOfJustice, 'target.isCasting' , "target" },
    {spells.blindingLight, 'target.distance < 10 and player.plateCount > 2' , "target" },

    -- "Hand of Reckoning" -- taunt
    {spells.handOfReckoning, 'kps.taunt and not player.isTarget' , "target" , "taunt" },

    -- "Main du protecteur" hasTalent(5,1) replace "Lumière du protecteur" -- rendre à une cible alliée 30% de ses points de vie manquants.
    {spells.handOfTheProtector, 'player. hasTalent(5,1) and player.hp < 0.80' },
    {spells.lightOfTheProtector, 'not player. hasTalent(5,1) and player.hp < 0.80' },
    -- "Lay on Hands" -- Heals a friendly target for an amount equal to your maximum health
    {spells.layOnHands, 'player.hp < 0.30 and spells.ardentDefender.cooldown > 0 and spells.handOfTheProtector.cooldown > 0' },
    {spells.layOnHands, 'player.hp < 0.30 and spells.ardentDefender.cooldown > 0 and spells.lightOfTheProtector.cooldown > 0' },
    -- "Divine Shield" -- Protects you from all damage and spells for 8 sec. 
    {spells.divineShield, 'player.hp < 0.30' },
    -- "Blessing of Protection" -- Places a blessing on a party or raid member, protecting them from all physical attacks for 10 sec.
    {spells.blessingOfProtection, 'mouseover.hp < 0.40 and mouseover.isFriend' , "mouseover"},

    -- "Avenging Wrath" -- "Courroux vengeur" -- Increases all damage done by 35% and all healing done by 35% for 20 sec.
    {spells.avengingWrath, 'player.incomingDamage > player.incomingHeal and spells.handOfTheProtector.cooldown < kps.gcd' },
    {spells.avengingWrath, 'player.incomingDamage > player.incomingHeal and spells.lightOfTheProtector.cooldown < kps.gcd' },

    {spells.judgment, 'not target.hasMyDebuff(spells.judgment)' },
    --{spells.judgment, 'not damage.enemyTarget.hasMyDebuff(spells.judgment)' , kps.damage.enemyTarget },
    {spells.consecration, 'not player.isMoving and not player.hasBuff(spells.consecration) and target.distance < 10' }, -- cd 8sec
    -- "Avengers Shield" -- "Bouclier du gives buff "Bulwark Of Order" "Rempart de l’ordre" absorbing 20% of Avenger's Shield damage.
    {spells.avengersShield },
    -- "Bouclier du vertueux" -- "Shield of the Righteous" -- degats reduits de 40%
    {spells.shieldOfTheRighteous, 'player.hasBuff(spells.blessedStalwart) and player.incomingDamage > player.incomingHeal' },
    -- "Jugement" vous confère "Pilier béni" "Blessed Stalwart", Caractéristique d'arme prodigieuse qui augmente de 8% les dégâts et la réduction de dégâts de votre prochain Bouclier du vertueux.
    {spells.judgment, 'not player.hasBuff(spells.blessedStalwart)' },
    {spells.blessedHammer, 'target.myDebuffDuration(spells.blessedHammer) < 2' }, -- cd 4 sec
    --{spells.seraphim},


   {{"nested"}, 'not player.hasBuff(spells.shieldOfTheRighteous) and player.incomingDamage > player.incomingHeal', {
       {spells.eyeOfTyr },
       -- "Guardian of Ancient Kings" -- 5 min cd Damage taken reduced by 50% 8 seconds remaining
       {spells.guardianOfAncientKings, 'player.hp < 0.55 and spells.ardentDefender.cooldown > 0' },
       -- "Ardent Defender" -- 1,33 min cd Damage taken reduced by 20%. The next attack that would otherwise kill you will instead bring you to 12% of your maximum health.
       {spells.ardentDefender, 'player.hp < 0.80' },
   }},
    {{"macro"}, 'true' , "/startattack" },
 

 }
,"paladin_protection.simc")
