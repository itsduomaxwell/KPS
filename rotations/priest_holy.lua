--[[[
@module Priest Holy Rotation
@author htordeux
@version 7.3.5
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

--kps.runAtEnd(function()
--  kps.gui.addCustomToggle("PRIEST","HOLY", "pauseRotation", "Interface\\Icons\\Spell_frost_frost", "pauseRotation")
--end)


kps.rotations.register("PRIEST","HOLY",{

    --{{"pause"}, 'kps.pauseRotation', 2},

    {{"macro"}, 'not target.exists and mouseover.isAttackable and mouseover.inCombat' , "/target mouseover" },
    env.ScreenMessage,
    --env.ShouldInterruptCasting,
    {{"macro"}, 'spells.heal.shouldInterrupt(0.95)' , "/stopcasting" },
    {{"macro"}, 'spells.flashHeal.shouldInterrupt(0.85)' , "/stopcasting" },
    {{"macro"}, 'spells.prayerOfHealing.shouldInterrupt(heal.countLossInRange(0.85))' , "/stopcasting" },

    {{"macro"}, 'player.hasBuff(spells.spiritOfRedemption) and heal.lowestInRaid.isUnit("player")' , "/cancelaura "..SpiritOfRedemption },
    {{"nested"}, 'player.hasBuff(spells.spiritOfRedemption) and not heal.lowestInRaid.isUnit("player")' ,{
        {spells.holyWordSerenity, 'true' , kps.heal.lowestInRaid},
        {spells.prayerOfMending, 'true' , kps.heal.lowestInRaid},
        {spells.prayerOfHealing, 'kps.lastCast["name"] == spells.flashHeal' , kps.heal.lowestInRaid},
        {spells.flashHeal, 'heal.lowestInRaid.hp < 0.90' , kps.heal.lowestInRaid},
        {spells.renew, 'not heal.lowestInRaid.hasBuff(spells.renew)' , kps.heal.lowestInRaid},
    }},

    -- "Guardian Spirit" 47788
    {{"nested"}, 'kps.interrupt' ,{
        {spells.guardianSpirit, 'player.hp < 0.30' , kps.heal.lowestTankInRaid},
        {spells.guardianSpirit, 'heal.defaultTank.hp < 0.30' , kps.heal.defaultTank},
        {spells.guardianSpirit, 'heal.lowestTankInRaid.hp < 0.30' , kps.heal.lowestTankInRaid},
        {spells.guardianSpirit, 'heal.lowestTargetInRaid.hp < 0.30' , kps.heal.lowestTargetInRaid},
        {spells.guardianSpirit, 'heal.lowestInRaid.hp < 0.30' , kps.heal.lowestInRaid},
    }},

    -- "Holy Word: Sanctify" and "Holy Word: Serenity" gives buff  "Divinity" 197030 When you heal with a Holy Word spell, your healing is increased by 15% for 8 sec.
    {{"macro"}, 'keys.shift', "/cast [@cursor] "..HolyWordSanctify },
    -- "Dissipation de masse" 32375
    {{"macro"}, 'keys.ctrl', "/cast [@cursor] "..MassDispel },
    -- "Divine Hymn" 64843
    {{"nested"}, 'keys.alt and not player.isMoving' ,{
        -- "Velen's Future Sight" 144258
        {{"macro"}, 'player.hasTrinket(1) == 144258 and player.useTrinket(1)' , "/use 14" },
        {spells.divineHymn, 'player.hasBuff(spells.divinity) and spells.prayerOfMending.cooldown > kps.gcd' },
        {spells.divineHymn, 'heal.hasBuffStacks(spells.prayerOfMending) > 0 and spells.prayerOfMending.cooldown > kps.gcd' },
        {spells.prayerOfMending, 'true', kps.heal.defaultTank},
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
    
    -- TRINKETS -- SLOT 0 /use 13
    -- "Carafe de lumière incendiaire" "Carafe of Searing Light"
    {{"macro"}, 'player.hasTrinket(0) == 151960 and player.useTrinket(0) and target.isAttackable' , "/use 13" },
    -- "Résonateur de vitalité" "Vitality Resonator" 151970
    {{"macro"}, 'player.hasTrinket(0) == 151970 and player.useTrinket(0) and target.isAttackable' , "/use 13" },
    -- "Ishkar's Felshield Emitter" 151957 -- "Emetteur de gangrebouclier d'Ishkar" 151957
    {{"macro"}, 'player.hasTrinket(0) == 151957 and player.useTrinket(0)' , "/target ".."player".."\n".."/use 13".."\n".."/targetlasttarget" },

    -- TRINKETS -- SLOT 1 /use 14
    -- "Carafe de lumière incendiaire" "Carafe of Searing Light"
    {{"macro"}, 'player.hasTrinket(1) == 151960 and player.useTrinket(1) and target.isAttackable' , "/use 14" },
    -- "Résonateur de vitalité" "Vitality Resonator" 151970
    {{"macro"}, 'player.hasTrinket(1) == 151970 and player.useTrinket(1) and target.isAttackable' , "/use 14" },
    -- "Velen's Future Sight" 144258
    {{"macro"}, 'player.hasTrinket(1) == 144258 and player.useTrinket(1) and heal.countLossInRange(0.78) > 2' , "/use 14" },
    
    -- "Surge Of Light"
    {{"nested"}, 'player.hasBuff(spells.surgeOfLight)' , {
        {spells.flashHeal, 'player.buffStacks(spells.surgeOfLight) == 2' , kps.heal.lowestInRaid},
        {spells.flashHeal, 'heal.lowestInRaid.hp < 0.72' , kps.heal.lowestInRaid},
        {spells.flashHeal, 'player.myBuffDuration(spells.surgeOfLight) < 4' , kps.heal.lowestInRaid},
    }},

    -- "Holy Word: Serenity"
    {spells.holyWordSerenity, 'player.hp < 0.50' , "player"},
    {spells.holyWordSerenity, 'heal.defaultTank.hp < 0.50' , kps.heal.defaultTank},
    {spells.holyWordSerenity, 'heal.lowestTankInRaid.hp < 0.50' , kps.heal.lowestTankInRaid},
    {spells.holyWordSerenity, 'heal.lowestTargetInRaid.hp < 0.50' , kps.heal.lowestTargetInRaid},
    {spells.holyWordSerenity, 'heal.lowestInRaid.hp < 0.50' , kps.heal.lowestInRaid},

    -- kps.lastCast["name"] ne fonctionne pas si lastCast etait une macro 'kps.lastCast["name"] == spells.prayerOfMending' or 'spells.prayerOfMending.lastCasted(4)'
    {spells.flashHeal, 'not player.isMoving and spells.prayerOfMending.lastCasted(4) and heal.lowestInRaid.hp < 0.40' , kps.heal.lowestInRaid ,"FLASH_POM" },    
    {spells.prayerOfMending, 'not player.isMoving and heal.lowestInRaid.hp > 0.85' , kps.heal.hasNotBuffMending , "POM" },
    {spells.prayerOfHealing, 'not player.isMoving and heal.countLossInRange(0.78) > 2 and player.hasBuff(spells.divinity) and player.hasBuff(spells.everlastingHope)' , kps.heal.lowestInRaid , "POH_divinity_everlastingHope" },
    {{spells.holyWordSerenity,spells.prayerOfHealing}, 'not player.isMoving and heal.countLossInRange(0.78) > 2 and heal.lowestInRaid.hp < 0.55 and spells.holyWordSerenity.cooldown == 0' , kps.heal.lowestInRaid , "POH_holyWordSerenity" },

    {{"nested"}, 'not player.isMoving and player.hasBuff(spells.divinity)' , {
        {spells.flashHeal, 'heal.defaultTank.hp < 0.55' , kps.heal.defaultTank, "FLASH_defaultTank" },
        {spells.flashHeal, 'heal.defaultTarget.hp < 0.40' , kps.heal.defaultTarget ,"FLASH_defaultTarget" },
        {spells.bindingHeal, 'not heal.lowestInRaid.isUnit("player")' , kps.heal.lowestInRaid ,"BINDING_BUFF_divinity" },
        {spells.bindingHeal, 'not heal.lowestTankInRaid.isUnit("player")' , kps.heal.lowestTankInRaid ,"BINDING_BUFF_divinity" },
    }},

    -- "Exaucements" "Answered Prayers" -- Prayer of Healing increases the healing done by your next Flash Heal, Binding Heal or Heal by 60%
    {{"nested"}, 'not player.isMoving and player.hasBuff(spells.answeredPrayers)' , {
        {spells.flashHeal, 'heal.defaultTank.hp < 0.55' , kps.heal.defaultTank, "FLASH_defaultTank" },
        {spells.flashHeal, 'heal.defaultTarget.hp < 0.40' , kps.heal.defaultTarget ,"FLASH_defaultTarget" },
        {spells.bindingHeal, 'not heal.lowestInRaid.isUnit("player")' , kps.heal.lowestInRaid ,"BINDING_BUFF_answeredPrayers" },
        {spells.bindingHeal, 'not heal.lowestTankInRaid.isUnit("player")' , kps.heal.lowestTankInRaid ,"BINDING_BUFF_answeredPrayers" },
    }},

    -- "Light of T'uure" 208065 -- increasing your healing done to the target by 25% for 10 sec.
    {{"nested"}, 'not player.isMoving and spells.lightOfTuure.cooldown == 0' , {
        {{spells.lightOfTuure,spells.flashHeal}, 'player.hp < 0.65' , "player"},
        {{spells.lightOfTuure,spells.flashHeal}, 'heal.defaultTank.hp < 0.65 and not heal.defaultTank.hasBuff(spells.lightOfTuure)' , kps.heal.defaultTank },
        {{spells.lightOfTuure,spells.flashHeal}, 'heal.lowestTargetInRaid.hp < 0.65 and not heal.lowestTargetInRaid.hasBuff(spells.lightOfTuure)' , kps.heal.lowestTargetInRaid },
        {spells.lightOfTuure, 'heal.lowestTankInRaid.hp < 0.90 and not heal.lowestTankInRaid.hasBuff(spells.lightOfTuure)' , kps.heal.lowestTankInRaid},
        {spells.lightOfTuure, 'heal.lowestTargetInRaid.hp < 0.90 and not heal.lowestTargetInRaid.hasBuff(spells.lightOfTuure)' , kps.heal.lowestTargetInRaid},
    }},

    -- "Prayer of Mending" (Tank only)
    {spells.prayerOfMending, 'not player.isMoving and not heal.lowestTankInRaid.hasBuff(spells.prayerOfMending)' , kps.heal.lowestTankInRaid },
    {spells.prayerOfMending, 'not player.isMoving and not heal.lowestTargetInRaid.hasBuff(spells.prayerOfMending)' , kps.heal.lowestTargetInRaid },

    -- "Holy Word: Sanctify" -- macro does not work for @target, @mouseover... ONLY @cursor and @player
    {{"macro"},'spells.holyWordSanctify.cooldown == 0 and heal.countLossInDistance(0.78,10) > countFriend()' , "/cast [@player] "..HolyWordSanctify },
    -- "Espoir impérissable" "Everlasting Hope" -- increase the healing amount of your next Prayer of Healing spell by 30%.
    {{"nested"}, 'not player.isMoving and heal.countLossInRange(0.78) > 2 and player.hasBuff(spells.everlastingHope)' ,{
        {{spells.holyWordSerenity,spells.prayerOfHealing}, 'heal.lowestInRaid.hp < 0.55 and spells.holyWordSerenity.cooldown == 0' , kps.heal.lowestInRaid , "POH_holyWordSerenity" },
        {spells.prayerOfHealing, 'player.hasBuff(spells.divinity)' , kps.heal.lowestInRaid , "POH_divinity" },
        {spells.prayerOfHealing, 'player.hasBuff(spells.powerOfTheNaaru)' , kps.heal.lowestInRaid , "POH_powerOfTheNaaru" },
        {{spells.holyWordSanctify,spells.prayerOfHealing}, 'heal.countLossInRange(0.78) > countFriend() and spells.holyWordSanctify.cooldown == 0' , kps.heal.lowestInRaid , "POH_holyWordSanctify" },
    }},
    
--    {spells.heal, 'target.isElite and targettarget.isFriend and target.isCasting and targettarget.hp > 0.85' , "targettarget" },
--    {spells.flashHeal, 'target.isElite and targettarget.isFriend and target.isCasting and targettarget.hp < 0.55' , "targettarget" },
--    {spells.bindingHeal, 'target.isElite and targettarget.isFriend and target.isCasting' , "targettarget" },

    -- "Espoir impérissable" "Everlasting Hope" -- increase the healing amount of your next Prayer of Healing spell by 30%.
--    {{"nested"}, 'not player.isMoving and not player.hasBuff(spells.everlastingHope)' ,{
--        {spells.flashHeal, 'heal.defaultTank.hp < 0.55' , kps.heal.defaultTank, "FLASH_defaultTank" },
--        {spells.flashHeal, 'heal.defaultTarget.hp < 0.40' , kps.heal.defaultTarget ,"FLASH_defaultTarget" },
--        {spells.bindingHeal, 'not heal.lowestInRaid.isUnit("player")' , kps.heal.lowestInRaid ,"BINDING" },
--        {spells.bindingHeal, 'not heal.lowestTankInRaid.isUnit("player")' , kps.heal.lowestTankInRaid ,"BINDING" },
--    }},
    
    -- MOUSEOVER
    {spells.guardianSpirit, 'kps.mouseOver and mouseover.isFriend and mouseover.hp < 0.30' , "mouseover" },
    {spells.holyWordSerenity, 'kps.mouseOver and not mouseover.immuneHeal and mouseover.isFriend and mouseover.hp < 0.40' , "mouseover" },
    {{"nested"}, 'kps.mouseOver and not player.isMoving and not mouseover.immuneHeal and mouseover.isFriend' , {
        {spells.flashHeal, 'mouseover.hp < 0.40' , "mouseover" },
        {spells.bindingHeal, 'not mouseover.isUnit("player") and heal.countLossInRange(0.85) > 2' , "mouseover" },
        {spells.bindingHeal, 'not mouseover.isUnit("player") and mouseover.hp < 0.85' , "mouseover" },
        {spells.bindingHeal, 'not mouseover.isUnit("player") and mouseover.hasBossDebuff' , "mouseover" },
        {spells.bindingHeal, 'not mouseover.isUnit("player") and mouseover.absorptionHeal' , "mouseover" },
        {spells.heal, 'holyWordSerenityOnCD() and heal.lowestInRaid.hp > 0.85' , "mouseover" },
    }},

    -- "Dispel" "Purifier" 527
    {spells.purify, 'kps.mouseOver and mouseover.isFriend and mouseover.isDispellable("Magic")' , "mouseover" },
    {{"nested"},'kps.cooldowns', {
        {spells.purify, 'player.isDispellable("Magic")' , "player" },
        {spells.purify, 'heal.lowestTankInRaid.isDispellable("Magic")' , kps.heal.lowestTankInRaid},
        {spells.purify, 'heal.lowestTargetInRaid.isDispellable("Magic")' , kps.heal.lowestTargetInRaid},
        {spells.purify, 'heal.lowestInRaid.isDispellable("Magic")' , kps.heal.lowestInRaid},
        {spells.purify, 'heal.isMagicDispellable ~= nil' , kps.heal.isMagicDispellable },
    }},

    -- "Dissipation de la magie" -- Dissipe la magie sur la cible ennemie, supprimant ainsi 1 effet magique bénéfique.
    {spells.dispelMagic, 'target.isAttackable and target.isBuffDispellable("Magic")' , "target" },
    {spells.dispelMagic, 'mouseover.isAttackable and mouseover.isBuffDispellable("Magic")' , "mouseover" },
    -- DAMAGE
    {spells.holyWordChastise, 'target.isAttackable and target.isInterruptable' , "target" },
    {spells.holyWordChastise, 'mouseover.isAttackable and mouseover.isInterruptable' , "mouseover" },
    {spells.holyWordChastise, 'mouseover.isAttackable and mouseover.isCasting' , "mouseover" },
    {{"nested"}, 'kps.multiTarget' , {
        {spells.prayerOfMending, 'not player.isMoving and heal.hasBuffStacks(spells.prayerOfMending) < 5' , kps.heal.hasNotBuffMending },
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

    -- "Prayer of Healing" 596 -- A powerful prayer that heals the target and the 4 nearest allies within 40 yards for (250% of Spell power)
    -- "Holy Word: Sanctify" & "Holy Word:Serenity" your healing is increased by 15% for 6 sec. Buff "Divinity" 197030 -- pas de cumul des 2 buffs
    -- "Holy Word: Sanctify" augmente les soins de Prière de soins de 30% pendant 15 sec. Buff "Puissance des naaru" 196490  
    {{"nested"}, 'not player.isMoving and heal.countLossInRange(0.78) > countFriend()' ,{
        {{spells.flashHeal,spells.prayerOfHealing}, 'player.hasBuff(spells.powerOfTheNaaru) and heal.lowestInRaid.hp < 0.55' , kps.heal.lowestInRaid  , "POH_BUFF" },
        {{spells.bindingHeal,spells.prayerOfHealing}, 'player.hasBuff(spells.powerOfTheNaaru) and not heal.lowestInRaid.isUnit("player")' , kps.heal.lowestInRaid  , "POH_BUFF" },
        {{spells.holyWordSanctify,spells.flashHeal,spells.prayerOfHealing}, 'not player.hasBuff(spells.powerOfTheNaaru) and spells.holyWordSanctify.cooldown == 0 and heal.lowestInRaid.hp < 0.55' , kps.heal.lowestInRaid  , "POH_BUFF" },
        {{spells.holyWordSanctify,spells.bindingHeal,spells.prayerOfHealing}, 'not player.hasBuff(spells.powerOfTheNaaru) and spells.holyWordSanctify.cooldown == 0 and not heal.lowestInRaid.isUnit("player")' , kps.heal.lowestInRaid  , "POH_BUFF" },
    }},

    -- "Circle of Healing" 204883
    --{spells.circleOfHealing, 'player.isMoving and heal.countLossInRange(0.78) > 2 and not player.isInRaid' , kps.heal.lowestInRaid},
    --{spells.circleOfHealing, 'player.isMoving and heal.countLossInRange(0.78) > 4 and player.isInRaid' },

    -- "Soins rapides" 2060
    {{"nested"}, 'not player.isMoving and heal.lowestInRaid.hp < 0.72 and not player.isInRaid' ,{
        {spells.flashHeal, 'heal.lowestTankInRaid.hp < 0.72' , kps.heal.lowestTankInRaid , "FLASH_TANK" },
        {spells.flashHeal, 'heal.lowestTargetInRaid.hp < 0.72' , kps.heal.lowestTargetInRaid , "FLASH_TARGET" },
        {spells.flashHeal, 'heal.lowestInRaid.hp < 0.72' , kps.heal.lowestInRaid , "FLASH_LOWEST" },
    }},
    -- Emergency Lowest Important Unit
    {spells.flashHeal, 'not player.isMoving and player.hp < 0.55 and heal.lowestInRaid.isUnit("player")' , "player" , "FLASH_PLAYER_LOWEST" },
    {spells.flashHeal, 'not player.isMoving and heal.lowestTargetInRaid.hp < 0.55 and heal.lowestInRaid.isUnit(heal.lowestTargetInRaid.unit)' , kps.heal.lowestTargetInRaid , "FLASH_TARGET_LOWEST" },
    {spells.flashHeal, 'not player.isMoving and heal.lowestTankInRaid.hp < 0.55 and heal.lowestInRaid.isUnit(heal.lowestTankInRaid.unit)' , kps.heal.lowestTankInRaid , "FLASH_TANK_LOWEST" },
    {spells.flashHeal, 'not player.isMoving and heal.defaultTank.hp < 0.55 and heal.defaultTank.incomingDamage > heal.defaultTank.incomingHeal' , kps.heal.defaultTank, "FLASH_defaultTank" },
    {spells.flashHeal, 'not player.isMoving and heal.defaultTarget.hp < 0.40 and heal.defaultTarget.incomingDamage > heal.defaultTarget.incomingHeal' , kps.heal.defaultTarget, "FLASH_defaultTarget" },
    -- "Soins de lien" 32546
    {spells.bindingHeal, 'not player.isMoving and not heal.lowestInRaid.isUnit("player") and spells.holyWordSanctify.cooldown > 4' , kps.heal.lowestInRaid ,"BINDING_SANCTIFY" },
    {spells.bindingHeal, 'not player.isMoving and not heal.lowestTankInRaid.isUnit("player") and spells.holyWordSanctify.cooldown > 4' , kps.heal.lowestTankInRaid ,"BINDING_SANCTIFY" },
    {spells.bindingHeal, 'not player.isMoving and not heal.lowestInRaid.isUnit("player") and heal.lowestInRaid.hp < 0.85' , kps.heal.lowestInRaid ,"BINDING_LOWEST" },
    {spells.bindingHeal, 'not player.isMoving and not heal.lowestTankInRaid.isUnit("player") and heal.countLossInRange(0.90) > 2' , kps.heal.lowestTankInRaid ,"BINDING_LOWEST" },
    {spells.bindingHeal, 'not player.isMoving and not heal.lowestTankInRaid.isUnit("player") and heal.lowestInRaid.hp < 0.85' , kps.heal.lowestTankInRaid ,"BINDING_LOWEST" },
    {spells.bindingHeal, 'not player.isMoving and not heal.lowestInRaid.isUnit("player") and heal.countLossInRange(0.90) > 2' , kps.heal.lowestInRaid ,"BINDING_LOWEST" },
    
    -- focus is friend
    {{"nested"}, 'focus.exists and focus.isFriend' ,{
        {spells.bindingHeal, 'not player.isMoving and heal.countLossInRange(0.90) > 2' , "focus" },
        {spells.renew, 'not heal.lowestInRaid.hasBuff(spells.renew)' , "focus" },
        {spells.heal, 'not player.isMoving and not heal.lowestInRaid.isUnit("player") and focus.hp < 0.90' , "focus" },
    }},
    
    -- "Soins" 2060 -- "Renouveau constant" 200153
    {spells.heal, 'not player.isMoving and player.hp < 0.90' , "player" },
    {spells.heal, 'not player.isMoving and heal.lowestTankInRaid.hp < 0.90' , kps.heal.lowestTankInRaid },
    {spells.heal, 'not player.isMoving and holyWordSerenityOnCD()' , kps.heal.lowestInRaid },
    {spells.bindingHeal, 'not player.isMoving and not heal.lowestInRaid.isUnit("player") and heal.lossHealthRaid > heal.incomingHealRaid' , kps.heal.lowestInRaid },
    {spells.bindingHeal, 'not player.isMoving and not heal.lowestTankInRaid.isUnit("player") and heal.lossHealthRaid > heal.incomingHealRaid' , kps.heal.lowestTankInRaid },

    -- "Renew" 139 PARTY
    {spells.renew, 'not player.isInRaid and heal.lowestInRaid.hp < 0.90 and not heal.lowestInRaid.hasBuff(spells.renew) and not heal.lowestInRaid.hasBuff(spells.masteryEchoOfLight)' , kps.heal.lowestInRaid, "RENEW_PARTY" },
    {spells.renew, 'player.isMoving and heal.lowestTankInRaid.hp < 0.55 and not heal.lowestTankInRaid.hasBuff(spells.renew) and not heal.lowestTankInRaid.hasBuff(spells.masteryEchoOfLight)' , kps.heal.lowestTankInRaid, "RENEW_TANK" },
    {spells.renew, 'player.isMoving and heal.lowestInRaid.hp < 0.55 and not heal.lowestInRaid.hasBuff(spells.renew) and not heal.lowestInRaid.hasBuff(spells.masteryEchoOfLight)' , kps.heal.lowestInRaid, "RENEW_LOWEST" },
    {spells.renew, 'player.isMoving and player.hp < 0.90 and not player.hasBuff(spells.renew) and not player.hasBuff(spells.masteryEchoOfLight)' , "player" },
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


