;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname SFF__TIF__0703D42A Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE

Cell playerCell = PlayerRef.GetParentCell()

if (MME.IsHome && MME.bHomeOwned)
	MM.SetHomeMarker(TokenID, CustomHomeMarker)
	if MME.SDEQuest
		if (MME.hasSetHome !=true)
			if (MME.CallSDErelval() >25)
				;SDE.SeranaLoves()
				MME.CallSDESetter (1) ;; 0- 'likes'; 1- 'loves'
			elseif (MME.CallSDErelval() <=25)
				;SDE.SeranaLikes()
				MME.CallSDESetter (0) ;; 0- 'likes'; 1- 'loves'
			endif
			MME.hasSetHome= true
		endif
	else 
		Debug.Trace("SFF: SDE main quest not loaded")
	endif

else
	Debug.Notification("You are not the owner of this place.")
endif 

;END CODE
EndFunction
;END FRAGMENT
Faction Property PlayerFaction auto 
Actor Property PlayerRef auto
ObjectReference Property CustomHomeMarker auto 	;; Dynamic XMarker that is moved to Player location when appropriate.
Int Property TokenID = 3 auto
DLC1_NPCMentalModelScript Property MM auto
SFF_MentalModelExtender Property MME auto
;SDECustomMentalModel Property SDE auto
;END FRAGMENT CODE - Do not edit anything between this and the begin comment
