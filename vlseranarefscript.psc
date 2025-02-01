Scriptname VLSeranaRefScript extends ReferenceAlias  

Actor SeranaRef
Actor PlayerRef

Ammo ElderScrollAmmo

;GlobalVariable Property SFF_VLSeranaLevelGlobal Auto

Race Property VampireLordRace auto

Spell Property VLSeranaCooldownSpell Auto
Spell Property VLSeranaTransformToNormal Auto
Spell Property VLSeranaTransformToVL Auto

Quest Property SFFMentalModelExtender Auto

Bool Function IsSeranaVampireLord()
	Return (SeranaRef.GetRace() == VampireLordRace)
EndFunction

Event OnInit()
	SeranaRef = GetActorRef()
	PlayerRef= Game.GetPlayer()
	;SFF_VLSeranaLevelGlobal.SetValue(SeranaRef.GetLevel())
	ElderScrollAmmo= (SFFMentalModelExtender as SFF_MentalModelExtender).DLC1ElderScrollBack
EndEvent

Event OnActivate(ObjectReference akActionRef)
	If(akActionRef == PlayerRef)
		If(IsSeranaVampireLord() && !SeranaRef.IsInCombat())
			Debug.Trace("SFF_VL: Combat stopped but Serana still in VL form. Oops! Should transform back...")
			(SFFMentalModelExtender As SFF_MentalModelExtender).bBusyTransforming = True
			VLSeranaTransformToNormal.Cast(SeranaRef, SeranaRef)
			;; SFF v1.2.1: strange bug where Serana will not return to human form. Only a disable-enable chain will reset her.
			;; SFF v1.4.0: disable-enable chain fixes microstuttering when transforming back from VL form. Added at end of 'VLSeranaTransformToNormalEffectScript'. No need for it here! - SFF v1.7.1: disable-enable chain removed from said script, so needed here!
			SeranaRef.Disable()	
			SeranaRef.Enable()
		EndIf
	EndIf
EndEvent

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	If(IsSeranaVampireLord())
		If(ElderScrollAmmo == (akBaseObject As Ammo))
			(SFFMentalModelExtender as SFF_MentalModelExtender).bElderScrollEquipped = True
			SeranaRef.UnequipItem(ElderScrollAmmo, True, True)
		EndIf
	EndIf
EndEvent

Event OnRaceSwitchComplete()
	if (!IsSeranaVampireLord())
		SeranaRef.DispelSpell(VLSeranaTransformToNormal)
		SeranaRef.SetGhost(False)

		If((SFFMentalModelExtender as SFF_MentalModelExtender).bElderScrollEquipped)
			SeranaRef.EquipItem(ElderScrollAmmo, True)
		EndIf

		SeranaRef.EvaluatePackage()

		If((SFFMentalModelExtender as SFF_MentalModelExtender).bShouldBleedOut)
			;Debug.Notification("Serana must BLEED!")
			SeranaRef.DamageActorValue("Health", (SeranaRef.GetActorValue("Health")/SeranaRef.GetActorValuePercentage("Health") * 1.0) + 1)
			;SeranaRef.KillSilent()
		EndIf

		(SFFMentalModelExtender as SFF_MentalModelExtender).bShouldBleedOut = False

		VLSeranaCooldownSpell.Cast(SeranaRef, SeranaRef)
	Else
		SeranaRef.SetGhost(False)

		If(!SeranaRef.IsSneaking())
			SeranaRef.StartSneaking()
		EndIf

		SeranaRef.EvaluatePackage()
		StartTracking()
 	endif

	(SFFMentalModelExtender as SFF_MentalModelExtender).bBusyTransforming = False
EndEvent



;=========================================
; Functions based on DLC1PlayerVampireChangeScript quest script
;=========================================

Function StartTracking()

    ;SeranaRef.UnequipAll()
	
	;; sff v1.7.1 -------
	;; for removing torch (or any other item) from left hand before transformation 
	;; NOTE: item not removed immediately: slight delay, with unequipping only happening after all effects finished...
	;; ideally, this should go in 'SFF_VampireLordHandler' script, firing as soon as conditions are met.
	;; HOWEVER, condition being met does not guarantee transformation will occur (cooldown/location blocker, etc)
	
		Form EquippedItemL = SeranaRef.GetEquippedObject(0) ; Check Left Hand
		
		if EquippedItemL != none
			SeranaRef.UnequipItemEx(EquippedItemL, 2)
		endif
	;; -------------------

	
    SeranaRef.EquipItem((SFFMentalModelExtender as SFF_MentalModelExtender).GetVLSeranaArmor(),  True, True)
	if (SFFMentalModelExtender as SFF_MentalModelExtender).GetVLSeranaCloak() != none
		SeranaRef.EquipItem((SFFMentalModelExtender as SFF_MentalModelExtender).GetVLSeranaCloak(),  True, True)	;; SFF v1.2.0
	endif

; ---------------------------------------------------------------------------------------------------------------------
; TO DO START CHECKING BELOW HERE PROBABLY WANT TO IMPLEMENT SOME OF THIS STUFF
; ---------------------------------------------------------------------------------------------------------------------

    ; Remove vampire powers
    ;PlayerActor.RemoveSpell(VampireSunDamage01)
    ;PlayerActor.RemoveSpell(VampireSunDamage02)
    ;PlayerActor.RemoveSpell(VampireSunDamage03)
    ;PlayerActor.RemoveSpell(VampireSunDamage04)

    ; Add Vampire Lord Abilities
    ;PlayerActor.AddSpell(DLC1VampireLordSunDamage, false)
    ;PlayerActor.AddSpell(LeveledAbility, false)
    ;PlayerActor.AddSpell(VampireHuntersSight, false)

    ; Add the Revert spell
    ;PlayerActor.AddSpell(DLC1Revert, false)

    ; Add & equip Vampire Powers
    ;PlayerActor.AddSpell(DLC1VampireBats, false)
    ;PlayerActor.EquipSpell((DialogueGenericVampire as VampireQuestScript).LastPower, 2)
;    if PlayerActor.HasSpell(LeveledRaiseDeadSpell) == False
;        PlayerActor.AddSpell(LeveledRaiseDeadSpell, false)
;    endif

    ;CheckPerkSpells()
    ;if PlayerActor.HasPerk(Lightfoot) == true
    ;    DLC1HasLightfoot = true
    ;else
    ;    DLC1HasLightfoot = false
    ;    PlayerActor.AddPerk(Lightfoot)
    ;endif

	SeranaRef.DispelSpell(VLSeranaTransformToVL)
EndFunction