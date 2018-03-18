--[[[
@module Priest Discipline Rotation
@generated_from priest_discipline_dmg.simc
@version 7.0.3
]]--

local spells = kps.spells.priest
local env = kps.env.priest

local MassDispel = spells.massDispel.name
local AngelicFeather = spells.angelicFeather.name
local Barriere = spells.powerWordBarrier.name

-- kps.interrupt for painSuppression
-- kps.cooldowns for dispel
-- kps.multiTarget for smite endless
-- kps.defensive for mouseover

kps.runAtEnd(function()
   kps.gui.addCustomToggle("PRIEST","DISCIPLINE", "smite", "Interface\\Icons\\spell_holy_holysmite", "smite")
end)

kps.runAtEnd(function()
   kps.gui.addCustomToggle("PRIEST","DISCIPLINE", "mouseOver", "Interface\\Icons\\priest_spell_leapoffaith_a", "mouseOver")
end)


kps.rotations.register("PRIEST","DISCIPLINE",{

    {{"macro"}, 'not target.exists and mouseover.isAttackable and mouseover.inCombat' , "/target mouseover" },
    
    -- "Dissipation de masse" 32375
    {{"macro"}, 'keys.ctrl', "/cast [@cursor] "..MassDispel },
    -- "Power Word: Barrier" 62618
    {{"macro"}, 'keys.shift', "/cast [@cursor] "..Barriere },

    -- "Fade" 586 "Disparition"
    {spells.fade, 'player.isTarget' },
    {spells.shiningForce, 'player.isTarget and target.distance < 10' , "player" },
    -- "Pierre de soins" 5512
    {{"macro"}, 'player.useItem(5512) and player.hp < 0.90' ,"/use item:5512" },
    -- "Prière du désespoir" 19236 "Desperate Prayer"
    {spells.desperatePrayer, 'player.hp < 0.72' , "player" },
    -- "Don des naaru" 59544
    {spells.giftOfTheNaaru, 'player.hp < 0.72' , "player" },
    -- "Angelic Feather"
    {{"macro"},'player.hasTalent(2,1) and player.isMovingFor(1.2) and spells.angelicFeather.cooldown == 0 and not player.hasBuff(spells.angelicFeather)' , "/cast [@player] "..AngelicFeather },
    -- "Body and Mind"
    {spells.bodyAndMind, 'player.hasTalent(2,2) and player.isMovingFor(1.2) and not player.hasBuff(spells.bodyAndMind)' , "player"},
    -- "Leap Of Faith"
    --{spells.leapOfFaith, 'not heal.lowestInRaid.isUnit("player") and heal.lowestInRaid.hp < 0.20 and heal.lowestInRaid.isDamagerInRaid' , kps.heal.lowestInRaid },
    
    {{"nested"}, 'kps.interrupt' ,{
        {spells.painSuppression, 'heal.aggroTankTarget.hp < 0.30' , kps.heal.aggroTankTarget },
        {spells.painSuppression, 'heal.lowestTankInRaid.hp < 0.30' , kps.heal.lowestTankInRaid },
        {spells.painSuppression, 'focus.isFriend and focus.hp < 0.30' , "focus" },
        {spells.painSuppression, 'player.hp < 0.30' , "player" },
        {spells.painSuppression, 'heal.lowestInRaid.hp < 0.30' , kps.heal.lowestInRaid },  
    }},
    
    -- "Dispel" "Purifier" 527
    {{"nested"},'kps.cooldowns', {
        {spells.purify, 'player.isDispellable("Magic")' , "player" },
        {spells.purify, 'mouseover.isFriend and mouseover.isDispellable("Magic")' , "mouseover" },
        {spells.purify, 'focus.isFriend and focus.isDispellable("Magic")' , "focus"},
        {spells.purify, 'heal.lowestTankInRaid.isDispellable("Magic")' , kps.heal.lowestTankInRaid},
        {spells.purify, 'heal.lowestInRaid.isDispellable("Magic")' , kps.heal.lowestInRaid},
        {spells.purify, 'heal.aggroTankTarget.isDispellable("Magic")' , kps.heal.aggroTankTarget},
        {spells.purify, 'heal.isMagicDispellable ~= nil' , kps.heal.isMagicDispellable , "DISPEL" },
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
    -- "Purge the Wicked" Spreads to an additional nearby enemy when you cast Penance on the target.
    {spells.purgeTheWicked, 'heal.hasBuffCount(spells.atonement) > 0 and target.isAttackable and not target.hasMyDebuff(spells.purgeTheWicked) and not spells.purgeTheWicked.isRecastAt("target")' , "target" },
    {spells.purgeTheWicked, 'heal.hasBuffCount(spells.atonement) > 0 and mouseover.isAttackable and mouseover.inCombat and not mouseover.hasMyDebuff(spells.purgeTheWicked) and not spells.purgeTheWicked.isRecastAt("mouseover")' , 'mouseover' },

    -- NOT ISINGROUP
    {{"nested"}, 'kps.multiTarget and not player.isInGroup' , {
        {spells.powerWordSolace, 'player.hasTalent(4,1) and target.isAttackable' , "target" },
        {spells.powerWordShield, 'not player.hasBuff(spells.powerWordShield)' , "player" },
        {spells.plea, 'not player.hasBuff(spells.atonement)' , "player" },
        {spells.schism, 'player.hasTalent(1,3) and player.myBuffDuration(spells.atonement) > 2 and target.isAttackable' , "target" },
        {spells.penance, 'player.myBuffDuration(spells.atonement) > 2 and target.isAttackable' , "target" },
        {spells.mindbender, 'player.hasTalent(4,3) and target.isAttackable' , "target" },
        {spells.shadowfiend, 'not player.hasTalent(4,3) and target.isAttackable' , "target" },
        {spells.lightsWrath, 'not player.isMoving and player.myBuffDuration(spells.atonement) > 2 and target.isAttackable' , "target" },
        {spells.shadowMend, 'not player.isMoving and player.hp < 0.40 and not spells.shadowMend.isRecastAt("player")' , "player" },  
        {spells.smite,'not player.isMoving and target.isAttackable' , "target" },
    }},

    -- SCHIELD
    {spells.powerWordShield, 'mouseover.immuneHeal and not mouseover.hasBuff(spells.powerWordShield)' , "mouseover" },  
    {spells.powerWordShield, 'not heal.aggroTankTarget.hasBuff(spells.powerWordShield)' , kps.heal.aggroTankTarget },  
    {spells.powerWordShield, 'not heal.lowestTankInRaid.hasBuff(spells.powerWordShield)' , kps.heal.lowestTankInRaid },
    {spells.powerWordShield, 'not player.hasBuff(spells.powerWordShield) and player.hp < 0.82' , "player" },
    {spells.powerWordShield, 'not heal.lowestInRaid.hasBuff(spells.powerWordShield) and heal.lowestInRaid.hp < 0.82' , kps.heal.lowestInRaid },
    {spells.powerWordShield, 'not heal.hasNotBuffAtonement.hasBuff(spells.powerWordShield) and heal.hasNotBuffAtonement.hp < 0.82' , kps.heal.hasNotBuffAtonement },

    {{"nested"}, 'player.hasBuff(spells.rapture)' , {
       {spells.powerWordShield, 'mouseover.immuneHeal and not mouseover.hasBuff(spells.powerWordShield)' , "mouseover" }, 
       {spells.powerWordShield, 'not heal.aggroTankTarget.hasBuff(spells.powerWordShield)' , kps.heal.aggroTankTarget }, 
       {spells.powerWordShield, 'not heal.lowestTankInRaid.hasBuff(spells.powerWordShield)' , kps.heal.lowestTankInRaid },
       {spells.powerWordShield, 'not player.hasBuff(spells.powerWordShield)' , "player" },
       {spells.powerWordShield, 'not heal.lowestInRaid.hasBuff(spells.powerWordShield)' , kps.heal.lowestInRaid },
       {spells.powerWordShield, 'not heal.hasNotBuffAtonement.hasBuff(spells.powerWordShield)' , kps.heal.hasNotBuffAtonement },
    }},
    
    -- IMMUNE HEAL
    {spells.clarityOfWill, 'player.hasTalent(5,2) and not player.isMoving and mouseover.immuneHeal and not mouseover.hasBuff(spells.clarityOfWill)' , "mouseover" },
    
    -- GROUPHEAL
    {spells.penance, 'heal.hasBuffCount(spells.atonement) > Threshold() and heal.countLossInRange(0.82) > Threshold() and target.isAttackable' , "target" },
    {spells.mindbender, 'player.hasTalent(4,3) and heal.hasBuffCount(spells.atonement) > Threshold() and heal.countLossInRange(0.82) > Threshold() and target.isAttackable' , "target" },
    {spells.shadowfiend, 'not player.hasTalent(4,3) and heal.hasBuffCount(spells.atonement) > Threshold() and heal.countLossInRange(0.82) > Threshold() and target.isAttackable' , "target" },
    {spells.powerWordRadiance, 'not player.isMoving and heal.hasBuffCount(spells.atonement) < heal.countLossInRange(0.82) and heal.countLossInRange(0.82) > Threshold()' , kps.heal.hasNotBuffAtonement },
    {spells.powerWordRadiance, 'not player.isMoving and heal.hasBuffCount(spells.atonement) < heal.countLossInRange(0.82) and heal.countLossInRange(0.82) > Threshold()' , "player" },
    {spells.evangelism, 'player.hasTalent(7,3) and spells.powerWordRadiance.lastCasted(4)' },
    {spells.lightsWrath, 'not player.isMoving and spells.powerWordRadiance.charges < 2 and heal.countLossInRange(0.82) > Threshold() and target.isAttackable' , "target" },
    
    -- MOUSEOVER
    {{"nested"}, 'kps.mouseOver and mouseover.isFriend' , {
        {spells.powerWordRadiance, 'not player.isMoving and heal.hasBuffCount(spells.atonement) < heal.countLossInRange(0.82) and heal.countLossInRange(0.82) > Threshold() and not mouseover.hasBuff(spells.atonement)' , "mouseover" },
        {spells.lightsWrath, 'not player.isMoving and spells.powerWordRadiance.charges < 2 and heal.countLossInRange(0.82) > Threshold() and mouseover.hasBuff(spells.atonement) and mouseovertarget.isAttackable' , "mouseovertarget" },
        {spells.painSuppression, 'mouseover.hp < 0.30' , "mouseover" },
        {spells.powerWordShield, 'mouseover.hp < 0.82 and not mouseover.hasBuff(spells.powerWordShield)' , "mouseover" },
        {spells.penance, 'mouseover.hp < 0.82 and mouseover.hasBuff(spells.atonement) and mouseovertarget.isAttackable' , "mouseovertarget" },
        {spells.clarityOfWill, 'player.hasTalent(5,2) and not player.isMoving and mouseover.hp < 0.55 and not mouseover.hasBuff(spells.clarityOfWill)' , "mouseover" },
        {spells.smite, 'mouseover.hasBuff(spells.atonement) and not player.isMoving and mouseovertarget.isAttackable' , "mouseovertarget" },
        {spells.plea, 'not mouseover.hasBuff(spells.atonement) and mouseover.hp < 0.82' , "mouseover" },
        {spells.shadowMend, 'not player.isMoving and mouseover.hp < 0.40 and not spells.shadowMend.isRecastAt("mouseover")' , "mouseover" },
    }},

   -- "Schisme" augmente les dégâts que vous lui infligez de 30% pendant 6 sec.
    {spells.schism, 'not player.isMoving and player.hasTalent(1,3) and heal.hasBuffLowestHealth(spells.atonement) < 0.82 and target.isAttackable' , "target" },
    {spells.penance, 'heal.hasBuffLowestHealth(spells.atonement) < 0.82 and target.isAttackable' , "target" , "penance_lowest" },
    -- "Borrowed Time" "Sursis"  -- Applying Atonement to a target reduces the cast time of your next Smite or Light's Wrath by 5%, or causes your next Penance to channel 5% faster
    {spells.smite, 'not player.isMoving and heal.hasNotBuffAtonement.hp > 0.82 and heal.hasBuffCount(spells.atonement) > 0 and heal.countLossInRange(1) > 0 and target.isAttackable' , "target" , "smite_count" },
    {spells.smite, 'kps.smite and not player.isMoving and heal.hasNotBuffAtonement.hp > 0.82 and heal.hasBuffCount(spells.atonement) > 0 and target.isAttackable' , "target" , "smite_aggro" },

    {spells.plea, 'heal.hasNotBuffAtonement.hp < 0.82' , kps.heal.hasNotBuffAtonement , "plea_lowest_unbuff" },
    {spells.shadowMend, 'not player.isMoving and heal.aggroTankTarget.hp < 0.40 and not spells.shadowMend.isRecastAt(heal.aggroTankTarget.unit)' , kps.heal.aggroTankTarget },
    {spells.shadowMend, 'not player.isMoving and heal.lowestTankInRaid.hp < 0.40 and not spells.shadowMend.isRecastAt(heal.lowestTankInRaid.unit)' , kps.heal.lowestTankInRaid },
    {spells.shadowMend, 'not player.isMoving and not player.isInRaid and heal.lowestInRaid.hp < 0.40 and not spells.shadowMend.isRecastAt(heal.lowestInRaid.unit)' , kps.heal.lowestInRaid },

}
,"priest_discipline")
