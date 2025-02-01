Scriptname SFF_XMarkerReferenceScript extends ObjectReference  
{Script adapted from https://www.creationkit.com/index.php?title=Detect_Player_Cell_Change_(Without_Polling)}

SFF_MentalModelExtender Property MME auto
Actor property playerRef auto

Event OnCellDetach()
	;debug.notification("XMarker cell detached")
	Utility.Wait(0.1) ;maybe not necessary
	MoveTo(playerRef)
	MME.OnCellChange()
EndEvent