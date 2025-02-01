Scriptname SFF_MCM_Script extends SKI_ConfigBase ;conditional
;import PO3_SKSEFunctions		;; SFF v1.4.0 ;; removed (v1.4.5)
import MiscUtil	;; SFF v1.6.0 ~ to be able to check if .dll plugin installed

;SDECustomMentalModel Property SDE auto
DLC1NPCMonitoringPlayerScript Property MPS auto
SFF_MentalModelExtender Property MME auto
SFF_SunDamageController Property SDC auto 
SFF_VampireLordHandler Property VLH auto
SFF_ChasingEchoesMonitor Property CEM auto
SFF_FollowBesidePlayer Property FBP auto
SFF_HungerAndFeedSys Property HnFS auto ;; sff v1.6.0

;;SFF v1.6.0 ;; keywords for conditional outfit logic
; KEYWORD PROPERTY kSFF_Outfit_Combat auto	;; SFF v1.9.0 - REMOVE! OBSOLETE! [DELETE]
; KEYWORD PROPERTY kSFF_Outfit_Town auto		;; SFF v1.9.0 - REMOVE! OBSOLETE! [DELETE]
; FormList Property SFF_CustomOutfitContList auto  ;; listing of all Custom Outfit containers ;; SFF v1.9.0 - REMOVE! OBSOLETE! [DELETE]


ReferenceAlias Property SeranaAlias  Auto  		;; Serana Alias
ReferenceAlias Property HomeMarkerAlias  Auto  	;; Serana Homemarker Alias
GlobalVariable Property SFF_MCM_HoodBeh auto	;; auto hood behaviour selector
GlobalVariable Property SFF_MCM_OrganicHood auto	;; sff v1.8.0 - if 'auto hood' enabled and Custom Hood left empty, enables looking for a hood in Inventory
GlobalVariable Property SFF_MCM_RelaxHome auto	;; auto relax behaviour selector
GlobalVariable Property SFF_MCM_Backpack auto	;; backpack selector
GlobalVariable Property SFF_MCM_Sandbox auto	;; sandbox selector 
GlobalVariable Property SFF_MCM_AdvancedSandbox auto	;; advanced sandbox toggle ;; SFF v1.2.1
GlobalVariable Property SFF_MCM_AlternativeSandbox auto	;; advanced sandbox toggle ;; SFF v1.2.1
GlobalVariable Property SFF_MCM_VarSideDist auto		;; variable side distance toggle ;; SFF v1.2.1
GlobalVariable Property SFF_MCM_OrganicCompanionMode auto	;; SFF v1.9.0: organic/variable companion mode follow side


GlobalVariable Property SFF_MCM_Teleport auto	;; teleportation selector 
GlobalVariable Property SFF_MCM_AutoCombatHeadGear auto		;; combat headgear controller
GlobalVariable Property SFF_MCM_HorseMount auto		;; horse system enabler
GlobalVariable Property SFF_MCM_HorseFollowMode auto	;; horse follow mode


GlobalVariable Property SFF_MCM_Bugfix_Sneak auto	;; Sneak Mode bug fix
GlobalVariable Property SFF_MCM_Bugfix_Combat auto	;; Combat Mode bug fix
GlobalVariable Property SFF_MCM_Bugfix_Unsheath auto	;; Unsheath Mode bug fix

GlobalVariable Property SFF_MCM_SeranaMarker auto	;; Serana tracker selector
Quest Property SFF_SeranaTracker auto

GlobalVariable Property SFF_MCM_Updater auto
;Quest Property SFF_Updater auto						;; UNUSED! [DELETE]

GlobalVariable Property SFF_MCM_ElderScroll auto
GlobalVariable Property SFF_MCM_SleepOutfit auto
GlobalVariable Property SFF_MCM_Synergy auto
GlobalVariable Property SFF_SunDamage auto
GlobalVariable Property SFF_MCM_QuestSpells auto
GlobalVariable Property SFF_MCM_AltCompanionMode auto
GlobalVariable Property SFF_MCM_CustomOutfitSets auto		;; sff v1.9.0 - USED BY 'SFF_SDEInitialiser'
GlobalVariable Property SFF_MCM_SynergyAffinityOnly auto	;; SFF v1.2.0 ~ to enable affinity-skill gain decoupling. 
;GlobalVariable Property SFF_MCM_CompanionModeSideDist auto


;; VampireLord
GlobalVariable Property SFF_MCM_AllowVL auto		;; enables Vampire Lord transformation
GlobalVariable Property SFF_MCM_VL_Health auto		;; trigger VL if health < X
GlobalVariable Property SFF_MCM_VL_Level auto		;; trigger VL through enemy lvl (X% more than Serana's cur. lvl)
GlobalVariable Property SFF_MCM_VL_Amount auto		;; trigger VL through enemy number (iVLAmount_MCM_SFF)
GlobalVariable Property SFF_MCM_VL_Habitations auto 	;; allow VL transformation in population centers
GlobalVariable Property SFF_MCM_VL_Cloak auto 		;; for determining if Serana should transform in the presence of sensitive NPCs (hold guards, Dawnguard members and Vigilants)

GlobalVariable Property SFF_MCM_VLSeranaRoyalArmorGlobal Auto	;; for determining outfit type
GlobalVariable Property SFF_MCM_VLSeranaCloakGlobal Auto	;; SFF v1.2.0 - for determining if should use cloak or not


GlobalVariable Property iVLAmount_MCM_SFF auto		;; how many enemies will trigger VL
GlobalVariable Property iVLHealth_MCM_SFF auto		;; health threshold
GlobalVariable Property iVLLevel_MCM_SFF auto		;; level threshold (actual level, not the percentage)
GlobalVariable Property iVLLevelPercent_MCM_SFF	auto	;; percentage set by slider, to be used externally to calculate 'iVLLevel_MCM_SFF'.
;GlobalVariable Property SFF_MCM_VL_Spell auto
GlobalVariable Property SFF_MCM_VL_Player auto 
GlobalVariable Property SFF_MCM_VL_Dragon auto 
GlobalVariable Property SFF_MCM_VL_Giant auto 
GlobalVariable Property SFF_MCM_VL_Boss auto 

;; transform indicators (if true, MCM enabled and consitions met. Code must now transform)
;; however, if disabling MCM enabler, corresponding indicator might not get zeroed,
;; so we must erase them as well on toggle.
GlobalVariable Property bVL_TransformNumber auto 
GlobalVariable Property bVL_TransformHealth auto 
GlobalVariable Property bVL_TransformLevel auto 
GlobalVariable Property bVL_TransformDragon auto
GlobalVariable Property bVL_TransformGiant auto
GlobalVariable Property bVL_TransformBoss auto

;; Custom Outfit Containers properties
ObjectReference Property SFF_Outfit01_Container auto conditional
ObjectReference Property SFF_Outfit02_Container auto conditional
ObjectReference Property SFF_Outfit03_Container auto conditional
ObjectReference Property SFF_Outfit04_Container auto conditional 	;sff v1.8.0
ObjectReference Property SFF_Outfit05_Container auto conditional 	;sff v1.8.0

FormList Property SFF_Outfit01_FormList auto
FormList Property SFF_Outfit02_FormList auto
FormList Property SFF_Outfit03_FormList auto
FormList Property SFF_Outfit04_FormList auto	;; sff v1.8.0
FormList Property SFF_Outfit05_FormList auto	;; sff v1.8.0

GlobalVariable Property SFF_MCM_Outfit01 auto
GlobalVariable Property SFF_MCM_Outfit02 auto
GlobalVariable Property SFF_MCM_Outfit03 auto
GlobalVariable Property SFF_MCM_Outfit04 auto	;; sff v1.8.0
GlobalVariable Property SFF_MCM_Outfit05 auto	;; sff v1.8.0
GlobalVariable Property SFF_MCM_SelectedOutfit auto		;; sff v1.6.1 - for determining which outfit to set on menu close


;; v1.6.0
GlobalVariable Property SFF_MCM_CondO_Town_01 auto
GlobalVariable Property SFF_MCM_CondO_Town_02 auto
GlobalVariable Property SFF_MCM_CondO_Town_03 auto
GlobalVariable Property SFF_MCM_CondO_Town_04 auto	;; sff v1.8.0
GlobalVariable Property SFF_MCM_CondO_Town_05 auto	;; sff v1.8.0

;; v1.6.1
GlobalVariable Property SFF_MCM_CondO_Hoodie_01 auto
GlobalVariable Property SFF_MCM_CondO_Hoodie_02 auto
GlobalVariable Property SFF_MCM_CondO_Hoodie_03 auto
GlobalVariable Property SFF_MCM_CondO_Hoodie_04 auto	;; sff v1.8.0
GlobalVariable Property SFF_MCM_CondO_Hoodie_05 auto	;; sff v1.8.0

;; v1.9.0 - for blocking use of Accessory items per outfit
GlobalVariable Property SFF_MCM_CondO_Accessory_01 auto
GlobalVariable Property SFF_MCM_CondO_Accessory_02 auto
GlobalVariable Property SFF_MCM_CondO_Accessory_03 auto
GlobalVariable Property SFF_MCM_CondO_Accessory_04 auto
GlobalVariable Property SFF_MCM_CondO_Accessory_05 auto	
GlobalVariable Property SFF_MCM_CondO_Accessory_Home auto
GlobalVariable Property SFF_MCM_CondO_Accessory_Sleep auto

;; v1.8.0
GlobalVariable Property SFF_MCM_CondO_Night_01 auto
GlobalVariable Property SFF_MCM_CondO_Night_02 auto
GlobalVariable Property SFF_MCM_CondO_Night_03 auto
GlobalVariable Property SFF_MCM_CondO_Night_04 auto
GlobalVariable Property SFF_MCM_CondO_Night_05 auto

;; v1.8.1
GlobalVariable Property SFF_MCM_CondO_Combat_01 auto
GlobalVariable Property SFF_MCM_CondO_Combat_02 auto
GlobalVariable Property SFF_MCM_CondO_Combat_03 auto
GlobalVariable Property SFF_MCM_CondO_Combat_04 auto
GlobalVariable Property SFF_MCM_CondO_Combat_05 auto


GlobalVariable Property SFF_MCM_OutfitDialogueRefresh auto
GlobalVariable Property SFF_MCM_CombatOutfitFix auto

GlobalVariable Property SFF_MCM_DisableTeammateUnsheath auto ;;SFF v1.4.3 - stores current status of patch toggle; (to stop DisableTeammateUnsheath resetting on save load). Accessed by 'SFF_SHFWA_varCache' script.

;; SFF v1.5.0
GlobalVariable Property SFF_MCM_OutfitPrev auto 			;;SFF v1.5.0 - stores current status of Outfit Previewer toggle
GlobalVariable Property SFF_MCM_OutfitPrevAnim auto 		;;SFF v1.9.0
GlobalVariable Property SFF_MCM_EnablePreviewLight auto		;;SFF v1.7.1 - for storing value of Previewer Light toggle
GlobalVariable Property SFF_MCM_EnablePreviewZoom auto		;;SFF v1.7.1 
GlobalVariable Property SFF_MCM_EnablePreviewMove auto		;;SFF v1.7.1 
GlobalVariable Property SFF_MCM_DisablePreview3D auto		;;SFF v1.7.1 

GlobalVariable Property SFF_MCM_Bugfix_SemiSneak auto
GlobalVariable Property SFF_MCM_ForceTeleport auto

;; SFF v1.6.0 - Hunger&Feed system
GlobalVariable Property SFF_MCM_HungerSys auto 			;; Hunger sys. toggle
GlobalVariable Property SFF_MCM_HungerSys_dynamicSpells auto ;; enables adding leveled spells tied to hunger
GlobalVariable Property SFF_MCM_HungerSys_bloodPotion auto 	 ;; enables Serana to use blood potions to fill hunger
GlobalVariable Property SFF_MCM_HungerSys_selectiveFeeding auto 	 ;; blocks feeding if specific conditions met
GlobalVariable Property SFF_MCM_Add2Fac auto 	 ;; 

;; SFF v1.6.2 - Combat Feed/Bite
GlobalVariable Property SFF_MCM_HungerSys_combatBite auto 


; TOGGLE STATES
Bool bAutoHood = true
Bool bOrganicHood = false			;; sff v1.8.0 
Bool bAutoRelax = true
Bool bBackpack = true
Bool bSandbox = true
Bool bAdvancedSandbox = false		;; sff v1.2.1
Bool bAlternativeSandbox = false	;; sff v1.2.1
Bool bVariableSideDist = true		;; sff v1.2.1
Bool bTeleport = true
Bool bHungerSys = false				;; sff v1.6.0
Bool bHnF_spells = false			;; sff v1.6.0
Bool bHnF_potion = false			;; sff v1.6.0
Bool bHnF_blocker = false			;; sff v1.6.0
Bool bHnF_combat = false			;; sff v1.6.1

Bool bFixSneak = true
Bool bFixCombat = true
Bool bFixSheath = true	;; SFF v1.3.1
Bool bFixHunch = false	;; SFF v1.5.0
Bool bFixTeleport = false;; SFF v1.5.0

Bool bSeranaMarker = false
Bool Property bUpdater = false Auto

Bool bScroll = true
Bool bSleepOutfit = true
Bool bSynergy = true
Bool bSunDamage = false
Bool bQuestSpells = true
Bool bAltCompMode = false			;; disabled (sff v1.9.0)
Bool bOrganicCompanionMode = false	;; SFF v1.9.0
Bool bHorse = false
Bool bAdd2Fac = true	;; sff v1.6.0 - enables toggling adding Serana to 'CurrentFollowerFaction' or not.

; Debug
Bool bRefresh = false
Bool bForceDefault = false
Bool bFlushVLvars = false 
Bool bFlushInvList = false
Bool bSynergyDecoup = false

;; v1.6.0 - ridable worldspace
Bool bAddRideableWS
Bool bRemoveRideableWS

;; v1.6.2 - custom home cells
Bool bAddHome
Bool bRemoveHome

; VL
Bool bVampireLord = false
Bool bVL_health = false
Bool bVL_enemylevel = false
Bool bVL_enemyamount = false
Bool bVL_player = false
Bool bVL_dragon = false
Bool bVL_giant = false
Bool bVL_boss = false

Bool bVL_habitations = false
Bool bVL_cloak =  true
Bool bVL_royaloutfit = true
Bool bVL_cloakoutfit = false

;; Page4 [Outfit Manager]
;Bool bCustomOutfit = false	;; sff v1.9.0 - To be purged....

Bool bEnableOutfit01 = false
Bool bEnableOutfit02 = false
Bool bEnableOutfit03 = false
Bool bEnableOutfit04 = false	;; sff v1.8.0
Bool bEnableOutfit05 = false	;; sff v1.8.0
Bool bDisableOutfits = false
Bool bEmptyOutfits = false

Bool bOutfitDialogueRefresh = false
;Bool bPlayerOutfitFix = true ;; sff v1.9.0 - purged
Bool bOutfitPrev = false
Bool bOutfitPrevAnim = false	;; sff v1.9.0
Bool bOutfitPrevLight = false	;; sff v1.7.1
Bool bOutfitPrevZoom = false	;; sff v1.7.1
Bool bOutfitPrevMove = false	;; sff v1.7.1
Bool bOutfitPrevDisable3D = true ;; sff v1.7.1

Bool bCondO_Town_01 = false		;; sff v1.6.0
Bool bCondO_Combat_01 = false	;; sff v1.6.0
Bool bCondO_Night_01 = false	;; sff v1.8.0

Bool bCondO_Town_02 = false		;; sff v1.6.0
Bool bCondO_Combat_02 = false	;; sff v1.6.0
Bool bCondO_Night_02 = false	;; sff v1.8.0

Bool bCondO_Town_03 = false		;; sff v1.6.0
Bool bCondO_Combat_03 = false	;; sff v1.6.0
Bool bCondO_Night_03 = false	;; sff v1.8.0

Bool bCondO_Town_04 = false		;; sff v1.8.0
Bool bCondO_Combat_04 = false	;; sff v1.8.0
Bool bCondO_Night_04 = false	;; sff v1.8.0

Bool bCondO_Town_05 = false		;; sff v1.8.0
Bool bCondO_Combat_05 = false	;; sff v1.8.0
Bool bCondO_Night_05 = false	;; sff v1.8.0


;; PATCHES 
Bool bDisableTeammateUnsheath= false

;; OPTION IDs
Int iNone ;; SFF v1.6.2
;; Page1
Int iCurLoc_t
Int iCurRel_t
Int iHomeLoc_t
Int iCurLevel_t
Int iCurHealth_t
Int iCurMagicka_t
Int iCurStamina_t
Int iArmourRating_t
Int iArmourSunProtec_t

Int iCurHungerLvl	;; sff v1.6.0

;; Page2
Int QuestSpells_t

Int iAutoHood
Int iOrganicHood			;; sff v1.8.0 
Int iAutoRelax
Int iBackpack
Int iSandbox
Int iAdvancedSandbox		;; sff v1.2.1
Int iAlternativeSandbox		;; sff v1.2.1
Int iVariableSideDist		;; sff v1.2.1
Int iTeleport

Int iCombatHeadgear
Int _CombatHeadgearVal = 0

Int iHorseMode
Int _HorseModeVal = 0	;; 0 - return to stable; 1 - stay put; 2 - follow Serana

Int iHungerSys			;; sff v1.6.0
Int iHnF_spells			;; sff v1.6.0
Int iHnF_potion			;; sff v1.6.0
Int iHnF_blocker		;; sff v1.6.0
Int iHnF_combat			;; sff v1.6.2

Int iScroll
Int iSleepOutfit
Int iSynergy
Int iSunDamage
Int iHorse
Int iVampireLord
Int iQuestSpells
Int iCustomOutfit

Int iAltCompMode
Int _CompModeVal

Int iOrganicCompanionMode

;Bugfix
Int iFixSneak
Int iFixCombat
Int iFixSheath	;; SFF v1.3.1
Int iFixHunch	;; SFF v1.5.0
Int iFixTeleport;; SFF v1.5.0

;Debug
Int iRefresh
Int iForceDefault
Int iSeranaMarker
Int iUpdater
Int iFlushVLvars
Int iFlushInvList
Int iSynergyDecoup

Int iAddRelVal_s
Int _RelValValue

Int iCompModeRightDist_s			;;slider
Float _CompModeRightDistVal= 70.0	;;slider value

;; v1.6.0
Int iAddRideableWS
Int iRemoveRideableWS

;; v1.6.2
Int iAddHome
Int iRemoveHome

;; Page3 [Vampire Lord]
Int iSDEWarning_t
Int iVLheader_t
Int iVLheader2_t
Int iVLheader3_t
Int iVLheader4_t
Int iVLWarning_t


;health
Int iVL_health
Int iVL_health_s
Float _healthPercent= 30.0

;enemy lvl
Int iVL_enemylevel		;;toggle
Int iVL_enemylevel_s	;;slider
Float _enemyLevel= 1.6	;;slider value

;enemy quant.
Int iVL_enemyamount		;;toggle
Int iVL_enemyamount_s	;;slider
Float _enemyAmount= 4.0	;;slider value

Int iVL_player
Int iVL_dragon 
Int iVL_giant 
Int iVL_boss 

Int iVL_habitations
Int iVL_cloak
Int iVL_royaloutfit
Int iVL_cloakoutfit

;; Page4 [Outfit Manager]
Int iOutfitPageWarning_t

Int iOMheader1_t
Int iOMheader2_t
Int iOMheader3_t

Int iEnableOutfit01
Int iEnableOutfit02
Int iEnableOutfit03
Int iEnableOutfit04	;; sff v1.8.0
Int iEnableOutfit05	;; sff v1.8.0
Int iDisableOutfits
Int iEmptyOutfits

Int iEnabledOutfit
Int _EnabledOutfitVal

;; SFF v2.0.0 - for setting outfits by category ('City', 'Combat', etc.)
Int iCityOutfit
Int _CityOutfitIndex
String[] property m_CityOutfitSets auto		;; || with Predefinable Outfit sets options

Int iNightOutfit
Int _NightOutfitIndex
String[] property m_NightOutfitSets auto		;; || with Predefinable Outfit sets options

Int iCombatOutfit
Int _CombatOutfitIndex
String[] property m_CombatOutfitSets auto		;; || with Predefinable Outfit sets options



Int iOutfitDialogueRefresh
Int iPlayerOutfitFix
Int iOutfitPrev				;; SFF v1.5.0
Int iOutfitPrevAnim			;; SFF v1.9.0
Int iOutfitPrevLight		;; sff v1.7.1
Int iOutfitPrevZoom			;; sff v1.7.1
Int iOutfitPrevMove			;; sff v1.7.1
Int iOutfitPrevDisable3D	;; sff v1.7.1

Int iCondO_Town_01				;; sff v1.6.0
Int iCondO_Combat_01			;; sff v1.6.0
Int iCondO_Night_01				;; sff v1.8.0

Int iCondO_Town_02				;; sff v1.6.0
Int iCondO_Combat_02			;; sff v1.6.0
Int iCondO_Night_02				;; sff v1.8.0

Int iCondO_Town_03				;; sff v1.6.0
Int iCondO_Combat_03			;; sff v1.6.0
Int iCondO_Night_03				;; sff v1.8.0

Int iCondO_Town_04				;; sff v1.8.0
Int iCondO_Combat_04			;; sff v1.8.0
Int iCondO_Night_04				;; sff v1.8.0

Int iCondO_Town_05				;; sff v1.8.0
Int iCondO_Combat_05			;; sff v1.8.0
Int iCondO_Night_05				;; sff v1.8.0

;; sff v2.0.0 ~renamed ID's to make it more intuitive
Int iCondO_Hoodie_1
Int iCondO_Hoodie_2
Int iCondO_Hoodie_3
Int iCondO_Hoodie_4
Int iCondO_Hoodie_5

Int iCondO_Accessory_1			;; sff v1.9.0
Int iCondO_Accessory_2			;; sff v1.9.0
Int iCondO_Accessory_3			;; sff v1.9.0
Int iCondO_Accessory_4			;; sff v1.9.0
Int iCondO_Accessory_5			;; sff v1.9.0
Int iCondO_Accessory_6			;; sff v2.0.0	(Home Outfit)
Int iCondO_Accessory_7			;; sff v2.0.0	(Sleep Outfit)


;; Patches
Int iDisableTeammateUnsheath

;; Page 05 - Misc. SETTINGS
Int iAdd2Fac



; SCRIPT VERSION
int function GetVersion()
	return 14
endFunction

event OnVersionUpdate(int a_version)
	if (a_version > 13)
		Debug.Trace(self + ": Updating SFF's MCM script to version " + a_version)
		OnConfigInit()
	endIf
endEvent

event OnConfigInit()
	;bCondO_Town_01= false
	;bCondO_Town_02= false
	;bCondO_Town_03 = false
	
	Pages= new string[6]
	Pages[0]= "$Page01_title"
	Pages[1]= "$Page02_title"
	Pages[2]= "$Page03_title"
	Pages[3]= "$Page04_title"
	Pages[4]= "$Page05_title"
	Pages[5]= "$Page06_title"
	
	m_OutfitSets= new string[6]
	m_OutfitSets[0]= "$m_OutfitSets_01"
	m_OutfitSets[1]= "$m_OutfitSets_02"
	m_OutfitSets[2]= "$m_OutfitSets_03"
	m_OutfitSets[3]= "$m_OutfitSets_04"
	m_OutfitSets[4]= "$m_OutfitSets_05"	;; sff v1.8.0
	m_OutfitSets[5]= "$m_OutfitSets_06"	;; sff v1.8.0
	
	m_CityOutfitSets= new string[6]
	m_CityOutfitSets[0]= "$m_OutfitSets_01"
	m_CityOutfitSets[1]= "$m_OutfitSets_02"
	m_CityOutfitSets[2]= "$m_OutfitSets_03"
	m_CityOutfitSets[3]= "$m_OutfitSets_04"
	m_CityOutfitSets[4]= "$m_OutfitSets_05"	
	m_CityOutfitSets[5]= "$m_OutfitSets_06"	
	
	m_NightOutfitSets= new string[6]
	m_NightOutfitSets[0]= "$m_OutfitSets_01"
	m_NightOutfitSets[1]= "$m_OutfitSets_02"
	m_NightOutfitSets[2]= "$m_OutfitSets_03"
	m_NightOutfitSets[3]= "$m_OutfitSets_04"
	m_NightOutfitSets[4]= "$m_OutfitSets_05"	
	m_NightOutfitSets[5]= "$m_OutfitSets_06"	
	
	m_CombatOutfitSets= new string[6]
	m_CombatOutfitSets[0]= "$m_OutfitSets_01"
	m_CombatOutfitSets[1]= "$m_OutfitSets_02"
	m_CombatOutfitSets[2]= "$m_OutfitSets_03"
	m_CombatOutfitSets[3]= "$m_OutfitSets_04"
	m_CombatOutfitSets[4]= "$m_OutfitSets_05"	
	m_CombatOutfitSets[5]= "$m_OutfitSets_06"	
	
	m_CombatHeadgear= new string[3]
	m_CombatHeadgear[0] = "$m_CombatHeadgear_01"
	m_CombatHeadgear[1] = "$m_CombatHeadgear_02"
	m_CombatHeadgear[2] = "$m_CombatHeadgear_03"
	
	; m_CompMode= new string[3]
	; m_CompMode[0] = "$m_CompMode_01"
	; m_CompMode[1] = "$m_CompMode_02"
	; m_CompMode[2] = "$m_CompMode_03"
	
	m_HorseMode= new string[3]
	m_HorseMode[0]= "$m_HorseMode_01"
	m_HorseMode[1]= "$m_HorseMode_02"
	m_HorseMode[2]= "$m_HorseMode_03"
	
	Debug.Notification("SFF: MCM menu initialised.")	;; v1.4.5
endEvent

;; percentage (of total v.)
Int Function TStatPV(int stat)
	Actor starget= SeranaAlias.GetReference() as Actor
	if stat == 1
		return (starget.GetActorValuePercentage("health")*100) as Int
	elseif stat == 2
		return (starget.GetActorValuePercentage("magicka")*100) as Int
	elseif stat == 3
		return (starget.GetActorValuePercentage("stamina")*100) as Int
	endif
EndFunction

;; sff v1.6.0
;; total value, including buffs/debuffs
float Function TStatPVMax(int stat)
	Actor starget= SeranaAlias.GetReference() as Actor
	if stat == 1
		return ((starget.GetActorValue("Health") / starget.GetActorValuePercentage("Health")) * 1.0)
	elseif stat == 2
		return ((starget.GetActorValue("Magicka") / starget.GetActorValuePercentage("Magicka")) * 1.0) 
	elseif stat == 3
		return ((starget.GetActorValue("Stamina") / starget.GetActorValuePercentage("Stamina")) * 1.0)
	endif
EndFunction


;; base value. does not include buffs/debuffs
Int Function TStatMaxV(int stat)
	Actor starget= SeranaAlias.GetReference() as Actor
	if stat == 1
		return (ActorValueInfo.GetActorValueInfobyName("Health").GetMaximumValue(starget)) as Int
	elseif stat == 2
		return (ActorValueInfo.GetActorValueInfobyName("Magicka").GetMaximumValue(starget)) as Int
	elseif stat == 3
		return (ActorValueInfo.GetActorValueInfobyName("Stamina").GetMaximumValue(starget)) as Int
	endif
EndFunction

Function checkAddition ()
	if _RelValValue != 0
		if MME.bIsSDEInstalled
			(MME.SDEQuest as SDECustomMentalModel).SDECMMRelVar += _RelValValue
			_RelValValue= 0
		endif
	endif
EndFunction

Function ResetFlag()	;; sff v1.4.5 - gets called from 'SFF_MentalModelExtender'; to remove unecessary conditional properties in MCM script
	bUpdater= false
	SFF_MCM_Updater.SetValue(0) 	;; sff v1.6.2
EndFunction

Bool Function bCorrectOutfitCategory(int n)
	if _CityOutfitIndex == n || _NightOutfitIndex == n || _CombatOutfitIndex == n
		return true
	endif
	
	return false
EndFunction

event OnPageReset(string page)
	{Called when a new page is selected, including the initial empty page}
	;UpdateCurOutfitDropMenu()
	
	; Load custom .swf for animated logo
	if (page == "")
		LoadCustomContent("seranafollowerframework/sff_intro.dds")
		return
	else
		UnloadCustomContent()
	endIf
	
	checkAddition()

	; ------------------ PAGE 01 -------------------------------------
	if (page == "Monitor" || page == "$Page01_title")
		;curPage= page
		SetCursorFillMode(TOP_TO_BOTTOM)

		AddHeaderOption("$Page1_header1")
		
		;Relationship data
		if MME.bIsSDEInstalled
			;if MME.CallSDErelval()
				iCurRel_t= AddTextOption("$iCurRel_t", (MME.SDEQuest as SDECustomMentalModel).SDECMMRelVar + "/200")
			;endif
		else
			iSDEWarning_t= AddTextOption("<font color='#cc0000'>$iSDEWarning_t</font>", "")
			AddTextOption("$iCurRel_t", "", OPTION_FLAG_DISABLED)
		endif
		
		;Cur. location data
		actor Serana = SeranaAlias.GetActorReference()
		location curLoc = Serana.GetCurrentLocation()
		WorldSpace curWorldSpace = Serana.GetWorldSpace()	;; sff v1.7.1
		
		string curLocName 
		string curWSName
		
		if curLoc != none
			curLocName = curLoc.GetName()
		else
			if curWorldSpace != none				;; sff v1.7.1 - if no loc. name, use WS name!
				curLocName = curWorldSpace.GetName() 
			else
				curLocName= "$loc_unknown"
			endif
		endIf
		
		;; current loc.
		iCurLoc_t= AddTextOption("$iCurLoc_t", curLocName)
		
		;Home location data
		ObjectReference HomeMarker = HomeMarkerAlias.GetReference()
		string homeLocName = HomeMarker.GetCurrentLocation().GetName()
		iHomeLoc_t= AddTextOption("$iHomeLoc_t", homeLocName)
		iCurLevel_t= AddTextOption("$iCurLevel_t", MME.rnpcActor.GetLevel())
		;AddEmptyOption()
		
		AddHeaderOption("$Page1_header2")
		
		iCurHealth_t= AddTextOption("<font color='#cc0000'>$iCurHealth_t</font>", TStatPV(1) + "% (" + TStatPVMax(1) as Int + " / " + TStatMaxV(1) + ")")
		iCurMagicka_t= AddTextOption("<font color='#5e47b1'>$iCurMagicka_t</font>", TStatPV(2) + "% (" + TStatPVMax(2) as Int + " / " + TStatMaxV(2) + ")")
		iCurStamina_t= AddTextOption("<font color='#33dd66'>$iCurStamina_t</font>", TStatPV(3) + "% (" + TStatPVMax(3) as Int + " / " + TStatMaxV(3) + ")")
		
		
		AddEmptyOption()
		
		;; sff v1.6.0 - hunger stats
		if SFF_MCM_HungerSys.GetValue() == 1
			iCurHungerLvl= AddTextOption("$iCurHungerLvl" , HnFS.iHungerLvl + "/3")
		else
			iCurHungerLvl= AddTextOption("$iCurHungerLvl" , HnFS.iHungerLvl + "/3", OPTION_FLAG_DISABLED)
		endif
		
		;AddEmptyOption()
	;	SetCursorPosition(1)
		;AddTextOption("Damage Resistance", MME.rnpcActor.GetActorValue("DamageResist") as int)
		if bSunDamage
			iArmourSunProtec_t= AddTextOption("$iArmourSunProtec_t", MME.iSunProtecLevel + "/5")
		else
			iArmourSunProtec_t= AddTextOption("$iArmourSunProtec_t", "", OPTION_FLAG_DISABLED)
		endif
		

	; ------------------ PAGE 02 -------------------------------------
	elseIf (page == "Beh. Settings" || page== "$Page02_title")
		SetCursorFillMode(TOP_TO_BOTTOM)
		
		;; v1.4.0 - FOLLOW SETTINGS
		AddHeaderOption("$Page2_header1")		;; Beh. toggles
		
		;; SANDBOX SETTINGS
		;; Sandbox toggle
		iSandbox= AddToggleOption("$iSandbox", bSandbox)
		;; Advanced Sandbox (v1.3.0)
		iAdvancedSandbox= AddToggleOption("$iAdvancedSandbox", bAdvancedSandbox)
		;; Alternative Sandbox (v1.3.0)
		iAlternativeSandbox= AddToggleOption("$iAlternativeSandbox", bAlternativeSandbox)
		
		;; COMPANION MODE SETTINGS 
		;; Alternative Companion Modes
		;; iAltCompMode= AddMenuOption("$iAltCompMode", m_CompMode[_CompModeVal])
		iAltCompMode= AddToggleOption("$iAltCompMode", bAltCompMode)	;; sff v1.9.0 - toggle instead of dropbox
		
		
		;; Companion Mode default distance bar
		iCompModeRightDist_s= AddSliderOption("$iCompModeRightDist_s", _CompModeRightDistVal, "{0}")
		
		;; Companion Mode - Variable Distance (v1.3.0)
		iVariableSideDist= AddToggleOption("$iVariableSideDist", bVariableSideDist)
		
		;; Companion Mode - Organic Companion Mode (v1.9.0)
		iOrganicCompanionMode= AddToggleOption("Organic Companion Mode", bOrganicCompanionMode)
		
		;; AUTONOMOUS BEHAVIOUR PACKAGES
		;; Auto Relax/Sleep
		iAutoRelax= AddToggleOption("$iAutoRelax", bAutoRelax)

		SetCursorPosition(1)
		
		
		;; v1.4.0 - HORSE SETTINGS
		AddHeaderOption("$Page2_header2")
		
		;; HORSE TOGGLE
		iHorse= AddToggleOption("$iHorse", bHorse)
		
		if bHorse
			
			;; HORSE BEH.
			iHorseMode= AddMenuOption("$iHorseMode", m_HorseMode[_HorseModeVal])
		endif


		;; v1.6.0 - HUNGER & FEED SETTINGS
		AddHeaderOption("$Page2_header3") 
		
		;; Hunger toggle
		iHungerSys= AddToggleOption("$iHungerSys", bHungerSys)
		
		if bHungerSys
			;; Dynamic buffs
			iHnF_spells= AddToggleOption("$iHnF_spells", bHnF_spells)
			;; Blood Potion use
			iHnF_potion= AddToggleOption("$iHnF_potion", bHnF_potion)
			;; Feed filter
			iHnF_blocker= AddToggleOption("$iHnF_blocker", bHnF_blocker)
			;; Combat bite
			iHnF_combat= AddToggleOption("$iHnF_combat", bHnF_combat)
		else
			iHnF_spells= AddToggleOption("$iHnF_spells", bHnF_spells, OPTION_FLAG_DISABLED)
			iHnF_potion= AddToggleOption("$iHnF_potion", bHnF_potion, OPTION_FLAG_DISABLED)
			iHnF_blocker= AddToggleOption("$iHnF_blocker", bHnF_blocker, OPTION_FLAG_DISABLED)
			iHnF_combat= AddToggleOption("$iHnF_combat", bHnF_combat, OPTION_FLAG_DISABLED)
		endif

		

	
	; ------------------ PAGE 03 -------------------------------------
	elseIf (page == "Outfit Manager" || page == "$Page03_title")
;; FIRST COLUMN			
		SetCursorFillMode(TOP_TO_BOTTOM)
		
			;; CURRENT OUTFIT STATS
			iOMheader3_t= AddHeaderOption("$Page3_header3")
						
		if MME.curOutfitContainer != none 
			
			;; sff v2.0.0 - to give an extra layer of information by displaying what the current outfit is set as (City, Combat, Nighttime, etc).
			IF MME.curOutfitContainer == MME._TownOutfit
				AddTextOption("Current Outfit: ", MME.curOutfitContainer.GetBaseObject().GetName() + " (URBAN)" , OPTION_FLAG_DISABLED)
			ELSEIF MME.curOutfitContainer == MME._NightOutfit
				AddTextOption("Current Outfit: ", MME.curOutfitContainer.GetBaseObject().GetName() + " (NIGHTTIME)" , OPTION_FLAG_DISABLED)
			ELSEIF MME.curOutfitContainer == MME._CombatOutfit
				AddTextOption("Current Outfit: ", MME.curOutfitContainer.GetBaseObject().GetName() + " (COMBAT)" , OPTION_FLAG_DISABLED)
			ELSE
				AddTextOption("Current Outfit: ", MME.curOutfitContainer.GetBaseObject().GetName(), OPTION_FLAG_DISABLED)
			ENDIF

			AddTextOption("$OutfitSize", MME.iCorrectedCurOutfitSize(), OPTION_FLAG_DISABLED)
			AddTextOption("$iArmourRating_t", MME.rnpcActor.GetActorValue("DamageResist") as int, OPTION_FLAG_DISABLED)
			;AddTextOption("$iArmourRating_t", MME.iOutfitArmourRating(MME.rnpcActor as objectreference, MME.SFF_SeranaInventoryList), OPTION_FLAG_DISABLED)
			

			
			if MME.curOutfitContainer == SFF_Outfit01_Container && !bCorrectOutfitCategory(1)
				AddTextOption("", "", OPTION_FLAG_DISABLED)
				iCondO_Hoodie_1= AddToggleOption ("$cOutfit_Hoodie", SFF_MCM_CondO_Hoodie_01.GetValue() as bool) ;; sff v1.6.1 - for enabling outfit-tied, selective auto-hood behaviour blocking.
				iCondO_Accessory_1= AddToggleOption ("Block Accessories", SFF_MCM_CondO_Accessory_01.GetValue() as bool) ;; sff v9.0.0 - Accessories blocker

				
			elseif MME.curOutfitContainer == SFF_Outfit02_Container && !bCorrectOutfitCategory(2)
				
				AddTextOption("", "", OPTION_FLAG_DISABLED)
				iCondO_Hoodie_2= AddToggleOption ("$cOutfit_Hoodie", SFF_MCM_CondO_Hoodie_02.GetValue() as bool) ;; sff v1.6.1 - for enabling outfit-tied, selective auto-hood behaviour blocking.
				iCondO_Accessory_2= AddToggleOption ("Block Accessories", SFF_MCM_CondO_Accessory_02.GetValue() as bool) ;; ;; sff v9.0.0 - Accessories blocker


			elseif MME.curOutfitContainer == SFF_Outfit03_Container && !bCorrectOutfitCategory(3)
				
				AddTextOption("", "", OPTION_FLAG_DISABLED)
				iCondO_Hoodie_3= AddToggleOption ("$cOutfit_Hoodie", SFF_MCM_CondO_Hoodie_03.GetValue() as bool) ;; sff v1.6.1 - for enabling outfit-tied, selective auto-hood behaviour blocking.
				iCondO_Accessory_3= AddToggleOption ("Block Accessories", SFF_MCM_CondO_Accessory_03.GetValue() as bool) ;; sff v9.0.0 - Accessories blocker

			;; sff v1.8.0 - extra outfit sets expansion
			elseif MME.curOutfitContainer == SFF_Outfit04_Container && !bCorrectOutfitCategory(4)
				
				AddTextOption("", "", OPTION_FLAG_DISABLED)
				iCondO_Hoodie_4= AddToggleOption ("$cOutfit_Hoodie", SFF_MCM_CondO_Hoodie_04.GetValue() as bool) 
				iCondO_Accessory_4= AddToggleOption ("Block Accessories", SFF_MCM_CondO_Accessory_04.GetValue() as bool)	;; sff v9.0.0 - Accessories blocker 

			elseif MME.curOutfitContainer == SFF_Outfit05_Container && !bCorrectOutfitCategory(5)
				
				AddTextOption("", "", OPTION_FLAG_DISABLED)
				iCondO_Hoodie_5= AddToggleOption ("$cOutfit_Hoodie", SFF_MCM_CondO_Hoodie_05.GetValue() as bool)
				iCondO_Accessory_5= AddToggleOption ("Block Accessories", SFF_MCM_CondO_Accessory_05.GetValue() as bool)	;; sff v9.0.0 - Accessories blocker
			
			endif 
		else
			AddTextOption("$EmptyOutfit", "", OPTION_FLAG_DISABLED)
		endif

AddTextOption("", "", OPTION_FLAG_DISABLED)

		;; OUTFIT EQUIPPER
		iOMheader2_t= AddHeaderOption("$Page3_header2")
		iEnabledOutfit= AddMenuOption("$iEnabledOutfit", m_OutfitSets[SFF_MCM_SelectedOutfit.GetValue() as int])			;; outfit equipper dropdown 
		iOutfitDialogueRefresh= AddToggleOption("$iOutfitDialogueRefresh", !SFF_MCM_OutfitDialogueRefresh.GetValue() as bool)	;; MCM-exclusive outfit setting 
	

;AddHeaderOption("")	;; separator
AddTextOption("", "", OPTION_FLAG_DISABLED)

		AddHeaderOption("$Page3_header0")
		;; v1.4.0 - DYNAMIC OUTFIT SETTINGS
		
		;; DYNAMIC OUTFIT OPTIONS
		;; Automatic Hood Beh.
		iAutoHood= AddToggleOption("$iAutoHood", bAutoHood)
		iOrganicHood= AddToggleOption("$iOrganicHood", bOrganicHood)
		
		;UpdateCurOutfitDropMenu() ;; sff v1.6.1
		
		;; Combat Head Gear
		iCombatHeadgear= AddMenuOption("$iCombatHeadgear", m_CombatHeadgear[_CombatHeadgearVal])
		
		if bAutoRelax
			;; Sleep Outfit
			iSleepOutfit= AddToggleOption("$iSleepOutfit", bSleepOutfit)
		endif
		
		;; Scroll Force-Equip
		iScroll= AddToggleOption("$iScroll", bScroll)
		
			
			if FileExists("data/SKSE/Plugins/SeranaFollowerFramework.dll")	;; SFF v1.6.0
AddTextOption("", "", OPTION_FLAG_DISABLED)

				AddHeaderOption("$Page3_header4")
				iOutfitPrev= AddToggleOption("$iOutfitPrev", bOutfitPrev)	;; SFF v1.5.0
				iOutfitPrevAnim = AddToggleOption("$iOutfitPrevAnim", bOutfitPrevAnim)		;; SFF v1.9.0
				iOutfitPrevLight = AddToggleOption("$iOutfitPrevLight", bOutfitPrevLight)	;; sff v1.7.1
				iOutfitPrevZoom = AddToggleOption("$iOutfitPrevZoom", bOutfitPrevZoom)	;; sff v1.7.1
				iOutfitPrevMove = AddToggleOption("$iOutfitPrevMove", bOutfitPrevMove)	;; sff v1.7.1
				iOutfitPrevDisable3D = AddToggleOption("$iOutfitPrevDisable3D", bOutfitPrevDisable3D)	;; sff v1.7.1
			else
				AddToggleOption("$iOutfitPrev", bOutfitPrev, OPTION_FLAG_DISABLED)
			endif

;; SECOND COLUMN			
			SetCursorPosition(1)


		;; Major warnings to user
		IF MME._CombatOutfit != none && (MME._CombatOutfit == MME._TownOutfit || MME._CombatOutfit == MME._NightOutfit)
			AddTextOption("<font color='#cc0000'>WARNING: Combat outfit MUST be EXCLUSIVE!</font>", "", OPTION_FLAG_DISABLED)
		
		AddTextOption("", "", OPTION_FLAG_DISABLED)
		ENDIF
		
		;; sff v2.0.0 - "OUTFIT SETTER"
		AddHeaderOption("$Page3_header1")
	
		;; CITY
		if MME._TownOutfit == none	;; empty, red
			iCityOutfit= AddMenuOption("<font color='#cc0000'>$iCityOutfit</font>", m_CityOutfitSets[_CityOutfitIndex])
		elseif MME._TownOutfit == MME.curOutfitContainer
			iCityOutfit= AddMenuOption("<font color='#d3d624'>City Outfit (in use): </font>", m_CityOutfitSets[_CityOutfitIndex])
			;AddTextOption("Use 'Outfit Stats' section to change settings", "", OPTION_FLAG_DISABLED)
		else
			iCityOutfit= AddMenuOption("<font color='#47bd20'>$iCityOutfit</font>", m_CityOutfitSets[_CityOutfitIndex])
		endif

		if _CityOutfitIndex == 1 ;&& MME.curOutfitContainer != SFF_Outfit01_Container
			iCondO_Hoodie_1= AddToggleOption ("$cOutfit_Hoodie", SFF_MCM_CondO_Hoodie_01.GetValue() as bool) 
			iCondO_Accessory_1= AddToggleOption ("$cOutfit_Accessories", SFF_MCM_CondO_Accessory_01.GetValue() as bool) 
			
		elseif _CityOutfitIndex == 2 ;&& MME.curOutfitContainer != SFF_Outfit02_Container
			iCondO_Hoodie_2= AddToggleOption ("$cOutfit_Hoodie", SFF_MCM_CondO_Hoodie_02.GetValue() as bool) 
			iCondO_Accessory_2= AddToggleOption ("$cOutfit_Accessories", SFF_MCM_CondO_Accessory_02.GetValue() as bool)
			
		elseif _CityOutfitIndex == 3 ;&& MME.curOutfitContainer != SFF_Outfit03_Container
			iCondO_Hoodie_3= AddToggleOption ("$cOutfit_Hoodie", SFF_MCM_CondO_Hoodie_03.GetValue() as bool) 
			iCondO_Accessory_3= AddToggleOption ("$cOutfit_Accessories", SFF_MCM_CondO_Accessory_03.GetValue() as bool)
			
		elseif _CityOutfitIndex == 4 ;&& MME.curOutfitContainer != SFF_Outfit04_Container
			iCondO_Hoodie_4= AddToggleOption ("$cOutfit_Hoodie", SFF_MCM_CondO_Hoodie_04.GetValue() as bool) 
			iCondO_Accessory_4= AddToggleOption ("$cOutfit_Accessories", SFF_MCM_CondO_Accessory_04.GetValue() as bool)	
			
		elseif _CityOutfitIndex == 5 ;&& MME.curOutfitContainer != SFF_Outfit05_Container
			iCondO_Hoodie_5= AddToggleOption ("$cOutfit_Hoodie", SFF_MCM_CondO_Hoodie_05.GetValue() as bool)
			iCondO_Accessory_5= AddToggleOption ("$cOutfit_Accessories", SFF_MCM_CondO_Accessory_05.GetValue() as bool)
		endif
AddHeaderOption("")	;; separator

		;; NIGHT 
		if MME._NightOutfit == none	;; empty, don't change colour
			iNightOutfit= AddMenuOption("<font color='#cc0000'>$iNightOutfit</font>", m_NightOutfitSets[_NightOutfitIndex])
		elseif MME._NightOutfit == MME.curOutfitContainer
			iNightOutfit= AddMenuOption("<font color='#d3d624'>Night Outfit (in use): </font>", m_NightOutfitSets[_NightOutfitIndex])
			AddTextOption("Use 'Outfit Stats' section to change settings", "", OPTION_FLAG_DISABLED)
		else
			iNightOutfit= AddMenuOption("<font color='#47bd20'>$iNightOutfit</font>", m_NightOutfitSets[_NightOutfitIndex])
		endif
		
		if _NightOutfitIndex == 1 ;&& MME.curOutfitContainer != SFF_Outfit01_Container
			
			if _NightOutfitIndex != _CityOutfitIndex		;; only show toggle if Night Outfit NOT THE SAME as  City Outfit
				iCondO_Hoodie_1= AddToggleOption ("$cOutfit_Hoodie", SFF_MCM_CondO_Hoodie_01.GetValue() as bool) 
				iCondO_Accessory_1= AddToggleOption ("$cOutfit_Accessories", SFF_MCM_CondO_Accessory_01.GetValue() as bool) 
			endIf
			
		elseif _NightOutfitIndex == 2 ;&& MME.curOutfitContainer != SFF_Outfit02_Container

			if _NightOutfitIndex != _CityOutfitIndex
				iCondO_Hoodie_2= AddToggleOption ("$cOutfit_Hoodie", SFF_MCM_CondO_Hoodie_02.GetValue() as bool) 
				iCondO_Accessory_2= AddToggleOption ("$cOutfit_Accessories", SFF_MCM_CondO_Accessory_02.GetValue() as bool)
			endIf
			
		elseif _NightOutfitIndex == 3 ;&& MME.curOutfitContainer != SFF_Outfit03_Container

			if _NightOutfitIndex != _CityOutfitIndex
				iCondO_Hoodie_3= AddToggleOption ("$cOutfit_Hoodie", SFF_MCM_CondO_Hoodie_03.GetValue() as bool) 
				iCondO_Accessory_3= AddToggleOption ("$cOutfit_Accessories", SFF_MCM_CondO_Accessory_03.GetValue() as bool)
			endIf
			
		elseif _NightOutfitIndex == 4 ;&& MME.curOutfitContainer != SFF_Outfit04_Container

			if _NightOutfitIndex != _CityOutfitIndex
				iCondO_Hoodie_4= AddToggleOption ("$cOutfit_Hoodie", SFF_MCM_CondO_Hoodie_04.GetValue() as bool) 
				iCondO_Accessory_4= AddToggleOption ("$cOutfit_Accessories", SFF_MCM_CondO_Accessory_04.GetValue() as bool)	
			endIf
			
		elseif _NightOutfitIndex == 5 ;&& MME.curOutfitContainer != SFF_Outfit05_Container
			if _NightOutfitIndex != _CityOutfitIndex
				iCondO_Hoodie_5= AddToggleOption ("$cOutfit_Hoodie", SFF_MCM_CondO_Hoodie_05.GetValue() as bool)
				iCondO_Accessory_5= AddToggleOption ("$cOutfit_Accessories", SFF_MCM_CondO_Accessory_05.GetValue() as bool)
			endIf
		endif
AddHeaderOption("")	;; separator

		;; COMBAT 
		Actor Serana= SeranaAlias.GetReference() as Actor
		if !Serana.IsInCombat() 
			if MME._CombatOutfit == none	;; empty, don't change colour
				iCombatOutfit= AddMenuOption("<font color='#cc0000'>$iCombatOutfit</font>", m_CombatOutfitSets[_CombatOutfitIndex])
			elseif MME._CombatOutfit == MME.curOutfitContainer
				iCombatOutfit= AddMenuOption("<font color='#d3d624'>$iCombatOutfit</font>", m_CombatOutfitSets[_CombatOutfitIndex])
				AddTextOption("Use 'Outfit Stats' section to change settings", "", OPTION_FLAG_DISABLED)
			else
				iCombatOutfit= AddMenuOption("<font color='#47bd20'>$iCombatOutfit</font>", m_CombatOutfitSets[_CombatOutfitIndex])
			endif
		else
			AddMenuOption("$iCombatOutfit", m_CombatOutfitSets[_CombatOutfitIndex], OPTION_FLAG_DISABLED)
		endIf

		if _CombatOutfitIndex == 1 ;&& MME.curOutfitContainer != SFF_Outfit01_Container
			
			if _CombatOutfitIndex != _CityOutfitIndex && _CombatOutfitIndex != _NightOutfitIndex
				iCondO_Accessory_2= AddToggleOption ("$cOutfit_Accessories", SFF_MCM_CondO_Accessory_01.GetValue() as bool) 
			endIf
			
		elseif _CombatOutfitIndex == 2 ;&& MME.curOutfitContainer != SFF_Outfit02_Container

			if _CombatOutfitIndex != _CityOutfitIndex && _CombatOutfitIndex != _NightOutfitIndex 
				iCondO_Accessory_2= AddToggleOption ("$cOutfit_Accessories", SFF_MCM_CondO_Accessory_02.GetValue() as bool)
			endIf
			
		elseif _CombatOutfitIndex == 3 ;&& MME.curOutfitContainer != SFF_Outfit03_Container

			if _CombatOutfitIndex != _CityOutfitIndex && _CombatOutfitIndex != _NightOutfitIndex
				iCondO_Accessory_3= AddToggleOption ("$cOutfit_Accessories", SFF_MCM_CondO_Accessory_03.GetValue() as bool)
			endIf
			
		elseif _CombatOutfitIndex == 4 ;&& MME.curOutfitContainer != SFF_Outfit04_Container

			if _CombatOutfitIndex != _CityOutfitIndex && _CombatOutfitIndex != _NightOutfitIndex 
				iCondO_Accessory_4= AddToggleOption ("$cOutfit_Accessories", SFF_MCM_CondO_Accessory_04.GetValue() as bool)	
			endIf
			
		elseif _CombatOutfitIndex == 5 ;&& MME.curOutfitContainer != SFF_Outfit05_Container
			if _CombatOutfitIndex != _CityOutfitIndex && _CombatOutfitIndex != _NightOutfitIndex
				iCondO_Accessory_5= AddToggleOption ("$cOutfit_Accessories", SFF_MCM_CondO_Accessory_05.GetValue() as bool)
			endIf
		endif
AddHeaderOption("")	;; separator		
		;; HOME
		if MME.bHomeOutfitFilled()
			AddHeaderOption("<font color='#32a8a8'>HOME OUTFIT</font>")
			iCondO_Accessory_6= AddToggleOption ("Block Accessories", SFF_MCM_CondO_Accessory_Home.GetValue() as bool)	
		else
			AddHeaderOption("<font color='#cc0000'>HOME OUTFIT (empty)</font>")
		endif
		
		;; SLEEP
		if MME.bSleepOutfitFilled()
			AddHeaderOption("<font color='#32a8a8'>SLEEP OUTFIT</font>")
			iCondO_Accessory_7= AddToggleOption ("Block Accessories", SFF_MCM_CondO_Accessory_Sleep.GetValue() as bool)
			
		else
			AddHeaderOption("<font color='#cc0000'>SLEEP OUTFIT (empty)</font>")
		endif


	; ------------------ PAGE 04 -------------------------------------
	elseIf (page == "Vampire Lord" || page == "$Page04_title")
		SetCursorFillMode(TOP_TO_BOTTOM)
		
		iVampireLord= AddToggleOption("$iVampireLord", bVampireLord)
		
		AddEmptyOption()
		
		if !bVampireLord
			;iVLheader_t= 
			AddHeaderOption("$Page4_header1")
			;iVLWarning_t= 
			AddTextOption("<font color='#cc0000'>$iVLWarning_t</font>", "", OPTION_FLAG_DISABLED)
		else 
			;iVLheader2_t= 
			AddHeaderOption("$Page4_header2")
			iVL_health= AddToggleOption("$iVL_health", bVL_health)
			iVL_health_s= AddSliderOption("$iVL_health_s", _healthPercent, "If below {0}%")
			iVL_enemylevel= AddToggleOption("$iVL_enemylevel", bVL_enemylevel)
			iVL_enemylevel_s= AddSliderOption("$iVL_enemylevel_s", _enemyLevel, "{2}")
			iVL_enemyamount= AddToggleOption("$iVL_enemyamount", bVL_enemyamount)
			iVL_enemyamount_s= AddSliderOption("$iVL_enemyamount_s", _enemyAmount, "{0} or more")
			
			SetCursorPosition(1)
			
			AddEmptyOption()
			
			;iVLheader3_t= 
			AddHeaderOption("$Page4_header3")
			iVL_player= AddToggleOption("$iVL_player", bVL_player)
			iVL_dragon= AddToggleOption("$iVL_dragon", bVL_dragon)
			iVL_giant= AddToggleOption("$iVL_giant", bVL_giant)
			iVL_boss= AddToggleOption("$iVL_boss", bVL_boss)
			iVL_habitations= AddToggleOption("$iVL_habitations", bVL_habitations)
			iVL_cloak= AddToggleOption("$iVL_cloak", bVL_cloak)
			AddEmptyOption()
			;iVLheader4_t= 
			AddHeaderOption("$Page4_header4")
			iVL_royaloutfit= AddToggleOption("$iVL_royaloutfit", bVL_royaloutfit)
			iVL_cloakoutfit= AddToggleOption("$iVL_cloakoutfit", bVL_cloakoutfit)
		endif

	; ----------------- PAGE 05 --------------------------------------
	elseIf (page == "Misc. Settings" || page == "$Page05_title")
		SetCursorFillMode(TOP_TO_BOTTOM)

		iBackpack= AddToggleOption("$iBackpack", bBackpack)
		iTeleport= AddToggleOption("$iTeleport", bTeleport)
		iQuestSpells= AddToggleOption("$iQuestSpells", bQuestSpells)
		if !MME.bCured		;; SFF v1.2.0 ~ makes sure SunDamage only available before cure
			iSunDamage= AddToggleOption("$iSunDamage", bSunDamage)
		else
			AddToggleOption("$iSunDamage", bSunDamage, OPTION_FLAG_DISABLED)
			bSunDamage= false		;; sff v1.6.1
			SFF_SunDamage.SetValue(0)
		endif
		iSeranaMarker= AddToggleOption("$iSeranaMarker", bSeranaMarker)
		iAdd2Fac= AddToggleOption("$iAdd2Fac", bAdd2Fac)
		iAddRideableWS= AddToggleOption("$iAddRideableWS", bAddRideableWS)
		iRemoveRideableWS= AddToggleOption("$iRemoveRideableWS", bRemoveRideableWS)
		AddEmptyOption()
		;; sff v1.6.2 - custom homes
		iAddHome= AddToggleOption("$iAddHomeCell", bAddHome)
		iRemoveHome= AddToggleOption("$iRemoveHomeCell", bRemoveHome)
		
		AddEmptyOption()
		
		;; Synergy
		AddHeaderOption("$Page5_header1")
		
		if MME.bIsSDEInstalled
			iSynergy= AddToggleOption("$iSynergy", bSynergy)
			iSynergyDecoup= AddToggleOption("$iSynergyDecoup", bSynergyDecoup)
		else
			bSynergy= false
			AddToggleOption("$iSynergy", bSynergy, OPTION_FLAG_DISABLED)
			AddToggleOption("$iSynergyDecoup", bSynergyDecoup, OPTION_FLAG_DISABLED)
		endif
	
		SetCursorPosition(1)
		
		AddHeaderOption("$Page5_header2")
		;; (Palliative) Bugfixes
		iFixSneak= AddToggleOption("$iFixSneak", bFixSneak)
		iFixCombat= AddToggleOption("$iFixCombat", bFixCombat)
		iFixSheath= AddToggleOption("$iFixSheath", bFixSheath)
		iFixHunch= AddToggleOption("$iFixHunch", bFixHunch)
		iFixTeleport= AddToggleOption("$iFixTeleport", bFixTeleport)
	
		AddEmptyOption()

		;; Troubleshoot	
		AddHeaderOption("$Page5_header3")
		
		iRefresh= AddToggleOption("$iRefresh", bRefresh)
		iForceDefault= AddToggleOption("$iForceDefault", bForceDefault)
		if bVampireLord
			iFlushVLvars= AddToggleOption("$iFlushVLvars", bFlushVLvars)
		else
			AddToggleOption("$iFlushVLvars", bFlushVLvars, OPTION_FLAG_DISABLED)
		endif
		iFlushInvList= AddToggleOption ("$iFlushInvList", bFlushInvList)
		if MME.bIsSDEInstalled
			
			iAddRelVal_s= AddSliderOption("$iAddRelVal_s", _RelValValue, "Add {0}")	
		else 
			AddSliderOption("$iAddRelVal_s", _RelValValue, "Add {0}", OPTION_FLAG_DISABLED)
		endif
		iUpdater= AddToggleOption("$iUpdater", bUpdater)

		
	
	; -------------------------------------------------------
	elseIf (page == "Patches" || page == "$Page06_title")
		SetCursorFillMode(TOP_TO_BOTTOM)
		;; SFF v1.6.0
		if FileExists("data/SKSE/Plugins/SeranaFollowerFramework.dll")
			AddTextOption("$dllFound", "", OPTION_FLAG_DISABLED)
		else
			AddTextOption("$dllNotFound", "", OPTION_FLAG_DISABLED)
		endif
		
		if MME.bIsSDEInstalled
			AddTextOption("$patchSDE", "", OPTION_FLAG_DISABLED)
		endif

		Bool bIsSHFWALoaded = Game.GetFormFromFile(0x0500809B, "SeranaHoodFixWithAnim.esp")		
		;if IsPluginFound("SeranaHoodFixWithAnim.esp")
		;if GetPluginVersion("SeranaHoodFixWithAnim.esp") != -1	;;Returns the specified plugin's version number (-1 if the plugin is not loaded).
		if bIsSHFWALoaded
			;Debug.Trace("SFF: [TEST] SHFWA plugin detected")
			AddEmptyOption()
			AddTextOption("$patchSHFWA", "", OPTION_FLAG_DISABLED)
			iDisableTeammateUnsheath= AddToggleOption("$iDisableTeammateUnsheath", bDisableTeammateUnsheath)
		else 
			;Debug.Trace("SFF: [TEST] SHFWA plugin not installed")
		endif	

	endif
endEvent


;; Slider events
Event OnOptionSliderOpen(int option)
	;if CurrentPage == "Extra"
		if option == iVL_health_s
			SetSliderDialogStartValue(_healthPercent)
			SetSliderDialogDefaultValue(30.0)
			SetSliderDialogRange(10.0, 90.0)
			SetSliderDialogInterval(5.0)
			
		elseif option == iVL_enemylevel_s
			SetSliderDialogStartValue(_enemyLevel)
			SetSliderDialogDefaultValue(1.25)
			SetSliderDialogRange(0.5, 2.0)
			SetSliderDialogInterval(0.05)
			
		elseif option == iVL_enemyamount_s
			SetSliderDialogStartValue(_enemyAmount)
			SetSliderDialogDefaultValue(4)
			SetSliderDialogRange(1, 20)
			SetSliderDialogInterval(1)		
		
		elseif option == iAddRelVal_s
			SetSliderDialogStartValue(_RelValValue)
			SetSliderDialogDefaultValue(0)
			SetSliderDialogRange(-100, 100)
			SetSliderDialogInterval(1)
			
		elseif option == iCompModeRightDist_s
			SetSliderDialogStartValue(_CompModeRightDistVal)
			SetSliderDialogDefaultValue(70)
			SetSliderDialogRange(-200, 200)
			SetSliderDialogInterval(1)
			
		endif 		
	;endif
EndEvent

event OnOptionSliderAccept(int a_option, float a_value)
	{Called when the user accepts a new slider value}
		
	if (a_option == iVL_health_s)
		_healthPercent= a_value
		SetSliderOptionValue(a_option, a_value, "$healthSlider" + "{0}%")
		iVLHealth_MCM_SFF.SetValue(a_value)
	
	elseif a_option == iVL_enemylevel_s
		_enemyLevel= a_value
		SetSliderOptionValue(a_option, a_value, "{2}%")
		iVLLevelPercent_MCM_SFF.SetValue(_enemyLevel)
		iVLLevel_MCM_SFF.SetValue(_enemyLevel*SeranaAlias.GetActorReference().GetLevel() as float)
	
	elseif a_option == iVL_enemyamount_s
		_enemyAmount= a_value
		SetSliderOptionValue(a_option, a_value, "{0}" + "$enemyQntSlider")
		iVLAmount_MCM_SFF.SetValue(a_value)
	
	elseif a_option == iAddRelVal_s
		_RelValValue= a_value as int
		SetSliderOptionValue(a_option, _RelValValue, "{0}")
	
	elseif a_option == iCompModeRightDist_s
		_CompModeRightDistVal= a_value ;as int
		SetSliderOptionValue(a_option, _CompModeRightDistVal, "{0}")
		FBP.SetDistanceX(_CompModeRightDistVal)
			
	endIf
endEvent

;; Menu events
String[] property m_CombatHeadgear auto	;; string array with Combat headgear entries
String[] property m_HorseMode auto		;; || with Horse mode entries
String[] property m_OutfitSets auto		;; || with Predefinable Outfit sets options

Event OnOptionMenuOpen (int option)
	;UpdateCurOutfitDropMenu()
	if option == iCombatHeadgear
		SetMenuDialogOptions(m_CombatHeadgear)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogStartIndex(_CombatHeadgearVal)
		
	elseif option == iHorseMode
		SetMenuDialogOptions(m_HorseMode)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogStartIndex(_HorseModeVal)
		
	elseif option == iAltCompMode
		;SetMenuDialogOptions(m_CompMode)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogStartIndex(_CompModeVal)
		
	elseif option == iEnabledOutfit
		SetMenuDialogOptions(m_OutfitSets)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogStartIndex(SFF_MCM_SelectedOutfit.GetValue() as int)
		
	elseif option == iCityOutfit
		SetMenuDialogOptions(m_CityOutfitSets)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogStartIndex(_CityOutfitIndex)
		
	elseif option == iNightOutfit
		SetMenuDialogOptions(m_NightOutfitSets)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogStartIndex(_NightOutfitIndex)
		
	elseif option == iCombatOutfit
		SetMenuDialogOptions(m_CombatOutfitSets)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogStartIndex(_CombatOutfitIndex)
		
	endif
EndEvent

Event OnOptionMenuAccept(int option, int index)
	if option == iCombatHeadgear
		_CombatHeadgearVal = index
		SFF_MCM_AutoCombatHeadGear.SetValue(_CombatHeadgearVal)
		SetMenuOptionValue(option, m_CombatHeadgear[_CombatHeadgearVal])
	
	elseif option == iHorseMode
		_HorseModeVal = index
		SFF_MCM_HorseFollowMode.SetValue(_HorseModeVal)
		SetMenuOptionValue(option, m_HorseMode[_HorseModeVal])
		Debug.Notification(SFF_MCM_HorseFollowMode.GetValue())
		
	elseif option == iAltCompMode
		_CompModeVal = index
		SFF_MCM_AltCompanionMode.SetValue(_CompModeVal)
		;SetMenuOptionValue(option, m_CompMode[_CompModeVal])
	
	elseif option == iEnabledOutfit
		_EnabledOutfitVal = index
		;SFF_MCM_AltCompanionMode.SetValue(_CompModeVal)
		
		;; SFF v1.8.1
		if _EnabledOutfitVal == SFF_MCM_SelectedOutfit.GetValue()
			;; do nothing. We ended up selecting the outfit we were already using...
			debug.Trace("[INFO] SFF: Selected outfit already in use. No need to call code execution...")
		else
		
			if  _EnabledOutfitVal == 1
				SFF_MCM_SelectedOutfit.SetValue(1)
				MME._SelectedOutfit= SFF_Outfit01_Container		;; sff v1.8.0 - for having a 'static' property with Player's outfit choice
				MME._SelectedOutfitList= SFF_Outfit01_FormList
				;MME.ReturnOutfit2Container(SFF_Outfit01_Container, SFF_Outfit01_FormList)
				;if !MME.bUsingIndoorsOutfit()
					MME.ConditionalOutfitController()
				;endIf

					
			elseif _EnabledOutfitVal == 2
				SFF_MCM_SelectedOutfit.SetValue(2)
				MME._SelectedOutfit= SFF_Outfit02_Container		;; sff v1.8.0 - for having a 'static' property with Player's outfit choice
				MME._SelectedOutfitList= SFF_Outfit02_FormList
				;MME.ReturnOutfit2Container(SFF_Outfit02_Container, SFF_Outfit02_FormList)
				;if !MME.bUsingIndoorsOutfit()
					MME.ConditionalOutfitController()
				;endIf
			elseif _EnabledOutfitVal == 3
				SFF_MCM_SelectedOutfit.SetValue(3)
				MME._SelectedOutfit= SFF_Outfit03_Container		;; sff v1.8.0 - for having a 'static' property with Player's outfit choice
				MME._SelectedOutfitList= SFF_Outfit03_FormList
				;MME.ReturnOutfit2Container(SFF_Outfit03_Container, SFF_Outfit03_FormList)
				;if !MME.bUsingIndoorsOutfit()
					MME.ConditionalOutfitController()
				;endIf
			;; sff v1.8.0
			elseif _EnabledOutfitVal == 4
				SFF_MCM_SelectedOutfit.SetValue(4)
				MME._SelectedOutfit= SFF_Outfit04_Container		;; sff v1.8.0 - for having a 'static' property with Player's outfit choice
				MME._SelectedOutfitList= SFF_Outfit04_FormList
				;MME.ReturnOutfit2Container(SFF_Outfit04_Container, SFF_Outfit04_FormList)
				;if !MME.bUsingIndoorsOutfit()
					MME.ConditionalOutfitController()
				;endIf
			elseif _EnabledOutfitVal == 5
				SFF_MCM_SelectedOutfit.SetValue(5)
				MME._SelectedOutfit= SFF_Outfit05_Container		;; sff v1.8.0 - for having a 'static' property with Player's outfit choice
				MME._SelectedOutfitList= SFF_Outfit05_FormList
				;MME.ReturnOutfit2Container(SFF_Outfit05_Container, SFF_Outfit05_FormList)
				;if !MME.bUsingIndoorsOutfit()
					MME.ConditionalOutfitController()
				;endIf
			elseif _EnabledOutfitVal == 0
				SFF_MCM_SelectedOutfit.SetValue(0)
				EmptyOutfits()
			endif
			
		endif
		SetMenuOptionValue(option, m_OutfitSets[SFF_MCM_SelectedOutfit.GetValue() as int])
		bMainOutfitChanged = true
		;Utility.WaitMenuMode(0.15)	;; sff v1.6.1 - hang the code for a short time to allow for all items to finish moving, and THEN refresh page so we can show correct stats (armour rating; outfit size)
		ForcePageReset()	
		
	elseif option == iCityOutfit
		_CityOutfitIndex = index
		
		if  _CityOutfitIndex == 1

				SFF_MCM_CondO_Town_01.SetValue(1)
				
				SFF_MCM_CondO_Town_02.SetValue(0)
				SFF_MCM_CondO_Town_03.SetValue(0)
				SFF_MCM_CondO_Town_04.SetValue(0)	
				SFF_MCM_CondO_Town_05.SetValue(0)	
				
				bCondO_Town_02 = false
				bCondO_Town_03 = false
				bCondO_Town_04 = false	
				bCondO_Town_05 = false	
				
				MME._TownOutfit= SFF_Outfit01_Container
				MME.SFF_fList_TownOutfit = SFF_Outfit01_FormList
				
		elseif _CityOutfitIndex == 2

				SFF_MCM_CondO_Town_02.SetValue(1)
				
				SFF_MCM_CondO_Town_01.SetValue(0)
				SFF_MCM_CondO_Town_03.SetValue(0)
				SFF_MCM_CondO_Town_04.SetValue(0)
				SFF_MCM_CondO_Town_05.SetValue(0)
				
				bCondO_Town_01 = false
				bCondO_Town_03 = false
				bCondO_Town_04 = false
				bCondO_Town_05 = false
				
				MME._TownOutfit= SFF_Outfit02_Container
				MME.SFF_fList_TownOutfit = SFF_Outfit02_FormList

		elseif _CityOutfitIndex == 3

				SFF_MCM_CondO_Town_03.SetValue(1)
				
				SFF_MCM_CondO_Town_01.SetValue(0)
				SFF_MCM_CondO_Town_02.SetValue(0)
				SFF_MCM_CondO_Town_04.SetValue(0)
				SFF_MCM_CondO_Town_05.SetValue(0)
				
				bCondO_Town_01 = false
				bCondO_Town_02 = false
				bCondO_Town_04 = false
				bCondO_Town_05 = false
				
				MME._TownOutfit= SFF_Outfit03_Container
				MME.SFF_fList_TownOutfit = SFF_Outfit03_FormList

		elseif _CityOutfitIndex == 4

				SFF_MCM_CondO_Town_04.SetValue(1)
				
				SFF_MCM_CondO_Town_01.SetValue(0)
				SFF_MCM_CondO_Town_02.SetValue(0)
				SFF_MCM_CondO_Town_03.SetValue(0)
				SFF_MCM_CondO_Town_05.SetValue(0)
				
				bCondO_Town_01 = false
				bCondO_Town_02 = false
				bCondO_Town_03 = false
				bCondO_Town_05 = false
				
				MME._TownOutfit= SFF_Outfit04_Container
				MME.SFF_fList_TownOutfit = SFF_Outfit04_FormList

		elseif _CityOutfitIndex == 5

				SFF_MCM_CondO_Town_05.SetValue(1)
				
				SFF_MCM_CondO_Town_01.SetValue(0)
				SFF_MCM_CondO_Town_02.SetValue(0)
				SFF_MCM_CondO_Town_03.SetValue(0)
				SFF_MCM_CondO_Town_04.SetValue(0)
				
				bCondO_Town_01 = false
				bCondO_Town_02 = false
				bCondO_Town_03 = false
				bCondO_Town_04 = false
				
				MME._TownOutfit= SFF_Outfit05_Container
				MME.SFF_fList_TownOutfit = SFF_Outfit05_FormList

				
		elseif _CityOutfitIndex == 0
				SFF_MCM_CondO_Town_05.SetValue(0)
				SFF_MCM_CondO_Town_04.SetValue(0)
				SFF_MCM_CondO_Town_03.SetValue(0)
				SFF_MCM_CondO_Town_02.SetValue(0)
				SFF_MCM_CondO_Town_01.SetValue(0)
				MME._TownOutfit= NONE
		endif

		SetMenuOptionValue(option, m_CityOutfitSets[_CityOutfitIndex])
		bUrbanOutfitChanged= true	;; making sure any changes to City Outfit are immediately reproduced
		ForcePageReset()
		
	elseif option == iNightOutfit
		_NightOutfitIndex = index
		
		if  _NightOutfitIndex == 1

				SFF_MCM_CondO_Night_01.SetValue(1)
				
				SFF_MCM_CondO_Night_02.SetValue(0)
				SFF_MCM_CondO_Night_03.SetValue(0)
				SFF_MCM_CondO_Night_04.SetValue(0)	
				SFF_MCM_CondO_Night_05.SetValue(0)	
				
				bCondO_Night_02 = false
				bCondO_Night_03 = false
				bCondO_Night_04 = false	
				bCondO_Night_05 = false	
				
				MME._NightOutfit= SFF_Outfit01_Container
				MME.SFF_fList_NightOutfit = SFF_Outfit01_FormList
				
		elseif _NightOutfitIndex == 2

				SFF_MCM_CondO_Night_02.SetValue(1)
				
				SFF_MCM_CondO_Night_01.SetValue(0)
				SFF_MCM_CondO_Night_03.SetValue(0)
				SFF_MCM_CondO_Night_04.SetValue(0)
				SFF_MCM_CondO_Night_05.SetValue(0)
				
				bCondO_Night_01 = false
				bCondO_Night_03 = false
				bCondO_Night_04 = false
				bCondO_Night_05 = false
				
				MME._NightOutfit= SFF_Outfit02_Container
				MME.SFF_fList_NightOutfit = SFF_Outfit02_FormList

		elseif _NightOutfitIndex == 3

				SFF_MCM_CondO_Night_03.SetValue(1)
				
				SFF_MCM_CondO_Night_01.SetValue(0)
				SFF_MCM_CondO_Night_02.SetValue(0)
				SFF_MCM_CondO_Night_04.SetValue(0)
				SFF_MCM_CondO_Night_05.SetValue(0)
				
				bCondO_Night_01 = false
				bCondO_Night_02 = false
				bCondO_Night_04 = false
				bCondO_Night_05 = false
				
				MME._NightOutfit= SFF_Outfit03_Container
				MME.SFF_fList_NightOutfit = SFF_Outfit03_FormList

		elseif _NightOutfitIndex == 4

				SFF_MCM_CondO_Night_04.SetValue(1)
				
				SFF_MCM_CondO_Night_01.SetValue(0)
				SFF_MCM_CondO_Night_02.SetValue(0)
				SFF_MCM_CondO_Night_03.SetValue(0)
				SFF_MCM_CondO_Night_05.SetValue(0)
				
				bCondO_Night_01 = false
				bCondO_Night_02 = false
				bCondO_Night_03 = false
				bCondO_Night_05 = false
				
				MME._NightOutfit= SFF_Outfit04_Container
				MME.SFF_fList_NightOutfit = SFF_Outfit04_FormList

		elseif _NightOutfitIndex == 5

				SFF_MCM_CondO_Night_05.SetValue(1)
				
				SFF_MCM_CondO_Night_01.SetValue(0)
				SFF_MCM_CondO_Night_02.SetValue(0)
				SFF_MCM_CondO_Night_03.SetValue(0)
				SFF_MCM_CondO_Night_04.SetValue(0)
				
				bCondO_Night_01 = false
				bCondO_Night_02 = false
				bCondO_Night_03 = false
				bCondO_Night_04 = false
				
				MME._NightOutfit= SFF_Outfit05_Container
				MME.SFF_fList_NightOutfit = SFF_Outfit05_FormList

				
		elseif _NightOutfitIndex == 0
				SFF_MCM_CondO_Night_05.SetValue(0)
				SFF_MCM_CondO_Night_04.SetValue(0)
				SFF_MCM_CondO_Night_03.SetValue(0)
				SFF_MCM_CondO_Night_02.SetValue(0)
				SFF_MCM_CondO_Night_01.SetValue(0)
				MME._NightOutfit= NONE
		endif

		SetMenuOptionValue(option, m_NightOutfitSets[_NightOutfitIndex])
		bNightOutfitChanged= true
		ForcePageReset()
		
	elseif option == iCombatOutfit
		_CombatOutfitIndex = index
		
		if  _CombatOutfitIndex == 1

				SFF_MCM_CondO_Combat_01.SetValue(1)
				
				SFF_MCM_CondO_Combat_02.SetValue(0)
				SFF_MCM_CondO_Combat_03.SetValue(0)
				SFF_MCM_CondO_Combat_04.SetValue(0)	
				SFF_MCM_CondO_Combat_05.SetValue(0)	
				
				bCondO_Combat_02 = false
				bCondO_Combat_03 = false
				bCondO_Combat_04 = false	
				bCondO_Combat_05 = false	
				
				MME._CombatOutfit= SFF_Outfit01_Container
				MME.SFF_fList_CombatOutfit = SFF_Outfit01_FormList
				
		elseif _CombatOutfitIndex == 2

				SFF_MCM_CondO_Combat_02.SetValue(1)
				
				SFF_MCM_CondO_Combat_01.SetValue(0)
				SFF_MCM_CondO_Combat_03.SetValue(0)
				SFF_MCM_CondO_Combat_04.SetValue(0)
				SFF_MCM_CondO_Combat_05.SetValue(0)
				
				bCondO_Combat_01 = false
				bCondO_Combat_03 = false
				bCondO_Combat_04 = false
				bCondO_Combat_05 = false
				
				MME._CombatOutfit= SFF_Outfit02_Container
				MME.SFF_fList_CombatOutfit = SFF_Outfit02_FormList

		elseif _CombatOutfitIndex == 3

				SFF_MCM_CondO_Combat_03.SetValue(1)
				
				SFF_MCM_CondO_Combat_01.SetValue(0)
				SFF_MCM_CondO_Combat_02.SetValue(0)
				SFF_MCM_CondO_Combat_04.SetValue(0)
				SFF_MCM_CondO_Combat_05.SetValue(0)
				
				bCondO_Combat_01 = false
				bCondO_Combat_02 = false
				bCondO_Combat_04 = false
				bCondO_Combat_05 = false
				
				MME._CombatOutfit= SFF_Outfit03_Container
				MME.SFF_fList_CombatOutfit = SFF_Outfit03_FormList

		elseif _CombatOutfitIndex == 4

				SFF_MCM_CondO_Combat_04.SetValue(1)
				
				SFF_MCM_CondO_Combat_01.SetValue(0)
				SFF_MCM_CondO_Combat_02.SetValue(0)
				SFF_MCM_CondO_Combat_03.SetValue(0)
				SFF_MCM_CondO_Combat_05.SetValue(0)
				
				bCondO_Combat_01 = false
				bCondO_Combat_02 = false
				bCondO_Combat_03 = false
				bCondO_Combat_05 = false
				
				MME._CombatOutfit= SFF_Outfit04_Container
				MME.SFF_fList_CombatOutfit = SFF_Outfit04_FormList

		elseif _CombatOutfitIndex == 5

				SFF_MCM_CondO_Combat_05.SetValue(1)
				
				SFF_MCM_CondO_Combat_01.SetValue(0)
				SFF_MCM_CondO_Combat_02.SetValue(0)
				SFF_MCM_CondO_Combat_03.SetValue(0)
				SFF_MCM_CondO_Combat_04.SetValue(0)
				
				bCondO_Combat_01 = false
				bCondO_Combat_02 = false
				bCondO_Combat_03 = false
				bCondO_Combat_04 = false
				
				MME._CombatOutfit= SFF_Outfit05_Container
				MME.SFF_fList_CombatOutfit = SFF_Outfit05_FormList

				
		elseif _CombatOutfitIndex == 0
				SFF_MCM_CondO_Combat_05.SetValue(0)
				SFF_MCM_CondO_Combat_04.SetValue(0)
				SFF_MCM_CondO_Combat_03.SetValue(0)
				SFF_MCM_CondO_Combat_02.SetValue(0)
				SFF_MCM_CondO_Combat_01.SetValue(0)
				MME._CombatOutfit= NONE
		endif

		SetMenuOptionValue(option, m_CombatOutfitSets[_CombatOutfitIndex])
		
		ForcePageReset()
	endif
EndEvent

Event OnConfigOpen()
	DEBUG.TRACE("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ MCM MENU OPEN! ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
	;SFF_MCM_AltCompanionMode.GetValue() == 1
	if SFF_MCM_AltCompanionMode.GetValue() > 1
		SFF_MCM_AltCompanionMode.SetValue(0)
	endif

	bAltCompMode= SFF_MCM_AltCompanionMode.GetValue()
EndEvent

;; SFF v2.0.0 - for making hoodie changes as soon as possible, but calling 'HoodieManager()' only AND ONLY IF we changed any of its settings
bool bBlockHoodieChanged
bool bUrbanOutfitChanged
bool bNightOutfitChanged
bool bMainOutfitChanged
bool bBlockAccessoriesChanged

Event OnConfigClose()
;; Main
;;VAMPIRE LORD
	if !bVL_health
		bVL_TransformHealth.SetValue(0)
	else 
		
	endif
	
	if !bVL_enemylevel
		bVL_TransformLevel.SetValue(0)
	else 
		
	endif
	
	if !bVL_enemyamount
		bVL_TransformNumber.SetValue(0)
	else 
		
	endif
	
	if !bVL_dragon
		bVL_TransformDragon.SetValue(0)
	endif	
	if !bVL_giant
		bVL_TransformGiant.SetValue(0)
	endif
	if !bVL_boss
		bVL_TransformBoss.SetValue(0)
	endif
	if bFlushVLvars 
		VLH.ClearFlag()
		bFlushVLvars= false
	endif

;; CUSTOM Outfit
	; if bEmptyOutfits
		; bEmptyOutfits= false
	; endif

;; RidableWorldSpaces
	bAddRideableWS= false
	bRemoveRideableWS= false
	
;; sff v1.8.0 - forgot to reset in prior versions...
	bAddHome= false
	bRemoveHome= false

;; sff v2.0.0 - for making hoodie changes as soon as possible, but calling 'HoodieManager()' only AND ONLY IF we changed any of its settings
	if bBlockHoodieChanged
	
		debug.trace("SFF: [MCM] Hoodie blocker option toggled; 'HoodieManager()' called from MCM.")
		MME.HoodieManager()
		bBlockHoodieChanged= false
	endIf
	
	if bBlockAccessoriesChanged
		MME.AddAccessories()
		MME.RemoveAccessories()
		bBlockAccessoriesChanged
	endIf
	
	if bUrbanOutfitChanged || bNightOutfitChanged
		if !MME.bUsingIndoorsOutfit()
			MME.ConditionalOutfitController()
		endIf
		bUrbanOutfitChanged = false
		bNightOutfitChanged = false
	endif
	
	if bMainOutfitChanged
		; if !MME.bUsingIndoorsOutfit()
			; call COC
			; MME.ConditionalOutfitController()
		; else
			;; call COP
			MME.CentralOutfitProcessor()
	;	endIf		
	endIf

EndEvent

event OnOptionSelect(int option)
	
	if CurrentPage == "$Page02_title"
		
		if (option == iSandbox)
			bSandbox = !bSandbox
			SetToggleOptionValue(iSandbox, bSandbox)
			
			if (SFF_MCM_Sandbox.GetValue() == 0)
				SFF_MCM_Sandbox.SetValue(1)
				MPS.Register4Update()
				Debug.Notification("Sandbox behaviour enabled")
			else
				SFF_MCM_Sandbox.SetValue(0)
				Debug.Notification("Sandbox behaviour disabled")
			endif 
			
		elseif (option == iAdvancedSandbox)
			bAdvancedSandbox = !bAdvancedSandbox
			SetToggleOptionValue(iAdvancedSandbox, bAdvancedSandbox)
			
			if (SFF_MCM_AdvancedSandbox.GetValue() == 0)
				SFF_MCM_AdvancedSandbox.SetValue(1)
				Debug.Notification("Advanced Sandbox behaviour enabled")
			else
				SFF_MCM_AdvancedSandbox.SetValue(0)
				Debug.Notification("Advanced Sandbox behaviour disabled")
			endif 
			
		elseif (option == iAlternativeSandbox)
			bAlternativeSandbox = !bAlternativeSandbox
			SetToggleOptionValue(iAlternativeSandbox, bAlternativeSandbox)
			
			if (SFF_MCM_AlternativeSandbox.GetValue() == 0)
				SFF_MCM_AlternativeSandbox.SetValue(1)
				debug.trace("SFF: Alternative Sandbox behaviour enabled")
				Debug.Notification("Alternative Sandbox behaviour enabled")
			else
				SFF_MCM_AlternativeSandbox.SetValue(0)
				debug.trace("SFF: Alternative Sandbox behaviour disabled")
				Debug.Notification("Alternative Sandbox behaviour disabled")
			endif 

		elseif (option == iAltCompMode)
			bAltCompMode = !bAltCompMode
			SetToggleOptionValue(iAltCompMode, bAltCompMode)
			
			SFF_MCM_AltCompanionMode.SetValue(bAltCompMode as int)
						
		elseif (option == iVariableSideDist)
			bVariableSideDist = !bVariableSideDist
			SetToggleOptionValue(iVariableSideDist, bVariableSideDist)
			
			if (SFF_MCM_VarSideDist.GetValue() == 0)
				SFF_MCM_VarSideDist.SetValue(1)
			else
				SFF_MCM_VarSideDist.SetValue(0)
			endif 
		
		;; SFF v1.9.0
		elseif (option == iOrganicCompanionMode)
			bOrganicCompanionMode = !bOrganicCompanionMode
			SetToggleOptionValue(iOrganicCompanionMode, bOrganicCompanionMode)
			
			if (SFF_MCM_OrganicCompanionMode.GetValue() == 0)
				SFF_MCM_OrganicCompanionMode.SetValue(1)
			else
				SFF_MCM_OrganicCompanionMode.SetValue(0)
			endif 
			
		elseif (option == iAutoRelax)
			bAutoRelax = !bAutoRelax
			SetToggleOptionValue(iAutoRelax, bAutoRelax)
			
			if (SFF_MCM_RelaxHome.GetValue() == 0)
				SFF_MCM_RelaxHome.SetValue(1)
			else								;; if Autonomous Behaviour disabled,
				SFF_MCM_RelaxHome.SetValue(0)	;; turn off Aut. Beh. switch
				SFF_MCM_SleepOutfit.SetValue(0)	;; also turn off Sleep outfit switch
				bSleepOutfit= false				;; and Sleep outfit MCM toggle
			endif 
			
		elseif (option == iHorse)
			bHorse = !bHorse
			SetToggleOptionValue(iHorse, bHorse)
			
			if (SFF_MCM_HorseMount.GetValue() == 0)
				SFF_MCM_HorseMount.SetValue(1)
				;Debug.Notification("Sandbox behaviour enabled")
			else
				SFF_MCM_HorseMount.SetValue(0)
				;Debug.Notification("Sandbox behaviour disabled")
			endif 
			
		elseif (option == iHungerSys)
			bHungerSys = !bHungerSys
			SetToggleOptionValue(iHungerSys, bHungerSys)
			
			if (SFF_MCM_HungerSys.GetValue() == 0)
				SFF_MCM_HungerSys.SetValue(1)
				HnFS.Setup()
				Debug.Notification("Hunger mechanism enabled")
			else
				SFF_MCM_HungerSys.SetValue(0)
				HnFS.DisableHnF()
				Debug.Notification("Hunger mechanism disabled")
			endif 
			
		elseif (option == iHnF_spells)
			bHnF_spells = !bHnF_spells
			SetToggleOptionValue(iHnF_spells, bHnF_spells)
			
			if (SFF_MCM_HungerSys_dynamicSpells.GetValue() == 0)
				SFF_MCM_HungerSys_dynamicSpells.SetValue(1)
			else
				SFF_MCM_HungerSys_dynamicSpells.SetValue(0)
			endif
			
		elseif (option == iHnF_potion)
			bHnF_potion = !bHnF_potion
			SetToggleOptionValue(iHnF_potion, bHnF_potion)
			
			if SFF_MCM_HungerSys_bloodPotion.GetValue() == 0
				SFF_MCM_HungerSys_bloodPotion.SetValue(1)
			else
				SFF_MCM_HungerSys_bloodPotion.SetValue(0)
			endif 
			
		elseif (option == iHnF_blocker)
			bHnF_blocker = !bHnF_blocker
			SetToggleOptionValue(iHnF_blocker, bHnF_blocker)
			
			if SFF_MCM_HungerSys_selectiveFeeding.GetValue() == 0
				SFF_MCM_HungerSys_selectiveFeeding.SetValue(1)
			else
				SFF_MCM_HungerSys_selectiveFeeding.SetValue(0)
			endif 
			
		elseif (option == iHnF_combat)
			bHnF_combat = !bHnF_combat
			SetToggleOptionValue(iHnF_combat, bHnF_combat)
			
			if SFF_MCM_HungerSys_combatBite.GetValue() == 0
				SFF_MCM_HungerSys_combatBite.SetValue(1)
			else
				SFF_MCM_HungerSys_combatBite.SetValue(0)
			endif 
		endif

	elseif CurrentPage == "$Page03_title"
		
		if (option == iAutoHood)
			bAutoHood = !bAutoHood
			SetToggleOptionValue(iAutoHood, bAutoHood)
			
			if (SFF_MCM_HoodBeh.GetValue() == 0)
				SFF_MCM_HoodBeh.SetValue(1)
			else
				SFF_MCM_HoodBeh.SetValue(0)
				MME.SFF_AutoHoodieDisabler()
			endif
		
		;; sff v1.8.0
		elseif (option == iOrganicHood)
			bOrganicHood = !bOrganicHood
			SetToggleOptionValue(iOrganicHood, bOrganicHood)
			
			if (SFF_MCM_OrganicHood.GetValue() == 0)
				SFF_MCM_OrganicHood.SetValue(1)
				MME.bAvailableInvHood()
			else
				SFF_MCM_OrganicHood.SetValue(0)
				MME.Hoodie= none
			endif
			MME.HoodieManager()	;; SFF v1.9.0 - make sure to update changes as soon as possible and refresh outfit
			MME.TriggerObj(50)
			
		elseif (option == iSleepOutfit)
			bSleepOutfit = !bSleepOutfit
			SetToggleOptionValue(iSleepOutfit, bSleepOutfit)
			
			if (SFF_MCM_SleepOutfit.GetValue() == 0)
				SFF_MCM_SleepOutfit.SetValue(1)
			else
				SFF_MCM_SleepOutfit.SetValue(0)
			endif 
		
		elseif (option == iScroll)
			bScroll = !bScroll
			SetToggleOptionValue(iScroll, bScroll)
			
			if (SFF_MCM_ElderScroll.GetValue() == 0)
				SFF_MCM_ElderScroll.SetValue(1)
			else
				SFF_MCM_ElderScroll.SetValue(0)
			endif 
					
			
		elseif (option == iOutfitDialogueRefresh)
			
			if (SFF_MCM_OutfitDialogueRefresh.GetValue() == 0)
				SFF_MCM_OutfitDialogueRefresh.SetValue(1)
			else
				SFF_MCM_OutfitDialogueRefresh.SetValue(0)
			endif 
			
			SetToggleOptionValue(iOutfitDialogueRefresh, !SFF_MCM_OutfitDialogueRefresh.GetValue() as bool)
			
		elseif (option == iOutfitPrev)
			bOutfitPrev = !bOutfitPrev
			SetToggleOptionValue(iOutfitPrev, bOutfitPrev)
			
			if (SFF_MCM_OutfitPrev.GetValue() == 0)
				SFF_MCM_OutfitPrev.SetValue(1)
			else
				SFF_MCM_OutfitPrev.SetValue(0)
			endif 
			
		elseif (option == iOutfitPrevAnim)
			bOutfitPrevAnim = !bOutfitPrevAnim
			SetToggleOptionValue(iOutfitPrevAnim, bOutfitPrevAnim)
			
			if (SFF_MCM_OutfitPrevAnim.GetValue() == 0)
				SFF_MCM_OutfitPrevAnim.SetValue(1)
			else
				SFF_MCM_OutfitPrevAnim.SetValue(0)
			endif 
		
		elseif (option == iOutfitPrevLight)
			bOutfitPrevLight = !bOutfitPrevLight
			SetToggleOptionValue(iOutfitPrevLight, bOutfitPrevLight)
			
			if SFF_MCM_EnablePreviewLight.GetValue() == 0
				SFF_MCM_EnablePreviewLight.SetValue(1)
				MME.PreviewerLightMenuRegisterer(true)
			else
				SFF_MCM_EnablePreviewLight.SetValue(0)
				MME.PreviewerLightMenuRegisterer(false)
			endif 
		
		elseif (option == iOutfitPrevZoom)
			bOutfitPrevZoom = !bOutfitPrevZoom
			SetToggleOptionValue(iOutfitPrevZoom, bOutfitPrevZoom)
			
			if SFF_MCM_EnablePreviewZoom.GetValue() == 0
				SFF_MCM_EnablePreviewZoom.SetValue(1)
			else
				SFF_MCM_EnablePreviewZoom.SetValue(0)
			endif 
		
		elseif (option == iOutfitPrevMove)
			bOutfitPrevMove = !bOutfitPrevMove
			SetToggleOptionValue(iOutfitPrevMove, bOutfitPrevMove)
			
			if SFF_MCM_EnablePreviewMove.GetValue() == 0
				SFF_MCM_EnablePreviewMove.SetValue(1)
			else
				SFF_MCM_EnablePreviewMove.SetValue(0)
			endif 
		
		elseif (option == iOutfitPrevDisable3D)
			bOutfitPrevDisable3D = !bOutfitPrevDisable3D
			SetToggleOptionValue(iOutfitPrevDisable3D, bOutfitPrevDisable3D)
			
			if SFF_MCM_DisablePreview3D.GetValue() == 0
				SFF_MCM_DisablePreview3D.SetValue(1)
			else
				SFF_MCM_DisablePreview3D.SetValue(0)
			endif
		
		;; SFF v2.0.0 - MCM menu toggler ID's getting mixed.
		;; To make sure we are enabling the correct toggle, extra checks necessary.
		;; Conditions below refer to the 'Outfit Equipper' subsection.
		;; HOODIE	(v1.6.1)			

		;; SFF v2.0.0 - MCM menu toggler ID's getting mixed.
		;; To make sure we are enabling the correct toggle, extra checks necessary.
		;; These conditions refer to the 'Outfit Setter' subsection.
		elseif option == iCondO_Hoodie_1 && (bCorrectOutfitCategory(1) || MME.curOutfitContainer == SFF_Outfit01_Container)
		
			
				if SFF_MCM_CondO_Hoodie_01.GetValue() == 0
					SFF_MCM_CondO_Hoodie_01.SetValue(1)
					debug.trace("SFF: [INFO] -1- 'Auto Hoodie blocker' ENABLED for Outfit 01.")
				else
					SFF_MCM_CondO_Hoodie_01.SetValue(0)
					debug.trace("SFF: [INFO] -1- 'Auto Hoodie blocker' DISABLED for Outfit 01.")
				endif
				
				SetToggleOptionValue(iCondO_Hoodie_1, SFF_MCM_CondO_Hoodie_01.GetValue() as bool)
				
				bBlockHoodieChanged= true
			
		elseif option == iCondO_Hoodie_2 && (bCorrectOutfitCategory(2) || MME.curOutfitContainer == SFF_Outfit02_Container)
			
			if SFF_MCM_CondO_Hoodie_02.GetValue() == 0
				SFF_MCM_CondO_Hoodie_02.SetValue(1)
				debug.trace("SFF: [INFO] -2- 'Auto Hoodie blocker' ENABLED for Outfit 02.")
			else
				SFF_MCM_CondO_Hoodie_02.SetValue(0)
				debug.trace("SFF: [INFO] -2- 'Auto Hoodie blocker' DISABLED for Outfit 02.")
			endif
			
			SetToggleOptionValue(iCondO_Hoodie_2, SFF_MCM_CondO_Hoodie_02.GetValue() as bool)
			
			bBlockHoodieChanged= true
			
			
		elseif option == iCondO_Hoodie_3 && (bCorrectOutfitCategory(3) || MME.curOutfitContainer == SFF_Outfit03_Container)
			
			if SFF_MCM_CondO_Hoodie_03.GetValue() == 0
				SFF_MCM_CondO_Hoodie_03.SetValue(1)
				debug.trace("SFF: [INFO] -3- 'Auto Hoodie blocker' ENABLED for Outfit 03.")
			else
				SFF_MCM_CondO_Hoodie_03.SetValue(0)
				debug.trace("SFF: [INFO] -3- 'Auto Hoodie blocker' DISABLED for Outfit 03.")
			endif
			
			SetToggleOptionValue(iCondO_Hoodie_3, SFF_MCM_CondO_Hoodie_03.GetValue() as bool)
			
			bBlockHoodieChanged= true
			
			
		elseif option == iCondO_Hoodie_4 && (bCorrectOutfitCategory(4) || MME.curOutfitContainer == SFF_Outfit04_Container)
			
			if SFF_MCM_CondO_Hoodie_04.GetValue() == 0
				SFF_MCM_CondO_Hoodie_04.SetValue(1)
				debug.trace("SFF: [INFO] -4- 'Auto Hoodie blocker' ENABLED for Outfit 04.")
			else
				SFF_MCM_CondO_Hoodie_04.SetValue(0)
				debug.trace("SFF: [INFO] -4- 'Auto Hoodie blocker' DISABLED for Outfit 04.")
			endif
			
			SetToggleOptionValue(iCondO_Hoodie_4, SFF_MCM_CondO_Hoodie_04.GetValue() as bool)
			
			bBlockHoodieChanged= true	
			
		elseif option == iCondO_Hoodie_5 && (bCorrectOutfitCategory(5) || MME.curOutfitContainer == SFF_Outfit05_Container)
			
			if SFF_MCM_CondO_Hoodie_05.GetValue() == 0
				SFF_MCM_CondO_Hoodie_05.SetValue(1)
				debug.trace("SFF: [INFO] -5- 'Auto Hoodie blocker' ENABLED for Outfit 05.")
			else
				SFF_MCM_CondO_Hoodie_05.SetValue(0)
				debug.trace("SFF: [INFO] -5- 'Auto Hoodie blocker' DISABLED for Outfit 05.")
			endif
			
			SetToggleOptionValue(iCondO_Hoodie_5, SFF_MCM_CondO_Hoodie_05.GetValue() as bool)
			
			bBlockHoodieChanged= true
			
		;; ACCESSORIES	(v1.9.0)
		elseif option == iCondO_Accessory_1 && (bCorrectOutfitCategory(1) || MME.curOutfitContainer == SFF_Outfit01_Container)
		
			if SFF_MCM_CondO_Accessory_01.GetValue() == 0
				SFF_MCM_CondO_Accessory_01.SetValue(1)
			else
				SFF_MCM_CondO_Accessory_01.SetValue(0)
			endif 
			
			SetToggleOptionValue(iCondO_Accessory_1, SFF_MCM_CondO_Accessory_01.GetValue() as bool)
			
			bBlockAccessoriesChanged= true
			
		elseif option == iCondO_Accessory_2 && (bCorrectOutfitCategory(2) || MME.curOutfitContainer == SFF_Outfit02_Container)
		
			if SFF_MCM_CondO_Accessory_02.GetValue() == 0
				SFF_MCM_CondO_Accessory_02.SetValue(1)
				debug.trace("SFF: [INFO] 'Acessories blocker' ENABLED for Outfit 02.")
			else
				SFF_MCM_CondO_Accessory_02.SetValue(0)
				debug.trace("SFF: [INFO] 'Acessories blocker' DISABLED for Outfit 02.")
			endif 
			
			SetToggleOptionValue(iCondO_Accessory_2, SFF_MCM_CondO_Accessory_02.GetValue() as bool)
			
			bBlockAccessoriesChanged= true
			
		elseif option == iCondO_Accessory_3 && (bCorrectOutfitCategory(3) || MME.curOutfitContainer == SFF_Outfit03_Container)
		
			if SFF_MCM_CondO_Accessory_03.GetValue() == 0
				SFF_MCM_CondO_Accessory_03.SetValue(1)
			else
				SFF_MCM_CondO_Accessory_03.SetValue(0)
			endif 
			
			SetToggleOptionValue(iCondO_Accessory_3, SFF_MCM_CondO_Accessory_03.GetValue() as bool)		
			
			bBlockAccessoriesChanged= true
			
		elseif option == iCondO_Accessory_4 && (bCorrectOutfitCategory(4) || MME.curOutfitContainer == SFF_Outfit04_Container)
		
			if SFF_MCM_CondO_Accessory_04.GetValue() == 0
				SFF_MCM_CondO_Accessory_04.SetValue(1)
			else
				SFF_MCM_CondO_Accessory_04.SetValue(0)
			endif 
			
			SetToggleOptionValue(iCondO_Accessory_4, SFF_MCM_CondO_Accessory_04.GetValue() as bool)		
			
			bBlockAccessoriesChanged= true
			
			
		elseif option == iCondO_Accessory_5 && (bCorrectOutfitCategory(5) || MME.curOutfitContainer == SFF_Outfit05_Container)
		
			if SFF_MCM_CondO_Accessory_05.GetValue() == 0
				SFF_MCM_CondO_Accessory_05.SetValue(1)
			else
				SFF_MCM_CondO_Accessory_05.SetValue(0)
			endif 
			
			SetToggleOptionValue(iCondO_Accessory_5, SFF_MCM_CondO_Accessory_05.GetValue() as bool)
			
			bBlockAccessoriesChanged= true
			
		elseif option == iCondO_Accessory_6 ;&& MME.curOutfitContainer == MME.OutfitContainer
		
			if SFF_MCM_CondO_Accessory_Home.GetValue() == 0
				SFF_MCM_CondO_Accessory_Home.SetValue(1)
				debug.trace("SFF: [INFO] 'Acessories blocker' ENABLED for Home Outfit.")
			else
				SFF_MCM_CondO_Accessory_Home.SetValue(0)
				debug.trace("SFF: [INFO] 'Acessories blocker' DISABLED for Home Outfit.")
			endif 
			
			SetToggleOptionValue(iCondO_Accessory_6, SFF_MCM_CondO_Accessory_Home.GetValue() as bool)
			
			bBlockAccessoriesChanged= true
			
		elseif option == iCondO_Accessory_7 ;&& MME.curOutfitContainer == MME.SleepOutfitContainer
		
			if SFF_MCM_CondO_Accessory_Sleep.GetValue() == 0
				SFF_MCM_CondO_Accessory_Sleep.SetValue(1)
			else
				SFF_MCM_CondO_Accessory_Sleep.SetValue(0)
			endif 
			
			SetToggleOptionValue(iCondO_Accessory_7, SFF_MCM_CondO_Accessory_Sleep.GetValue() as bool)
			
			bBlockAccessoriesChanged= true
			
		endif

		;ForcePageReset()
	
	elseif CurrentPage == "$Page04_title"
		;; VampireLord
		if (option == iVampireLord)
			bVampireLord = !bVampireLord
			SetToggleOptionValue(iVampireLord, bVampireLord)
			
			if (SFF_MCM_AllowVL.GetValue() == 0)
				SFF_MCM_AllowVL.SetValue(1)
				VLH.EstablishLeveledSpells()	;; SFF v1.4.1 ~ to make sure VL spell property in MME is not left empty
			else
				SFF_MCM_AllowVL.SetValue(0)
			endif
		
			ForcePageReset()

		elseif (option == iVL_health)
			bVL_health = !bVL_health
			SetToggleOptionValue(iVL_health, bVL_health)
			
			if (SFF_MCM_VL_Health.GetValue() == 0)
				SFF_MCM_VL_Health.SetValue(1)
				Debug.Notification("Health threshold: " + iVLHealth_MCM_SFF.GetValue() as Int + "%")
			else
				SFF_MCM_VL_Health.SetValue(0)
			endif 		
			
		elseif (option == iVL_enemylevel)
			bVL_enemylevel = !bVL_enemylevel
			SetToggleOptionValue(iVL_enemylevel, bVL_enemylevel)
			
			if (SFF_MCM_VL_Level.GetValue() == 0)
				SFF_MCM_VL_Level.SetValue(1)
				Debug.Notification("Enemy lvl: if greater than " + iVLLevel_MCM_SFF.GetValue())
			else
				SFF_MCM_VL_Level.SetValue(0)
			endif 		
			
		elseif (option == iVL_enemyamount)
			bVL_enemyamount = !bVL_enemyamount
			SetToggleOptionValue(iVL_enemyamount, bVL_enemyamount)
			
			if (SFF_MCM_VL_Amount.GetValue() == 0)
				SFF_MCM_VL_Amount.SetValue(1)
				Debug.Notification("Enemy quantity: " + iVLAmount_MCM_SFF.GetValue() as Int + " or more")
			else
				SFF_MCM_VL_Amount.SetValue(0)
			endif 		
		
		elseif (option == iVL_habitations)
			bVL_habitations = !bVL_habitations
			SetToggleOptionValue(iVL_habitations, bVL_habitations)
			
			if (SFF_MCM_VL_Habitations.GetValue() == 0)
				SFF_MCM_VL_Habitations.SetValue(1)
			else
				SFF_MCM_VL_Habitations.SetValue(0)
			endif 		
		
		elseif (option == iVL_cloak)
			bVL_cloak = !bVL_cloak
			SetToggleOptionValue(iVL_cloak, bVL_cloak)
			
			if (SFF_MCM_VL_Cloak.GetValue() == 0)
				SFF_MCM_VL_Cloak.SetValue(1)
			else
				SFF_MCM_VL_Cloak.SetValue(0)
			endif 		
			
		elseif (option == iVL_player)
			bVL_player = !bVL_player
			SetToggleOptionValue(iVL_player, bVL_player)
			
			if (SFF_MCM_VL_Player.GetValue() == 0)
				SFF_MCM_VL_Player.SetValue(1)
			else
				SFF_MCM_VL_Player.SetValue(0)
			endif 
		
		elseif (option == iVL_dragon)
			bVL_dragon = !bVL_dragon
			SetToggleOptionValue(iVL_dragon, bVL_dragon)
			
			if (SFF_MCM_VL_Dragon.GetValue() == 0)
				SFF_MCM_VL_Dragon.SetValue(1)
			else
				SFF_MCM_VL_Dragon.SetValue(0)
			endif 
		
		elseif (option == iVL_giant)
			bVL_giant = !bVL_giant
			SetToggleOptionValue(iVL_giant, bVL_giant)
			
			if (SFF_MCM_VL_Giant.GetValue() == 0)
				SFF_MCM_VL_Giant.SetValue(1)
			else
				SFF_MCM_VL_Giant.SetValue(0)
			endif 
		
		elseif (option == iVL_boss)
			bVL_boss = !bVL_boss
			SetToggleOptionValue(iVL_boss, bVL_boss)
			
			if (SFF_MCM_VL_Boss.GetValue() == 0)
				SFF_MCM_VL_Boss.SetValue(1)
			else
				SFF_MCM_VL_Boss.SetValue(0)
			endif 
		
		elseif (option == iVL_royaloutfit)
			bVL_royaloutfit = !bVL_royaloutfit
			SetToggleOptionValue(iVL_royaloutfit, bVL_royaloutfit)
			
			if (SFF_MCM_VLSeranaRoyalArmorGlobal.GetValue() == 0)
				SFF_MCM_VLSeranaRoyalArmorGlobal.SetValue(1)
			else
				SFF_MCM_VLSeranaRoyalArmorGlobal.SetValue(0)
			endif 
			
		elseif (option == iVL_cloakoutfit)
			bVL_cloakoutfit = !bVL_cloakoutfit
			SetToggleOptionValue(iVL_cloakoutfit, bVL_cloakoutfit)
			
			if (SFF_MCM_VLSeranaCloakGlobal.GetValue() == 0)
				SFF_MCM_VLSeranaCloakGlobal.SetValue(1)
			else
				SFF_MCM_VLSeranaCloakGlobal.SetValue(0)
			endif 
			
		endif		
	
	elseif (CurrentPage == "$Page05_title")
		if (option == iBackpack)
			bBackpack = !bBackpack
			SetToggleOptionValue(iBackpack, bBackpack)
			
			if (SFF_MCM_Backpack.GetValue() == 0)
				SFF_MCM_Backpack.SetValue(1)
			else
				SFF_MCM_Backpack.SetValue(0)
			endif 

		elseif (option == iTeleport)
			bTeleport = !bTeleport
			SetToggleOptionValue(iTeleport, bTeleport)
			
			if (SFF_MCM_Teleport.GetValue() == 0)
				SFF_MCM_Teleport.SetValue(1)
				Debug.Notification("Teleportation enabled")
			else
				SFF_MCM_Teleport.SetValue(0)
				Debug.Notification("Teleportation disabled")
			endif 
			
		elseif (option == iQuestSpells)
			bQuestSpells = !bQuestSpells
			SetToggleOptionValue(iQuestSpells, bQuestSpells)
			
			if (SFF_MCM_QuestSpells.GetValue() == 0)
				SFF_MCM_QuestSpells.SetValue(1)
				CEM.ManualChecker()
				;Debug.Notification("")
			else
				SFF_MCM_QuestSpells.SetValue(0)
				CEM.RemoveSpells()
				;Debug.Notification("")
			endif

		elseif (option == iSunDamage)
			bSunDamage = !bSunDamage
			SetToggleOptionValue(iSunDamage, bSunDamage)
			
			if (SFF_SunDamage.GetValue() == 0)
				SFF_SunDamage.SetValue(1)
				SDC.SwapSpells()
				Debug.Notification("Alternative Sun Damage Mechanic enabled")
			else
				SFF_SunDamage.SetValue(0)
				SDC.RevertSpells()
				Debug.Notification("Alternative Sun Damage Mechanic disabled")
			endif 

		elseif (option == iSeranaMarker)
			bSeranaMarker = !bSeranaMarker
			SetToggleOptionValue(iSeranaMarker, bSeranaMarker)
			
			if (SFF_MCM_SeranaMarker.GetValue() == 0)
				SFF_MCM_SeranaMarker.SetValue(1)
				SFF_SeranaTracker.Start()
				SFF_SeranaTracker.SetStage(10)
				Debug.Notification("Serana being tracked...")
			else
				SFF_MCM_SeranaMarker.SetValue(0)
				SFF_SeranaTracker.SetStage(20)
				SFF_SeranaTracker.Stop()
				Debug.Notification("Serana not tracked")
			endif 

		elseif (option == iAdd2Fac)
			bAdd2Fac = !bAdd2Fac
			SetToggleOptionValue(iAdd2Fac, bAdd2Fac)
			
			if (SFF_MCM_Add2Fac.GetValue() == 0)
				SFF_MCM_Add2Fac.SetValue(1)
				MME.MM.FollowerFacManager(0)
			else
				SFF_MCM_Add2Fac.SetValue(0)
				MME.MM.FollowerFacManager(1)
			endif 

		elseif (option == iAddRideableWS)
			bAddRideableWS = !bAddRideableWS
			SetToggleOptionValue(iAddRideableWS, bAddRideableWS)
			
			;if !iAddRideableWS
				MME.AddWorldSpace2List(Game.GetPlayer().GetWorldSpace())
			;endif 
			
		elseif (option == iRemoveRideableWS)
			bRemoveRideableWS = !bRemoveRideableWS
			SetToggleOptionValue(iRemoveRideableWS, bRemoveRideableWS)
			
			;if !iRemoveRideableWS
				MME.RemoveWorldSpaceFromList(Game.GetPlayer().GetWorldSpace())
			;endif 

		elseif (option == iAddHome)
			bAddHome = !bAddHome
			SetToggleOptionValue(iAddHome, bAddHome)
			
			MME.AddLoc2HomeList(Game.GetPlayer().GetCurrentLocation())

			
		elseif (option == iRemoveHome)
			bRemoveHome = !bRemoveHome
			SetToggleOptionValue(iRemoveHome, bRemoveHome)
			
			MME.RemoveLocFromHomeList(Game.GetPlayer().GetCurrentLocation())
			
		elseif (option == iSynergy)
			bSynergy = !bSynergy
			SetToggleOptionValue(iSynergy, bSynergy)
			
			if (SFF_MCM_Synergy.GetValue() == 0)
				SFF_MCM_Synergy.SetValue(1)
				Debug.Notification("Synergy mechanism enabled")
			else
				SFF_MCM_Synergy.SetValue(0)
				Debug.Notification("Synergy mechanism disabled")
			endif 

		elseif (option == iSynergyDecoup)
			bSynergyDecoup = !bSynergyDecoup
			SetToggleOptionValue(iSynergyDecoup, bSynergyDecoup)
			
			if (SFF_MCM_SynergyAffinityOnly.GetValue() == 0)
				SFF_MCM_SynergyAffinityOnly.SetValue(1)
			else
				SFF_MCM_SynergyAffinityOnly.SetValue(0)
			endif

		elseif (option == iFixSneak)
			bFixSneak = !bFixSneak
			SetToggleOptionValue(iFixSneak, bFixSneak)
			
			if (SFF_MCM_Bugfix_Sneak.GetValue() == 0)
				SFF_MCM_Bugfix_Sneak.SetValue(1)
				MME.SneakingBug()
				Debug.Notification("'Stuck in Crouch Mode' fix enabled")
			else
				SFF_MCM_Bugfix_Sneak.SetValue(0)
				MME.SneakingBug()
				Debug.Notification("'Stuck in Crouch Mode' fix disabled")
			endif

		elseif (option == iFixCombat)
			bFixCombat = !bFixCombat
			SetToggleOptionValue(iFixCombat, bFixCombat)
			
			if (SFF_MCM_Bugfix_Combat.GetValue() == 0)
				SFF_MCM_Bugfix_Combat.SetValue(1)
				MME.CombatBug()
				Debug.Notification("'Stuck in Combat Mode' fix enabled")
			else
				SFF_MCM_Bugfix_Combat.SetValue(0)
				MME.CombatBug()
				Debug.Notification("'Stuck in Combat Mode' fix disabled")
			endif 

		elseif (option == iFixSheath)
			bFixSheath = !bFixSheath
			SetToggleOptionValue(iFixSheath, bFixSheath)
			
			if (SFF_MCM_Bugfix_Unsheath.GetValue() == 0)
				SFF_MCM_Bugfix_Unsheath.SetValue(1)
				Debug.Notification("'Stuck in Unsheath Mode' fix enabled")
			else
				SFF_MCM_Bugfix_Unsheath.SetValue(0)
				Debug.Notification("'Stuck in Unsheath Mode' fix disabled")
			endif 

		elseif (option == iFixHunch)
			bFixHunch = !bFixHunch
			SetToggleOptionValue(iFixHunch, bFixHunch)
			
			if (SFF_MCM_Bugfix_SemiSneak.GetValue() == 0)
				SFF_MCM_Bugfix_SemiSneak.SetValue(1)
				Debug.Notification("'SemiCrouch/Hunched pose' fix enabled")
			else
				SFF_MCM_Bugfix_SemiSneak.SetValue(0)
				Debug.Notification("'SemiCrouch/Hunched pose' fix disabled")
			endif 

		elseif (option == iFixTeleport)
			bFixTeleport = !bFixTeleport
			SetToggleOptionValue(iFixTeleport, bFixTeleport)
			
			if (SFF_MCM_ForceTeleport.GetValue() == 0)
				SFF_MCM_ForceTeleport.SetValue(1)
				Debug.Notification("'Forced Teleportation' enabled")
			else
				SFF_MCM_ForceTeleport.SetValue(0)
				Debug.Notification("Forced Teleportation' disabled")
			endif 

		elseif (option == iRefresh)
			bRefresh = !bRefresh
			SetToggleOptionValue(iRefresh, bRefresh)
			if bRefresh
				MME.RefreshActor()
				bRefresh= false
			endif
			
		elseif (option == iForceDefault)
			bForceDefault = !bForceDefault
			SetToggleOptionValue(iForceDefault, bForceDefault)
			
			if bForceDefault
				MME.ForceDefaultOutfit()
				bForceDefault= false
			endif 
			
		elseif (option == iFlushVLvars)
			bFlushVLvars = !bFlushVLvars
			SetToggleOptionValue(iFlushVLvars, bFlushVLvars)
			
			if bFlushVLvars
				VLH.ClearFlag()
				bFlushVLvars= false
			endif
		
		;; OBSOLETE/OUTDATED - NEEDS REVISION!
		elseif (option == iFlushInvList)
			bFlushInvList = !bFlushInvList
			SetToggleOptionValue(iFlushInvList, bFlushInvList)
			
			if bFlushInvList
				;MME.RecycleOutfitList()
				bFlushInvList= false
			endif 
			
		elseif (option == iUpdater)
			bUpdater = !bUpdater
			SetToggleOptionValue(iUpdater, bUpdater)
			
			if (SFF_MCM_Updater.GetValue() == 0)
				SFF_MCM_Updater.SetValue(1)
				MME.MMEUpdater()
			else
				SFF_MCM_Updater.SetValue(0)
			endif 
			
		endIf
	
	elseif (CurrentPage == "$Page06_title")
		if (option == iDisableTeammateUnsheath)
			bDisableTeammateUnsheath = !bDisableTeammateUnsheath
			SetToggleOptionValue(iDisableTeammateUnsheath, bDisableTeammateUnsheath)
			
			if bDisableTeammateUnsheath
				MME.DrawWeaponManager(0)
				SFF_MCM_DisableTeammateUnsheath.SetValue(1)
			else
				MME.DrawWeaponManager(1)
				SFF_MCM_DisableTeammateUnsheath.SetValue(0)
			endif
		endif

	endIf
endEvent

Function EmptyOutfits()

	;MME.iMainOutfitSize= 0

	MME._SelectedOutfit= none		;; sff v1.8.0
	MME._SelectedOutfitList= none	;; sff v1.8.0
	
	if !MME.bUsingIndoorsOutfit()
		MME.curOutfitContainer= SFF_Outfit01_Container	;; sff v2.0.0 - we know we must always have an Outfit set, and eventually Outfit 1 will be selected. Might as well save all the hassle of figuring out which Outfit is available and set it here. 
		MME.SFF_CurOutfitList= SFF_Outfit01_FormList
		;SFF_MCM_SelectedOutfit.SetValue(1)
	endif

	MME.priorOutfitContainer= NONE
	MME.fList_priorOutfitList= NONE

	MME.priorCombatOutfit= NONE
	MME.fList_priorCombatOutfitList= NONE

	MME._CombatOutfit = none
	MME.SFF_fList_CombatOutfit = NONE
	MME._NightOutfit = none
	MME.SFF_fList_NightOutfit = NONE
	MME._TownOutfit = none
	MME.SFF_fList_TownOutfit = NONE
	
	SFF_Outfit01_Container.RemoveAllItems(MME._player)
	SFF_Outfit02_Container.RemoveAllItems(MME._player)
	SFF_Outfit03_Container.RemoveAllItems(MME._player)
	SFF_Outfit04_Container.RemoveAllItems(MME._player)
	SFF_Outfit05_Container.RemoveAllItems(MME._player)
	
	;; DISABLE [CITY]
				SFF_MCM_CondO_Town_01.SetValue(0)
				SFF_MCM_CondO_Town_02.SetValue(0)
				SFF_MCM_CondO_Town_03.SetValue(0)
				SFF_MCM_CondO_Town_04.SetValue(0)	;; sff v1.8.0
				SFF_MCM_CondO_Town_05.SetValue(0)	;; sff v1.8.0
				
				bCondO_Town_01 = false
				bCondO_Town_02 = false
				bCondO_Town_03 = false
				bCondO_Town_04 = false	;; sff v1.8.0
				bCondO_Town_05 = false	;; sff v1.8.0
				
				_CityOutfitIndex= 0

	;; DISABLE [NIGHT]
				SFF_MCM_CondO_Night_01.SetValue(0)
				SFF_MCM_CondO_Night_02.SetValue(0)
				SFF_MCM_CondO_Night_03.SetValue(0)
				SFF_MCM_CondO_Night_04.SetValue(0)	;; sff v1.8.0
				SFF_MCM_CondO_Night_05.SetValue(0)	;; sff v1.8.0
				
				bCondO_Night_01 = false
				bCondO_Night_02 = false
				bCondO_Night_03 = false
				bCondO_Night_04 = false	;; sff v1.8.0
				bCondO_Night_05 = false	;; sff v1.8.0
				
				_NightOutfitIndex= 0
	
	;; DISABLE [COMBAT]
				SFF_MCM_CondO_Combat_01.SetValue(0)
				SFF_MCM_CondO_Combat_02.SetValue(0)
				SFF_MCM_CondO_Combat_03.SetValue(0)	
				SFF_MCM_CondO_Combat_04.SetValue(0)	
				SFF_MCM_CondO_Combat_05.SetValue(0)	
				
				bCondO_Combat_01 = false
				bCondO_Combat_02 = false
				bCondO_Combat_03 = false
				bCondO_Combat_04 = false
				bCondO_Combat_05 = false
				
				_CombatOutfitIndex= 0

	
	debug.trace("[INFO] SFF: Custom Outfits reset and content returned to Player")
EndFunction