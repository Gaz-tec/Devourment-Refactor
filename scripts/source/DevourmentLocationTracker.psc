scriptName DevourmentLocationTracker extends ActiveMagicEffect
{
	Every 2 seconds the target is moved to a position 2800 units away from their pred.
	The effect only runs outside of dialog and when the target is in a loaded cell.
}
import Logging


Actor property PlayerRef auto
Cell property StomachCell auto
DevourmentManager Property Manager auto
DevourmentDialog property DialogQuest auto
float property UpdateInterval = 1.5 autoreadonly


String PREFIX = "DevourmentLocationTracker"
bool DEBUGGING = false


bool dead = false
bool paused = false
Cell OwnedCell = none
Actor subject
ActorBase OwnedCellOwner1 = none
Faction OwnedCellOwner2 = none


float distanceMove = 1000.0
float distanceTooClose = 500.0
float distanceTooFar = 3000.0


event OnEffectStart(Actor target, Actor caster)
{ Event received when this effect is first started (OnInit may not have been run yet!) }
	subject = target

	if DEBUGGING
		Log1(PREFIX, "OnEffectStart", Namer(subject))
	endIf

	;MoveSubject(apex)
	RegisterForSingleUpdate(0.05)
	RegisterForModEvent("DevourmentVoreSleep", "OnVoreSleep")

	if subject.IsSneaking()
		Debug.SendAnimationEvent(subject, "SneakStop")
	endIf
endEvent


event OnPlayerLoadGame()
	RegisterForModEvent("DevourmentVoreSleep", "OnVoreSleep")
endEvent


event OnEffectFinish(Actor target, Actor caster)
	{ Event received when this effect ends. }
	if DEBUGGING
		Log0(PREFIX, "OnEffectFinish")
	endIf
	
	subject.stopTranslation()
	ResetCellOwners()
EndEvent


Event OnCombatStateChanged(Actor newTarget, int aeCombatState)
	if DEBUGGING
		Log1(PREFIX, "OnCombatStateChanged", "Stopping combat.")
		ConsoleUtil.PrintMessage("Stopping Combat")
	endIf

	subject.stopCombatAlarm()
	subject.stopCombat()
endEvent 


Event OnCellAttach()
	if subject == PlayerRef && PlayerRef.IsTrespassing()
		if DEBUGGING
			Log1(PREFIX, "OnCellAttach", "Preventing Trespass alarm from going off.")
			ConsoleUtil.PrintMessage("Preventing Trespass alarm from going off.")
		endIf
		StoreCellOwners()
	endIf
EndEvent


Event OnCellDetach()
	if subject == PlayerRef
		ResetCellOwners()
	endIf
EndEvent 


Event onUpdate()
{ Called repeatedly whenever the prey is not in dialogue. }

	if dead
		return
	endIf
	
	Actor apex = Manager.FindApex(subject)
	float distance = subject.GetDistance(apex)
	Cell apexCell = apex.getParentCell()
	Cell subjectCell = subject.getParentCell()

	if paused || Game.GetDialogueTarget() != none || DialogQuest.Activated
		if DEBUGGING
			Log1(PREFIX, "OnUpdate", "In dialogue -- skipping player relocation.")
		endIf

		subject.StopTranslation()

	else
		if DEBUGGING
			Log4(PREFIX, "OnUpdate", Namer(apex), Namer(apexCell), Namer(subjectCell), distance)
		endIf

		if apexCell != subjectCell ;&& (apexCell.IsInterior() || subjectCell.IsInterior())	;"This function will return false for the various interior cells in certain worldspaces due to those being classified by the game engine as being exteriors." https://ck.uesp.net/wiki/IsInInterior_-_ObjectReference
			if DEBUGGING
				Log1(PREFIX, "onUpdate", "Relocating Player to Pred's cell.")
			endIf
			ConsoleUtil.PrintMessage("Relocating Player to Pred's location.")
			MoveSubject(apex, cellChange = true)

		elseif distance > distanceTooFar || distance < distanceTooClose
			if DEBUGGING
				Log1(PREFIX, "onUpdate", "Relocating Player to an appropriate distance.")
			endIf
			MoveSubject(apex)

		endIf
	endIf
	
	RegisterForSingleUpdate(UpdateInterval)
endEvent


Event OnDeath(Actor akKiller)
	{ Event that is triggered when this actor finishes dying. }
	Log1(PREFIX, "OnDeath", "Player died!")
	dead = true
EndEvent


Event OnDying(Actor akKiller)
	{ Event that is triggered when this actor begins to die. }
	Log1(PREFIX, "OnDying", "Player dying!")
EndEvent


Function StoreCellOwners()
	ResetCellOwners()
	
	OwnedCell = PlayerRef.GetParentCell()
	if OwnedCell
		OwnedCellOwner1 = OwnedCell.GetActorOwner()
		OwnedCellOwner2 = OwnedCell.GetFactionOwner()
		Log3(PREFIX, "StoreCellOwners", Namer(OwnedCell), Namer(OwnedCellOwner1), Namer(OwnedCellOwner2))
	endIf
EndFunction


Function ResetCellOwners()
	if OwnedCell
		Log3(PREFIX, "ResetCellOwners", Namer(OwnedCell), Namer(OwnedCellOwner1), Namer(OwnedCellOwner2))
		OwnedCell.SetActorOwner(OwnedCellOwner1)
		OwnedCell.SetFactionOwner(OwnedCellOwner2)
		OwnedCell = none
		OwnedCellOwner1 = none
		OwnedCellOwner2 = none
	endIf
EndFunction


Function MoveSubject(ObjectReference center, bool cellChange = false)
	if cellChange
		if DEBUGGING
			Log1(PREFIX, "MoveSubject", "Using MoveTo().")
		endIf

		subject.moveTo(center, -distanceMove, -distanceMove, 0.0, false)

	else
		if DEBUGGING
			Log1(PREFIX, "MoveSubject", "Using TranslateTo().")
		endIf

		float px = center.GetPositionX() - distanceMove
		float py = center.GetPositionY() - distanceMove
		float pz = center.GetPositionZ()

		subject.stopTranslation()
		subject.TranslateTo(px, py, pz, 0.0, 0.0, 0.0, 1000.0)
	endIf
EndFunction


Event OnTranslationComplete()
	if DEBUGGING
		Actor apex = Manager.FindApex(subject)
		float distance = subject.GetDistance(apex)
		Log2(PREFIX, "OnTranslationComplete", distance, "Using TranslateTo(z+20).")
	endIf

	float px = subject.GetPositionX()
	float py = subject.GetPositionY()
	float pz = subject.GetPositionZ()
	subject.TranslateTo(px, py, pz + 20.0, 0.0, 0.0, 0.0, 0.01)
EndEvent


Event OnVoreSleep(Form BedRollRef)
	paused = true
	subject.stopTranslation()
	subject.MoveTo(Manager.FindApex(subject))
	(BedRollRef as ObjectReference).Activate(subject)
	paused = false
EndEvent