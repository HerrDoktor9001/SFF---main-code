Scriptname sff_dialoguedetectorscript extends activemagiceffect  
;; also used to detect if Serana using furnitur or not ('SFF_IsSeranaUsingFurniture' GlobalVar)

GlobalVariable Property SFF_IsSeranaSpeaking Auto

Event OnInit()
	;debug.Trace("[INFO] SFF:: 'DialogueDetector' Magic Effect script successfully initialised!")
EndEvent

Event OnEffectStart(Actor akTarget, Actor akCaster)
	SFF_IsSeranaSpeaking.SetValue(1)
	;debug.Trace("[INFO] SFF:: 'DialogueDetector' returned positive: Serana is talking.")
	;debug.notification("Serana SPEAKING.")
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	SFF_IsSeranaSpeaking.SetValue(0)
	;debug.Trace("[INFO] SFF:: 'DialogueDetector': Serana no longer talking.")
EndEvent