Scriptname sff_combatfeed_chance_listener extends ActiveMagicEffect  
import PO3_SKSEFunctions


GlobalVariable Property SFF_HnF_CombatFeed_chance auto
GlobalVariable Property SFF_HnF_BlockChanceCalc auto	;; to stop bugging Hunger Lvl gauge

Actor Serana
Actor[] myTargets
Actor myTarget

Keyword ActorTypeUndead 
Faction CreatureFaction
Race DLC1VampireBeastRace

SPELL Property SFF_HnF_BlockCombatFeed_spell auto
SFF_HungerAndFeedSys Property HnF auto

Int iFeedChance = 20

Event OnEffectStart(Actor akTarget, Actor akCaster)
	ResetChance()
	Serana= akTarget
	RegisterForSingleUpdate(2.0)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	ResetChance()
	UnregisterForUpdate()
EndEvent

Bool Function bIsVL()
	return Serana.GetRace() == DLC1VampireBeastRace
endFunction

Float Function fCurrentActorHealth(actor target)
	;debug.trace ("-> -> -> CUR. HEALTH: " + Serana.GetActorValuePercentage("Health"))
	return target.GetActorValuePercentage("Health")
EndFunction

Function ResetChance()
	iFeedChance= 20/2 ;; make subtractor a global, MCM-modifiable value
	SFF_HnF_CombatFeed_chance.SetValue(0)
EndFunction

Function Add2Chance(int extra)
	if extra <= 0
		return
	endif
	
	iFeedChance += extra
	;debug.trace("SFF: Added " + extra + " to combat feed chance.")
	;debug.trace("SFF: Current feed chance: " + iFeedChance + ".")
EndFunction

Function Feed()
	int random= Utility.RandomInt(0, 100) 
	if random <= iFeedChance
		SFF_HnF_CombatFeed_chance.SetValue(1)
		;debug.trace("-> -> Serana within feed chance! Feed!")
		return
	endif
	SFF_HnF_CombatFeed_chance.SetValue(0)
	;debug.trace("-> -> (" + random +"/"+ iFeedChance + ") Serana not within feed chance yet. Roll again...")
EndFunction

Event OnUpdate()
	ResetChance()					;; reset, so chance don't stack up
	if bEnableCombatFeed()
		;SFF_HnF_CombatFeed_chance.SetValue(100)
		iFeedChance= 100
		if Serana.HasSpell(SFF_HnF_BlockCombatFeed_spell)
			Serana.RemoveSpell(SFF_HnF_BlockCombatFeed_spell)
		endif
	endIf
	
	Feed()
	RegisterForSingleUpdate(5.0)	;; loop
EndEvent

Bool Function bEnableCombatFeed()
	if bIsVL()
		debug.trace("SFF: Serana in VL form. Cannot combat feed.")
		return FALSE
	endif	
	
	if SFF_HnF_BlockChanceCalc.GetValue() == 1
		debug.trace("SFF: Feeding anim. playing. Blocking combat feed chance calculator...")
		return FALSE
	endif
	
	;; IF LOW HEALTH
	if fCurrentActorHealth(Serana) <= 0.45
		RETURN TRUE
		debug.trace("SFF: Low health... FEED!")
	elseif fCurrentActorHealth(Serana) <= 0.75
		Add2Chance(10)
	endif
	
	;; IF VERY HUNGRY
	if HnF.iHungerLvl > 2
		debug.trace("SFF: Serana famished... FEED!")
		RETURN TRUE
	else
		Add2Chance(HnF.iHungerLvl*10)
	endif
	
	;; IF FIGHTING LAST / ONE ENEMY
	myTargets = GetCombatTargets(Serana)
	if myTargets.length as Float == 1.0
		myTarget = Serana.GetCombatTarget()
		if !myTarget.HasKeyword(ActorTypeUndead) && !myTarget.IsInFaction(CreatureFaction) && !myTarget.IsCommandedActor()
			if fCurrentActorHealth(myTarget) <= 0.5
				debug.trace("SFF: Lone target... FEED!")
				RETURN TRUE
			endif
			
			Add2Chance(20)	;; increase chance of feeding, but not 100%
		endIf
	endIf
	
	RETURN FALSE
EndFunction