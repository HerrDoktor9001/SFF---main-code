Scriptname sff_combatfeed_condition_listener extends ActiveMagicEffect  
import PO3_SKSEFunctions

SFF_HungerAndFeedSys Property HnF auto
Idle Property IdleVampireStandingFeedFront_Loose auto
Spell Property SFF_HnF_BlockCombatFeed_spell auto
GlobalVariable Property SFF_HnF_BlockChanceCalc auto


;; checks actor's relative health value
Float Function fCurrentActorHealth(actor target)
	return target.GetActorValuePercentage("Health")
EndFunction

Event OnEffectStart(Actor akTarget, Actor akCaster)
	Actor myTarget = akCaster.GetCombatTarget()									;; get target,
	;Actor myTargetCache
	
	;; PASSO 01 - PLAY ANIMATION
	if myTarget == none
		debug.trace("[ERROR] SFF:: HungerMech.:: Serana set for combat feed but combat target now null!")
		SFF_HnF_BlockChanceCalc.SetValue(0)
		return
	endif
	
	;myTargetCache= myTarget	;; cache cur. target
	if !akCaster.PlayIdleWithTarget(IdleVampireStandingFeedFront_Loose, myTarget)	;; play anim.,
		debug.trace("[ERROR] SFF: Combat Feed anim. did not play.")
		SFF_HnF_BlockChanceCalc.SetValue(0)
		return
	endif
	
	if akCaster.GetCombatTarget() != myTarget ;myTargetCache
		;debug.notification("OH, MY GOD!")
		debug.trace("[ERROR] SFF: Combat Feed animation (apparently) played, but animation target no longer combat target. Abort!")
		return
	endif
	
	
	SFF_HnF_BlockChanceCalc.SetValue(1) ;; STOP 'CHANCE CALCULATOR' FROM RUNNING ('sff_combatfeed_chance_listener' script)
	
	DLC1VampireChangeBackFXS.Play(akCaster, 12.0)	;; set shader effect
	
	;; PASSO 02 - MAKE SERANA INVULNERABLE
	if !akCaster.GetActorBase().IsInvulnerable()					;; make Serana temporarily invulnerable while anim. plays
		akCaster.GetActorBase().SetInvulnerable()
	endif
	
	;; if target dies while anim. playing, anim. might bug out. Make sure any damage added happens AFTER anim. finished
	Utility.wait(3.0) ;; wait for anim. to finish
	
	;; PASSO 03 - DYNAMICALLY REMOVE/ADD HEALTH FROM/TO TARGET/SERANA
	if HnF.iHungerLvl == 0
		HnF.iHungerLvl= 1
		
		;; change hunger lvl ro correspond to damage taken (health lvl)
		if fCurrentActorHealth(akCaster) < 0.75 && fCurrentActorHealth(akCaster) >= 0.60	;; between 60 and 75%
			HnF.iHungerLvl= 1
			
		elseif fCurrentActorHealth(akCaster) < 0.60 && fCurrentActorHealth(akCaster) >= 0.45	;; between 45 and 75%
			HnF.iHungerLvl= 2
			
		elseif fCurrentActorHealth(akCaster) < 0.45	;; less than 45%
			HnF.iHungerLvl= 3
		endif 
	endif
	
	;; take from target's health
	float  fTargetMaxHealth= myTarget.GetBaseActorValue("Health")
	float fHealthDamage= fTargetMaxHealth * (HnF.iHungerLvl as float/4.0)	;; amount of health taken depends on akCaster's hunger lvl
	float fHealthRestore= fHealthDamage/2
	myTarget.DamageActorValue("Health", fHealthDamage as Int)			;; remove from target,
	akCaster.RestoreActorValue("Health", fHealthRestore as Int)			;; add to akCaster, but not 1:1 
	
	;;reset hunger
	HnF.iHungerLvl= 0
	HnF.bIsHungry= false
	HnF.bCanPlayDiag= false
	
	
	;; PASSO 04 - CAST COOLDOWN SPELL
	SFF_HnF_BlockCombatFeed_spell.Cast(akCaster, akCaster)
EndEvent

EffectShader Property DLC1VampireChangeBackFXS Auto
;EffectShader Property DLC1VampireChangeBack02FXS Auto

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	SFF_HnF_BlockChanceCalc.SetValue(0)
	if akCaster.GetActorBase().IsInvulnerable()					;; make Serana temporarily invulnerable while anim. plays
		akCaster.GetActorBase().SetInvulnerable(false)
	endif

    DLC1VampireChangeBackFXS.stop(akCaster)
   ; DLC1VampireChangeBack02FXS.Play(akCaster,0.1)
EndEvent