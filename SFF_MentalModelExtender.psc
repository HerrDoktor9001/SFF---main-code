Scriptname SFF_MentalModelExtender extends Quest Conditional
import PO3_SKSEFunctions		;; SFF v1.1.0 ~ for removing base spell (Drain spell cured Serana fix)
;import ConsoleUtil				;; SFF v1.5.0 - for opening Serana's Inventory menu
import MiscUtil					;; SFF v1.5.0 - for enabling scanning cell for Serana ref. (ForcedTeleportation solution)
import ANDR_PapyrusFunctions	;; SFF v1.7.1 ~ for enabling better handling of potion use 
import PapyrusIniManipulator	;; SFF v1.9.0 ~ for handling Previewer animation feature
import DynamicHDT				;; SFF v2.0.0 ~ for dealing with physics bugs during preview (when using unpaused menus)

;; ----------- CACHE -----------
;; [Follow Mechanic] tracks if Player has asked Serana to Follow Close/Beside. For sending affection points once only (SFF v1.0.0). 
Bool Property hasAskedCloseFollow auto conditional 
Bool Property hasAskedWalkBeside auto conditional
Bool Property hasSetHome auto conditional 

;; [Horse Mount System]
Bool Property bHasGivenHorse Auto Conditional
;; -----------		-----------

DLC1_NPCMentalModelScript Property MM auto  ;; Serana AI (MentalModel)

;;ACTORS
ReferenceAlias Property SeranaAlias  Auto
Actor property rnpcActor auto conditional ;; sff v1.7.1 - made property conditional to be accessed by 'sif_outfitmanagement'
Actor property _player auto 

;;OUTFITS
Outfit Property HomeOutfit auto
Outfit Property OriginalOutfit auto
Outfit Property DefaultOutFit auto
Outfit Property EmptyOutfit auto

Armor Property triggerObj auto  

;;Containers
ObjectReference Property OutfitContainer  auto 		;wardrobe container
ObjectReference Property SafeHoldingCont auto		;temporary holder to avoid losing items

;;Keywords&Factions
Keyword Property LocTypePlayerHouse auto
Faction Property PlayerFaction auto

;;Lists & associated vars
LeveledItem Property OutfitLeveledItem  Auto  
FormList Property ItemList Auto 					;container with items to be duplicated

Int ILsize	
Int index=0 
Bool checked2 = true	;; sff v1.9.0 - bool would start life as 'false', causing problems in OutfitHandler(): [!IsHome] -> [!checked2] -> UnequipAll(), ArmourSafekeeping(1), etc. = possible nude Serana when moving between cells


;;Bools
;Bool manageableOutfit = false
;Bool wardrobeOpened 								;bool that checks if player has opened the wardrobe inventory
Bool checked
Bool Property IsHome auto conditional
Bool Property bHomeOwned auto conditional
Bool Register4ActionSet = false
Bool Property bWait4Trap = false auto conditional				;; trigger for trap beh. package. Set by 'sff_traplistener' scripts on respective trap trigger/lever aliases in 'UpdatableScripts'

;;Quests
Quest Property DLC1VQ03Hunter auto	;; 'Prophet' quest, Dawnguard
Quest Property DLC1VQ03Vampire auto	;; 'Prophet' quest, Vampire

;;	Checks if the 'Prophet' quest has started, which is where wardrobe functions should be enabled
Bool Function bIsQuestComplete()
    return DLC1VQ03Hunter.GetStage() > 0 || DLC1VQ03Vampire.GetStage() > 0
EndFunction


;; ---------------------- MOD PATCHES -----------------------------------
;; SFF v1.3.1 - patches properties
 Idle Property shfwa_hood_wear auto conditional;add shfwa
 Idle Property shfwa_hood_takeoff auto conditional;add shfwa

;; SFF v1.3.1: patch for Animated Hood mod by 'chikuwan'
Bool Property bAnimatedHood auto conditional

Function AnimatedHoodPatchCecker()
	if IsPluginFound("SeranaHoodFixWithAnim.esp")
		Debug.Trace("SFF: SHFWA plugin found. Enabling patch...")
		bAnimatedHood= true
	else
		Debug.Trace("SFF: SHFWA plugin not found. Skip patch...")
		Debug.Notification("SHFWA plugin not found.Skip patch...")
		bAnimatedHood= false
	endif
EndFunction
;; -----------------------------------------------------------------------


;; ---------------------- MOD INITIALISATION CODE -----------------------

Bool 	Property bIsSDEInstalled auto conditional
Int 	Property SDE_RelationLvl auto conditional
Quest	Property SDEQuest auto conditional

Function SDEIniatialiser()
	bIsSDEInstalled= Game.IsPluginInstalled("Serana Dialogue Edit.esp")
	if bIsSDEInstalled
		;; grab SDE main quest
		SDEQuest= Game.GetFormFromFile(0x00029012,"Serana Dialogue Edit.esp") As Quest
	endif
EndFunction

Function CallSDESetter (int mode)
	if SDEQuest
		if mode == 0
			(SDEQuest as SDECustomMentalModel).SeranaLikes()
		elseif mode == 1
			(SDEQuest as SDECustomMentalModel).SeranaLoves()
		elseif mode == 2
			(SDEQuest as SDECustomMentalModel).SeranaRelishes()		
		elseif mode == -1
			(SDEQuest as SDECustomMentalModel).SeranaDislikes()		
		elseif mode == -2
			(SDEQuest as SDECustomMentalModel).SeranaHates()		
		elseif mode == -3
			(SDEQuest as SDECustomMentalModel).SeranaDetests()
		endif
	else
		Debug.Trace("SFF: SDECustomMentalModel not found or loaded")
	endif
EndFunction

Int Function CallSDErelval()
	int curRelVal= (SDEQuest as SDECustomMentalModel).SDECMMRelVar
	if curRelVal
		return (curRelVal)
	else
		return (-555)
	endif
EndFunction

Function AddSDErelval(int amount)
	if bIsSDEInstalled
		int curRelVal= (SDEQuest as SDECustomMentalModel).SDECMMRelVar
		;if curRelVal
			curRelVal += amount
		;endif
	endif
EndFunction

;; SFF v1.9.0 - for filling properties from .ini file related to Previewer Anim. feature
;; called externally from 'SFF_SDEInitialiser' script
Function PreviewerAnimInitialiser()
	
	if !bIsSSREInstalled()		;; if SS:RE not installed, no need to waste time and resources running code, as animations will never play
								;; Also frees users from having to install IniManipulator if they don't have SS:RE
		return
	endif
	
	if FileExists("data/Serana Follower Framework.ini")
		debug.trace("[INFO] SFF: Configuration .ini found. Filling properties...")
		
		;; REF.
		if IniDataExists(2, "data/Serana Follower Framework.ini", "Previewer", "IdleRef")
			iIdleRef= HexUtil.ParseHexStringToInt(PullStringFromIni ("data/Serana Follower Framework.ini", "Previewer", "IdleRef", "3"))
			debug.trace("[INFO] SFF: 'IdleRef' read: " + iIdleRef)
		else
			iIdleRef= 0
			debug.trace("[ERROR] SFF: Configuration .ini missing [Previewer] 'IdleRef' entry.")
		endif
		
		;; SOURCE
		if IniDataExists(2, "data/Serana Follower Framework.ini", "Previewer", "IdlePlugin")
			sIdleSource= PullStringFromIni ("data/Serana Follower Framework.ini", "Previewer", "IdlePlugin", "")
			debug.trace("[INFO] SFF: 'IdlePlugin' read: " + sIdleSource)
		else
			sIdleSource = ""
			debug.trace("[ERROR] SFF: Configuration .ini missing [Previewer] 'IdleSource' entry.")			
		endif
		
		;; TIME
		if IniDataExists(2, "data/Serana Follower Framework.ini", "Previewer", "IdleTime")
			fIdleTime= PullFloatFromIni ("data/Serana Follower Framework.ini", "Previewer", "IdleTime", 0.35)
			debug.trace("[INFO] SFF: 'IdleTime' read: " + fIdleTime)
		else
			fIdleTime= 0.0
			debug.trace("[ERROR] SFF: Configuration .ini missing [Previewer] 'IdleTime' entry.")			
		endif
	
	else
		debug.trace("=> [ERROR] SFF: 'Serana Follower Framework.ini' not found! Make sure .ini is correctly installed and configured!")
	endif
EndFunction

;; ----------------------------------------------------------------------

Event OnInit()
	SDEIniatialiser()
	if (!Register4ActionSet)
		RegisterForActorAction(8)	; Register for weapon draw
		RegisterForActorAction(10)	; Register for weapon sheathe
		Register4ActionSet= true
	endif
	rnpcActor = SeranaAlias.GetActorReference()
	DLC1VampireBeastRace=  Game.GetFormFromFile(0x0200283A,"Dawnguard.esm") As Race
	FactionsSetter()		;; sff v2.0.0 ~to make sure Serana is added to 'bed faction' from the very start
	RegisterForSingleUpdate(9.0)
EndEvent

;; ----------------------- PILLAR FUNC. ------------------- 
;; backbone function; gets called from dialogue topic
;; called from 'SFF__TIF__070EE777' ('SFF__TIF__070B1B64'?) fragment script
Function OutfitManager()
	CheckLocale()
	Debug.Trace("[SFF_O.Sys:003] Home Outfit container opened.")
	OpenCustomOutfitCont(SFF_OutfitContainer, ItemList)
EndFunction
;; --------------------------------------------------------

;; ----------------------- Dismiss/Recruit ----------------

Function OnRecruit() 
	;; [SFF v1.3.0]: revised and reworked code.
		;; implementation of "Guard Clauses Technique": avoid complex/unecessary nesting of clauses, kill code as early as possible
		
	Debug.Trace("SFF: OnRecruit() called.")
	
	if !bIsQuestComplete()	;; if quest condition not met, halt code
		Debug.Trace("[SFF_O.Sys:001.1]: 'Prophet' quest not running nor finished. Aborting code...")
		return
	endif
	
	if rnpcActor.GetActorBase().GetOutfit() == EmptyOutfit
		;; if Player recruited Serana and she's wearing EmptyOutfit,
		;; make her (re)equip her items, but don't set them to forced (i.e., clear 'forced' flag).
		Debug.Trace("[SFF_O.Sys:001.4] Serana recruited, but EmptyOutfit already in use.")

	else
		;; if Serana NOT using EmptyOutfit, 
		;; and neither SleepOutfit nor HomeOutfit (if using either, code would have returned long ago),
		;; unequip all. Safeguard Inventory items. Change Outfit to EmptyOutfit.
		
		rnpcActor.UnequipAll()
		ArmourSafekeeping(0)	;; tuck everything away to avoid item loss (INCLUDING inaccessible items from current Outfit, if any)
		rnpcActor.SetOutfit(EmptyOutfit)
		ArmourSafekeeping(1)

		if !curOutfitContainer

			_SelectedOutfit = SFF_MCM.SFF_Outfit01_Container
			_SelectedOutfitList =	SFF_MCM.SFF_Outfit01_FormList
			
			curOutfitContainer = SFF_MCM.SFF_Outfit01_Container
			SFF_CurOutfitList =	SFF_MCM.SFF_Outfit01_FormList
			
		endif
		Debug.Trace("[SFF_O.Sys:001.0] Outfit now manageable!")
	endif
	
	;; SFF v2.0.1. ~ if we force-equipped items on Serana, make sure to 'unforce' them on recruitment
	; if bForceEquipped
		; ForceEquipIntegral(false)
	; endif
	
	EquipElderScroll()						;; check to see if Elder Scroll should be equipped 
EndFunction


Function OnDismiss()
	Debug.Trace("SFF: Serana dismissed.")
	
	if !bIsQuestComplete()	;; if quest condition not met, halt code
		Debug.Trace("[SFF_O.Sys:002.1]: 'Prophet' quest not running nor finished. Aborting code...")
		return
	endif
	
	;; sff v2.0.0 ~ do nothing: Serana should keep wearing the Outfit Player last set
	EquipElderScroll()						;; check to see if Elder Scroll should be equipped
	
	
	;ForceEquipIntegral()
	
	;; run by CureQuest
EndFunction

;; --------------------------------------------------------


;; called from MCM
Function ForceDefaultOutfit()
	rnpcActor.SetOutfit(DefaultOutFit)
EndFunction

;; SFF v1.7.1 - Centralise time of day calc. code
Float Function fCurTime()

	Float Time = GameDaysPassed.GetValue() ;utility.GetCurrentGameTime()
	Time -= math.Floor(Time) as Float
	Time *= 24 as Float
	
	return Time
EndFunction		

GlobalVariable Property GameDaysPassed auto			;; more efficient vanilla alternative to 'Game.GetCurrentGameTime()'
GlobalVariable Property SFF_IsSeranaSpeaking Auto	;; Global variable that internalises Condition Function ('IsTalking'), for checking if Serana is playing a dialogue line/commentary

;; SFF v1.6.0: function rework:
	;; - altered logic, no more adding misc. item to Inventory: Refreshing Serana (disable/enable) also updates outfit!
	;; - faster and smoother: no need for hanging code! Before, hang code to make sure added item properly removed. Now, no items added, no need to Wait() code.
	;; - with disable/enable, Serana only loads 3d after all items equipped. Before, game would stutter while items being applied/loaded!
	;; NOTE: possibility of issues reguarding calling refresh in crucial moments (e.g., Harkon fight)?
		
Function TriggerObj(float t)
	
	;; sff v1.6.0: if Serana playing dialogue/speaking, we should not use disable-enable chain,
	;; as refreshing Serana force-stops her dialogue, can be incovenient if activated by Player, and can cause problems while in scenes.
	;; Thus, if talking, fall back to traditional method used hitherto.
	;; sff v1.8.1: if Serana in Combat Mode, make sure to use legacy refresh (or else combat will be forcibly cut). 
	if SFF_IsSeranaSpeaking.GetValue() == 0 && t < 50.0 && !rnpcActor.IsInCombat() && !rnpcActor.GetAnimationVariableBool("bIsRiding")
		rnpcActor.Disable()
		rnpcActor.Enable(true)
		debug.Trace("[DEBUG] SFF:: Alternative Inventory refresh used.")
	
	else ;; i.e., SeranaSpeaking = true  t >= 50.0
		
		;; using EquipItem to re-equip individual Inventory items not reliable (slow, + high chance of items not getting equipped). Furthermore, it still leads to stutters (v1.8.1). 
		;; 'QueueNiNodeUpdate()' does not seem to work with NPCs while game unpaused...
		;; 'UpdateWeight()' has no effect...
		;; changing between actual outfits has no effect...
		
		;; Equipping items immediatly when they are added to Inventory ('OnItemAdded()') much more efficient ('SFF_SunDamageController' script). 		
		
		rnpcActor.AddItem(triggerObj, 1, true)
		if t < 50.0
			Utility.Wait(t)
		else
			if Utility.IsInMenuMode()
				Utility.WaitMenuMode(0.1)	
			else
				Utility.Wait(0.1)	;; v1.8.1:  maybe reducing wait time helps reduce stutters? Nope.
			endif
		endif
		if rnpcActor.IsEquipped(triggerObj)
			rnpcActor.UnequipItem(triggerObj)
		endif
		rnpcActor.RemoveItem(triggerObj, 1, true)
		debug.Trace("[DEBUG] SFF:: Legacy Inventory refresh used.")
	endif
EndFunction
;; END

;; SFF v1.9.0: centralise SS:RE checking code (cleaner than using 'FileExists' check multiple times)
Bool Function bIsSSREInstalled()		
		return FileExists("data/SKSE/Plugins/SkyrimSoulsRE.dll")
EndFunction

;; -----------	Custom Outfit Selector ------------
;; SFF v.1.2.0

;Int Property iMainOutfitSize auto conditional
;LeveledItem Property SFF_MainOutfitContent auto

FormList Property SFF_CurOutfitList auto conditional ;; list for determining what outfit Serana is currently using. Accessed by MCM menu script.
FormList Property SFF_SeranaInventoryList auto 		;; Keeps track of armour items currently in Inventory (NOT limited to Player-given items) - minus hoodie or auto-headgear! Generated by 'SFF_SunDamageController'. 

GlobalVariable Property SFF_MCM_OutfitDialogueRefresh auto	;; for determining if outfit should be set/refreshed when exiting outfit dialogue, or only via MCM.

ObjectReference Property curOutfitContainer auto conditional

Bool Function bCanSetOutfitDialogue()
	return SFF_MCM_OutfitDialogueRefresh.GetValue()
EndFunction



;; Accessed by 'sif_outfitmanagement' script
Bool Property bPreviewerCanWork auto conditional		;; to stop Previwer code from running if key properties null ;; sff v2.0.0 - not strictly needed. Simply check against Global Var. both here and in 'sif_outfitmanagement' script.

FormList Property SFF_SafeContainerList auto ;; SFF v1.8.0 - keeps track of items in Safe Container ;; v2.0.0 - DELETE!

;; PREVIEWER ANIM. CODE 
INT iIdleRef ;= 0 ;= 0x000AF886
STRING sIdleSource ;= "Skyrim.esm"
FLOAT fIdleTime = 0.35;
GlobalVariable Property SFF_MCM_OutfitPrevAnim auto 		;;SFF v1.9.0
GlobalVariable Property SFF_IsSeranaUsingFurniture auto 	;;SFF v1.9.0 - for checking if Serana is using furniture or not (managed natively via Magic Effects)

;; similar function as 'bUsingConditionalOutfit()'... redundant;
Bool Function bOutfitInUse(ObjectReference n)
    return _TownOutfit == n || _NightOutfit == n || _CombatOutfit == n
EndFunction

Bool Function bIsIndoorsOutfit(ObjectReference n)
	return OutfitContainer == n || SleepOutfitContainer == n
EndFunction

;; SFF v1.8.0 - determines if Serana currently equipped with Indoors Outfit (Home or Sleep Outfits)
Bool Function bUsingIndoorsOutfit()
    return curOutfitContainer == SFF_OutfitContainer || curOutfitContainer == SleepOutfitContainer
EndFunction

GlobalVariable Property SFF_MCM_SelectedOutfit auto		;; sff v1.6.1 - for determining which outfit to set on menu close


Function PlayPreviewIdle()
	
	if bIsUsingTorch()
		return			;; if using torch, previewer feature does not trigger, so animation shouldn't either.
	endif
	
	if fIdleTime < 0.35		;; to make sure all items get computed and there is no item duplication issues.
		fIdleTime= 0.35
	endif
	
	if SFF_MCM_OutfitPrevAnim.GetValue() != 1  
		;; Previewer Anim. disabled.
		return
	endif
	
	if SFF_IsSeranaUsingFurniture.GetValue() == 1
		debug.trace("----> SFF: Serana using furniture. Disable Previewer anim.")
		return
	endif
	
	if iIdleRef != 0 && sIdleSource != ""
		IDLE PreviewerIdleAnim = Game.GetFormFromFile(iIdleRef, sIdleSource) As IDLE
		;FORM Torch = Game.GetFormFromFile(0x0001D4EC, sIdleSource) AS FORM

		if PreviewerIdleAnim != none
			debug.trace("ANIM FOUND!")
			rnpcActor.PlayIdle(PreviewerIdleAnim as idle)
			utility.wait(fIdleTime)
		else
			debug.trace("ANIM NOT FOUND...")
		endif
	else
		utility.Wait(0.35)	;; to make sure all items get computed and there is no item duplication issues.
		debug.trace("[WARNING] SFF: Previewer Anim. properties not filled. Is .ini properly configured? IdleRef: " + iIdleRef + "; IdlePlugin: " + sIdleSource + "; IdleTime: " + fIdleTime + ";")
	endif
EndFunction
;; END 

Function ActivateOutfitCont(ObjectReference myCont)

	PlayPreviewIdle()	;; SFF v1.9.0 - plays anim. before opening Container
	
	if SFF_MCM_OutfitPrev.GetValue() == 1 || bCanSetOutfitDialogue() ;; only cleanse vanilla hoodie IF Outfit Preview feature is enabled
		DefautHoodieClenser(MM.Hoodie)
	endif
	
	myCont.Activate(_player)
EndFunction


;; called by 'OpenCustomOutfitCont()', if Outfit Container opened same as one in use
;; called externally from vanilla Trade Dialogue fragment scripts ('DLC1_TIF__01003210', 'DLC1_TIF__01003211', 'DLC1_TIF__01003212', 'DLC1_TIF__01003213')
Function ActivateInventory()
	PlayPreviewIdle()				;; so Previewer Anim. can also play if opening Inventory by proxy.
	if Hoodie == MM.Hoodie
		DefautHoodieClenser(MM.Hoodie)	;; sff v2.0.0 - remove any Default Hoodies from Inventory for better Outfit management 
	endif
	rnpcActor.OpenInventory(true)	;;sff v1.9.0 - no need to use Console Commands here. Papyrus alternative available.
EndFunction

;; SFF v1.8.0 - for gauging correct and actual size of custom outfits in use
;; called externally from MCM menu
Int Function iCorrectedCurOutfitSize()
;; sff v2.0.0 - this function was outdated and not compatible with current mod mechanims' logic
;; a) we no longer use parallel outfit setting systems ('OutfitFix'). Default now is to add items to Inventory, instead of swapping baked outfits;
;; b) checking for CURRENT outfit size from our Safekeeping container while indoors will give erroneous results, as CURRENT outfit will be in Serana's Inventory! Thus, only INVENTORY should be gauged.

	return SFF_SeranaInventoryList.GetSize()
EndFunction

;; v1.5.0 - logic segmentation, code rework and cleaning
;; called from individual Containers via fragment scripts
;; 1st part of custom outfit code: under what conditions to REMOVE ITEMS from Serana.
Function OpenCustomOutfitCont(ObjectReference myCont, FormList myFormList)
	
	;; SFF v2.0.0 ~ to make sure we always have an Outfit set and avoid issues 
	if !curOutfitContainer 
		;; if no outfit set assigned,
		;; we run risk of sending items to nether.

		debug.trace("SFF: [OUTFIT] [ERROR]: Previewer called, but no current Outfit in use detected.")
		
		if !_SelectedOutfit
			MainOutfitCorrector(false)
		endif
		
		curOutfitContainer 	= _SelectedOutfit
		SFF_CurOutfitList	= _SelectedOutfitList
		debug.trace("SFF: [OUTFIT] [INFO]: Current Outfit set as last know Outfit selected for use by Player.")
	endif

	;; if myCont == NONE, something bad must've happened. Abort running the function
	if !myCont
		debug.trace("SFF: [OUTFIT] [ERROR]: Previewer called, but no Outfit passed (NULL). Aborting code...")
		RETURN
	endif

	;; if opening same Outfit as one in use, simply bypass all this and open Inventory directly
	if myCont == curOutfitContainer
		
		debug.trace("SFF: [OUTFIT] [INFO]: Outfit opened by Player already in use. Bypassing it and opening Inventory directly...")
		ActivateInventory()		;; sff v1.9.0
		return
	endif


	;; sff v1.8.0 - easy way to store outfit chosen by Player 
	if bCanSetOutfitDialogue()

		_SelectedOutfit= myCont
		_SelectedOutfitList= myFormList
		debug.trace("SFF: [OUTFIT] [INFO]: Dialogue Outfit Setting enabled. '" + _SelectedOutfit.GetBaseObject().GetName() + "' set as main Outfit.")
		;; sff v2.0.0 - would also be nice if we could also set 'SFF_MCM_SelectedOutfit' to correct index (so MCM dropdown reflects our choice here)
	endif
	
	;; enable Previewer flag
	bPreviewerCanWork= SFF_MCM_OutfitPrev.GetValue()
	

	;; if the Outfit Container opened is one currently in use,
	;; make sure to move the items from Inventory back to the Container (if not Container Menu will be empty).
	;; if opening any other Outfit, its content will already be in its respective Container,
	;; but current Inventory items must be moved to make space for Preview items
	
	if bPreviewerCanWork
		
		rnpcActor.RemoveAllItems(curOutfitContainer)	;; Inventory now empty and ready to receive the 'dummy' preview items (Inventory 'cleansed')
	endif

	
	;; if all's fine, we can finally open the container
	ActivateOutfitCont(myCont)
EndFunction

;Bool Property bBlockSandboxTemp auto conditional	;; sff v1.7.1 ~ for blocking sandbox while in preview mode (v2.0.0 - OBSOLETE!)

;; SFF v1.7.1 
;; centralise repeating code from 'CustomOutfitManager()' related to SkyrimSouls:RE compatibility
Function SSREMidProcessCode()
	;; messy code, but necessary to make sure 'Previewer' feature works with SkyrimSouls:RE.
	if !bIsSSREInstalled()
		utility.wait(0.1)	;; force code to pause until menu is quit
	else
		While (Utility.IsInMenuMode())	;; force code to pause while menu open
			Utility.Wait(0.1)
		EndWhile
	endif
EndFunction

;; SFF v1.5.0
;; function created by breaking it from 'OpenCustomOutfitCont()', to better synchronise and organise code called by 'sif_outfitmanagement'.
;; 2nd part of custom outfit code: under what circumstances GIVE ITEMS BACK to Serana.
Function CustomOutfitManager(ObjectReference myCont, FormList myFormList)
;; 'OpenCustomOutfitCont()' sent our ORIGINAL Inventory items back to their Container (clean slate);
;; 'sif_outfitmanagement' script added 'dummy' items to Inventory for Previwer to function;
;; now we need to (a) once again clean our Inventory; and (b) decide which Outfit and its items to return to it...


	;; SFF v1.5.0 - if 'Previewer' enabled,
	;;	sanitise Inventory first (if required)					(a)
	if bPreviewerCanWork
		
		debug.Trace("[SFF][Previewer] Preemptive call to remove 'preview items' from Inventory.")
		
		;; sff v1.7.1 ~ for making sure Previewer feature is compatible with SkyrimSouls:RE
		SSREMidProcessCode()		
		
		rnpcActor.RemoveAllItems(SFF_ProxyForm)	;; remove all items to this holding cont.. Non-armour items will be returned. Rest will be destroyed.

		debug.Trace("[SFF][Previewer] Inventory sanitised: preview items removed.")	
	endif
	
	;; sff v2.0.0 ~ ?? what list?
	Utility.Wait(0.25)					;; hang code to ensure 'sif_outfitmanagement' list is complete 
	
	
	;; if Dialogue Setter enabled and Serana NOT using Home/Sleep outfit,
	;; and NEITHER Conditional Outfits (e.g, Urban Outfit, as COC returns if passed Outfit same as one in use),
	;;	call COC so we can determine which Outfit to equip
	if bCanSetOutfitDialogue() && !bUsingIndoorsOutfit() && !bUsingConditionalOutfit()
		ConditionalOutfitController()
		return
	endif
	
	;; if we NOT using Dialogue Setter, ALWAYS return the 'current outfit' items to Serana (or else she will be nude)
	;; same for if using Indoors/Conditional Outfits (Home/Sleep/Urban/Night/Combat)
	curOutfitContainer.RemoveAllItems(rnpcActor)
	
	
	AddAccessories()	;; we should re-add Accessory items...		
	bAvailableInvHood() ;; sff v1.8.0 - make sure to refresh Custom Hoodie, if using Organic Hoodie, to check for correct hoodie
						;; HoodieManager() will be called anyways when Outfit Containers or Inventory is closed
	debug.trace("@@@-@@@-@@@ Preview finished. Outfit items should be back in Serana's Inventory @@@-@@@-@@@ ")
EndFunction

;; sff v2.0.0 - called by some dialogue fragment scripts ('SFF__TIF__041E68FA', 'SFF__TIF__041E68FB', ...) (easier chaining here than editing those scripts to call 'EmptyOutfits()' directly)
Function ResetOutfit()
	SFF_MCM.EmptyOutfits()
EndFunction



;; set in 'AddOutfit2Inventory()', used by 'bAvailableInvHood()'
Bool bAddingItems

;; --------------------


Function ArmourSafekeeping (int ctrl)
		if (ctrl==0)
			rnpcActor.RemoveAllItems(SafeHoldingCont)
			debug.trace("SFF:: OutfitSys.:: INFO:: All Inventory items moved to a safe container.")
		elseif (ctrl==1)
			SafeHoldingCont.RemoveAllItems(rnpcActor)
			debug.trace("SFF:: OutfitSys.:: INFO:: Items in safe container returned to Serana.")
		;; sff v1.6.0
		elseif ctrl==2
			if curOutfitContainer != none
				SafeHoldingCont.RemoveAllItems(curOutfitContainer)
				debug.trace("[INFO] SFF:: OutfitSys.:: Items in safe container returned directly to current outfit container.")
			endif
		endif
EndFunction


;; ///////////////////////// OUTFIT PREVIEWER CODE ///////////////////////////
GlobalVariable Property SFF_MCM_OutfitPrev auto 			;;SFF v1.5.0 - stores current status of Outfit Previewer toggle
ObjectReference Property SFF_ProxyForm auto					;; SFF v1.5.0 - cache container, for filtering and processing 'preview items'


ObjectReference Property SFF_Previewer_Light auto ;; SFF v1.7.1 - for adding body light source for 'Previewer' feature

Spell Property Candlelight_SFF auto
ObjectReference Property PreviewerLightMarker auto
GlobalVariable Property SFF_MCM_EnablePreviewLight auto

Bool bPrevLightOn
Bool bOpenedContainer ;; sff v1.7.2 - indicates if Player has opened any Container while talking to Serana (Custom/Interior/Inventory/Backpack etc.)
BOOL bOpenedInventory ;; sff v1.8.1 - indicates if Player has opened Serana's Inventory!
;BOOL bContainerIsCustomOutfit

;; v1.7.1 - for enabling 'Previewer Light' feature to work when opening Inventory (or any other container while in dialogue with Serana)
;; called externally from MCM ('Previewer Light' toggle)
Function PreviewerLightMenuRegisterer(bool register)
	if register
		RegisterForMenu("ContainerMenu")
		return
	endif
	
	UnregisterForMenu("ContainerMenu")
EndFunction

;; SFF v1.9.0 - for checking if Serana is using a Torch or not
Bool Function bIsUsingTorch()
	;; RETURN rnpcActor.GetEquippedItemType(0) == 11
	if rnpcActor.GetEquippedItemType(0) == 11
		return true
	endif
	return false
EndFunction

Event OnMenuOpen(String MenuName)
	
	if MenuName != "ContainerMenu"
		RETURN
	endif
	
	if !rnpcActor.IsInDialogueWithPlayer()
		return
	endif

	ObjectReference curContObjRef = GetMenuContainer()

	
	if curContObjRef != none
		
		;; sff v1.9.0 - non-outfit containers should not trigger any of the previewer features
		
		if GetFormEditorID(curContObjRef.GetBaseObject()) != "SFF_MainOutfit_01_Container" && GetFormEditorID(curContObjRef.GetBaseObject()) != "SFF_MainOutfit_02_Container" && GetFormEditorID(curContObjRef.GetBaseObject()) != "SFF_MainOutfit_03_Container" && GetFormEditorID(curContObjRef.GetBaseObject()) != "SFF_MainOutfit_04_Container" && GetFormEditorID(curContObjRef.GetBaseObject()) != "SFF_MainOutfit_05_Container" && GetFormEditorID(curContObjRef.GetBaseObject()) != "SFF_OutfitContainer" && GetFormEditorID(curContObjRef.GetBaseObject()) != "SFF_SleepOutfitContainer" && GetFormEditorID(curContObjRef.GetBaseObject()) != "DLC1Serana"
			return

		else
			debug.trace("++++++++++> Outfit Container MENU OPENED <++++++++++")
			
			bOpenedContainer= true	;; sff v1.7.2
			
			if GetFormEditorID(curContObjRef.GetBaseObject()) == "DLC1Serana"
				bOpenedInventory= TRUE
				debug.trace(" [DEBUG] [INFO] SFF: current opened container matches Serana's Inventory: " + curContObjRef as STRING)
			endif
		endif
	endif
	
	if bIsSSREInstalled() && SFF_MCM_OutfitPrev.GetValue() == 1 
		PreviewerLightToggler(1)
		
		if !bIsUsingTorch()
		
			rnpcActor.EnableAI(false)	;; sff v1.9.0 - freezes Serana for preview, but only if SS:RE installed (and Previewer feature enabled)
		endif
		

		;; SFF v2.0.0 - TESTING: solution for htd issues when in Preview mode
		sHDTConfigs = FilesInFolder("data/SKSE/Plugins/hdtSkinnedMeshConfigs/SFF", "*")
		
		if !sOld_Dir || !sNew_Dir
			sOld_Dir= PullStringFromIni("data/Serana Follower Framework.ini", "Previewer", "OldPath")
			sNew_Dir= PullStringFromIni("data/Serana Follower Framework.ini", "Previewer", "NewPath")
		endif
		
		SwapHDT(_player, sOld_Dir, sNew_Dir)
	endif
EndEvent

;; SFF v2.0.0 - remember to run this OnInit() so we can fill it once and be done with it (they should be permanent);
STRING sOld_Dir
STRING sNew_Dir

STRING[] sHDTConfigs	;; array with names of all files contained in SFF hdt folder. Filled in 'OnOpenMenu()'.

Function SwapHDT(Actor myActor, String old_physx_file_path, String new_physx_file_path)
	
	int iListLength = sHDTConfigs.Length
	
	if iListLength == 0
		;; folder empty
		debug.trace("----------->>> No HDT configs found in 'SFF' folder!")
		return
	else
		debug.trace("----------->>> HDT configs found: " + iListLength)
	endif	
	
	
	int i = 0
	
	while i < iListLength
		
		;; if the hdt config. not actively in use, it will not be swapped (the function will return false)
		if SwapPhysicsFile(myActor, old_physx_file_path + sHDTConfigs[i], new_physx_file_path + sHDTConfigs[i], false, true)
			debug.trace("----------->>> Config. file n" + (i+1) + " (" + sHDTConfigs[i] + ") swapped.")
		endif
		;debug.trace("----------->>> OLD Config. file path: " + sOld_Dir + sHDTConfigs[i])
		;debug.trace("----------->>> NEW Config. file path: " + sNew_Dir + sHDTConfigs[i])
		i += 1
	endwhile	
EndFunction

Event OnMenuClose(String MenuName)
	
	If MenuName == "ContainerMenu"
	
		debug.trace("++++++++++> Container MENU CLOSED <++++++++++")
	
		if bPrevLightOn
			PreviewerLightToggler(0)
		endif
		
		if bOpenedContainer && !rnpcActor.IsInDialogueWithPlayer()
			ActivatePlayer()
		endif
		
		if bOpenedContainer
			if !rnpcActor.IsAIEnabled()	;; sff v1.9.0 - unfreeze Serana, if frozen
				rnpcActor.EnableAI()
				
				if SFF_IsSeranaUsingFurniture.GetValue() != 1
					;; sff v1.9.0 - refresh/reset animations only if Serana not using furniture (stops aborting furniture anim. unecessarily)
					IDLE PreviewerAnimFixer = Game.GetFormFromFile(0x0010D9EE, "Skyrim.esm") As IDLE
					rnpcActor.PlayIdle(PreviewerAnimFixer)
					Debug.SendAnimationEvent(rnpcActor, "IdleForceDefaultState")
				endif
			endif
			
			;; sff v2.0.0 - we need this code to make sure Indoors Outfit is REMOVED if emptied by Player while in use by Serana
			if (curOutfitContainer == OutfitContainer && !bHomeOutfitFilled() ) || (curOutfitContainer == SleepOutfitContainer && !bSleepOutfitFilled() )
				debug.trace("[SFF] [OUTFIT] [INFO]: Indoors Outfit emptied while in use.")
				CentralOutfitProcessor()
			endif
							
			bOpenedContainer= false 	;; clear flag 
			
			;; extracted from 'SFF_SunDamageController' script (sff v1.8.1)
			;; make sure to only call 'HoodieManager()' if we closing Serana-related container!
			;; we need to call this BEFORE clearing 'bOpenedInventory', but AFTER 'bOpenedContainer', or else 'bAvailableInvHood' will always return false... (sff v1.9.0)
			If bOpenedInventory
				debug.trace("=======> INVENTORY CLOSED <=======")
				
				;; SFF v1.9.0 - adding head items directly to Inventory does not update our hoodie. Not a problem usually, but if using Organic Hoodie, becomes an annoying issue as prior hoodie (especially vanilla) stops 'bAvailableInvHood()' from getting called, while the actual Inventory hoodie candidate stops the prior hoodie from being equipped. 
				if bAvailableInvHood()	;; clear and update hoodie; if all clear, re-run Manager... 
					debug.trace("=======> INV. HOODIE AVAILABLE! <=======")
				endif
				
				EquipElderScroll()	;; SFF v1.2.1: if Inventory opened, check for Elder Scroll equip (to avoid constant OnUpdate calls), as changing clothing leads to Scroll going missing
				
				if SFF_SunDamage.GetValue() == 1
					SDC.CheckClothingProtection()
				endif 
				
				bOpenedInventory= false		;; clear flag (v1.8.1)
			EndIf
			
			HoodieManager()					;; sff v1.8.1 - updates hoodie immediately (no waiting for Update() cycle)


			;; SFF v2.0.0 - 'solution' for htd issues when in Preview mode
			if bIsSSREInstalled() && SFF_MCM_OutfitPrev.GetValue() == 1
				SwapHDT(_player, sNew_Dir, sOld_Dir)
			endif
			
		endif
	EndIf
EndEvent

;; sff v1.7.2 - for a more robust solution to 'frozen in place' bug after sudden dialogue exit ('Previewer' feature)
Function ActivatePlayer()
	if bIsSSREInstalled()
		rnpcActor.Activate(_player)	;; SFF v1.7.1 - this avoids cases of Player getting completely stuck if dialogue menu cut off during Preview
	endif
EndFunction

;; outlines certain conditions for Previewer Light to work (being indoors, or currently at night)
Bool Function bCanToggleLight()
	RETURN rnpcActor.IsInInterior() || fCurTime() < 5.0 || fCurTime() > 19.0
EndFunction

Function PreviewerLightToggler(int mode)
	if SFF_MCM_EnablePreviewLight.GetValue() != 1
		SFF_Previewer_Light.Disable()
		bPrevLightOn= false
		return
	endif
	if mode == 1 && bCanToggleLight()
		;Candlelight_SFF.Cast(rnpcActor, rnpcActor)
		SFF_Previewer_Light.Enable()
		SFF_Previewer_Light.MoveTo(rnpcActor, 35.0* Math.Sin(rnpcActor.GetAngleZ()), 35.0* Math.Cos(rnpcActor.GetAngleZ()), (rnpcActor.GetHeight() - 1)) ;; x (front/back), y (left/right), z (top/bottom)
		bPrevLightOn= true
		return
	endif
	;rnpcActor.DispelSpell(Candlelight_SFF)
	SFF_Previewer_Light.Disable()
	bPrevLightOn= false
EndFunction

Function QueueLegacyRefresh()
	TriggerObj(50.0)
EndFunction

Form EquippedItemL
Form EquippedItemR	;; sff v1.7.2
Int iMyCountL
Int iMyCountR
;; For making sure torch animation does not conflict with features
;; sff v1.7.2 - use this to unequip torch before playing hoodie anim.
Function DisableHandTorch(bool disable)
	;; sff v1.7.1 -------
	;; for removing torch (or any other item) from left hand 
	
	if disable
		EquippedItemL = rnpcActor.GetEquippedObject(0) ; Check Left Hand
		;EquippedItemR = rnpcActor.GetEquippedObject(1) ; Check Right Hand
		
		if EquippedItemL != none
			iMyCountL= rnpcActor.GetItemCount(EquippedItemL)
			rnpcActor.UnequipItemEx(EquippedItemL, 2)
			;rnpcActor.RemoveItem(EquippedItemL, iMyCount)
			Debug.Trace("SFF:: Previewer:: Left hand emptied.")
		else
			iMyCountL= 0 ;; sff v1.7.2 - reset counter
		endif
		
		;if EquippedItemR != none
		;	iMyCountR= rnpcActor.GetItemCount(EquippedItemR)
		;	rnpcActor.UnequipItemEx(EquippedItemR, 1)
			;rnpcActor.RemoveItem(EquippedItemL, iMyCount)
		;	Debug.Trace("SFF:: Previewer:: Right hand emptied.")
		;else
		;	iMyCountR= 0 ;; sff v1.7.2 - reset counter
		;endif
		
		return
	endif
	
	if EquippedItemL != none && iMyCountL > 0
		;rnpcActor.AddItem(EquippedItemL, iMyCount)
		rnpcActor.EquipItemEx(EquippedItemL, 2, false)
		iMyCountL= 0;
		Debug.Trace("SFF:: Previewer:: Left hand restored.")
	endif
	
	;if EquippedItemR != none && iMyCountR > 0
		;rnpcActor.AddItem(EquippedItemL, iMyCount)
	;	rnpcActor.EquipItemEx(EquippedItemR, 1, false)
	;	iMyCountR= 0;
	;	Debug.Trace("SFF:: Previewer:: Right hand restored.")
	;endif
EndFunction

;; Forces Serana to reset anim. while in menu
;; Cannot implement via SKSE plugin: CommonLib has no 'Enable()' function, so disable-enable chain impossible. 
;; called externally from 'sif_outfitmanagement'
Function ResetSeranaInPreview()
	;; NOTES: 
	;; 'QueueNiNodeUpdate' only works (when game paused, at least) if Actor is refreshed (disabled/re-enabled)
	;; Refreshing Serana, however, leads to crashes when in Inventory menu: opening Inevntory twice and selecting an equipped weapon item will freeze (SE) or crash (AE) game
	;; THUS, this function can only be used while in custom Containers, acting as proxies to Inventory
	
	;PreviewerLightToggler(1)	;; SFF v1.7.1 - enable preview light. Canna do with CommonLib, as canna access/manipulate unloaded references...
	
	;; SFF v1.7.1 - SS:RE compatibility: if Skyrim Souls installed, no need to run any of this, as Serana canna be T-posed!
	if bIsSSREInstalled()
			
		While (Utility.IsInMenuMode())
			Utility.Wait(0.1)
		EndWhile
		return
	endif
	
	;; store current position coordinates (after Serana already moved to preview pos.; this is because disabling actor moves them)
	float curXpos= rnpcActor.GetPositionX();
	float curYpos= rnpcActor.GetPositionY();
	float curZpos= rnpcActor.GetPositionZ();
	
	;; resets Serana's 3D
	rnpcActor.Disable()
	rnpcActor.Enable()
	
	;; return Serana to her Preview pos.
	rnpcActor.SetPosition(curXpos, curYpos, curZpos)
	
	rnpcActor.QueueNiNodeUpdate()

	Debug.Trace("->-> [SFF] [Previewer]: Serana menu T-pose.")
	
	utility.wait(0.01)	;; gimmick to force-hang code until Menu is quit
	
	rnpcActor.Activate(_player)	;; disabling/enabling Serana exits Dialogue Menu. Force-activate Serana on Menu exit. 
EndFunction
;; ///////////////////////// END ////////////////////////////


;; //////////////////////// ACCESSORY ITEMS ///////////////////////// (SFF v1.9.0)
FormList Property SFF_AccessoryList auto conditional	;; SFF v1.9.0 - used by 'SFF_CustomHoodieDetector'; used for storing and managing 'Acessory Container' content
ObjectReference Property SFF_Acessory_Container auto conditional	;; SFF v2.0.0 wtf?	
ObjectReference Property SFF_Accessory_Container auto conditional

;; called externally by fragment script ('SFF__TIF__043F51B7')
Function OpenAccessoryContainer()
	SFF_Acessory_Container.Activate(_player)
EndFunction
;; ///////////////////////// END ////////////////////////////


;; //////////////////////// CONDITIONAL OUTFITS /////////////////////////

;; initially empty, these get dynamically filled by MCM menu. Reflects chosen conditions by Player and respective outfit containers,
;; so we can force Serana to use them when condition met.
ObjectReference Property _CombatOutfit auto conditional
FormList Property SFF_fList_CombatOutfit auto conditional
;; City Outfit
ObjectReference Property _TownOutfit auto conditional
FormList Property SFF_fList_TownOutfit auto conditional
;; Night-time Outfit (v1.8.0)
ObjectReference Property _NightOutfit auto conditional
FormList Property SFF_fList_NightOutfit auto conditional


ObjectReference PROPERTY priorOutfitContainer AUTO 	;; cache the container just changed
FormList PROPERTY fList_priorOutfitList	Auto		;; cache respective formlist

ObjectReference PROPERTY priorCombatOutfit AUTO		;; cache the Outfit in use before change to Combat Outfit
FormList PROPERTY fList_priorCombatOutfitList AUTO	;; cache respective formlist

;; v1.8.0 - set by MCM menu AND/OR by CustomOutfitManager() (when 'MCM exclusive setting' DISABLED)
;; static property to hold Player-chosen outfit set (using curOutfit not ideal, as it can dynamically change; nor chains of 'chached' outfits, which quickly become unwealdy)
;; used to revert Night-time Outfit back to our default chosen outfit
ObjectReference Property _SelectedOutfit auto Conditional
FormList Property _SelectedOutfitList auto Conditional 

Keyword Property LocTypeCity auto	;; 'City' kword - useless: not only city proper, but all of external cells around Whiterun considered 'City'
FormList Property RidableWorldSpaces auto ;; vanilla. Stores all "open" spaces, which clearly are not "City" (Tamriel, Blackreach, Dayspring Canyon, Soul Cairn)

Bool Function bIsInCity()
	;; if Player is in ANY of the listed WorldSpaces, definately not in city.
	if RidableWorldSpaces.HasForm(_player.GetWorldSpace() as FORM)
		RETURN FALSE
	endif
	
	if _player.GetCurrentLocation() == none
		debug.trace("[WARNING] SFF:: Player currently registered as in a 'none' location...")
		RETURN FALSE
	endif
	
	;; if neither cur. loc. nor its parent loc. have 'City' kword,
	if !_player.GetCurrentLocation().HasKeyword(LocTypeCity) 
		
		if GetParentLocation(_player.GetCurrentLocation()) != none && GetParentLocation(_player.GetCurrentLocation()).HasKeyword(LocTypeCity)
			debug.trace("[INFO] SFF:: CustomOutfit:: Conditions:: Current loc. has no 'City' kword, but its parent loc. has.")
			RETURN TRUE
		ELSEIF GetParentLocation(GetParentLocation(_player.GetCurrentLocation())) != none && GetParentLocation(GetParentLocation(_player.GetCurrentLocation())).HasKeyword(LocTypeCity)
			;; oh god... Inception-esque vibes...
			debug.trace("[INFO] SFF:: CustomOutfit:: Conditions:: Current loc. has no 'City' kword, neither its parent loc., but parent loc.'s parent has! (Player most likely in Solitude...)")
			RETURN TRUE
		endif
		 
		RETURN FALSE
	endif
	
	;DEBUG.TRACE("SFF:: Player in a City location.")
	RETURN TRUE
EndFunction

;; //////////////////////// END /////////////////////////////

ObjectReference Property SFF_OutfitContainer auto 	;; sff v1.9.0 - Home Outfit container ref. (for Outfit Sys. rework) OBSOLETE. ALREADY AN EXISTING PROPERTY 

;; SFF v2.0.0 ~ Indoors Outfit list unreliable when used outside baked outfits (moving items from Container to Inventory will cause list to zero)
FormList Property SFF_Perma_HomeOutfitList auto
FormList Property SFF_Perma_SleepOutfitList auto

Bool function bHomeOutfitFilled()
	return SFF_Perma_HomeOutfitList.GetSize()
EndFunction

Bool function bSleepOutfitFilled()
	return SFF_Perma_SleepOutfitList.GetSize()
EndFunction



;; NEW CODE!

Bool Function bIsHome()
	Location loc = _player.GetCurrentLocation()
	RETURN loc.HasKeyword(LocTypePlayerHouse) || SFF_fList_customHomeCell.HasForm(loc as Form) 
EndFunction

Bool Function bIsHomeOwned()
	Cell playerCell = _player.GetParentCell()
	Location loc = _player.GetCurrentLocation()
	RETURN playerCell.GetFactionOwner() == PlayerFaction || playerCell.GetActorOwner() == _player.GetActorBase() || SFF_fList_customHomeCell.HasForm(loc as Form)
EndFunction

Bool Function bUsingConditionalOutfit()
	RETURN curOutfitContainer == _TownOutfit || curOutfitContainer == _NightOutfit || curOutfitContainer == _CombatOutfit
EndFunction

ObjectReference Function _HomeOutfit()
	RETURN SFF_OutfitContainer
EndFunction

ObjectReference Function _SleepOutfit()
	RETURN SleepOutfitContainer
EndFunction

ObjectReference Property previousOutfit				auto						;; last outfit in queue
FormList		Property previousOutfitList			auto
FormList 		Property curOutfitList 				auto conditional			;; the Outfit Serana has currently equipped




;; we need a Condition to assign a '_SelectedOutfit' in case it is EMPTY or incorrectly assigned (e.g., assigned to Indoors Outfits)
Function MainOutfitCorrector(bool c=true)
	
	if c
		;; if '_SelectedOutfit' exists and is NOT an Indoors Outfit
		if _SelectedOutfit && !bIsIndoorsOutfit(_SelectedOutfit)
			;; nothing to do...
			RETURN
		endif
		

		debug.trace("[SFF] [OUTFIT] [WARNING]: Main Outfit incorrectly assigned...")
	endif

	if !bOutfitInUse(SFF_MCM.SFF_Outfit01_Container)

		_SelectedOutfit = SFF_MCM.SFF_Outfit01_Container
		_SelectedOutfitList =	SFF_MCM.SFF_Outfit01_FormList
		
		debug.trace("[SFF] [OUTFIT] [INFO]: Assigning Main Outfit as Outfit 01.")
		
	elseif !bOutfitInUse(SFF_MCM.SFF_Outfit02_Container)

		_SelectedOutfit = SFF_MCM.SFF_Outfit02_Container
		_SelectedOutfitList =	SFF_MCM.SFF_Outfit02_FormList
		
		debug.trace("[SFF] [Outfit] [INFO]: Assigning Main Outfit as Outfit 02.")
		
	elseif !bOutfitInUse(SFF_MCM.SFF_Outfit03_Container)

		_SelectedOutfit = SFF_MCM.SFF_Outfit03_Container
		_SelectedOutfitList =	SFF_MCM.SFF_Outfit03_FormList

		debug.trace("[SFF] [Outfit] [INFO]: Assigning Main Outfit as Outfit 03.")
		
	elseif !bOutfitInUse(SFF_MCM.SFF_Outfit04_Container)

		_SelectedOutfit = SFF_MCM.SFF_Outfit04_Container
		_SelectedOutfitList =	SFF_MCM.SFF_Outfit04_FormList

		debug.trace("[SFF] [Outfit] [INFO]: Assigning Main Outfit as Outfit 04.")
		
	elseif !bOutfitInUse(SFF_MCM.SFF_Outfit05_Container)

		_SelectedOutfit = SFF_MCM.SFF_Outfit05_Container
		_SelectedOutfitList =	SFF_MCM.SFF_Outfit05_FormList
		debug.trace("[SFF] [Outfit] [INFO]: Assigning Main Outfit as Outfit 05.")
	endif
EndFunction

Function AddAccessories()
	int iAccessoriesListSize= SFF_AccessoryList.GetSize()
	int iAcLiIndex = 0
	
	if !bCustomOutfitAccessoryBlock()
		while iAcLiIndex < iAccessoriesListSize
		
			Form entry = SFF_AccessoryList.GetAt(iAcLiIndex)
			bAddingItems= true
			
			;; only add Accessory item IF none already present in Inventory (to avoid duplication)
			;; NOTE: Player must make sure not adding items already in Accessories Container to Inventory (or latter will get eventually deleted)
			if rnpcActor.GetItemCount(entry) == 0
				rnpcActor.AddItem(entry, 1)
				Debug.Trace("[SFF] [ACCESSORIES] [INFO]: '" + entry.GetName() +"' not found in Inventory. Adding a copy to it.")
			else
				Debug.Trace("[SFF] [ACCESSORIES] [INFO]: '" + entry.GetName() +"' already in Inventory. No need to add it!")
			endif
			iAcLiIndex += 1
		endwhile 
		
		bAddingItems= false
	endif	
EndFunction

;; called by MCM menu
Function RemoveAccessories()
	int iAccessoriesListSize= SFF_AccessoryList.GetSize()
	int iAcLiIndex = 0
	
	if bCustomOutfitAccessoryBlock()
		while iAcLiIndex < iAccessoriesListSize
		
			Form entry = SFF_AccessoryList.GetAt(iAcLiIndex)
			bAddingItems= true
			
			;; NOTE: Player must make sure not adding items already in Accessories Container to Inventory (or latter will get eventually deleted)
			if rnpcActor.GetItemCount(entry) > 0
				rnpcActor.RemoveItem(entry, 1)
				Debug.Trace("[SFF] [ACCESSORIES] [INFO]: '" + entry.GetName() +"' found in Inventory and removed.")
			else
				Debug.Trace("[SFF] [ACCESSORIES] [INFO]: '" + entry.GetName() +"' not found in Inventory. Nothing to remove!")
			endif
			iAcLiIndex += 1
		endwhile 
		
		bAddingItems= false
	endif	
EndFunction



;; run this on Update()...
;; Part 2a of Conditional Outfits code
;; here we determine if 'Night Outfit' should be equipped based on current TIME;
;; also hijacked to remove Combat Outfit if not in combat
Function NightOutfitMonitor()
	;; sff v2.0.0 - more efficient way of running the Conditionals framework:
	;; the only Conditional Outfit that requires Update checks is the Night Outfit (Urban can be detected on cell change; Combat, with Combat events)
	
	
	;; if NOT using Indoors or Urban Outfit, and 
	if bUsingIndoorsOutfit() || curOutfitContainer == _TownOutfit
		RETURN
	endif
	
	
	;; hijack this function to also detect Combat Outfit
	if curOutfitContainer == _CombatOutfit && !rnpcActor.IsInCombat()
		CentralOutfitProcessor()
	endIf
	
	; if Night Outfit filled,
	;; Serana NOT using it,
	;; and it is night time,
	;; equip it!
	if (fCurTime() >= 19 || fCurTime() <= 5) 
		
		if _NightOutfit && curOutfitContainer != _NightOutfit
			;; call COC
			debug.trace ("SFF: [OUTFIT] [INFO]: Night Outfit not equipped, but currently nighttime...")
			ConditionalOutfitController()
		endif
	
	;; else, if daytime and Night Outfit in use,
	else
		if curOutfitContainer == _NightOutfit
			;; call COC
			debug.trace ("SFF: [OUTFIT] [INFO]: Night Outfit in use, but currently daytime...")
			ConditionalOutfitController()
		endif
	endif
EndFunction

;; Part 2b of Conditional Outfits code
;; here we determine what 'Outdoors Outfit' (Urban, Night or 'Main') we should equip
Function ConditionalOutfitController()
	if rnpcActor.IsInCombat()
		;; if in combat, skip code below.
		Debug.Trace("SFF: [OUTFIT] [INFO]: Equipping Combat Outfit...")
		OutfitEquipper(_CombatOutfit, SFF_fList_CombatOutfit)
		
		RETURN
	endif 
	
;; SFF v2.0.1 - we might not want the Conditionals check to run if calling change from MCM menu,
;; as Outfit may not update: e.g. if Urban Outfit set and Player changes main Outfit via menu,
;; the chosen Outfit stats will not update, as COC stops it from being applied. 02 possible solutions: 
;; - on MCM script, check for size directly from Container instead of Inventory (but no Sun Damage nor armour rating available);
;; - capture condition here, and skip the Conditionals checks, forcing Outfit to be equipped and re-run COC when exiting MCM
	Bool bIsMCMMenuOpen = UI.IsMenuOpen("Journal Menu")
	
	if !bIsMCMMenuOpen
		;; primacy should be given to Urban Outfit, as if in city and outfit set, no other outfit (save for Combat Outfit) should be in use! 
		if bIsInCity() && _TownOutfit
			Debug.Trace("SFF: [OUTFIT] [INFO]: Equipping Urban Outfit...")
			OutfitEquipper(_TownOutfit, SFF_fList_TownOutfit)
			return
		endif
		
		if _NightOutfit && (fCurTime() >= 19 || fCurTime() <= 5)
			Debug.Trace("SFF: [OUTFIT] [INFO]: Equipping Nighttime Outfit...")
			OutfitEquipper(_NightOutfit, SFF_fList_NightOutfit)
			return
		endif
	
	else
		Debug.Trace("SFF: [OUTFIT] [INFO]: Player setting Outfits via MCM. Skipping Conditionals checks so Outfit can be immediately equipped and stats seen...")
	endif
	
	;; if none of the conditions above met, simply equip the 'main' outfit last chosen by Player
	MainOutfitCorrector()	;; just make sure our 'main' outfit is actually 'fit' to be used
	Debug.Trace("SFF: [OUTFIT] [INFO]: Equipping last Player-chosen Outfit ('" + _SelectedOutfit.GetBaseObject().GetName() + "').")
	OutfitEquipper(_SelectedOutfit, _SelectedOutfitList)
EndFunction

;; call on cell change
;; Part 1 of Conditional Outfits code
;; here we determine if and what Indoors Outfits (Home or Sleep) should be applied 
Function CentralOutfitProcessor()
	
	;; we are in a Player-owned Home cell,
	if bIsHome() && bIsHomeOwned()
		Debug.Trace("SFF: [OUTFIT] [INFO]: Outfit sys. called; Player in owned Home cell.")
		
		;; and it is not yet sleep time OR it is sleep time but our Sleep Outfit is empty.
		if !bSleepTime || bSleepTime && !bSleepOutfitFilled()
			
			;; if our Home Outfit is filled, we should equip it.
			if bHomeOutfitFilled()
				;; Equip Home Outfit 
				OutfitEquipper(_HomeOutfit(), ItemList)
			
			;; if Home Outfit not filled...
			else
				Debug.Trace("SFF: [OUTFIT] [INFO]: Home Outfit EMPTY.")
				;; do nothing
				
				;; UNLESS... we are ALREADY using Home Outfit. That means Outfit was emptied while in use, so we should unequip it...
				if curOutfitContainer == _HomeOutfit()
					Debug.Trace("SFF: [OUTFIT] [INFO]: Home Outfit emptied WHILE in use! Unequipping it...")
					
					ConditionalOutfitController()
				
				endif
			endif
		
		
		elseif bSleepTime
			
			;; if Sleep time and Outfit filled,
			if bSleepOutfitFilled()
				OutfitEquipper(_SleepOutfit(), SleepOutfitList)	;; equip it
			
			;; if Sleep Outfit not filled...
			else 
				Debug.Trace("SFF: [OUTFIT] [INFO]: Sleep Outfit EMPTY.")
				;; do nothing	

				;;UNLESS... we are ALREADY using Sleep Outfit. That means Outfit was emptied while in use, so we should unequip it...
				if curOutfitContainer == _NightOutfit
					Debug.Trace("SFF: [OUTFIT] [INFO]: Sleep Outfit emptied WHILE in use! Unequipping it...")
					
					if bHomeOutfitFilled()
						OutfitEquipper(_HomeOutfit(), ItemList)		;; equip Home Outfit, if not empty;
					else
						ConditionalOutfitController()							;; or determine which outfit should be used...
					endif
				endif
			endif
			
		endif
	
	elseif !bIsHome()
		;; COC must always be called. If not, when changing cells, Outfits will not change in accordance to conditions...
		ConditionalOutfitController()

	endif
EndFunction


;; this is the code that actually manages the transfer of items between Outfits
;; merges together a myriad of previous functions ('ReturnOutfit2Container()', 'AddOutfit2Inventory()', 'MCMCustomOutfit()')
Function OutfitEquipper(objectreference myCont, formlist myList)
	debug.trace("SFF: [OUTFIT] [INFO]: Outfit change requested.")
	
	while bAddingItems
		debug.trace("SFF: [OUTFIT] [INFO]: Outfit change requested, but function already running! Waiting and trying again...")
		
		;; sff v2.0.1
		if !bIsSSREInstalled()
			utility.wait(1.0)	;; force code to pause until menu is quit
		else
			if (Utility.IsInMenuMode())	;; force code to pause while menu open
				Utility.WaitMenuMode(1.0)
			endif
		endif
	endwhile
	
	;; to make sure we don't run code if 'curOutfitContainer' empty 
	if !curOutfitContainer
		debug.trace("->->->->-> SFF: [ERROR]: no assigned Outfit detected in use! Due to risk of item loss, new Outfit will be assigned.")
		MainOutfitCorrector()
		if _SelectedOutfit
			debug.trace("SFF: [OUTFIT] [INFO]: '" + _SelectedOutfit.GetBaseObject().GetName() + "' set as current outfit...")
		else
			debug.trace("->->->->-> SFF: [ERROR]: No Outfit could be assigned to Serana. We cannot proceed with Outfit change request. Aborting code execution...")
			RETURN
		endif
	endif
	
	if myCont == curOutfitContainer
		debug.trace("SFF: [OUTFIT] [INFO]: Outfit change requested, but '" + myCont.GetBaseObject().GetName() + "' already in use! Abort code.")
		RETURN
	endif

	
	int i
	
	
	DefautHoodieClenser(MM.Hoodie)	;; call this to make sure it is duly removed beforehand
	
	
	;; remove all items from Inventory, returning them to their Container
	rnpcActor.RemoveAllItems(curOutfitContainer)
	while SFF_SeranaInventoryList.GetSize() != 0 && i < 3	;; hang code to make sure items sent to Inventory ONLY IF all prior items removed (Inventory empty)
		bAddingItems= true
		debug.trace("->->->->-> SFF: [ERROR]: Unsuccessful attempt[" + i +  "] to empty Inventory. Still " + SFF_SeranaInventoryList.GetSize() + " item(s) left...")
		i += 1 
		
		if !bIsSSREInstalled()
			debug.trace("->->->->-> SFF: [DEBUG]: SS:RE NOT installed. Use traditional Wait().")
			utility.wait(0.3)	;; force code to pause until menu is quit
		else
			debug.trace("->->->->-> SFF: [DEBUG]: SS:RE installed. Use alternative Wait().")
			;While (Utility.IsInMenuMode())	;; force code to pause while menu open
			if Utility.IsInMenuMode()
				debug.trace("->->->->-> SFF: [DEBUG]: we in MENU MODE, boyyyy...")
				Utility.WaitMenuMode(0.3)
			endif
			;EndWhile
		endif
	endwhile
	
	if i < 3
		debug.trace("SFF: [OUTFIT] [INFO]: Inventory empty and ready for '" + myCont.GetBaseObject().GetName() + "'.")	
	else
		debug.trace("SFF: [OUTFIT] [WARNING]: Outfit change requested, but Inventory could not be completely emptied! Applying '" + myCont.GetBaseObject().GetName() + "'.")
	endIf
	
	i = 0
	
	;; cache our current outfit. Mainly useful for reversing Combat Outfit.
	;; that means that Combat Outfit can NEVER be cached, else we might end up in an eternal loop
	if curOutfitContainer != _CombatOutfit
		previousOutfit= curOutfitContainer
		previousOutfitList= curOutfitList
	endif
	
	;; register target outfit as current Outfit
	curOutfitContainer= myCont
	curOutfitList= myList
	
	
	;; now we need code to check and add Accessories (better to do it BEFORE main outfit items, so any conflicting items from latter gets prioritised)
	int iAccessoriesListSize= SFF_AccessoryList.GetSize()
	int iAcLiIndex = 0
	
	if !bCustomOutfitAccessoryBlock()
		while iAcLiIndex < iAccessoriesListSize
		
			Form entry = SFF_AccessoryList.GetAt(iAcLiIndex)
			bAddingItems= true
			
			;; only add Accessory item IF none already present in Inventory (to avoid duplication)
			;; NOTE: Player must make sure not adding items already in Accessories Container to Inventory (or latter will get eventually deleted)
			if rnpcActor.GetItemCount(entry) == 0
				rnpcActor.AddItem(entry, 1)
				Debug.Trace("[SFF] [ACCESSORIES] [INFO]: '" + entry.GetName() +"' not found in Inventory. Adding a copy to it.")
			else
				Debug.Trace("[SFF] [ACCESSORIES] [INFO]: '" + entry.GetName() +"' already in Inventory. No need to add it!")
			endif
			iAcLiIndex += 1
		endwhile 
	endif	
	

	;; now we are ready to give Serana the Outfit content
	curOutfitContainer.RemoveAllItems(rnpcActor)	;; and transfer items to Inventory
	while myList.GetSize() != 0
		bAddingItems= true
		
		if !bIsSSREInstalled()
			utility.wait(0.3)	;; force code to pause until menu is quit
		else
			if (Utility.IsInMenuMode())	;; force code to pause while menu open
				Utility.WaitMenuMode(0.3)
			endif
		endif							;; force function to wait until all items transfered from Container to Inventory
	endwhile
	
	debug.trace("SFF: [OUTFIT] [INFO]: DONE! All '" + curOutfitContainer.GetBaseObject().GetName() + "' items given to Serana.")
	
	bAddingItems= false
	
	;; - call Hoodie code
	DefautHoodieClenser(MM.Hoodie)	;; purge Vanilla hoodie, if existent. 		
	bAvailableInvHood() ;; sff v1.8.0 - make sure to refresh Custom Hoodie, if using Organic Hoodie, to check for correct hoodie

	SDC.OutfitProtecChecker()	;; for updating the Armour rating of our current Outfit;
	 
	if UI.IsMenuOpen("Journal Menu")
		rnpcActor.QueueNiNodeUpdate()
	endif
EndFunction


;; END END END END END END END END END END END END END END END END END END END END END END END END










































Function OnCellChange()				;; called externally (SFF_XMarkerReferenceScript, added to XMarker used to detect Player cell change)
	utility.wait(0.15)				;; to give enough time for Serana to be searched for and moved
	ForcedTeleportation()			;; SFF v1.5.0 - for cases where Serana will not accompany Player when moving between cells
	CheckLocale()					;; call to check current player location (in player home or not)
	CheckSleepTime()
	CentralOutfitProcessor()
	utility.wait(0.15)
	bAvailableInvHood()				;; SFF v1.9.0 - so hoodie system immediately updates what hoodie we should be using. Else, prior hoodie may linger when changing cells/outfits
	HoodieManager()					;; 	SFF v1.9.0 - for immediate hood respose when changing cells, as'OnLocationChange' (on 'DLC1RNPCAliasScript') does not pick up cell changes.  
	
	;; SFF v2.0.1 - to avoid nudeness bug when Serana not a follower (also checked OnCombatStateChanged(), @ 'SFF_CombatHelmetHandler' script)
	; if !rnpcActor.IsPlayerTeammate() && !bForceEquipped
		; Debug.Trace("SFF: We moved cells but Serana NOT a follower. Force-equip outfit...")
		; ForceEquipIntegral()
	; endif
EndFunction


FormList property SFF_fList_customHomeCell auto	;; sff v1.6.2 - stores all custom cells added as home cell by Player
;; sff v1.6.2 - for enabling users to add custom home cells without need for compatibility patches...
Function AddLoc2HomeList(Location wsp)
	if wsp != none
		SFF_fList_customHomeCell.AddForm(wsp)
		debug.trace("[INFO] SFF:: " + wsp + " added as a home cell.")
		debug.notification(wsp.GetName() + " added as a home cell.")
	else
		debug.trace("[ERROR] SFF:: Current cell NULL! Cannot add as a home cell!")
	endif
EndFunction

Function RemoveLocFromHomeList(Location wsp)
	if wsp != none
		SFF_fList_customHomeCell.RemoveAddedForm(wsp)
		debug.trace("[WARNING] SFF:: " + wsp + " removed as a home cell")
		debug.trace(wsp.GetName() + " removed as a home cell.")
	else
		debug.trace("[ERROR] SFF:: Current cell NULL! Cannot add as a home cell!")
	endif
EndFunction

Function CheckLocale()
	Location loc = _player.GetCurrentLocation()
	if (loc != None)
		;; sff v1.6.2 - if Player in a cell added by them to FormList,
		;; that means Player wants it to be a full-fledged home cell. So, let it be so...
		if SFF_fList_customHomeCell.HasForm(loc as Form)
			IsHome= true
			bHomeOwned= true
			return
		endif
		
		if (loc.HasKeyword(LocTypePlayerHouse))
		;Debug.Notification("Player Home")
			IsHome=true
			CheckOwnership()
		else
			IsHome=false
			bHomeOwned= false
			;Debug.Notification("Player NOT Home")
		endif
	else
		IsHome=false
		bHomeOwned= false
		;Debug.Notification("Player NOT Home")
	endif
EndFunction

Function CheckOwnership()
	Cell playerCell = _player.GetParentCell()
	;; SFF v1.2.0 ~ added Actor Owner checks to broaden compatibility: latest playthorugh Severin Manor giving problems, not being in owner faction. Other modded Player houses as well
	if (playerCell.GetFactionOwner() == PlayerFaction || playerCell.GetActorOwner() == _player.GetActorBase())
		bHomeOwned= true
		AddLoc2HomeList(_player.GetCurrentLocation())	;; sff v1.7.1 - if Player is owner of current cell (and it is a Player home), add it to formlist to improve performance
		;Debug.Notification("Current property owned by Player")
	elseif (playerCell.GetFactionOwner() != PlayerFaction && playerCell.GetActorOwner() != _player.GetActorBase())
		
		bHomeOwned= false
		;Debug.Notification("You are not the owner of this place.")
	endif 
EndFunction 

Bool Property bWeaponDrawPatch auto conditional	;; SFF v1.4.2 - VL tranformation resets WeaponDraw disabler. We need to know if patch enbaled to re-reset it (accessed by 'SFF_VampireLordHandler')

;; SFF v1.4.0 - function for reducing possible conflicts with SWHFA patch
;; Disables Teammates from unsheathing weapons in tandem with Player
Function DrawWeaponManager(int mode= 0)
	if mode == 0
		Game.SetGameSettingFloat("fAIDistanceTeammateDrawWeapon", 0)	;; SFF v1.4.0 - stop "limp arm" bug. Stop 'Draw weapon with Player' beh.
		bWeaponDrawPatch= true
		Debug.Trace("SFF: 'fAIDistanceTeammateDrawWeapon' set to 0.")
	else
		Game.SetGameSettingFloat("fAIDistanceTeammateDrawWeapon", 2000)	;; SFF v1.4.0 - stop "limp arm" bug. Stop 'Draw weapon with Player' beh.
		bWeaponDrawPatch= false
		Debug.Trace("SFF: 'fAIDistanceTeammateDrawWeapon' set to default (2000).")
	endif
EndFunction


;; //////////////////////////////// SLEEP OUTFIT \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Outfit Property SleepOutfit auto
ObjectReference Property SleepOutfitContainer auto
Bool Property bSleepTime auto	;; var set from Alias script ('SFF_SleepOutfit'), which checks for beh. package changes
GlobalVariable Property SFF_MCM_SleepOutfit auto

FormList Property SleepOutfitList auto
LeveledItem Property SleepOutfitLeveledItem auto

Int SleepILsize
Int SleepIndex

;; called from where?
Function OpenSleepWardrobe()

	Debug.Trace("[SFF_O.Sys:003] Sleep Outfit opened.")
	;wardrobeOpened= true
	OpenCustomOutfitCont(SleepOutfitContainer, SleepOutfitList)
EndFunction 

Function SleepOutfitManager()
;; called from 'SFF_SleepOutfit' alias script
;; calls CentralOutfitProcessor based on SleepPackage changes
	if IsHome				;; only mess with outfits if Sleep Outfit MCM enabled, Player in Home cell and Wardrobe is not empty (i.e., Player has given something to use)
		CentralOutfitProcessor()
		Debug.Trace("SFF: Sleep handler called")
	endif
EndFunction

Function CheckSleepTime()
	if IsHome 
		if !bCured && fCurTime() >= 8 && fCurTime() <=16 || bCured && fCurTime() >= 22 && fCurTime() <=6
			;Debug.Notification("Time checked: SLEEP")
			bSleepTime= true
		endif
	endif
EndFunction


;; ////////////////////////////////		 END	 \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

;; //////////////////////////////// HOOD BEHAVIOUR \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
SFF_SunDamageController Property SDC auto
Quest Property CureQuest  Auto  ;; DLC1SeranaCureSelfQuest
bool bStopCureQuestCheck 
bool Property bCured = false auto conditional

Keyword Property ArmorClothing auto ;; ClothingHead (used 'ArmorClothing' to reuse redundant Keyword property)
Keyword Property ArmorHelmet auto 	;; ArmorHelmet
Keyword Property ClothingCirclet auto 	;; ArmorCirclet

GlobalVariable Property SFF_MCM_HoodBeh auto
GlobalVariable Property SFF_SunDamage auto
GlobalVariable Property SFF_MCM_AutoCombatHeadGear auto		;; SFF v1.2.1: Global that keeps track of Combat headgear toggle.
int Property iSunProtecLevel auto conditional	;; set by 'SFF_SunDamageController' Alias script on UpdatableScripts quest

bool property bBlockHood auto conditional		;; used to block autohood code dynamically. Set by 'SFF_CombatHelmetHandler' script.
FormList Property SunDamageExceptionList auto 	;; SFF v1.2.1: fill this via CK. No point pooling declaration OnUpdate.
FormList Property SFF_CombatHoodieList Auto		;; SFF v1.2.1: List that keeps track of Serana's CUSTOM headgear. Used in 'SFF_CombatHelmetHandler'. Used here to make sure combat headgear is unequipped on combat end.
FormList Property SFF_HoodieList auto conditional ;; [SFF v1.2.1] - used by 'SFF_CustomHoodieDetector' function



Armor Property Hoodie auto	;; v1.4.4 - made variable external property, to be accessed by 'sif_outfitmanagement' script (to stop hoodie being unduly added to outfit sets and duplicated)


Bool Function bHoodieAutoEquip()
	if SFF_MCM_HoodBeh.GetValue() == 1
		return true
	else
		return false
	endif
EndFunction 

Bool Function bIsCured()
	if CureQuest.GetStage() < 100
		;Debug.Trace("SFF: Serana not cured yet.")
		bCured= false		;; obsolete. Keep this for backwards compatibility
		return false
	else
		;Debug.Trace("SFF: Serana cured!")
		bCured= true		;; obsolete. Keep this for backwards compatibility
		SFF_PostCureCleanUp()
		return true
	endif
EndFunction 

;; For centralising code related to Cure Quest
Function SFF_PostCureCleanUp()
	
	if bStopCureQuestCheck
	;; if stop check flag is on, halt code, duh!
		return
	endif
	
	RemoveDrainSpell()	;; SFF v1.2.0 - removes Vampiric Drain base spell
	SDC.RevertSpells()	;; SFF v1.2.0 - removes SunDamage spells
	SFF_AutoHoodieDisabler()	;; SFF v.1.2.0 - unequips and removes any traces of auto hoodie from cured Serana 
	Debug.Trace("SFF: Serana cured. Vampire spells and nerfs removed!")
	bStopCureQuestCheck= true
EndFunction


;; v1.6.1 - Custom Outfit Hoodie Conditional
GlobalVariable Property SFF_MCM_CondO_Hoodie_01 auto
GlobalVariable Property SFF_MCM_CondO_Hoodie_02 auto
GlobalVariable Property SFF_MCM_CondO_Hoodie_03 auto
GlobalVariable Property SFF_MCM_CondO_Hoodie_04 auto
GlobalVariable Property SFF_MCM_CondO_Hoodie_05 auto

;; v1.9.0 - Custom Outfit Accessories Conditional
GlobalVariable Property SFF_MCM_CondO_Accessory_01 auto
GlobalVariable Property SFF_MCM_CondO_Accessory_02 auto
GlobalVariable Property SFF_MCM_CondO_Accessory_03 auto
GlobalVariable Property SFF_MCM_CondO_Accessory_04 auto
GlobalVariable Property SFF_MCM_CondO_Accessory_05 auto	
GlobalVariable Property SFF_MCM_CondO_Accessory_Home auto	
GlobalVariable Property SFF_MCM_CondO_Accessory_Sleep auto	

;; v1.8.0 - Organic Hood selector 
GlobalVariable Property SFF_MCM_OrganicHood auto

Bool Function bCustomOutfitTempBlock()
	
	if SFF_MCM_CondO_Hoodie_01.GetValue() == 1 && curOutfitContainer == SFF_MCM.SFF_Outfit01_Container
		if Hoodie != none && rnpcActor.GetItemCount(Hoodie) > 0
			rnpcActor.RemoveItem(Hoodie, rnpcActor.GetItemCount(Hoodie))
			SDC.OutfitProtecChecker()	;; sff v1.8.1: make sure to update outfit Sun Protec. Val. after blocking/removing outfit hoodie
		endif
		RETURN TRUE
		
	elseif SFF_MCM_CondO_Hoodie_02.GetValue() == 1 && curOutfitContainer == SFF_MCM.SFF_Outfit02_Container
		if Hoodie != none && rnpcActor.GetItemCount(Hoodie) > 0
			rnpcActor.RemoveItem(Hoodie, rnpcActor.GetItemCount(Hoodie))
			SDC.OutfitProtecChecker()
		endif
		RETURN TRUE
		
	elseif SFF_MCM_CondO_Hoodie_03.GetValue() == 1 && curOutfitContainer == SFF_MCM.SFF_Outfit03_Container
		if Hoodie != none && rnpcActor.GetItemCount(Hoodie) > 0
			rnpcActor.RemoveItem(Hoodie, rnpcActor.GetItemCount(Hoodie))
			SDC.OutfitProtecChecker()
		endif
		RETURN TRUE
		
	elseif SFF_MCM_CondO_Hoodie_04.GetValue() == 1 && curOutfitContainer == SFF_MCM.SFF_Outfit04_Container
		if Hoodie != none && rnpcActor.GetItemCount(Hoodie) > 0
			rnpcActor.RemoveItem(Hoodie, rnpcActor.GetItemCount(Hoodie))
			SDC.OutfitProtecChecker()
		endif
		RETURN TRUE
		
	elseif SFF_MCM_CondO_Hoodie_05.GetValue() == 1 && curOutfitContainer == SFF_MCM.SFF_Outfit05_Container
		if Hoodie != none && rnpcActor.GetItemCount(Hoodie) > 0
			rnpcActor.RemoveItem(Hoodie, rnpcActor.GetItemCount(Hoodie))
			SDC.OutfitProtecChecker()
		endif
		RETURN TRUE
	endif
	
	RETURN FALSE
EndFunction

;; SFF v1.9.0 - Accessories Blocker
Bool Function bCustomOutfitAccessoryBlock()
	
	if SFF_MCM_CondO_Accessory_01.GetValue() == 1 && curOutfitContainer == SFF_MCM.SFF_Outfit01_Container
		debug.trace("[SFF] [ACCESSORIES]: Accessories blocked for Outfit 01, currently in use.")
		RETURN TRUE
		
	elseif SFF_MCM_CondO_Accessory_02.GetValue() == 1 && curOutfitContainer == SFF_MCM.SFF_Outfit02_Container
		debug.trace("[SFF] [ACCESSORIES]: Accessories blocked for Outfit 02, currently in use.")
		RETURN TRUE
		
	elseif SFF_MCM_CondO_Accessory_03.GetValue() == 1 && curOutfitContainer == SFF_MCM.SFF_Outfit03_Container
		debug.trace("[SFF] [ACCESSORIES]: Accessories blocked for Outfit 03, currently in use.")
		RETURN TRUE	
		
	elseif SFF_MCM_CondO_Accessory_04.GetValue() == 1 && curOutfitContainer == SFF_MCM.SFF_Outfit04_Container
		debug.trace("[SFF] [ACCESSORIES]: Accessories blocked for Outfit 04, currently in use.")
		RETURN TRUE
		
	elseif SFF_MCM_CondO_Accessory_05.GetValue() == 1 && curOutfitContainer == SFF_MCM.SFF_Outfit05_Container
		debug.trace("[SFF] [ACCESSORIES]: Accessories blocked for Outfit 05, currently in use.")
		RETURN TRUE
	;; SFF v2.0.0 - add Accessory Blocker possibility to Home Outfit
	elseif SFF_MCM_CondO_Accessory_Home.GetValue() == 1 && curOutfitContainer == OutfitContainer
		debug.trace("[SFF] [ACCESSORIES]: Accessories blocked for Home Outfit, currently in use.")
		RETURN TRUE
		
	elseif SFF_MCM_CondO_Accessory_Sleep.GetValue() == 1 && curOutfitContainer == SleepOutfitContainer
		debug.trace("[SFF] [ACCESSORIES]: Accessories blocked for Sleep Outfit, currently in use.")
		RETURN TRUE
	endif
	
	debug.trace("[SFF] [ACCESSORIES]: Accessories not blocked for current Outfit ('" + curOutfitContainer.GetBaseObject().GetName() + "').")
	RETURN FALSE
EndFunction

;; To avoid pooling this OnUpdate. 
;; Called from MCM script on AutoHood beh. toggle off 
Function SFF_AutoHoodieDisabler()
	;; call this ONCE from MCM menu when disabling autohood feature... No need to pool updates on this. 
	if Hoodie == none ;;SFF v1.4.1
		Hoodie= MM.Hoodie	
	endif 
	
	DefautHoodieClenser(Hoodie)

	if SFF_SunDamage.GetValue() == 1
		SDC.bHeadCovered= false
		SDC.Convert2Int()
	endif
EndFunction

;; sff v1.8.0 - extracted from 'SFF_AutoHoodieDisabler()'
Function DefautHoodieClenser(Armor hood)
	if hood == none
		return
	endif
	int hoodAmount = rnpcActor.GetItemCount(hood)
	if (hoodAmount > 0)
		rnpcActor.UnequipItem(hood)
		rnpcActor.RemoveItem(hood, hoodAmount)
		debug.trace("SFF: " + hoodAmount + " default hoodies removed from Serana's Inventory.")
	endif
EndFunction

;; sff v1.8.0 
Bool Function bOrganicHoodDetection()
	if SFF_MCM_OrganicHood.GetValue() == 1
		return true
	endif
	
	return false
EndFunction

;; sff v1.8.0 - if no 'master' hood selected, seek a candidate from Inventory
;; and if no Inventory alternative available, revert to default one (sff v1.8.1)
;; called from 'SFF_CombatHelmetHandler', when using Shared Combat Hoodie mode
Bool Function bAvailableInvHood()
	
	if SFF_HoodieList.GetSize() == 1 || !bOrganicHoodDetection() || !bHoodieAutoEquip()
		; Custom Hoodie already set by Player, so use it instead of Inventory hoodie
		; if Organic Hoodie feature DISABLED, no need to execute this (Player does not want to use Inventory hoodies)
		; if Auto Hoodie feature disabled, no need to execute this (Player wants no hoodie, or permanent hoodie)
		return false
	endif
	
	if bCustomOutfitTempBlock()
		;; outfit-specific hoodie block by Player
		return false
	endif
	
	if bOpenedContainer	;; so that hoodie does not update while in Serana trading/outfit menu
		;; if Player managing Serana's Inventory, no need to execute function (especially useful if using unpaused menus while managing/testing outfits). 
		return false
	endif
		
	if curOutfitContainer != none && curOutfitContainer == _CombatOutfit
		debug.trace("SFF: Combat Outfit currently equipped. Abort Organic Hood checking...")
		return false
	endif
	
	if bAddingItems
		debug.trace("SFF: Items being moved to/from Serana's Inventory. Temporarily abort Organic Hood checking...")
		return false
	endif
	
	;;sff v2.0.0
	if bUsingIndoorsOutfit()
		
		return false
	endif
	
	;; REMOVE ANY DEFAULT HOODIES PRESENT IN INVENTORY FIRST!
	Hoodie= none	;; make sure to sanitise hoodie property, just in case something goes awry and we get stuck with a non-intended hood
	DefautHoodieClenser(MM.Hoodie)	;; no need to check for Custom Hoodie: when disabling it, hoodie SHOULD get removed also from Inv.
	;DefautHoodieClenser(Hoodie)
	
	int InventorySize = SFF_SeranaInventoryList.GetSize()
	int iIndex= 0
	
	While iIndex < InventorySize
		Armor entry= SFF_SeranaInventoryList.GetAt(iIndex) as armor
		
		if entry == none	;; to avoid log error spam due to checks against unfilled objects (also avoids setting hoodie as none)
			return false
		endif
		
		;; we now filter entire Inv. list for possible hoodie items available;
		;; if we have a match, set it as our Hoodie and return true (i.e., Inventory Hoodie found) 
		if entry.IsHelmet() || entry.IsClothingHead()  ;|| entry.HasKeyword(ClothingCirclet) && bFormHasString(entry)
			if !bAddingItems
				Hoodie= entry as Armor
				debug.trace("[DEBUG] SFF:: Possible headpiece found in Inventory and set as Hoodie...")
				return true
			else
				debug.trace("SFF: Items being moved to/from Serana's Inventory. Temporarily abort Organic Hood checking...")
				return false
			endif
		endif
		iIndex += 1
	EndWhile

	iIndex= 0			;; we zero index (redundant. when re-running code the property resets itself ['int iIndex=0'])
	debug.trace("[INFO] SFF:: Custom Hoodie empty. No candidate headpiece found in Inventory...")
	
	;; SFF v1.8.1: if we got here, it means that Organic Hoodie is active (which implies no Custom Hoodie available) but no Inventory Hoodie was found...
	;; To avoid Serana being left completely deprived of sun protection, force vanilla hoodie as our main hoodie.
	
	Hoodie= MM.Hoodie	;; sff v1.8.1: make sure a hoodie always available for use (if no hoodie candidate found in Inventory, use default).
	debug.trace("[INFO] SFF:: Default vanilla hoodie set as main hoodie.")	
	
	return false
EndFunction

Function CustomHoodieHandler()
;; Called from dialogue, after opening container menu ('SFF__TIF__070D5272')
;; 'SFF_HoodieContainerScript' goes on HoodieContainer and populates/updates the HoodieList as the Player adds or removes items from it
;; 'SFF_CustomHoodieDetector' keeps track of Serana's inventory. If HoodieList item is removed from her inventory by Player, also removes it from HoodieContainer, which will remove it from HoodieList


	;; [SFF v1.2.1]: improved logic so that not only default hood gets removed, but any prior hoodie defined by Player. 
	if !bHoodieAutoEquip()
		return
	endif

	if bIsCured()
		SFF_MCM_HoodBeh.SetValue(0)
		return
	endif
	
	;; sff v1.8.0 - for making sure code runs ONLY after menu is closed (guaranteeing hoodie list is properly updated before being read)
	if bIsSSREInstalled()
		While (Utility.IsInMenuMode())	;; force code to pause while menu open
			Utility.Wait(0.1)
		EndWhile
	endif
	
	if SFF_HoodieList.GetSize() == 1								;; if CustomHoodie container has 1 single item,

		rnpcActor.UnequipItem(Hoodie)
		int hoodAmount = rnpcActor.GetItemCount(Hoodie)	
		rnpcActor.RemoveItem(Hoodie, hoodAmount)
		Hoodie= SFF_HoodieList.GetAt(0) as Armor					;; set CustomHoodie container content as the hoodie reference to be used.			
		
	else															;; if CustomHoodie container has more or less than 1 item, 
		
		;; sff v1.8.0 - only use 'default' hoodie if Organic Hood feature disabled or no available hoodie candidate in Inventory
		if !bAvailableInvHood()  ;!bOrganicHoodDetection() || !bAvailableInvHood()
			;DEBUG.TRACE("-> -> -> [SFF][DEBUG] N.1")
			Hoodie= MM.Hoodie												;; set hoodie reference as default hoodie.
		endif
	endif
	
	HoodieManager()	
	
EndFunction

Function HoodieManager()
;; [SFF v1.2.1]:
;; - hang code if auto-hood disabled
;; - hang code if in combat
;; - hang code if VL
;; - removed unecessary variable declarations from Update
;; - extracted and externalised cure quest code from Update.

;; [SFF v1.3.1]:
;; - added auto-patch support for Animated Hoodie mod
	debug.trace("==========> 1.HOODIE MANAGER CALLED! <==========")
	UpdateChainer() 	;; daisy-chain this here to use MM's OnUpdate event for necessary code.Must be given highest priority (it may never get called if at bottom of stack) ~ SFF v1.2.1
	
	;bAvailableInvHood()	;; v1.9.0 - simplify our life: instead of looking for all moments along hoodie process where hoodie property should be updated, when using Organic Hoodie, simply do it here, when 'HoodieManager()' is called.
	
	if bIsCured()
		;; if this does not come before AutoHood toggle check,
		;; and auto hood is set to off, we might miss opportunity to remove Vampire Spells from cured Serana ('SFF_PostCureCleanUp' won't get called)
		Debug.Trace("DEBUG] [HoodieManager] SFF: Serana cured. No need to run code. Aborting...")
		return 
	endif
	
	;; sff v1.8.1: code should not run while Serana in combat! Causing issues with Combat Outfit, where combat outfit hoodie will get removed while in combat (which can cause more serious problems, like Serana not properly fighting enemies). 
	if rnpcActor.IsInCombat()
		Debug.Trace("[DEBUG] [HoodieManager] SFF: Serana currently in combat. Aborting code...")
		return
	endif
	
	if bIsVL()
		;; SFF v1.1.0: add VL check to hoodie code
		Debug.Trace("SFF: Serana in VL mode. Abort auto-hoodie code...")
		return
	endif
	
	if bUsingIndoorsOutfit()
		Debug.Trace("[DEBUG] [HoodieManager] SFF: Serana currently using Indoors Outfit. Aborting code...")
		return
	endif
	
	;; sff v2.0.0
	if bAddingItems
		Debug.Trace("[INFO] [HoodieManager] SFF: Outfit Manager processing items. Access to Inventory denied! Aborting code...")
		return		
	endIf

	if bOpenedContainer	;; so that hoodie does not update while in Serana trading/outfit menu
		;; if Player managing Serana's Inventory, no need to execute function (especially usefull if using unpaused menus while managing/testing outfits). 
		Debug.Trace("SFF: Player trading with Serana. Abort auto-hoodie code...")
		return
	endif
	
	if bBlockHood
		Debug.Trace("SFF: Auto-hood blocked by auto combat gear code")
		;; SFF v1.2.0 ~ OnCombatStateChanged event in 'SFF_CombatHelmetHandler' script sometimes fails to catch combat end. Result: combat headgear permance and log spamming. 
		;; If auto-hood blocked but Serana not in combat, safe to assume error and force reset bool...
		if !rnpcActor.IsInCombat()
			Debug.Trace("SFF: Auto-hood blocked, but Serana no longer in combat. Bool not re-set. Resetting now...")
			bBlockHood= false
		else 
			return
		endif
	endif
	
	;; SFF v1.6.0: returned to below 'bBlockHood' check (or else gear will get removed midcomabt); lowered toggle check priority
	;; SFF v1.5.2: higher priority given to make sure combat headgear gets removed even if Serana cured or auto-hoodie disabled!
	;; SFF v1.2.1: to make sure (independent) combat headgear is removed if kept on after combat!
	if SFF_MCM_AutoCombatHeadGear.GetValue() == 2 && rnpcActor.IsEquipped(SFF_CombatHoodieList.GetAt(0) as Armor)
		rnpcActor.UnequipItem(SFF_CombatHoodieList.GetAt(0) as Armor)
		rnpcActor.RemoveItem(SFF_CombatHoodieList.GetAt(0) as Armor)
	endif

	if !bHoodieAutoEquip() || bCustomOutfitTempBlock()
		Debug.Trace("SFF: hoodie auto equip disabled. Skip code...")
		return
	endif

	bool shouldWearHood
	
	if Hoodie == none 
		debug.trace("=======> 2. NO DEFAULT HOODIE SET <=======")
		if !bAvailableInvHood() 
			Hoodie= MM.Hoodie
			;DEBUG.TRACE("-> -> -> [SFF][DEBUG] N.2")
		endif
	else
		debug.trace("=======> 2. HOODIE FOUND: " + Hoodie +"<=======")
	endif 
	
	
	if (rnpcActor.IsInInterior())
		shouldWearHood = false
	else 
		worldspace currentSpace = rnpcActor.GetWorldSpace()
		;UDGP 2.0.2 - Added check to make sure the worldspace is valid.
		if (currentSpace && SunDamageExceptionList.Find(currentSpace as form) < 0)

			if (fCurTime() >= 5 && fCurTime() <= 19)	;; v1.7.1 - checking against 'GameDaysPassed' GlobalVar less taxing than using 'GetCurrentGameTime()'
					shouldWearHood = true
					debug.trace("=======> 3. Should Wear hoodie! <=======")
			else
				shouldWearHood= false		; SFF v1.2.0
				debug.trace("=======> 3. Should not Wear hoodie... <=======")
			endIf					
		else
			shouldWearHood = false
			debug.trace("=======> 3. Should not Wear hoodie... <=======")
		endIf
	endIf


	if !shouldWearHood && rnpcActor.IsEquipped(Hoodie)		
		if bAnimatedHood ;; SFF v1.4.0 - Animated Hoodie patch
			rnpcActor.SheatheWeapon()	;; sff v1.7.2
			DisableHandTorch(true)
			rnpcActor.playIdle(shfwa_hood_takeoff)
			Utility.Wait(0.75)
			;;DisableHandTorch(false)
		endif
			
		rnpcActor.UnequipItem(Hoodie, true)
		debug.trace("=======> 4. Wrong time 4 hoodie! Unequip! <=======")
		
		if !bOrganicHoodDetection() || SFF_HoodieList.GetSize() == 1
			rnpcActor.RemoveItem(Hoodie)
		endif

		if SFF_SunDamage.GetValue() == 1
			SDC.bHeadCovered= false
			SDC.Convert2Int()
		endif
	
	elseif shouldWearHood && !rnpcActor.IsEquipped(Hoodie)	
		if (!rnpcActor.WornHasKeyword(ArmorHelmet) && !rnpcActor.WornHasKeyword(ArmorClothing))
			if bAnimatedHood	;; SFF v1.4.0 - Animated Hoodie patch
				rnpcActor.SheatheWeapon()	;; sff v1.7.2
				DisableHandTorch(true)
				rnpcActor.playIdle(shfwa_hood_wear)
				Utility.Wait(0.75)
				;;DisableHandTorch(false)
			endif
			
			rnpcActor.EquipItem(Hoodie, true, true)
			debug.trace("=======> 4. Time 4 hoodie! Equip! <=======")

			if SFF_SunDamage.GetValue() == 1
				SDC.bHeadCovered= true
				SDC.Convert2Int()
			endif
		else
			debug.trace("=======> 4. Time 4 hoodie, but already equipped! <=======")
			debug.trace("[DEBUG] SFF: Serana should equip hoodie, but head slot already full*")	;; could be a hoodie set externally, from another mod mechanism, so we cannot "correct" it as it might  ot be an actual error.
		endif
	
	else
		;; SFF v1.9.0: if head gear added to Inventory, even if Organic Hoodie on, head gear might not get registered as main hoodie. It will not get unequipped, and will impede use of actual hoodie. IF not using Organic Hoodie, no problem! But if O.H. on, we should recheck actual hoodie item and call HoodieManager again...
		;debug.trace("=======> 4. FAM! IF SHIT GOT HERE, SOMETHING MAY BE WRONG: Inventory Hoodie blocking actual hoodie from being set... <=======")

	endif

EndFunction
;; //////////////////////////////// END \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

;; //////////////////////////////// ELDER SCROLL BEH. \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Ammo Property DLC1ElderScrollBack auto
GlobalVariable Property SFF_MCM_ElderScroll auto

Function EquipElderScroll()
;; Updated and Revised [SFF v1.2.1]

	if !SFF_MCM_ElderScroll.GetValue() == 1
		return
	endif
	
	if rnpcActor.GetItemCount(DLC1ElderScrollBack) < 1
		debug.trace("SFF: Serana has no Elder Scrolls in her Inventory. Halting code and disabling feature...")
		SFF_MCM_ElderScroll.SetValue(0)
		return
	endif
	
	if rnpcActor.IsEquipped(DLC1ElderScrollBack)
		debug.Trace("SFF: Serana already has Elder Scroll equipped. Aborting code...")
		return
	endif
	
	if rnpcActor.GetActorBase().GetOutfit() != EmptyOutfit
		;; if either using default, home or sleep outfit, skip equipping Elder Scroll
		debug.Trace("SFF: Serana not using main outfit. Elder Scroll should not be equipped. Avorting code...")
		return
	endif
	
	if bIsVL()
		debug.trace("SFF: Serana in VL mode. Canna equip elder scroll.")
		return
	endif
	
	rnpcActor.EquipItem(DLC1ElderScrollBack)
EndFunction
;; //////////////////////////////// 	END 	\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

Function UpdateChainer()
	ReInitChecker()
	NightOutfitMonitor()		;; will continually check if Night and Combat Outfit assigned out of time
EndFunction







;; ---------------------------------- UPDATER / RECHECKER ----------------------------------
Function ReInitChecker ()	;; for checking variables and code needed OnInit has been set/run.
	if (!Register4ActionSet)
		RegisterForActorAction(8)
		RegisterForActorAction(10)
	endif
EndFunction

GlobalVariable Property SFF_MCM_Updater auto 
SFF_MCM_Script Property SFF_MCM auto ;; MCM Menu script
Quest Property SFF_Updater auto ;; Updater quest
;Location Property DLC1DBTest auto

Function MMEUpdater()
	AnimatedHoodPatchCecker()
	SFF_Updater.Start()
	SFF_MCM_Updater.SetValue(0)
	;SFF_MCM.bUpdater= false						
	SFF_MCM.ResetFlag()		;; sff v1.4.5 - to remove necessity of conditional properties ('bUpdater') in MCM script ('SFF_MCM_Script')
	FactionsSetter()		;; SFF v1.9.0 - makes sure Serana is added to 'PlayerBedOwnership' faction (better to move this to Update System, instead of re-checking on every save load)
EndFunction

;; SFF v1.9.0 - For making sure Serana is added to 'PlayerBedOwnership' and other factions
;; called internally from 'MMEUpdater()'
Function FactionsSetter()
	if !rnpcActor.IsInFaction(Game.GetFormFromFile(0x000F2073, "Skyrim.esm") as faction)
		rnpcActor.AddToFaction(Game.GetFormFromFile(0x000F2073, "Skyrim.esm") as faction)
		debug.trace("[DEBUG] [INFO] SFF: Serana added to 'PlayerBedOwnership' faction.")
	endif
EndFunction
;; ---------------------------------- END ----------------------------------

Function OnUpdate()
	Bugfixes()
EndFunction

Function Bugfixes()
	;; SFF v1.2.0 ~ makes sure code is only called if Serana following Player;
	;; SFF v1.2.1 - changed check to PlayerTeammate - Serana may be "dismissed" from teammate faction, but still be "following" (IsFollowing/Dismissed not changed) 
		;; application of "Guard Clauses Technique": avoid complex/unecessary nesting of clauses, kill code as early as possible
	;; SFF v1.4.0 - make sure no 'returns' are called inside OnUpdate itself
	
	if !SFF_MCM_Bugfix_Sneak.GetValue() == 1 && !SFF_MCM_Bugfix_Combat.GetValue() == 1		;; if BOTH MCM bugfix options off, kill code exec.,
		Debug.Trace("[SFF_bugfixes]: both MCM bugfix toggles off. Aborting code...")
		UnregisterForUpdate()																;; unregister loop.
		return
	endif
	
	if !rnpcActor.IsPlayerTeammate()	;; if Serana not in Teammate fac., kill code exec.,
		Debug.Trace("[SFF_bugfixes]: Serana not currently in Teammate faction. Aborting code, registering for new check in 15.0s...")
		RegisterForSingleUpdate(15.0)	;; re-check again to see if Serana still not in faction (to make sure code does not die permanently, being able to run again when added to fac.)
		return
	endif
	
	if bIsVL()
		Debug.Trace("[SFF_bugfixes]: Serana currently in VL form. Aborting code, checking again in 15.0s...")
		RegisterForSingleUpdate(15.0)
		return
	endif
	
	SneakingBug()						;; if code still running here, call bugfixes functions
	CombatBug()
	RegisterForSingleUpdate(4.0)		;; and re-register loop. 
EndFunction

;; //////////////////////////////// BUGFIXES \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
GlobalVariable Property SFF_MCM_Bugfix_Sneak auto
GlobalVariable Property SFF_MCM_Bugfix_Combat auto
GlobalVariable Property SFF_MCM_Bugfix_Unsheath auto
GlobalVariable Property SFF_MCM_Bugfix_SemiSneak auto

;; sff v1.6.0 ~added 'Is3dLoaded()' check to avoid log spamming
Function SneakingBug ()
	if (SFF_MCM_Bugfix_Sneak.GetValue() == 1)
		;Debug.Notification("Bugfix ENABLED")
		if (rnpcActor.Is3dLoaded() && rnpcActor.GetAnimationVariableInt("iState") ==2)	;; spits error in Log. Revise code (consider checking not against int, but bool of crouch anim itself
			if (!_player.IsSneaking())
				Debug.Trace("[SFF_bugfixes]: Serana sneaking, but Player not. Serana probably stuck!")
				rnpcActor.GetCombatState()
				if (rnpcActor.GetCombatState() != 1)
					Debug.Trace("[SFF_bugfixes]: Serana sneaking, Player not. Serana in combat mode. Definitely stuck!")
					RefreshActor(0)
				endif
			else
				;Debug.Trace("[SFF_bugfixes]: Serana probably not stuck. Player also sneaking.")
			endif
		else
			;;Debug.Notification("NOT Sneaking")
		endif
	endif
	RegisterForSingleUpdate(4.0)	;; call Update once every x seconds. Used to jumpstart update from MCM menu
EndFunction

;; sff v1.6.0 ~added 'Is3dLoaded()' check to avoid log spamming
Function CombatBug () ;; (SIF v1.4.1)
	if (SFF_MCM_Bugfix_Combat.GetValue() == 1)
		rnpcActor.GetCombatState() 																				;; called to avoid bug with function
		if (rnpcActor.GetCombatState() == 1 && rnpcActor.Is3dLoaded() && rnpcActor.GetAnimationVariableBool("iState_NPCMagicCasting"))	;; if Serana in combat state and playing dualcasting anim.,
			;Debug.Trace("[SFF_bugfixes]: Serana in combat and playing casting anim.")
			Actor TargetRef = rnpcActor.GetCombatTarget()														;; grab aggression target.
			if (rnpcActor.GetAnimationVariableFloat("Speed") <= 0 && TargetRef == none)							;; if Serana standing or STUCK AND has no valid target for aggression,
				Debug.Trace("[SFF_bugfixes]: Serana not moving and has no enemy targets in sight. Most likely stuck...")
				RefreshActor(1)
			endif
		endif
	endif
	RegisterForSingleUpdate(4.0)	;; call Update once every x seconds
EndFunction

;; SFF v1.3.1: rare bug where Serana will have her weapon equipped/unsheathed independently of Player draw state
Function UnsheathAnimBug(float time)
	Utility.Wait(time)
		
	if SFF_MCM_Bugfix_Unsheath.GetValue() != 1
		;; to stop code if bugfix disabled by Player
		return
	endif
	
	if !rnpcActor.IsPlayerTeammate()
		;; to stop code if Serana not following Player
		return
	endif
	
	if rnpcActor.GetAnimationVariableInt("iRightHandEquipped") == 0
		;; to stop code if Serana has no item equipped in her right hand
		return
	endif
	
	rnpcActor.GetCombatState()
	if rnpcActor.GetCombatState() != 0
		;; to stop refreshing Serana if Player unsheathing while in combat
		return
	endif

	RefreshActor()
EndFunction

;; SFF v1.5.0
;; called externally from 'SFF_NPCMovementMonitor' script
Function SemiSneakBug()
;; Serana will be stuck in "hunched" pose, not exactly sneaking, but not in full erect pose either. She will not follow Player around. 
;; In all detected cases she was using torch (due to time? it may be possible for her to become stuck during daytime also...).
;; Testing reveals she is not in sneak mode; not playing sneak anim; not in combat
;; Her 'AnimSpeed' is always greater than 0 (so, considered as moving)
;; She's never in sneak mode, even if Player is crouching
;; Entering combat or bashing her with weapon resets freeze
	
	if SFF_MCM_Bugfix_SemiSneak.GetValue() != 1
		return
	endif

	if !_player.IsSneaking() || rnpcActor.IsSneaking() || _player.GetAnimationVariableFloat("Speed") <= 0
		return
	endif
	
	Debug.Trace("[SFF_bugfixes]: Player sneaking and moving, but Serana not. Most likely stuck ('hunched' or semi-senak pose. Refreshing Serana...")
	
	RefreshActor(0)
EndFunction



;; SFF v1.6.0 - 'SFF_PlayerLocationTracker' completely unreliable. As of v1.6.0, does not fire at all. Internalise function...
FormList Property SFF_fList_teleportWhitelist auto 

BOOL FUNCTION bWhitelistedLoc()
	if SFF_fList_teleportWhitelist.HasForm(_player.GetCurrentLocation() as FORM)
		debug.trace("[INFO] SFF:: Player in a whitelisted loc. Cannot teleport Serana.")
		RETURN TRUE
	endif
	debug.trace("[INFO] SFF:: Player NOT in a whitelisted loc. Allow teleportation.")
	RETURN FALSE
ENDFUNCTION

;;SFF v1.5.0: for dealing with recurrent issue of Serana not teleporting with Player when entering/exiting Home-tagged cells
;; BASIC LOGIC: check Serana follow status, check if 3D loaded (i.e., is she in cell), check combat status
;; if conditions met, teleport her to us
GlobalVariable Property SFF_MCM_ForceTeleport auto

FUNCTION ForcedTeleportation()

	if !SFF_MCM_ForceTeleport.GetValue() == 1
		return;
	endif
	
	if bBlockTeleport || bWhitelistedLoc()
		return
	endif
	
	if !MM.IsFollowing || MM.IsWaiting || MM.SimpleFollow
	;; if Serana either NOT following, OR following but waiting, OR in 'simple follow' mode
		return
	endif
	
	if rnpcActor.IsInCombat()
		return
	endif
	
	if rnpcActor.IsOnMount() || _player.IsOnMount()
		return
	endif
	
	utility.wait(0.2)	;; hang a bit to make sure Serana will not teleport to us normally 
	; if rnpcActor.Is3dLoaded()
	; Serana already in cell, so no need to run code
		; return
	; endif
	
	Actor[] loadedActors= ScanCellNPCs(_player, 300)
	
	int iArraySize= loadedActors.Length
	int indx = 0
	
	while indx < iArraySize
		if loadedActors[indx] != rnpcActor
			indx += 1
			
		else
			Debug.trace("Serana found. Stop search...")
			return
		endif
	endwhile
	
	if indx == iArraySize
		;; if we parsed through all actors in array,
		;; and none of them is Serana,
		;; move her to us!
			rnpcActor.MoveTo(_player)
			Debug.Notification("Serana moved to Player.")
			Debug.Trace("SFF: Serana moved to Player.")
	endif
ENDFUNCTION

Function RefreshActor (int mode= 0)
	if mode == 0
		rnpcActor.Disable(true)
		rnpcActor.Enable()	;; fading out gives more natural effect, with no noticeable cutoff ~ sff v1.6.2
	else
		rnpcActor.StopCombat()
	endif
	Debug.Notification("Serana refreshed.")
EndFunction

;; SFF v1.9.0 - for reseting offset that becomes stuck while using Companion Mode.
;; called externally from 'SFF_SDEInitialiser' script, run everytime save loads.
Function ClearOffsets()
	if rnpcActor.IsInCombat()		;; best not to meddle while Serana in combat
		return
	endif
	
	if !MM.IsFollowing				;; not following? no need to waste resources...
		return
	endif
	
	if !MM.FollowDistanceBeside		;; not Companion Mode? abort...
		return
	endif
	
	if MM.IsWaiting					;; waiting? abort...	
		return
	endif
	
	if MM.SimpleFollow				;; simple follow
		return
	endif
	
	rnpcActor.KeepOffsetFromActor(Game.GetPlayer(), 0.0, 0.0, -20.0)
	rnpcActor.ClearKeepOffsetFromActor()	
	Debug.Trace("[DEBUG] SFF: Offsets cleared. Serana should not be stuck to Player's side any longer.")
EndFunction

;; //////////////////////////////// END \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

;; //////////////////////////////// TELEPORTATION \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
GlobalVariable Property SFF_MCM_Teleport auto	;; teleportation enabler 
Bool canTeleport = true
Bool Property bBlockTeleport auto conditional 	;; set by a Player Alias script that detects if Player in Apocrypha or not
;; SFF v1.2.0 ~ also set by 'SFF_QuestsMonitor' alias script, which detects when certain lonewolf quests have started or not

;; sff v1.6.0 ~ code readability
Event OnActorAction(int actionType, Actor akActor, Form source, int slot)
	if (akActor == _player && actionType == 8)
		if SFF_MCM_Teleport.GetValue() != 1 
			RETURN
		endif
		
		if bBlockTeleport || bWhitelistedLoc()
			debug.trace("[INFO] SFF:: Player in whitelisted loc. Cannot teleport Serana...")
			RETURN
		endif
		
		if _player.GetDistance(rnpcActor) > 3000 && canTeleport
			canTeleport= false
			if (MM.IsFollowing && MM.IsWaiting != true)
				rnpcActor.GetCombatState() ;; to avoid bug with function
				if (rnpcActor.GetCombatState() != 1) ;; 1, "in combat". 2, "searching"; So, avoid calling while Serana in combat;
					rnpcActor.MoveTo(_player, -500.0 * Math.Sin(_player.GetAngleZ()), -500.0 * Math.Cos(_player.GetAngleZ()), _player.GetHeight() + 1.0)
					Debug.Trace("[INFO] SFF:: Serana teleported to Player.")
				endif
			endif
		endif
		
	elseif(akActor == _player && actionType == 10)
		canTeleport= true
		UnsheathAnimBug(1.25)
	endif
EndEvent
;; //////////////////////////////// END \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

Spell Property DLC1SeranaDrain02 auto
Function RemoveDrainSpell()
	if rnpcActor.HasSpell(DLC1SeranaDrain02)
		RemoveBaseSpell(rnpcActor, DLC1SeranaDrain02)
		Debug.Trace("SFF: Base drain spell removed from Serana")
	endif
EndFunction

;; ---------------------------------- SYNERGY MECH. ----------------------------------
;SDECustomMentalModel Property SDE auto
;Float skillbarMeter
Float Property fMeterBackUp auto Conditional
Float Property fAffectionMeterBackUp auto Conditional
Float Property fDifficultyBackUp auto Conditional

;; //////////////////////////////// VAMPIRE LORD \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Armor Property VLSeranaArmor Auto
Armor Property VLSeranaArmorRoyal Auto
Armor Property DLC1VampireLordCape Auto	;; SFF v1.2.0

;GlobalVariable Property SFF_VLSeranaLevelGlobal Auto			;; keeps track of Serana's level
GlobalVariable Property SFF_MCM_VLSeranaRoyalArmorGlobal Auto
GlobalVariable Property SFF_MCM_VLSeranaCloakGlobal Auto	;; SFF v1.2.0

Race Property NormalSeranaRace Auto
;; these variables are called and set by VL system external scripts
Bool Property bBusyTransforming Auto
Bool Property bElderScrollEquipped Auto
Bool Property bShouldBleedout Auto

Race Property DLC1VampireBeastRace auto conditional		;; vampire lord race 
Spell Property LeveledDrainSpell Auto conditional		;; spell that should be used when in VL form

Spell Property RaiseZombieSpell auto

Bool Function bIsVL()
	if rnpcActor.GetRace() == DLC1VampireBeastRace
		return(true)
	else
		return(false)
	endif
EndFunction

;; called externally from ...
Function SpellManager(int mode)
	RaiseZombieSpell= Game.GetFormFromFile(0x02011F35, "Dawnguard.esm") As Spell
	
	if mode==0		;; for VL transformation
		RemoveBaseSpell(rnpcActor, RaiseZombieSpell)
		
		if !rnpcActor.HasSpell(LeveledDrainSpell)
			rnpcActor.AddSpell(LeveledDrainSpell)
			;utility.wait(0.3)
			rnpcActor.EquipSpell(LeveledDrainSpell, 1)
			Debug.Trace("SFF: VL Drain spell added & equipped")
		else
			rnpcActor.EquipSpell(LeveledDrainSpell, 1)
			Debug.Trace("SFF: VL Drain spell equipped")
		endif
		
	elseif mode==1	;; for turning human
		if rnpcActor.HasSpell(LeveledDrainSpell)
			if rnpcActor.GetEquippedSpell(1) == LeveledDrainSpell
				rnpcActor.UnequipSpell(LeveledDrainSpell, 1)
			endif
			rnpcActor.RemoveSpell(LeveledDrainSpell)
			Debug.Trace("SFF: VL Drain spell removed")
		endif
		if !rnpcActor.HasSpell(RaiseZombieSpell)	;; sff v1.6.0 - to avoid log error spams
			AddBaseSpell(rnpcActor, RaiseZombieSpell)
		endif
	endif
EndFunction


Armor Function GetVLSeranaArmor()
	If(SFF_MCM_VLSeranaRoyalArmorGlobal.GetValue() == 1)
		Return VLSeranaArmorRoyal
	Else
		Return VLSeranaArmor
	EndIf
EndFunction

Armor Function GetVLSeranaCloak()	;; SFF v1.2.0
	If(SFF_MCM_VLSeranaCloakGlobal.GetValue() == 1)
		Return DLC1VampireLordCape
	Else
		Return none
	EndIf
EndFunction

;; ---------------------- HORSE CODE -----------------------
Bool Property bUsingArvak Auto Conditional 	;; for telling other scripts Serana is using Arvak as mount. Set by dialogue ('SFF__TIF__0419A9CF')
ObjectReference Property DLC01SoulCairnHorseSummon Auto
ObjectReference Property Arvak_XMarker auto	;; maker of where to return Arvak to (in DLC1dbTest cell)
ObjectReference property currentMount auto conditional ;; SFF v1.2.0 - for storing what horse Serana's currently using; set by dialogue scripts in 'SFF_HorseMountController' script; called from 'SFF_HorseControllerScript'. 

Spell Property DLC01SummonSoulHorse auto

ReferenceAlias Property myHorseAlias auto

Race HorseRace	;; to enable PC dialogue

Function ResetOwnership (ReferenceAlias[] myList) ;, ReferenceAlias myHorse)
	{Func. called from dialogue fragment scripts to return mount ownership to Player when swapping Serana's horse}
	Debug.Trace("SFF_MountSys.: Horse ownership resetter called")
	
	;; forces current mount onto a centralised alias, to facilitate beh. package management and avoid redundancy
	if currentMount != none
		myHorseAlias.ForceRefTo(currentMount)
		Debug.Trace("SFF_MountSys.: Current Mount alias filled successfully")
		Debug.Trace("SFF_MountSys.: Current Mount alias: " + myHorseAlias.GetReference().GetDisplayName())
		;RaceBlockHandler()
	else	
		myHorseAlias.Clear()
		;RaceBlockHandler(false)
		Debug.Trace("SFF_MountSys.: No mount detected. Alias cleared...")
	endif
	
	int size= myList.Length
	int i = 0
	while i < size
		if (myList[i].GetReference()).GetActorOwner() == rnpcActor.GetActorBase()
			(myList[i].GetReference()).SetActorOwner(_player.GetActorBase())
		else
			Debug.Trace(myList[i] + " not owned by Serana")
		endif
		i += 1
	endwhile
	
	if bUsingArvak
		DisableArvak()			;; move Arvak back to Oblivion
		ArvakSpellManager(1)	;; return Summon Arvak spell to Player
		bUsingArvak= false 		;; set Arvak as not in use
	endif
EndFunction

Function HorseAliasRefill()
;; called from external script ('')
;; used when updating mod to refill cur horse alias
	if currentMount != none
		myHorseAlias.ForceRefTo(currentMount)
	endIf
EndFunction

Function DisableArvak()
;; called externally from 'ssf_ArvakDisabler' RefAlias script to remove Arvak after Serana dismounts
	if bUsingArvak
		;if !Serana.GetAnimationVariableBool("bIsRiding")
			DLC01SoulCairnHorseSummon.PlaceAtMe(Game.GetForm(0x0007CD55))
			DLC01SoulCairnHorseSummon.MoveTo(Arvak_XMarker)
		;endif
	endif 
EndFunction

Function SummonArvak(ReferenceAlias[] myList) ;, ReferenceAlias myHorse)
	{Called from 'SFF__TIF__0419A9CF' dialogue fragment script}
	Debug.Trace("SFF_MountSys.: Arvak ownership setter called")

	currentMount= DLC01SoulCairnHorseSummon	;; set current mount

	ResetOwnership(myList)					;; remove all other horses from Serana's ownership
	bUsingArvak= true						;; set bool for summoning Arvak ('SFF_SeranaHorseInstantiator')
	ArvakSpellManager(0)
	if !bHasGivenHorse
		CallSDESetter (1) ;; 0- 'likes'; 1- 'loves'
		bHasGivenHorse= true
	endif
EndFunction

Function ArvakSpellManager(int mode)
;; removes Arvak spell from the Player
	;spell sArvakSpell= Game.GetForm(0x0200C600)
	if mode == 0
		if _player.HasSpell(DLC01SummonSoulHorse)
			_player.RemoveSpell(DLC01SummonSoulHorse)
		endif
	elseif mode == 1
		_player.AddSpell(DLC01SummonSoulHorse)
	endif
EndFunction

;; sff v1.6.0 - code for enabling Player to add current WorldSpace as rideable
;; both funcs. called from MCM.
Function AddWorldSpace2List(WorldSpace wsp)
	if wsp != none
		RidableWorldSpaces.AddForm(wsp)
		debug.trace("[INFO] SFF:: " + wsp + " added as a ridable worldspace.")
		debug.notification(wsp.GetName() + " added as a ridable worldspace.")
	else
		debug.trace("[ERROR] SFF:: Worldspace passed NULL!")
	endif
EndFunction

Function RemoveWorldSpaceFromList(WorldSpace wsp)
	if wsp != none
		RidableWorldSpaces.RemoveAddedForm(wsp)
		debug.trace("[WARNING] SFF:: " + wsp + " removed as ridable worldspace")
		debug.trace(wsp.GetName() + " removed as ridable worldspace.")
	else
		debug.trace("[ERROR] SFF:: Worldspace passed NULL!")
	endif
EndFunction
