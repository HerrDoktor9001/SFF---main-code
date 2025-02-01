Scriptname SFF_VL_PlayerTransform extends ReferenceAlias  

GlobalVariable Property SFF_MCM_VL_Player auto 		;; MCM menu toggle for Player transformation 
GlobalVariable Property bVL_TransformPlayer auto	;; indicator for transforming Serana. Only "1" if conditions are met
Race Property DLC1VampireBeastRace auto

Event OnInit()
	;DLC1VampireBeastRace=  Game.GetFormFromFile(0x0200283A,"Dawnguard.esm") As Race
EndEvent

Event OnRaceSwitchComplete()
	if SFF_MCM_VL_Player.GetValue() == 1
		Debug.Trace("Player switched race & VL transformation on Player transform enabled. Is his new race VL?")
		if GetActorReference().GetRace() == DLC1VampireBeastRace
			Debug.Trace("Player Vampire Lord. Transform Serana.")
			bVL_TransformPlayer.SetValue(1)
		else
			Debug.Trace("Player back to human. Revert Serana.")
			bVL_TransformPlayer.SetValue(0)
		endif
	else 
		bVL_TransformPlayer.SetValue(0)		;; failsafe to disable indicator (e.g., if Player disables Player transformation while Serana still transformed, code here cannot reset indicator when transforming back to human
		Debug.Trace("Player Vampire Lord, but Serana transform not enabled.")
	endif 
EndEvent