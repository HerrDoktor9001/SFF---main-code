Scriptname SFF_SummonSeranaEffect extends activemagiceffect  
	{Code adapted from https://www.creationkit.com/index.php?title=Complete_Example_Scripts}

Actor Property Serana Auto ; An ObjectReference will also work with the summon function
 
Event OnEffectStart(Actor akTarget, Actor akCaster)
        Summon(akCaster, Serana)
EndEvent
 
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