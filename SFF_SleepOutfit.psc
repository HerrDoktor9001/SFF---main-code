Scriptname SFF_SleepOutfit extends ReferenceAlias  
{Calls function on MentalModelExtender when Sleep Packages loaded}

Actor Serana 
ReferenceAlias Property Alias_Serana auto
Package[] Property SeranaSleepPackage  Auto 
SFF_MentalModelExtender Property MME auto
GlobalVariable Property SFF_MCM_SleepOutfit auto

Event OnInit()
	Serana= Alias_Serana.GetActorReference()
EndEvent

Event OnPackageStart(Package akNewPackage)
	if SFF_MCM_SleepOutfit.GetValue() == 1
		;Serana = Alias_Serana.GetActorReference() 
		if Serana.GetCurrentPackage() == SeranaSleepPackage [0] || Serana.GetCurrentPackage() == SeranaSleepPackage[1]
			Debug.Trace("SFF: Sleep package started")
			MME.bSleepTime= true
			MME.SleepOutfitManager()
		EndIf
	endif
EndEvent

Event OnPackageChange(Package akOldPackage)
	if SFF_MCM_SleepOutfit.GetValue() == 1
		;Serana = Alias_Serana.GetActorReference() 
		if Serana.GetCurrentPackage() == SeranaSleepPackage [0] || Serana.GetCurrentPackage() == SeranaSleepPackage[1]
			;Debug.Notification("Sleep started")
			MME.bSleepTime= true
			MME.SleepOutfitManager()
		
		elseif Serana.GetCurrentPackage() != SeranaSleepPackage [0] || Serana.GetCurrentPackage() != SeranaSleepPackage[1]
			if akOldPackage == SeranaSleepPackage [0] || akOldPackage == SeranaSleepPackage [1]
				MME.bSleepTime= false
				MME.SleepOutfitManager()
			endif
		endif
	endif
EndEvent

Event OnPackageEnd(Package akOldPackage)
	;;as soon as Serana starts sleeping, OnPackageEnd is called, even though package itself still running...
endEvent