Scriptname sif_outfitmanagement extends ObjectReference  

SFF_MentalModelExtender Property MME auto
Actor Property PlayerRef Auto
FormList Property ItemList Auto								;; specific list that keeps track of items in this Container
FormList Property SFF_CombatHoodieList auto
GlobalVariable Property SFF_MCM_AutoCombatHeadGear auto

GlobalVariable Property SFF_MCM_OutfitPrev auto 	;; DELETE!		;;SFF v1.5.0 - stores current status of Outfit Previewer toggle
Actor Property SeranaRef Auto						;; DELETE!

;; sff v2.0.0
FormList Property PermaItemList auto		;; a less volatile list for keeping track of items added/removed BY PLAYER.



;; sff v1.5.0
Event OnActivate(ObjectReference akActionRef)
	
	if akActionRef != PlayerRef
		return
	endif	
	
	;; copy all items currently in this Container to Serana.
	;; Serana's Inventory should be clear, or else items will mix! ('OpenCustomOutfitCont()').
	;; only do so if all clear ('bPreviewerCanWork' = true)
	if MME.bPreviewerCanWork
		
		
		;; sff v1.8.1 - adding items via console commands does not trigger 'OnItem' events!!!
		;; We thus need to either use intermediate container to shuffle items, OR read and add to Inventory from generated list
		
		;SetSelectedReference(self)
		;ExecuteCommand("duplicateallitems 02002b74")
		
		
		;; Adding preview items to Serana...
		Int iIndex = 0
		Int iSize = 0
		
		iSize= ItemList.GetSize()
		
		While iIndex < iSize
			
			Form entry = ItemList.GetAt(iIndex)
			MME.rnpcActor.AddItem(entry as ARMOR)
			iIndex += 1
		EndWhile
		
		;self.removeallitems(self)
		
		Debug.Trace("[SFF][Previewer] Items of currently opened Outfit cloned to Serana's Inventory, so Player can preview it")

		MME.ResetSeranaInPreview()			;; sff v1.5.1 - call this here, as T-Pose now only possible in Custom Cont. 
		MME.rnpcActor.QueueNiNodeUpdate()	;; sff v1.7.1 - only works if game paused. Unpaused menu solution necessary...
	endif

	MME.CustomOutfitManager(self, ItemList)

EndEvent

Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	
	If (akBaseItem as Armor != None) 			;; If item is Armour,
		ItemList.AddForm(akBaseItem)		;; add to Outfit list. Does not matter if source is Player or not
		

		if akSourceContainer != PlayerRef
			Debug.Trace("SFF: '" + GetBaseObject().GetName() + "' being filled from '" + akSourceContainer.GetBaseObject().GetName() + "'.")
			
			;; SFF v1.4.4 - removes hoodie currently in use from outfit container, returning it to source
			;; SFF v1.8.0 - deleterious behaviour for 'Organic Hood' feature, as hood will be unduly returned to Inventory
			if akBaseItem == MME.Hoodie as Form	
				if MME.SFF_MCM_HoodBeh.GetValue() != 0 && (MME.bOrganicHoodDetection() != true || MME.bOrganicHoodDetection() == true && MME.SFF_HoodieList.GetSize() == 1)
					RemoveItem(akBaseItem, aiItemCount, True);, akSourceContainer)
					Debug.Trace("SFF: Hoodie removed from " + GetBaseObject().GetName())
				endif
			
			else
				if SFF_MCM_AutoCombatHeadGear.GetValue() == 1 && akBaseItem == MME.SFF_HoodieList.GetAt(0) || SFF_MCM_AutoCombatHeadGear.GetValue() == 2 && akBaseItem == SFF_CombatHoodieList.GetAt(0)
					RemoveItem(akBaseItem)
					Debug.Trace("SFF: Combat headgear removed from '" + GetBaseObject().GetName() + "'.")
					;; SFF v1.2.0 - part of Custom Outfit Sets expansion; part of solution to Player-tempered or enchanted armour issue. Like hoodie, if comabt headgear item is unduly moved to Container, it'll become part of the outfit. Remove it!
				endif					
			endif
	
		endif
		
		;; SFF v1.5.0 - if Previewer enabled,
		;; add a copy of the item added to Outfit Container directly to Serana's Inventory.
		;; That way, the outfit can be previewed by the Player.
		if MME.bPreviewerCanWork
			if akSourceContainer == PlayerRef
				MME.rnpcActor.AddItem(akBaseItem, 1, true)
				MME.rnpcActor.QueueNiNodeUpdate()				;; Force outfit items to update while game still paused.
				;;MME.ResetSeranaInPreview()
				Debug.Trace("SFF: Outfit Prev. enabled and " + akBaseItem.GetName() +" added to Inventory.")
			endif
		EndIf
	Else								;; If not, give back to Player.
		RemoveItem(akBaseItem, aiItemCount, True, akSourceContainer)
		Debug.Trace("SFF: " + akBaseItem.GetName() + " cannot be stored in outfit container ('" + GetBaseObject().GetName() + "'). Returning...")
		if akSourceContainer == PlayerRef
			Debug.Notification("Item cannot be used in outfit!")
		endif
	Endif
	
	
	;; sff v1.9.0 - if adding items externally that belong to AccessoryContainer, remove them (but ONLY if externally, and not added by Player)
	if akSourceContainer != PlayerRef 
		FormList cacheAccessoryList = MME.SFF_AccessoryList
		int iListSize = cacheAccessoryList.GetSize()
		if iListSize > 0										;; if Accessories empty, no need to check anything
			int iMyIndex= 0
			While  iMyIndex < iListSize
				Form entry= cacheAccessoryList.GetAt(iMyIndex)
					if akBaseItem == entry 
						;if MME.rnpcActor.GetItemCount(akBaseItem) > 0			;; if Serana has same item already on her Inventory, delete it from Outfit
							RemoveItem(akBaseItem, 1)
							debug.trace("->-> [SFF] [ACCESSORIES]: '" + entry.GetName() + "' REMOVED from '" + GetBaseObject().GetName() + "'. <-<-")
						; else
							; if MME.bCustomOutfitAccessoryBlock()
								; debug.trace("->-> [SFF] [ACCESSORIES]: Accessories blocked! Will not send items back to Serana's Inventory...")
								; RemoveItem(akBaseItem, 1)
								; return
							; endif
							
								; RemoveItem(akBaseItem, 1, true, MME.rnpcActor)
								; debug.trace("->-> [SFF] [ACCESSORIES]: '" + entry.GetName() + "' REMOVED from '" + GetBaseObject().GetName() + "' and RETURNED to Serana's Inventory. <-<-")
							

							
						;endif
					endif
				iMyIndex += 1
			EndWhile
			iMyIndex= 0
		endif
	
	;; SFF v2.0.0 - Player trading items and cur. container == HomeOutfitContainer or SleepOutfitContainer
	else
		If (akBaseItem as Armor != None) 
			if self == MME.SFF_OutfitContainer || self == MME.SleepOutfitContainer
				PermaItemList.AddForm(akBaseItem)
			endif
		endif
	endif
	
EndEvent

Event OnItemRemoved (Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
	
	ItemList.RemoveAddedForm(akBaseItem)
	
	;; SFF v1.5.0 - if item removed from Container by Player,
	;; also remove it from Inventory.
	if akDestContainer == PlayerRef
		if MME.bPreviewerCanWork
		
			MME.rnpcActor.RemoveItem(akBaseItem, aiItemCount, true)
			MME.rnpcActor.QueueNiNodeUpdate()				;; Force outfit items to update while game still paused.
			;;MME.ResetSeranaInPreview()
			Debug.Trace("SFF: Player removed " + akBaseItem.GetName() + " from '" + GetBaseObject().GetName() + "'.")
		endif
	
	
		If (akBaseItem as Armor != None)
			if self == MME.SFF_OutfitContainer || self == MME.SleepOutfitContainer		
				PermaItemList.RemoveAddedForm(akBaseItem)
			endif
		endif	
	
	else
		Debug.Trace("SFF: " + akBaseItem.GetName() + " REMOVED from '" + GetBaseObject().GetName() + "'. Sent to '" + akDestContainer.GetBaseObject().GetName() + "'.")
	endif
EndEvent
;; SFF v1.0.0 ~ Listening to OnItemRemoved event much cheaper and reliable than shuffling between containers and maintaining redundancy containers. 
;; If armour item is removed from Container, removes it automatically from the Outfit list


;; SFF v2.0.1 ~ so far we used the 'Damage Resist' actor value to reflect Outfit armour protection value/rating. The issue is that changing Outfits while MCM menu still open would not update the stat. CK wiki has this enlightening info: 
;; "Armor equipped while in OpenInventory or pick-pocketing dialogues will not be visible on the actor until the dialogue is ended. Calling the SKSE function QueueNiNodeUpdate straight after calling EquipItem can force the actor to draw the new equipment immediately." The same happens when in MCM. 
;; So, instead of iterating through Inventory list, checking the armour rating of individual items and aggregating them, we simply call a "QueueNiNodeUpdate()" when adding items to Serana