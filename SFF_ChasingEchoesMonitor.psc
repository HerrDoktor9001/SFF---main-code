Scriptname SFF_ChasingEchoesMonitor extends ReferenceAlias  Conditional
import PO3_Events_Alias

Quest Property DLC1VQ05 auto			;; 'Beyond Death' quest
Spell Property SFF_SummonSerana auto
Spell Property SFF_Teleport2Cairn auto
Actor PlayerRef
Alias Property PlayerAlias auto 
GlobalVariable Property SFF_MCM_QuestSpells auto


Event OnInit()
	PlayerRef= Game.GetPlayer()
	RegisterForQuest(PlayerAlias, DLC1VQ05)
EndEvent

Event OnQuestStop(Quest akQuest)
	if akQuest == DLC1VQ05
		Debug.Trace("'Chasing Echoes' quest completed.")
		if SFF_MCM_QuestSpells.GetValue() == 1				;; if spells enabled
			AddSpells()										;; add them to Player
		else 
			Debug.Trace("Canna add spells: MCM toggle disabled.")
		endif	
		UnregisterForQuest(PlayerAlias, DLC1VQ05)			;; and unregister the event
	endif
EndEvent

Function ManualChecker()
	{Called from MCM menu. Checks if quest is complete & calls spell addition code}
	if DLC1VQ05.IsCompleted()
		AddSpells()
	else
		Debug.Trace("SFF: Canna add spells yet. Player has not completed 'Chasing Echoes' yet.")
	endif
EndFunction

Function AddSpells()
	{Adds necessary spells to the Player. Shared by OnQuestStop event and ManualChecker func.}
	PlayerRef.AddSpell(SFF_SummonSerana)
	PlayerRef.AddSpell(SFF_Teleport2Cairn)
	Debug.Trace("SFF: 'Chasing Echoes' spells added.")
EndFunction

Function RemoveSpells()
	{Called from MCM menu. Removes spells from Player}
	if PlayerRef.HasSpell(SFF_SummonSerana)
		PlayerRef.RemoveSpell(SFF_SummonSerana)
		Debug.Trace("SFF: 'Summon Serana' spell removed.")
	endif
	if PlayerRef.HasSpell(SFF_Teleport2Cairn)
		PlayerRef.RemoveSpell(SFF_Teleport2Cairn)
		Debug.Trace("SFF: 'Teleport to Soul Cairn' spell removed.")
	endif
EndFunction