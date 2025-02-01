Scriptname sff_OnLevelUpManager extends ReferenceAlias  
import PO3_Events_Alias

GlobalVariable Property iVLLevel_MCM_SFF auto		;; level threshold (actual level, not the percentage)
GlobalVariable Property iVLLevelPercent_MCM_SFF	auto	;; percentage set by slider, to be used externally to calculate 'iVLLevel_MCM_SFF'.

Event OnInit() 
	RegisterForLevelIncrease(self)
EndEvent

Event OnLevelIncrease(int aiLevel)
	UpdateVampireLvl()
	Debug.Trace("SFF: VL enemy lvl threshhold updated. Now transform if enemy >= :" + iVLLevel_MCM_SFF.GetValue())
EndEvent

Function UpdateVampireLvl()
	int iCurLvl= Self.GetActorReference().GetLevel()
	float fCurLvl= iCurLvl as float
	iVLLevel_MCM_SFF.SetValue(iVLLevelPercent_MCM_SFF.GetValue() * fCurLvl)
EndFunction