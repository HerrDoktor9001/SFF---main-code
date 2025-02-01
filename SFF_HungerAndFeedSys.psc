Scriptname SFF_HungerAndFeedSys extends Quest conditional
{Script for managing code related to Serana's Hunger & Feeding system. Runs on an independent quest ('SFF_HungerAndFeedQuest')}
import PO3_SKSEFunctions		;; SFF v1.6.0 ~ for managing base spell (VampireRaiseThrall)
import ANDR_PapyrusFunctions	;; SFF v1.6.0 ~ for enabling better handling of potion use 
import MiscUtil					;; SFF v1.6.0 ~ for enabling scanning cell for Serana ref. (to enable selective feeding)

;; [DONE] add dynamic spell change
;; [DONE] tie to SDE relationship framework
;; [DONE] voiced lines
	;; [DONE] add exit dialogue lines (after feeding)
;; [DONE] implement use of potion use
;; [DONE] implement health restoration dynamic
;; MCM integration (toggles [DONE], feed interval [PENDING])

DLC1_NPCMentalModelScript Property MM auto  ;; Serana AI (MentalModel)
SFF_MentalModelExtender Property MME auto	;; AI Extender

Actor PlayerRef
Actor Property Serana auto

Race DLC1VampireBeastRace		;; vampire lord race 

Faction Property CreatureFaction auto	;; for filtering Actors and block feed
Faction Property VampireFaction auto	;; for filtering Actors and block feed
;Faction Property DLC1DawnguardFaction auto	;; sff v1.7.1
Faction Property DLC1HunterFaction auto	;; sff v1.7.2
Keyword Property LocTypeHabitation auto ;; for filtering Locations and block feed

GlobalVariable Property GameDaysPassed auto		;; vanilla alternative to 'Game.GetCurrentGameTime()'
GlobalVariable Property SFF_MCM_HungerSys auto 			;; Hunger sys. toggle
GlobalVariable Property SFF_MCM_HungerSys_dynamicSpells auto ;; enables adding leveled spells tied to hunger
GlobalVariable Property SFF_MCM_HungerSys_bloodPotion auto 	 ;; enables Serana to use blood potions to fill hunger
GlobalVariable Property SFF_MCM_HungerSys_selectiveFeeding auto 	 ;; blocks feeding if specific conditions met


;; SDE affinity lvl 
Int iMinRelLevel = 30	;; minimum SDE relationship lvl necessary for enabling hunger
Int Property iAffinitySink= 0 auto Conditional	;; store here all feed relationship tokens, to help determine if Serana should 'like' or 'love' our actions
Int iTier01 = 15		;; more than this and we go to next level
Int iTier02 = 30		;; more than this and we go to next level


Bool Property bIsHungry auto conditional 		;; for enabling dialogue line (due to HUNGER)
Bool Property bCanPlayDiag auto conditional 	;; for enabling radiant dialogue to indicate Serana is hungry
Bool Property bCanPlayExitDiag auto conditional ;; for enabling post-feed remarks
Bool Property bIsLowHealth auto conditional 	;; for enabling dialogue line (due to LOW HEALTH)
Bool Property bBlockDiag auto conditional		;; for determining if feeding should be blocked (due to people nearby)
int Property iHungerLvl = 0	auto Conditional	;; for determining how hungry Serana is. Add a level every day passed without feeding

;; commentary management properties
Bool Property bDiag_ThankYou auto conditional
Bool Property bDiag_ImGladYoureHere auto conditional
Bool Property bDiag_IllRemember auto conditional

;;SPELLS
SPELL PROPERTY crABVampire auto				;; Vampire Weaknesses spell. Adds frost resist. and fire weakness.

FormList Property SFF_HnF_SpellsRemovalList  Auto	;; list containing all of our managed spells
;; Raise Thrall

;; Fire Weakness
SPELL spell2Add_Weakness2Fire
SPELL Property AbVampire01b auto
SPELL Property AbVampire02b auto 
SPELL Property AbVampire03b auto 
SPELL Property AbVampire04b auto 

;; Frost Resist.
SPELL spell2Add_FrostResist
SPELL Property AbVampire01 auto
SPELL Property AbVampire02 auto 
SPELL Property AbVampire03 auto 
SPELL Property AbVampire04 auto 

;; Potion mech.
POTION PROPERTY DLC1BloodPotion Auto


Event OnInit()
	;; spell has to be removed via CK, else its effects continue to linger;
	;; thus, re-add it here, via script, so if Player does NOT want to use feature,
	;; Serana will still have access to removed spell.
	if !Serana.HasSpell(crABVampire)
		Serana.AddSpell(crABVampire)
	endif
	
	Setup()
EndEvent


;; call this from MCM on enable
Function Setup()
	;; if feature disabled or Serana already cured, stop code
	if SFF_MCM_HungerSys.GetValue() != 1 || MME.bCured
		debug.trace("SFF:: HungerMech.:: Serana already cured or Hunger&Feeding Mech. disabled. Aborting code...")
		return
	endif
	
	PlayerRef= Game.GetPlayer()					;; grab Player ref. 
	DLC1VampireBeastRace=  Game.GetFormFromFile(0x0200283A,"Dawnguard.esm") As Race
	
	ScheduleNextHunger() ;; schedule feed so 'SFF_NextFeedTime' is not empty 
	
	RegisterForSingleUpdateGameTime(fInterval)	;; start UpdateGameTime loop 
	RegisterForSingleUpdate(10.0)				;; start Update loop
	Debug.Trace("SFF:: HungerMech.:: Hunger and feeding mech. registered")
	
	FirstPrep()	;; clean slate: remove all associated spells and add base ones
EndFunction

Function FirstPrep()
	;; lets get Serana ready for Hunger&Feeding system:
	;; remove her original spell that gives her a full tier FrostResist and FireWeakness effect
	;; RemoveBaseSpell(Serana, crABVampire)
	if Serana.HasSpell(crABVampire)
		Serana.RemoveSpell(crABVampire)
	endif

	SanitiseSpells()
	
	;; add the most basic spells as substitutes
	Serana.AddSpell(AbVampire01)
	spell2Add_FrostResist= AbVampire01

	Serana.AddSpell(AbVampire01b)
	spell2Add_Weakness2Fire= AbVampire01b
	
	Debug.trace("SFF:: HungerMech.:: Serana's spells sanitised")
EndFunction

;; to be called by MCM script on disable
Function DisableHnF()

	UnregisterForUpdateGameTime()
	UnregisterForUpdate()
	ClearCommentaryFlags()
	SanitiseSpells()
		
	;; if Serana already cured, no need to re-add vamp. debuffs
	if !MME.bCured
		Serana.AddSpell(crABVampire)
	endif
EndFunction

;; cleaning func.: removes all spells in list from Serana
Function SanitiseSpells()
	int count = 0
	
	while (count < SFF_HnF_SpellsRemovalList.GetSize())
		Spell curListedSpell = SFF_HnF_SpellsRemovalList.GetAt(count) as Spell
		Serana.RemoveSpell(curListedSpell)
		count += 1
	endwhile
EndFunction

;; for calculating current time of day
Float Function curTime()
	Float Time = GameDaysPassed.GetValue() ;utility.GetCurrentGameTime()
	Time -= math.Floor(Time) as Float
	Time *= 24 as Float
	return Time
EndFunction

;; checks actor's relative health value
Float Function fCurrentActorHealth(actor target)
	return target.GetActorValuePercentage("Health")
EndFunction

;; for determining if Serana in VL form or not
Bool Function bIsVL()
	if Serana.GetRace() == DLC1VampireBeastRace
		return true
	else
		return false
	endif
EndFunction

Event OnUpdateGameTime()
	;; stop loop if feature disabled
	if MME.bCured
		UnregisterForUpdateGameTime()	;; SFF v1.7.1 - we forgot to unregister it!
		return
	endif
	
	if SFF_MCM_HungerSys.GetValue() != 1
		return
	else
		RegisterForSingleUpdateGameTime(fInterval) ;; loop interval (run this every x hours) (01h)
		;debug.Trace("SFF:: HungerMech.:: Update looped.")
	endif
	
	;; go no further if relationship lvl not high enough (if SDE installed)
	if MME.bIsSDEInstalled && MME.CallSDErelval() < iMinRelLevel
		debug.Trace("SFF:: HungerMech.:: SDE rel. level not high enough! At least " + iMinRelLevel + " needed.")
		return
	endif
	
	;; stop code if Serana currently occupied or unavailable 
	if bIsVL() || Serana.IsInCombat() || !Serana.IsPlayerTeammate() || MM.IsWaiting
		;; Serana not ready to be hungry. Check again in an ingame hour...
		debug.Trace("SFF:: HungerMech.:: Cannot update hunger: Serana busy...")
		return
	endif
	
    if curTime() <= 5.0 || curTime() >= 19.0 						;; feed window: between 19:00 and 05:00
		;debug.Trace("SFF:: HungerMech.:: In Time Window...")
		if GameDaysPassed.GetValue() >= SFF_NextFeedTime
			;; TIME 2 EAT!
			;debug.Trace("SFF:: HungerMech.:: TIME 2 EAT")
			
			if iHungerLvl < 0	;; limit minimum hunger level
				iHungerLvl= 0
			endif
			
			iHungerLvl += 1		;; increment hunger lvl by 01
			
			if iHungerLvl > 3	;; put a cap on hunger lvl
				iHungerLvl= 3
			endif
			
			bIsHungry= true		;; set hunger flag (to enable dialogue entry)
			bCanPlayDiag= true	;; set played flag. Will be reset once dialogue line is said
			
			HungerMessager()	;; notify Player
			HungerEffects()		;; select and add corresponding spells
			UsePotion(true)			;; check if Serana has blood potions
			ScheduleNextHunger()	;; update 'SFF_NextFeedTime' (24 hours from now)
			;; play dialogue, enable dialogue entry
		else
			debug.Trace("SFF:: HungerMech.:: still in interval... Time left for next hunger: " + (SFF_NextFeedTime - GameDaysPassed.GetValue()))
			;; check here for health-related feeding conditions
			;; detect if in towns or if people nearby. Change response accordingly.
			
			;; sff v1.7.1 - makes sure feed dialogue is available as soon as within feed time window, if Serana already thirsty
			if iHungerLvl > 0
				bIsHungry= true
			endif
		endif
    else
		debug.Trace("SFF:: HungerMech.:: not in time interval for feeding...")
		bIsHungry= false ;; so no feed dialogue shows during daytime
	endif
endEvent

Event OnUpdate()
	;; check here for health-related conditions.
	;; if Serana has less than or 75% of health...
	;; call blood potion use
	if bCheckLowHealth()
		debug.trace("SFF:: HungerMech.:: Serana has low health (" + (fCurrentActorHealth(Serana)*100.0) + "%)")
		UsePotion()
	endif

	registerforsingleupdate(10.0) ;; loop code every 10s
EndEvent

Function UsePotion(bool skip= false)
	if SFF_MCM_HungerSys_bloodPotion.GetValue() != 1
		;; feature disabled...
		return
	endif
	if Serana.GetItemCount(DLC1BloodPotion) == 0
		;; Serana has no potions... 
		return
	endif
	
	CastPotion(Serana, DLC1BloodPotion, Serana)					;; apply potion effect
	Serana.RemoveItem(DLC1BloodPotion, 1, true)					;; remove an instance of potion from Inventory
	
	debug.notification("Serana used a Blood Potion")
	debug.trace("SFF:: HungerMech.:: Serana used a Blood Potion")
	
	if iHungerLvl != 0		;; if Blood Potion used, count as feeding
		iHungerLvl -= 1		;; drop hunger lvl (do not reset, like feeding on Player does)
		debug.trace("SFF_FEED: Hunger lvl not zero: " + iHungerLvl)
	endif
	if iHungerLvl == 0		;; if Hunger lvl then reaches 0,
		bCanPlayDiag= false	;; disable commentary ("I'm feeling hungry...")
		bIsHungry = false	;; disable dialogue
		debug.notification("Serana satisfied her hunger.")
	else
		debug.notification("Serana still hungry...")
	endif
	
	bCheckLowHealth()	;; update low health flag - health restored or still depleated?
	
	if !skip	;; as we consider potion as feeding, we need to re-schedule next feed time
				;; but if calling from UpdateGameTime, this function will already be called,
				;; so we can skip it here.
		ScheduleNextHunger()
	endif
EndFunction

Bool Function bCheckLowHealth()
	if fCurrentActorHealth(Serana) > 0.75
		bIsLowHealth= false
		return false
	else
		bIsLowHealth= true
		return true
	endif
EndFunction

Function HungerMessager()
	if iHungerLvl > 3
		return		;; no need to keep bothering Player with hunger status if already past maximum
	endif
	
	if iHungerLvl == 1
		debug.Notification("Serana is hungry.")
		debug.trace("SFF:: HungerMech.:: Serana is hungry.")
	elseif iHungerLvl == 2
		debug.Notification("Serana is famished!")
		debug.trace("SFF:: HungerMech.:: Serana is famished!")
	elseif iHungerLvl == 3
		debug.Notification("Serana is starving!")
		debug.trace("SFF:: HungerMech.:: Serana is starving!")
	endif
EndFunction

Function HungerEffects()
	;; hunger increases frost resist., necro power
	;; hunger increases fire weakness
	;; hunger increases sun damage taken
	
	if SFF_MCM_HungerSys_dynamicSpells.GetValue() != 1
		;; dynamic spells not enabled
		return
	endif
	
	if iHungerLvl == 1
		;; "HUNGRY"
		;; 30% weakness to fire
		;; 30% frost resistance
		UpdateSpells(AbVampire02b, AbVampire02)
				
	elseif iHungerLvl == 2
		;; "FAMISHED"
		;; 40% weakness to fire
		;; 40% frost resistance
		UpdateSpells(AbVampire03b, AbVampire03)
		
	elseif iHungerLvl == 3
		;; "STARVING"
		;; 50% weakness to fire
		;; 50% frost resistance
		UpdateSpells(AbVampire04b, AbVampire04)
		
	elseif iHungerLvl == 0
		;; BASE
		;; 20% weakness to fire
		;; 20% frost resistance
		UpdateSpells(AbVampire01b, AbVampire01)
	endif
EndFunction

Function UpdateSpells(spell spell2add01, spell spell2add02)
	;; remove all spells (aside from our SET spell)
	;; if no  spell SET, set correct one
	spell2Add_Weakness2Fire = spell2add01
	spell2Add_FrostResist = spell2add02
	
	int count = 0
	
	while (count < SFF_HnF_SpellsRemovalList.GetSize())
		Spell curListedSpell = SFF_HnF_SpellsRemovalList.GetAt(count) as Spell
		;if curListedSpell != spell2Add_Weakness2Fire && curListedSpell != spell2Add_FrostResist
		Serana.RemoveSpell(curListedSpell)
		debug.trace(curListedSpell.GetName() + ", " + curListedSpell + ", removed.")
		;endif
		count += 1
	endwhile
	
	if !Serana.HasSpell(spell2add01)
		Serana.AddSpell(spell2add01)
	endif
	if !Serana.HasSpell(spell2add02)
		Serana.AddSpell(spell2add02)
	endif
	debug.trace("SFF:: HungerMech.:: Spells updated")
EndFunction 

;; clears all commentary/dialogue flags. Called from dialogue fragment scripts
;; to make sure entry/exit dialogue lines are not repeated 
Function ClearCommentaryFlags()
	bDiag_ThankYou= false
	bDiag_ImGladYoureHere= false
	bDiag_IllRemember= false
EndFunction

;; called externally from dialogue fragment scripts
Function FeedOnPlayer()
	;; Play anim.
	bCanPlayExitDiag= true	;; tell our Quest exit line can be played (but wait for anim. to finish...
	Serana.PlayIdleWithTarget(IdleVampireStandingFeedFront_Loose, PlayerRef)
	
	;; if 'FeedOnPlayer' gets called due to HEALTH, possibility of 
	;; iHungerLvl being 0 and bugging calculations. 
	if iHungerLvl == 0
		iHungerLvl= 1
		
		if bIsLowHealth
			;; change hunger lvl ro correspond to damage taken (health lvl)
			if fCurrentActorHealth(Serana) < 0.75 && fCurrentActorHealth(Serana) >= 0.60	;; between 60 and 75%
				iHungerLvl= 1
				
			elseif fCurrentActorHealth(Serana) < 0.60 && fCurrentActorHealth(Serana) >= 0.45	;; between 45 and 75%
				iHungerLvl= 2
				
			elseif fCurrentActorHealth(Serana) < 0.45	;; less than 45%
				iHungerLvl= 3
			endif
		endif 
	endif
	
	;; take from Player's health
	float  fPlayerMaxHealth= PlayerRef.GetBaseActorValue("Health")
	float fHealthDamage= fPlayerMaxHealth * (iHungerLvl as float/5.0)	;; amount of health taken depends on Serana's hunger lvl
	float fHealthRestore= fHealthDamage/2
	PlayerRef.DamageActorValue("Health",fHealthDamage as Int)			;; remove from Player,
	Serana.RestoreActorValue("Health", fHealthRestore as Int)			;; add to Serana, but not 1:1 
	
	Utility.Wait(3.0)
	
	if MME.bIsSDEInstalled
		SDEHungerAffinityManager(iHungerLvl)
	endif
	;;reset hunger
	iHungerLvl= 0
	bIsHungry= false
	bCanPlayDiag= false
	
	if !bIsLowHealth
		debug.Notification("Serana satisfied her hunger.")
		debug.trace("SFF:: HungerMech.:: Serana satisfied her hunger.")
	else
		debug.Notification("Serana's health restored.")
		debug.trace("SFF:: HungerMech.:: Serana's health restored.")		
	endif
	
	bCheckLowHealth() ;; check if Serana still has low health
	ScheduleNextHunger()
	UpdateSpells(AbVampire01b, AbVampire01)	;; reset spells
EndFunction

Function SDEHungerAffinityManager(int cache)
;; 1st tier: like, love, love 
;; 2nd tier: nothing, like, love
;; 3rd tier: nothing, nothing, like
;; [cascading affinity gainz]

	iAffinitySink += iHungerLvl
	
	if iAffinitySink <= iTier01 ;; up to 15
		if cache == 1
			MME.CallSDESetter (0) ;; 0- 'likes'; 1- 'loves';  2- 'relishes'
		elseif cache == 2
			MME.CallSDESetter (1) ;; 0- 'likes'; 1- 'loves';  2- 'relishes'
		elseif cache >= 3
			MME.CallSDESetter (2) ;; 0- 'likes'; 1- 'loves'; 2- 'relishes'
		endif
		
	
	elseif iAffinitySink > iTier01 && iAffinitySink <= iTier02  ;; between 15 and 30
		if cache == 2
			MME.CallSDESetter (0) ;; 0- 'likes'; 1- 'loves'
		elseif cache >= 3
			MME.CallSDESetter (1) ;; 0- 'likes'; 1- 'loves'
		endif
		
	elseif iAffinitySink > iTier02	;; > 30
		if cache >= 3
			MME.CallSDESetter (0) ;; 0- 'likes'; 1- 'loves'
		endif
	endif
EndFunction

Function ScheduleNextHunger()
	;; gets current time, adds our base hunger interval, and randomises by adding or removing up to 02 hours from result
	;; to schedule Serana's next hunger check
	float random= Utility.RandomFloat(-0.083, 0.083)	;; make hunger more "dynamic/organic" by randomising next feed limit ( 1.0 = 01 day; 0.0416 = 01 hour (1.0/24); 0.083 = 02 hours
	SFF_NextFeedTime = GameDaysPassed.GetValue() +  SFF_FeedInterval + random
	;Debug.Trace("Next hunger check (InGameTime) set to: " + SFF_NextFeedTime)
	;Debug.Trace("Next hunger check (hours) set to: " + calcTime(SFF_NextFeedTime))
EndFunction

;; //////////////////////// FEED BLOCKING ///////////////////////////
Bool Function FilteredActor(actor myActor)
	if myActor.IsInFaction(CreatureFaction) || myActor.IsPlayerTeammate() || myActor.IsCommandedActor() || myActor.IsGhost() || myActor.IsInFaction(VampireFaction) || myActor == Game.GetPlayer()
		
		;; sff v1.7.1 - stop feeding if in vicinity of Dawnguard members!
		if myActor.IsInFaction(DLC1HunterFaction) && myActor != Game.GetPlayer()
			return false
		endif
		
		return true
	endif
	
	return false
EndFunction

Bool Function FilteredLoc(Location CurrentLocation = None)
	If(CurrentLocation == None)
		CurrentLocation = Serana.GetCurrentLocation()
	EndIf

	If CurrentLocation != None && CurrentLocation.HasKeyword(LocTypeHabitation)
		Return True
	EndIf

	Return False
EndFunction

;; gets called by 'sff_HnFAliasScript' Alias script;
;; called every time Player activates Serana
Function FeedBlocker()
	if SFF_MCM_HungerSys_selectiveFeeding.GetValue() != 1 || !bIsHungry ;; sff v1.6.1 - to stop wasting resources running this every time Serana activated without need 
		;; if feature disabled, abort.
		bBlockDiag= false
		return
	endif
	
	if FilteredLoc()
		;; if we are in a blacklisted cell, no need to check further.
		bBlockDiag= true
		return
	endif
	
	Actor[] loadedActors= ScanCellNPCs(Serana, radius)
	
	int iArraySize= loadedActors.Length
	int indx = 0
	
	while indx < iArraySize
		if !FilteredActor(loadedActors[indx])
			debug.trace(indx + " NPCs were found around Serana's radius of " + radius + " units.")
			debug.trace("SFF:: HungerMech.:: Feeding will be blocked.")
			bBlockDiag= true
			return
		endif
		indx += 1
	endwhile
	bBlockDiag= false
	debug.trace("SFF:: HungerMech.:: No NPCs found within radius. Allow feeding...")
EndFunction

Float radius = 300.0			;; npc search radius 

Float fInterval = 1.0			;; interval for re-checking if not yet feed time (code loop) ('1', 01 hour)

Float Property SFF_FeedInterval = 1.0 auto conditional	;; default interval between feeding ('1', 01 day)	;; let this be manageable via MCM ;; maybe change to 1.5? (1 1/2 days)
Float SFF_NextFeedTime 			;; current time + x day interval
Idle Property IdleVampireStandingFeedFront_Loose auto
