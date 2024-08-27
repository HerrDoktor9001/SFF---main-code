Scriptname SFF_AcessoryContainerHandler extends ObjectReference  


SFF_MentalModelExtender Property MME auto
Actor Property Serana Auto
Actor Property PlayerRef Auto

FormList Property SFF_AccessoryList auto		;; List for keeping track of all items added to Accessory Container


Event OnActivate(ObjectReference akActionRef)
	;; if Accessory Cont. opened, get its content currently in Inv. BACK for Player to manage...
	;MME.AccessoriesManager(0, Serana as objectreference)
EndEvent

Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	

	if akSourceContainer == PlayerRef				;; if item added by Player,
		
		;; return to Player if container already full (no more than 05 items allowed)
		if SFF_AccessoryList.GetSize() > 5
			RemoveItem(akBaseItem, aiItemCount, true, akSourceContainer)
			Debug.Notification("No more items allowed.")
			return
		endif
		
		;; return to Player if container already has an instance of the same item (only 01 unit per item allowed)
		if aiItemCount > 1
			;int i = aiItemCount - 1
			RemoveItem(akBaseItem, (aiItemCount - 1), true, akSourceContainer)
			Debug.Trace("->-> [SFF] [ACCESSORIES]: Player tried adding more than 01 unit of " + akBaseItem + ". Only 01 unit per item allowed! Returning...")
			Debug.Notification("Only 01 unit per item allowed!")
		endif
		
		;; return to Player if trying to add more than one item
		if self.GetItemCount(akBaseItem) > 1
			RemoveItem(akBaseItem, aiItemCount, true, akSourceContainer)
			Debug.Trace("->-> [SFF] [ACCESSORIES]: " + akBaseItem + " already present in Accessory Container. No more allowed. Returning...")
			Debug.Notification("Item already present in Accessory list.")
			return
		endif
		

	
		SFF_AccessoryList.AddForm(akBaseItem)		;; add it to list.
		Serana.AddItem(akBaseItem)
		Debug.Trace("SFF: Player added " + akBaseItem.GetName() + " to Accessory Container.")
	endif
	
	Debug.Trace("->-> [SFF] [ACCESSORIES]: '" + akBaseItem.GetName() + "' added to AccessoryCont. from '" + akSourceContainer.GetBaseObject().GetName() + "' <-<-")
EndEvent

Event OnItemRemoved (Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
	;Bool bIsMCMMenuOpen = UI.IsMenuOpen("ContainerMenu")
	;if akDestContainer == PlayerRef ;&& bIsMCMMenuOpen					;; if item removed by Player,
		
	if GetItemCount(akBaseItem) < 1										;; only erase item from list if NO units present in container (if for some reason more than one unit of any item is added, removing only one but leaving the rest would lead to erasure from list)
		SFF_AccessoryList.RemoveAddedForm(akBaseItem)	;; erase it from list.
		if !MME.bUsingIndoorsOutfit()
			Serana.RemoveItem(akBaseItem, 1)				;; remove it from Serana's Inventory, if present
		elseif MME.bUsingIndoorsOutfit()
			MME.SafeHoldingCont.RemoveItem(akBaseItem)
		endif
		Debug.Trace("SFF: Player removed " + akBaseItem.GetName() + " from Accessory Container.")
	endif
	;endif
EndEvent
