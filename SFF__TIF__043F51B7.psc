;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 2
Scriptname SFF__TIF__043F51B7 Extends TopicInfo Hidden
SFF_MentalModelExtender Property MME auto
;ObjectReference Property AccessoryContainer auto
;Actor Property PlayerRef auto 
;BEGIN FRAGMENT Fragment_1
Function Fragment_1(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
	;AccessoryContainer.Activate(PlayerRef)
	MME.OpenAccessoryContainer()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
