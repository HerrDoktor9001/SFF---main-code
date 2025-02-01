;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 2
Scriptname SFF__QF_SFF_Updater_0709D755 Extends Quest Hidden

;BEGIN ALIAS PROPERTY PlayerRef
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_PlayerRef Auto
;END ALIAS PROPERTY
GlobalVariable Property SFF_MCM_Updater auto
Quest Property SFF_SeranaUpdatableScripts auto 
Quest Property SFF_HorseMountController auto
SFF_SynergyCombatHandler Property SCH auto
SFF_MentalModelExtender Property MME auto

;BEGIN ALIAS PROPERTY SeranaRefUpdater
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_SeranaRefUpdater Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE

SCH.BackUpVars()					;; call backup function on Synergy script
SFF_SeranaUpdatableScripts.Stop()	;; kills quest to reset scripts and alias
SFF_HorseMountController.Stop()
Utility.Wait(2.0)
SFF_SeranaUpdatableScripts.Start()	;; restarts the quest
SFF_HorseMountController.Start()
MME.HorseAliasRefill()
SetStage(100)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN CODE
SFF_MCM_Updater.SetValue(0)
Debug.Notification("Update complete")
Stop()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment


