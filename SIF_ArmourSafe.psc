Scriptname SIF_ArmourSafe extends ObjectReference  

FormList Property SFF_SafeContainerList auto


Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	
	If (akBaseItem as Armor != None) 					;; If item is Armour,
		SFF_SafeContainerList.AddForm(akBaseItem)		;; add to Outfit list.
		;debug.trace("WORKING!")
	endif

EndEvent

Event OnItemRemoved (Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
	If (akBaseItem as Armor != None) 						;; If item is Armour,
		SFF_SafeContainerList.RemoveAddedForm(akBaseItem)	;; remove from list.
	endif
EndEvent