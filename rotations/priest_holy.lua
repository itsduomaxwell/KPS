--[[[
@module Priest Holy Rotation
@author htordeux
@version 7.2
]]--


local spells = kps.spells.priest
local env = kps.env.priest

local HolyWordSanctify = spells.holyWordSanctify.name
local SpiritOfRedemption = spells.spiritOfRedemption.name
local MassDispel = spells.massDispel.name
local AngelicFeather = spells.angelicFeather.name

kps.runAtEnd(function()
   kps.gui.addCustomToggle("PRIEST","HOLY", "mouseOver", "Interface\\Icons\\priest_spell_leapoffaith_a", "mouseOver")
end)

-- kps.cooldowns for dispel
-- kps.interrupt for guardianSpirit
-- kps.defensive for overhealing
-- kps.multiTarget for damage
kps.rotations.register("PRIEST","HOLY",{

    {{"macro"}, 'not target.exists and mouseover.inCombat and mouseover.isAttackable' , "/target mouseover" },
    env.ShouldInterruptCasting,
    env.ScreenMessage,

    {{"macro"}, 'player.hasBuff(spells.spiritOfRedemption) and heal.countInRange == 0' , "/cancelaura "..SpiritOfRedemption },
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
    {{spells.prayerOfMending,spells.divineHymn}, 'not player.isMoving and spells.prayerOfMending.cooldown == 0 and keys.alt' ,  kps.heal.defaultTank },
    {spells.divineHymn, 'not player.isMoving and heal.hasBuffStacks(spells.prayerOfMending) > 5 and keys.alt' ,  kps.heal.defaultTank }, 
    
    -- "Fade" 586 "Disparition"
    {spells.fade, 'player.isTarget' },
    -- "Pierre de soins" 5512
    {{"macro"}, 'player.useItem(5512) and player.hp < 0.78' ,"/use item:5512" },
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

    -- "Guardian Spirit" 47788
    {{"nested"}, 'kps.interrupt' ,{
        {spells.guardianSpirit, 'mouseover.immuneHeal and mouseover.hp < 0.40' , "mouseover" },
        {spells.guardianSpirit, 'mouseover.isFriend and mouseover.hp < 0.30' , "mouseover" },
        {spells.guardianSpirit, 'player.hp < 0.30 and not heal.lowestInRaid.isUnit("player")' , kps.heal.lowestInRaid},
        {spells.guardianSpirit, 'player.hp < 0.30 and not heal.lowestTankInRaid.isUnit("player")' , kps.heal.lowestTankInRaid},
        {spells.guardianSpirit, 'heal.defaultTank.hp < 0.30' , kps.heal.defaultTank},
        {spells.guardianSpirit, 'heal.aggroTankTarget.hp < 0.30' , kps.heal.aggroTankTarget},
        {spells.guardianSpirit, 'heal.lowestTankInRaid.hp < 0.30' , kps.heal.lowestTankInRaid},
        {spells.guardianSpirit, 'heal.lowestInRaid.hp < 0.30' , kps.heal.lowestInRaid},
    }},
    
    -- "Holy Word: Serenity"
    {spells.holyWordSerenity, 'mouseover.isFriend and mouseover.hp < 0.30' , "mouseover" },
    {spells.holyWordSerenity, 'player.hp < 0.40' , "player"},
    {spells.holyWordSerenity, 'heal.defaultTank.hp < 0.40' , kps.heal.defaultTank},
    {spells.holyWordSerenity, 'heal.lowestTankInRaid.hp < 0.55' , kps.heal.lowestTankInRaid},
    {spells.holyWordSerenity, 'heal.aggroTankTarget.hp < 0.55' , kps.heal.aggroTankTarget},
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

    -- "Dispel" "Purifier" 527
    {{"nested"},'kps.cooldowns', {
        {spells.purify, 'player.isDispellable("Magic")' , "player" },
        {spells.purify, 'mouseover.isDispellable("Magic")' , "mouseover" },
        {spells.purify, 'focus.isFriend and focus.isDispellable("Magic")' , "focus"},
        {spells.purify, 'heal.lowestTankInRaid.isDispellable("Magic")' , kps.heal.lowestTankInRaid},
        {spells.purify, 'heal.aggroTankTarget.isDispellable("Magic")' , kps.heal.aggroTankTarget},
        {spells.purify, 'heal.lowestInRaid.isDispellable("Magic")' , kps.heal.lowestInRaid},
        {spells.purify, 'heal.isMagicDispellable ~= nil' , kps.heal.isMagicDispellable },
    }},
    -- "Dissipation de la magie" -- Dissipe la magie sur la cible ennemie, supprimant ainsi 1 effet magique bénéfique.
    -- {spells.dispelMagic, 'target.isAttackable' , "target" },
    -- {spells.dispelMagic, 'focustarget.isAttackable' , "focustarget" },
    
    -- "Prayer of Mending" (Tank only)
    {spells.prayerOfMending, 'not player.isMoving and not heal.lowestTankInRaid.hasBuff(spells.prayerOfMending)' , kps.heal.lowestTankInRaid },
    {spells.prayerOfMending, 'not player.isMoving and not heal.aggroTankTarget.hasBuff(spells.prayerOfMending)' , kps.heal.aggroTankTarget},
    {spells.prayerOfMending, 'not player.isMoving and not heal.defaultTank.hasBuff(spells.prayerOfMending)' , kps.heal.defaultTank},
    {{"nested"}, 'not player.isMoving and spells.prayerOfMending.lastCasted(2)' , {
        {spells.flashHeal, 'heal.lowestInRaid.hp < 0.40' , kps.heal.lowestInRaid ,"FLASH_LOWEST_POM" },
        {spells.bindingHeal, 'not heal.lowestInRaid.isUnit("player")' , kps.heal.lowestInRaid ,"BINDING_LOWEST_POM" },
        {spells.bindingHeal, 'not heal.aggroTankTarget.isUnit("player")' , kps.heal.aggroTankTarget ,"BINDING_LOWEST_POM" },
        {spells.bindingHeal, 'not heal.lowestTankInRaid.isUnit("player")' , kps.heal.lowestTankInRaid ,"BINDING_LOWEST_POM" },
    }},
    
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
    {{"macro"}, 'player.hasTrinket(1) == 144258 and player.useTrinket(1) and heal.countLossInRange(0.78) > 2' , "/use 14" },
    {{"macro"}, 'player.hasTrinket(1) == 144258 and player.useTrinket(1) and heal.lowestInRaid.hp < 0.55 ' , "/use 14" },

    -- "Light of T'uure" 208065 -- track buff in case an other priest have casted lightOfTuure
    {{spells.lightOfTuure,spells.heal}, 'not player.isMoving and spells.lightOfTuure.cooldown == 0 and heal.lowestTankInRaid.incomingDamage > heal.lowestTankInRaid.incomingHeal and heal.lowestTankInRaid.hp < 0.78 and not heal.lowestTankInRaid.hasBuff(spells.lightOfTuure)' , kps.heal.lowestTankInRaid},
    {{spells.lightOfTuure,spells.heal}, 'not player.isMoving and spells.lightOfTuure.cooldown == 0 and heal.aggroTankTarget.incomingDamage > heal.aggroTankTarget.incomingHeal and heal.aggroTankTarget.hp < 0.78 and not heal.aggroTankTarget.hasBuff(spells.lightOfTuure)' , kps.heal.aggroTankTarget},
    {{spells.lightOfTuure,spells.flashHeal}, 'not player.isMoving and spells.lightOfTuure.cooldown == 0 and player.hp < 0.55 and not player.hasBuff(spells.lightOfTuure)' , kps.heal.lowestInRaid},
    {{spells.lightOfTuure,spells.flashHeal}, 'not player.isMoving and heal.hasAbsorptionHeal ~= nil and heal.hasAbsorptionHeal.hp < 0.55' , "mouseover" , kps.heal.hasAbsorptionHeal },
    {{spells.lightOfTuure,spells.heal}, 'not player.isMoving and heal.hasAbsorptionHeal ~= nil' , "mouseover" , kps.heal.hasAbsorptionHeal },
    -- kps.lastCast["name"] ne fonctionne pas si lastCast etait une macro 'kps.lastCast["name"] == spells.prayerOfHealing' or 'spells.prayerOfHealing.lastCasted(4)'
    -- "Exaucements" "Answered Prayers" -- Prayer of Healing increases the healing done by your next Flash Heal, Binding Heal or Heal by 60%
    {{"nested"}, 'not player.isMoving and player.hasBuff(spells.answeredPrayers)' , {
        {spells.flashHeal, 'heal.lowestInRaid.hp < 0.55' , kps.heal.lowestInRaid ,"FLASH_LOWEST_POH" },
        {spells.heal, 'not player.isMoving and holyWordSerenityOnCD()' , kps.heal.lowestInRaid , "HEAL_SERENITY" },
        {spells.bindingHeal, 'not heal.lowestInRaid.isUnit("player")' , kps.heal.lowestInRaid ,"BINDING_LOWEST_POH" },
        {spells.bindingHeal, 'not heal.aggroTankTarget.isUnit("player")' , kps.heal.aggroTankTarget ,"BINDING_LOWEST_POH" },
        {spells.bindingHeal, 'not heal.lowestTankInRaid.isUnit("player")' , kps.heal.lowestTankInRaid ,"BINDING_LOWEST_POH" },
    }},
    -- "Espoir impérissable" "Everlasting Hope" -- increase the healing amount of your next Prayer of Healing spell by 30%.
    {{"nested"}, 'not player.isMoving and heal.countLossInRange(0.78) > 2 and not player.hasBuff(spells.everlastingHope)' ,{
        {spells.flashHeal, 'holyWordSerenityOnCD() and heal.lowestInRaid.hp < 0.55' , kps.heal.lowestInRaid , "FLASH_SERENITY" },
        {spells.bindingHeal, 'not heal.lowestInRaid.isUnit("player")' , kps.heal.lowestInRaid },
        {spells.bindingHeal, 'not heal.aggroTankTarget.isUnit("player")' , kps.heal.aggroTankTarget },
        {spells.bindingHeal, 'not heal.lowestTankInRaid.isUnit("player")' , kps.heal.lowestTankInRaid },
    }},

    {{"nested"}, 'kps.mouseOver and mouseover.isFriend and mouseover.absorptionHeal' , {
        {{spells.lightOfTuure,spells.flashHeal}, 'not player.isMoving ' , "mouseover" },
        {spells.holyWordSerenity, 'mouseover.hp < 0.55' , "mouseover" },
        {spells.bindingHeal, 'not player.isMoving and not mouseover.isUnit("player") and heal.countLossInRange(0.78) > 2' , "mouseover" },
        {spells.flashHeal, 'not player.isMoving and mouseover.hp < 0.72' , "mouseover" },
        {spells.heal, 'not player.isMoving' , "mouseover" },
    }},

    -- "Holy Word: Sanctify" -- macro does not work for @target, @mouseover... ONLY @cursor and @player
    {{"macro"},'spells.holyWordSanctify.cooldown == 0 and heal.countLossInDistance(0.78,10) > 4' , "/cast [@player] "..HolyWordSanctify },
    {{"macro"},'spells.holyWordSanctify.cooldown == 0 and heal.countLossInDistance(0.78,10) > 2 and not player.isInRaid' , "/cast [@player] "..HolyWordSanctify },
    
    -- "Espoir impérissable" "Everlasting Hope" -- increase the healing amount of your next Prayer of Healing spell by 30%.
    {{"nested"}, 'not player.isMoving and heal.countLossInRange(0.78) > 2 and player.hasBuff(spells.everlastingHope)' ,{
        {spells.prayerOfHealing, 'heal.countLossInRange(0.72) > 2 and player.hasBuff(spells.powerOfTheNaaru)' , kps.heal.lowestInRaid , "POH_HOPE" },
        {{spells.holyWordSanctify,spells.prayerOfHealing}, 'heal.countLossInRange(0.72) > 2 and spells.holyWordSanctify.cooldown == 0' , kps.heal.lowestInRaid , "POH_HOPE" },
        {spells.prayerOfHealing, 'heal.countLossInRange(0.72) > 2' , kps.heal.lowestInRaid , "POH_HOPE" },
        {spells.prayerOfHealing, 'heal.lowestInRaid.hp < 0.55' , kps.heal.lowestInRaid , "POH_HOPE" },
    }},

    -- "Prayer of Healing" 596 -- A powerful prayer that heals the target and the 4 nearest allies within 40 yards for (250% of Spell power)
    -- "Holy Word: Sanctify" your healing is increased by 15% for 6 sec. Buff "Divinity" 197030
    -- "Holy Word: Sanctify" augmente les soins de Prière de soins de 6% pendant 15 sec. Buff "Puissance des naaru" 196490
    {{"nested"}, 'not player.isMoving and heal.countLossInRange(0.78) > 4' ,{
        {{spells.flashHeal,spells.prayerOfHealing}, 'player.hasBuff(spells.powerOfTheNaaru) and heal.lowestInRaid.hp < 0.55' , kps.heal.lowestInRaid  , "POH_BUFF" },
        {{spells.bindingHeal,spells.prayerOfHealing}, 'player.hasBuff(spells.powerOfTheNaaru) and not heal.lowestInRaid.isUnit("player")' , kps.heal.lowestInRaid  , "POH_BUFF" },
        {{spells.holyWordSanctify,spells.flashHeal,spells.prayerOfHealing}, 'spells.holyWordSanctify.cooldown == 0 and heal.lowestInRaid.hp < 0.55' , kps.heal.lowestInRaid  },
        {{spells.holyWordSanctify,spells.bindingHeal,spells.prayerOfHealing}, 'spells.holyWordSanctify.cooldown == 0 and not heal.lowestInRaid.isUnit("player")' , kps.heal.lowestInRaid  },
        {{spells.bindingHeal,spells.prayerOfHealing}, 'not spells.prayerOfHealing.isRecastAt(heal.lowestInRaid.unit) and not heal.lowestInRaid.isUnit("player")', kps.heal.lowestInRaid , "POH_COUNT" },
    }},

    {{"nested"}, 'not player.isMoving and heal.countLossInRange(0.78) > 2 and not player.isInRaid' ,{
        {{spells.flashHeal,spells.prayerOfHealing}, 'player.hasBuff(spells.powerOfTheNaaru) and heal.lowestInRaid.hp < 0.55' , kps.heal.lowestInRaid , "POH_BUFF" },
        {{spells.bindingHeal,spells.prayerOfHealing}, 'player.hasBuff(spells.powerOfTheNaaru) and not heal.lowestInRaid.isUnit("player")' , kps.heal.lowestInRaid , "POH_BUFF" },
        {{spells.holyWordSanctify,spells.flashHeal,spells.prayerOfHealing}, 'spells.holyWordSanctify.cooldown == 0 and heal.lowestInRaid.hp < 0.55' , kps.heal.lowestInRaid  },
        {{spells.holyWordSanctify,spells.bindingHeal,spells.prayerOfHealing}, 'spells.holyWordSanctify.cooldown == 0 and not heal.lowestInRaid.isUnit("player")' , kps.heal.lowestInRaid  },
        {{spells.bindingHeal,spells.prayerOfHealing}, 'not spells.prayerOfHealing.isRecastAt(heal.lowestInRaid.unit) and not heal.lowestInRaid.isUnit("player")' , kps.heal.lowestInRaid , "POH_COUNT" },
    }},

    -- "Circle of Healing" 204883
    --{spells.circleOfHealing, 'player.isMoving and heal.countLossInRange(0.78) > 2 and not player.isInRaid' , kps.heal.lowestInRaid},
    --{spells.circleOfHealing, 'player.isMoving and heal.countLossInRange(0.78) > 4 and player.isInRaid' },

    -- MOUSEOVER
    {{"nested"}, 'kps.mouseOver and mouseover.isFriend' , {
        {spells.guardianSpirit, 'mouseover.hp < 0.30' , "mouseover" },
        {spells.holyWordSerenity, 'mouseover.hp < 0.55' , "mouseover" },
        {spells.flashHeal, 'not player.isMoving and mouseover.hp < 0.72' , "mouseover" },
        {spells.bindingHeal, 'not player.isMoving and not mouseover.isUnit("player") and mouseover.hp < 0.90 and heal.countLossInRange(0.78) > 2' , "mouseover" },
        {spells.heal, 'not player.isMoving and mouseover.hp < 0.90' , "mouseover" },
    }},

    -- DAMAGE
    {{"nested"}, 'kps.multiTarget and heal.lowestInRaid.hp > target.hp and heal.lowestInRaid.hp > 0.72' , {
        {spells.holyWordChastise, 'target.isAttackable' , "target" },
        {spells.holyWordChastise, 'targettarget.isAttackable', "targettarget" },
        {spells.holyWordChastise, 'focustarget.isAttackable', "focustarget" },
        {spells.holyFire, 'target.isAttackable' , "target" },
        {spells.holyFire, 'targettarget.isAttackable', "targettarget" },
        {spells.holyFire, 'focustarget.isAttackable', "focustarget" },
        {spells.holyNova, 'kps.lastCast["name"] == spells.smite and target.distance < 10 and target.isAttackable' , "target" },
        {spells.smite, 'not player.isMoving and target.isAttackable', "target" },
        {spells.smite, 'not player.isMoving and targettarget.isAttackable', "targettarget" },
        {spells.smite, 'not player.isMoving and focustarget.isAttackable', "focustarget" },
    }},

    -- "Soins rapides" 2060
    {spells.flashHeal, 'not player.isMoving and player.hp < 0.55 and not spells.flashHeal.isRecastAt("player")' , "player" ,"FLASH_PLAYER" },
    {spells.flashHeal, 'not player.isMoving and player.hp < 0.55 and heal.lowestInRaid.isUnit("player")' , "player" , "FLASH_PLAYER_LOWEST" },
    {spells.flashHeal, 'not player.isMoving and heal.lowestTankInRaid.hp < 0.55 and heal.lowestInRaid.isUnit(heal.lowestTankInRaid.unit)' , kps.heal.lowestTankInRaid , "FLASH_TANK_LOWEST" },
    {spells.flashHeal, 'not player.isMoving and heal.aggroTankTarget.hp < 0.55 and heal.lowestInRaid.isUnit(heal.aggroTankTarget.unit)' , kps.heal.aggroTankTarget , "FLASH_AGGRO_LOWEST" },
    {{"nested"}, 'not player.isMoving and heal.lowestInRaid.hp < 0.82 and not player.isInRaid' ,{
        {spells.flashHeal, 'not player.isMoving and heal.lowestTankInRaid.hp < 0.82' , kps.heal.lowestTankInRaid , "FLASH_TANK" },
        {spells.flashHeal, 'not player.isMoving and heal.aggroTankTarget.hp < 0.82' , kps.heal.aggroTankTarget , "FLASH_AGGRO" },
        {spells.flashHeal, 'not player.isMoving and heal.lowestInRaid.hp < 0.82' , kps.heal.lowestInRaid , "FLASH_LOWEST" },
    }},
    {spells.flashHeal, 'not player.isMoving and heal.lowestTankInRaid.hp < 0.55 and heal.lowestTankInRaid.incomingDamage > heal.lowestTankInRaid.incomingHeal' , kps.heal.lowestTankInRaid , "FLASH_TANK_DMG" },
    {spells.flashHeal, 'not player.isMoving and heal.aggroTankTarget.hp < 0.55 and heal.aggroTankTarget.incomingDamage > heal.aggroTankTarget.incomingHeal' , kps.heal.aggroTankTarget , "FLASH_AGGRO_DMG" },
    {spells.flashHeal, 'not player.isMoving and heal.lowestInRaid.hp < 0.40 and heal.lowestInRaid.incomingDamage > heal.lowestInRaid.incomingHeal' , kps.heal.lowestInRaid , "FLASH_LOWEST_DMG" },
    -- "Soins de lien" 32546
    {spells.bindingHeal, 'not player.isMoving and not heal.lowestInRaid.isUnit("player") and player.hp < 0.90' , kps.heal.lowestInRaid ,"BINDING_PLAYER" },
    {spells.bindingHeal, 'not player.isMoving and not heal.lowestTankInRaid.isUnit("player") and spells.holyWordSanctify.cooldown > 4' , kps.heal.lowestTankInRaid ,"BINDING_SANCTIFY_TANK" },
    {spells.bindingHeal, 'not player.isMoving and not heal.aggroTankTarget.isUnit("player") and spells.holyWordSanctify.cooldown > 4' , kps.heal.aggroTankTarget ,"BINDING_SANCTIFY_AGGRO" },
    {spells.bindingHeal, 'not player.isMoving and not heal.lowestInRaid.isUnit("player") and heal.countLossInRange(0.90) > 2' , kps.heal.lowestInRaid ,"BINDING_LOWEST" },
    {spells.bindingHeal, 'not player.isMoving and not heal.lowestInRaid.isUnit("player") and heal.countLossInRange(0.90) > 1 and not player.isInRaid' , kps.heal.lowestInRaid ,"BINDING_LOWEST" },
    -- "Soins" 2060 -- "Renouveau constant" 200153
    {spells.heal, 'not player.isMoving and holyWordSerenityOnCD()' , kps.heal.lowestInRaid , "HEAL_SERENITY" },
    {spells.heal, 'not player.isMoving and heal.aggroTankTarget.hp < 0.90' , kps.heal.aggroTankTarget , "HEAL_AGGRO" },
    {spells.heal, 'not player.isMoving and heal.lowestTankInRaid.hp < 0.90' , kps.heal.lowestTankInRaid , "HEAL_TANK" },
    {spells.heal, 'not player.isMoving and heal.lowestInRaid.hp < 0.90' , kps.heal.lowestInRaid , "HEAL_LOWEST" },

    -- "Renew" 139 PARTY
    {spells.renew, 'not player.isInRaid and heal.lowestInRaid.hp < 0.90 and not heal.lowestInRaid.hasBuff(spells.renew) and not heal.lowestInRaid.hasBuff(spells.masteryEchoOfLight)' , kps.heal.lowestInRaid, "RENEW_PARTY" },
    {spells.renew, 'player.isMoving and heal.lowestTankInRaid.hp < 0.90 and not heal.lowestTankInRaid.hasBuff(spells.renew) and not heal.lowestTankInRaid.hasBuff(spells.masteryEchoOfLight)' , kps.heal.lowestTankInRaid, "RENEW_TANK" },
    {spells.renew, 'player.isMoving and heal.aggroTankTarget.hp < 0.90 and not heal.aggroTankTarget.hasBuff(spells.renew) and not heal.aggroTankTarget.hasBuff(spells.masteryEchoOfLight)' , kps.heal.aggroTankTarget, "RENEW_AGGRO" },
    {spells.renew, 'player.isMoving and heal.lowestInRaid.hp < 0.72 and not heal.lowestInRaid.hasBuff(spells.renew) and not heal.lowestInRaid.hasBuff(spells.masteryEchoOfLight)' , kps.heal.lowestInRaid, "RENEW" },

    -- "Nova sacrée" 132157
    {spells.holyNova, 'player.isMoving and target.distance < 10 and target.isAttackable and heal.countLossInDistance(0.90,10) > 2' , "target" },
    {spells.holyNova, 'player.isMoving and targettarget.distance < 10 and targettarget.isAttackable and heal.countLossInDistance(0.90,10) > 2' , "targettarget" },
    {spells.holyNova, 'player.isMoving and focustarget.distance < 10 and focustarget.isAttackable and heal.countLossInDistance(0.90,10) > 2' , "focustarget" },
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


