--[[[
@module Priest Holy Rotation
@author htordeux
@version 7.2
]]--

-- kps.cooldowns for dispel
-- kps.interrupt for guardianSpirit
-- kps.defensive for overhealing
-- kps.multiTarget for damage


local spells = kps.spells.priest
local env = kps.env.priest

local HolyWordSanctify = spells.holyWordSanctify.name
local SpiritOfRedemption = spells.spiritOfRedemption.name
local MassDispel = spells.massDispel.name
local AngelicFeather = spells.angelicFeather.name

kps.runAtEnd(function()
   kps.gui.addCustomToggle("PRIEST","HOLY", "mouseOver", "Interface\\Icons\\priest_spell_leapoffaith_a", "mouseOver")
end)


kps.rotations.register("PRIEST","HOLY",{

    {{"macro"}, 'not target.exists and mouseover.inCombat and mouseover.isAttackable' , "/target mouseover" },

    env.ScreenMessage,
    --env.ShouldInterruptCasting,
    {{"macro"}, 'spells.heal.shouldInterrupt(0.98)' , "/stopcasting" },
    {{"macro"}, 'spells.flashHeal.shouldInterrupt(0.82)' , "/stopcasting" },
    {{"macro"}, 'spells.prayerOfHealing.shouldInterrupt(heal.countLossInRange(0.82))' , "/stopcasting" },

    {{"macro"}, 'player.hasBuff(spells.spiritOfRedemption) and heal.lowestInRaid.isUnit("player")' , "/cancelaura "..SpiritOfRedemption },
    {{"nested"}, 'player.hasBuff(spells.spiritOfRedemption) and not heal.lowestInRaid.isUnit("player")' ,{
        {spells.holyWordSerenity, 'true' , kps.heal.lowestInRaid},
        {spells.prayerOfMending, 'true' , kps.heal.lowestInRaid},
        {spells.prayerOfHealing, 'kps.lastCast["name"] == spells.flashHeal' , kps.heal.lowestInRaid},
        {spells.flashHeal, 'heal.lowestInRaid.hp < 0.90' , kps.heal.lowestInRaid},
        {spells.renew, 'heal.lowestInRaid.myBuffDuration(spells.renew) < 3' , kps.heal.lowestInRaid},
    }},

    -- "Holy Word: Sanctify" and "Holy Word: Serenity" gives buff  "Divinity" 197030 When you heal with a Holy Word spell, your healing is increased by 15% for 8 sec.
    {{"macro"}, 'keys.shift', "/cast [@cursor] "..HolyWordSanctify },
    -- "Dissipation de masse" 32375
    {{"macro"}, 'keys.ctrl', "/cast [@cursor] "..MassDispel },
    -- "Divine Hymn" 64843
    {{"nested"}, 'keys.alt and not player.isMoving' ,{
        {{"macro"}, 'player.hasTrinket(1) == 144258 and player.useTrinket(1)' , "/use 14" },
        {{spells.prayerOfMending,spells.divineHymn}, 'spells.prayerOfMending.cooldown == 0' ,  kps.heal.lowestTankInRaid },
        {spells.divineHymn, 'heal.hasBuffStacks(spells.prayerOfMending) > 5' ,  kps.heal.lowestTankInRaid }, 
    }},

    -- "Fade" 586 "Disparition"
    {spells.fade, 'player.isTarget' },
    -- "Pierre de soins" 5512
    {{"macro"}, 'player.useItem(5512) and player.hp < 0.72' ,"/use item:5512" },
    -- "Prière du désespoir" 19236 "Desperate Prayer"
    {spells.desperatePrayer, 'player.hp < 0.72' , "player" },
    -- "Don des naaru" 59544
    {spells.giftOfTheNaaru, 'player.hp < 0.72' , "player" },
    -- "Angelic Feather"
    {{"macro"},'player.hasTalent(2,1) and player.isMovingFor(1.2) and spells.angelicFeather.cooldown == 0 and not player.hasBuff(spells.angelicFeather)' , "/cast [@player] "..AngelicFeather },
    -- "Body and Mind"
    {spells.bodyAndMind, 'player.hasTalent(2,2) and player.isMovingFor(1.2) and not player.hasBuff(spells.bodyAndMind)' , "player"},
    -- "Apotheosis" 200183 increasing the effects of Serendipity by 200% and reducing the cost of your Holy Words by 100% -- "Benediction" for raid and "Apotheosis" for party
    {spells.apotheosis, 'player.hasTalent(7,1) and heal.countLossInRange(0.78) * 2 > heal.countInRange' },
    -- "Leap Of Faith"
    --{spells.leapOfFaith, 'not heal.lowestInRaid.isUnit("player") and heal.lowestInRaid.hp < 0.20 and heal.lowestInRaid.isDamagerInRaid' , kps.heal.lowestInRaid },

    -- "Holy Word: Serenity"
    {spells.holyWordSerenity, 'mouseover.isFriend and mouseover.hp < 0.40 and mouseover.absorptionHeal' , "mouseover" },
    {spells.holyWordSerenity, 'mouseover.isFriend and mouseover.hp < 0.40 and not mouseover.immuneHeal' , "mouseover" },
    {spells.holyWordSerenity, 'player.hp < 0.40' , "player"},
    {spells.holyWordSerenity, 'heal.defaultTank.hp < 0.40' , kps.heal.defaultTank},
    {spells.holyWordSerenity, 'heal.lowestTankInRaid.hp < 0.40' , kps.heal.lowestTankInRaid},
    {spells.holyWordSerenity, 'heal.aggroTankTarget.hp < 0.40' , kps.heal.aggroTankTarget},
    {spells.holyWordSerenity, 'heal.lowestInRaid.hp < 0.40' , kps.heal.lowestInRaid},

    -- "Surge Of Light"
    {{"nested"}, 'player.hasBuff(spells.surgeOfLight)' , {
        {spells.flashHeal, 'player.buffStacks(spells.surgeOfLight) == 2' , kps.heal.lowestInRaid},
        {spells.flashHeal, 'player.hp < 0.78' , "player"},
        {spells.flashHeal, 'heal.lowestTankInRaid.hp < 0.78' , kps.heal.lowestTankInRaid},
        {spells.flashHeal, 'heal.aggroTankTarget.hp < 0.78' , kps.heal.aggroTankTarget},
        {spells.flashHeal, 'heal.lowestInRaid.hp < 0.78' , kps.heal.lowestInRaid},
        {spells.flashHeal, 'player.myBuffDuration(spells.surgeOfLight) < 4' , kps.heal.lowestInRaid},
    }},
    
    -- "Guardian Spirit" 47788
    {{"nested"}, 'kps.interrupt' ,{
        {spells.guardianSpirit, 'mouseover.isFriend and mouseover.hp < 0.30 and mouseover.immuneHeal' , "mouseover" },
        {spells.guardianSpirit, 'player.hp < 0.40 and not heal.lowestInRaid.isUnit("player")' , kps.heal.lowestInRaid},
        {spells.guardianSpirit, 'player.hp < 0.40 and not heal.lowestTankInRaid.isUnit("player")' , kps.heal.lowestTankInRaid},
        {spells.guardianSpirit, 'heal.defaultTank.hp < 0.30' , kps.heal.defaultTank},
        {spells.guardianSpirit, 'heal.lowestTankInRaid.hp < 0.30' , kps.heal.lowestTankInRaid},
        {spells.guardianSpirit, 'heal.aggroTankTarget.hp < 0.30' , kps.heal.aggroTankTarget},
        {spells.guardianSpirit, 'heal.lowestInRaid.hp < 0.30' , kps.heal.lowestInRaid},
    }},

    -- "Dispel" "Purifier" 527
    {{"nested"},'kps.cooldowns', {
        {spells.purify, 'mouseover.isFriend and mouseover.isDispellable("Magic")' , "mouseover" },
        {spells.purify, 'player.isDispellable("Magic")' , "player" },
        {spells.purify, 'heal.lowestTankInRaid.isDispellable("Magic")' , kps.heal.lowestTankInRaid},
        {spells.purify, 'heal.aggroTankTarget.isDispellable("Magic")' , kps.heal.aggroTankTarget},
        {spells.purify, 'heal.lowestInRaid.isDispellable("Magic")' , kps.heal.lowestInRaid},
        {spells.purify, 'heal.isMagicDispellable ~= nil' , kps.heal.isMagicDispellable },
    }},
    -- "Dissipation de la magie" -- Dissipe la magie sur la cible ennemie, supprimant ainsi 1 effet magique bénéfique.
    -- {spells.dispelMagic, 'target.isAttackable' , "target" },
    -- {spells.dispelMagic, 'focustarget.isAttackable' , "focustarget" },
    
    -- DAMAGE
    {{"nested"}, 'kps.multiTarget' , {
        {spells.prayerOfMending, 'not player.isMoving' , kps.heal.hasNotBuffMending },
        {spells.holyWordChastise, 'target.isAttackable' , "target" },
        {spells.holyWordChastise, 'targettarget.isAttackable', "targettarget" },
        {spells.holyWordChastise, 'focustarget.isAttackable', "focustarget" },
        {spells.holyFire, 'target.isAttackable' , "target" },
        {spells.holyFire, 'targettarget.isAttackable', "targettarget" },
        {spells.holyFire, 'focustarget.isAttackable', "focustarget" },
        {spells.holyNova, 'target.distance < 10 and target.isAttackable' , "target" },
        {spells.smite, 'not player.isMoving and target.isAttackable', "target" },
        {spells.smite, 'not player.isMoving and targettarget.isAttackable', "targettarget" },
        {spells.smite, 'not player.isMoving and focustarget.isAttackable', "focustarget" },
    }},

    -- kps.lastCast["name"] ne fonctionne pas si lastCast etait une macro 'kps.lastCast["name"] == spells.prayerOfMending' or 'spells.prayerOfMending.lastCasted(4)'
    {spells.flashHeal, 'not player.isMoving and spells.prayerOfMending.lastCasted(2) and heal.lowestInRaid.hp < 0.55' , kps.heal.lowestInRaid ,"FLASH_LOWEST_POM" },
    -- "Prayer of Mending" (Tank only)
    {spells.prayerOfMending, 'not player.isMoving and not heal.lowestTankInRaid.hasBuff(spells.prayerOfMending)' , kps.heal.lowestTankInRaid },
    {spells.prayerOfMending, 'not player.isMoving and not heal.aggroTankTarget.hasBuff(spells.prayerOfMending)' , kps.heal.aggroTankTarget },
    {spells.prayerOfMending, 'not player.isMoving and not heal.defaultTank.hasBuff(spells.prayerOfMending)' , kps.heal.defaultTank },
    {spells.prayerOfMending, 'not player.isMoving' , kps.heal.hasNotBuffMending },

    -- TRINKETS -- SLOT 0 /use 13
    -- "Carafe de lumière incendiaire" "Carafe of Searing Light"
    {{"macro"}, 'player.hasTrinket(0) == 151960 and player.useTrinket(0) and target.isAttackable' , "/use 13" },
    -- "Résonateur de vitalité" "Vitality Resonator" 151970
    {{"macro"}, 'player.hasTrinket(0) == 151970 and player.useTrinket(0) and target.isAttackable' , "/use 13" },
    -- "Ishkar's Felshield Emitter" 151957 -- "Emetteur de gangrebouclier d'Ishkar" 151957
    {{"macro"}, 'player.hasTrinket(0) == 151957 and player.useTrinket(0) and focus.isFriend' , "/target ".."focus".."\n".."/use 13".."\n".."/targetlasttarget" },
    {{"macro"}, 'player.hasTrinket(0) == 151957 and player.useTrinket(0)' , "/target ".."player".."\n".."/use 13".."\n".."/targetlasttarget" },

    -- TRINKETS -- SLOT 1 /use 14
    -- "Carafe de lumière incendiaire" "Carafe of Searing Light"
    {{"macro"}, 'player.hasTrinket(1) == 151960 and player.useTrinket(1) and target.isAttackable' , "/use 14" },
    -- "Résonateur de vitalité" "Vitality Resonator" 151970
    {{"macro"}, 'player.hasTrinket(1) == 151970 and player.useTrinket(1) and target.isAttackable' , "/use 14" },
    -- "Velen's Future Sight" 144258
    --{{"macro"}, 'player.hasTrinket(1) == 144258 and player.useTrinket(1) and heal.countLossInRange(0.78) > 2' , "/use 14" },
    
    -- "Exaucements" "Answered Prayers" -- Prayer of Healing increases the healing done by your next Flash Heal, Binding Heal or Heal by 60%
    {{"nested"}, 'not player.isMoving and player.hasBuff(spells.answeredPrayers)' , {
        {spells.flashHeal, 'not player.isMoving and heal.defaultTank.hp < 0.55' , kps.heal.defaultTank, "FLASH_DEFAULT" },
        {spells.flashHeal, 'heal.lowestInRaid.hp < 0.55' , kps.heal.lowestInRaid , "FLASH_SERENITY" },
        {spells.flashHeal, 'holyWordSerenityOnCD() and heal.lowestInRaid.hp < 0.65' , kps.heal.lowestInRaid , "FLASH_SERENITY" },
        {spells.heal, 'holyWordSerenityOnCD() and heal.lowestInRaid.hp > 0.82' , kps.heal.aggroTankTarget , "HEAL_SERENITY" },
        {spells.bindingHeal, 'not heal.aggroTankTarget.isUnit("player")' , kps.heal.aggroTankTarget  ,"BINDING_BUFF" },
        {spells.bindingHeal, 'not heal.lowestTankInRaid.isUnit("player")' , kps.heal.lowestTankInRaid ,"BINDING_BUFF" },
    }},
    
    -- "Espoir impérissable" "Everlasting Hope" -- increase the healing amount of your next Prayer of Healing spell by 30%.
    {{"nested"}, 'not player.isMoving and not player.hasBuff(spells.everlastingHope)' ,{
        {spells.flashHeal, 'not player.isMoving and heal.defaultTank.hp < 0.55' , kps.heal.defaultTank, "FLASH_DEFAULT" },
        {spells.flashHeal, 'heal.lowestInRaid.hp < 0.55' , kps.heal.lowestInRaid , "FLASH_SERENITY" },
        {spells.flashHeal, 'holyWordSerenityOnCD() and heal.lowestInRaid.hp < 0.65' , kps.heal.lowestInRaid , "FLASH_SERENITY" },
        {spells.heal, 'holyWordSerenityOnCD() and heal.lowestInRaid.hp > 0.82' , kps.heal.aggroTankTarget , "HEAL_SERENITY" },
        {spells.bindingHeal, 'not heal.aggroTankTarget.isUnit("player")' , kps.heal.aggroTankTarget ,"BINDING_BUFF" },
        {spells.bindingHeal, 'not heal.lowestTankInRaid.isUnit("player")' , kps.heal.lowestTankInRaid ,"BINDING_BUFF" },
    }},

    -- "Holy Word: Sanctify" -- macro does not work for @target, @mouseover... ONLY @cursor and @player
    {{"macro"},'spells.holyWordSanctify.cooldown == 0 and heal.countLossInDistance(0.78,10) > 4' , "/cast [@player] "..HolyWordSanctify },
    {{"macro"},'spells.holyWordSanctify.cooldown == 0 and heal.countLossInDistance(0.78,10) > 2 and not player.isInRaid' , "/cast [@player] "..HolyWordSanctify },
    -- "Espoir impérissable" "Everlasting Hope" -- increase the healing amount of your next Prayer of Healing spell by 30%.
    {{"nested"}, 'not player.isMoving and heal.countLossInRange(0.78) > 2 and player.hasBuff(spells.everlastingHope)' ,{
        -- "Velen's Future Sight" 144258
        {{"macro"}, 'player.hasTrinket(1) == 144258 and player.useTrinket(1)' , "/use 14" },
        {{spells.holyWordSerenity,spells.prayerOfHealing}, 'heal.lowestInRaid.hp < 0.55 and spells.holyWordSerenity.cooldown == 0' , kps.heal.lowestInRaid , "POH_Serenity" },
        {spells.prayerOfHealing, 'heal.countLossInRange(0.78) > 3 and player.hasBuff(spells.divinity)' , kps.heal.lowestInRaid , "POH_divinity" },
        {spells.prayerOfHealing, 'heal.countLossInRange(0.78) > 3 and player.hasBuff(spells.powerOfTheNaaru)' , kps.heal.lowestInRaid , "POH_powerOfTheNaaru" },
        {{spells.holyWordSanctify,spells.prayerOfHealing}, 'heal.countLossInRange(0.78) > 3 and not player.hasBuff(spells.powerOfTheNaaru) and spells.holyWordSanctify.cooldown == 0' , kps.heal.lowestInRaid , "POH_Sanctify" },
    }},

    -- "Prayer of Healing" 596 -- A powerful prayer that heals the target and the 4 nearest allies within 40 yards for (250% of Spell power)
    -- "Holy Word: Sanctify" & "Holy Word:Serenity" your healing is increased by 15% for 6 sec. Buff "Divinity" 197030 -- pas de cumul des 2 buffs
    -- "Holy Word: Sanctify" augmente les soins de Prière de soins de 30% pendant 15 sec. Buff "Puissance des naaru" 196490  
    {{"nested"}, 'not player.isMoving and heal.countLossInRange(0.78) > 3' ,{
        -- "Velen's Future Sight" 144258
        {{"macro"}, 'player.hasTrinket(1) == 144258 and player.useTrinket(1)' , "/use 14" },
        {{spells.flashHeal,spells.prayerOfHealing}, 'player.hasBuff(spells.powerOfTheNaaru) and heal.lowestInRaid.hp < 0.55' , kps.heal.lowestInRaid  , "POH_BUFF" },
        {{spells.bindingHeal,spells.prayerOfHealing}, 'player.hasBuff(spells.powerOfTheNaaru) and not heal.lowestInRaid.isUnit("player")' , kps.heal.lowestInRaid  , "POH_BUFF" },
        {{spells.holyWordSanctify,spells.flashHeal,spells.prayerOfHealing}, 'not player.hasBuff(spells.powerOfTheNaaru) and spells.holyWordSanctify.cooldown == 0 and heal.lowestInRaid.hp < 0.55' , kps.heal.lowestInRaid  , "POH_BUFF" },
        {{spells.holyWordSanctify,spells.bindingHeal,spells.prayerOfHealing}, 'not player.hasBuff(spells.powerOfTheNaaru) and spells.holyWordSanctify.cooldown == 0 and not heal.lowestInRaid.isUnit("player")' , kps.heal.lowestInRaid  , "POH_BUFF" },
    }},

    -- "Light of T'uure" 208065 -- increasing your healing done to the target by 25% for 10 sec.
    {{"nested"}, 'not player.isMoving and spells.lightOfTuure.cooldown == 0' , {
        {spells.lightOfTuure, 'heal.defaultTank.hp < 0.85 and not heal.defaultTank.hasBuff(spells.lightOfTuure)' , kps.heal.defaultTank},
        {spells.lightOfTuure, 'heal.lowestTankInRaid.hp < 0.85 and heal.lowestTankInRaid.incomingDamage > heal.lowestTankInRaid.incomingHeal and not heal.lowestTankInRaid.hasBuff(spells.lightOfTuure)' , kps.heal.lowestTankInRaid},
        {spells.lightOfTuure, 'heal.aggroTankTarget.hp < 0.85 and heal.aggroTankTarget.incomingDamage > heal.aggroTankTarget.incomingHeal and not heal.aggroTankTarget.hasBuff(spells.lightOfTuure)' , kps.heal.aggroTankTarget},
    }},
    -- Emergency Lowest Important Unit
    {spells.flashHeal, 'not player.isMoving and heal.defaultTank.hp < 0.55' , kps.heal.defaultTank, "FLASH_DEFAULT" },
    {spells.flashHeal, 'not player.isMoving and heal.aggroTankTarget.hp < 0.55 and heal.lowestInRaid.isUnit(heal.aggroTankTarget.unit)' , kps.heal.aggroTankTarget , "FLASH_AGGRO_LOWEST" },
    {spells.flashHeal, 'not player.isMoving and heal.lowestTankInRaid.hp < 0.55 and heal.lowestInRaid.isUnit(heal.lowestTankInRaid.unit)' , kps.heal.lowestTankInRaid , "FLASH_TANK_LOWEST" },
    {spells.flashHeal, 'not player.isMoving and heal.hasBossDebuff ~= nil and heal.hasBossDebuff.hp < 0.65 ' , kps.heal.hasBossDebuff , "BOSSDEBUFF" },
    -- ABSORBHEAL
    {spells.bindingHeal, 'kps.mouseOver and not player.isMoving and mouseover.absorptionHeal and not mouseover.isUnit("player")' , "mouseover" },
    {spells.prayerOfHealing, 'not player.isMoving and player.hasBuff(spells.everlastingHope) and heal.countAbsorptionHeal > 2 and heal.hasAbsorptionHeal ~= nil' , kps.heal.hasAbsorptionHeal },
    {spells.flashHeal, 'not player.isMoving and heal.hasAbsorptionHeal ~= nil and heal.hasAbsorptionHeal.hp < 0.65' , kps.heal.hasAbsorptionHeal },
    {spells.bindingHeal, 'not player.isMoving and heal.hasAbsorptionHeal ~= nil and not heal.hasAbsorptionHeal.isUnit("player")' , kps.heal.hasAbsorptionHeal },
    -- MOUSEOVER
    {{"nested"}, 'kps.mouseOver and mouseover.isFriend and not mouseover.immuneHeal' , {
        {spells.flashHeal, 'not player.isMoving and mouseover.hasBossDebuff and mouseover.hp < 0.65 ' , "mouseover" },
        {spells.heal, 'not player.isMoving and mouseover.hasBossDebuff and mouseover.hp < 0.95 ' , "mouseover" },
        {{spells.bindingHeal,spells.prayerOfHealing}, 'player.hasBuff(spells.powerOfTheNaaru) and heal.countLossInRange(0.78) > 3 and not mouseover.isUnit("player")' , "mouseover" },
        {spells.flashHeal, 'not player.isMoving and mouseover.hp < 0.55' , "mouseover" },
        {spells.bindingHeal, 'not player.isMoving and not mouseover.isUnit("player") and heal.countLossInRange(0.82) > 2' , "mouseover" },
        {spells.heal, 'not player.isMoving and holyWordSerenityOnCD() and mouseover.hp < 0.90' , "mouseover" },
    }},


    -- "Circle of Healing" 204883
    --{spells.circleOfHealing, 'player.isMoving and heal.countLossInRange(0.78) > 2 and not player.isInRaid' , kps.heal.lowestInRaid},
    --{spells.circleOfHealing, 'player.isMoving and heal.countLossInRange(0.78) > 4 and player.isInRaid' },

    -- "Soins rapides" 2060
    {{"nested"}, 'not player.isMoving and heal.lowestInRaid.hp < 0.72 and heal.countInRange < 6' ,{
        {spells.flashHeal, 'not player.isMoving and heal.lowestTankInRaid.hp < 0.72' , kps.heal.lowestTankInRaid , "FLASH_TANK" },
        {spells.flashHeal, 'not player.isMoving and heal.aggroTankTarget.hp < 0.72' , kps.heal.aggroTankTarget , "FLASH_AGGRO" },
        {spells.flashHeal, 'not player.isMoving and heal.lowestInRaid.hp < 0.72' , kps.heal.lowestInRaid , "FLASH_LOWEST" },
    }},
    {spells.flashHeal, 'not player.isMoving and heal.lowestTankInRaid.hp < 0.55 and heal.lowestTankInRaid.incomingDamage > heal.lowestTankInRaid.incomingHeal' , kps.heal.lowestTankInRaid , "FLASH_TANK_DMG" },
    {spells.flashHeal, 'not player.isMoving and heal.aggroTankTarget.hp < 0.55 and heal.aggroTankTarget.incomingDamage > heal.aggroTankTarget.incomingHeal' , kps.heal.aggroTankTarget , "FLASH_AGGRO_DMG" },
    {spells.flashHeal, 'not player.isMoving and heal.lowestInRaid.hp < 0.55 and heal.lowestInRaid.incomingDamage > heal.lowestInRaid.incomingHeal' , kps.heal.lowestInRaid , "FLASH_LOWEST_DMG" },
    -- "Soins de lien" 32546
    {spells.bindingHeal, 'not player.isMoving and not heal.lowestTankInRaid.isUnit("player") and spells.holyWordSanctify.cooldown > 4' , kps.heal.lowestTankInRaid ,"BINDING_SANCTIFY_TANK" },
    {spells.bindingHeal, 'not player.isMoving and not heal.aggroTankTarget.isUnit("player") and spells.holyWordSanctify.cooldown > 4' , kps.heal.aggroTankTarget ,"BINDING_SANCTIFY_AGGRO" },
    {spells.bindingHeal, 'not player.isMoving and not heal.lowestInRaid.isUnit("player") and player.hp < 0.90' , kps.heal.lowestInRaid ,"BINDING_LOWEST" },
    {spells.bindingHeal, 'not player.isMoving and not heal.lowestInRaid.isUnit("player") and heal.countLossInRange(0.90) > 2' , kps.heal.lowestInRaid ,"BINDING_LOWEST" },
    -- "Soins" 2060 -- "Renouveau constant" 200153
    {spells.heal, 'not player.isMoving and heal.hasBossDebuff ~= nil and heal.hasBossDebuff.hp < 0.95 ' , kps.heal.hasBossDebuff , "BOSSDEBUFF" },
    {spells.heal, 'not player.isMoving and holyWordSerenityOnCD()' , kps.heal.lowestInRaid },
    {spells.heal, 'not player.isMoving and heal.aggroTankTarget.hp < 0.90' , kps.heal.aggroTankTarget },
    {spells.heal, 'not player.isMoving and heal.lowestTankInRaid.hp < 0.90' , kps.heal.lowestTankInRaid },
    {spells.heal, 'not player.isMoving and heal.lowestInRaid.hp < 0.90' , kps.heal.lowestInRaid },

    -- "Renew" 139 PARTY
    {spells.renew, 'not player.isInRaid and heal.lowestInRaid.hp < 0.90 and not heal.lowestInRaid.hasBuff(spells.renew) and not heal.lowestInRaid.hasBuff(spells.masteryEchoOfLight)' , kps.heal.lowestInRaid, "RENEW_PARTY" },
    {spells.renew, 'player.isMoving and heal.lowestTankInRaid.hp < 0.90 and not heal.lowestTankInRaid.hasBuff(spells.renew) and not heal.lowestTankInRaid.hasBuff(spells.masteryEchoOfLight)' , kps.heal.lowestTankInRaid, "RENEW_TANK" },
    {spells.renew, 'player.isMoving and heal.aggroTankTarget.hp < 0.90 and not heal.aggroTankTarget.hasBuff(spells.renew) and not heal.aggroTankTarget.hasBuff(spells.masteryEchoOfLight)' , kps.heal.aggroTankTarget, "RENEW_AGGRO" },
    {spells.renew, 'player.isMoving and heal.lowestInRaid.hp < 0.72 and not heal.lowestInRaid.hasBuff(spells.renew) and not heal.lowestInRaid.hasBuff(spells.masteryEchoOfLight)' , kps.heal.lowestInRaid, "RENEW_LOWEST" },

    -- "Nova sacrée" 132157
    {spells.holyNova, 'player.isMoving and target.distance < 10 and target.isAttackable and heal.countLossInDistance(0.90,10) > 2' , "target" },
    -- "Surge Of Light" Your healing spells and Smite have a 8% chance to make your next Flash Heal instant and cost no mana
    {spells.smite, 'not player.isMoving and target.isAttackable', "target" },
    {spells.smite, 'not player.isMoving and targettarget.isAttackable', "targettarget" },
    {spells.smite, 'not player.isMoving and focustarget.isAttackable', "focustarget" },

}
,"priest_holy")


-- MACRO --
--[[

#showtooltip Rénovation
/cast [@mouseover,exists,nodead,help][exists,nodead,help][@player] Rénovation

#showtooltip Soins rapides
/cast [@mouseover,exists,nodead,help][exists,nodead,help][@player] Soins rapides

#showtooltip Esprit gardien
/cast [@mouseover,exists,nodead,help][exists,nodead,help][@player] Esprit gardien

#showtooltip Prière de guérison
/cast [@mouseover,exists,nodead,help][exists,nodead,help][@player] Prière de guérison

#showtooltip Prière de soins
/cast [@mouseover,exists,nodead,help][exists,nodead,help][@player] Prière de soins

#showtooltip Purifier
/cast [@mouseover,exists,nodead,help][exists,nodead,help][@player] Purifier

#showtooltip Mot sacré : Sérénité
/cast [@mouseover,exists,nodead,help][exists,nodead,help][@player] Mot sacré : Sérénité

#showtooltip Supplique
/cast [@mouseover,exists,nodead,help][@player] Supplique

#showtooltip Mot de pouvoir : Bouclier
/cast [@mouseover,exists,nodead,help][@player] Mot de pouvoir : Bouclier

]]--


