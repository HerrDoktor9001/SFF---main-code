;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname SFF__TIF__0703D429 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
MM.SetHomeMarker(TokenID)
;END CODE
EndFunction
;END FRAGMENT
DLC1_NPCMentalModelScript Property MM auto
Int Property TokenID auto
;END FRAGMENT CODE - Do not edit anything between this and the begin comment
