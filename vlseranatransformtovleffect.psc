Scriptname VLSeranaTransformToVLEffect extends ActiveMagicEffect  

Sound Property VampireIMODSound auto
Spell Property VLSeranaChangeFX auto

Actor SeranaRef

Event OnEffectStart(Actor Target, Actor Caster)
	SeranaRef = Target
	PrepShift()
	VLSeranaChangeFX.Cast(Target, Target)
EndEvent

Function PrepShift()
	VampireIMODSound.Play(SeranaRef)

	;
	; not sure if we want to do this for Serana. Code snippet from: DLC1PlayerVampireChangeScript (quest script)
	;
	; get rid of your summons
	;int count = 0
	;while (count < VampireDispelList.GetSize())
	;	Spell gone = VampireDispelList.GetAt(count) as Spell
	;	if (gone != None)
	;		PlayerActor.DispelSpell(gone)
	;	endif
	;	count += 1
	;endwhile

	;
	; Not sure if we need the following code snippet from DLC1PlayerVampireChangeScript (quest script) for Serana:
	;
	; First, establish our leveled spells. The player cannot level up while
	; a Vampire Lord so we only need to do this once.
	;EstablishLeveledSpells()
EndFunction