Scriptname DLC1NPCMonitoringPlayerScript extends Quest  
import MiscUtil	;; SFF v1.2.1 -  PapyrusUtil required for enabling advanced/alternative sandbox behaviour

;;[REVIEW PENDING]
;; SFF v1.2.1: unecessary duplication of variables internally present in original code. Externalise 'Player' to avoid parallel declarations. 

DLC1_NPCMentalModelScript Property MM auto
ReferenceAlias Property RNPC auto

int Property UpdateInterval auto
float Property SettleRadius auto

;; SFF v1.2.1
Actor Property PlayerRef auto
Actor Serana
Float Property iSearchRadius = 320.0 auto	;; working radius of sandbox package. No point looking beyond it as sandbox package does not look for anyhting farther than this...
GlobalVariable Property SFF_MCM_Sandbox auto	;; sandbox selector 
GlobalVariable Property SFF_MCM_AdvancedSandbox auto


GlobalVariable Property SFF_MCM_AlternativeSandbox auto	;; alternative sandbox logic mode () toggle 
;Faction Property SFF_SandboxFac auto
Float Property fSandboxRadiusMult = 2.0 auto

int __historySize = 8 ; remember to update the declarations if necessary
float[] __playerPosX
float[] __playerPosY
float[] __playerPosZ

Event OnInit()
	Debug.Trace("SFF: MonitoringPlayer script (re)started.")
	Setup()
EndEvent

Function Setup()
	; history of player position over the last __historySize updates
	__playerPosX = new float[8]
	__playerPosY = new float[8]
	__playerPosZ = new float[8]

	; initialize the position histories with faraway junk datums
	;  so that we won't immediately assume the player is holding 
	;  still when the quest starts
	;Actor _player = Game.GetPlayer()
	int count = 0
	while (count < __historySize)
		__playerPosX[count] = PlayerRef.X + 1000
		__playerPosY[count] = PlayerRef.Y + 1000
		__playerPosZ[count] = PlayerRef.Z + 1000
		count += 1
	endwhile
	Serana= RNPC.GetActorReference()
	RegisterForSingleUpdate(UpdateInterval as float)
EndFunction

Bool Function bSandbox()
	if SFF_MCM_Sandbox.GetValue() == 1
		return true
	else
		return false
	endif
EndFunction

Bool Function bAdvancedSandbox()
	if SFF_MCM_AdvancedSandbox.GetValue() == 1
		return true
	else
		return false
	endif
EndFunction

Bool Function bAlternativeSandbox()
	if SFF_MCM_AlternativeSandbox.GetValue() == 1
		return true
	else
		return false
	endif
EndFunction

;; called from MCM menu to re-register Update if needed
Function Register4Update(float time=1.0)
	RegisterForSingleUpdate(time)
EndFunction 

Int Function Check4Markers()
	;; function for detecting if there are any nearby Idle Makers for Serana to use
	;; if not, we should stop Serana from sandboxing...
	
	ObjectReference[] availableMarkers = ScanCellObjects(47, PlayerRef as ObjectReference, iSearchRadius)	;; array of filtered GameObjects detected within radius 
																											;; 47 - kIdleMarker, IdleMarker formtype number
																											;; kFurniture = 40, Idle Marker for furniture
	Int iMarkerNum= availableMarkers.Length
	
	if iMarkerNum <= 0
		;; furniture not considered as IdleMarker. 'ScanCell' func. only allows for one formtype filter
		;; so, necessary to check both: if IdleMarker (47) returns null, check for Furniture (40)
		
		availableMarkers = ScanCellObjects(40, PlayerRef as ObjectReference, iSearchRadius)
		iMarkerNum= availableMarkers.Length
	endif
	
	;debug.trace(iMarkerNum + " Idle Markers found in radius ("+ iSearchRadius +")")
	return iMarkerNum
EndFunction

Bool Function PlayerInRadius()
	;Actor[] facMembers = ScanCellNPCsByFaction(SFF_SandboxFac, RNPC.GetActorReference(), iSearchRadius*fSandboxRadiusMult)	;; only Player should be found here 

	;Int iMarkerNum= facMembers.Length
	
	if Serana.GetDistance(PlayerRef) > iSearchRadius*fSandboxRadiusMult ;iMarkerNum <= 0
		;debug.trace("SFF: Player not within Serana's radius.")
		return false
	else
		;debug.trace("SFF: Player found in radius (" + iSearchRadius*fSandboxRadiusMult +")")
		return true
	endif
EndFunction

Event OnUpdate()
	PlayerPosChecker()
EndEvent

;; SFF v1.4.1: keep 'returns' CLEAR from 'OnUpdate' event. Cause major problems
Function PlayerPosChecker()
	;; SFF v1.2.1 - if sandbox disabled, no point executing all this code. Hang it!
	;; Update then called from MCM if re-enabling it.
	if !bSandbox()
		debug.Trace("[SFF_Sandbox]: Sandbox disabled in MCM. Skip relevant code...")
		MM.PlayerSettled= false			;; set this to false just as a failsafe, so Serana not stuck in sandbox (highly unlikely, but still...)
		return
	endif
	
	;; sff v1.7.1 - EVP getting called while Serana in dialogue with Player, 
	;; causing problems for Outfit Previewer while using SkyrimSouls RE.
	;  if Serana.IsInDialogueWithPlayer()
		;  MM.PlayerSettled= false
		;  RegisterForSingleUpdate(15.0)
		;  return
	;  endif
	
	;; SFF v1.2.1 - if Serana not formally following Player, wasted resource! Hang code, check again later.
	;; SFF v1.4.1 - only run this if Serana NOT in combat
	if !MM.IsFollowing || Serana.IsInCombat ()
		debug.trace("[SFF_Sandbox]: Serana either not registered as follower or currently in combat. Suspending code, re-check in 15s...")
		RegisterForSingleUpdate(15.0)
		return
	endif
	
	; cycle all positions down one notch in the history arrays
	int historyIndex = 0
	while (historyIndex < __historySize - 1)
		__playerPosX[historyIndex] = __playerPosX[historyIndex + 1]
		__playerPosY[historyIndex] = __playerPosY[historyIndex + 1]
		__playerPosZ[historyIndex] = __playerPosZ[historyIndex + 1]

		historyIndex += 1
	endwhile

	; set the most recent history as the current player position
	__playerPosX[__historySize - 1] = PlayerRef.X
	__playerPosY[__historySize - 1] = PlayerRef.Y
	__playerPosZ[__historySize - 1] = PlayerRef.Z


	; check current position against oldest history point if we're
	;   in follow mode
	bool switchedPackageConditions = false

	if (!MM.IsWillingToWait && Serana.GetActorValue("WaitingForPlayer") != 0)
		; she's not willing to wait for the player right now, but for
		;  some reason is waiting. Let's kick her out of this.
		Serana.SetActorValue("WaitingForPlayer", 0)
		switchedPackageConditions = true
	endif

	; calculate distance between history start and present
	;    sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2)
	float xFactor = (__playerPosX[0] - PlayerRef.X)
	xFactor = xFactor * xFactor
	float yFactor = (__playerPosY[0] - PlayerRef.Y)
	yFactor = yFactor * yFactor
	float zFactor = (__playerPosZ[0] - PlayerRef.Z)
	zFactor = zFactor * zFactor

	float distance = Math.sqrt(xFactor + yFactor + zFactor)

	if (MME.IsHome==true) 									;; if Player entered Home-tagged cell,
			
			if (bEVPfired != true)							;; fire a single EVP, if not done so already.
				switchedPackageConditions= true			    
				bEVPfired= true								;; set flag so it stops further EVP's while in Cell. 
			endif
			
	else
		bEVPfired= false
		
		if distance <= SettleRadius
		;;Player not moved, or moved within radius - so, is (technically) settled. But,
			
			if bAdvancedSandbox() && Check4Markers() < 1
			;; if AdvancedSandbox mode enabled and no sandbox markers available,
			;; keep her in follow mode
				if (MM.PlayerSettled == true)
					switchedPackageConditions = true
				endif
				MM.PlayerSettled= false		;; Player is (technically) settled, but we have to hide fact from Serana (bar Sandbox beh.)
			else
			;; if AdvancedSandbox disabled OR enabled and sandbox markers available,
			;; let Serana sandbox
				if (MM.PlayerSettled == false)
					switchedPackageConditions = true
				endif
				MM.PlayerSettled= true
			endif
		
		elseif distance > SettleRadius
		;; Player moved more than 'settle' radius - so, technically 'on the move'.
		
			if bAlternativeSandbox() && PlayerInRadius()
				;; if AlternateSandbox enabled and Player in Serana's radius,
				;; do nothing. If Player already settled and Serana sandboxing, continue so. If Player moving and Serana following, continue so: bool will be inherited and will not have been changed
			else
			;; if AlternateSandbox disabled, OR enabled and Player NOT in Serana's radius,
			;; set settled status to false (if not already so...): tell Serana to stop frolicking and follow Player.
				if (MM.PlayerSettled == true)
					switchedPackageConditions = true
					MM.PlayerSettled= false 			;; no need to set flag to false if already false. 
				endif
			endif
		endif
	endif

	; only do the EVP if we've actually changed the value
	if (switchedPackageConditions)
		Serana.EvaluatePackage()
		Debug.Trace("SFF: EVP called.")
	endif
	
	; do it all again
	RegisterForSingleUpdate(UpdateInterval as float)
EndFunction

;; SFF Variables
Bool bEVPfired
SFF_MentalModelExtender Property MME auto
;; /SFF Variables