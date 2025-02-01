Scriptname SFF_CustomHoodieDetector extends ReferenceAlias  
{Should go on Serana's reference alias. Detects specific item removal from her inventory, e.g., if Player has removed any Custom hoodies directly from inventory instead of appropriate menu}

SFF_MentalModelExtender Property MME auto
ObjectReference Property HoodContainer auto
ObjectReference Property PlayerRef auto	;; sff v1.8.0
Actor Property Serana auto 	;; sff v1.9.0

;; sff v1.9.0 - just to make sure property is always filled
Event OnInit()
	PlayerRef= Game.GetPlayer()
	Serana= self.GetReference() as actor
EndEvent

Event OnItemRemoved (Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
	If akBaseItem == MME.SFF_HoodieList.GetAt(0)
		;Debug.Notification("Removed CUSTOM HOODIE from inventory")
		if akDestContainer == PlayerRef
			;Debug.Notification("CUSTOM HOODIE given to Player")
			HoodContainer.RemoveItem(akBaseItem)
			Utility.Wait(3)
			MME.CustomHoodieHandler()
		endif
	Endif
	
	
	;; SFF v1.9.0
	if akDestContainer == PlayerRef									;; if Player is one removing items from Inventory,
		if MME.SFF_AccessoryList.Find(akBaseItem) != -1				;; and the item removed is part of Acessory list,
			if self.GetReference().GetItemCount(akBaseItem) == 0	;; and we now have 0 of it left in Inventory,
				;MME.SFF_AccessoryList.RemoveAddedForm(akBaseItem)	;; remove it from the list!
				MME.SFF_Acessory_Container.RemoveItem(akBaseItem)
				Debug.Trace("->-> [SFF] [ACCESSORIES]: Player removed Accessory Item ('" + akBaseItem.GetName() + "') from Serana's Inventory. Removing it from Accessory Container... <-<-")
			endif
		endif
	endif
	
	
	
	;If akBaseItem as Armor != None
	;	if akDestContainer == Game.GetPlayer()
	;		SFF_DismissalList.RemoveAddedForm(akBaseItem)
	;	endif
	;Endif
EndEvent

;Event OnItemAdded (Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	;If (akBaseItem as Armor != None) 					;; If item is Armour
	;	if akSourceContainer == Game.GetPlayer()		;; given by Player
	;		Utility.Wait(0.1)							;; hang code to make sure Serana equips what is necessary,
	;		if SeranaAlias.GetActorReference().IsEquipped(akBaseItem as Armor)	;; check if item given is equipped,
	;			SFF_DismissalList.AddForm(akBaseItem)							;; add it to ForceEquip() list.
	;			;Debug.Notification(akBaseItem + " added to List.")
	;		endif
	;	endif
	;Endif
;EndEvent

;; Serana's outfit after dismissal has proven to be a challenge to manage: adding or removing items while dismissed does not trigger her to equip anything: she'll only wear what's in her OUTFIT, and if outfit empty, she'll wear nothing. We thus need an updated list of all armour given by Player (so, no items given by other mechanisms - e.g., Wet&Cold hoods), currently in her Inventory (so no items which were previously removed - at least by the Player) and in use (avoid adding obsolete, unused items). From this list we can force her to equip said items when necessary. 