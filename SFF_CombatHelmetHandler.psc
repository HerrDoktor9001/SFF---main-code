Scriptname SFF_CombatHelmetHandler extends ReferenceAlias  
;; manages Combat Headgear mechanism;
;; manages Combat Outfit mechanism (sff v1.8.1);

SFF_MentalModelExtender Property MME auto
DLC1_NPCMentalModelScript Property MM auto  ;; Serana AI (MentalModel)
GlobalVariable Property SFF_MCM_AutoCombatHeadGear auto		;; 
GlobalVariable Property SFF_MCM_HoodBeh auto	;; auto hood behaviour selector ;; v1.4.4
Actor Serana
Armor HeadGear
Armor CustomHeadGear
Race DLC1VampireBeastRace				;; vampire lord race 
FormList Property CustomHeadgearList Auto

Bool Function bIsVL()
	if Serana.GetRace() == DLC1VampireBeastRace
		return(true)
	else
		return(false)
	endif
EndFunction

Event OnInit()
	Serana= Self.GetActorReference() 
EndEvent 

Event OnCombatStateChanged(Actor akTarget, int aeCombatState)


	if SFF_MCM_AutoCombatHeadGear.GetValue() == 1 || MME._CombatOutfit != none ;; v1.8.1: necessary to make sure Combat Outfit code runs even if Combat Headgear feature is disabled
	;; equip auto-hoodie
		
		if aeCombatState == 1
			;Debug.Notification("Serana entered combat!")
			if !bIsVL()
				
				;; SFF v1.8.1: Combat Outfit implementation code
				if MME._CombatOutfit != none 
					CombatOutfitEquipper()
				elseif MME._CombatOutfit == none
				
					GearEquipper()	;; if Combat Outfit enabled, no need to manage headgear: complexifies mechanism, amplifies chance of errors, when headgear should already be included in Combat Outfit itself by Player, given its ad hoc nature. 
				endif
			endif

		elseif aeCombatState == 0
			MME.bBlockHood= false
			
			if MME._CombatOutfit == none
				GearRemover()
			
			else
				;; SFF v1.8.1: Combat Outfit implementation code
				;CombatOutfitRemover() 
				;; No need to do anything. 'ConditionalOutfitManager()' is called automatically in an Update cycle in MME.
			endif
		endIf
	
	elseif SFF_MCM_AutoCombatHeadGear.GetValue() == 2
	;; equip specific headgear
	
		if aeCombatState == 1
			if !bIsVL()
				if MME._CombatOutfit == none
					GearEquipperCustom()
				else
					CombatOutfitEquipper()	;; sff v1.8.1: Combat Outfit implementation. If using C.O, no need to check for headgear.
				endif
			endif		
		
		elseif aeCombatState == 0
			MME.bBlockHood= false
			
			if MME._CombatOutfit == none
				GearRemoverCustom()
			else
				;CombatOutfitRemover()		;; sff v1.8.1: Combat Outfit implementation. If using C.O, no need to check for headgear.
				;; No need to do anything. 'ConditionalOutfitManager()' is called automatically in an Update cycle in MME.
			endif
		endif
	
	elseif SFF_MCM_AutoCombatHeadGear.GetValue() == 0
		if (aeCombatState == 1)
			Debug.Trace("SFF: Combat started but 'Auto combat headgear' not enabled.")
		endif
	endif
	
	;; if Combat Outfit exists, it'll eventually get equipped, and 'sif_outfitmanagement' script will auto-forceequip items
	; if !MME.rnpcActor.IsPlayerTeammate() &&  MME._CombatOutfit == none && !MME.bForceEquipped
		; Debug.Trace("SFF: Combat started but SERANA NOT a follower. Force-equip outfit...")
		; MME.ForceEquipIntegral()
	; endif
endEvent

;; SFF v1.8.1: Combat Outfit implementation code
Function CombatOutfitEquipper()
	; if MME.bUsingIndoorsOutfit()
		
		; DEBUG.TRACE("[DEBUG] [COMBAT Outfit] SFF: Serana in combat but using Indoors Outfit. Aborting...")
		; return
	; endif
	
	if MME.curOutfitContainer != MME._CombatOutfit	;; no need to call change if already using Combat Outfit
		if Serana.IsInCombat()						;; make sure Serana ACTUALLY in combat (i.e., not false positive). 
			;MME.ReturnOutfit2Container(MME._CombatOutfit, MME.SFF_fList_CombatOutfit)
			Debug.Trace("[DEBUG] SFF: Combat started, Combat Outfit requested.")
			MME.ConditionalOutfitController()	;; sff v2.0.0 - simply call COC; if conditions met for equipping Combat Outfit, it'll be...
		endif	
	endif
EndFunction

Function GearEquipper()
	;; sff v1.8.1: do not equip headgear if using Inddors Outfit. Why? For sake of consistence (Combat Outfit also not used under same circumstances).
	if MME.bUsingIndoorsOutfit()
		
		DEBUG.TRACE("[DEBUG] [COMBAT Hoodie] SFF: Serana in combat but using Indoors Outfit. Aborting...")
		return
	endif
	;HeadGear= MME.SFF_HoodieList.GetAt(0) as Armor
	;; sff v1.8.0 - to make sure Serana ALWAYS equipped updated hoodie
	; if MME.bOrganicHoodDetection() && MME.SFF_HoodieList.GetSize() != 1
		; MME.bAvailableInvHood()
		; utility.wait(0.15)
	; endif
	
	HeadGear= MME.Hoodie		;; sff v1.8.0 - with Organic Hood featue, checking against HoodieList not practical (as a hoodie may now be extracted from Inventory itself, instead of set by Player)
	
	if HeadGear != none ;&& HeadGear != MM.Hoodie		;; if hoodie list not empty and not default hoodie,
		if !Serana.IsEquipped(HeadGear)					;; if Serana not wearing list item already,
			MME.bBlockHood= true						;; block auto-hood code from running,
			CheckEquipped()
			Serana.EquipItem(HeadGear, true, true)			;; force-equip hoodie list item.
			Debug.Trace("SFF: Combat started. Combat Headgear equipped.")
		endif
	endif
EndFunction

Function GearRemover()
	if HeadGear != none && Serana.IsEquipped(HeadGear) ;&& !MME.shouldWearHood	;; if list item already equipped,
		
		;; SFF v1.7.1 - no need to unequip/remove headgear after combat if shared with auto-hoodie!
		;; if during daytime, hoodie should be kept on;
		;; if during nightime, hoodie should come off, but will be detected and done by 'HoodieManager()', in MME!
		;Serana.UnequipItem(HeadGear)					;; SFF v1.2.1: to avoid game hanging every time headgear removed after combat.
		;Serana.RemoveItem(HeadGear)					;; remove item; else, just leave it.
		
		if SFF_MCM_HoodBeh.GetValue() !=0	;; v1.4.4 - to make sure Serana refreshes Inventory even if auto-hoodie disabled (or else original headgear will not be equipped!)			
			MME.bBlockHood= false								;; unblock auto hood equip code
			MME.HoodieManager()									;; and call it (to re-equip hood if necessary).
		else	;; SFF v1.7.1 - this code might be obsolete! Seems only run to counter Unequip call above, which has been suppressed....
			;MME.TriggerObj(0.05)
			if HeadGear != none && HeadGear != MM.Hoodie		;; if hoodie list not empty and not default hoodie,
				if Serana.IsEquipped(HeadGear)					;; if Serana wearing hoodie,
					Serana.UnequipItem(HeadGear)				;; unequip;				
					Serana.RemoveItem(HeadGear)					;; remove;			
																;; and refresh!
					Serana.AddItem(Game.GetFormFromFile(0x0000000F, "Skyrim.esm") as MiscObject, 1, true)
					Utility.Wait(0.1)
					Serana.RemoveItem(Game.GetFormFromFile(0x0000000F, "Skyrim.esm") as MiscObject, 1, true)	;; SFF v1.7.1 - prior versions forgot to remove misc obj. from Inventory! Although this should realistically never get called, code needed to be complete!
				endif
			endif
			
		endif
		Debug.Trace("SFF: Combat finished. Combat Headgear removed.")
	endif
EndFunction

Function GearEquipperCustom()
	;; sff v1.8.1: do not equip headgear if using Indoors Outfit. Why? For sake of consistence (Combat Outfit also not used under same circumstances).
	if MME.bUsingIndoorsOutfit()
		
		DEBUG.TRACE("[DEBUG] [COMBAT Hoodie] SFF: Serana in combat but using Indoors Outfit. Aborting...")
		return
	endif
	
	CustomHeadGear= CustomHeadgearList.GetAt(0) as Armor
	if CustomHeadGear != none 
		if !Serana.IsEquipped(CustomHeadGear)
			MME.bBlockHood= true
			CheckEquipped()
			Serana.EquipItem(CustomHeadGear, true, true)
			Debug.Trace("SFF: Combat started. Custom combat Headgear equipped.")
		endif
	endif
EndFunction

Function GearRemoverCustom()
	if Serana.IsEquipped(CustomHeadGear)
		Serana.UnequipItem(CustomHeadGear)	;; SFF v1.2.1: to avoid game hanging every time headgear removed after combat.
		Serana.RemoveItem(CustomHeadGear)
		Debug.Trace("SFF: Combat finished. Custom combat Headgear removed.")
		
		if SFF_MCM_HoodBeh.GetValue() !=0	;; v1.4.4 - to make sure Serana refreshes Inventory even if auto-hoodie disabled (or else original headgear will not be equipped!)
			MME.bBlockHood= false
			MME.HoodieManager()
			
		else
			;MME.TriggerObj(0.0)
			;Serana.AddItem(Game.GetFormFromFile(0x0000000F, "Skyrim.esm") as MiscObject, 1, true)
			if curHead != none && !Serana.IsEquipped(curHead) && Serana.GetItemCount(curHead) > 0 
				Serana.EquipItem(curHead)
			endif
			
			if curHair != none && !Serana.IsEquipped(curHair) && Serana.GetItemCount(curHair) > 0
				Serana.EquipItem(curHair)
			endif
			
			if curCirclet != none && !Serana.IsEquipped(curCirclet) && Serana.GetItemCount(curCirclet) > 0
				Serana.EquipItem(curCirclet)
			endif
			Debug.Trace("SFF: Combat finished. Original headgear re-equipped.")
		endif
		
	endif
	resetHeadEquipProp()	;; resets the stored current Invenory headgear items, to make sure it is up-to-date 
EndFunction

;; SFF v1.4.4 - store current headgear in use, re-equip it later
Armor curHead
Armor curHair
Armor curCirclet

Function CheckEquipped()
	
	;; stores all current head equipment in use
	curHead= Serana.GetWornForm(0x00000001) as Armor
	curHair= Serana.GetWornForm(0x00000002) as Armor
	curCirclet= Serana.GetWornForm(0x00001000) as Armor
	
	;; check only one slot: calling unequipItem multiple times causes stutters
	if curHead != none 
		Serana.UnequipItem(curHead)
		Debug.Trace("SFF: Combat started. Head slot emptied.")
	elseif curHair != none
		Serana.UnequipItem(curHair)
		Debug.Trace("SFF: Combat started. Hair slot emptied.")
	elseif curCirclet != none
		Serana.UnequipItem(curCirclet)
		Debug.Trace("SFF: Combat started. Circlet slot emptied.")
	endif
EndFunction

Function resetHeadEquipProp()
	curHead= none
	curHair= none
	curCirclet= none
EndFunction