Scriptname SFF_SDEInitialiser extends ReferenceAlias  
;; Script name misleading: used to initialise all sort of needed code, not just related to SDE.

SFF_MentalModelExtender Property MME auto
SFF_MCM_Script Property MCM auto 

Event OnPlayerLoadGame()
	SDEIniatialiser()
	MME.PreviewerAnimInitialiser()	;; SFF v1.9.0 - fills the necessary properties on MME
	MME.ClearOffsets()				;; SFF v1.9.0 - clears (possible) stuck offset on Save Load
	;MME.FactionsSetter()			;; SFF v1.9.0 - makes sure Serana is added to 'PlayerBedOwnership' faction (better to move this to Update System, instead of re-checking on every save load)
EndEvent  

Event OnInit()
	SDEIniatialiser()
	if !MME.bIsSDEInstalled
		;Debug.MessageBox("SFF installed but SDE not found. Some features dependent on it have been disabled. To experience the mod in full, SDE installation is recommended.")
	endif
EndEvent

Function SDEIniatialiser()
	Debug.Trace("SFF: SDE initialiser called")
	MME.bIsSDEInstalled= Game.IsPluginInstalled("Serana Dialogue Edit.esp")
	if MME.bIsSDEInstalled
		Debug.Trace("SFF: SDE installed")
		;; grab SDE main quest
		MME.SDEQuest= Game.GetFormFromFile(0x00029012,"Serana Dialogue Edit.esp") As Quest
		if MME.SDEQuest
			Debug.Trace("SFF: SDE CustomMentalModel quest found")
		endif
	else
		Debug.Trace("SFF: SDE plugin not found. Some features will be unavailable.")
	endif
EndFunction


;; SFF v1.9.0 - for making sure removed MCM settings have proper values filled
Function PropertyFiller()
	MCM.SFF_MCM_CustomOutfitSets.SetValue(1)		;; force-enable 'Advanced Outfit Management'
	MCM.SFF_MCM_CombatOutfitFix.SetValue(1)			;; force-enable 'Combat Outfit Fix' (using loose items instead of baked outfits)
EndFunction