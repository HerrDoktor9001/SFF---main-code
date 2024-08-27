Scriptname SFF_IndoorsOutfitMonitor extends ReferenceAlias

;; as we have ditched the parallel Outfit System mechanims (i.e., we no longer use baked outfits, opting for moving/adding/removing items directly to and fro Serana's Inventory), Indoors Outfit behaviour became problematic:
;; - if items are moved from their container to Inventory, we cannot keep track of the Outfit's content in real-time (every time Outfit in use, size would return 0)
;; - in the case of other Outfits, we simply check if the Outfit Container for it is currently in use, and if so check the size against the Inventory; if Outfit NOT in use, size can be checked directly in Container
;; - that solution is not viable in case of Indoors Outfit: both Home and Sleep Outfits auto-disable if empty! 

;; SOLUTION 1: we emulate the outfit list, keeping track of items added or removed to Outfit Container BY PLAYER ONLY! So even if Container emptied BY THE GAME, it would still count as filled;

;; HOWEVER, that does not solve problem of PLAYER-INDUCED modifications! If Outfit emptied BY PLAYER, it would auto-disable - BUT ONLY IF DONE VIA OUTFIT CONTAINER! If items removed from INVENTORY directly, the emulated system would never know Outfit has been emptied out surreptitiously  
;; THUS, we need to make sure changes are mirrored in both containers: Outfit Container and Inventory.

;; SOLUTION: 
;; if USING INDOORS OUTFIT, we know that 1) they are not empty; 2) their content will not be in their Container, but in Inventory.
;; thus, for every ARMOUR item REMOVED from Inventory by Player while using Indoors Outfit, we can subtract it from our tracking properties ('iOutfitHome_Items', 'iOutfitSleep_Items' in 'SFF_MentalModelExtender' script)
;; equally, every ARMOUR item ADDED to Inventory should be reflected in said tracking properties.

;; NOTE: we MUST, however, account for Armour items NOT added by Player but which can be accessed by the Player (e.g., Accessory items).  



FormList Property SFF_Perma_HomeOutfitList auto
FormList Property SFF_Perma_SleepOutfitList auto
SFF_MentalModelExtender Property MME auto
ObjectReference Property playerRef auto 

Event OnItemRemoved (Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
	;; If Player the one removing items from Inventory
	if akDestContainer == playerRef
		;debug.trace("0000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000")
		if GetReference().GetItemCount(akBaseItem) == 0 ;; Form lists don't keep track of QUANTITY. If there is 02 of the same item and you remove 01, without this check it would immediately erase the item from the list
			;debug.trace("1111111111111111111111111111111111111111111_11111111111111111111111111111111111111111111111111")
			if MME.curOutfitContainer == MME.OutfitContainer
				SFF_Perma_HomeOutfitList.RemoveAddedForm(akBaseItem)
				debug.trace("SFF: [INFO] Player REMOVED an item from Home Outfit via Inventory.")
					
			elseif MME.curOutfitContainer == MME.SleepOutfitContainer
				SFF_Perma_SleepOutfitList.RemoveAddedForm(akBaseItem)
				debug.trace("SFF: [INFO] Player REMOVED an item from Sleep Outfit via Inventory.")
			endif
		
		ELSE
			;debug.trace("3333333333333333333333333333333333333333333_33333333333333333333333333333333333333333333333333")
		
		endif
	endif
EndEvent

Event OnItemAdded (Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	
	if akSourceContainer == playerRef
		if MME.curOutfitContainer == MME.OutfitContainer
			SFF_Perma_HomeOutfitList.AddForm(akBaseItem)
			debug.trace("SFF: [INFO] Player ADDED an item to Home Outfit via Inventory.")	
		elseif MME.curOutfitContainer == MME.SleepOutfitContainer
			SFF_Perma_SleepOutfitList.AddForm(akBaseItem)
			debug.trace("SFF: [INFO] Player ADDED an item to Sleep Outfit via Inventory.")	
		endif
	endif
EndEvent
