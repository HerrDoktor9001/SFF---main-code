Scriptname DLC1RNPCAliasScript extends ReferenceAlias  

SFF_MentalModelExtender Property MME auto
SFF_SunDamageController Property SDC auto

GlobalVariable Property SFF_MCM_DisableTeammateUnsheath auto	;; v1.4.3

Event OnUpdateGameTime()
	if GetActorRef().GetAV("WaitingforPlayer") == 0
		UnRegisterForUpdateGameTime()
	else
		;Debug.Trace("RNPC: Done waiting...")
		(GetOwningQuest() as DLC1_NPCMentalModelScript).FinishWaiting()
		UnRegisterForUpdateGameTime()
	endif	
EndEvent

Event OnLocationChange(Location akOldLoc, Location akNewLoc)
	GoToState("CheckingOutfit")
	;(GetOwningQuest() as DLC1_NPCMentalModelScript).CheckOutfit()
	(GetOwningQuest() as DLC1_NPCMentalModelScript).PlayerSettled= false	;; SFF v1.2.1: make sure Serana's not sandboxing when moving between cells
	MME.EquipElderScroll()
	utility.wait(2)
	MME.HoodieManager()	;; v1.9.0
	SDC.OutfitProtecChecker()
	ForceSet()	;; v1.4.3
	GoToState("")
EndEvent

State CheckingOutfit
	Event OnLocationChange(Location akOldLoc, Location akNewLoc)
		; do nothing
	EndEvent
EndState

;; sff v1.5.0 - to expose when Player has activated Serana
;; sff v1.5.1 - REMOVED
; Event OnActivate(ObjectReference akActionRef)
	; if akActionRef == Game.GetPlayer()
		;MME.SetSeranaActivationStatus(true)
		;Debug.trace("Player activated Serana!")
	; endif
	; ObjectReference Serana= GetReference()
	; Actor myAct = Serana as Actor
	; if myAct.IsInCombat()
		; debug.trace("Serana supposedly in combat!")
		; debug.notification("Serana supposedly in combat!")
		
		; Actor TargetRef = myAct.GetCombatTarget()
		; if TargetRef == none
			; debug.trace("Serana supposedly in combat but no target.")
			; debug.notification("Serana supposedly in combat but no target.")
		; endif
	; else 
		; debug.trace("Serana NOT in combat.")
		; debug.notification("Serana NOT in combat.")	
	; endif
	; if myAct.IsSneaking()
		; debug.trace("Serana supposedly sneaking...")
		; debug.notification("Serana supposedly sneaking...")
	
	; else
		; debug.trace("Serana NOT sneaking.")
		; debug.notification("Serana NOT sneaking.")	
	; endif
	; if Serana.GetAnimationVariableFloat("Speed") <= 0
		; debug.trace("Serana de facto stuck!")
		; debug.notification("Serana de facto stuck!")
	; else
		; debug.trace("Serana NOT frozen.")
		; debug.notification("Serana NOT frozen.")	
	; endif
	
	; if myAct.GetAnimationVariableInt("iState") ==2
		; debug.trace("Serana playing SNEAK ANIM!")
		; debug.notification("Serana playing SNEAK ANIM!")
	; else
		; debug.trace("Serana NOT playing SNEAK ANIM!")
		; debug.notification("Serana NOT playing SNEAK ANIM!")		
	; endif
;EndEvent

Function ForceSet()	;; v1.4.3 - fix for 'DistanceTeammateDrawWeapon' reseting on cell change.
	if SFF_MCM_DisableTeammateUnsheath.GetValue() == 1
		Game.SetGameSettingFloat("fAIDistanceTeammateDrawWeapon", 0) 		;; do not call function in MME (MME may not have yet loaded)
		Debug.Trace("[DEBUG] [INFO] SFF: SHFWA patch enabled, force-set on cell change.")	
	endif
EndFunction

;; SFF v2.0.1 ~ TESTING: to avoid complex, cumbersome, and costly mechanism for dealing with nudeness bug, let's simply force-set EVERY armour item given to Serana, instead of doing it selectively
;; instead of working with list iteration in 03 different scripts (MME, 'sif_outfitmanager', 'SFF_CombatHelemtHandler'), we centralise all here
Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	
	If (akBaseItem as Armor != None) 			;; If item is Armour,
		GetActorRef().EquipItem(akBaseItem, true)	
		debug.trace("****** *** *** [SFF] [DEBUG]: '" + akBaseItem.GetName() +"' force-quipped...")
	endif
	
endevent


