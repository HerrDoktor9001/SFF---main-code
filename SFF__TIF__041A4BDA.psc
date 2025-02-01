;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname SFF__TIF__041A4BDA Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
(Alias_Horse.GetReference()).SetActorOwner(Alias_Serana.GetActorReference().GetActorBase())
MME.currentMount= Alias_Horse.GetReference()

MME.ResetOwnership(Alias_Horse_extras)


if !MME.bHasGivenHorse
	MME.CallSDESetter (1) ;; 0- 'likes'; 1- 'loves'
	MME.bHasGivenHorse= true
endif
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

ReferenceAlias Property Alias_Horse  Auto  
ReferenceAlias [] Property Alias_Horse_extras auto ;; every horse other than current one (4/5 horses)
ReferenceAlias Property Alias_Serana  Auto  
SFF_MentalModelExtender Property MME auto
