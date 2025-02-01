Scriptname VLSeranaCloakApplyingEffectScript extends ActiveMagicEffect  

ReferenceAlias Property SeranaRef auto
Spell Property VLSeranaBlockVampireLord auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If(!akTarget.IsDead())
		Actor Serana = SeranaRef.GetActorRef()
		VLSeranaBlockVampireLord.Cast(Serana, Serana)
	EndIf
EndEvent