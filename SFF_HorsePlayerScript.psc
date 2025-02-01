Scriptname SFF_HorsePlayerScript extends ReferenceAlias  

Faction Property JobHostlerFaction auto


Event OnActivate(ObjectReference akActionRef)
	;If (akActionRef as Actor).IsInFaction(JobHostlerFaction)
	;If (akActionRef as Actor).GetDialogueTarget().IsInFaction(JobHostlerFaction)
	If akActionRef == Game.GetPlayer()
		Debug.Notification("Player talking to a Stables Owner.")
	EndIf
EndEvent