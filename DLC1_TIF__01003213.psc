;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname DLC1_TIF__01003213 Extends TopicInfo Hidden
SFF_MentalModelExtender Property MME auto

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
;akSpeaker.OpenInventory(true)
MME.ActivateInventory()	;; SFF v1.9.0 - hijack vanilla Open Inventory script. 
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
