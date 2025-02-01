Scriptname VLSeranaTransformToNormalEffectScript extends ActiveMagicEffect  

EffectShader Property DLC1VampireChangeBackFXS Auto
EffectShader Property DLC1VampireChangeBack02FXS Auto

Sound Property VampireIMODSound auto

Spell Property VLSeranaDLC1AbVampireFloatBodyFX Auto

Quest Property SFFMentalModelExtender Auto

Actor SeranaRef

Event OnEffectStart(Actor akTarget, Actor akCaster)
	SeranaRef = akTarget

	while (SeranaRef.GetAnimationVariableBool("bIsSynced"))
		Utility.Wait(0.1)
	endwhile

	ActuallyShiftBackIfNecessary()
EndEvent

Function ActuallyShiftBackIfNecessary()

    VampireIMODSound.Play(SeranaRef)

    ;  We now add the effect with a long duration and remove it later.
    DLC1VampireChangeBackFXS.Play(SeranaRef,12.0)

    ; get rid of your summons if you have any
;    int count = 0
;    while (count < VampireDispelList.GetSize())
;        Spell gone = VampireDispelList.GetAt(count) as Spell
;        if (gone != None)
;            ;Debug.Trace("VAMPIRE: Dispelling " + gone)
;            PlayerActor.DispelSpell(gone)
;        endif
;        count += 1
;    endwhile


    ; clear out perks/abilities
    ;PlayerActor.RemoveSpell(LeveledDrainSpell)
    ;PlayerActor.RemoveSpell(LeveledAbility)
    ;PlayerActor.RemoveSpell(LeveledRaiseDeadSpell)

    ;PlayerActor.RemoveSpell(DLC1VampiresGrip)
    ;PlayerActor.RemoveSpell(DLC1ConjureGargoyleLeftHand)
    ;PlayerActor.RemoveSpell(DLC1CorpseCurse)
    ;PlayerActor.RemoveSpell(DLC1VampireDetectLife)
    ;PlayerActor.RemoveSpell(DLC1VampireMistForm)
    ;PlayerActor.RemoveSpell(DLC1VampireBats)
    ;PlayerActor.RemoveSpell(DLC1SupernaturalReflexes)
    ;PlayerActor.RemoveSpell(DLC1NightCloak)
    ;PlayerActor.RemoveSpell(DLC1Revert)
    ;PlayerActor.RemoveSpell(DLC1VampireLordSunDamage)

    ; You might want to add these spells to the VampireDispelList
    ; and then delete the next four DispelSpell lines.
    ;PlayerActor.DispelSpell(DLC1VampireDetectLife)
    ;PlayerActor.DispelSpell(DLC1VampireMistform)
    ;PlayerActor.DispelSpell(DLC1SupernaturalReflexes)
    ;PlayerActor.DispelSpell(DLC1Revert)
    ;PlayerActor.DispelSpell(VampireHuntersSight)

    SeranaRef.RemoveSpell(VLSeranaDLC1AbVampireFloatBodyFX)

    ;turn off all the vampire necklace/ring variables when we change back
    ;pDLC1nVampireNecklaceBats.setValue(0)
    ;pDLC1nVampireNecklaceGargoyle.setValue(0)
    ;pDLC1nVampireRingBeast.setValue(0)
    ;pDLC1nVampireRingErudite.setValue(0)

    ; Restore current stage vampirism:
    ;PlayerVampireQuest.VampireProgression(PlayerActor, PlayerVampireQuest.VampireStatus)

; PREVIOUSLY- just turned the player always into stage 4 vampire
;/
    ;VampireFeedReady.SetValue(3)
    ;PlayerActor.AddSpell(AbVampire04, abVerbose = False)
    ;PlayerActor.AddSpell(AbVampire04b, abVerbose = False)
    ;PlayerVampireQuest.VampireStatus = 4

    ;PlayerActor.RemoveSpell(VampireDrain01)
    ;PlayerActor.RemoveSpell(VampireDrain02)
    ;PlayerActor.RemoveSpell(VampireDrain03)		
    ;PlayerActor.AddSpell(VampireDrain04, abVerbose = False)		
    ;PlayerActor.RemoveSpell(VampireRaiseThrall01)
    ;PlayerActor.RemoveSpell(VampireRaiseThrall02)
    ;PlayerActor.RemoveSpell(VampireRaiseThrall03)
    ;PlayerActor.AddSpell(VampireRaiseThrall04, abVerbose = False)
    ;PlayerActor.RemoveSpell(VampireSunDamage01)
    ;PlayerActor.RemoveSpell(VampireSunDamage02)
    ;PlayerActor.RemoveSpell(VampireSunDamage03)
    ;PlayerActor.AddSpell(VampireSunDamage04, abVerbose = False)	
    ;PlayerActor.AddSpell(VampireInvisibilityPC, abVerbose = False)	
    ;PlayerActor.AddSpell(VampireCharm, abVerbose = False)	
;    PlayerActor.AddSpell(VampireHuntersSight, abVerbose = False)	
/;
    ;SendShrinesIsPlayerVampireLord(false)

    ; make sure your health is reasonable before turning you back
    ; PlayerActor.GetActorBase().SetInvulnerable(true)
    ;PlayerActor.SetGhost()
    float currHealth = SeranaRef.GetAV("health")
    if (currHealth <= 70)

		If(currHealth <= 5)
			;; this tells us that Serana should be set to bleed out after transformation complete
			(SFFMentalModelExtender as SFF_MentalModelExtender).bShouldBleedOut = True
		EndIf

		; Note: if Serana is transformed with low or no health, she'll be stuck in VL form... why? no idea...
		SeranaRef.RestoreAV("health", 70 - currHealth)
	endif
	(SFFMentalModelExtender as SFF_MentalModelExtender).SpellManager(1)
    ; change you back
	;SeranaRef.UnequipAll()	;; SFF v1.2.1
    
	;; SFF v1.4.1 ~ check if items are in use first, THEN unequip and remove if necessary
	if SeranaRef.IsEquipped((SFFMentalModelExtender as SFF_MentalModelExtender).GetVLSeranaArmor())
		SeranaRef.UnequipItem((SFFMentalModelExtender as SFF_MentalModelExtender).GetVLSeranaArmor())
		SeranaRef.RemoveItem((SFFMentalModelExtender as SFF_MentalModelExtender).GetVLSeranaArmor(), 1, true)
	endif
	
	;; check if cloak value is not "none"
	if (SFFMentalModelExtender as SFF_MentalModelExtender).GetVLSeranaCloak() != none && SeranaRef.IsEquipped((SFFMentalModelExtender as SFF_MentalModelExtender).GetVLSeranaCloak())	
		SeranaRef.UnequipItem((SFFMentalModelExtender as SFF_MentalModelExtender).GetVLSeranaCloak())
		SeranaRef.RemoveItem((SFFMentalModelExtender as SFF_MentalModelExtender).GetVLSeranaCloak(), 1, true)
	endif
    SeranaRef.SetRace((SFFMentalModelExtender as SFF_MentalModelExtender).NormalSeranaRace)
	

    ;  We remove the Effect shader here now. And now we also try to book end it with another shader.
    DLC1VampireChangeBackFXS.stop(SeranaRef)
    DLC1VampireChangeBack02FXS.Play(SeranaRef,0.1)
		
	;; SFF v1.4.0
	if SeranaRef.IsPlayerTeammate()	;; to make sure will not conflict with specific scenes
		;; to avoid stutter/freezing when coming back to human form
		;; sff v1.6.0 - this seems to cause strange behaviour with magic effects not being applied
		;SeranaRef.Disable()
		;SeranaRef.Enable()
	endif
	
    ; <<TAKE BACK POWERS IF NECESSARY>>

    ; gimme back mah stuff
    ; We don't need to do this here. DLC1PlayerVampireScript.psc will restore
    ; all items previously equipped using the PopEquippedItems call.
    ; PlayerActor.EquipSpell(DLC1VampireChange, 2)	

EndFunction