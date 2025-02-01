;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname SFF__TIF__0419A9CF Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
	MME.SummonArvak(Alias_Horse_extras);, Alias_Horse)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

;ReferenceAlias Property Alias_Horse auto
ReferenceAlias [] Property Alias_Horse_extras auto ;; every horse other than current one (all buyable horses)
SFF_MentalModelExtender Property MME auto
