Scriptname SFF_HoodieContainerScript extends ObjectReference  

FormList Property ItemList Auto
Keyword Property ClothingHead Auto
Keyword Property ArmorHelmet Auto
;Actor rnpcActor
ReferenceAlias Property Serana Auto

Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	
		If akBaseItem.HasKeyword(ClothingHead) || akBaseItem.HasKeyword(ArmorHelmet)	;; If item has necessary keyword,
			ItemList.AddForm(akBaseItem)	;; add to hoodie list.
		Else								;; If not, give back to Player.
			RemoveItem(akBaseItem, aiItemCount, True, akSourceContainer)
			Debug.Notification("Item cannot be used as hoodie!")
		Endif
		
	
EndEvent

Event OnItemRemoved (Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
	If akBaseItem.HasKeyword(ClothingHead) || akBaseItem.HasKeyword(ArmorHelmet)
		ItemList.RemoveAddedForm(akBaseItem)
		Serana.GetActorReference().RemoveItem(akBaseItem)
		;Debug.Notification("Removed " + akBaseItem + "from list")
	Endif
EndEvent