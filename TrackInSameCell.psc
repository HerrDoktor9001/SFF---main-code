Scriptname TrackInSameCell extends activemagiceffect  
{ability that will be activated when player is not in the same cell as invisibleObject. Copied from https://www.creationkit.com/index.php?title=Detect_Player_Cell_Change_(Without_Polling)}
 
Actor property playerRef auto
ObjectReference property invisibleObject auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	;debug.notification("player changed cells")
	Utility.Wait(0.1) ; Required.
	invisibleObject.MoveTo(playerRef)

EndEvent