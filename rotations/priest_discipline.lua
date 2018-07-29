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
   kps.gui.addCustomToggle("PRIEST","DISCIPLINE", "mouseOver", "Interface\\Icons\\priest_spell_leapoffaith_a", "mouseOver")
end)


kps.rotations.register("PRIEST","DISCIPLINE",{

    {{"macro"}, 'not target.isAttackable and mouseover.isAttackable and mouseover.inCombat' , "/target mouseover" },
    {{"macro"}, 'not target.exists and mouseover.isAttackable and mouseover.inCombat' , "/target mouseover" },
    
    -- "Dissipation de masse" 32375
    {{"macro"}, 'keys.ctrl', "/cast [@cursor] "..MassDispel },
    -- "Power Word: Barrier" 62618
    {{"macro"}, 'keys.shift', "/cast [@cursor] "..Barriere },

    -- "Fade" 586 "Disparition"
    {spells.fade, 'player.isTarget' },
    {spells.shiningForce, 'player.isTarget and target.distance < 10' , "player" },
    {spells.psychicScream, 'player.isTarget and spells.shiningForce.cooldown > 0 and target.distance < 10' , "player" },
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
        {spells.painSuppression, 'player.hp < 0.30' , "player" },
        {spells.painSuppression, 'heal.lowestTankInRaid.hp < 0.30' , kps.heal.lowestTankInRaid },
        {spells.painSuppression, 'heal.lowestInRaid.hp < 0.30' , kps.heal.lowestInRaid },
    }},
    
    -- "Dispel" "Purifier" 527
    {{"nested"},'kps.cooldowns', {
        {spells.purify, 'mouseover.isFriend and mouseover.isDispellable("Magic")' , "mouseover" },
        {spells.purify, 'player.isDispellable("Magic")' , "player" },
        {spells.purify, 'heal.lowestTankInRaid.isDispellable("Magic")' , kps.heal.lowestTankInRaid},
        {spells.purify, 'heal.lowestInRaid.isDispellable("Magic")' , kps.heal.lowestInRaid},
        {spells.purify, 'heal.isMagicDispellable ~= nil' , kps.heal.isMagicDispellable , "DISPEL" },
    }},
    -- "Dissipation de la magie" -- Dissipe la magie sur la cible ennemie, supprimant ainsi 1 effet magique bénéfique.
    {spells.dispelMagic, 'target.isAttackable and target.isBuffDispellable' , "target" },
    {spells.dispelMagic, 'mouseover.isAttackable and mouseover.isBuffDispellable' , "mouseover" },
    
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
    {{"macro"}, 'player.hasTrinket(1) == 144258 and player.useTrinket(1) and heal.countLossInRange(0.85) > 2' , "/use 14" },
    {{"macro"}, 'player.hasTrinket(1) == 144258 and player.useTrinket(1) and heal.lowestInRaid.hp < 0.55 ' , "/use 14" },

    -- SCHIELD
    {spells.powerWordShield, 'mouseover.immuneHeal and not mouseover.hasBuff(spells.powerWordShield)' , "mouseover" },
    {spells.powerWordShield, 'not player.hasBuff(spells.powerWordShield) and player.hp < 0.55 and heal.lowestTankInRaid.hp > 0.85' , "player" },
    {spells.powerWordShield, 'not heal.lowestInRaid.hasBuff(spells.powerWordShield) and heal.lowestInRaid.hp < 0.55 and heal.lowestTankInRaid.hp > 0.85' , kps.heal.lowestInRaid },
    {spells.powerWordShield, 'not heal.lowestTankInRaid.hasBuff(spells.powerWordShield)' , kps.heal.lowestTankInRaid },

    -- IMMUNE HEAL
    {spells.clarityOfWill, 'player.hasTalent(5,2) and not player.isMoving and mouseover.immuneHeal and not mouseover.hasBuff(spells.clarityOfWill)' , "mouseover" },
    {spells.clarityOfWill, 'player.hasTalent(5,2) and not player.isMoving and mouseover.isFriend and mouseover.hp < 0.30 and not mouseover.hasBuff(spells.clarityOfWill)' , "mouseover" },

    {{"nested"}, 'not heal.lowestTankInRaid.hasBuff(spells.atonement)' , {
        {spells.powerWordShield, 'not heal.lowestTankInRaid.hasBuff(spells.powerWordShield)' , kps.heal.lowestTankInRaid },
        {spells.plea, 'spells.powerWordShield.cooldown > 0' , kps.heal.lowestTankInRaid },
    }},
    
    -- MOUSEOVER 
    {{"nested"}, 'kps.mouseOver and mouseover.isFriend' , {
        {spells.painSuppression, 'mouseover.hp < 0.30' , "mouseover" },
        {spells.powerWordShield, 'not mouseover.hasBuff(spells.powerWordShield) and mouseover.hp < 0.85' , "mouseover" },
        {spells.penance, 'mouseover.hp < 0.30 and mouseover.hasBuff(spells.atonement)' , "mouseover" },
        {spells.penance, 'mouseover.hp < 0.90 and mouseover.hasBuff(spells.atonement) and mouseovertarget.isAttackable' , "mouseovertarget" },
        {spells.smite, 'not player.isMoving and mouseover.hasBuff(spells.atonement) and mouseovertarget.isAttackable' , "mouseovertarget" },
        {spells.shadowMend, 'not player.isMoving and mouseover.hp < 0.40 and not spells.shadowMend.isRecastAt("mouseover")' , "mouseover" },
        {spells.plea, 'not mouseover.hasBuff(spells.atonement) and mouseover.hp < 0.85' , "mouseover" },
    }},

    -- GROUPHEAL
    {spells.evangelism, 'player.hasTalent(7,3) and spells.powerWordRadiance.lastCasted(4)' },
    {spells.lightsWrath, 'not player.isMoving and heal.hasBuffAtonementCount(0.85) > countFriend() and target.isAttackable' , "target" },
    {spells.lightsWrath, 'not player.isMoving and heal.hasBuffAtonementCount(0.85) > countFriend() and targettarget.isAttackable' , "targettarget" },
    {spells.powerWordRadiance, 'not player.isMoving and heal.hasBuffAtonementCount(0.85) < heal.countLossInRange(0.85) and heal.countLossInRange(0.85) > countFriend()' , kps.heal.hasNotBuffAtonement },
    {spells.penance, 'heal.hasBuffAtonement.hp < 0.90 and target.isAttackable' , "target" },
    {spells.penance, 'heal.hasBuffAtonement.hp < 0.90 and targettarget.isAttackable' , "targettarget" },
    {spells.mindbender, 'player.hasTalent(4,3) and heal.hasBuffAtonement.hp < 0.85 and target.isAttackable' , "target" },    
    {spells.mindbender, 'player.hasTalent(4,3) and heal.hasBuffAtonement.hp < 0.85 and targettarget.isAttackable' , "targettarget" }, 
    {spells.shadowfiend, 'not player.hasTalent(4,3) and heal.hasBuffAtonement.hp < 0.85 and target.isAttackable' , "target" }, 
    {spells.shadowfiend, 'not player.hasTalent(4,3) and heal.hasBuffAtonement.hp < 0.85 and targettarget.isAttackable' , "targettarget" },

    {spells.purgeTheWicked, 'target.isAttackable and not target.hasMyDebuff(spells.purgeTheWicked) and not spells.purgeTheWicked.isRecastAt("target")' , "target" },
    {spells.purgeTheWicked, 'targettarget.isAttackable and not targettarget.hasMyDebuff(spells.purgeTheWicked) and not spells.purgeTheWicked.isRecastAt("targettarget")' , "targettarget" },
    {spells.purgeTheWicked, 'mouseover.isAttackable and mouseover.inCombat and not mouseover.hasMyDebuff(spells.purgeTheWicked) and not spells.purgeTheWicked.isRecastAt("mouseover")' , 'mouseover' },
    -- NOT ISINGROUP
    --{spells.powerWordSolace, 'player.hasTalent(4,1) and target.isAttackable' , "target" },
    --{spells.schism, 'player.hasTalent(1,3) and target.isAttackable' , "target" }, -- 30% increased damage from the Priest. 6 seconds remaining
    {{"nested"}, 'kps.defensive and not player.isInGroup' , {
        {spells.powerWordShield, 'not player.hasBuff(spells.powerWordShield)' , "player" },
        {spells.penance, 'player.hasBuff(spells.atonement) and target.isAttackable' , "target" },
        {spells.lightsWrath, 'not player.isMoving and player.hasBuff(spells.atonement) and target.isAttackable' , "target" },
        {spells.shadowMend, 'not player.isMoving and player.hp < 0.40 and not spells.shadowMend.isRecastAt("player")' , "player" }, 
        {spells.plea, 'not player.hasBuff(spells.atonement)' , "player" },
        {spells.mindbender, 'player.hasTalent(4,3) and target.isAttackable' , "target" },
        {spells.shadowfiend, 'not player.hasTalent(4,3) and target.isAttackable' , "target" },
        {spells.smite,'not player.isMoving and target.isAttackable' , "target" },
    }},

    {spells.shadowMend, 'not player.isMoving and heal.lowestTankInRaid.hp < 0.40 and not spells.shadowMend.isRecastAt(heal.lowestTankInRaid.unit)' , kps.heal.lowestTankInRaid },
    {spells.shadowMend, 'not player.isMoving and player.hp < 0.40 and not spells.shadowMend.isRecastAt("player")' , "player" },    
    -- "Borrowed Time" "Sursis"  -- Applying Atonement to a target reduces the cast time of your next Smite or Light's Wrath by 5%, or causes your next Penance to channel 5% faster
    {{"nested"}, 'not player.hasBuff(spells.borrowedTime)' , {
        {spells.plea, 'not heal.lowestTankInRaid.hasBuff(spells.atonement)' , kps.heal.lowestTankInRaid },
        {spells.plea, 'not player.hasBuff(spells.atonement)' , "player" },
        {spells.plea, 'not heal.hasNotBuffAtonement.hasBuff(spells.atonement) and heal.hasNotBuffAtonement.hp < 0.65' , kps.heal.hasNotBuffAtonement , "ertyui" },
    }},

    -- heal.atonementHealthRaid - Returns the loss Health for all raid members with buff atonement
    {spells.smite, 'not player.isMoving and heal.atonementHealthRaid > 0 and target.isAttackable' , "target" , "smite_count" },
    {spells.smite, 'not player.isMoving and heal.atonementHealthRaid > 0 and targettarget.isAttackable' , "targettarget" , "smite_count" },
    {spells.smite, 'kps.multiTarget and not player.isMoving' , kps.heal.enemyTarget , "enemyTarget" },

}
,"priest_discipline")

-- MACRO --
--[[

#showtooltip Mot de pouvoir : Bouclier
/cast [@mouseover,exists,nodead,help] Mot de pouvoir : Bouclier; [@mouseover,exists,nodead,harm] Châtiment

#showtooltip Pénitence
/cast [@mouseover,exists,nodead,help] Mot de pouvoir : Bouclier; [@mouseover,exists,nodead,harm] Pénitence

]]--