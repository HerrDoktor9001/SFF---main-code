Scriptname sff_previewercache extends ObjectReference  
;; SFF v1.5.0
;; script used to filter items if using the Outfit Previewer function
;; when Player opens any one of Outfit Containers, any previous items Inventory items will be returned to their corresponding Containers,
;; and "preview" copies of items from the currently opened Outfit Container will be added to Inventory (so Player can preview how outfit will look).
;; HOWEVER, preview items need to be removed before returning actual outfit to Inventory!
;; Given complexity of filtering items, MME script will move ALL Inventory items to here.
;; ... from here, script should filter items, sending back any non-armour objects.
;; the remaining items SHOULD BE ONLY the preview items added earlier to Inventory and can be safely discarded.

SFF_MentalModelExtender Property MME auto


Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	if akBaseItem as Armor != none		;; if added item of Armor type,
		
		RemoveItem(akBaseItem)			;; delete it.
	
	else								;; if NOT Armor,
	
		RemoveItem(akBaseItem, aiItemCount, true, akSourceContainer)	;; return to source.
	endif
	
	;; SFF v1.9.0 - Previewer feature deletes Accessory items returned to Inventory which are not part of the Outfit itself
	if MME.SFF_AccessoryList.Find(akBaseItem) != -1
		RemoveItem(akBaseItem, aiItemCount, true, akSourceContainer)	;; return to source (should be Inventory).
	endif
EndEvent