Scriptname VLSeranaChangeFXEffect extends ActiveMagicEffect  

Ammo Property ElderScrollAmmo Auto

Race Property DLC1VampireLordRace auto

Idle Property IdleVampireTransformation auto
Explosion Property FXVampChangeExplosion auto

Quest Property SFFMentalModelExtender auto

SPELL Property VLSeranaDLC1AbVampireFloatBodyFX  Auto
	{Spell FX Art holder for Levitation Glow.}

Actor SeranaRef

Event OnEffectStart(Actor Target, Actor Caster)
	SeranaRef = Target
	Debug.Trace("SFF_3: VL change magic effect cast. Should transform soon...")

	 if (SeranaRef.GetActorBase().GetRace() != DLC1VampireLordRace)
		SeranaRef.PlayIdle(IdleVampireTransformation)
		TransformIfNecessary(SeranaRef)
	endif
EndEvent

Function TransformIfNecessary(Actor Target)
	if (Target == None)
		return
	endif

	Race currRace = Target.GetRace()

	if (currRace != DLC1VampireLordRace)

		(SFFMentalModelExtender as SFF_MentalModelExtender).NormalSeranaRace = currRace
		InitialShift()

		; I added this explosion and blood to give the transition some pop!
		target.placeatme(FXVampChangeExplosion)	
	endif

EndFunction

; This function is based on function of the same name in DLC1PlayerVampireQuest script
Function InitialShift()
    
	;
	; Not sure if we need this for Serana. Think not?
	;
	; The player needs to be invulnerable and ghosted during the transition.
	; We want to bracket the SetRace calls with this. OnRaceSwitchComplete
	; in DLC1PlayerVampireScript will turn these off.
	;PlayerActor.GetActorBase().SetInvulnerable( true )
	SeranaRef.SetGhost( true )

	; actual switch	
	(SFFMentalModelExtender as SFF_MentalModelExtender).bElderScrollEquipped = (SeranaRef.IsEquipped(ElderScrollAmmo))

	;If(!(SFFMentalModelExtender as SFF_MentalModelExtender).bElderScrollEquipped)
		;Debug.Notification("Scroll was not equipped!")
	;Else
		;Debug.Notification("Scroll was equipped!")
	;EndIf
	(SFFMentalModelExtender as SFF_MentalModelExtender).SpellManager(0)
	SeranaRef.SetRace(DLC1VampireLordRace)
	SeranaRef.AddSpell(VLSeranaDLC1AbVampireFloatBodyFX, abVerbose = False)
EndFunction