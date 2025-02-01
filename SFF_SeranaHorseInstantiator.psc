Scriptname SFF_SeranaHorseInstantiator extends ReferenceAlias  

SFF_MentalModelExtender Property MME auto

Actor Serana 
Actor PlayerRef  
Package Property SFF_RideHorse Auto 
Spell Property SFF_SummonArvak Auto		;; spell for summoning Arvak
Bool bStopCheck


Event OnInit()
	Serana = GetActorReference() 
	PlayerRef= Game.GetPlayer()
	Debug.Notification("SFF Horse-riding system initiated")
EndEvent

Event OnPackageStart(Package akNewPackage)

	if Serana.GetCurrentPackage() == SFF_RideHorse
		Teleport2Serana()
	else
		;bStopCheck= false
	EndIf
	if akNewPackage != SFF_RideHorse && bStopCheck
		bStopCheck= false
	endif
EndEvent

Event OnPackageEnd(Package akOldPackage)
	;DisableArvak()
	if akOldPackage == SFF_RideHorse
		bStopCheck= false
	endif
endEvent

Function Teleport2Serana()
;; SFF v1.2.1: this function is getting called over indefinatelly...
	if bStopCheck
		DEBUG.TRACE("SFF: Serana cannot call horse. BLOCKED!")
		return
	endif
	
	if MME.bUsingArvak != true
		if (Serana.GetDistance(MME.currentMount) > 3000)
			;MME.currentMount.MoveTo(Serana, -500.0 * Math.Sin(Serana.GetAngleZ()), -500.0 * Math.Cos(Serana.GetAngleZ()), Serana.GetHeight() + 1.0)
			MME.currentMount.MoveTo(Serana)
		endif
	else
		if Serana.GetDistance(MME.DLC01SoulCairnHorseSummon) > 3000
			Summon(Serana, MME.DLC01SoulCairnHorseSummon)
		endif
	endif
	utility.wait(0.5)
	Serana.MoveToNode(MME.currentMount, "SaddleBone")
	debug.trace("SFF: Serana moved to horse")
	Serana.EvaluatePackage()
	bStopCheck= true
EndFunction

Function Summon(ObjectReference akSummoner = None, ObjectReference akSummon = None, Float afDistance = 150.0, Float afZOffset = 0.0, ObjectReference arPortal = None, Int aiStage = 0)
	While aiStage < 6
			aiStage += 1
			If aiStage == 1 ; Shroud summon with portal
					arPortal = akSummon.PlaceAtMe(Game.GetForm(0x0007CD55)) ; SummonTargetFXActivator disables and deletes itself
			ElseIf aiStage == 2 ; Disable Summon
					akSummon.Disable()
			ElseIf aiStage == 3 ; Move portal in front of summoner
					arPortal.MoveTo(akSummoner, Math.Sin(akSummoner.GetAngleZ()) * afDistance, Math.Cos(akSummoner.GetAngleZ()) * afDistance, afZOffset)
			ElseIf aiStage == 4 ; Move summon to portal
					akSummon.MoveTo(arPortal)
			ElseIf aiStage == 5 ; Enable summon as the portal dissipates
					akSummon.Enable()
			EndIf
			Utility.Wait(0.6)
	EndWhile
EndFunction