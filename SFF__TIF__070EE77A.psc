;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname SFF__TIF__070EE77A Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
MM.FollowDistanceClose=false
MM.FollowDistanceMedium=false
MM.FollowDistanceFar=false
MM.FollowDistanceBeside=true

;; code for sending relationship points on 1st ask (SFF v1.0.0) 
if (MME.hasAskedWalkBeside !=true)
	;SDE.SeranaLoves()
	MME.CallSDESetter (1) ;; 0- 'likes'; 1- 'loves'
	MME.hasAskedWalkBeside= true
	if (MME.hasAskedCloseFollow != true)
		;SDE.SDECMMRelVar += 1
		(MME.SDEQuest as SDECustomMentalModel).SDECMMRelVar += 1
		MME.hasAskedCloseFollow= true
	endif
endif
;END CODE
EndFunction
;END FRAGMENT
DLC1_NPCMentalModelScript Property MM auto  ;; Serana AI (MentalModel)
SFF_MentalModelExtender Property MME auto
;END FRAGMENT CODE - Do not edit anything between this and the begin comment
