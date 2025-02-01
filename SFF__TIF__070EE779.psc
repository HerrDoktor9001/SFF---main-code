;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname SFF__TIF__070EE779 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
MM.FollowDistanceClose=true
MM.FollowDistanceMedium=false
MM.FollowDistanceFar=false
MM.FollowDistanceBeside=false


;; code for sending relationship points on 1st ask (SFF v1.0.0) 
if (MME.hasAskedCloseFollow !=true)
	;SDE.SeranaLikes()
	MME.CallSDESetter (0) ;; 0- 'likes'; 1- 'loves'
	MME.hasAskedCloseFollow= true
endif
;END CODE
EndFunction
;END FRAGMENT
DLC1_NPCMentalModelScript Property MM auto
SFF_MentalModelExtender Property MME auto
;SDECustomMentalModel Property SDE auto
;END FRAGMENT CODE - Do not edit anything between this and the begin comment
