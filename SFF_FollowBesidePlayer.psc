Scriptname SFF_FollowBesidePlayer extends ReferenceAlias Conditional

import PO3_SKSEFunctions

;; [TODO] [SFF v1.2.1]: 'RightDist' var, manipulable via MCM menu, gets reset after toggling update. Needs to be added to Update framework!
;; SFF v1.8.0:
;;	- Remove obsolete, left-over code and properties
;;	- Revise code for more efficient and rational execution
;;	- Remove Original follow beh. implementation (MODE 0)

;; SFF v1.9.0:
;;	- Add a 'Variable Companion Mode' option (Serana not stuck to following to the left or right of Player exclusively) [DONE]

;DLC1_NPCMentalModelScript Property MM auto  ;; Serana AI (MentalModel) [UNUSED!] [DELETE]

Package Property SeranaFollowBesidePackage  Auto 

ReferenceAlias Property Alias_Serana auto
Actor Property Serana auto
Actor Property PlayerRef  Auto  

float fUpdateInt = 1.0		;; update cycle rate

;; Variables carried from Ishara's script
Float Property RightDist = 70.0 Auto
Float Property BackDist = 0.0 Auto
Float Property UpDist = 0.0 Auto
Float Property RightAngle = 0.0 Auto
Float Property BackAngle = 0.0 Auto
Float Property UpAngle = 0.0 Auto
Float Property CatchUpRadius = 100.0 Auto
Float Property FollowRadius = 15.0 Auto

Float Property RightDistIndoors = 55.0 auto	;; SFF v1.2.1 - distance used when not in Exterior cells

GlobalVariable Property SFF_MCM_AltCompanionMode auto
GlobalVariable Property SFF_MCM_OrganicCompanionMode auto	;; SFF v1.9.0: organic/variable companion mode follow side
GlobalVariable Property SFF_MCM_VarSideDist auto			;; SFF v1.2.1: variable side distance toggle

String Property sMessage = "SFF: Companion Mode script started!" auto

;; for checking if Companion Mode package is running
Bool Function bPackageRunning()
	if Serana.GetCurrentPackage() == SeranaFollowBesidePackage
		return true
	endif
	
	return false
EndFunction

;; for checking if 'Variable Companion Mode Dist.' feature is ON
Bool Function bVarSideDist()
	if SFF_MCM_VarSideDist == none			;; v1.8.0 - for making sure a value is always returned, even if game for any reason does not detect property as filled (vff issue)
		return false
	endif
	
	if SFF_MCM_VarSideDist.GetValue() == 1
		return true
	endif

	return false
EndFunction

;; called externally (MCM menu)
;; sets the side distance amount
Function SetDistanceX(float myDist)
	Debug.Trace("SFF: Player changed Companion Mode distance from " + RightDist + " to " + myDist)	;; sff v1.8.0 - better trace information
	RightDist= myDist
EndFunction

Event OnInit() 

	RegisterForMenu("Dialogue Menu")
	RegisterForCameraState()			;; for faster detection of camera change, to stop/restart Companion follow beh.
	
	if Serana == none
		Serana = Alias_Serana.GetActorReference() 
	endif
	Serana.EvaluatePackage()
	
	if !bPackageRunning()
		ClearOffset(false)
	endif	

	;RegisterForSingleUpdate(fUpdateInt)
	UnregisterForUpdate()
	Debug.Notification(sMessage)
EndEvent


Event OnCellLoad()
;; fix for frequent Serana freeze when moving between cells (SFF v1.2.0)
	if bPackageRunning()
		ClearOffset(false)
		Utility.Wait(1.0)
		if bPackageRunning()
			RegisterOffset()
		endif
	endif
endEvent

Function ClearOffset(bool unregister = true)
	;Serana.ClearKeepOffsetFromActor()
	;Serana.KeepOffsetFromActor(PlayerRef, 0.0, 0.0, -20.0)	;; sff v1.9.0 - for making sure offset is properly reset, giving issue of offset permanence 
	Serana.ClearKeepOffsetFromActor()
	Serana.SetHeadTracking(true)
	if unregister
		UnregisterForUpdate()
	endif
EndFunction

;; SFF v1.9.0 ~ Code structure for enabling 'Organic Companion Mode' feature
BOOL bWeightTrigger = true
FLOAT iEffectiveOffset
FLOAT FUNCTION iOrganicOffset (float myDist = 0.0)

	if myDist == 0.0
		myDist= RightDist
	endif
	
	int iRandom = GenerateRandomInt(0, 100)
	debug.trace("SFF: [DEBUG] Organic Companion Mode randomiser called: " + iRandom)
	
	;; so we can add a weight to preferred position
	int iPosMult = 0
	int iNegPos = 0
	
	if bWeightTrigger
		iPosMult += 20
	else
		iNegPos += 20
	endif
	
	
	if iRandom >= 50 - iPosMult + iNegPos		;; 1st run, 70:30 chance of returning true
		bWeightTrigger= true
		debug.trace("SFF: [DEBUG] Organic Companion Mode: follow on side X")
		return myDist
	else
		bWeightTrigger= false
		debug.trace("SFF: [DEBUG] Organic Companion Mode: follow on side -X")
		return myDist*-1
	endif
ENDFUNCTION

Function RegisterOffset(bool register = true, float fZAngle = 0.0)
;; SFF v1.2.1: added variable side distance code
;; SFF v1.9.0: organic offset code
	Serana.SetHeadTracking(false)

	if SFF_MCM_OrganicCompanionMode.GetValue() == 1
		
		
		
		if bVarSideDist()
			if Serana.IsInInterior() && (RightDist > 0 && RightDistIndoors < RightDist || RightDist < 0 && RightDistIndoors*-1 > RightDist)
				iEffectiveOffset= iOrganicOffset(RightDistIndoors)	;; capture 'Organic Offset' value here, so we know value used by 'KeepOffsetFromActor()' function
				Serana.KeepOffsetFromActor(PlayerRef,iEffectiveOffset,BackDist,UpDist,RightAngle,BackAngle,fZAngle,CatchUpRadius,FollowRadius)
			else
				iEffectiveOffset= iOrganicOffset(RightDist)	;; capture 'Organic Offset' value here, so we know value used by 'KeepOffsetFromActor()' function
				Serana.KeepOffsetFromActor(PlayerRef,iEffectiveOffset,BackDist,UpDist,RightAngle,BackAngle,fZAngle,CatchUpRadius,FollowRadius)
			endif

		else
			iEffectiveOffset= RightDist
			Serana.KeepOffsetFromActor(PlayerRef,iEffectiveOffset,BackDist,UpDist,RightAngle,BackAngle,fZAngle,CatchUpRadius,FollowRadius)
		endif
	
	else
		if bVarSideDist()
			if RightDist > 0
			;; if Serana following on Player's right side
				if Serana.IsInInterior() && RightDistIndoors < RightDist
					iEffectiveOffset= RightDistIndoors
					Serana.KeepOffsetFromActor(PlayerRef,iEffectiveOffset,BackDist,UpDist,RightAngle,BackAngle,fZAngle,CatchUpRadius,FollowRadius)
					;Debug.Trace("SFF: Serana using Indoors follow distance.")
				else
					iEffectiveOffset= RightDist
					Serana.KeepOffsetFromActor(PlayerRef,iEffectiveOffset,BackDist,UpDist,RightAngle,BackAngle,fZAngle,CatchUpRadius,FollowRadius)
				endif
			
			elseif RightDist < 0
			;; if Serana following on Player's left side
				if Serana.IsInInterior() && RightDistIndoors*-1 > RightDist
					iEffectiveOffset= RightDistIndoors*-1
					Serana.KeepOffsetFromActor(PlayerRef,iEffectiveOffset,BackDist,UpDist,RightAngle,BackAngle,fZAngle,CatchUpRadius,FollowRadius)
				else
					iEffectiveOffset= RightDist*-1
					Serana.KeepOffsetFromActor(PlayerRef,iEffectiveOffset,BackDist,UpDist,RightAngle,BackAngle,fZAngle,CatchUpRadius,FollowRadius)
				endif					
			endif
		else
			iEffectiveOffset= RightDist
			Serana.KeepOffsetFromActor(PlayerRef,iEffectiveOffset,BackDist,UpDist,RightAngle,BackAngle, fZAngle,CatchUpRadius,FollowRadius)
		endif
	endif
	
	if register
		RegisterForSingleUpdate(fUpdateInt)
	endif
EndFunction


;;SFF v1.2.1: Serana sometimes gets permanently snapped to Player. Especially annoying during combat.
;; this seeks to redress (or at least mitigate) the issue
Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
	;; if Serana not in non-combat mode (i.e., in combat or searching (1 and 2),
	;; clear offset
	if aeCombatState != 0
		ClearOffset()
	endif
EndEvent

;; SFF v1.8.0 - DUMB! Listen for DIALOGUE MENU! Whenever it closes, snap Serana to us (as long as she is following and near us!) 
Event OnMenuClose(String MenuName)
	;; no reverse function for OnActivate. So, listen for "close dialogue menu" event,
	;; and if the FollowBeside package is running, we can assume Serana must snap to Player again
	;; false positives may happen: if Player closes a third-party npc dialogue, this will re-call Offset, but Serana should already be in it
	;Debug.Trace("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ SFF: Player closed a dialogue window! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	if MenuName == "Dialogue Menu"
		if bPackageRunning()
			RegisterOffset()
			Debug.Trace("SFF: Player closed a dialogue window. Serana in Companion Mode. Snap to Player...")
		endif
	endif
EndEvent

Event OnPlayerCameraState(int oldState, int newState)
	if bPackageRunning() && !Serana.IsInDialogueWithPlayer() ;; sff v1.8.0 - to make sure changing cam. state during dialogue does not re-snap Serana to Player
		if newState == 0
			Debug.Trace("SFF: Camera state changed. Now 1st Person & Serana in Companion Mode. Unsnap her...")
			ClearOffset()
		elseif newState == 8 || newState == 9
			;;3rd person 1 & 2 (? difference between them? no idea)
			Debug.Trace("SFF: Camera state changed. Now 3rd Person & Serana in Companion Mode. Snap her...")
			RegisterOffset()
		EndIf
	;; SFF v1.2.1: Serana sometimes gets permanently snapped to Player, even though CM package not running.
	;; This forces camera change to force unsnap her.
	else
		ClearOffset()
	endif
EndEvent


Event OnPackageEnd(Package akOldPackage)
	 
	;UnregisterForUpdate()
	if !bPackageRunning() && akOldPackage == SeranaFollowBesidePackage
		ClearOffset()		;; clear offset, headtrack and unregister update
	endif
endEvent

Event OnPackageStart(Package akNewPackage)

	if bPackageRunning()
		;debug.Notification("Correct package loaded.")
		;Serana.MoveTo(Serana)
		Serana.EvaluatePackage()
		
		if bPackageRunning()

			;RegisterForSingleUpdate(fUpdateInt)
			RegisterOffset(true)
			
		Else
			;debug.Notification("Package NOT LOADED.")
			ClearOffset()	;; clear offset, headtrack and unregister update
		endif
		
	EndIf
EndEvent

Event OnPackageChange(Package akOldPackage)

	if bPackageRunning()
		RegisterForSingleUpdate(fUpdateInt)
		;debug.Notification("Same package.")
		RegisterOffset(false)
		Serana.EvaluatePackage()

		Serana.SetHeadTracking(false)

	Else
		;debug.Notification("Package NOT LOADED.")
		;Serana.ClearKeepOffsetFromActor()
		ClearOffset()
		Serana.SetHeadTracking()
		;UnregisterForUpdate()
	endif

EndEvent

Event OnUpdate()
	;; this loops check to make sure Serana's angle is  synchronised with Player's
	if SFF_MCM_AltCompanionMode.GetValue() == 1
		ResetAngle()
	elseif SFF_MCM_AltCompanionMode.GetValue() == 0
		CorrectAngle()
	endif
	;debug.trace(":1:")
EndEvent

float property threshold = 90.0 auto conditional	;; set via MCM

;; user with same issue, and possibly more elegant fix: https://forums.nexusmods.com/index.php?/topic/10149943-help-with-troop-formations/page-2
;; user alleges that AngleZ values > 0 lead to character rotation - CONFIRMED!
;; HOWEVER, npc is not permanently rotated: a few seconds later, it is undone, and we end up in a loop.
;; Loop seems unavoidable. Any integer value  (+ or -, large or small) corrects the rotation initially, but auto-reverts...
;; Further, it triggers when moving in ANY direction, and at ANY speed.

;; WORKS if we clear the default Offset before forcing the 'correcting' Offset!
;; positive values = clockwise rotation; negative values, anti-clockwise rotation
;; BENEFITS: less disruptive than using 'ResetAngle()', which would interfere with offset 
;; 
Function ResetAngle()
	if bPackageRunning()
		float SeranaAngle= Serana.GetAngleZ()
		float PlayerAngle= PlayerRef.GetAngleZ()
		if SeranaAngle > (PlayerAngle-threshold) && SeranaAngle < (PlayerAngle+threshold)
			 ;; do nothing
		
		else

			Serana.SetAngle(0.0, 0.0, PlayerAngle)	;; outdated. Method '0' now preferred ('CorrectAngle()') 
			RegisterOffset(false)					;; not strictly needed. Offset still registered even after calling angle reset
		endif
		;CheckDistance()
		RegisterForSingleUpdate(fUpdateInt)
	else 
		UnregisterForUpdate()
	endif
EndFunction


Bool bAngleMatched = false
;; SFF v2.0.0 - corrects 'KeepOffsetFromActor()' angle instead of resetting angle itself and killing the offset in the process
Function CorrectAngle()
	if bPackageRunning()
	
		float SeranaAngle= Serana.GetAngleZ()
		float PlayerAngle= PlayerRef.GetAngleZ()
		
		if SeranaAngle > (PlayerAngle-threshold) && SeranaAngle < (PlayerAngle+threshold)
			
			;; SFF v2.0.0 ~ we don't want to run 'RegisterOffset()': re-running may give us a NEW 'RightDist' value if using 'Organic Companion Mode' feature,
			;; which is something we do not want given that this will be called every 1sec.!
			;; Because of this, we had to cache the X-Dist. offset in use ('iEffectiveOffset'), which can be used here so we can keep the offset stable...
			if !bAngleMatched		;; trigger to stop offset register from looping unecessarily
				Serana.KeepOffsetFromActor(PlayerRef, iEffectiveOffset, BackDist, UpDist, RightAngle, BackAngle, UpAngle, CatchUpRadius, FollowRadius)
				bAngleMatched= true
			endif
		else
			bAngleMatched= false	;; clear bool so when we match again, offset register can be re-called
			Serana.ClearKeepOffsetFromActor()	;; SFF v2.0.0 ~ prior offset clearing needed to set the 'corrector' offset...			
			Serana.KeepOffsetFromActor(PlayerRef, iEffectiveOffset, BackDist, UpDist, RightAngle, BackAngle, -10.0, CatchUpRadius, FollowRadius)
		endif
		
		;CheckDistance()
		RegisterForSingleUpdate(fUpdateInt)
	else 
		UnregisterForUpdate()
	endif
	
EndFunction 


; Function CheckDistance()

	; if Serana.GetDistance(PlayerRef) > 300
		; debug.Notification(Serana.GetDistance(PlayerRef))
	; endif

; EndFunction