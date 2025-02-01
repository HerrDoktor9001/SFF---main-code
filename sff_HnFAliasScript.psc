Scriptname sff_HnFAliasScript extends ReferenceAlias  
{Extension of 'SFF_HungerAndFeedSys'. Listens for Activation Event, so we don't need to pool Feed Blocking code OnUpdate}

SFF_HungerAndFeedSys Property HnFS auto

Event OnActivate(ObjectReference akActionRef)
	if akActionRef == Game.GetPlayer()
		HnFS.FeedBlocker()
	endif
EndEvent