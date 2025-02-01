Scriptname sff_ArvakDisabler extends ReferenceAlias  

Package Property SFF_ArvakReturn2Oblivion auto
SFF_MentalModelExtender Property MME auto

Event OnPackageStart(Package akNewPackage)

	if (MME.DLC01SoulCairnHorseSummon as Actor).GetCurrentPackage() == SFF_ArvakReturn2Oblivion
		;Debug.Notification("disable arvak...")
		MME.DisableArvak()
	EndIf
EndEvent