;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname SFF__PF_SFF_ArvakReturn2Obliv_041A4BD4 Extends Package Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(Actor akActor)
;BEGIN CODE
	akSummon= MME.DLC01SoulCairnHorseSummon
	While aiStage < 3
			aiStage += 1
			If aiStage == 1 ; Shroud summon with portal
					arPortal = akSummon.PlaceAtMe(Game.GetForm(0x0007CD55)) ; SummonTargetFXActivator disables and deletes itself
			ElseIf aiStage == 2 ; Disable Summon
					akSummon.Disable()
			EndIf
	EndWhile
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

;ReferenceAlias Property myArvak auto
SFF_MentalModelExtender Property MME auto
Int aiStage = 0
ObjectReference akSummon
ObjectReference arPortal