Scriptname SFF_SunDamageController extends ReferenceAlias  Conditional
{This scrip controls code related to Serana's Sun Damage Mechanic. Sun damage is now not absolute (vanilla), but variable: more armour slots in use =  milder damage from sun}
import PO3_SKSEFunctions		

Actor Serana
Actor PlayerRef
SFF_MentalModelExtender Property MME auto
GlobalVariable Property SFF_SunDamage auto

Bool bInInventory	;; checks if Player is in Inventory and protection amount needs to be rechecked (i.e., armour has been removed or added)

Bool bBodyCovered	;; checks if Serana using Torso gear
Bool Property bHeadCovered auto conditional	;; checks if Serana using Head gear. Also set by 'SFF_MentalModelExtender'
Bool bHandsCovered	;; checks if Serana using Hand gear
Bool bFeetCovered	;; checks if Serana using Feet gear

Int Property iProtection auto conditional	;; int used to represent different levels of protection (0-4)

Spell Property crVampireSunDamage auto		;; original spell that nerfs Serana's healing rates (must be removed)
Spell Property crVampireSunDamage_90 auto	;; (4-5) full protection (Torso + 2 other slots) 
;Spell Property crVampireSunDamage_25 auto	;; (3/4) partial protection
;Spell Property crVampireSunDamage_50 auto	;; (2/4) partial protection 
;Spell Property crVampireSunDamage_75 auto	;; (1/4) partial protection
Spell Property crVampireSunDamage_100 auto	;; (0-3) no protection (Torso alone, or all but torso, or completely empty)

FormList Property SFF_SeranaInventoryList auto 
FormList Property SFF_CombatHoodieList auto
GlobalVariable Property SFF_MCM_AutoCombatHeadGear auto	

int iBody
int iHead
int iHands
int iFeet

Event OnInit()
	Serana= Self.GetActorReference() 
	PlayerRef= Game.GetPlayer()
	;RegisterForMenu("ContainerMenu")
	;SwapSpells()
	;if Serana.AddSpell(crVampireSunDamage)
	;  Debug.Trace("SFF: Serana sun weakness spell added. This should only happen once, on very first script load and never again...")
	  ;; SFF v1.2.1 ~ for re-adding via script SunDamage spell, removed from Alias manually
	;endIf

	;; SFF v1.3.1: to make sure spells are not unduly added after mod update or otherwise restarting of quest holding this script
	if 	SFF_SunDamage.GetValue() == 0
		RevertSpells()
	else
		SwapSpells()
	endif

EndEvent

Function SwapSpells()
;; called from MCM menu, in case Player enables Sun Damage Mech. 
	RemoveBaseSpell(Serana, crVampireSunDamage)	;; SFF v1.2.1 - VampireSunDamage is a base spell. Traditional removal would result in spell returning on savegame reload/fast travel.
	if Serana.RemoveSpell(crVampireSunDamage)
	  Debug.Trace("crVampireSunDamage removed (non-base)")
	endIf
	if Serana.AddSpell(crVampireSunDamage_90)
	  Debug.Trace("crVampireSunDamage_0 Spell added")
	endIf
	if Serana.AddSpell(crVampireSunDamage_100)
	  Debug.Trace("crVampireSunDamage_100 Spell added")
	endIf
EndFunction

;; called from MCM menu, in case Player disables Sun Damage Mech. 
;; called from MME after cure		(SFF v1.2.0)
Function RevertSpells()
	if !MME.bCured										;; SFF v1.2.0 - makes sure Vampire damage is not re-added to Serana if already cured 
		if Serana.AddSpell(crVampireSunDamage)
		  Debug.Trace("crVampireSunDamage re-added")
		endIf
	else 
		Debug.Trace("SFF_SunDamage: Serana is cured. SunDamage spell should not be re-added.")
	endif
	
	if Serana.RemoveSpell(crVampireSunDamage_90)
	  Debug.Trace("crVampireSunDamage_0 Spell removed")
	endIf
	if Serana.RemoveSpell(crVampireSunDamage_100)
	  Debug.Trace("crVampireSunDamage_100 Spell removed")
	endIf
EndFunction

;; if items were added or removed from Inventory, means we accessed it 
;; event not fired if items added via console command... (v1.8.1)
Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	If (akBaseItem as Armor != None) 					;; If item is Armour
		
		SFF_SeranaInventoryList.AddForm(akBaseItem)			;; SFF v1.2.0 - list to be used by outfit system. Keeps track of every armour currently in Inventory.
		
		;; SFF v1.8.1 - if items are being added to Inventory, they should inadvertently get equipped.
		;; Doing so here is much more efficient and causes much less stutters than doing it @ MME (no need to trigger outfit refresh). 
		if Serana.GetItemCount(akBaseItem as Armor) > 0 && !Serana.IsEquipped(akBaseItem as Armor)
			Serana.EquipItem(akBaseItem as Armor)
			;Debug.Trace("-->> -->> -->> SFF: item added and equipped <<-- <<-- <<--")
		endif
		
		
		;; combat headgear will be automatically removed on combat end. No need to remove it from list beforehand here. SFF v1.2.1
		;; code obviously doesn't care about hoodie in general, only in its combat form, so, obsolete code. 
	endif
EndEvent

Event OnItemRemoved (Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
	If (akBaseItem as Armor != None)

		SFF_SeranaInventoryList.RemoveAddedForm(akBaseItem)
	Endif
EndEvent


;; SFF v1.3.1: For making sure Sun Damage gauge can be called externally
;; solve bug were protc. value is not updated properly unless opening Inventory
;; called by 'DLC1RNPCAliasScript', 'MME'.
Function OutfitProtecChecker()
	if SFF_SunDamage.GetValue() != 1
		return
	endif 
	
	if PlayerRef.IsInInterior()
		return
	endif
	
	CheckClothingProtection()
EndFunction

;; check if we have selected slots full or otherwise empty
Function CheckClothingProtection()

	if Serana.GetWornForm(0x00000004) as Armor != none
		;Debug.Trace("SFF: Serana torso slot full")
		bBodyCovered= true
	else
		Debug.Trace("SFF: Serana torso slot empty")
		bBodyCovered= false
	endif

	if Serana.GetWornForm(0x00000002) as Armor != none || Serana.GetWornForm(0x00000001) as Armor != none
		;Debug.Trace("SFF: Serana head slot full")
		bHeadCovered= true
	else
		Debug.Trace("SFF: Serana head slot empty")
		bHeadCovered= false
	endif
	
	if Serana.GetWornForm(0x00000008) as Armor != none || Serana.GetWornForm(0x00000010) as Armor != none
		;Debug.Trace("SFF: Serana hand slot full")
		bHandsCovered= true
	else
		Debug.Trace("SFF: Serana hand slot empty")
		bHandsCovered= false
	endif
	
	if Serana.GetWornForm(0x00000080) as Armor != none
		;Debug.Trace("SFF: Serana feet slot full")
		bFeetCovered= true
	else
		Debug.Trace("SFF: Serana feet slot empty")
		bFeetCovered= false
	endif
	
	Convert2Int()
EndFunction

Function Convert2Int()
	
	if bBodyCovered
		if iBody == 0
			iBody += 2		;; give greater weight to torso armour to simulate larger surface area protection
		endif
	else
		if iBody > 0
			iBody -= 2
		endif
	endif
	
	if bHeadCovered
		if iHead == 0
			iHead+= 1
		endif
	else
		if iHead > 0
			iHead -= 1
		endif
	endif
	
	if bHandsCovered
		if iHands == 0
			iHands += 1
		endif
	else
		if iHands > 0
			iHands -= 1
		endif
	endif
	
	if bFeetCovered
		if iFeet == 0
			iFeet += 1
		endif
	else
		if iFeet > 0
			iFeet -= 1
		endif
	endif
	CalculateProtection()
EndFunction

Function CalculateProtection()
	iProtection= 0
	iProtection= iHead + iBody + iHands + iFeet
	MME.iSunProtecLevel= iProtection
	Debug.Trace("Outfit Sun Protection val.: " + MME.iSunProtecLevel)
EndFunction