;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 4
Scriptname SFF__PF_SFF_FollowBeside_07019D1A Extends Package Hidden

;BEGIN FRAGMENT Fragment_1
Function Fragment_1(Actor akActor)
;BEGIN CODE
akActor.ClearKeepOffsetFromActor()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(Actor akActor)
;BEGIN CODE
;WARNING: Unable to load fragment source from function Fragment_0 in script SFF__PF_SFF_FollowBeside_07019D1A
;Source NOT loaded
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_3
Function Fragment_3(Actor akActor)
;BEGIN CODE
akActor.ClearKeepOffsetFromActor()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Actor Property PlayerRef  Auto  

GlobalVariable Property SFFXnumber  Auto  

Float Property FollowRadius = 5.0 Auto  

Float Property CatchUpRadius  Auto  

Float Property UpAngle  Auto  

Float Property BackAngle  Auto  

Float Property RightAngle  Auto  

Float Property UpDist  Auto  

Float Property BackDist  Auto  

Float Property RightDist  Auto  
