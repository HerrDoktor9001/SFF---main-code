Scriptname sff_Teleport2CairnEffect extends activemagiceffect  

ObjectReference property SoulCairnPortal auto
Actor Property PlayerRef auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	;PlayerRef.MoveTo(SoulCairnPortal)
	Game.FastTravel(SoulCairnPortal)
	Debug.Trace("Player teleported to Soul Cairn")
EndEvent