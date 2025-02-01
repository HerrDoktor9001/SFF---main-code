Scriptname sff_vl_condition_listener extends ActiveMagicEffect  

SFF_VampireLordHandler Property VLH auto

Event OnInit()
	;debug.Trace("[INFO] SFF:: 'DialogueDetector' Magic Effect script successfully initialised!")
EndEvent

Event OnEffectStart(Actor akTarget, Actor akCaster)
	VLH.EnableChecks()
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	VLH.DisableChecks()
EndEvent