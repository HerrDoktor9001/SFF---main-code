Scriptname VLSeranaAllowTransformEffectScript extends activemagiceffect  

GlobalVariable Property VLSeranaInterestingCombatTargets Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	VLSeranaInterestingCombatTargets.SetValue(1)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	VLSeranaInterestingCombatTargets.SetValue(0)
EndEvent