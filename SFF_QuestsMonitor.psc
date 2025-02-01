Scriptname SFF_QuestsMonitor extends ReferenceAlias  
import PO3_Events_Alias

Actor PlayerRef
Alias Property PlayerAlias auto 
SFF_MentalModelExtender Property MME auto

;; Severin Manor quest
Quest Property DLC2RR02 auto
Cell Property DLC2RRSeverinHouse  Auto 
Faction Property PlayerFaction auto 

;; 'Diplomatic Immunity' quest
Quest Property MQ201 auto

Event OnInit()
	PlayerRef= Game.GetPlayer()
	RegisterForQuest(PlayerAlias, DLC2RR02)
	RegisterForQuest(PlayerAlias, MQ201)
	if MQ201.GetStageDone(30)
		;; if Player already started the quest (meaning InQuestStart event cannot catch it),
		;; register for quest change event
		RegisterForQuestStage(PlayerAlias, MQ201)
		Debug.Trace("SFF: 'Diplomatic Immunity' quest already started.")
	endif
EndEvent

Event OnQuestStop(Quest akQuest)
	if akQuest == DLC2RR02
		Debug.Trace("SFF: 'Served Cold' Soltheim quest complete.")
		DLC2RRSeverinHouse.SetFactionOwner(PlayerFaction)
		UnregisterForQuest(PlayerAlias, DLC2RR02)			;; and unregister the event
	elseif akQuest == MQ201
		UnregisterForQuest(PlayerAlias, MQ201)
	endif	
EndEvent

Event OnQuestStart(Quest akQuest)
	if akQuest == MQ201
		Debug.Trace("SFF: 'Diplomatic Immunity' quest started. Registering for quest stage...")
		RegisterForQuestStage(PlayerAlias, MQ201)
	endif
EndEvent

Event OnQuestStageChange(Quest akQuest, Int aiNewStage)
	if akQuest == MQ201
		if aiNewStage >= 70
		;; disable teleportation
		MME.bBlockTeleport= true
		Debug.Trace("SFF: 'Diplomatic Immunity' lonewolf quest stage reached. Teleportation disabled")
	
		elseif aiNewStage >= 230
			;; re-enable teleport.
			MME.bBlockTeleport= false
			UnregisterForQuest(PlayerAlias, MQ201)
			Debug.Trace("SFF: 'Diplomatic Immunity' lonewolf quest stage finished. Teleportation re-enabled")
		endif
	endif
EndEvent