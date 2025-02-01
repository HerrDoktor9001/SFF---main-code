;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname SFF__TIF__042C0434 Extends TopicInfo Hidden

;;PROPERTIES:
SFF_HungerAndFeedSys PROPERTY HaFS auto

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
	HaFS.ClearCommentaryFlags() ;; possibility of flags not being cleared with exit dialogue. 
	HaFS.FeedOnPlayer()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
