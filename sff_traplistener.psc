Scriptname sff_traplistener extends ReferenceAlias 

DLC1_NPCMentalModelScript Property MM auto  ;; Serana AI (MentalModel)
SFF_MentalModelExtender Property MME auto	;; Serana AI extender

ObjectReference PlayerRef
ObjectReference SeranaRef 

ObjectReference Property myMarker auto	;; xMarker where Serana must go to
ObjectReference Property refObj auto	;; reference object for determining 'myMarker' location

float property xOffset = 100.0 auto	;; back-front (negative, goes to front; positive, back)
float property yOffset = 40.0 auto	;; (negative, goes left; positive, right)
float property zOffset = 0.0 auto	;;?

bool property bIsTrigger auto	;; to determine if we should use Trigger or Lever code
bool property bMatchRotation auto 	;; determine if 'myMarker' should have same rotation as 'refObj'

Event OnInit()
	PlayerRef= Game.GetPlayer()
	SeranaRef= MME.rnpcActor as ObjectReference
EndEvent

Event OnTriggerEnter(ObjectReference akActionRef)
	if bIsTrigger && akActionRef == PlayerRef
		Debug.Trace("SFF: Player entered trap trigger.")
		MoveMarker(bMatchRotation)
	endif
EndEvent

Event OnActivate(ObjectReference akActionRef)
	if !bIsTrigger && akActionRef == PlayerRef
		Set2Follow()
		Debug.Trace("SFF: PLayer disabled trap. Release Serana.")
	endif
EndEvent

Function MoveMarker(bool bRotation = true)

	if MM.IsFollowing
		;SetPositions()
		myMarker.MoveTo(refObj, xOffset, yOffset, zOffset, bRotation)
		Debug.Trace("SFF: idle marker moved to wait location.")
		Set2Wait()
	endif
EndFunction

Function SetPositions()
	float GameX = refObj.GetAngleX()
	float GameZ = refObj.GetAngleZ()
	float AngleX = 90 + GameX            ;needed because without it, X rotation reads -90 to 90. We need it to read 0 to 180.
	float AngleZ
	if GameZ < 90            ;needed to convert Skyrim's Z rotation to a notation we can use in trigonometric functions and calculus.
		AngleZ = 90 - GameZ
	else
		AngleZ = 450 - GameZ
	endIf
	myMarker.MoveTo(refObj, xOffset * Math.Sin(AngleX) * Math.Cos(AngleZ), yOffset * Math.Sin(AngleX) * Math.Sin(AngleZ), zOffset * Math.Cos(AngleX)) 
EndFunction

Function Set2Wait()
	;(SeranaRef as Actor).PathToReference(myMarker, 1.0)
	MME.bWait4Trap= true
	MM.SimpleFollow= true	;; to make sure certain packages stop running;
	;MM.IsWaiting= true		;; to make sure Serana satys still when target reached.
	(SeranaRef as Actor).EvaluatePackage()
	Debug.Trace("SFF: Serana waiting4Player.")
EndFunction

Function Set2Follow()
	MME.bWait4Trap= false
	MM.SimpleFollow= false	;; to make sure certain packages stop running;
	MM.IsWaiting= false		;; to make sure Serana satys still when target reached.
	(SeranaRef as Actor).EvaluatePackage()
	Debug.Trace("SFF: Serana released from trap wait.")
EndFunction