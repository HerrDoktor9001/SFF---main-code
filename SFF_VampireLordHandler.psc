scriptName SFF_VampireLordHandler extends ReferenceAlias
{Script for handling main Vampire Lord tranformation code}
import PO3_SKSEFunctions

;-- Properties --------------------------------------
globalvariable property iVLAmount_MCM_SFF auto
spell property DLC1VampireDrain08 auto
spell property DLC1VampireDrain06 auto
globalvariable property bVL_TransformMasterKey auto
faction property DragonPriestFaction auto
globalvariable property bVL_TransformNumber auto
spell property DLC1VampireDrain09 auto
alias property SeranaAlias auto
globalvariable property SFF_MCM_AllowVL auto
keyword property ActorTypeGiant auto
spell property DLC1VampireDrain05 auto
keyword property ActorTypeDLC1Boss auto
globalvariable property iVLLevel_MCM_SFF auto
spell property DLC1VampireDrain07 auto
globalvariable property SFF_MCM_VL_Amount auto
globalvariable property bVL_TransformBoss auto
globalvariable property bVL_TransformLevel auto
globalvariable property SFF_MCM_VL_Boss auto
keyword property ActorTypeDragon auto
globalvariable property SFF_MCM_VL_Dragon auto
globalvariable property bVL_TransformDragon auto
globalvariable property SFF_MCM_VL_Health auto
globalvariable property SFF_MCM_VL_Level auto
globalvariable property bVL_TransformHealth auto
globalvariable property SFF_MCM_VL_Giant auto
globalvariable property iVLHealth_MCM_SFF auto
globalvariable property bVL_TransformGiant auto
Float property fUpdateInterval auto
sff_mentalmodelextender property MME auto

;;Quests
Quest Property DLC1VQ03Hunter auto	;; 'Prophet' quest, Dawnguard
Quest Property DLC1VQ03Vampire auto	;; 'Prophet' quest, Vampire


;-- Variables ---------------------------------------
Actor Serana
Bool bAlreadyTransformedOnce
Actor[] myTargets
Race DLC1VampireBeastRace

;-- Functions ---------------------------------------
Bool Function bIsVL()

	if Serana.GetRace() == DLC1VampireBeastRace
		return true
	endif
	
	return false
endFunction

Bool Function bIsQuestComplete()	;;	Checks if the 'Prophet' quest has started, which is where wardrobe functions should be enabled
	if MME.bIsQuestComplete()
		return true
	else
		return false
	endif
EndFunction

Bool function bVLBossTransform(Actor myTarget)

	if myTarget.HasKeyword(ActorTypeDLC1Boss) || myTarget.IsInFaction(DragonPriestFaction)
		return true
	else
		return false
	endIf
endFunction

function OnInit()
	SetUp()
endFunction

Function SetUp()
	FillProperties()
	EstablishLeveledSpells()
	po3_events_alias.RegisterForLevelIncrease(SeranaAlias)
EndFunction

;;/////////////////////////////////////////////////////////////////////////////////
;; called from 'sff_vl_condition_listener' MagicEffect script
Function EnableChecks()
	ClearFlag()	;; to catch any instance of flag remaining and leading to undue transformation on combat start.
	RegisterForSingleUpdate(1.5)
	debug.trace("[SFF_VL]: VL transformation conditions monitor enabled.")
EndFunction

Function DisableChecks()
	UnregisterForUpdate()
	ClearFlag() ;; flag not always cleared on Race switch. Also do it here, to make sure no undue transformation happens due to leftover flags.
	debug.trace("[SFF_VL]: VL transformation conditions monitor disabled.")
EndFunction
;; ////////////////////////////////////////////////////////////////////////////////

function FillProperties()

	Serana = self.GetActorReference()
	DLC1VampireBeastRace = game.GetFormFromFile(33564730, "Dawnguard.esm") as Race
	MME.DLC1VampireBeastRace = game.GetFormFromFile(33564730, "Dawnguard.esm") as Race
	fUpdateInterval = 5.00000
endFunction

function OnLevelIncrease(Int aiLevel)

	EstablishLeveledSpells()
	debug.Trace("Serana increased level:" + Serana.GetLevel() as String)
endFunction

function EstablishLeveledSpells()

	if SFF_MCM_AllowVL.GetValue() != 1 
		
		return
	endIf
	
	if MME.bCured
		
		return
	endIf
	
	Int seranaLevel = Serana.GetLevel()
	if seranaLevel <= 10
		MME.LeveledDrainSpell = DLC1VampireDrain05
	elseIf seranaLevel <= 20
		MME.LeveledDrainSpell = DLC1VampireDrain06
	elseIf seranaLevel <= 30
		MME.LeveledDrainSpell = DLC1VampireDrain07
	elseIf seranaLevel <= 40
		MME.LeveledDrainSpell = DLC1VampireDrain08
	else
		MME.LeveledDrainSpell = DLC1VampireDrain09
	endIf
	Debug.Trace("[SFF_VL]: Serana's VL spells adjusted to her current level.")
endFunction

;; will get called on: combat stop, VL blocker effect, VL race transform., human race transform
function ClearFlag()
	bAlreadyTransformedOnce = false
	bVL_TransformNumber.SetValue(0 as Float)
	bVL_TransformLevel.SetValue(0 as Float)
	bVL_TransformHealth.SetValue(0 as Float)
	bVL_TransformDragon.SetValue(0 as Float)
	bVL_TransformGiant.SetValue(0 as Float)
	bVL_TransformBoss.SetValue(0 as Float)
	MME.bBusyTransforming = false			;; if this hangs, for whatever reason, it'll permanently block VL transformation!
	debug.Trace("[SFF_VL]: flags cleared.")
endFunction

function OnRaceSwitchComplete()
	if bIsVL()
		debug.Notification("Serana transformed.")
		
		utility.wait(0.5)
		MME.SpellManager(0)
	
	else
		debug.Notification("Serana back to human.")
		ClearFlag()	;; sff v1.6.0 - this doesn't always get called... For redundancy, also force it on combat end
		MME.SpellManager(1)
		;MME.ForceEquipPostTransform(0.150000)

		if MME.bWeaponDrawPatch
			MME.DrawWeaponManager(0)	;; SFF v1.4.2 ~ re-reset teammate weapon draw disabler if transforming back2human
		endIf
	endIf
endFunction



Event OnUpdate()
	VLConditionChecker()
	RegisterForSingleUpdate(1.5)	;; loop code
EndEvent

Function VLConditionChecker()
	;; sff v1.8.0 - stop transformation if Serana cured!
	if MME.bIsCured()
		
		return
	endIf
	
	if bIsVL()
		debug.trace("[SFF_VL]: Serana already in VL form. No need to re-check transform. conditions.")
		return
	else
		;bAlreadyTransformedOnce= false	;; if flag set but transformation not consolidated, reset it
	endIf
	
	if bAlreadyTransformedOnce
		debug.trace("[SFF_VL]: Serana already transformed. Should not transform again. Flag should be cleared once transformation ends. This entry should not show up if she is back2human. Aborting code...")
		return
	endIf

	if Serana.IsBleedingOut() 
		debug.trace("[SFF_VL]: Serana bleeding out. Should not transform. Blocking code...")
		utility.wait(0.5)
		Serana.DamageActorValue("Health", (Serana.GetActorValue("Health")/Serana.GetActorValuePercentage("Health") * 1.0) + 1)	;; sucessfully forced Serana to stay in bleed mode after transformation due to low health!
		;bAlreadyTransformedOnce= true
		return
	endIf
	
	if !bIsQuestComplete()
		debug.trace("[SFF_VL]: Prophet quest not yet started. Serana not full follower yet. Should not transform...")
		return
	endIf
	
	Actor myTarget
	
	if SFF_MCM_VL_Health.GetValue() == 1 as Float

		if Serana.GetActorValuePercentage("health") * 100 as Float < iVLHealth_MCM_SFF.GetValue()
			debug.Notification("Serana's health low. Transforming...")
			debug.Trace("SFF: Serana's health low. Transforming...")
			bVL_TransformHealth.SetValue(1 as Float)
			bAlreadyTransformedOnce = true
			return
		endIf
	else
		bVL_TransformHealth.SetValue(0 as Float)
	endIf
	
	if SFF_MCM_VL_Amount.GetValue() == 1 as Float
		
		myTargets = GetCombatTargets(Serana)
	
		if myTargets.length as Float >= iVLAmount_MCM_SFF.GetValue()
			debug.Notification("Too many enemies. Transforming...")
			debug.Trace("SFF: Too many enemies. Transforming...")
			bVL_TransformNumber.SetValue(1 as Float)
			bAlreadyTransformedOnce = true
			return
		endIf
	else
		bVL_TransformNumber.SetValue(0 as Float)
	endIf
	
	if SFF_MCM_VL_Level.GetValue() == 1 as Float
	
		myTargets = GetCombatTargets(Serana)	;; sff v2.0.0 - this conditional was not filling 'myTargets' var!
		
		Int index
		Int arraySize = myTargets.length
		if arraySize > 0
			while index < arraySize && !self.bIsVL() && !bAlreadyTransformedOnce
				if myTargets[index].GetLevel() as Float > iVLLevel_MCM_SFF.GetValue()
					debug.Notification("Enemy too strong. Transforming...")
					debug.Trace("SFF: Enemy too strong. Transforming...")
					bVL_TransformLevel.SetValue(1 as Float)
					bAlreadyTransformedOnce = true
					return
				else
					index += 1
				endIf
			endWhile
		else
			index = 0
		endIf
	else
		bVL_TransformLevel.SetValue(0 as Float)
	endIf
	
	;;sff v2.0.0 - reduce redundant code: check for null target only once, instead of for each condition...
	myTarget = Serana.GetCombatTarget()
	if myTarget == none
		debug.trace("SFF: [VL] Serana supposedly in combat but no target found. Aborting code...")
		return
	endIf
	
	if SFF_MCM_VL_Dragon.GetValue() == 1 as Float
		;myTarget = Serana.GetCombatTarget()
		;if myTarget != none
			if myTarget.HasKeyword(ActorTypeDragon)
				debug.Notification("Serana fighting dragon. Transforming...")
				debug.Trace("SFF: Serana fighting dragon. Transforming...")
				bVL_TransformDragon.SetValue(1 as Float)
				bAlreadyTransformedOnce = true
				return
			endIf
		;endIf
	else
		bVL_TransformDragon.SetValue(0 as Float)
	endIf
	
	if SFF_MCM_VL_Giant.GetValue() == 1 as Float
		;myTarget = Serana.GetCombatTarget()
		;if myTarget != none
			if myTarget.HasKeyword(ActorTypeGiant)
				debug.Notification("Serana fighting giant. Transforming...")
				debug.Trace("SFF: Serana fighting giant. Transforming...")
				bVL_TransformGiant.SetValue(1 as Float)
				bAlreadyTransformedOnce = true
				return
			endIf
		;endIf
	else
		bVL_TransformGiant.SetValue(0 as Float)
	endIf
	
	if SFF_MCM_VL_Boss.GetValue() == 1 as Float
		;myTarget = Serana.GetCombatTarget()
		;if myTarget != none
			if self.bVLBossTransform(myTarget)
				debug.Notification("Serana fighting boss. Transforming...")
				debug.Trace("SFF: Serana fighting boss. Transforming...")
				bVL_TransformBoss.SetValue(1 as Float)
				bAlreadyTransformedOnce = true
				return
			endIf
		;endIf
	else
		bVL_TransformBoss.SetValue(0 as Float)
	endIf
	;debug.trace("[SFF_VL]: None of transform conditions met... Will not transform.")
EndFunction