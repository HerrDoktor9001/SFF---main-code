Scriptname SFF_NPCMovementMonitor extends Quest 
{Script for determining if Serana is stuck while trying to follow Player in Companion Mode}

SFF_MentalModelExtender Property MME auto
DLC1_NPCMentalModelScript Property MM auto  ;; Serana AI (MentalModel)

Actor Property Serana auto

float Property UpdateInterval= 1.0 auto
float Property SettleRadius= 90.0 auto

Bool Property bIsStuck= false auto conditional

int __historySize = 4 ; remember to update the declarations if necessary
float[] __seranaPosX
float[] __seranaPosY
float[] __seranaPosZ

String SeranaMove = "Serana on the move."
String SeranaStuck = "Serana is stuck!"

Package Property SeranaFollowBesidePackage  Auto 

Bool Function bPackageRunning()
	if Serana.GetCurrentPackage() == SeranaFollowBesidePackage
		return true
	else
		return false
	endif
EndFunction

Event OnInit()
	Debug.Trace("SFF: Serana position tracker script (re)started.")
	Setup()
EndEvent 


Function Setup()
	; history of player position over the last __historySize updates
	__seranaPosX = new float[4]
	__seranaPosY = new float[4]
	__seranaPosZ = new float[4]

	; initialize the position histories with faraway junk datums
	;  so that we won't immediately assume the player is holding 
	;  still when the quest starts
	;Actor _player = Game.GetPlayer()
	int count = 0
	while (count < __historySize)
		__seranaPosX[count] = Serana.X + 1000
		__seranaPosY[count] = Serana.Y + 1000
		__seranaPosZ[count] = Serana.Z + 1000
		count += 1
	endwhile

	RegisterForSingleUpdate(UpdateInterval)
EndFunction


Event OnUpdate()
	SeranaMovementMonitor()
	;MME.Test()
EndEvent

Function SeranaMovementMonitor()
	;debug.trace("SFF: Movement Monitor code working as expected...")
	if !Serana.IsPlayerTeammate()
		debug.trace("[SFF_MovementDetector]: Serana not currently registered as follower. Aborting code...")
		bIsStuck= false
		RegisterForSingleUpdate(20.0)
		return
	endif
	
	if !MM.FollowDistanceBeside
		;; Serana not in Companion Mode. No point wasting resource gauging movement/location
		bIsStuck= false
		RegisterForSingleUpdate(20.0)
		return
	endif
	
	;; SFF v1.5.0
	if MM.SimpleFollow
		;; Serana meant to be in "Simple Follow" alternative mode. Dangerous to mess with her here (used when playing scenes and in other special occasions. 
		bIsStuck= false
		RegisterForSingleUpdate(20.0)
		return	
	endif
	
	if Serana.IsInCombat()
		;; if Serana in combat, no need to waste resources checking if stuck
		bIsStuck= false
		RegisterForSingleUpdate(20.0)
		return
	endif

	; cycle all positions down one notch in the history arrays
	int historyIndex = 0
	while (historyIndex < __historySize - 1)
		__seranaPosX[historyIndex] = __seranaPosX[historyIndex + 1]
		__seranaPosY[historyIndex] = __seranaPosY[historyIndex + 1]
		__seranaPosZ[historyIndex] = __seranaPosZ[historyIndex + 1]

		historyIndex += 1
	endwhile

	; set the most recent history as the current player position
	__seranaPosX[__historySize - 1] = Serana.X
	__seranaPosY[__historySize - 1] = Serana.Y
	__seranaPosZ[__historySize - 1] = Serana.Z


	; calculate distance between history start and present
	;    sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2)
	float xFactor = (__seranaPosX[0] - Serana.X)
	xFactor = xFactor * xFactor
	float yFactor = (__seranaPosY[0] - Serana.Y)
	yFactor = yFactor * yFactor
	float zFactor = (__seranaPosZ[0] - Serana.Z)
	zFactor = zFactor * zFactor

	float distance = Math.sqrt(xFactor + yFactor + zFactor)
	
	;; sff v1.6.0 ~ added 3DLoaded check to stop log error spam (cannot get anim. variable if npc has no 3d...)
	if Serana.Is3DLoaded() && Serana.GetAnimationVariableFloat("Speed") > 0 
		;Debug.Trace("Serana 'moving' (playing anim.).")
		
		if distance > SettleRadius
			;;Serana on the move
			bIsStuck= false
			if Serana.IsInDialogueWithPlayer()
				debug.Trace("--> --> SFF: Serana on the move & In Dialogue with Player!")
				;; sff v1.9.0 - for stopping the Stuck Offset' issue, simply superimpose another offset and then clear it...
				Serana.ClearKeepOffsetFromActor()
				Serana.KeepOffsetFromActor(Game.GetPlayer(), 0.0, 0.0, -20.0)
				Serana.ClearKeepOffsetFromActor()
			endif
		else
			;; Serana stuck
			;;Debug.Trace(SeranaStuck)
			;;Debug.Notification(SeranaStuck)
			bIsStuck= true
			Serana.EvaluatePackage()	;; call EVP to make sure beh. changes as fast as possible
			MME.SemiSneakBug()	;; SFF v1.5.0
		endif
	else
		bIsStuck= false
	endif
	
	; do it all again
	RegisterForSingleUpdate(UpdateInterval)
endfunction