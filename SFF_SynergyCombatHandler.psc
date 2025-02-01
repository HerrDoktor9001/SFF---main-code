Scriptname SFF_SynergyCombatHandler extends ReferenceAlias  

SFF_MentalModelExtender Property MME auto
;SDECustomMentalModel Property SDE auto

Actor Property Serana auto
ObjectReference SeranaObjRef
ObjectReference PlayerObjRef
ReferenceAlias Property SeranaAlias auto
GlobalVariable Property SFF_MCM_Synergy auto
GlobalVariable Property SFF_MCM_SynergyAffinityOnly auto	;; SFF v1.2.0 ~ to enable affinity-skill gain decoupling. 


Float fMeter								;; meter that fills by 'fFillAmount' while Serana in combat (PERSISTANCE)
Float Property fFillAmount = 1.0 auto		;; amount to fill 'fMeter' by every 'fUpdateInterval' seconds
Float Property fUpdateInterval = 1.0 auto	;; call OnUpdate every x seconds
Float Property fMeterMax = 300.0 auto
Float fMult									;; Relationship skill meter multiplier
;; fill meter by 1 every second (if Relationship value == 0). If meter reaches 300, it means 300s (i.e., 5m) have passed in combat (if Relationship value == 0)

Float fAffectionMeter = 0.0						;; PERSISTANCE
Float Property fAffectionMeterMax = 300.0 auto
Float fDifficulty = 1.0							;; PERSISTANCE
Float Property fIncrement = 0.15 auto

Event OnInit()
if MME.bIsSDEInstalled
	Debug.Notification("Synergy Handler reloaded")
	;PlayerRef= Game.GetPlayer()
	PlayerObjRef= Game.GetPlayer()
	Serana = SeranaAlias.GetActorReference()
	SeranaObjRef= Serana as ObjectReference
	InitializeVars()
endif
EndEvent

Function InitializeVars()
	fMeter= MME.fMeterBackUp 							;; on reload, grab backed up fMeter value
	fAffectionMeter= MME.fAffectionMeterBackUp
	fDifficulty= MME.fDifficultyBackUp
	if fDifficulty < 1.0								;; make sure script does not inherit null value here from MME
		fDifficulty= 1.0
	endif
EndFunction

Event OnCombatStateChanged(Actor akTarget, int aeCombatState)

	if SFF_MCM_Synergy.GetValue() == 1 && MME.bIsSDEInstalled
		if (aeCombatState == 0)
			;Debug.Notification("Serana left combat! " + fMeter)
			UnregisterForUpdate()
			if SFF_MCM_SynergyAffinityOnly.GetValue() != 1	;; only send xp if enabled
				if fMeter >= fMeterMax	;; send 'fMeter' value to be weighted 
					SendAndReset()
				endif 
			endif
			if MME.bIsSDEInstalled	;; SFF v1.2.0 ~only call affction gauge if SDE installed
				poolAffection()
			endif
		
		elseif (aeCombatState == 1)
		  ;Debug.Notification("Serana entered combat!")
		  GaugeRelationship ()
		  RegisterForSingleUpdate(fUpdateInterval)
		  
		elseif (aeCombatState == 2)
		  ;Debug.Notification("Serana searching...")
		  UnregisterForUpdate()
		endIf
	endif
endEvent

Event OnUpdate()
	if SeranaObjRef.GetDistance(PlayerObjRef) < 2000
		CombatXP()
		;Debug.Notification("Serana Close...")
	else
		RegisterForSingleUpdate(fUpdateInterval)
		Debug.Trace("SFF_SynergySys: Serana not near player. Synergy stopped!")
	endif
EndEvent

Function GaugeRelationship ()
;; check relationship status/level/affinity and normalise it between a 0.5 and 1.5 range.
;; Set "fMult" to this value.

	int RelVar= (MME.SDEQuest as SDECustomMentalModel).SDECMMRelVar	;; SFF v1.1.0
	fMult= (((RelVar as float - -50.0) / 100.0)) + 0.5   ;-200=0,5; -150=0,625; -100=0,75; -50=0,875; 0=1; 50=1,125; 100=1,250; 150=1,375; 200=1,5
	Debug.Trace ("SFF_SynergySys: Affinity level gauge called. Cur. affinity: " +RelVar+". Multiplier = " + fMult)
EndFunction														; -50=0,5; -25=0,75; -10=0,9; 0=1; 10=1,1; 25=1,25; 50=1,5 

Function CombatXP ()					;; timer fired when Serana enters combat
		fMeter += fFillAmount*fMult 
		fAffectionMeter += fFillAmount*fMult			;; fill affection bar.
		RegisterForSingleUpdate(fUpdateInterval)
EndFunction

Function SendAndReset()
	fMeter= fMeter - fMeterMax	;; removes 300 from fMeter instead of zeroing, so fractions still kept in meter
	Send2Player() 				;; send xp to Player
	;; send affection points
EndFunction

Function Send2Player ()
	;; randomise skill to be chosen
	;; send x amount of that skill to player. 
	;; constant value times relationship level (0.5 -1.5) equals to x
	
	string skill=""
	int random= Utility.RandomInt(1,5)
	
 	if (random ==1)
		skill= "Alchemy"
	elseif (random ==2)
		skill= "Conjuration"
	elseif (random ==3)
		skill= "Destruction"
	elseif (random ==4)
		skill= "OneHanded"
	else 
		skill= "LightArmor"
	endif 
	
	float x = 15.0 * fMult
	Game.AdvanceSkill(skill, x) 
	
	Debug.Notification("Synergy Skill Added: " + skill + ", " + x as Int + " xp")
	Debug.Trace("Synergy Skill Added: " + skill + ", " + x as Int + " xp")
EndFunction

Function poolAffection ()
	
	if fAffectionMeter >= fAffectionMeterMax*fDifficulty					;; Call code when it fills up and add difficulty multiplier.
		;SDE.SeranaLikes()													;; increase general relationship
		MME.CallSDESetter (0) ;; 0- 'likes'; 1- 'loves'
		fAffectionMeter= fAffectionMeter-(fAffectionMeterMax*fDifficulty)	;; resets bar but keeps any extra gains
		fDifficulty += fIncrement											;; increase difficulty by multiplier. 
		Debug.Trace("SFF_SynergySys: Affection point added")
	endif
EndFunction

Function BackUpVars ()
if MME.bIsSDEInstalled
	MME.fMeterBackUp= fMeter
	MME.fAffectionMeterBackUp= fAffectionMeter
	MME.fDifficultyBackUp= fDifficulty
	Debug.Notification("Synergy Handler backed up")
endif
EndFunction