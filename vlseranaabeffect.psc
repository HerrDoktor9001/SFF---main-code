Scriptname VLSeranaAbEffect extends ActiveMagicEffect  

; Author: Borgut1337

Keyword Property LocTypeHabitation Auto

Actor Property PlayerRef Auto

Ammo Property ElderScrollAmmo auto

MagicEffect Property VLSeranaTransformToNormalMagicEffect Auto
MagicEffect Property VLSeranaTransformToVLMagicEffect Auto

Quest Property SFFMentalModelExtender Auto

Race Property VampireLordRace auto

Spell Property VLSeranaTransformToNormal Auto
Spell Property VLSeranaTransformToVL Auto

Actor SeranaRef

Bool bTransformOnCooldown = False
Bool bWantsVL = False
Bool bWantsNormal = False

Actor combatTarget = None

;; SFF v1.1.0
GlobalVariable Property SFF_MCM_VL_Habitations auto 

GlobalVariable Property bVL_TransformNumber auto 
GlobalVariable Property bVL_TransformHealth auto 
GlobalVariable Property bVL_TransformLevel auto 
GlobalVariable Property bVL_TransformPlayer auto	;; while Player transfromed, Serana should not transform back
GlobalVariable Property bVL_TransformDragon auto
GlobalVariable Property bVL_TransformGiant auto
GlobalVariable Property bVL_TransformBoss auto

;=======================
; Events to control transformations
;=======================

Event OnEffectStart(Actor akTarget, Actor akCaster)
	SeranaRef = akTarget
	Debug.Trace("VL Main Effect started.")
	If (!IsSeranaVampireLord())
		; we're not a Vampire Lord, start transformation if we want to
		If (SeranaRef.IsInCombat())
			Debug.Trace("VL mech.: Serana in combat.")
			If (AllowTransform())
				Debug.Trace("VL mech.: Serana allowed to transform.")
				combatTarget = SeranaRef.GetCombatTarget()
				StartTransformIntoVL()
			EndIf
		Else
			if bVL_TransformPlayer.GetValue() == 1
				if AllowTransform()
					StartTransformIntoVL()
				endif
			endif
		EndIf
	EndIf
EndEvent

Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
	If(IsSeranaVampireLord())
		If(aeCombatState == 1)
			If(AllowTransform())
				combatTarget = akTarget
				StartTransformIntoVL()
			EndIf
		Else
			if bVL_TransformPlayer.GetValue() != 1		;; SFF v1.1.0 ~ only transform back 2 normal if Player transformation optional is turned off or if its on, if Player not transformed
				StartTransformIntoNormal()
			endif
		EndIf
	Else
		If(aeCombatState != 1)
			StartTransformIntoNormal()
		;; SFF v1.1.0
		elseif aeCombatState == 1 && AllowTransform()
			if bVL_TransformNumber.GetValue() == 1 || bVL_TransformHealth.GetValue() == 1 || bVL_TransformLevel.GetValue() == 1 || bVL_TransformPlayer.GetValue() == 1 || bVL_TransformDragon.GetValue() == 1 || bVL_TransformGiant.GetValue() == 1|| bVL_TransformBoss.GetValue() == 1
				StartTransformIntoVL() 	
				debug.trace("[SFF_VL] Serana in combat & can transform!")
			else
				debug.trace("[SFF_VL] Serana in combat but canna transform.")
			endif
		elseif !AllowTransform()
			debug.trace("[SFF_VL] [WARNING] Serana in habitation loc. Transformation blocked...")
		EndIf
	EndIf
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	;Debug.Notification("Main Effect FINISHED!")
	If(IsSeranaVampireLord() && bVL_TransformPlayer.GetValue() != 1)
		StartTransformIntoNormal()
	EndIf
EndEvent

Event OnLocationChange(Location akOldLoc, Location akNewLoc)
	If(IsSeranaVampireLord() && !AllowTransform(akNewLoc))
		if bVL_TransformPlayer.GetValue() != 1					;; SFF v1.1.0 
			StartTransformIntoNormal()
		endif
	EndIf
EndEvent

Event OnUpdate()

	bTransformOnCooldown = False
	If(bWantsNormal)
		bWantsNormal = False
		bWantsVL = False
		StartTransformIntoNormal()
	ElseIf(bWantsVL)
		bWantsNormal = False
		bWantsVL = False
		StartTransformIntoVL()
	EndIf

EndEvent

; ====================================================
; Functions
; ====================================================

Bool Function AllowTransform(Location CurrentLocation = None)
	If(CurrentLocation == None)
		CurrentLocation = SeranaRef.GetCurrentLocation()
	EndIf

	;If PlayerRef.IsSneaking()
	;	Return False
	;Else
	If CurrentLocation != None && CurrentLocation.HasKeyword(LocTypeHabitation) && SFF_MCM_VL_Habitations.GetValue() == 1		; don't allow Vampire Lord in cities / settlments / farms / etc., but only if enabled by Player
		Return False
	EndIf

	Return True
EndFunction

Bool Function IsSeranaVampireLord()
	Return (SeranaRef.GetRace() == VampireLordRace)
EndFunction

Function StartTransformIntoVL()
	Debug.Trace("SFF_1: Should start transform into VL now")

	If(!IsSeranaVampireLord() && !(SFFMentalModelExtender As SFF_MentalModelExtender).bBusyTransforming)
		If(bTransformOnCooldown)
			RegisterForSingleUpdate(1.0)
			bWantsVL = True
			Return
		EndIf
		
		(SFFMentalModelExtender As SFF_MentalModelExtender).bBusyTransforming = True
		bTransformOnCooldown = True
		VLSeranaTransformToVL.Cast(SeranaRef, SeranaRef)
		Debug.Trace("SFF_2: VL change effect called. Now to cast...")
	EndIf
	debug.trace("[SFF_VL] Serana busy transforming...!")
EndFunction

Function StartTransformIntoNormal()
	Debug.Notification("Should start VL reversal now")

	If(IsSeranaVampireLord() && !(SFFMentalModelExtender As SFF_MentalModelExtender).bBusyTransforming)
		If(bTransformOnCooldown)
			RegisterForSingleUpdate(1.0)
			bWantsNormal = True
			Return
		EndIf

		(SFFMentalModelExtender As SFF_MentalModelExtender).bBusyTransforming = True
		bTransformOnCooldown = True
		VLSeranaTransformToNormal.Cast(SeranaRef, SeranaRef)
	EndIf
EndFunction