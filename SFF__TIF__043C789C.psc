;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname SFF__TIF__043C789C Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
	Actor akSpeaker = akSpeakerRef as Actor
	;BEGIN CODE
	if !bReset
		MME.OpenCustomOutfitCont(myContainer, myFormList)
	else
		MME.ResetOutfit()
	endif
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
SFF_MentalModelExtender Property MME auto
ObjectReference Property myContainer auto
FormList Property myFormList auto
Bool Property bReset = false auto